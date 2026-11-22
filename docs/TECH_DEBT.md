# Technical debt and open verification

| Area | Observed limitation or remaining risk | Resolution |
| --- | --- | --- |
| Windows | Release exported. The available Linux compatibility runner failed during its own initialization. Native Windows startup, audio and input still require a PC playtest. | First Windows playtest |
| Directional movement | Eight aim headings and sampled poses are in use. Strafing reuses the forward or reverse foot cycle, especially visible when circling a stationary target. | Review side-on gait, planted feet and sword transitions before scaling up M3 armor art |
| Combat balance | Resolver windows and combat states are covered by tests. Timing, difficulty and SFX have had only a short desktop pass. | Tune with a human raider-duel and mixed-squad session |
| Hardware coverage | The recorded direct-entry timing used a 1280 × 720 Linux software renderer. Crowded formations and 1080p target hardware are unmeasured. | M3/M4 representative hardware review |
| Range fixtures | The second protected lane holds fixed cover. Breachable walls, supports, diagnostics/stepping and destructible navigation remain scheduled work. | M4 destruction fixtures |
| Campaign persistence | This arena has no campaign save service or rewards. A sentinel verifies isolation. Save recovery, item identity and story outcomes need real fixtures as those systems land. | M3 item instances, M4 saves, M5 opening operation |
