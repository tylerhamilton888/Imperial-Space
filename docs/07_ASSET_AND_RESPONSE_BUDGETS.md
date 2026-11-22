# Asset and response budgets

## Purpose and authority

The user reported that oversized images were associated with broken ChatGPT responses in earlier work. The original failure logs have not been diagnosed here. These are conservative **project budgets and working practices**, not statements of ChatGPT's hard limits or a guarantee against every rendering failure. The objective is a responsive development loop with modest previews, traceable originals and predictable runtime imports.

Keep this document authoritative for budget values. Tool behavior and exact commands are in [the asset tools guide](../tools/README.md). Record a justified exception in `DECISION_LOG.md` before introducing a larger production asset; do not silently raise every limit to accommodate one file.

## Separate source art from runtime art

Keep high resolution originals in an art source location outside the Godot project import tree. The handoff's `reference_art` contains compact review derivatives, not textures to drop into gameplay. If reference documents are copied inside the game repository, put `.gdignore` in their folder so they are excluded from Godot resource import. Maintain original filename/source, selected feature, derivative filename, dimensions and intended use in the art manifest. Keep any licensing and provenance information with purchased or commissioned assets.

An attractive armor concept does not constitute a working sprite. Its gameplay derivative must pass the camera-scale test, directional pose test, pivot check, animation check and silhouette readability check. Do not reuse a whole concept sheet as a character texture or trim sprites by eye without stable ground pivots.

| Asset type | Working target | Project ceiling | Response practice |
| --- | --- | --- | --- |
| Screenshot or chat preview | 960–1280 pixel long edge; 100–300 KiB | 1280 pixel long edge; 600 KiB | Show one or two useful images per update |
| Curated concept reference | Up to 1600 pixel long edge | 1600 pixels; 750 KiB | Link the file; embed selectively |
| Individual runtime frame | Sized for actual camera use, often far below ceiling | 1024 pixel long edge; 1 MiB encoded | Inspect contact sheets or small crops |
| Runtime atlas | Enough related frames for one use case | 2048 × 2048 maximum; 3 MiB encoded | Split by direction, animation or family |
| Raw source | Preserve the useful original | Review any individual file above 8 MiB before importing or adding to source control | Keep outside normal chat and runtime import |

The checker enforces image ceilings, not the source-art review threshold. Do not make 8192 pixel atlases by default. Do not downsize production artwork merely to fit a chat preview: create a separate derivative. File size and dimensions both matter. An uncompressed RGBA image uses `width × height × 4` bytes for one level: 2048 × 2048 is 16 MiB and 4096 × 4096 is 64 MiB. A full mip chain is roughly one third extra before implementation-specific overhead. Actual GPU formats, import compression and allocation behavior must be measured; a small PNG or JPEG on disk does not establish a small runtime memory footprint.

## Preview workflow

1. Preserve the original. Give the review image a separate descriptive name.
2. Use the preview utility to bound dimensions and encoded bytes. Opaque concept art normally uses JPEG. Preserve alpha with PNG when transparency is relevant; flatten only with an explicit background choice.
3. Run the checker on the intended output profile. Inspect the resulting image at the actual review scale; a technically small but illegible contact sheet is not useful.
4. Report filenames, dimensions, byte counts and the design question the preview answers. Never print binary, a base64 data URL, an entire generated image response or a huge serialized resource into chat or logs.
5. Show one or two derivatives and link the remainder. For a larger comparison, make a compact contact sheet with legible labels and provide individual files separately.

The supplied `make_preview.py` only resizes and compresses. It does not create missing views, repair anatomical inconsistencies or manufacture animation frames. It will refuse to overwrite an existing file or flatten transparency into JPEG without an explicit background.

## Runtime and repository discipline

Import only assets the current milestone uses. Keep the art and runtime manifests small and task-oriented. Add `.godot/`, build exports, generated caches, temporary renders and tool environments to appropriate ignore rules. Keep original authoring files separate from exported runtime files. Do not commit source material, generated previews and every conversion intermediate together without a reason.

Use stable asset identifiers and a minimal naming scheme such as `crusader_medium_south_idle`, `khorgoth_raider_west_attack` and `district_wall_breached`. Keep common pixels-per-world-unit, feet pivots, weapon sockets and material/lighting conventions documented. Do not let imported content silently change physics collision size.

Check frame folders with the frame profile and atlas folders with the atlas profile; a generous atlas limit must not accidentally bless oversized single-frame sprites. The checker does not validate rig quality, engine import settings, licenses or memory pressure. Work Mode still needs a native-scale scene review and profiling on an identified test machine.

## Context and output discipline

Keep current state in concise Markdown files, with links to evidence instead of pasted logs. `PROGRESS.md` should answer what runs, what was tested, current blockers and the next concrete task; aim for fewer than 150 lines. Put durable decisions in `DECISION_LOG.md` and detailed test evidence in `TEST_REPORT.md`. Load only the relevant design chapter and latest progress for a task. Do not reprint the full design bible in every turn.

Tool stdout should be bounded and human-readable. Write long reports to files. Batch independent reads, but keep dependent edits and validations ordered. Before sending a response, check that linked files exist, previews meet budgets, and no raw image payload or full import log has entered the message. If a preview cannot be displayed, provide its file link and a brief factual description; do not retry the same oversized payload repeatedly.

## Acceptance

The packet and each art handoff must have no missing reference links, no unexplained oversized preview, and no binary/base64 content in Markdown. Runtime imports remain separate from reference originals. The asset checker exits nonzero for missing targets, unreadable images, unsupported animation and budget violations. Successful asset checks establish only those checks; they are not evidence that the game itself runs.
