# staunton

**Publish chess with [Typst](https://typst.app).** staunton goes beyond 
board drawings and turns games and positions into publication-quality
**diagrams**, **move notation**, and **tournament tables** — all referenceable `#figure`s.
A move generator in pure Typst reads **FEN** and **PGN**, and everything is
localized to seven languages.

## A game, published

Install the package, parse a PGN, and drop a captioned diagram of any position —
the players, the year, and the move just played are filled in automatically:

```typ
#import "@preview/staunton:0.2.2": parse-pgn, diagram-after, chess-notation, standings-table

#let opera = parse-pgn(```
[White "Morphy"] [Black "Allies"] [Date "1858"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 4. dxe5 Bxf3 5. Qxf3 dxe5 6. Bc4 Nf6 7. Qb3 Qe7
8. Nc3 c6 9. Bg5 b5 10. Nxb5 cxb5 11. Bxb5+ Nbd7 12. O-O-O Rd8 13. Rxd7 Rxd7
14. Rd1 Qe6 15. Bxd7+ Nxd7 16. Qb8+ Nxb8 17. Rd8# 1-0
```).first()

// The final position: roster → info line, last move → caption, check → king glow.
#diagram-after(opera, "17w", check: true)
```

![Morphy – Allies (1858): the final mate, the black king glowing, captioned "Position after 17. Rd8#"](https://raw.githubusercontent.com/ndg6/staunton/v0.2.2/docs/img/showcase-diagram.png)

## Move notation

Numbered movetext with figurine glyphs, inline **variations**, NAGs and comments,
localized to the document language — output no board-only package produces:

```typ
#let g = parse-pgn("1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 (5... Nxe4!? 6. d4 b5) 6. Re1 b5 7. Bb3 d6 *").first()

#chess-notation(g, figurine: true, variations: true, nags: true)
```

![Figurine Ruy Lopez notation with an inline variation and a “!?” annotation](https://raw.githubusercontent.com/ndg6/staunton/v0.2.2/docs/img/showcase-notation.png)

## Tournament tables

Standings, cross-tables and progress tables straight from the games' result tags,
with Buchholz / Sonneborn-Berger tie-breaks:

```typ
#let games = parse-pgn(```
[White "Carlsen"][Black "Nakamura"][Result "1-0"][Round "1"] 1-0
[White "Caruana"][Black "Nepomniachtchi"][Result "1/2-1/2"][Round "1"] 1/2-1/2
[White "Carlsen"][Black "Caruana"][Result "1/2-1/2"][Round "2"] 1/2-1/2
[White "Nepomniachtchi"][Black "Nakamura"][Result "1-0"][Round "2"] 1-0
[White "Carlsen"][Black "Nepomniachtchi"][Result "1-0"][Round "3"] 1-0
[White "Nakamura"][Black "Caruana"][Result "0-1"][Round "3"] 0-1
```)

#standings-table(games, caption: [Final standings])
```

![A final-standings table: rank, player, played, +/=/−, points, Buchholz and Sonneborn-Berger tie-breaks](https://raw.githubusercontent.com/ndg6/staunton/v0.2.2/docs/img/showcase-table.png)

## Annotated diagrams

`%cal` / `%csl` drawing commands in a move's comment become arrows and highlights,
and a `!` / `?` grade becomes a move-quality badge — composited onto the board:

```typ
#let g = parse-pgn("1. e4 e5 2. Nf3! {[%cal Gf3e5,Rf1c4][%csl Ge5]} Nc6 *").first()

#diagram-after(g, "2w", annotations: true, move-quality: true)
```

![Board after 2.Nf3 with a green and a red arrow, a highlighted square, and a blue “!” badge](https://raw.githubusercontent.com/ndg6/staunton/v0.2.2/docs/img/showcase-annotations.png)

## …and the basics

A **bare `board`** for an inline or decorative position; a **`chess-diagram`**
whenever you want it captioned, counted, `@`-referenceable and listed by an
outline. Sources are the same everywhere — a FEN string, a `position(..)` object,
or a squares dict:

```typ
#chess-diagram("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")
```

![A chess diagram of the position after 1.e4 c5 2.Nf3, captioned "Black to move"](https://raw.githubusercontent.com/ndg6/staunton/v0.2.2/docs/img/quickstart-1.png)

## Features

- **PGN engine** — parse multi-game files, navigate the mainline and (nested)
  **variations** by locator, play "what-if" lines, and export FEN, all on a
  pure-Typst legal-move engine (lazy parsing stays fast on large files).
- **Notation** — numbered movetext, inline/indented variations, figurine glyphs,
  NAGs, comments, and diagrams **embedded at markers**; localized piece letters.
- **Tournament tables** — standings, cross-tables and progress (player or team),
  with Buchholz / Sonneborn-Berger tie-breaks.
- **Annotations & markings** — `%cal` / `%csl` arrows and highlights from PGN, an
  in-check glow, and move-quality badges; add NAGs / comments / variations to a
  game programmatically, then render it like any parsed one.
- **Styling** — themes, six label placements, flip, piece sets, grid; proportional
  highlights (filled / cross / circle) and arrows; size-adaptive layout.
- **Bring-your-own & fairy pieces** — any downloaded set via a `piece-set` loader
  (`named-piece-set` / `svg-piece-set`), plus non-standard kinds and whole variants
  (`define-variant`, `with-fallback`).
- **Chess960 / Fischer Random** — board, engine, PGN pipeline and notation all
  handle 960 (X-FEN castling, the FRC PGN tags, Scharnagl start numbers).
- **Publishing niceties** — everything is a `#figure`: `@label` cross-references,
  dedicated **outlines** (lists of diagrams / tables), localization (en, de, es,
  fr, it, pt, ru), and limited **HTML export**.

## Documentation

- **User manual** — the complete reference (every function, option, and example),
  with each feature shown as the code you type beside the board it produces.
  Download the compiled **[PDF](https://github.com/ndg6/staunton/releases/download/v0.2.2/manual.pdf)** (attached to each release), or build it yourself
  from its Typst source, [`docs/manual.typ`](https://github.com/ndg6/staunton/blob/v0.2.2/docs/manual.typ). The manual is part
  of the repo only — it is not shipped in the package bundle.
- **[Showcase](https://github.com/ndg6/staunton/blob/v0.2.2/docs/examples/showcase.typ)** — a runnable capability tour.

Compile the manual and the showcase locally with the package folder as root:

```sh
typst compile --root . docs/manual.typ docs/manual.pdf
typst compile --root . docs/examples/showcase.typ showcase.pdf
```

### API at a glance

| area | entry points |
|---|---|
| diagrams | `chess-diagram`, `diagram`, `board`, `chess-board`, `chess960-board`, `chess960-diagram` |
| positions | `position`, `parse-fen`, `to-fen`, `starting-fen`, `chess960-start`, `chess960-start-fen` |
| games (PGN) | `parse-pgn`, `movetext`, `mainline`, `diagram-after`, `position-after`, `chess-moves`, `game-start`, `game-variant` |
| annotate / build | `with-nags`, `with-comments`, `with-variation` |
| notation | `chess-notation`, `notation` |
| tables | `standings-table`, `crosstable-table`, `progress-table`, `games-by-event` (+ compute: `standings`, `crosstable`, `progress`) |
| outlines | `chess-diagram-outline`, `chess-table-outline`, `chess-outlines` |
| defaults | `set-chess-defaults`, `set-board-defaults`, `set-diagram-defaults`, `set-table-defaults`, `set-pgn-defaults`, `set-lang`, `set-piece-set` |

## Pieces & licensing

The **code** (`lib.typ`, `src/**/*.typ`) is **MIT**. The bundled **piece SVGs**
are **GPLv2+** — two sets ship: `cburnett` (default, © Colin M.L. Burnett) and
`merida` (© Armando Hernandez Marroquin), from the
[lichess](https://github.com/lichess-org/lila) collection. See [LICENSE](LICENSE)
and [LICENSE-PIECES](LICENSE-PIECES). The package manifest declares
`MIT AND GPL-2.0-or-later`.

A `"unicode"` glyph fallback needs no SVGs. To use other art, pass `piece-set` a
loader (`named-piece-set` / `svg-piece-set`, or `with-fallback` for mixed and
fairy boards) — see the *Pieces and fonts* and *Non-standard pieces* sections of
the [manual](https://github.com/ndg6/staunton/blob/v0.2.2/docs/manual.typ).
(Other popular lichess sets carry non-commercial licenses and are not bundled.)
The manual and tests also embed **CC BY-SA 4.0** fairy demo art (under `docs/` and
`tests/`), which is *not* part of the shipped package — see [LICENSE-PIECES](LICENSE-PIECES).

## Repository layout

```
typst.toml          package manifest          LICENSE / LICENSE-PIECES  MIT / GPLv2+
lib.typ             public API + figure wrapper
src/                engine, FEN/PGN/SAN, notation, tournament, board renderer, i18n
src/assets/         piece-set SVGs (cburnett, merida) + i18n language files
docs/manual.typ     user manual (-> PDF)      docs/examples/  runnable showcase
tests/              test suite (bash tests/run.sh)   scripts/  release bundle build
```

## Tests

```sh
bash tests/run.sh        # compiles pass-cases; asserts fail-cases error as expected
```

The runner walks every `.typ` under `tests/`; a file with a `// EXPECT: <substr>`
header must error with that message, any other must compile. Files/dirs prefixed
`_` (shared fixtures) are skipped; `docs/examples/*.typ` are compiled too.

## Roadmap

- **Tournament tables**: read results from non-PGN sources, and richer styling
  options for the standings / cross / progress tables.
- A **move→SAN encoder** — name an engine-generated move (`legal-moves` / `apply`)
  from a bare position; the inverse of the SAN parser, so movetext can be produced
  without a pre-existing PGN (puzzle solutions, generated lines, legal-move lists).
- Engine **performance** (the narrow `legal-moves` / `apply` seam can swap to WASM).
- More **chess variants**: non-western variants (e.g. xiangqi) are a more distant
  goal (0.5.0); the `position` / `board` pipeline is already variant-aware.

## Changelog

<!-- RELEASE NOTE (not user-facing): the top changelog section is the version
     currently in development. Keep its heading version-only (e.g. "### 0.2.2") —
     never add "(unreleased)" or similar to user-visible text. -->

### 0.2.2

- **Proportional markers**: cross / circle / arrow strokes — and the new
  `cross-margin` / `circle-margin` — scale with the square by default (stroke 15%,
  cross tip 10% from the corners, circle margin 3%), so marks read the same at any
  board size. Default arrows are also more opaque now (35% transparency, was 85%),
  so they no longer look faint.
  Each is settable per call or document-wide, as a ratio or an absolute length.
- **Notation spacing**: move numbers render spaced by default ("1. e4 e5 2. Nf3";
  a forced Black move as "24... Nf6"). A new `spaced` option (document-settable via
  `set-pgn-defaults`) opts back into the dense "1.e4" / "24...Nf6" form.
- **Uniform captions**: automatic below-captions are consistent — a `diagram-after`
  reads "Position after 24. Nf3", and a FEN `chess-diagram` reads "White to move" /
  "Black to move" (localized).

### 0.2.1

- **i18n**: automatic diagram captions ("Position after move …" / "Position at
  move N, X to play") and tournament-table column headers are now localized —
  previously they stayed English regardless of `set-lang`. The chess language
  (`set-lang`) is independent of the document language (`#set text(lang: ..)`),
  and `set-lang("auto")` follows the document language for these too.
- **docs**: the README Quick-Start examples now show their rendered output.

### 0.2.0

- **Chess960 / Fischer Random**: variant-named `chess960-board` / `chess960-diagram`;
  start positions by Scharnagl number (`chess960-start`, `chess960-start-fen`, 0–959,
  518 = standard); X-FEN castling in `parse-fen` / `to-fen`; PGN recognition of
  `[Variant]`, `[SetUp]`, `[FEN]` and `[FRCPosition]` / `[Chess960Position]`
  (`game-variant`, `game-start`). The engine's castling is generalised, so 960
  shares the standard move generator.
- **Bring-your-own piece art**: `piece-set` accepts a loader `(color, kind) → bytes`
  (or a bytes dict), so any downloaded or custom set renders. Helpers build one:
  `named-piece-set` (filename pattern), `svg-piece-set` (lichess layout), and
  `with-fallback` (custom pieces over a standard base). Reads live in your
  document, so it works from an installed package (Typst's file sandbox).
- **Non-standard / fairy pieces**: define custom piece kinds and whole variants
  with `define-variant`; the squares-dict and string-form parsers understand the
  new letters, with a Unicode-glyph fallback for kinds you have no art for.
- **Move markings**: an in-check glow (`check: true`, auto-locates the king) and a
  move-quality badge (`move-quality: true` on `diagram-after`; the `!` `?` `!!`
  `??` `!?` `?!` codes).
- **Outlines**: caption-less diagrams and tables are no longer listed (they stay
  referenceable but leave no blank outline row), and `title: none` fully drops an
  outline title.
- **Changed**: `position.castling` is now the castling rook's *file index* (or
  `none`) per side, not a boolean — breaking if you read that field directly.
  `to-fen` now emits X-FEN castling when `KQkq` is ambiguous and writes en-passant
  targets strictly (only when a capture is available); standard positions are
  otherwise unchanged and still round-trip exactly.
- **Changed**: `set-board-defaults` / `set-chess-defaults` now reject the
  position-specific options `highlight`, `arrows` and `move-quality-mark` as
  document-wide defaults (they apply per call, or via `diagram-after` for the
  badge); their *styling* options stay settable document-wide.

### 0.1.0

Initial release.

- Boards and diagrams from a FEN string, a `position(..)` object, or a squares
  dict; themes, six label placements, flip, piece sets, grid, highlights, arrows.
- Pure-Typst legal-move engine; PGN parsing with mainline and nested variations,
  locator navigation, "what-if" play, and FEN export.
- Localized move notation with variations, figurine glyphs, NAGs, comments, and
  embedded diagrams; programmatic NAG / comment / variation builders.
- Tournament tables (standings, cross-tables, progress; player or team) with
  Buchholz / Sonneborn-Berger tie-breaks.
- Figure-based references and diagram / table outlines; document-wide defaults
  and localization (en, de, es, fr, it, pt, ru).
- Limited HTML export (notation, tables, outlines and references as native HTML;
  boards and diagrams as inline SVG).

## Acknowledgements

- The [boards-n-pieces](https://typst.app/universe/package/boards-n-pieces) Typst
  package was an inspiration for some features.
- Developed with assistance from Claude (Opus 4.8) by Anthropic.

## License

Code: **MIT** (© 2026 Frank Lippert). Bundled piece images: **GPL-2.0-or-later**.
See [LICENSE](LICENSE) and [LICENSE-PIECES](LICENSE-PIECES).
