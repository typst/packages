#import "@preview/childrens-book:0.1.0": *

#show: childrens-book.with(
  title: "Luna and the Starry Night",
  author: "A. Example",
  illustrator: "B. Creative",
  title-color: rgb("#1a3a5c"),
)

// Helper: placeholder illustration boxes with colored backgrounds
#let scene(bg-color, elements) = {
  block(
    width: 100%,
    height: 100%,
    fill: bg-color,
    radius: 0pt,
    align(center + horizon, elements),
  )
}

#book-part("Part One", subtitle: "The Adventure Begins")

// --- Page 1: Full-page illustration (night sky) ---
#full-page-illustration(
  scene(
    rgb("#0b1a3b"),
    {
      text(size: 40pt, fill: rgb("#ffe066"), "\u{2605}  \u{2605}  \u{2605}")
      v(3mm)
      text(size: 24pt, fill: rgb("#ffe066"), "\u{2605}   \u{2605}")
      v(3mm)
      text(size: 32pt, fill: rgb("#ffe066"), "\u{2605}  \u{2605}  \u{2605}  \u{2605}")
      v(5mm)
      text(size: 72pt, fill: rgb("#f0e68c"), "\u{263D}")
      v(5mm)
      block(
        width: 100%,
        height: 25mm,
        fill: rgb("#1a472a"),
        align(center + horizon, text(size: 32pt, "\u{1F332}  \u{1F332}  \u{1F332}")),
      )
    },
  ),
)

// --- Page 2: Story text ---
#story-page[
  Luna loved the night sky.

  Every evening she would sit
  by her window and count
  the stars, one by one.
]

// --- Page 3: Illustrated page (Luna at window) ---
#illustrated-page(
  scene(
    rgb("#1a1a40"),
    {
      text(size: 24pt, fill: rgb("#ffe066"), "\u{2605}   \u{2605}   \u{2605}")
      v(3mm)
      text(size: 56pt, fill: rgb("#f0e68c"), "\u{263D}")
      v(3mm)
      block(
        width: 50mm,
        height: 20mm,
        fill: rgb("#8b6914"),
        radius: 6pt,
        align(center + horizon, {
          block(
            width: 40mm,
            height: 14mm,
            fill: rgb("#1a1a40"),
            radius: 3pt,
            align(center + horizon, text(size: 18pt, "\u{1F467}")),
          )
        }),
      )
    },
  ),
)[
  "One, two, three ..."
  she whispered softly.

  "I wish I could visit
  the stars!"
]

// --- Page 4: Story text ---
#story-page[
  That night, something
  magical happened.

  A bright star floated
  down from the sky and
  landed right on her
  windowsill!
]

// --- Page 5: Full-page illustration (the bright star) ---
#full-page-illustration(
  scene(
    rgb("#0b0b2b"),
    {
      v(15mm)
      text(size: 100pt, fill: rgb("#ffe066"), "\u{2605}")
      v(5mm)
      text(
        size: 20pt,
        fill: rgb("#c8d8ff"),
        [_\~ \~ sparkle \~ \~_],
      )
    },
  ),
)

// --- Page 6: Story text ---
#story-page[
  "Hello, Luna!" said the star.

  "My name is Sol.
  Would you like to come
  on an adventure?"

  Luna smiled the biggest
  smile. "Yes, please!"
]

// --- Page 7: Illustrated page (flying through the sky) ---
#illustrated-page(
  scene(
    rgb("#0d1b3e"),
    {
      text(size: 18pt, fill: rgb("#ffe066"), "\u{2605}  \u{2605}  \u{2605}  \u{2605}  \u{2605}")
      v(2mm)
      text(size: 18pt, fill: rgb("#ffe066"), "  \u{2605}  \u{2605}  \u{2605}  \u{2605}")
      v(4mm)
      text(size: 44pt, "\u{1F467}")
      h(4mm)
      text(size: 44pt, fill: rgb("#ffe066"), "\u{2605}")
      v(2mm)
      text(size: 18pt, fill: rgb("#ffe066"), "\u{2605}  \u{2605}  \u{2605}  \u{2605}  \u{2605}")
    },
  ),
)[
  Sol took Luna's hand,
  and together they flew
  up, up, up into the
  starry night.
]

// --- Page 8: Story text ---
#story-page[
  They danced among
  the stars and played
  hide-and-seek behind
  the moon.

  Luna had never been
  so happy.
]

// --- Page 9: Full-page illustration (dancing near moon) ---
#full-page-illustration(
  scene(
    rgb("#0a0a30"),
    {
      v(8mm)
      text(size: 90pt, fill: rgb("#f5f5dc"), "\u{1F315}")
      v(4mm)
      text(size: 40pt, "\u{1F467}")
      h(5mm)
      text(size: 40pt, fill: rgb("#ffe066"), "\u{2605}")
      v(4mm)
      text(size: 16pt, fill: rgb("#aac8ff"), "\u{2605}  \u{2605}  \u{2605}  \u{2605}  \u{2605}  \u{2605}")
    },
  ),
)

// --- Page 10: Story text ---
#story-page[
  When morning came,
  Sol gently brought
  Luna back home.

  "Will you come back?"
  Luna asked.
]

// --- Page 11: Illustrated page (sunrise) ---
#illustrated-page(
  scene(
    gradient.linear(rgb("#ff9a56"), rgb("#ffcc33"), rgb("#87ceeb")),
    {
      v(5mm)
      text(size: 80pt, fill: rgb("#ff6600"), "\u{2600}")
      v(4mm)
      block(
        width: 100%,
        height: 20mm,
        fill: rgb("#2d8a4e"),
        align(center + horizon, text(size: 32pt, "\u{1F332}  \u{1F3E0}  \u{1F332}")),
      )
    },
  ),
)[
  "Every night," Sol
  whispered. "Just look
  up at the sky, and
  I will be there."
]

// --- Page 12: Story text (ending) ---
#story-page[
  And from that night on,
  whenever Luna looked up
  at the stars, the
  brightest one always
  twinkled just for her.
]

// --- The End ---
#the-end(color: rgb("#1a3a5c"))
