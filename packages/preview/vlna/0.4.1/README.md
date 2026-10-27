<h1 align="center">vlna</h1>

<p align="center">
  <strong>Czech non-breaking spaces for Typst, done by the rules.</strong><br>
  Lines never end where Czech typography forbids it, and jump-to-source keeps working.
</p>

<p align="center">
  <a href="https://typst.app/universe/package/vlna"><img alt="Latest version on Typst Universe" src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fiamanro%2Ftypst-vlna%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&label=typst%20universe&color=239DAD"></a>
  <a href="https://github.com/iamanro/typst-vlna/actions/workflows/test.yml"><img alt="Status of the line-break tests on the main branch" src="https://img.shields.io/github/actions/workflow/status/iamanro/typst-vlna/test.yml?branch=main&label=tests"></a>
  <a href="LICENSE"><img alt="License: MIT, see the LICENSE file" src="https://img.shields.io/github/license/iamanro/typst-vlna?color=blue"></a>
  <a href="https://prirucka.ujc.cas.cz/?id=880"><img alt="Follows the line-breaking guideline of the Czech Language Institute (ÚJČ AV ČR)" src="https://img.shields.io/badge/follows-%C3%9AJ%C4%8C%20AV%20%C4%8CR-c2504a"></a>
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#what-it-binds">What it binds</a> ·
  <a href="#options">Options</a> ·
  <a href="#legal-texts">Legal texts</a> ·
  <a href="#performance">Performance</a> ·
  <a href="#how-it-works">How it works</a>
</p>

<p align="center">
  <img alt="The same Czech paragraph set without vlna and with vlna; with vlna, debug frames outline every glued group: short prepositions, dates, numbers with units, titles, initials and a case number." src="https://raw.githubusercontent.com/iamanro/typst-vlna/992e46835f26e2f89eb23ad018c110380f838dba/examples/hero.png" width="860">
</p>

In Czech typography, **„vlna"** (literally "wave") is a non-breaking space,
the tilde `~` in Typst and LaTeX. This package inserts it for you, so a line
never ends after a one-letter preposition, inside a number or a date, between
a number and its unit, inside a compound abbreviation, and in every other
place the guideline of the Institute of the Czech Language
([ÚJČ AV ČR, ?id=880](https://prirucka.ujc.cas.cz/?id=880)) rules out. The
feature set mirrors `luavlna` (Michal Hoftich), and every rule group has its
own switch.

## Quick start

```typ
#import "@preview/vlna:0.4.1": apply-vlna
#show: apply-vlna
```

That is all: the defaults follow the ÚJČ guideline. To see exactly what the
package glued, outline every group:

```typ
#show: apply-vlna.with(debug: true)
```

## What it binds

| Rule group | Examples |
|---|---|
| One- and two-letter words | `k lesu`, `V lese`, `na kopci`; acronyms such as `EU`, `AI`, `OSN` stay free |
| Titles before a name | `Ing. arch. Novák`, `pplk. gšt. Svoboda`, `dr. h. c. Dvořák`, `viz tabulka`, `tzv. postup`, `s. 12`, `odst. 4`, `písm. a)` |
| Titles after a name | `Novák, Ph.D.`, `Malý, CSc.` |
| Initials | `M. J. Hegel`, `Ž. Zíbrt`, `Fr. Daneš`, `Ch. Novák` |
| Numbers | `2 500`, `25,325 23`, `+420 800 123 987`, `50 %`, `§ 23`, `† 2000`, `10 kg`, `19 °C`, `1 000 000 Kč`, `250 €` |
| Ratios and scales | `1 : 50 000`, `5 : 3`, `10 : 2 = 5` |
| Dates | `21. 6.` and `16. ledna` stay together; the year may move to the next line |
| Compound abbreviations and codes | `a. s.`, `s. r. o.`, `př. n. l.`, `T. G. M.`, `PS PČR`, `ČSN 01 6910` |
| Dashes | a spaced dash stays at the line end (`slovo –`); `1948–1989` never breaks |
| Web and e-mail addresses | `link()` addresses break only where ÚJČ allows: after `/`, before `.` and `-`, around `@` |
| Legal identifiers (opt-in) | `sp. zn. 12 Nt 345/2026`, `I. ÚS 2438/25`, `VINITIS s.r.o.`, `89/2012 Sb.` |

Groups chain: `k s bratrem`, `o 2 500 Kč`, `od 21. 6.` and
`plk. gšt. doc. Mgr. et Mgr. Ing. Libor Kutěj` each stay one block. Code in
`raw`, inline or block, is never touched.

## Options

Every rule group can be switched off, or on, independently:

| Parameter | Default | Binds |
|---|---|---|
| `bind-two-letter-words` | `true` | two-letter words in addition to one-letter ones |
| `short-words` | `auto` | which short words are bound (`none` disables them) |
| `initials` | `true` | `M. J. Hegel`, `Fr. Daneš`, `Ž. Zíbrt` |
| `compound-initials` | `("Ch",)` | multi-letter initials: `Ch. Novák` |
| `titles` | `true` | titles and abbreviations before and after a name |
| `numbers` | `true` | `2 500`, `50 %`, `§ 23`, `10 kg`, `+420 800 123 987` |
| `units` | `default-units` | units and currencies bound after a number |
| `ratios` | `true` | `1 : 50 000`, `10 : 2 = 5` |
| `dates` | `true` | `21. 6. \| 2024`, `16. ledna \| 1972` (the year may separate) |
| `months` | `auto` (Czech) | month names recognised in dates |
| `number-word` | `false` | `500 lidí`, `strana 2`, `5. pluk`, `Karel IV.` |
| `abbreviations` | `true` | `a. s.`, `př. n. l.`, `PS PČR`, `ČSN 01 6910` |
| `dashes` | `true` | `slovo –` at the line end; `1948–1989` unbroken |
| `links` | `true` | ÚJČ break points inside `link()` addresses |
| `legal` | `false` | Czech legal identifiers, see [Legal texts](#legal-texts) |
| `lang` | `auto` | force one language's set, see [per-language sets](#per-language-sets) |
| `debug` | `false` | outline every glued block |

- `units` **replaces** the default list. Extend it instead:
  `units: default-units + ("µm", "dpt")` (`default-units` is exported).
- `number-word` applies "číslo + název počítaného jevu" literally and removes
  many break opportunities, which is why it is off by default.
- The uppercase branch of `abbreviations` allows 2–4 letters per part, so
  ALL-CAPS headings are not glued word by word.
- `links` inserts zero-width spaces (U+200B) into the *displayed* address,
  the technique the ÚJČ note itself recommends. The link target (`dest`) is
  untouched and stays clickable.

## Legal texts

```typ
#show: apply-vlna.with(legal: true)
```

Off by default. Keeps the identifiers of Czech court filings and statutes in
one piece:

| Kind | Examples |
|---|---|
| Case numbers | `12 Nt 345/2026`, `4 Tdo 123/2025`, `2 KZV-12/2026`, `VZV 23/2026-22` |
| Constitutional Court | `I. ÚS 2438/25`, `Pl. ÚS 45/04` |
| Reference numbers, bank accounts | `KRPA-12345-67/TČ-2026-000089`, `19-1234567890/0100` |
| Statutes | `89/2012 Sb.`, `2/1993 Sb. m. s.`, `zák. práce`, `tr. zák.` (`o. s. ř.`, `tr. ř.`, `o. z.` are covered by `abbreviations`) |
| Legal forms, bound to the company name | `VINITIS s.r.o.`, `ABC a.s.`, `XY v.o.s.`, spaced forms too |
| Bound to what follows | `sp. zn.`, `č. j.`, `ev. č.`, `bod`, `bodu`, `věta`, `věty`: `sp. zn. 12 Nt 345/2026`, `věty první` |

The identifier is a block of its own inside `č. j. KRPA-…`: when the whole
run does not fit on a line, the break falls after `č. j.`, never inside the
identifier. In legal mode `věta` and `věty` also bind in ordinary sentences,
and hyphenated codes such as `COVID-19` are glued.

## Configuration guide

<details>
<summary><strong>Which short words are bound</strong></summary>

By default, both one- and two-letter words are bound. The strict Czech rule
requires this only for one-letter prepositions and conjunctions; binding all
two-letter words is a stronger convention that can hurt line breaking in
narrow layouts (mobile-friendly pages, multi-column text):

```typ
// Bind only one-letter words; `na`, `po`, `je`, `se`, … may end a line:
#show: apply-vlna.with(bind-two-letter-words: false)

// Bind exactly these words and nothing else (case-sensitive).
// A string is a set of single letters: this binds one-letter prepositions,
// their uppercase forms and uppercase A/I, while lowercase `a`/`i` may end
// a line:
#show: apply-vlna.with(short-words: "vksuozVKSUOZAI")

// An array lists whole words, so two-letter words can be included:
#show: apply-vlna.with(short-words: ("v", "k", "s", "z", "a", "i", "na", "Na"))
```

`short-words` replaces the built-in short-word pattern entirely and takes
precedence over `bind-two-letter-words`.

</details>

<details id="per-language-sets">
<summary><strong>Per-language sets</strong> (luavlna <code>\singlechars</code>)</summary>

`short-words` also accepts a dictionary keyed by language code. The set is
chosen by the language of the surrounding text (`text.lang`), and, as in
luavlna, **languages not listed are not processed at all** (neither short
words nor title runs; the other rule groups stay language-independent):

```typ
#set text(lang: "cs")             // required: the default text.lang is "en"
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

</details>

<details>
<summary><strong>Initials</strong> (luavlna <code>\compoundinitials</code>)</summary>

Initials and abbreviated given names (an uppercase letter, optionally
followed by a lowercase one, plus a period) are bound to the next word and
chain with titles: `M. J. Hegel`, `Fr. Daneš`, `Ing. B. Novák`. Compound
letters that count as one initial default to `Ch` (`Ch. Novák`):

```typ
#show: apply-vlna.with(compound-initials: ("Ch",))  // default
#show: apply-vlna.with(initials: false)             // turn initials off
```

</details>

<details>
<summary><strong>Mid-document toggles</strong> (luavlna <code>\preventsingleon/off</code>)</summary>

A global `show` rule cannot be cancelled from inside the document, so the
package provides state-based switches:

```typ
#import "@preview/vlna:0.4.1": apply-vlna, vlna-on, vlna-off, vlna-debug-on, vlna-debug-off
#show: apply-vlna

Tady se váže. #vlna-off() Tady ne. #vlna-on() A tady zase.
#vlna-debug-on() Orámuje zásahy odsud dál. #vlna-debug-off()
```

</details>

<details>
<summary><strong>Coming from luavlna</strong></summary>

| luavlna | vlna for Typst |
|---|---|
| `\singlechars{czech}{AIiVvOoUuSsZzKk}` | `short-words: (cs: "AIiVvOoUuSsZzKk")` |
| `\compoundinitials{czech}{Ch}` | `compound-initials: ("Ch",)` |
| `\preventsinglelang{czech}` | `lang: "cs"` |
| `\preventsingleoff` / `\preventsingleon` | `#vlna-off()` / `#vlna-on()` |
| `\preventsingledebugon` / `...off` | `#vlna-debug-on()` / `#vlna-debug-off()` (or `debug: true`) |

</details>

## Performance

Every match becomes a `#box`, so the package cannot be free, but it only pays
for what the document needs. Measured on a 63-page Czech document with every rule group
firing: typst 0.15.1, all series compiled in parallel, each pinned to
its own physical core (2 threads), at least 12 runs per series. Harness, chart and raw dataset are in
[`examples/benchmark`](https://github.com/iamanro/typst-vlna/tree/992e46835f26e2f89eb23ad018c110380f838dba/examples/benchmark).

<p align="center">
  <img alt="Compile time p95 on a 63-page document: bare 0.49 s, v0.1.1 1.22 s, v0.2.0 0.84 s, v0.3.0 2.12 s, v0.4.0 1.53 s, v0.4.1 1.54 s, v0.4.1 with legal 1.97 s, with one raw block v0.3.0 3.71 s, v0.4.0 4.06 s, v0.4.1 3.94 s" src="https://raw.githubusercontent.com/iamanro/typst-vlna/992e46835f26e2f89eb23ad018c110380f838dba/examples/benchmark/p95.png" width="860">
</p>

| | p95 | p50 | vs. bare document |
|---|---:|---:|---:|
| bare document, no package | 0.49 s | 0.47 s | 1.00× |
| v0.3.0 | 2.12 s | 2.01 s | 4.32× |
| v0.4.0 | 1.53 s | 1.43 s | 3.12× |
| **v0.4.1** | **1.54 s** | **1.43 s** | **3.15×** |
| v0.4.1 with `legal: true` | 1.97 s | 1.85 s | 4.01× |
| plus one `raw` block, v0.3.0 | 3.71 s | 3.39 s | 7.56× |
| plus one `raw` block, v0.4.0 | 4.06 s | 3.51 s | 8.30× |
| **plus one `raw` block, v0.4.1** | **3.94 s** | **3.48 s** | **8.04×** |

v0.4.1 compiles 27% faster than v0.3.0 at p95, matches v0.4.0 (the new citation abbreviations cost nothing measurable), and `legal: true` adds 0.42 s, 27% on top.

These figures come from the quick parallel harness (about a minute, 12–85
runs per series) and are not comparable to the 501-page serial figures of
earlier releases. The `raw` rows are the noisiest (up to 3 of 12 runs
stalled), so their ordering is within noise; the serial 0.4.0 measurement
(22.16 s → 20.30 s p50 on 501 pages, see [CHANGELOG.md](CHANGELOG.md)) remains
the reference for that comparison.

The `raw` rows are the price of two features. `#vlna-off()`, `#vlna-on()`,
`#vlna-debug-on()` and skipping `raw` all depend on *where* a match sits in
the document, which forces a state lookup at every match, and a single code
block anywhere is enough to require it. A document that uses neither takes
the cheap path automatically, with no configuration.

## How it works

A `show` rule that rebuilds text (`it.text.replace(" ", "~")`) produces
**new** content whose source position points at the rule itself, so
clicking a letter in the PDF jumps into the package code instead of your
document. vlna wraps the **original matched content** in `#box(..)`
instead. The box cannot break internally, and the glyphs keep their original
source span, so clicking them jumps to your document.

## Limitations

- Inside a box, spaces do not stretch under justification and words are not
  hyphenated, so a very long word right after a preposition can produce a
  looser line. A glued group wider than the line wraps at the column edge.
- Matches cannot cross styling boundaries: in `k *lesu*` the `k` is not
  bound, because the bold word is a separate element.
- Initials are a heuristic. A sentence ending with a bare capital
  (`… vitamin C. Nový výzkum`) looks like an initial and gets bound too; use
  `initials: false` if that bothers you.
- Text copied from a PDF may contain the invisible U+200B characters that
  `links` inserted, and jump-to-source is not preserved for the rewritten
  URL text (it is for everything else).

## Version history

| Feature | 0.1.1 | 0.2.0 | 0.3.0 | 0.4.0 | 0.4.1 |
|---|:-:|:-:|:-:|:-:|:-:|
| One- and two-letter words | via `~` | box, source-safe | configurable | yes | yes |
| Titles and abbreviations before a name | partial | yes | yes | yes | yes |
| Titles after a name (`Ph.D.`, `CSc.`) | – | yes | yes | yes | yes |
| Chaining of words and titles | – | yes | yes | yes | yes |
| Debug visualisation | – | yes | + mid-document toggle | yes | yes |
| Initials (`M. J. Hegel`), compound `Ch.` | – | – | yes | yes | yes |
| Per-language sets, `lang` forcing, on/off | – | – | yes | yes | yes |
| Digit groups, units, dates, ratios, phone numbers | no | no | yes | yes | yes |
| Number + counted noun (`500 lidí`, `strana 2`) | – | – | opt-in | opt-in | opt-in |
| Compound abbreviations (`a. s.`, `ČSN 01 6910`), dashes | – | – | yes | yes | yes |
| URL and e-mail break points (ÚJČ, via U+200B) | – | – | yes | yes | yes |
| Legal citations (`písm. a)`, `čl. 5`) | – | – | – | – | yes |
| Legal identifiers (`12 Nt 345/2026`, `s.r.o.`) | – | – | – | – | opt-in |
| Compile time, 63 pages (p50) | 1.17 s | 0.79 s | 2.01 s | 1.43 s | **1.43 s** |

Compile times are not like-for-like across versions: 0.1.1 and 0.2.0
implement fewer rules, so they have less work to do and still lose. Full
notes are in [CHANGELOG.md](CHANGELOG.md).

## Development

```sh
python3 tests/breaks.py   # line-break regression test (needs typst, pdftotext)
typst compile --root . examples/stress-test.typ   # every rule, with debug frames
```

`tests/breaks.py` sweeps the page width so that a line break lands in every
gap of each glued unit, and fails if a unit ever splits. The benchmark and
the typographic equivalence check against the previous release are described
in [`examples/benchmark`](https://github.com/iamanro/typst-vlna/tree/main/examples/benchmark).

## License

MIT, © 2025–2026 iamanro.
