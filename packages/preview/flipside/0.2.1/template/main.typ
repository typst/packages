#import "@preview/flipside:0.2.1": *

// "cards": the sheets to print; "list": one card per row (question | answer), to check
#let layout = "cards"
// Card size: "DIN A8" (16 per A4), "DIN A7" (8), "DIN A6" (4), "DIN A5" (2),
// "US 3x5", "US 4x6", "US business", "EU business" or (width: …, height: …)
#let card = "DIN A8"

#let title = "Capitals of the world"
// Card number as "5/16"
#let number(c) = if c.number != none [#c.number/#c.total]

#flipside(
  title: title,
  layout: layout,
  card: card,
  lang: "en",                 // or one per side: (q: "de", a: "fr")
  // Header and footer of the question side: (left: …, center: …, right: …).
  // A slot is content, or a function that gets the card (c.theme, c.number, c.total, …).
  header: (left: smallcaps[My school], right: title),
  footer: (left: c => c.at("theme", default: none), right: number),
  // The answer side: the card number, to check the cards after cutting
  back-footer: (right: c => text(fill: gray, number(c))),
  // A coloured stripe on one edge, one colour per theme, to sort the cards
  stripe: auto,
  // Shift of the answer pages for your printer, measured with
  // `typst compile --input layout=calibrate main.typ`
  back-offset: (x: 0mm, y: 0mm),
  (
    (theme: "Europe"),        // no card: the theme of the cards below
    (q: [France], a: [Paris]),
    (q: [Germany], a: [Berlin]),
    (q: [Italy], a: [Rome]),
    (q: [Spain], a: [Madrid]),
    (q: [Luxembourg], a: [Luxembourg]),
    (q: [Portugal], a: [Lisbon]),

    (theme: "Asia"),
    (q: [Japan], a: [Tokyo]),
    (q: [India], a: [New Delhi]),
    (q: [Thailand], a: [Bangkok]),
    (q: [Vietnam], a: [Hanoi]),

    (theme: "Several lines"),
    (
      q: [
        Which country has \
        two capital cities? \
        #small[(one official, one seat of government)]
      ],
      a: [
        The Netherlands \
        Amsterdam (official) \
        The Hague (government)
      ],
    ),
    (
      q: [Australia],
      a: [
        Canberra \
        #small[(not Sydney!)]
      ],
    ),

    (theme: "Maths"),
    (q: [$a^2 + b^2 = ?$ \ #small[(right triangle)]], a: [$c^2$ \ #small[Pythagoras]]),
    (q: [$sqrt(144) = ?$], a: [$12$]),
    (q: [$1/2 + 1/4 = ?$], a: [$3/4$]),
    (q: [$pi approx ?$], a: [$3.14159...$]),
  ),
)
