# Asset export checklist

Use the [art direction](03_ART_DIRECTION.md) and [reference interpretation](../reference_art/README.md) for silhouette, surface treatment and color. The [asset budgets](07_ASSET_AND_RESPONSE_BUDGETS.md) specify limits for frames, atlases, previews and reference boards.

1. Preserve reusable source paintings and packing code under `source_art/`. Production textures go under `game/art/`. Keep source PNGs outside the Godot import tree. The option B studies guide art direction.
2. Use the current packers below from the repository root. They export into the live game. Preserve shared pose metadata when repacking one role. Keep each role’s cell and pivot from the [manifest](ART_ASSET_MANIFEST.md). Recheck muzzle positions after changing the rifle art.
3. Check all frame and atlas outputs with the appropriate profile. SVGs have separate dimension and hotspot checks. Run source and preview checks on their own paths. Preserve full-size sources when creating derivatives.
4. Reimport with the pinned Godot version. Inspect the release at the native 1280 × 720 game view. Test eight headings, circling gait, backward steps, guard, rifle, blade contacts, defeat, cloak visibility and readability over the floor. Check the shield and rail occlude actors at their ground pivots. Verify aim sockets and shot obstruction in motion.
5. Update the manifest when an image, packing recipe or source changes. Record the count, dimensions and encoded byte size for the exported file. Give review captures separate filenames and check them with the preview profile before sharing.

## Active recipes

| Asset | Rebuild from the saved master | Dependencies |
| --- | --- | --- |
| Medium Crusader, weapons and cloak | `python source_art/actors/crusader/pack.py` | Python, Pillow, NumPy, SciPy |
| Raider, gunner, range officer and target | `python source_art/actors/khorgoth/build.py` | Python, Pillow, NumPy, SciPy |
| Forecourt, two shields, inspection desk and crew rail | `python source_art/range/pack_painted_range.py` | Python, Pillow |
| Orbital shipyard title | [Title export recipe](../source_art/menu/README.md) | Python, Pillow |
| HUD inlays, vitality glass, fleet crest and panel frame | `python source_art/hud/forge_instruments.py` | Python, Pillow, Inkscape |
| Application icon and cursor | Edit `game/art/standard.svg` and `game/art/aim_cursor.svg` | SVG editor or text editor |

The four deck tiles must join at world x = 800 and y = 420 (the canvas starts at y = −120). The actor runtime samples eight columns clockwise from screen right and looks up its action and muzzle data in `game/art/actors/poses.json`. Keep hit detection and gameplay collision feet-anchored as the paintings change.

## Preflight commands

```sh
python tools/check_assets.py --profile runtime --kind atlas game/art/actors
python tools/check_assets.py --profile runtime --kind frame game/art/range game/art/menu game/art/hud
python tools/check_assets.py --profile reference reference_art
godot --headless --path game --editor --import
godot --headless --path game --script ../tools/tests/verify_range_map.gd
```

For a capture, run `tools/make_preview.py` using the [asset tools guide](../tools/README.md), then `python tools/check_assets.py --profile preview <preview-file>`. The image checker measures file bounds and decoding. The native-view checks cover registration, motion and combat readability.
