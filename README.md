# Imperial Space

A single-player PC action RPG about an Imperial Crusader. **Developer Arena 0.4.2** rebuilds the Khorgoth raider’s cleaver grip and sword finish. Choose **Play counter duel** for the parry and riposte. [Watch the exchange at normal speed](docs/evidence/raider-cleaver.mp4).

[0.2.0 breach drill](docs/evidence/proving-ground-breach.mp4) · [Proving ground screenshot](docs/evidence/proving-ground-breach.jpg)

[0.1.2 gameplay screenshot](docs/evidence/arsenal-forecourt.jpg) · [0.1.2 mixed-squad clip](docs/evidence/arsenal-forecourt.mp4)

[Previous 0.1.1 desktop release.](https://github.com/tylerhamilton888/Imperial-Space/releases/tag/arena-v0.1.1)

## Play

On Windows x86-64, extract the Windows ZIP and run `ImperialSpace.exe`. On Linux x86-64, extract the Linux ZIP, make `ImperialSpace.x86_64` executable if necessary, and launch it. Choose **Play counter duel**. Face the raider and tap Shift as its blade glints. Right-click during the opening to riposte, or left-click for a countershot. On a regular sword hit, click again during recovery for a return cut. F5 starts a rematch. Open F1 → **Crossfire drill** to bait a gunner into hitting its own raider. The breach drill has a separate title button. **Developer Arena** opens the empty forecourt.

| Default control | Action |
| --- | --- |
| WASD / mouse | Move / aim independently |
| Left / right mouse | Fire the rifle / swing the sword |
| Space | Dodge in your movement direction, or toward your aim when stationary |
| Left Shift | Guard the front arc. An early guard can parry a raider’s strike. |
| R / Q | Reload / spend a medical charge |
| F1 | Open range controls, select a scenario, spawn actors, clear, or refill |
| F5 / G | Rebuild the selected scenario / toggle scale grid |
| Esc | Pause, resume, or return from a panel |

Settings persist volume, fullscreen, keyboard bindings, mouse-button swap and toggle guard. The range has its own temporary actors and RNG. A restart returns the selected drill to its authored positions with fresh health, supplies and AI. No campaign file is needed.

## Run from source

Use **Godot 4.7.2 stable**, official build `ed1daf0bf`, with its Compatibility renderer. The prebuilt release requires no editor. From a fresh source checkout, import first. Run these from the repository root.

```sh
godot --headless --path game --editor --import
godot --path game
godot --path game -- --arena
godot --path game -- --duel
godot --path game -- --breach
```

Alternatively, import `game/project.godot` in the Godot Project Manager and press F6 on the boot scene or F5 to run the project. The development build also accepts `-- --arena` on its own executable. The runtime artwork is checked in. The optional bake scripts under `source_art/` are only needed to change the artwork.

## Export

Install the matching Godot 4.7.2 standard export templates. Both presets embed their game data.

```sh
mkdir -p build/windows build/linux
godot --headless --path game --export-release "Windows Desktop"
godot --headless --path game --export-release "Linux"
```

Include Godot and third-party engine notices with distributed builds. See the packaged notices and the Godot editor’s Credits / License view.

## Scene art kit

[Download the editable Godot kit](docs/downloads/Imperial-Space-Scene-Art-Kit.zip) · [See the four assembled views](docs/evidence/scene-art-studies.jpg). Open `art_studies/project.godot` in Godot 4.7.2 to review the scenes. [Asset list and controls](art_studies/README.md)

## Continue development

Read `AGENTS.md` and `docs/PROGRESS.md` to resume. `docs/TEST_REPORT.md` records verification and `docs/TECH_DEBT.md` tracks remaining work. Shared actors, hit resolution and navigation live under `game/actors/` and `game/combat/`. Arena-specific setup and resets live under `game/arena/`. The gameplay data never writes to campaign progression.

The modular design chapters are authoritative. The consolidated design document and `PACKAGE_MANIFEST.json` preserve the supplied 1.0 handoff baseline. Their original file hashes correspond to the handoff import commit. New implementation and gate evidence are tracked separately.
