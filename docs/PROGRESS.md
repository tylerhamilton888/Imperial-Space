# Progress

## 22 November 2026 • Developer Arena 0.1.0

- Branch `main`. Tested gameplay commit `49e42045d84d`, tag `arena-v0.1.0`. The subsequent documentation commit carries the same runtime.
- Pinned engine and templates: Godot 4.7.2 stable, official `ed1daf0bf`, native 2D Compatibility renderer. Independent Imperial Space project.
- Play on Windows by extracting the Windows build and launching `ImperialSpace.exe`. Choose **Developer Arena**, then **F1 → Raider duel**. The separate Linux build was played on a rendered desktop. Windows execution still needs a Windows-machine check.
- From a clean source checkout, run `godot --headless --path game --editor --import`, then `godot --path game`. For direct entry run `godot --path game -- --arena`.
- M0 foundation, M1 movement/scale proof and M2 shared-combat features are playable. Four seeded presets cover an empty room, range dummy, raider duel and mixed squad. F5 reconstructs the active scenario. F1 exposes spawning, passive actors, clearing and refill.
- Medium armor, a service rifle and a sword are implemented. Combat is independent of the range. Defense timing, shot obstruction, duplicate hits, death, scene teardown and campaign isolation have dedicated executable checks. See [test results](TEST_REPORT.md).
- Current art proves camera scale and eight-way facing. Both hands-on combat tuning and improved strafing remain open. See [technical debt](TECH_DEBT.md) and [asset inventory](ART_ASSET_MANIFEST.md).

## Repository delivery

The project is published on [GitHub](https://github.com/tylerhamilton888/Imperial-Space). The default branch is `main`. All four original commits through `ffb553922a39` and the annotated `arena-v0.1.0` tag are available there. The portable source ZIP contains the same original history.

## Next increment

1. Play the raider duel on Windows, checking sword contact, guard timing and the leg poses while circling.
2. Begin M3 with interchangeable loadouts on the same actor. Prove Light/Medium/Heavy movement and a simple equipment selector before producing additional armor art.
3. Add the precision rifle, heavy cannon and hammer to the range and verify their handling against the same four scenarios.
