# Changelog

## [0.4.0] – 2026-09-02

Performance release: identical typography, roughly a third off the compile
time. Verified on 24 configurations (every rule group, per-language sets,
links, `raw`, mid-document toggles, nested scopes, and columns from 12 mm to
120 mm) — every word lands on exactly the same spot as in 0.3.0, debug
frames included, and a 501-page document renders byte-identical text. No
public API change.

### Changed
- **One state instead of three.** Reading state is the single most expensive
  thing done per match, and there are tens of thousands of matches in a real
  document; `active`, `debug` and the `raw` suspend counter now live in one
  dictionary, so a match costs one lookup rather than three.
- **No state lookup at all when the document does not switch anything.**
  `#vlna-off()`, `#vlna-on()`, `#vlna-debug-on()`, `#vlna-debug-off()` and
  skipping `raw` are the only features that depend on *where* a match sits.
  `apply-vlna` now walks the document content before layout and, if it finds
  neither a toggle nor a `raw` element, glues without a `context` block at
  all. A document-level query stays as a safety net for `raw` created during
  layout (inside `context` or another package's `show` rule). Detection
  inspects the toggles' own state-update elements, so nothing extra is
  injected into the document and `query(metadata)` stays clean.
- `typst compile` on a 501-page all-rules-firing document, 25 interleaved
  runs pinned to 8 cores: **12.83 s → 8.66 s** at p50 and 12.98 s → 8.79 s
  at p95, i.e. −32%. At p50 that is 3.07× the bare document, down from
  4.55×, and the package's own overhead above it drops from 10.01 s to
  5.84 s (10.15 s → 5.95 s at p95). The same document plus one `raw` block,
  where the state lookups cannot be avoided: 22.16 s → 20.30 s at p50.
  Harness, chart and dataset in `examples/benchmark`.
- **Internals.** The three module-level states (`vlna:active`, `vlna:debug`,
  `vlna:suspend`) are replaced by one `vlna` state holding
  `(active, debug, suspend, switches)`. `switches` counts toggle calls, which
  is what lets the safety-net query notice a toggle even when it was switched
  off and on again. The four toggle functions share one `_switch` helper, so
  the two invariants they must keep (patch the field, count the switch) live
  in one place. `_needs-state` walks the content tree, rejecting `text` nodes
  before building their field dictionary — the walk costs about 0.2 s on 500
  pages, against the ~4 s it saves.

### Verified
- 24 configurations rendered with 0.3.0 and 0.4.0 and compared two ways:
  every word position from `pdftotext -bbox`, rounded to 1/1000 pt, must be
  identical, and the page rasters may differ only by antialiasing rounding.
  The set covers every rule group and switch, `short-words` as a letter
  string / word array / per-language dictionary, forced `lang`, empty and
  metacharacter-laden `units`, links in a 24 mm column, `raw` inline and as a
  block, `raw` produced during layout (inside `context` and inside another
  package's `show` rule), nested `apply-vlna` scopes, and measures of
  12, 16, 20, 24, 30 and 120 mm plus a 14 mm table cell.
- A 501-page document renders byte-identical extracted text (25 678 lines).
- `examples/stress-test.typ` renders pixel-identical, debug frames included.
- Reproduce the configuration set with `examples/benchmark/equivalence.py`;
  the 501-page and stress-test checks above were run by hand. The benchmark
  dataset is committed as `examples/benchmark/results.json`, and
  `examples/benchmark/chart.py` redraws `p95.svg` from it.

### Not changed (deliberately)
- The rule groups remain **seven separate `show` rules**. Merging them into
  one regex scans the text once and is measurably faster, but a single match
  cannot nest: separate rules wrap `1 000 000` in its own box *inside* the
  box around `o 1 000 000 Kč`, so when the outer box does not fit the
  measure, a narrow column still breaks only at its outer spaces. Merged, a
  16 mm column broke the number group as `1 000 | 000`. Correct typography
  wins over the extra speed.

## [0.3.0] – 2026-07-21

Implements the full ÚJČ line-breaking guideline
([prirucka.ujc.cas.cz/?id=880](https://prirucka.ujc.cas.cz/?id=880)) and the
luavlna command set — every rule group individually switchable.

### Added
- `bind-two-letter-words: false` — binds only one-letter words; two-letter
  words (`na`, `po`, `je`, `se`, …) may end a line. The strict Czech rule
  concerns one-letter prepositions/conjunctions; binding all two-letter words
  can noticeably worsen line breaking in narrow layouts.
- `short-words` — an explicit, case-sensitive set of words to bind, replacing
  the built-in short-word pattern. Accepts a string of single letters
  (`"vksuozVKSUOZAI"`) or an array of words (`("v", "k", "na", "Na")`).
  Takes precedence over `bind-two-letter-words`. Titles and abbreviations
  are bound regardless.
- **luavlna parity** (see the command mapping table in the README):
  - `short-words` also accepts a per-language dictionary
    (`(cs: "AIiVvOoUuSsZzKk", sk: …)`), resolved against `text.lang` —
    the equivalent of `\singlechars`. Languages not listed are left
    unprocessed, as in luavlna.
  - `lang: "cs"` forces one language's set for the whole document,
    ignoring `text.lang` — the equivalent of `\preventsinglelang`.
  - **Initials** (`M. J. Hegel`, `Ž. Zíbrt`) are bound to the following word
    and chain with titles (`Ing. B. Novák`). `initials: false` turns this
    off; `compound-initials: ("Ch",)` declares multi-letter initials — the
    equivalent of `\compoundinitials`.
  - Mid-document toggles `#vlna-off()` / `#vlna-on()` and
    `#vlna-debug-on()` / `#vlna-debug-off()` — the equivalents of
    `\preventsingleoff/on` and `\preventsingledebugon/off`.
- **ÚJČ rules** (prirucka.ujc.cas.cz/?id=880), each with its own toggle:
  - `numbers` + `units` — digit grouping (`2 500`, `25,325 23`, phone
    numbers `+420 800 123 987`), number + symbol (`50 %`, `§ 23`, `* 1921`,
    `† 2000`) and number + unit/abbreviation/currency (`10 kg`, `19 °C`,
    `5 str.`, `1 000 000 Kč`, `250 €`). The unit list is exported as
    `default-units` and can be replaced or extended.
  - `ratios` — scales, ratios and division (`1 : 50 000`, `10 : 2 = 5`).
  - `dates` + `months` — day and month hold together, the year may
    separate (`21. 6. | 2024`, `16. ledna | 1972`).
  - `number-word` (off by default — aggressive) — number + counted noun
    (`500 lidí`, `strana 2`, `5. pluk`, `II. patro`, `Karel IV.`).
  - `abbreviations` — compound abbreviations and codes (`a. s.`,
    `s. r. o.`, `př. n. l.`, `PS PČR`, `FF UK`, `ČSN 01 6910`).
  - `dashes` — a spaced dash stays at the end of a line (`slovo –`);
    an unspaced range dash does not break at all (`1948–1989`).
  - `links` — web/e-mail addresses in `link()` receive zero-width-space
    break opportunities at the spots ÚJČ recommends (after `/` but not
    inside `//`, before `.`, `-` and other special characters, around `@`).
    The link destination is untouched. Social-media handles (`@SenatCZ`)
    get no break after the `@`. Works also for bodies that parse as
    sequences (escaped characters like `\@`) or carry styling.
  - Initials also cover abbreviated given names (`Fr. Daneš`,
    `M. Těšitelová` — ÚJČ), and the before-name list gained `kap.`, `obr.`,
    `odst.`, `tab.` (`obr. 1`, `tab. 3`).
- **Raw/code blocks are excluded** — code is not Czech running text, so no
  rule glues anything inside `raw` (inline or block).
- `examples/stress-test.typ` — a torture sheet covering every rule, edge
  cases (Unicode, chained runs, narrow columns, URL breaking) and
  degenerate configurations.
  - The short-word run's target understands the numeric rules, so
    `o 2 500 Kč`, `od 21. 6.`, `i s. r. o.` or `zápas o 5 : 3` are glued
    as one block instead of the preposition stealing the first token.

## [0.2.0] – 2026

Major rewrite of the core.

### Fixed
- **Jump-to-source preserved.** Feature #1 no longer rebuilds text with
  `it.text.replace(" ", "~")` (which moved the source position of the affected
  glyphs to the package). Both short words and titles now wrap the **original**
  matched content in `#box(..)`, so clicking a glyph in the PDF jumps back to
  the document, not to the package code.
- Title alternation is ordered **longest-first**, so multi-word titles match
  correctly (`Ing. arch.`, `dr. h. c.`, `pplk. gšt.` no longer lose to their
  shorter prefixes).
- Typo `plk` → `plk.` in the list of titles.
- Non-period abbreviations get a trailing word boundary, so `viz` no longer
  matches inside `vize` and `PhD` no longer matches the start of `PhDr.`.

### Added
- **Titles after a name** (`Ph.D.`, `PhD.`, `Th.D.`, `CSc.`, `DrSc.`, `DSc.`,
  `DiS.`, `MBA`, `LL.M.`, `MSc.`) are bound to the preceding word.
- **Chaining** of short words and titles into a single non-breaking run
  (`k s bratrem`, `plk. gšt. doc. Mgr. et Mgr. Ing. Libor Kutěj`) — a unified
  prefix run prevents adjacent rules from competing for the boundary word
  (e.g. `za tzv. postup`).
- **Two-letter words** with a lowercase second letter (`na`, `po`, `je`, `se`,
  …) in addition to single letters.
- `debug: true` mode that outlines every glued block.

### Changed
- Public API is unchanged: `#show: apply-vlna` still works. `apply-vlna` now
  also accepts `debug: false`.

## [0.1.1] – 2025-04-30
- Short-word regex narrowed to `(\<\p{Lowercase}{1,2}\>)+ `.
- Experimental list of titles/abbreviations before a name.

## [0.1.0] – 2025-03-03
- Initial non-breaking spaces after short prepositions/conjunctions.
