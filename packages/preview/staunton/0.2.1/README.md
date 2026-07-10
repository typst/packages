# staunton

A **chess publishing** toolkit for [Typst](https://typst.app): render boards and
pieces, build diagrams from **FEN** or **PGN** (with a pure-Typst legal-move
engine), write localized move **notation**, and generate **tournament tables** —
all as referenceable `#figure`s, with ready-made **outlines** (lists of diagrams
and tables).

![Gallery of staunton output: chess boards and diagrams, localized move notation, and tournament tables](https://raw.githubusercontent.com/ndg6/staunton/v0.2.1/docs/img/gallery.png)

## Features

- **Boards & diagrams** from a FEN string, a `position(..)` object, or a manual
  squares dict — captioned `#figure`s with automatic game-info lines.
- **Styling**: themes, six label placements, flip, piece sets, grid, square
  **highlights** (filled / cross / circle) and **arrows**; size-adaptive layout.
- **Move markings**: an in-check glow and move-quality badges (`!`, `?`, `!!`, …)
  on diagrams.
- **Bring-your-own & fairy pieces**: render any downloaded set through a
  `piece-set` loader (`named-piece-set` / `svg-piece-set`), and add non-standard
  kinds and whole variants (`define-variant`, `with-fallback`) for mixed boards.
- **PGN**: parse multi-game files, navigate the mainline and (nested) variations
  by locator, play "what-if" lines, export FEN. Lazy parsing stays fast on large
  files.
- **Chess960 / Fischer Random**: the same board, engine, PGN pipeline and notation
  handle 960 — X-FEN castling, the FRC PGN tags (`Variant` / `SetUp` / `FEN` /
  `FRCPosition`), and start positions by Scharnagl number.
- **Notation**: numbered movetext with **variations** (inline or indented),
  figurine glyphs, NAGs, comments, embedded diagrams, and **localized piece
  letters**.
- **Annotate & build**: add NAGs, comments and (nested) **variations** to a game
  programmatically — without touching the PGN — then render it like any parsed one.
- **Tournament tables**: standings, cross-tables, and progress (player or team),
  with Buchholz / Sonneborn-Berger tie-breaks.
- **Internationalization**: one document language drives supplements, outline
  titles, and notation (en, de, es, fr, it, pt, ru; per-call overridable).
- **References & outlines**: diagrams and tables are figures with distinct kinds,
  so `@label` and dedicated "list of diagrams / tables" outlines just work.
- **HTML export (limited)**: notation, tables, outlines, references and captioned
  figures export to native HTML; boards and diagrams embed as inline SVG. Typst's
  own HTML export is still experimental, so parity with PDF is partial.

## Quick start

```typ
#import "@preview/staunton:0.2.1": chess-diagram, position, starting-fen
```

From a FEN string (this one is 1.e4 c5 2.Nf3):

```typ
#chess-diagram("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")
```

![A chess diagram of the position after 1.e4 c5 2.Nf3, with a "Position at move 2, Black to play" caption](https://raw.githubusercontent.com/ndg6/staunton/v0.2.1/docs/img/quickstart-1.png)

The starting position, with PGN-style metadata for the caption:

```typ
#chess-diagram(starting-fen, white: [Carlsen], black: [Nepo], event: [Dubai], year: 2021)
```

![The starting position with a bold "Carlsen – Nepo (2021)" info line above and a "Position at move 1, White to play" caption](https://raw.githubusercontent.com/ndg6/staunton/v0.2.1/docs/img/quickstart-2.png)

Manual placement: a squares dict (square → piece). Square-name case is ignored;
pieces may be long names, abbreviations, or bare letters.

```typ
#chess-diagram(position((
  e1: (kind: "king", color: "white"),
  e8: (kind: "king", color: "black"),
  e4: "P",                                // bare letter: upper = white pawn
)), labels: false)
```

![A near-empty board with the two kings on e1 and e8 and a white pawn on e4, labels off and no caption](https://raw.githubusercontent.com/ndg6/staunton/v0.2.1/docs/img/quickstart-3.png)

And from a game:

```typ
#import "@preview/staunton:0.2.1": parse-pgn, diagram-after, mainline

#let game = parse-pgn(```
[White "Morphy"] [Black "NN"] [Result "1-0"]
1. e4 e5 2. Nf3 d6 3. d4 *
```).first()

#diagram-after(game, "3w")   // a diagram of the position after White's 3rd move
```

![A chess diagram of the position after 3.d4 in a Morphy game, with a "Morphy – NN" info line and a "Position after move 3. d4" caption](https://raw.githubusercontent.com/ndg6/staunton/v0.2.1/docs/img/quickstart-4.png)

## Documentation

- **User manual** — the complete reference (every function, option, and example),
  with each feature shown as the code you type beside the board it produces.
  Download the compiled **[PDF](https://github.com/ndg6/staunton/releases/download/v0.2.1/manual.pdf)** (attached to each release), or build it yourself
  from its Typst source, [`docs/manual.typ`](https://github.com/ndg6/staunton/blob/v0.2.1/docs/manual.typ). The manual is part
  of the repo only — it is not shipped in the package bundle.
- **[Showcase](https://github.com/ndg6/staunton/blob/v0.2.1/docs/examples/showcase.typ)** — a runnable capability tour.

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
the [manual](https://github.com/ndg6/staunton/blob/v0.2.1/docs/manual.typ).
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

### 0.2.1 (unreleased)

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
