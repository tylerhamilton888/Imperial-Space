# Imperial Space Work Mode Handoff

**Version 1.0 — 22 November 2026**  
**Purpose:** design and implementation specification for the first playable foundation and opening mission. This package is a handoff, not an implemented game.

## Start with a playable arena

Build a single-player action RPG about an extraordinary Imperial Crusader who breaks invasions, defeats powerful enemies, and makes conquered human worlds visibly safer and more prosperous. Preserve the confident, masculine heroic fantasy, characterful shipboard relationships, valuable loot, and freedom to choose an approach.

**The first deliverable is a runnable Developer Arena.** Establish the project, menus, player representation, movement, combat, enemies, and convenient testing before building the opening campaign. The first major integrated milestone is the 20–35 minute Khorgoth invasion described in the mission document. The eventual living galaxy is a later expansion of proven systems.

## How to use this package

1. Extract the complete package into the intended Imperial Space workspace. Inspect the existing repository before creating or moving project files. Preserve unrelated work, including Stellar Holds.
2. Read this file, [AGENTS.md](AGENTS.md), and [PROGRESS.md](docs/PROGRESS.md). Then load only the one to three specifications relevant to the immediate task.
3. Follow [the production roadmap](docs/08_PRODUCTION_ROADMAP.md). Resolve reversible implementation choices and record them; do not resume the world-building questionnaire.
4. Keep the modular Markdown files authoritative. A consolidated reading copy is provided for the human reader; update it from the modules when issuing a new handoff, rather than editing two competing specifications.

## Find the right document

| Task | Read |
| --- | --- |
| Understand scope and exclusions | [00 Vision and scope](docs/00_VISION_SCOPE.md) |
| Implement controls, combat and builds | [02 Gameplay](docs/02_GAMEPLAY_COMBAT_EQUIPMENT.md) |
| Build the testing environment | [12 Developer Arena](docs/12_DEVELOPER_ARENA.md) |
| Design scenes, data and saves | [06 Architecture](docs/06_TECHNICAL_ARCHITECTURE.md) |
| Produce usable visual assets | [03 Art direction](docs/03_ART_DIRECTION.md), [reference guide](reference_art/README.md) |
| Keep images and reports manageable | [07 Asset and response budgets](docs/07_ASSET_AND_RESPONSE_BUDGETS.md), [tools](tools/README.md) |
| Implement the opening operation | [05 Opening mission](docs/05_OPENING_MISSION.md), [10 Dialogue and UI](docs/10_DIALOGUE_UI.md) |
| Check lore and characters | [01 Universe](docs/01_UNIVERSE_AND_NARRATIVE.md), [04 Cast](docs/04_CAST_AND_CHARACTER_OPTIONS.md) |
| Check completion and decisions | [08 Roadmap](docs/08_PRODUCTION_ROADMAP.md), [09 Acceptance](docs/09_QA_ACCEPTANCE.md), [11 Canon](docs/11_CANON_AND_PENDING_DECISIONS.md) |

## Technical starting recommendation

Use Godot 4, typed GDScript, and a native 2D simulation presented from a fixed three-quarter viewpoint. Verify the installed engine and pin an exact release before coding. This is a recommended implementation route, not an instruction to discard a functioning existing project. Any retained alternative must support the same playable arena, readability, save behavior, and delivery goals.

The art references are concept studies. They are not screenshots, production sprites, final approved insignia, or evidence of an already functioning game. See the guide for the particular attributes the user liked.

## What to deliver first

A project that launches into a real menu and reaches the arena directly; a controllable Crusader; a test target and then a fighting enemy; shooting, melee, dodge, guard/parry, health, and rapid reset. Use the same actors and combat rules the mission will later instantiate. Show an actual native-scale screenshot and record actual tests. Extend this foundation through the staged roadmap.

The ready-to-paste implementation instruction is [WORK_MODE_KICKOFF_PROMPT.md](WORK_MODE_KICKOFF_PROMPT.md).
