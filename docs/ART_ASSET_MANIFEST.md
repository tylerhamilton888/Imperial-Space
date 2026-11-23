# Art Asset Manifest

The user supplied these five concept studies from earlier conversations. Their compact derivatives live in `reference_art/`. Original names and hashes are recorded in [source_manifest.json](../reference_art/source_manifest.json).

| Asset | Purpose | Dimensions | Bytes | Status |
| --- | --- | --- | --- | --- |
| `01_visual_style.jpg` | Concept reference | 1536 × 1024 | 497,894 | Compressed derivative; outside runtime |
| `02_cloaks_and_weapons.jpg` | Concept reference | 1536 × 1024 | 419,310 | Compressed derivative; outside runtime |
| `03_helmet_variants.jpg` | Concept reference | 1536 × 1024 | 426,055 | Compressed derivative; outside runtime |
| `04_armor_weights.jpg` | Concept reference | 1536 × 1024 | 422,098 | Compressed derivative; outside runtime |
| `05_heavy_collar_variants.jpg` | Concept reference | 1536 × 1024 | 397,564 | Compressed derivative; outside runtime |

## Gameplay art target

The owner supplied [Karth Vale](../reference_art/06_karth_vale_art_target.jpg) as the reference for whole-scene art acceptance. The 1600 × 900 JPEG (699,607 bytes) is a review derivative of the supplied 1672 × 941 PNG. Source identity is recorded in the [source manifest](../reference_art/source_manifest.json). Keep this concept outside the runtime.

## Scene art kit

Four separately indexed owner-provided targets (07–10) are recorded in the [reference manifest](../reference_art/source_manifest.json). The three clean environment plates and five original transparent prop/actor sheets were generated with OpenAI ImageGen using their respective concept images. Full-resolution lossless masters are in [source_art/scene_targets/masters](../source_art/scene_targets/masters). The target-to-source mapping is in [production notes](../source_art/scene_targets/README.md).

The separate Godot art project contains twelve backdrop tiles, twenty prop and character frames, nine cropped action icons, a cropped Vale portrait and five scale fixtures from the 0.1.2 arena. The [inventory](../source_art/scene_targets/inventory.json) records dimensions and exact bytes for every master and exported texture. These are staged production studies. The wall has two visual states at a shared origin. Heavy has four poses.

## Developer Arena 0.1.2 environment kit

Original ImageGen plates guided by the owner-supplied Karth Vale concept. Three lossless source paintings live under `source_art/range/`. The packer registers the painted paving to the rectangular play area and cuts the fixtures around their feet. The signs, actors, cast shadows and HUD render in Godot. The 0.1.1 section below records the previous kit.

| Asset | Pixels | Bytes |
| --- | ---: | ---: |
| `source_art/range/arsenal_fixtures.webp` | 2172 × 724 | 1,122,932 |
| `source_art/range/arsenal_forecourt.webp` | 1619 × 971 | 2,269,730 |
| `source_art/range/inspection_desk.webp` | 1774 × 887 | 1,237,472 |
| `game/art/range/crew_rail.webp` | 159 × 61 | 6,120 |
| `game/art/range/deck_0_0.webp` | 800 × 540 | 177,668 |
| `game/art/range/deck_0_1.webp` | 800 × 540 | 155,262 |
| `game/art/range/deck_1_0.webp` | 800 × 540 | 180,824 |
| `game/art/range/deck_1_1.webp` | 800 × 540 | 151,716 |
| `game/art/range/inspection_desk.webp` | 94 × 49 | 5,882 |
| `game/art/range/north_cover.webp` | 180 × 87 | 13,420 |
| `game/art/range/south_cover.webp` | 170 × 87 | 12,414 |

The four 800 × 540 tiles cover world coordinates (0, −120) to (1600, 960). The inspection desk and rail form one staffed station. Both barriers share the same design and register to their existing collision widths. Use these independently sorted pieces when assembling another civic encounter. The forecourt panorama remains specific to this location.

## Developer Arena 0.1.1

This release includes new project-specific paintings generated with OpenAI ImageGen and original code-authored graphics. Source paths below identify which process produced each asset. The earlier runtime inventory is recorded at Git tag `arena-v0.1.0`.

### Source paintings

Keep the full-resolution masters in `source_art/`. The generation notes document the art direction and reference inputs. Asset packing uses the saved paintings. Live labels, combat state and actor positions are drawn by the game.

| Master under `source_art/` | Source pixels | Encoded bytes | Runtime purpose |
| --- | --- | ---: | --- |
| `actors/crusader/axial.png` | 1254 × 1254 | 1,595,534 | Crusader axial headings |
| `actors/crusader/low.png` | 1536 × 1024 | 2,236,506 | Crusader low defensive and downed poses |
| `actors/crusader/ready.png` | 1536 × 1024 | 2,318,773 | Crusader ready and weapon presentation |
| `actors/crusader/stride.png` | 1536 × 1024 | 2,379,829 | Crusader gait contact poses |
| `actors/crusader/sword.png` | 1536 × 1024 | 2,259,980 | Crusader sword extremes |
| `actors/khorgoth/dummy_source.png` | 1086 × 1448 | 1,432,582 | Brass target with crimson aiming ring |
| `actors/khorgoth/gunner_source.png` | 1983 × 793 | 1,933,677 | Gunner carrying and aiming |
| `actors/khorgoth/raider_source.png` | 1619 × 971 | 2,659,323 | Raider blade poses |
| `actors/khorgoth/soldier_source.png` | 2172 × 724 | 794,585 | Human scale-reference views |
| `menu/imperial_shipyard.webp` | 1672 × 941 | 2,057,084 | Title illustration |
| `range/painted_fixtures.png` | 2125 × 740 | 1,378,438 | Separate shields and crew rail |
| `range/painted_hall.png` | 1619 × 971 | 2,743,099 | Walkable hall and surrounding architecture |

The medium Crusader uses five painted viewing angles, with three mirrored entries completing the eight-heading set. The saved cutouts include rifle-ready, guard, chambered and extended sword, stride, crouch and defeat poses. The packer articulates the boots and cloak for the gait, applies rifle recoil and samples the painted blade extremes within the attack window. Reload and healing use a simple lowered-rifle pose. Axial actions reuse a nearby three-quarter pose for the full blade swing and low states. [Crusader packing source](../source_art/actors/crusader/pack.py) · [Crusader prompts and provenance](../source_art/actors/crusader/sources.json)

The raider has painted ready, raised and extended blade poses. The gunner has separate carrying and aiming poses. Both use five painted directions that supply eight headings through mirroring. Lower-limb warps create eight stride phases. The soldier uses three painted views with mirroring and reuse for eight idle headings. A single painted brass target with a crimson aiming ring occupies all eight dummy columns and stays fixed while the camera and player move. [Enemy and soldier packing source](../source_art/actors/khorgoth/build.py) · [Enemy, target and soldier prompts](../source_art/actors/khorgoth/prompts.txt)

The range uses option B and the previous room footprint as references. The two illustrated sources supply the four floor plates and separately sorted shields and rail. The packing script registers wall bases to the collision bounds and puts fixture shadows on the ground. The menu illustration shows a cruiser above a coastal Imperial shipyard and places live title controls against open sky. [Range prompts](../source_art/range/painted_sources.json) · [Range packing](../source_art/range/pack_painted_range.py) · [Title brief and export recipe](../source_art/menu/README.md)

### Runtime actor atlas pages

Paths below are relative to `game/art/actors/`. Headings increase clockwise from screen right. Foot pivots are texture-pixel offsets from the upper left of one cell. The runtime draws 1.5 texture pixels per world unit. Eleven atlas pages contain 488 gameplay cells across five roles. The shared layout file holds action rows and muzzle offsets. [Pose metadata](../game/art/actors/poses.json) · [Runtime view](../game/art/actor_view.gd)

| Actor | Cell | Foot pivot | Directional cells | Motion and contact |
| --- | --- | --- | ---: | --- |
| Medium Crusader | 256 × 208 | (128, 181) | 224 | Rifle, sword, eight-phase gait, defense, dodge, utility actions and defeat |
| Raider | 256 × 194 | (128, 163) | 144 | Ready, gait, windup, cut, stagger, defeat |
| Gunner | 204 × 174 | (102, 143) | 104 | Ready, gait, aim, fire, stagger, defeat |
| Soldier | 204 × 174 | (102, 143) | 8 | Stationary range officer |
| Dummy | 204 × 174 | (102, 143) | 8 | Stationary hit target |

| Atlas | Pixels | Encoded bytes |
| --- | --- | ---: |
| `crusader_0.webp` | 2048 × 1664 | 719,526 |
| `crusader_1.webp` | 2048 × 1664 | 708,744 |
| `crusader_2.webp` | 2048 × 1664 | 681,826 |
| `crusader_3.webp` | 2048 × 832 | 306,948 |
| `dummy_0.webp` | 1632 × 174 | 27,180 |
| `gunner_0.webp` | 1632 × 1392 | 408,640 |
| `gunner_1.webp` | 1632 × 870 | 250,152 |
| `raider_0.webp` | 2048 × 1552 | 664,550 |
| `raider_1.webp` | 2048 × 1552 | 664,098 |
| `raider_2.webp` | 2048 × 388 | 150,422 |
| `soldier_0.webp` | 1632 × 174 | 22,338 |

### Runtime scenery and interface

Paths below are relative to `game/art/`. The four deck quarters form a 1600 × 960 ground plane. Range prop pivots use texture pixels. [Range scene](../game/arena/range_map.tscn)

| File | Purpose or pivot | Pixels | Encoded bytes |
| --- | --- | --- | ---: |
| `range/deck_0_0.webp` | Northwest deck | 800 × 480 | 119,730 |
| `range/deck_1_0.webp` | Northeast deck | 800 × 480 | 127,672 |
| `range/deck_0_1.webp` | Southwest deck | 800 × 480 | 112,450 |
| `range/deck_1_1.webp` | Southeast deck | 800 × 480 | 108,246 |
| `range/north_cover.webp` | North shield (90, 82) | 180 × 87 | 17,750 |
| `range/south_cover.webp` | South shield (85, 82) | 170 × 87 | 16,746 |
| `range/crew_rail.webp` | Crew rail (80, 56) | 159 × 61 | 7,464 |
| `menu/orbital_watch.jpg` | Title-screen cruiser and shipyard | 1024 × 576 | 378,216 |
| `hud/field_instruments.webp` | Combat instrument plate | 974 × 142 | 34,986 |
| `hud/vitality_glass.webp` | Vitality lens | 128 × 128 | 9,710 |
| `hud/frame.webp` | Scalable instrument housing | 148 × 120 | 6,118 |
| `hud/fleet_crest.webp` | Fleet insignia | 84 × 84 | 5,748 |
| `standard.svg` | Application icon | 96 × 96 | 362 |
| `aim_cursor.svg` | Aim reticle, hotspot (16, 16) | 32 × 32 | 378 |

The brass HUD plate, vitality glass, fleet crest and nine-patch frame use original drawn paths and gradients, rasterized with Inkscape and Pillow. Equipment labels, current values, bindings, prompts and gauge fill remain live. The application icon and cursor are editable SVG sources. [Instrument artwork](../source_art/hud/forge_instruments.py) · [Instrument controls](../game/ui/instrument_theme.gd)

### Combat feedback

[feedback.gd](../game/combat/feedback.gd) draws short-lived tracers and sparks and synthesizes the sounds for gunfire, attacks, dodges, defense, reloads, healing and impacts. Each cached mono cue runs for 0.17 seconds at 22,050 Hz with 16-bit PCM (7,496 sample bytes).
