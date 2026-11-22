# Asset export checklist

Use the [art direction](03_ART_DIRECTION.md) for the character and camera targets and the [budget specification](07_ASSET_AND_RESPONSE_BUDGETS.md) for encoded size and dimensions.

1. Identify the asset’s role at the 1280 × 720 native view. Preserve editable sources under `source_art/`, reference studies under `reference_art/`, and runtime imports under `game/art/`.
2. Rebuild actors with `python source_art/actors/bake.py` (Python 3, NumPy, Pillow and a C compiler). Keep the 204 × 174 cell, foot pivot (102, 143), eight heading columns and matching `poses.json`. Check every cell for clipping, including the sword tip during windup.
3. Rebuild the range with Blender and the crop script in `source_art/range/`. Keep the deck tile edges aligned and preserve the cover and rail ground pivots. Use `source_art/menu/render_orbit.py` for the title artwork. Edit the HUD crest and reticle directly in their SVG sources.
4. Run the checker with the profile for each file type. Use `python tools/check_assets.py game/art/actors --profile runtime --kind atlas` for actor sheets and `python tools/check_assets.py game/art/menu game/art/range --profile runtime --kind frame` for baked scenery. Check SVG dimensions, hotspots and Godot import separately.
5. Inspect a native gameplay capture and moving actors. Check alternating boots, cloth continuity, near/far hand and weapon ordering, cover occlusion, and the correspondence between muzzle position and shot feedback.
6. Update the [asset manifest](ART_ASSET_MANIFEST.md) with source, status, dimensions and encoded bytes. Create a separate review image with `tools/make_preview.py` and run the preview profile before sharing. Record any budget exception in the decision log.
