# Technical Debt and Production Risks

No implemented game has been inspected, so this is an initial risk register, not a report of existing code defects.

| Risk | Consequence | Resolution milestone |
| --- | --- | --- |
| Inconsistent directional character art | Attractive portraits but poor motion and aim readability | M1 native-scale proof; one body and coherent anchors before more variants |
| Arena behavior diverges from campaign | Testing gives misleading results | M2 shared production actor and resolver scenes |
| Destruction updates visuals only | Invisible walls, invalid navigation or unfair shooting | M4 collision, navigation and save transaction tests |
| Save states miss actions or branch claims | Lost progress, unfair resumes or duplicated rewards | M4 snapshot design; M5/M6 branch fixtures |
| Asset growth exceeds budgets | Slow imports, memory pressure or oversized review payloads | Asset preflight every art increment |
| Cosmetic and crew choices multiply scope | Animation/dialogue backlog before combat is fun | Limit initial implemented roster and record future candidates |

Add actual defects with reproduction, severity and a bounded fix. Remove entries once resolved; keep a brief completion reference in the changelog.
