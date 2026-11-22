#!/usr/bin/env python3
"""Read-only image budget check. Project budgets, not platform upload limits."""
import argparse
import json
from pathlib import Path
import sys
import warnings

from PIL import Image, UnidentifiedImageError

SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".tga", ".bmp"}
BUDGETS = {
    "preview": (1280, 600 * 1024),
    "reference": (1600, 750 * 1024),
    "frame": (1024, 1024 * 1024),
    "atlas": (2048, 3 * 1024 * 1024),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="+", type=Path)
    parser.add_argument("--profile", choices=("preview", "reference", "runtime"), required=True)
    parser.add_argument("--kind", choices=("frame", "atlas"), help="Required for runtime; forbidden otherwise.")
    parser.add_argument("--report", type=Path, help="Write complete JSON report to a new file, not stdout.")
    args = parser.parse_args()
    if (args.profile == "runtime") != bool(args.kind):
        parser.error("Use --kind frame|atlas exactly when --profile runtime is selected.")
    if args.report and args.report.exists():
        parser.error("Report already exists; choose a new report path.")
    profile = args.kind if args.profile == "runtime" else args.profile
    side_limit, byte_limit = BUDGETS[profile]
    errors, records, files = [], [], set()
    for path in args.paths:
        if not path.exists():
            errors.append(f"Missing path: {path}")
        elif path.is_dir():
            found = {p.resolve() for p in path.rglob("*")
                     if p.is_file() and p.suffix.lower() in SUFFIXES
                     and not any(x in {".git", ".godot"} for x in p.parts)}
            if not found:
                errors.append(f"No supported images found: {path}")
            files.update(found)
        elif path.suffix.lower() not in SUFFIXES:
            errors.append(f"Unsupported image extension: {path}")
        else:
            files.add(path.resolve())
    for path in sorted(files):
        try:
            size = path.stat().st_size
            with warnings.catch_warnings():
                warnings.simplefilter("error", Image.DecompressionBombWarning)
                with Image.open(path) as im:
                    width, height = im.size
                    animated = getattr(im, "n_frames", 1) > 1
                    im.verify()
                if max(width, height) <= side_limit:
                    with Image.open(path) as im:
                        im.load()  # JPEG truncation is not always caught by verify().
            row = {"path": str(path), "width": width, "height": height,
                   "bytes": size, "rgba_bytes_estimate": width * height * 4}
            records.append(row)
            if max(width, height) > side_limit:
                errors.append(f"Dimensions {width}x{height} exceed {side_limit}px: {path.name}")
            if size > byte_limit:
                errors.append(f"Size {size} bytes exceeds {byte_limit}: {path.name}")
            if animated:
                errors.append(f"Animated image unsupported; export static frames: {path.name}")
        except (OSError, ValueError, UnidentifiedImageError,
                Image.DecompressionBombError, Image.DecompressionBombWarning) as exc:
            errors.append(f"Unreadable image {path.name}: {str(exc)[:160]}")
    result = {"profile": profile, "side_limit": side_limit, "byte_limit": byte_limit,
              "images_checked": len(files), "total_bytes": sum(x["bytes"] for x in records),
              "images": records, "errors": errors, "passed": not errors}
    if args.report:
        try:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            with args.report.open("x", encoding="utf-8") as out:
                json.dump(result, out, indent=2)
                out.write("\n")
        except OSError as exc:
            print(f"ERROR writing report: {exc}", file=sys.stderr)
            return 2
    print(f"{'PASS' if not errors else 'FAIL'}: {len(files)} images; {profile}; "
          f"{result['total_bytes'] / 1024:.1f} KiB total; {len(errors)} errors")
    for error in errors[:20]:
        print(f"ERROR: {error}")
    if len(errors) > 20:
        print(f"{len(errors) - 20} further errors omitted; use --report for details.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
