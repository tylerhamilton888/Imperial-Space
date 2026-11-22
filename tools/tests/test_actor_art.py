"""Offline checks for the directional plates consumed by the Godot actor view.

Run with python -m unittest discover -s tools/tests -p test_actor_art.py.
"""
import json
import math
import re
import unittest
from pathlib import Path

from PIL import Image, ImageChops

ART = Path(__file__).resolve().parents[2] / "game" / "art"
ACTORS = ART / "actors"
HEADINGS = 8
ROWS_PER_PAGE = 8

# Ignore faint resampling fringes when looking for material on a crop boundary.
# A cell must contain at least 64 pixels at >= 12.5% opacity, with at least one
# pixel of clearance on every side. A nearly empty speck cannot pass as a pose.
SOLID_ALPHA = 32
MIN_MATERIAL = 64

# Compare a composited actor on a neutral backdrop. A changed pixel needs a
# difference of 18/255 in at least one displayed RGB channel. Measure it as a
# fraction of the two silhouettes, excluding their transparent surroundings.
CHANNEL_STEP = 18
MOTION_FRACTION = 0.025


def displayed_difference(first, second):
    def composite(image):
        canvas = Image.new("RGB", image.size, (25, 28, 34))
        canvas.paste(image, (0, 0), image.getchannel("A"))
        return canvas

    channels = ImageChops.difference(composite(first), composite(second)).split()
    delta = ImageChops.lighter(ImageChops.lighter(channels[0], channels[1]), channels[2])
    footprint = ImageChops.lighter(first.getchannel("A"), second.getchannel("A"))
    changed = sum(delta.histogram()[CHANNEL_STEP:])
    material = sum(footprint.histogram()[SOLID_ALPHA:])
    return changed / max(1, material)


class ActorArtTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.roles = json.loads((ACTORS / "poses.json").read_text())
        cls.pages = {}
        for role, record in cls.roles.items():
            total_rows = max(first + count for first, count in record["poses"].values())
            for index in range(math.ceil(total_rows / ROWS_PER_PAGE)):
                rows = min(ROWS_PER_PAGE, total_rows - index * ROWS_PER_PAGE)
                with Image.open(ACTORS / f"{role}_{index}.webp") as file:
                    cls.pages[role, index] = (file.convert("RGBA"), rows)

    @classmethod
    def tearDownClass(cls):
        for page, _ in cls.pages.values():
            page.close()

    def cell(self, role, row, heading):
        page_number, local_row = divmod(row, ROWS_PER_PAGE)
        page, row_count = self.pages[role, page_number]
        w, h = page.width // HEADINGS, page.height // row_count
        return page.crop((heading*w, local_row*h, (heading+1)*w, (local_row+1)*h))

    def test_scene_registry_matches_published_pages(self):
        # The view loads the pages in role and index order. Check the actual
        # resource paths as well as disk; stale atlas files can hide mistakes.
        source = (ART / "actor_view.gd").read_text()
        registry = {}
        for role, entries in re.findall(r'&?"(\w+)"\s*:\s*\[([^\]]*)\]', source):
            names = re.findall(r'res://art/actors/([^"]+\.webp)', entries)
            if names:
                registry[role] = names
        expected = {role: [] for role in self.roles}
        for role, page in sorted(self.pages):
            expected[role].append(f"{role}_{page}.webp")
        self.assertEqual(registry, expected)
        self.assertEqual(
            {name for names in expected.values() for name in names},
            {file.name for file in ACTORS.glob("*.webp")},
        )

    def test_ranges_and_eight_column_geometry(self):
        for role, record in self.roles.items():
            with self.subTest(role=role):
                self.assertIn("idle", record["poses"])
                self.assertEqual(len(record["muzzle"]), HEADINGS)
                for anchor in record["muzzle"]:
                    self.assertEqual(len(anchor), 2)
                    self.assertTrue(all(math.isfinite(x) for x in anchor))
                used_rows = set()
                for first, count in record["poses"].values():
                    self.assertIs(type(first), int)
                    self.assertIs(type(count), int)
                    self.assertGreaterEqual(first, 0)
                    self.assertGreater(count, 0)
                    used_rows.update(range(first, first + count))
                # Named aliases may intentionally reuse an existing pose.
                self.assertEqual(used_rows, set(range(max(used_rows) + 1)))
                sizes = set()
                for (name, index), (page, rows) in self.pages.items():
                    if name != role:
                        continue
                    self.assertEqual(page.width % HEADINGS, 0, f"page {index} width")
                    self.assertEqual(page.height % rows, 0, f"page {index} height")
                    sizes.add((page.width // HEADINGS, page.height // rows))
                self.assertEqual(len(sizes), 1, "all pages of one role use the same cell")
                w, h = sizes.pop()
                self.assertEqual(tuple(record["cell"]), (w, h), "renderer must sample the actual cell")
                px, py = record["pivot"]
                self.assertTrue(0 <= px < w and 0 <= py < h, "feet pivot outside the cell")

    def test_every_declared_cell_is_visible_and_unclipped(self):
        for role, record in self.roles.items():
            for action, (first, count) in record["poses"].items():
                for row in range(first, first + count):
                    for heading in range(HEADINGS):
                        with self.subTest(role=role, action=action, row=row, heading=heading):
                            alpha = self.cell(role, row, heading).getchannel("A")
                            self.assertGreaterEqual(sum(alpha.histogram()[SOLID_ALPHA:]), MIN_MATERIAL)
                            left, top, right, bottom = alpha.point(lambda v: 255 if v >= SOLID_ALPHA else 0).getbbox()
                            clearance = min(left, top, alpha.width-right, alpha.height-bottom)
                            self.assertGreaterEqual(clearance, 1, "material touches a cell edge")

    def test_motion_and_attack_silhouettes(self):
        # Idle-only props may legitimately share a drawing across all headings.
        # Static holds at the beginning or end of an attack may also be repeated.
        for role, record in self.roles.items():
            poses = record["poses"]
            for action in ("walk", "windup", "melee", "fire"):
                if action not in poses:
                    continue
                first, count = poses[action]
                for heading in range(HEADINGS):
                    with self.subTest(role=role, action=action, heading=heading):
                        frames = [self.cell(role, row, heading) for row in range(first, first + count)]
                        if count == 1:
                            # A held telegraph should differ from idle, and the
                            # released shot should differ from that telegraph.
                            previous = poses.get("windup", poses["idle"]) if action == "fire" else poses["idle"]
                            frames.insert(0, self.cell(role, previous[0] + previous[1] - 1, heading))
                        distinct = []
                        for frame in frames:
                            if all(displayed_difference(frame, other) >= MOTION_FRACTION for other in distinct):
                                distinct.append(frame)
                        required = 3 if action == "walk" and count >= 3 else 2
                        self.assertGreaterEqual(len(distinct), required, "too few visibly different keyframes")


if __name__ == "__main__":
    unittest.main()
