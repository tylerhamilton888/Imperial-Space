# Art Asset Manifest

The user supplied these five concept studies from earlier conversations. Their compact derivatives live in `reference_art/`. Original names and hashes are recorded in [source_manifest.json](../reference_art/source_manifest.json).

| Asset | Purpose | Dimensions | Bytes | Status |
| --- | --- | --- | --- | --- |
| `01_visual_style.jpg` | Concept reference | 1536 × 1024 | 497,894 | Compressed derivative; outside runtime |
| `02_cloaks_and_weapons.jpg` | Concept reference | 1536 × 1024 | 419,310 | Compressed derivative; outside runtime |
| `03_helmet_variants.jpg` | Concept reference | 1536 × 1024 | 426,055 | Compressed derivative; outside runtime |
| `04_armor_weights.jpg` | Concept reference | 1536 × 1024 | 422,098 | Compressed derivative; outside runtime |
| `05_heavy_collar_variants.jpg` | Concept reference | 1536 × 1024 | 397,564 | Compressed derivative; outside runtime |

## Developer Arena art, version 0.1.0

All runtime visuals and sound cues below are original Imperial Space prototypes created for this repository. The concept studies informed costume shapes and color choices. The runtime sprites, environments and audio were authored independently. Retain the editable sources with the derivatives.

### Directional actors

Files live under `game/art/actors/`. [bake.py](../source_art/actors/bake.py) builds the rig and animation poses, and [raster.c](../source_art/actors/raster.c) renders the lit surfaces. Each plate has eight facing columns, clockwise from screen right. Every 204 × 174 cell uses the same foot pivot (102, 143) with 1.5 texture pixels per world unit. The generated `poses.json` supplies row ranges and muzzle offsets to [actor_view.gd](../game/art/actor_view.gd).

| File | Pixels | Encoded bytes |
| --- | --- | ---: |
| `crusader_0.webp` | 1632 × 1392 | 304,598 |
| `crusader_1.webp` | 1632 × 1392 | 309,026 |
| `crusader_2.webp` | 1632 × 1392 | 300,368 |
| `crusader_3.webp` | 1632 × 696 | 145,704 |
| `dummy_0.webp` | 1632 × 174 | 19,214 |
| `gunner_0.webp` | 1632 × 1392 | 282,706 |
| `gunner_1.webp` | 1632 × 870 | 167,534 |
| `raider_0.webp` | 1632 × 1392 | 311,646 |
| `raider_1.webp` | 1632 × 1392 | 299,600 |
| `raider_2.webp` | 1632 × 348 | 68,618 |
| `soldier_0.webp` | 1632 × 174 | 18,426 |

The medium Crusader has idle, eight walking poses, fire, melee, guard, parry, reload, heal, dodge, stagger and defeat. The crimson cloak, helmet and weapon accompany every pose. Raider and gunner plates cover idle, walk, windup, attack, stagger and defeat. The range dummy and human defender have eight stationary views each. Together these sheets hold 488 directional frames.

### Environment and interface

Paths below are relative to `game/art/`. [build_range.py](../source_art/range/build_range.py) generates the original orthographic Blender scene. [split_range.py](../source_art/range/split_range.py) crops the deck and transparent props. Prop pivots are listed as texture pixels from the upper-left corner and correspond to ground contact for depth sorting.

| File | Purpose or pivot | Pixels | Encoded bytes |
| --- | --- | --- | ---: |
| `range/crew_rail.webp` | Crew rail (80, 56) | 159 × 61 | 6,106 |
| `range/north_cover.webp` | North cover (90, 82) | 180 × 87 | 16,040 |
| `range/south_cover.webp` | South cover (85, 82) | 170 × 87 | 13,530 |
| `range/deck_0_0.webp` | Northwest deck, top left | 800 × 480 | 59,776 |
| `range/deck_0_1.webp` | Southwest deck, top left | 800 × 480 | 43,276 |
| `range/deck_1_0.webp` | Northeast deck, top left | 800 × 480 | 96,278 |
| `range/deck_1_1.webp` | Southeast deck, top left | 800 × 480 | 68,604 |
| `menu/orbital_watch.jpg` | Title-screen cruiser and orbital horizon | 1024 × 576 | 80,619 |
| `standard.svg` | Title crest and application icon | 96 × 96 | 362 |
| `aim_cursor.svg` | Aim reticle, hotspot (16, 16) | 32 × 32 | 378 |

[render_orbit.py](../source_art/menu/render_orbit.py) creates the menu illustration. The two SVGs are their own editable sources. UI panels, lane diagnostics and contact shadows are drawn in Godot.

### Combat feedback

[feedback.gd](../game/combat/feedback.gd) draws short-lived tracers and sparks and synthesizes the sounds for gunfire, attacks, dodges, defense, reloads, healing and impacts. Each cached mono cue runs for 0.17 s at 22,050 Hz, 16-bit PCM (7,496 sample bytes). The project ships the synthesis code.
