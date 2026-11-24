# Progress

## 24 November 2026 • Ready guard and relative scale 0.4.4

In **Armory trial** the Knight stands about 134 pixels tall beside the 98-pixel trooper. He raises the weapon in a dedicated idle guard after he moves or strikes. [Native-scale comparison](evidence/knight-guard-scale.png) · [Motion](evidence/knight-ready-guard.mp4). Both weapon profiles and shoulder pieces are available to try. This scale is a proposal for review.

## 24 November 2026 • Modular Armory trial 0.4.3

From the title screen choose **Armory trial**, or run with `-- --armory`. A one-handed Knight can practice on a Khorgoth target beside Imperial infantry and solid cover. Use 1 and 2 to change weapon and shoulder plate independently. [Native-scale comparison](evidence/armory-comparison.jpg) · [Moving trial](evidence/armory-trial.mp4). Built and recorded on Godot 4.7.2. Next proof is an independently drawn opposite facing and a removable off-hand shield.

## 23 November 2026 • Khorgoth cleaver and breakup 0.4.2

Choose **Play counter duel**. Watch the grip during the approach, guard on the glint, then right-click for the sword finish. The forearm, cleaver and shoulder plate each have original loose-part art and land alongside a one-armed body. F5 resets the exchange. [Godot gameplay capture](evidence/raider-cleaver.mp4) · [Verification](TEST_REPORT.md)

The Windows x86-64 build and the change on main are ready for owner review. The current scope is the raider. Review the finish at ordinary zoom before extending this treatment to the gunner.

## 23 November 2026 • Painted combat review 0.4.1

Open **Play counter duel** to compare the Medium sword and Khorgoth fall. **Play breach drill** contains repainted barricades and the steel shutter. The sword stays in hand into recovery and movement. Both scenes appear in the [matched gameplay capture](evidence/painted-combat.mp4), with 0.4.0 on the left and 0.4.1 on the right. Godot 4.7.2, Windows x86-64 export. [Verification](TEST_REPORT.md).

Owner review is open. The gunner still uses its previous fall and straight north/south sword attacks use the existing keys. Review the visual language at ordinary zoom before extending it to the Heavy kit or campaign ranks.

## 23 November 2026 • Destruction review 0.4.0

Choose **Play breach drill** for the four-stage shutter and two collapsible stone barricades. Choose **Play counter duel** for the first directional Khorgoth dismemberment. [Watch the nine-second gameplay capture](evidence/destruction-pass.mp4). The Windows x86-64 build uses Godot 4.7.2. [Verification](TEST_REPORT.md).

Next review the force of the landing and the readability of the flying weapon arm at normal zoom. Next content targets are a heavy hammer versus an armored defender and a breakable support whose collapse changes a route. The Medium return-cut ending and equal-height armor proof remain open.

## 23 November 2026 • Next owner review

Playable baseline: 0.3.0, `20164c4`. The new [review sequence](08_PRODUCTION_ROADMAP.md#next-playable-review-after-030) pairs one repaired sword exchange with the equal-height Medium/Heavy silhouette proof. Heavy currently has art studies. The runtime protagonist is Medium. The immediate code targets are lethal displacement and the return-cut finish.

## 22 November 2026 • Counter duel and crossfire 0.3.0

On `main`, the Medium kit now supports two target-specific parry counters, a confirmed second sword cut, physical impact reactions and eight-direction sidestepping. Choose **Play counter duel** from the title screen, then try **F1 → Crossfire drill**. Gunner shots lock on commit and a raider crossing that line can absorb the hit. The proving ground remains playable. [Normal-speed capture](evidence/counter-duel.mp4) · [Test report](TEST_REPORT.md).

Next review: test the guard cue by ear and sight and try both finishes against pressure from a mixed squad. Heavy equipment remains a later milestone.

## 22 November 2026 • Playable proving ground 0.2.0

On `main`, the proving-ground study is now the fifth playable scenario. Choose **Play breach drill**. The medium Crusader can shoot the range targets, breach the shutter with rifle or sword, cross its aperture and secure the far side. F5 resets the drill. The four forecourt presets remain available. Godot 4.7.2. [Recorded playthrough](evidence/proving-ground-breach.mp4) · [Verification](TEST_REPORT.md)

This increment delivers the first destruction fixture. Heavy armor, its cannon and hammer, the Karth Vale operation and the narrative bridge remain future gameplay work. The next equipment pass can use the same drill to compare loadouts.

## 22 November 2026 • Scene art preparation

Four new acceptance boards are recorded with three assembled environments and a second proving-ground view for Heavy armor. Open the [Godot art studies](../art_studies/README.md) or inspect the [four rendered views](evidence/scene-art-studies.jpg). The playable build at this point was 0.1.2. The proving-ground integration is recorded above.

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
