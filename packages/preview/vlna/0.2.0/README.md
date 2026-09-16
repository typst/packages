# `vlna` package for Typst

In Czech typography, **„vlna"** (literally "wave") is a non-breaking space — the
tilde `~` in Typst/LaTeX. This package inserts non-breaking spaces automatically
so that lines never end with a one-/two-letter word, a title, or a common
abbreviation.

> Version 0.2.0 rewrites the core so that **jump-to-source keeps working** and
> adds title/abbreviation handling with chaining support.

## Usage

```typ
#import "@preview/vlna:0.2.0": apply-vlna
#show: apply-vlna
```

Debug mode outlines every glued block (short-word runs, titles before a name,
titles after a name):

```typ
#show: apply-vlna.with(debug: true)
```

## What it does

- **One-/two-letter words** — `k`, `s`, `v`, `z`, `a`, `i`, but also `na`, `po`,
  `je`, `se`, … are bound to the following word. First letter may be uppercase
  (so a sentence may start with `V lese…`); the optional second letter must be
  lowercase, so acronyms like `EU`, `AI`, `OSN` are left alone.
- **Titles / abbreviations before a name** — `Ing. arch. Novák`,
  `pplk. gšt. Svoboda`, `dr. h. c. Dvořák`, `viz tabulka`, `tzv. postup`, `s. 12`.
- **Titles after a name** — `Novák, Ph.D.`, `Malý, CSc.`
- **Chaining** — runs like `k s bratrem` or `plk. gšt. doc. Mgr. et Mgr. Ing.
  Libor Kutěj` stay together as one block.

## How it works (and why jump-to-source is preserved)

A `show` rule that rebuilds text (`it.text.replace(" ", "~")`) produces **new**
content whose source position points at the rule itself — so clicking the
letter in the PDF jumps to the package code, not to your document.

Version 0.2.0 instead wraps the **original matched content** in `#box(..)`.
The box cannot break internally, yet the glyphs keep their original source
span, so clicking them jumps to your document.

**Trade-off:** inside a box, spaces do not stretch under justification and the
words are not hyphenated. In practice this is not noticeable; a very long word
right after a preposition could occasionally produce a slightly looser line.

## Implementation status

| # | Feature | 0.1.1 | 0.2.0 |
|---|---------|:-----:|:-----:|
| 1 | One-/two-letter words | ✅ (via `~`) | ✅ (box, source-safe) |
| 9 | Abbreviations / titles **before** a name | ⚠️ partial | ✅ |
| — | Titles **after** a name (`Ph.D.`, `CSc.`) | — | ✅ |
| — | Chaining of words / titles | — | ✅ |
| — | Debug visualisation | — | ✅ |
| 2–8 | Digit groups, numbers + units, dates, … | ❌ | ❌ |

The goal mirrors `luavlna` (Michal Hoftich) and the Czech typographic rules of
the Institute of the Czech Language:
<https://prirucka.ujc.cas.cz/?id=880>

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT — © 2025–2026 iamanro.
