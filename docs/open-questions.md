# Open questions

These are decisions the parent has not made. Each has a suggested default so work is not blocked, but ask before building anything large on top of one.

## From the storyboard notes

| # | Question | Where it matters | Suggested default |
|---|---|---|---|
| 1 | Do the girls get to name and style their mermaid? | Pick your mermaid | No for the first version. The three mermaids already are the three girls. |
| 2 | Can a child wander into any zone, or only her own? | Reef map | Any unlocked zone. The map remembers each child's usual zone and highlights it. |
| 3 | Is the chest reward a surprise, or does she pick from three? | Treasure chest | A surprise. Picking needs reading or explaining; a surprise needs neither. |
| 4 | Is the grotto about decorating, collecting sea pets, or a story? | Grotto | Decorating, as storyboarded (lamp, kelp curtain, shell bed). |
| 5 | Should any palette color be swapped or adjusted? | Everywhere | Keep as is. |
| 6 | Do the Baloo 2 numerals match how Ophelia is taught to write 4, 7 and 9? | Every numeral | Baloo 2 was chosen for its closed 4, flagged 1 and plain 7. Worth one look by the parent against her schoolwork. |

## Raised during design, not settled

| # | Question | Suggested default |
|---|---|---|
| 7 | Tide Pool levels: is "match, then listen, then count" the right ladder? What number range do the twins start with? | Yes to the ladder. Start with 1 to 5, widen to 10. |
| 8 | Coral Reef: when do the countable shells fade? | After several quick, correct answers in a row, fade them for the next question; bring them back after a wrong tap. |
| 9 | Deep Sea: what exactly unlocks it ("once addition is quick"), and what do its questions look like? | Unlock after a set number of Coral Reef dives finished without hints. Question format still needs designing. |
| 10 | Which twin has which hair? | Daphne has pigtails, Violet has buns. Swapping is a one-word change in `art-pipeline/mpuppet.py`, then `python3 make_pieces.py daphne violet`. |
| 11 | Is the crab the guide in every zone, or does each zone get its own? | The crab everywhere. One familiar voice. |
| 12 | What are the grotto items after the starfish lamp, and in what order? | Kelp curtain, then shell bed, as storyboarded. Each new item needs painting with the art recipe. |

## Not designed at all yet

| # | Question | Suggested default |
|---|---|---|
| 13 | What device is this for? | A tablet in landscape. The 800x600 design space is 4:3. |
| 14 | Whose voice speaks the prompts? | Record the parent. A familiar voice suits children this young. Use the browser's speech synthesis as a stand-in while building. |
| 15 | What does the parent screen show, and how is it kept away from small fingers? | Per-child progress and a way to reset. Open it with a long press on the wordmark. |
| 16 | How is progress saved, and does it need to sync between devices? | On the device only. |
| 17 | Music and sound effects? | Quiet ambient water, a soft chime for a right answer, nothing for a wrong one. |
