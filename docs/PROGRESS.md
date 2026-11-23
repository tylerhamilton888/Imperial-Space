# Progress

## 22 November 2026 • Scene art preparation

Four new acceptance boards are recorded with three assembled environments and a second proving-ground view for Heavy armor. Open the [Godot art studies](../art_studies/README.md) or inspect the [four rendered views](evidence/scene-art-studies.jpg). The latest playable combat build is 0.1.2. Next, bring the range bays and target stations into the Developer Arena and test floor contacts, weapon readability and moving silhouettes at the live camera scale.

## 22 November 2026 • Developer Arena 0.1.2

The early environment pass is playable on `main`. The four existing drills share a sunlit arsenal forecourt. A staffed inspection desk and reusable stone cover establish human scale. The gunner starts beside the north barricade in Mixed squad. All actors cast directional shadows from their current pose.

Enter Developer Arena → F1 → Mixed squad. [Native capture](evidence/arsenal-forecourt.jpg) · [Combat clip](evidence/arsenal-forecourt.mp4) · [Verification](TEST_REPORT.md). The latest packaged GitHub release below is the earlier 0.1.1 hall.

## 22 November 2026 • Developer Arena 0.1.1

- Branch `main`. The illustrated runtime is `dd6de25739e3`, tagged `arena-v0.1.1`. A subsequent documentation commit records that build. The mechanical baseline is tagged `arena-v0.1.0`.
- Pinned engine and templates: Godot 4.7.2 stable, official `ed1daf0bf`, native 2D Compatibility renderer. Independent Imperial Space project.
- Play on Windows by extracting the Windows build and launching `ImperialSpace.exe`. Choose **Developer Arena**, then **F1 → Raider duel**. The separate Linux build was played on a rendered desktop. Windows execution still needs a Windows-machine check.
- From a clean source checkout, run `godot --headless --path game --editor --import`, then `godot --path game`. For direct entry run `godot --path game -- --arena`.
- M0 foundation, M1 movement/scale proof and M2 shared-combat features are playable. Four seeded presets cover an empty room, range dummy, raider duel and mixed squad. F5 reconstructs the active scenario. F1 exposes spawning, passive actors, clearing and refill.
- Medium armor, a service rifle and a sword are implemented. Combat is independent of the range. Defense timing, shot obstruction, duplicate hits, death, scene teardown and campaign isolation have dedicated executable checks. See [test results](TEST_REPORT.md).
- The current revision replaces the original faceted model renders with painted characters, reworks the hall and HUD, and preserves independent camera aim and character-foot collisions. The owner’s visual review is open. See [technical debt](TECH_DEBT.md) and [asset inventory](ART_ASSET_MANIFEST.md).

## Repository delivery

The independent project is on [GitHub](https://github.com/tylerhamilton888/Imperial-Space). Release notes, game builds and the mixed-squad gameplay clip are collected on the [0.1.1 release](https://github.com/tylerhamilton888/Imperial-Space/releases/tag/arena-v0.1.1).

## Next increment

1. Review the forecourt capture against [Karth Vale](03_ART_DIRECTION.md#karth-vale-gameplay-art-target). For the next art increment, give the Medium Crusader dedicated lateral steps and preserve the weapon hand through the mirrored headings. Recheck this same encounter before expanding the roster.
2. Begin M3 with interchangeable loadouts on the same actor. Prove Light/Medium/Heavy movement and a simple equipment selector before producing additional armor art.
3. Add the precision rifle, heavy cannon and hammer to the range and verify their handling against the same four scenarios.
