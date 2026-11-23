# Verification record

## Proving ground 0.2.0 • 22 November 2026

Godot 4.7.2 stable on Linux. Imported the project, then ran `arena_checks.gd`, `combat_checks.gd`, `test_enemies.gd`, `verify_range_map.gd` and `breach_checks.gd` using `godot --headless --path game --fixed-fps 60 --script ../tools/tests/<suite>.gd` with isolated test profiles. All 125 checks passed (26 + 36 + 22 + 17 + 24). All 15 Python tests passed.

The new suite fires four service rifle rounds, compares actor movement, shot rays and AI paths across the same segment before and after breach, checks both solid jambs, rejects a detour as objective progress, exercises target impact and restores the scenario. Removing defenders manually cannot award completion.

Exported Linux and Windows with matching templates. Launched the Linux executable on an X11 desktop, clicked the title button, fired until the panel broke, and reset with F5. Recorded the [complete run](evidence/proving-ground-breach.mp4) at 1280 × 720 using the exported Linux game data and scripted mouse and movement input. Result: crossed the opening, defeated both active defenders, 85 health, one round in the magazine, and a successful F5 reset. Mesa llvmpipe reported unsupported VSync.

Verified the Windows ZIP CRC and booted its embedded game pack to the breach drill under Linux. Native Windows execution awaits a PC playtest. Windows ZIP SHA-256: `d824d014300a851f6b11a72135396e10e01fc1fe9ebdd76955c3c86f3294f9e5`.

## Four scene art studies • 22 November 2026

Imported the 1,465,499-byte artist kit ZIP into an empty directory, checked every member CRC, imported its project with Godot 4.7.2 stable and launched its default review scene. The clean extraction passed all four view loads, paired-wall state changes, target and terminal visibility, all four Heavy poses (one visible at a time), and instantiation of the individual reusable kit scenes. The packaged copy has 134 files and needs only the Godot editor to open.

Rendered the four assemblies at 1280 × 720 on Linux with the Compatibility renderer and Mesa llvmpipe. Reviewed the [four-scene capture](evidence/scene-art-studies.jpg), corrected cross-cell clipping on the transit sign and Vale, registered the wall variants on a common canvas and checked the final capture. Software GL reported unsupported VSync. The staging project contains static actor studies; animation, actor controls, wall physics and mission flow require live integration.

Asset preflight passed all 47 study textures, 10 reference boards and the composite preview. The largest study texture was the northwest Karth Vale tile at 640 × 360 and 126,354 bytes. The largest source painting was the full 1672 × 941 district at 2,729,974 bytes. [Repeat the checks](../source_art/scene_targets/README.md).

## Civic arsenal forecourt 0.1.2 • 22 November 2026

Ran Godot 4.7.2 stable on Linux x86-64. Imported the project, exported both desktop presets and recorded a 1280 × 720 Mixed squad session from the Linux executable using mouse and keyboard. The screenshot and [short clip](evidence/arsenal-forecourt.mp4) come from that run. A second rendered check placed the player on opposite sides of the north barricade to inspect the ground pivot and overlap.

| Check | Observed result |
| --- | --- |
| Godot suites | 26 arena, 36 combat, 22 enemy and 17 map checks passed. A new ray query hits the inspection desk at its painted footprint. |
| Art and utilities | 15 Python tests passed. All 13 scenery/menu/HUD frames and 11 actor atlases passed preflight. The largest new runtime image is `deck_1_0.webp` at 180,824 bytes. The native screenshot passed the preview profile. |
| Windows export | The ZIP passed CRC validation and its executable matched the export. Its embedded pack booted into the arena with the matching Linux engine. Native Windows play remains open. ZIP SHA-256 `ffb948d2fd3f49416e6cb4d9b3af0d23ca2afa38df09816c198e216e4062f6a5`. |
| Capture limitations | The software GL driver reported unsupported VSync. Fixed-frame movie shutdown reported WAV playback objects still in use. The separate rendered cover check and all four headless suite runs exited without that warning. |

See the [native screenshot](evidence/arsenal-forecourt.jpg) for the environment review. The original actor poses still have the directional limitations recorded in [technical debt](TECH_DEBT.md).

## Illustrated Developer Arena 0.1.1 • 22 November 2026

**Runtime** `dd6de25739e3` (tag `arena-v0.1.1`). A separate checkout of that exact revision imported in Godot 4.7.2 stable and reached both the main menu and direct-entry arena. Runtime, export templates and OS are the same as in the foundation report below.

| Suite or audit | Observed result |
| --- | --- |
| Godot | 26 arena, 36 combat, 22 enemy and 16 map checks passed. All four suite logs were clean. The added combat case shoots the upper outside shoulder of a painted raider. Three successive AI runs also completed with clean teardown. |
| Python | 15 tests passed, including four new image checks across all 488 actor cells. The tests verify atlas geometry, pose ranges, image content, edge clearance and motion differences; the threshold details are in `tools/tests/test_actor_art.py`. |
| Asset preflight | 11 actor atlases and 12 runtime scenery/menu/HUD frames passed. The largest runtime file is `crusader_0.webp`, 2048 × 1664, 719,526 bytes. Five source reference boards passed their separate reference budget. |
| Visual review | An actual 1280 × 720 mixed-squad session showed a readable helmet, collar and trailing cloak, separate raider and gunner silhouettes, and a human defender behind the rail. Consecutive sword frames showed the raider losing health during the lunging cut. Directional art limitations are listed in [technical debt](TECH_DEBT.md). |
| Desktop packages | Linux and Windows x86-64 packages exported with embedded game data. ZIP CRCs and executable checksums match the local exports. The extracted Windows game pack booted under the matching Linux engine. Native Windows execution remains untested. |

Repeat with the commands in the foundation section. For current art preflight, use the commands in [the asset guidelines](ASSET_GUIDELINES.md). To see combat immediately, launch, enter Developer Arena, press **F1** and select **Mixed squad**. [Native image](evidence/illustrated-arena-0.1.1.jpg) · [Gameplay clip and builds](https://github.com/tylerhamilton888/Imperial-Space/releases/tag/arena-v0.1.1)

| Download | SHA-256 |
| --- | --- |
| Windows ZIP | `7263ef326178602c75fc23853af58fc641074792c26f77ded5fd98012e18aa43` |
| Linux ZIP | `8a0906badfff22c1c3ebd4f21cb85a4cbc2e0f4c69352a14550e742b0082f418` |

## Developer Arena 0.1.0 • 22 November 2026

**Tested runtime** `49e42045d84d` (`arena-v0.1.0`, main). Godot 4.7.2 stable official `ed1daf0bf`, matching desktop export templates, Linux x86-64. The runtime and art were imported from a fresh local Git clone outside the authoring folder. Headless import, menu and direct arena launches completed without engine errors. Removing the optional title illustration from the test checkout also allowed boot.

### Repeatable checks

Run from the repository root after importing with `godot --headless --path game --editor --import`. The isolated profile is required for the campaign-sentinel test.

```sh
export XDG_DATA_HOME="$(mktemp -d -t imperial-test-XXXXXX)"
godot --headless --path game --fixed-fps 60 --script ../tools/tests/arena_checks.gd
godot --headless --path game --fixed-fps 60 --script ../tools/tests/combat_checks.gd
godot --headless --path game --fixed-fps 60 --script ../tools/tests/test_enemies.gd
godot --headless --path game --script ../tools/tests/verify_range_map.gd
python3 -m unittest discover -s tools/tests -p 'test_*.py' -q
```

| Suite | Passed | Observed coverage |
| --- | ---: | --- |
| Arena and menu | 26 | Direct menu entry, preferences/defaults, normalized movement, seeded layout, spawn clearance, refill, clear, death/retry, pausing, reconstruction and teardown. Campaign sentinel SHA-256 matched before/after. |
| Combat | 35 | Registered damage and attacker, ordering against close cover, click at torso/feet, one sword contact per target, timing and rearm of defense, death and UI ownership. |
| Enemy behavior | 22 | Raider approach and telegraph, parry interruption, gunner aim commitment, late cover, last-seen pursuit and clearance-aware routing. |
| Range map | 16 | Four boundaries, collision on cover and rail, clear firing lane, valid spawns, grid, reference soldier and actual detour. |
| Python asset utilities | 11 | Budget limits, image decoding, preview bounds, path safety and preservation of source images. |

All 99 Godot checks passed with zero engine warnings or errors in the fresh clone. All 11 Python utility tests passed. The three asset audits passed all 5 supplied reference boards, 8 runtime frames and 11 actor atlases. The largest new runtime image was `raider_0.webp`, 1632 × 1392, 311,646 bytes. All 488 directional actor cells held nonempty pixels inside their cell borders.

### Rendered play

Actual OS mouse and keyboard events drove the 1280 × 720 X11 build on a Xeon Platinum 8370C with Mesa llvmpipe (LLVM 19.1.7). Tested the title screen, volume, movement rebinding, restore defaults, entry, scenario controls, grid, clear/refill/reset, pause, resume, exit and Quit. The developer range retained a visible helmet, cloak and distinct leading feet while the Crusader moved.

- In Dummy range, the target lost health as the rifle counted down from 12 to 9. A reload produced 12/81. Refill restored 12/84, clear removed the target, and F5 restored one full-health target.
- In Mixed squad, a raider approached while a gunner acquired its shot. Combat rendered hits, sword contact, dodging and held guard. A medical charge moved health from 52 to 77 and charges from 3 to 2. Defeat and retry returned the Crusader to full health.
- On the Linux release, process launch to a visible direct-entry health meter took **0.947 seconds** on the final release (an earlier run took 1.391 seconds). This is a sample from the test host. Frame rate and target-PC benchmarks remain open.
- The Windows x86-64 PE and Linux x86-64 ELF exports both completed with embedded game data. ZIP integrity and executable hashes matched their export outputs. The Windows pack extracted from the PE also booted with the matching Linux engine. Windows OS execution remains unverified because the available Wine runner failed during its IPC initialization.
- Gameplay footage and the native-resolution screenshot were taken on `dedb65dd4d38`. The final runtime change releases the custom cursor on exit and has identical arena presentation. A captured shutdown exposed a 5,460-byte texture left allocated; normal and direct desktop exits were checked again after its cleanup. On the final Linux export, swapping the mouse buttons and right-clicking reduced the magazine from 12 to 10 and hit the dummy. Pause → main menu → Quit completed without leaked objects or engine errors. [Developer Arena screenshot](evidence/developer-arena.jpg)

### Release file integrity

| File | SHA-256 |
| --- | --- |
| `Imperial-Space-0.1.0-Windows.zip` | `9735b653d8eb5b9ee2cf34403c0c988630a54e39cc261ed0559ddbeaba4635db` |
| `Imperial-Space-0.1.0-Linux.zip` | `e6a6738af0afa481478e5f93e7513c56792e460f2af43a1ac4cc9c35cd73a021` |

The opening operation, other armor weights, destruction and save recovery have dedicated later gates. See [current debt](TECH_DEBT.md).
