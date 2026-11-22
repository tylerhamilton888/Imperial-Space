# Cast and character options

## Visual and production rules

Use traditional heroic action, science-fiction, and fantasy attractiveness: massive, handsome, masculine Crusaders; fit, handsome male officers; attractive, feminine adult women. Healthy posture, grooming, and flattering uniforms express confidence and competence. Clothing can emphasize shoulders, waist, and silhouette while remaining credible for the character's occupation.

Everyone described here is an adult. Romance is optional and primarily developed through recurring ship characters. Professional respect comes before intimacy; flirting can be warm and direct without making every woman interchangeable or every interaction a reward dispenser. The prototype needs introductions and a small amount of reactive banter, not relationship simulation.

**These names and designs are proposals for selection.** Do not build the entire candidate list before combat works. Establish one production body and animation set, one medium armor, one captain, and one artificer first. Portrait, complexion, hair, and voice-in-text variations are cheaper than three separately animated physiques. Actual body-shape variants require an asset-budget decision later.

## Player presentation presets

These are starting appearances and roleplaying suggestions, not classes. All can use every armor weight, weapon family, and doctrine. Physique is cosmetic. A player may combine a stoic personality with bright armor or an exuberant personality with black and crimson.

| Proposed preset | Appearance | Personality and presentation | Suggested introductory look |
| --- | --- | --- | --- |
| Imperial Laureate | Apparent age 32; handsome square face, dark swept-back hair, strong brows; broad, athletic heroic proportions | Polished, composed, conventionally heroic; dry confidence and public courtesy | Black and crimson Imperial Standard armor, brass detailing, grand cloak, high uniform-like collar |
| Iron Veteran | Apparent age 41; ruggedly handsome face, close beard, an old brow scar; proposed Goliath physique | Laconic and practical; protective of ordinary soldiers; humor delivered without smiling | Gunmetal and deep green Military tradition, restrained insignia, heavy boots and cloak clasp |
| Silver Paladin | Apparent age 30; attractive angular face, fair hair, clean-shaven; proposed tall athletic physique | Earnest, resolute, courteous; fervent conviction expressed through deeds | Ivory, blue, and steel Knightly tradition, angular helmet and substantial blue cloak |

At the initial implementation stage, use portrait and palette presets on the shared body. Label unimplemented physique previews honestly. All combat versions wear helmets. A selected cloak remains visible in combat; do not silently remove it to avoid animation work. Simplified cloak animation is acceptable if it reads well at play scale.

Possible player tone choices in dialogue are **measured**, **heroic**, **fervent**, and **exuberant**. They change wording and small reactions, not the ability to use a weapon or complete an objective. Provide authored lines rather than a large procedural personality engine.

## Captain candidates

The captain runs the vessel, presents requests, and explains available support. The Crusader chooses the mission and approach. A captain can disagree plainly while respecting that relationship.

**Lucan Veyr — default production candidate, apparent age 44.** A handsome, fit man with dark hair silvering at the temples, a clean jaw, and relaxed military bearing. His navy-black uniform uses a high collar, restrained silver piping, a broad belt, and clean boots. Unflappable, observant, and dryly funny; he values accurate information more than theatrics. He admires the protagonist without becoming a sycophant. Sample: “The governor requests immediate assistance. His army has held longer than his transmissions suggest.”

**Seraphine Vale — alternative candidate, apparent age 36.** A beautiful, athletic woman with auburn hair in a disciplined updo and clear, assessing eyes. A tailored navy coat, ivory blouse, structured shoulders, shaped waist, gold rank details, and practical boots create a feminine command silhouette. She is diplomatic, exacting, and quietly formidable, with very dry humor. Sample: “I have prepared three approaches. Naturally, I assumed you would invent a fourth.”

**Cassian Rook — alternative candidate, apparent age 39.** A handsome, broad-shouldered man with bronze skin, a neat beard, and weathered features. His charcoal uniform has crimson panels and worn but carefully maintained metal fittings. Bold, sociable, and delighted by a well-executed risk; he still knows exactly when a ship cannot survive another volley. Sample: “They have a fortified gate. We have you. I favor our engineering.”

## Personal artificer candidates

The artificer maintains the Crusader's personalized armor and weapons, handles outfitting, and later explains supply-dependent crafting. Armor is personal property and biologically paired; the artificer makes it distinctive without requiring every modification to be a separate gameplay system.

**Dorian Rusk — default production candidate, apparent age 52.** A handsome, powerful craftsman with a short gray beard, strong hands, and a charcoal tunic beneath a bronze-trimmed workshop apron. He is exacting, proud of his work, and affectionately abrasive. His admiration appears as relentless improvement: the Crusader deserves better equipment and Dorian intends to provide it. Sample: “The cannon will take the new feed. Try not to mistake the entire district for a firing range.”

**Elira Voss — alternative candidate, apparent age 34.** A beautiful woman with dark braided hair, bright eyes, a fitted deep-green technical tunic, leather work belt, gloves, and a close-fitting protective apron. Curious, witty, and competitive about her craft, she enjoys the protagonist's appetite for difficult work. Sample: “Tell me what you wanted that weapon to do. Then tell me what it actually did.”

## Recurring support candidates

| Role and candidate | Design | Personality and function |
| --- | --- | --- |
| Physician Celene Ardent, 37 | Beautiful, composed woman; pinned dark hair; ivory medical coat with an indigo waist panel and clean metallic fasteners | Warm, firm, and unembarrassed by rank; explains recovery and respects the man beneath the armor. Default medical contact, portrait first. |
| Physician Magnus Thorne, 55 | Handsome, vigorous older man; silver hair; fitted white and charcoal clinical uniform | Patient, humane, quietly sardonic; a veteran of keeping impossible patients alive. Alternative physician. |
| Operations officer Mirelle Damar, 29 | Attractive, feminine woman; black braid; scarlet and charcoal duty uniform with a defined waist and practical boots | Precise, alert, quietly playful; turns scattered reports into useful choices. Default operations contact, portrait or radio first. |
| Operations officer Adrian Sol, 30 | Handsome man; wavy brown hair; navy uniform with bronze details and rolled workshop-style cuffs off duty | Buoyant, resourceful, eager to solve problems; his optimism is backed by preparation. Alternative operations contact. |

The default roster is Lucan, Dorian, Celene, and Mirelle. Only Lucan and Dorian initially require walk-up interactions. Celene and Mirelle can speak through portraits and text. Store candidate choices as IDs so later alternatives do not require rewriting the hub. Character selection should eventually choose authored personalities and looks; it should not combine incompatible lines, portrait traits, or backgrounds at random.

## Opening operation cast

**Sergeant Rellan** leads surviving imperial defenders. He is tired, competent, and visibly relieved by the Crusader's arrival. Give him an ordinary human scale and a restrained uniform so the protagonist's size reads immediately. He provides short practical information while continuing his job.

**Druvak**, the proposed Khorgoth lieutenant, introduces a disciplined enemy response. He uses a shield or reinforced forelimb, orders a flanking pair, and becomes the first named test of intelligent aggression. A trophy can support the later warlord exchange, but the encounter must still work without a bespoke decapitation animation.

**Khorvath**, the proposed warlord, is a dangerous opponent who recognizes strength without becoming friendly. A distinct arm silhouette, brutal command equipment, and an identifiable helmet or face allow the player to recognize him after his injury. Prepare an intact and wounded visual state. A prosthetic rematch is a later content opportunity, not part of the initial asset requirement.

## Minimum character delivery

For the opening milestone, deliver a playable helmeted Crusader, one reusable ordinary-human base, one Khorgoth base with readable role variants, and the warlord variant. Use portraits for dialogue detail. Record each asset's pivot, scale, palette, direction coverage, animation states, license or provenance, and status in the asset manifest. A concept portrait does not count as a combat sprite or animation set.
