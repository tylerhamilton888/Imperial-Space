# Asset review utilities

These small Python tools enforce **this project's review budgets**. They do not test ChatGPT limits or game performance. They never alter an input image. Install Pillow in a project environment; the range below is a compatibility constraint, not a claim that every release has been tested.

The handoff's utility checks were run with Python 3.12.14 and Pillow 13.0.0. Eleven focused tests passed: valid image/report, excessive dimensions, excessive encoded bytes, missing/corrupt input, frame versus atlas budgets, preview limits/source preservation/overwrite refusal, transparent output/explicit flattening, empty directory failure, truncated JPEG rejection, symlink safety and alpha-bearing background colors. These are utility tests; no game execution is implied.

```bash
python -m pip install -r tools/requirements.txt
python tools/tests/test_asset_tools.py
python tools/check_assets.py reference_art --profile reference
python tools/check_assets.py assets/characters --profile runtime --kind frame
python tools/check_assets.py assets/atlases --profile runtime --kind atlas --report qa/atlas_report.json
python tools/make_preview.py source.png previews/armor_review.jpg --max-side 1280 --max-kib 300
python tools/make_preview.py transparent_source.png previews/armor_alpha.png --max-kib 600
python tools/check_assets.py previews --profile preview
```

Run from the handoff or game repository root as appropriate. Example asset folders are created by Work Mode as the game is implemented; they are not included game assets.

`check_assets.py` accepts files or directories. It recursively checks PNG, JPEG, WebP, TGA and BMP files, skips `.git` and `.godot`, deduplicates paths, checks decoding, dimensions and encoded size, and rejects animated images. It reports at most 20 individual errors to stdout. `--report` writes full JSON to a **new** file. A missing path or directory with no supported images fails; nothing silently passes as a checked asset collection. Mixed frame and atlas folders must be checked separately with the appropriate runtime kind.

| Profile | Maximum side | Per image encoded ceiling |
| --- | ---: | ---: |
| preview | 1280 pixels | 600 KiB |
| reference | 1600 pixels | 750 KiB |
| runtime frame | 1024 pixels | 1 MiB |
| runtime atlas | 2048 pixels | 3 MiB |

`make_preview.py` defaults to a 1280 pixel, 300 KiB derivative. Use `--profile reference` for the 1600 pixel ceiling; `--max-kib 750` permits its larger byte budget. Options can lower limits, never raise a profile's ceiling. The script reduces JPEG quality and then dimensions until the byte budget is met; this is a review image, never an automatic replacement for a production sprite. PNG retains transparency. JPEG output from a transparent source requires an explicit `--background '#20252A'`; a background color's alpha component is ignored because JPEG flattening uses an opaque background. Source and destination must differ, and an existing destination is never overwritten. A failed conversion returns a nonzero exit code.

Checker exit codes: `0` pass, `1` asset failure, `2` invocation/report failure. Preview exit codes: `0` written, nonzero failed. Never embed a resulting file as base64 in logs or chat. Link the derivative and keep originals separate.
