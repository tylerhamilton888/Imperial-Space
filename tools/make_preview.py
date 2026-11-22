#!/usr/bin/env python3
"""Create a bounded review derivative without changing the source image."""
import argparse
from io import BytesIO
from pathlib import Path
import sys
import warnings

from PIL import Image, ImageColor, ImageOps

LIMITS = {"preview": (1280, 600), "reference": (1600, 750)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--profile", choices=tuple(LIMITS), default="preview")
    parser.add_argument("--max-side", type=int, help="May reduce, never exceed, the profile limit.")
    parser.add_argument("--max-kib", type=int, help="May reduce, never exceed, the profile limit.")
    parser.add_argument("--background", help="Explicit background color when flattening alpha to JPEG, e.g. '#20252A'.")
    args = parser.parse_args()
    side_limit, kib_limit = LIMITS[args.profile]
    max_side = args.max_side if args.max_side is not None else side_limit
    max_kib = args.max_kib if args.max_kib is not None else min(300, kib_limit)
    if not (64 <= max_side <= side_limit and 1 <= max_kib <= kib_limit):
        parser.error(f"Allowed max-side 64..{side_limit}; max-kib 1..{kib_limit}.")
    if args.source.resolve() == args.output.resolve():
        parser.error("Source and output must be different files.")
    if args.output.exists():
        parser.error("Output already exists; choose a new derivative name.")
    suffix = args.output.suffix.lower()
    if suffix not in {".jpg", ".jpeg", ".png"}:
        parser.error("Output must be .jpg, .jpeg or .png.")
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("error", Image.DecompressionBombWarning)
            with Image.open(args.source) as source:
                if getattr(source, "n_frames", 1) > 1:
                    raise ValueError("Animated input unsupported; choose a static frame.")
                source.load()
                im = ImageOps.exif_transpose(source).convert("RGBA")
        has_alpha = im.getextrema()[3][0] < 255
        if suffix != ".png":
            if has_alpha and not args.background:
                raise ValueError("Transparent source requires PNG output or an explicit --background.")
            if has_alpha:
                background = Image.new("RGBA", im.size, ImageColor.getcolor(args.background, "RGB") + (255,))
                im = Image.alpha_composite(background, im)
            im = im.convert("RGB")
        elif not has_alpha:
            im = im.convert("RGB")
        im.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
        candidate = None
        while True:
            qualities = (88, 80, 72, 64, 55, 45) if suffix != ".png" else (None,)
            for quality in qualities:
                buf = BytesIO()
                if quality is None:
                    im.save(buf, format="PNG", optimize=True)
                else:
                    im.save(buf, format="JPEG", quality=quality, optimize=True, progressive=True)
                if buf.tell() <= max_kib * 1024:
                    candidate = buf.getvalue()
                    break
            if candidate is not None:
                break
            longest = max(im.size)
            if longest <= 64:
                raise ValueError("Cannot meet byte budget at usable preview size; no file written.")
            next_side = max(64, int(longest * 0.85))
            im.thumbnail((next_side, next_side), Image.Resampling.LANCZOS)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("xb") as out:
            out.write(candidate)
        print(f"WROTE {args.output.name}: {im.width}x{im.height}, {len(candidate)/1024:.1f} KiB; source unchanged")
        return 0
    except (OSError, ValueError, Image.DecompressionBombError, Image.DecompressionBombWarning) as exc:
        print(f"ERROR: {str(exc)[:300]}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
