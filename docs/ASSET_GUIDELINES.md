# Asset Export Checklist

Read `03_ART_DIRECTION.md` for the visual contract and `07_ASSET_AND_RESPONSE_BUDGETS.md` for authoritative budgets. This file is the short working checklist, not a duplicate art bible.

1. Confirm the asset's gameplay role, camera scale, pivot, facing coverage and status.
2. Preserve its source and provenance. Store raw concepts outside `game/`.
3. Export only the required runtime size and format. Keep alpha where the sprite needs it.
4. Validate dimensions, decoding and file bytes with the appropriate `tools/check_assets.py` profile.
5. Test animation, layering, collisions and readability in the actual arena.
6. Create a separate compressed preview if a visual report is useful; never print image data or a giant atlas into tool output.
7. Update `ART_ASSET_MANIFEST.md` and report any budget exception with its reason.

One successful high-resolution portrait does not establish a production-ready animation pipeline. Inspect at gameplay scale.
