# Scene kit production sources

| Accepted board | Original lossless source paintings | Output |
| --- | --- | --- |
| 07 Proving Ground | `proving.webp`, `range_kit.webp` | Empty range, target, terminal and matching two-state wall |
| 08 Karth Vale wide | `district.webp`, `street_kit.webp` | District, planter, stairs, wreck and transit sign |
| 09 Cruiser Bridge | `bridge.webp`, `bridge_kit.webp`, `crew_kit.webp` | Bridge, command furnishings, holomap, Vale, social Crusader, operator and guard |
| 10 Heavy Proving Ground | `heavy_kit.webp` | Two cannon views and two hammer poses |

The paintings were generated for this project with the owner-selected image as the visual reference. The interface icon interiors and Captain Vale portrait are crops from boards 08–10. Scene labels, readouts, dialogue and review controls render separately.

`pack.py` reads the masters, the review JPEGs in `reference_art/`, the live game's actor sheets, and the [crop and size definitions](objects.json). It regenerates textures under `art_studies/`. Prop pivots, shadows, scene composition and overlay layout are authored in the Godot scenes. Full-size source dimensions and file sizes are in [the inventory](inventory.json).

To verify, import and run from the repository root:

```sh
godot --headless --path art_studies --editor --import
godot --headless --path art_studies --script ../source_art/scene_targets/verify.gd
python tools/check_assets.py --profile runtime --kind frame art_studies/kits art_studies/review/scale
```

For native captures set `ART_STUDY_CAPTURES` to an existing output folder and run the verification script with a rendered display. Each resulting JPEG is a view of the art project.
