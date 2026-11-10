# Game design

Status key: **Decided** means the parent agreed to it during design. **Proposed** means it was suggested and not yet confirmed. Anything proposed is also listed in `open-questions.md`.

## The loop (decided)

One play session is one **dive**.

1. **Pick your mermaid.** Each child taps her own mermaid. No reading, no login.
2. **Reef map.** She picks a zone. The twins start in Tide Pool, Ophelia in Coral Reef.
3. **Dive.** About 10 questions. Each right answer adds one pearl to the counter at the top right.
4. **Treasure chest.** Ten pearls fill the counter and the chest opens with one new item.
5. **My grotto.** She places the item in her grotto. Empty spots show what is still to come. This is the reason to come back tomorrow.
6. **Dive again**, or switch mermaid.

## Rules that never bend (decided)

- No timers. No lives. No score that can go down.
- A wrong tap is never punished. The wrong bubble fades to 45% and a counting hint appears. She can keep trying.
- Only the right answer glows (it turns gold).
- Every prompt is spoken aloud. Tapping the crab or the shell says it again.
- The written prompt spells the number as a word and never shows the digit: "Find the number four!"

## Zones

### Tide Pool: number recognition (twins)

Decided: the crab says a number, three bubbles show numerals, she taps the matching one. This is the locked style frame.

- Right: the bubble turns gold, the counter fills one pearl. On the tenth pearl the panel reads "You found four! That makes 10 pearls." with an "Open the chest" button.
- Wrong: that bubble fades, and a panel appears: "Count with me" followed by as many orange dots as the target number.

Proposed, not confirmed: three levels inside Tide Pool, in this order.

1. **Match.** She sees a numeral and finds the same numeral.
2. **Listen.** She hears the number and finds the numeral (the style frame).
3. **Count.** She counts objects and finds the numeral.

The number range for the twins has not been set. Starting with 1 to 10 is a reasonable default.

### Coral Reef: addition to 10 (Ophelia)

Decided: the sum is shown with countable shells above each number (three orange shells over the 3, two teal shells over the 2), then three answer bubbles. The shells fade out as she gets faster, so she moves from counting to knowing. The crab is the guide here too, in the same spot as in the Tide Pool (a design default, not yet confirmed by the parent).

- Right: "3 and 2 make 5! That makes 10 pearls." and "Open the chest" on the tenth.
- Wrong: a hint that counts on across both groups: "Count all the shells: 1, 2, 3 and then 4, 5".

How fast is "faster" and how the shells fade (per question, per dive) is not specified yet.

### Deep Sea: counting by 2s and 5s (locked on the map)

Decided: it exists, it is shown locked with a dashed gold ring and a padlock, and it "unlocks once addition is quick". Ophelia can already count by 2s and 5s.

Not designed: the question format, and the exact unlock rule.

## Reward loop

Decided: one dive earns one grotto item. The storyboard shows a starfish lamp, a kelp curtain and a shell bed, with dashed rings marking "Next dive", "2 more dives" and "3 more dives". On the chest and grotto screens the child's own mermaid is there with her.

Open: whether the chest gives a surprise or lets her pick from three, and whether the grotto is about decorating, collecting sea pets, or a story. See `open-questions.md`.

## Screen copy (as storyboarded)

| Screen | Text |
|---|---|
| Pick your mermaid | "Who is diving today?" and the three names |
| Reef map | "Where shall we dive?", "Switch mermaid", "Tide Pool: Find the number", "Coral Reef: Adding to 10", "Deep Sea: Counting by 2s and 5s" |
| Tide Pool | "Find the number four!", "Count with me", "You found four! That makes 10 pearls.", "Open the chest" |
| Coral Reef | "3 + 2 = ", "Count all the shells: 1, 2, 3 and then 4, 5", "3 and 2 make 5! That makes 10 pearls.", "Open the chest" |
| Chest | "10 pearls! The chest is open.", "You earned a starfish lamp!", "Put it in my grotto" |
| Grotto | "My grotto", "Dive again", "New! Starfish lamp", "Kelp curtain", "Shell bed", "Next dive", "2 more dives", "3 more dives" |

The children do not read these. They are for the parent sitting alongside, and every one needs a spoken version.

## Still to build (agreed to leave for the build phase)

- Game logic: question generation, the pearl counter, progression between levels and zones.
- Voice and sound. The storyboard is silent.
- Saved progress per child.
- A parent screen. Nothing has been designed for it.
