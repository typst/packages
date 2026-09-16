# `vlna` package for Typst

In Czech typography, **„vlna"** (literally "wave") is a non-breaking space — the
tilde `~` in Typst/LaTeX. This package inserts non-breaking spaces
automatically, so that lines never break in the places where Czech
typographic rules forbid it: after short prepositions, inside numbers and
dates, between a number and its unit, in compound abbreviations, and more.

It implements the guideline of the Institute of the Czech Language
([Internetová jazyková příručka, ?id=880](https://prirucka.ujc.cas.cz/?id=880))
and mirrors the feature set of `luavlna` (Michal Hoftich) — every rule group
has its own on/off switch.

## Usage

```typ
#import "@preview/vlna:0.3.0": apply-vlna
#show: apply-vlna
```

That is all — the defaults follow the ÚJČ guideline. Debug mode outlines
every glued block so you can see exactly what the package did:

```typ
#show: apply-vlna.with(debug: true)
```

## What it does

- **One-/two-letter words** — `k`, `s`, `v`, `z`, `a`, `i`, but also `na`,
  `po`, `je`, `se`, … are bound to the following word. The first letter may
  be uppercase (a sentence may start with `V lese…`); the optional second
  letter must be lowercase, so acronyms like `EU`, `AI`, `OSN` are left
  alone.
- **Titles / abbreviations before a name** — `Ing. arch. Novák`,
  `pplk. gšt. Svoboda`, `dr. h. c. Dvořák`, `viz tabulka`, `tzv. postup`,
  `s. 12`, `obr. 1`, `tab. 3`.
- **Titles after a name** — `Novák, Ph.D.`, `Malý, CSc.`
- **Initials and abbreviated given names** — `M. J. Hegel`, `Ž. Zíbrt`,
  `Fr. Daneš`, `Ch. Novák`.
- **Numbers** — digit grouping (`2 500`, `25,325 23`), phone numbers
  (`+420 800 123 987`, `800 11 22 33`), number + symbol (`50 %`, `§ 23`,
  `* 1921`, `† 2000`), number + unit, abbreviation or currency (`10 kg`,
  `19 °C`, `5 str.`, `1 000 000 Kč`, `250 €`).
- **Ratios and scales** — `1 : 50 000`, `5 : 3`, `10 : 2 = 5`.
- **Dates** — day and month stay together, the year may separate:
  `21. 6. | 2024`, `16. ledna | 1972`.
- **Compound abbreviations and codes** — `a. s.`, `s. r. o.`, `př. n. l.`,
  `T. G. M.`, `PS PČR`, `FF UK`, `ČSN 01 6910`.
- **Dashes** — a spaced dash stays at the end of the line (`slovo –`);
  an unspaced range dash never breaks (`1948–1989`).
- **Web and e-mail addresses** — `link()` URLs get break opportunities
  exactly where ÚJČ recommends them (after `/`, before `.` and `-`,
  around `@`); social-media handles (`@SenatCZ`) never break after `@`.
- **Chaining** — runs like `k s bratrem`, `o 2 500 Kč`, `od 21. 6.` or
  `plk. gšt. doc. Mgr. et Mgr. Ing. Libor Kutěj` stay together as one block.
- **Raw/code is skipped** — nothing is glued inside `raw`, inline or block.

## Options

Every rule group can be switched off (or on) independently:

| Parameter | Default | Binds |
|---|---|---|
| `bind-two-letter-words` | `true` | two-letter words in addition to one-letter ones |
| `short-words` | `auto` | which short words are bound (`none` disables them) |
| `initials` | `true` | `M. J. Hegel`, `Fr. Daneš`, `Ž. Zíbrt` |
| `compound-initials` | `("Ch",)` | multi-letter initials: `Ch. Novák` |
| `titles` | `true` | titles/abbreviations before and after a name |
| `numbers` | `true` | `2 500`, `50 %`, `§ 23`, `10 kg`, `+420 800 123 987` |
| `units` | `default-units` | units/currencies bound after a number |
| `ratios` | `true` | `1 : 50 000`, `10 : 2 = 5` |
| `dates` | `true` | `21. 6. \| 2024`, `16. ledna \| 1972` (year may separate) |
| `months` | `auto` (Czech) | month names recognised in dates |
| `number-word` | `false` | `500 lidí`, `strana 2`, `5. pluk`, `Karel IV.` |
| `abbreviations` | `true` | `a. s.`, `př. n. l.`, `PS PČR`, `ČSN 01 6910` |
| `dashes` | `true` | `slovo –` at line end; `1948–1989` unbroken |
| `links` | `true` | ÚJČ break points inside `link()` addresses |
| `lang` | `auto` | force one language's set (see per-language sets) |
| `debug` | `false` | outline every glued block |

Notes:

- `units` **replaces** the default list; extend it instead with
  `units: default-units + ("µm", "dpt")` (`default-units` is exported).
- `number-word` implements "číslo + název počítaného jevu" literally, which
  removes a lot of break opportunities — that is why it is off by default.
- The uppercase branch of `abbreviations` is limited to 2–4 letters per
  part, so ALL-CAPS headings are not glued word by word.
- `links` inserts zero-width spaces (U+200B) into the *displayed* address —
  the technique the ÚJČ note itself recommends. The link target (`dest`)
  is untouched and stays clickable.

### Which short words are bound

By default, both one- and two-letter words are bound. The strict Czech rule
requires this only for one-letter prepositions/conjunctions — binding all
two-letter words is a stronger convention that can hurt line breaking in
narrow layouts (mobile-friendly pages, multi-column text):

```typ
// Bind only one-letter words; `na`, `po`, `je`, `se`, … may end a line:
#show: apply-vlna.with(bind-two-letter-words: false)

// Bind exactly these words and nothing else (case-sensitive).
// A string is a set of single letters — this example binds one-letter
// prepositions, their uppercase forms, and uppercase A/I, while allowing
// lowercase `a`/`i` at the end of a line:
#show: apply-vlna.with(short-words: "vksuozVKSUOZAI")

// An array lists whole words, so two-letter words can be included:
#show: apply-vlna.with(short-words: ("v", "k", "s", "z", "a", "i", "na", "Na"))
```

`short-words` replaces the built-in short-word pattern entirely and takes
precedence over `bind-two-letter-words`.

### Per-language sets (luavlna `\singlechars`)

`short-words` also accepts a dictionary keyed by language code. The set is
then chosen by the language of the surrounding text (`text.lang`), and —
like in luavlna — **languages not listed are not processed at all** (neither
short words nor title runs; the other rule groups stay language-independent):

```typ
#set text(lang: "cs")             // required — the default text.lang is "en"!
#show: apply-vlna.with(short-words: (
  cs: "AIiVvOoUuSsZzKk",          // luavlna's default set for Czech
  sk: "AIiVvOoUuSsZzKk",
))
```

To force one language's set for the whole document regardless of `text.lang`
(luavlna `\preventsinglelang`):

```typ
#show: apply-vlna.with(short-words: (cs: "AIiVvOoUuSsZzKk"), lang: "cs")
```

### Initials (luavlna `\compoundinitials`)

Initials and abbreviated given names — an uppercase letter, optionally
followed by a lowercase one, plus a period — are bound to the next word and
chain with titles: `M. J. Hegel`, `Fr. Daneš`, `Ing. B. Novák`. Compound
letters that count as one initial default to `Ch` (`Ch. Novák`):

```typ
#show: apply-vlna.with(compound-initials: ("Ch",))  // default
#show: apply-vlna.with(initials: false)             // turn initials off
```

### Mid-document toggles (luavlna `\preventsingleon/off`)

A global `show` rule cannot be cancelled from inside the document, so the
package provides state-based switches:

```typ
#import "@preview/vlna:0.3.0": apply-vlna, vlna-on, vlna-off, vlna-debug-on, vlna-debug-off
#show: apply-vlna

Tady se váže. #vlna-off() Tady ne. #vlna-on() A tady zase.
#vlna-debug-on() Orámuje zásahy odsud dál. #vlna-debug-off()
```

### luavlna command mapping

| luavlna | vlna for Typst |
|---|---|
| `\singlechars{czech}{AIiVvOoUuSsZzKk}` | `short-words: (cs: "AIiVvOoUuSsZzKk")` |
| `\compoundinitials{czech}{Ch}` | `compound-initials: ("Ch",)` |
| `\preventsinglelang{czech}` | `lang: "cs"` |
| `\preventsingleoff` / `\preventsingleon` | `#vlna-off()` / `#vlna-on()` |
| `\preventsingledebugon` / `...off` | `#vlna-debug-on()` / `#vlna-debug-off()` (or the `debug: true` parameter) |

## How it works (and why jump-to-source is preserved)

A `show` rule that rebuilds text (`it.text.replace(" ", "~")`) produces
**new** content whose source position points at the rule itself — so
clicking a letter in the PDF jumps to the package code, not to your
document. This package instead wraps the **original matched content** in
`#box(..)`. The box cannot break internally, yet the glyphs keep their
original source span, so clicking them jumps to your document.

Compile-time cost is roughly 2–2.5× of the bare document and scales
linearly (measured: a 300-page all-rules-firing document compiles in
~2.4 s vs. ~1.0 s without the package).

## Limitations

- Inside a box, spaces do not stretch under justification and words are not
  hyphenated; a very long word right after a preposition can produce a
  looser line. In extremely narrow columns, a glued group wider than the
  line wraps at the column edge instead of gluing.
- Matches cannot cross styling boundaries: in `k *lesu*` the `k` is not
  bound, because the bold word is a separate element.
- Initials are a heuristic — a sentence ending with a bare capital
  (`… vitamin C. Nový výzkum`) is indistinguishable from an initial and
  gets bound too. Use `initials: false` if that bothers you.
- Text copied from a PDF may contain the invisible U+200B characters that
  `links` inserted, and jump-to-source is not preserved for the rewritten
  URL text (it is for everything else).

## Implementation status

| # | Feature | 0.1.1 | 0.2.0 | 0.3.0 |
|---|---------|:-----:|:-----:|:----:|
| 1 | One-/two-letter words | ✅ (via `~`) | ✅ (box, source-safe) | ✅ configurable |
| 9 | Abbreviations / titles **before** a name | ⚠️ partial | ✅ | ✅ |
| — | Titles **after** a name (`Ph.D.`, `CSc.`) | — | ✅ | ✅ |
| — | Chaining of words / titles | — | ✅ | ✅ |
| — | Debug visualisation | — | ✅ | ✅ + mid-doc toggle |
| — | Initials (`M. J. Hegel`), compound `Ch.` | — | — | ✅ |
| — | Per-language sets, `lang` forcing, on/off | — | — | ✅ |
| 2–8 | Digit groups, number + symbol/unit, dates, ratios, phone numbers | ❌ | ❌ | ✅ |
| — | Number + counted noun (`500 lidí`, `strana 2`) | — | — | ✅ opt-in |
| — | Compound abbreviations (`a. s.`, `ČSN 01 6910`), dashes | — | — | ✅ |
| — | URL / e-mail break points (ÚJČ, via U+200B) | — | — | ✅ |

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT — © 2025–2026 iamanro.
