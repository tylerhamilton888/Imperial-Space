# Technical debt and open verification

| Area | Observed limitation or remaining risk | Resolution |
| --- | --- | --- |
| Windows | Release exported. The available Linux compatibility runner failed during its own initialization. Native Windows startup, audio and input still require a PC playtest. | First Windows playtest |
| Directional movement | Five painted Crusader views provide eight displayed aim headings. Three headings mirror the opposing painting, reversing weapon handedness. Lateral travel now uses a dedicated eight-phase step. Some north/south attacks still use the nearest diagonal pose. | Review lateral gait, rifle handedness and top/bottom sword transitions in the new mixed-squad clip before producing further armor weights |
| Second sword stroke | The return cut re-times the original painted extension. Its ending reads like the first cut. | Author the opposite-side finish and check the visible edge against the contact tick at gameplay zoom. |
| Dismemberment coverage | The raider has one eight-heading sword finish. The gunner uses a whole-body fall. Debris uses point sweeps, so wide painted edges may overlap cover. | Author a distinct heavy hit and an armored reaction, and review the visual footprint by narrow jambs |
| Combat balance | Resolver windows and combat states are covered by tests. Desktop footage covers counter timings and crossfire. The parry cue and fall, hit and rifle sounds still need human playtest feedback. | Tune with a human raider-duel and mixed-squad session |
| Hardware coverage | The recorded direct-entry timing used a 1280 × 720 Linux software renderer. Crowded formations and 1080p target hardware are unmeasured. | M3/M4 representative hardware review |
| Range fixtures | The proving ground has two material families, each with four states. Structural supports, linked collapse and destruction persistence remain open. | M4 destruction fixtures |
| Campaign persistence | This arena has no campaign save service or rewards. A sentinel verifies isolation. Save recovery, item identity and story outcomes need real fixtures as those systems land. | M3 item instances, M4 saves, M5 opening operation |
