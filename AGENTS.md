# Imperial Space Agent Instructions

These instructions apply to implementation work in the Imperial Space project. The user's current instructions take precedence. This package authorizes preparation and local implementation; it is not evidence that a game, repository, deployment, or release already exists.

## Working rules

- Build the Developer Arena and fundamentals before the campaign. Follow the milestone gates in `docs/08_PRODUCTION_ROADMAP.md`.
- Inspect the actual repository, engine version, dependencies and Git status. Preserve existing work. Use a separate project or branch where appropriate; never overwrite Stellar Holds or rewrite unrelated history.
- Choose reversible defaults without asking repeated design questions. Record significant decisions with their reason. Ask only when missing access, conflicting requirements, or an irreversible commitment genuinely blocks the task.
- Keep each increment runnable. Do not build a galaxy simulator, generalized mod framework, multiplayer stack, or enormous inventory architecture to support one opening mission.
- Use small, explicit components and immutable content definitions. Avoid a universal `GameManager` that owns combat, saves, UI, narrative and rendering.
- Never claim a successful build, playable feature, test, export or upload without verifying it. State limitations precisely.

## Load context selectively

At session start, read `START_HERE.md`, this file and `docs/PROGRESS.md`. Then read only the one to three relevant topic documents. Search with `rg` rather than dumping the repository or full transcript. Do not repeatedly load all art boards or the consolidated reading copy for a small code edit.

Maintain these separate files in the repository:

| File | Contents and maintenance rule |
| --- | --- |
| `docs/PROGRESS.md` | Current playable state, engine, branch/commit, blocker and next step; aim below 100 lines, hard review at 150. |
| `docs/DECISION_LOG.md` | Short dated decisions, rationale, alternatives when material, and affected specification. |
| `docs/CHANGELOG.md` | Completed increments; distinguish documentation from implemented behavior. |
| `docs/TEST_REPORT.md` | Commands, environment, measured results and concise reproduction steps; do not write predicted passes. |
| `docs/TECH_DEBT.md` | Specific limitations, impact and planned milestone; retire resolved entries. |
| `docs/ART_ASSET_MANIFEST.md` | Source, license/provenance, purpose, dimensions, bytes and prototype/final status. |
| `docs/ASSET_GUIDELINES.md` | Short export checklist linking the authoritative art and size documents. |

Update the affected topic document when a real decision changes. Link to it from the log instead of duplicating long explanations. Archive old test logs outside the small rolling context files. End each working session with one concise update pass.

## Preserve the design

No stamina bar; momentum is a description of effective play, not another spendable meter. Light, Medium and Heavy are equipment roles. Visual tradition and physique do not lock a class. Helmets stay on during combat; an equipped cloak remains visible. Basic competence is high with every weapon. Imperial soldiers are competent. The Sovereign is distant and exceptional. The galaxy must not make the player manage a strategy game.

Follow the attractive adult heroic cast direction and the distinctive regal industrial art language. Do not copy recognizable franchise armor, emblems or characters. Refer to the art guide instead of treating generated lettering as canon.

## Keep assets and responses small

Use the included asset checker before adding runtime art and before attaching previews. These are project budgets, not platform guarantees. Keep binary data, base64 strings, full atlases, long generated files and unbounded logs out of chat and tool output. Save full logs locally; report a bounded summary and a small number of compressed previews. Never replace the only source image with its review derivative.

## Verification and reporting

Use targeted tests for damage resolution, reset isolation, equipment state, mission branching and save restoration. Inspect actual gameplay for animation, collision, readability and feel; those cannot be established by code inspection alone. Test the exported application when export tooling is available. Report unavailable platforms as untested.

Report: **milestone; repository/branch/commit; what runs; relevant changes; tests actually performed; largest new asset and audit result; remaining limitation; next one to three actions.** Do not seek approval for every reversible fix. Stop optional testing once the concrete risk is resolved and continue toward the agreed milestone.
