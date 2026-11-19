# ransom

Cut-out ransom-note letters for [Typst](https://typst.app). Every letter comes
from a different scrap of paper, in a different typeface, at a slightly
different angle, with ragged scissor-cut edges and a faint shadow.

Write ordinary Typst; get a ransom letter.

## Quick start

Start off from the template:

```sh
typst init @preview/ransom
```

or, to use it in an existing document:

```typ
#import "@preview/ransom:0.1.0": *

#show: ransom-note.with(title: "A Polite Demand", seed: 7)

= We have your thesis

Leave one espresso under the third bench. Tell *no one*.
```

Headings, lists, tables, links, footnotes and inline code are all cut out.
Heading text comes out larger because the letters follow the size of the text
around them.

## Cutting letters yourself

Prefer to keep your document normal and cut only a few words? Turn the
document-wide behaviour off, and call `ransom` where you want it:

```typ
#show: ransom-note.with(cut-text: false, surface: "none")

Plain text stays plain. #ransom(size: 2.4em, seed: 3)[Except this.]
```

`ransom` also works with no template at all:

```typ
#import "@preview/ransom:0.1.0": ransom

#ransom(palette: "noir", tilt: 12deg)[Meet me at midnight.]
```

Typst's strong text (`*...*`) and emphasized text (`_..._`) are cut out as
single pieces, while the rest is cut letter by letter:


## `ransom` options

| Option       | Default        | Meaning                                                           |
| ------------ | -------------- | ----------------------------------------------------------------- |
| `seed`       | `1`            | Any int or string. Same seed, same arrangement, every compile.    |
| `size`       | `1.0em`        | Base letter size. `em` follows the surrounding text.              |
| `palette`    | `"classic"`    | `"classic"`, `"noir"`, `"candy"`, `"vintage"`, or an array of `scrap`s. |
| `faces`      | `"embedded"`   | `"embedded"`, `"expressive"`, or an array of `face`s.             |
| `case`       | `"mixed"`      | `"mixed"`, `"upper"`, `"lower"` or `"keep"`.                      |
| `tilt`       | `8deg`         | Largest rotation of one letter.                                   |
| `sway`       | `12%`          | Largest vertical wobble, as a share of `size`.                    |
| `scale`      | `(90%, 120%)`  | Smallest and largest letter size, as shares of `size`.            |
| `cut-words`  | `10%`          | Share of short words cut out whole, as one headline.              |
| `backing`    | `25%`          | Share of letters that keep a white paper margin.                  |
| `ragged`     | `7%`           | How uneven the scissor cuts are.                                  |
| `shadow`     | `true`         | Whether scraps cast a faint shadow.                               |
| `tracking`   | `4%`           | Gap between letters, as a share of `size`.                        |
| `word-gap`   | `80%`          | Gap between words, as a share of `size`.                          |

## `ransom-note` options

| Option     | Default      | Meaning                                                               |
| ---------- | ------------ | --------------------------------------------------------------------- |
| `title`    | `none`       | Document title for the PDF metadata.                                  |
| `seed`     | `1`          | Reshuffles every letter when changed.                                 |
| `surface`  | `"lined"`    | `"plain"`, `"lined"`, `"grid"`, `"kraft"` or `"none"`.                |
| `folds`    | `true`       | Show the creases of a letter folded in thirds.                        |
| `cut-text` | `true`       | `false` leaves text alone; cut only where you call `ransom`.          |
| `paper`    | `"a4"`       | Page size.                                                            |
| `margin`   | `auto`       | `auto` is 2.4 cm, with extra room left of lined paper's margin line.  |
| `size`     | `1.0em`      | Base letter size relative to the 11 pt text.                          |

Any other named argument (`palette`, `faces`, `tilt` …) is passed on to `ransom`.

## Your own paper and type

```typ
#import "@preview/ransom-note:0.1.0": *

#show: ransom-note.with(
  palette: (
    scrap(rgb("#ff5d8f"), white, weight: 3),      // fill, ink, how often
    scrap(rgb("#ffe066"), black),
    scrap(tiling(size: (4pt, 4pt))[#square(size: 2pt)], black),
  ),
  faces: (
    face("Libertinus Serif", weight: "bold"),
    face("DejaVu Sans Mono", weight: "bold"),
    // System fonts work too, with fallbacks: face(("Impact", "DejaVu Sans Mono"))
  ),
)
```

A `scrap` fill can be any Typst paint, including gradients and tilings.

## Good to know

- **Fonts.** The default `"embedded"` face set only uses fonts that ship with
  Typst, so the result is identical everywhere. `"expressive"` prefers common
  system fonts (Impact, Georgia, Courier New …) and falls back to embedded ones,
  but Typst prints a warning for every family it cannot find.
- **Stable edits.** Each paragraph, line and word gets its own random state
  derived from its position, so fixing a typo does not reshuffle the rest of
  the page. Change `seed` to reshuffle everything on purpose.
- **Formatting is dropped.** Strong and emphasized chunks are cut out whole;
  other formatting is discarded. Equations and images are left as they are.
- **Long words wrap.** Words longer than ten letters, such as URLs, are split
  into chunks that Typst may break between.
- **Quotes.** Apostrophes and quotation marks are cut out too, always as
  straight quotes.
- **Line spacing.** Scraps are taller than ordinary text. When using `ransom`
  on its own, a generous `set par(leading: 1em)` keeps lines apart.

## How it works

Typst has no random-number function and documents must compile identically
every time, so the package carries a tiny seeded generator. Each letter is
measured, drawn onto a jittered eight-point polygon, and rotated without
reflow so neighbouring scraps overlap like glued paper. The document template
works by matching ordinary `text` with a show rule; the letters it produces
are marked with `overhang: false`, which is what keeps the rule from matching
its own output.
