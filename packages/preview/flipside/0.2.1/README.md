Double-sided flash cards that line up when printed. Write the questions and
answers, print the PDF double-sided, cut along the lines: every card has its
question on the front and its answer on the back.

![A sheet of DIN A8 cards](https://raw.githubusercontent.com/ffasbend/flipside/v0.2.1/thumbnail.png)

- **Any card size:** DIN A8, A7, A6, A5, US index cards (3×5, 4×6 in),
  business cards on perforated sheets, or your own size; A4 or Letter paper;
  landscape or upright cards.
- **A list to check the cards:** every card on one row, question and answer
  side by side, exactly as printed.
- **A calibration sheet** to make up for printers that shift the back side.
- **Cards from a CSV file**, e.g. a word list from Excel.
- **Header and footer** with three slots each: logo, theme, card number, …
- **Coloured stripes** per theme, to sort the cut cards.
- **Text that is too large is shrunk** to fit, and marked in the list.
- **Reprint** single cards without the rest of the deck.
- **Both directions** (`dir: "both"`), **several items** (`all`, `any`) and
  **hints** shown only as question or only as answer (`[? …]`, `[! …]`), e.g.
  for vocabulary.

The [manual](https://github.com/ffasbend/flipside/releases/download/v0.2.1/flipside-manual-0.2.1.pdf)
(PDF, attached to each [release](https://github.com/ffasbend/flipside/releases)) explains
everything, with many examples.

Needs Typst 0.15.1 or newer.

## Getting started

```typst
#import "@preview/flipside:0.2.1": *

#flipside((
  (q: [France], a: [Paris]),
  (q: [Germany], a: [Berlin]),
  (q: [Which country has \ two capital cities?], a: [Bolivia \ #small[(Sucre and La Paz)]]),
))
```

or start from the template:

```sh
typst init @preview/flipside:0.2.1 my-cards
```

Page 1 holds the questions with cutting lines, page 2 the answers, mirrored so
that each answer lands behind its question. Print **all pages double-sided at
100 %**: *flip on short edge* for a landscape sheet, *flip on long edge* for a
portrait sheet.

## Checking the cards

```sh
typst compile --input layout=list cards.typ cards-list.pdf
```

![The list](https://raw.githubusercontent.com/ffasbend/flipside/v0.2.1/thumbnail-list.png)

## Themes, header and footer

```typst
#let number(c) = if c.number != none [#c.number/#c.total]

#flipside(
  header: (left: image("logo.png", width: 19mm), right: [Geography · 7a]),
  footer: (left: c => c.theme, right: number),
  back-footer: (right: c => text(fill: gray, number(c))),
  stripe: auto,
  (
    (theme: "Europe"),          // no card: the theme of the cards below
    (q: [France], a: [Paris]),
    (theme: "Asia"),
    (q: [Japan], a: [Tokyo]),
  ),
)
```

A slot is content, or a function that gets the card (`c.theme`, `c.number`,
`c.total`, …). `header`/`footer` are the question side,
`back-header`/`back-footer` the answer side.

## Cards from a CSV file

```typst
#flipside(lang: (q: "de", a: "fr"), csv("words.csv", row-type: dictionary))
```

```csv
q,a,theme
der Verkäufer,"le vendeur
la vendeuse",Berufe
der Sänger,le chanteur,
```

Columns `q` and `a`, any other column becomes a field; an empty cell keeps the
value above; a line break in a cell is a line break on the card.

## Both directions, items and hints

```typst
#flipside(
  lang: (q: "de", a: "fr"),
  dir: "both",                                           // every card both ways
  (
    (q: [laut [? (m/f)]], a: [bruyant, bruyante]),
    (q: [der Lift, [? ein Lift]], a: [l'ascenseur, [! un ascenseur]]),
    (q: [der Kühlschrank], a: any[le réfrigérateur][le frigo]),
    (q: [die Möbel #q-note[Plural]], a: all[les meubles][le mobilier]),
  ),
)
```

- `[? …]` is shown only when its side is asked, `[! …]` only when it is the
  answer (`#q-only[…]` / `#a-only[…]` for maths or bold).
- `all[…][…]`: as the question one card, as the answer all needed;
  `any[…][…]`: as the question one card per item, as the answer any one right.
- `#note[…]`, `#q-note[…]`, `#a-note[…]`: notes on a line of their own.

## Card sizes

| `card:` | Card | Paper | Per sheet |
|---|---|---|---|
| `"DIN A8"` (default) | 74 × 52 mm | A4 | 16 |
| `"DIN A7"` | 105 × 74 mm | A4 | 8 |
| `"DIN A6"` | 148 × 105 mm | A4 | 4 |
| `"DIN A5"` | 210 × 148 mm | A4 | 2 |
| `"US 3x5"` | 5 × 3 in | Letter | 4 |
| `"US 4x6"` | 6 × 4 in | Letter | 2 |
| `"US business"` | 3.5 × 2 in | Letter | 10 |
| `"EU business"` | 85 × 54 mm | A4 | 10 |
| `(width: 90mm, height: 60mm)` | your own | A4 | as many as fit |

`paper: "us-letter"` (or `"a4"`, `"a3"`, `"a5"`, `"us-legal"`) changes the
paper, `orientation: "portrait"` makes the cards upright. Your own size can
also give `cols`, `rows`, `gap` and `margin` to match a perforated sheet.

## Printing

- **Back side shifted?** Print the calibration sheet
  (`--input layout=calibrate`), hold it against the light, read the values on
  the rulers and set `back-offset: (x: 0.8mm, y: -0.5mm)`.
- **Reprint lost cards:** `--input only=5-12,17`; the numbers stay those of the
  whole deck.

Everything that changes between printouts can be chosen when compiling, and
wins over the file: `--input layout=…`, `card=…`, `paper=…`,
`orientation=…`, `only=…`, `back-offset=…`, `dir=…`.

## Parameters

| Parameter | Default | |
|---|---|---|
| `cards` | — | `(q: […], a: […])`, entries with fields only, `(q: [], a: [])` for a blank card, CSV rows |
| `header`, `footer`, `back-header`, `back-footer` | `(:)` | slots `(left:, center:, right:)` |
| `title` | `none` | name of the deck, in the list's footer |
| `lang` | `"en"` | `"fr"` or `(q: "de", a: "fr")` |
| `font`, `size` | New Computer Modern, 13 pt | text of the cards |
| `slot-font`, `slot-size` | New Computer Modern, 7 pt | text of the slots |
| `back-borders` | `false` | outline the answer cards too |
| `fit` | `true` | shrink a side that is too large |
| `stripe`, `stripe-width` | `none`, 2.5 mm | `auto`, `("Theme": colour)` or `c => colour` |
| `markup` | `false` | read CSV cells as Typst markup |
| `back-offset` | `(x: 0mm, y: 0mm)` | shift of the answer pages |
| `only` | `none` | `"5-12,17"`, `(3, 8)` or `c => bool` |
| `layout` | `"cards"` | `"cards"`, `"list"`, `"calibrate"`, `"report"` (for the MyCards app) |
| `dir` | `"forward"` | `"reverse"` or `"both"`; a card's own `dir` wins |
| `count` | `n => [(n)]` | shown on the question when more than 2 items are needed |
| `card`, `paper`, `orientation` | `"A8"`, `auto`, `"landscape"` | see Card sizes |

Helpers: `small[…]` (72 %), `tiny[…]` (60 %), `block-left[…]` (left-aligned,
justified).

## Examples

The [examples](https://github.com/ffasbend/flipside/tree/v0.2.1/examples) folder of the repository holds complete decks: a German–French
vocabulary from CSV learnt both ways with hints, maths with formulas, chemical elements on business-card
sheets, US index cards, upright cards of your own size.

## Development

Tests, the manual's sources and how a version is released: see
[CONTRIBUTING.md](https://github.com/ffasbend/flipside/blob/v0.2.1/CONTRIBUTING.md) in the repository.

## Author and license

Frank Fasbender, <ffasbend@gmail.com> ·
[github.com/ffasbend/flipside](https://github.com/ffasbend/flipside)
(questions, ideas and bug reports: please open an
[issue](https://github.com/ffasbend/flipside/issues)).

MIT, © 2026 Frank Fasbender
