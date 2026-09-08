# staunton

**Publish chess with [Typst](https://typst.app).** staunton goes beyond 
board drawings and turns games and positions into publication-quality
**diagrams**, **move notation**, and **tournament tables** — all as referenceable `#figure`s.
A move generator in pure Typst reads **FEN** and **PGN**, and everything is
localized to seven languages.

Requires **Typst 0.14.2+** with HTML export as the only exception — it builds on
compiler features added in 0.15, so it needs **0.15+** whereas paged output (PDF, PNG,
SVG) and every other feature work already on 0.14.2.

## A game, published-

Install the package, parse a PGN, and drop a captioned diagram of any position —
the players, the year, and the move just played are filled in automatically:

```typ
#import "@preview/staunton:2.0.0": game, diagram, notation, standings-table

#let opera = game(```
[White "Morphy"] [Black "Allies"] [Date "1858"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 4. dxe5 Bxf3 5. Qxf3 dxe5 6. Bc4 Nf6 7. Qb3 Qe7
8. Nc3 c6 9. Bg5 b5 10. Nxb5 cxb5 11. Bxb5+ Nbd7 12. O-O-O Rd8 13. Rxd7 Rxd7
14. Rd1 Qe6 15. Bxd7+ Nxd7 16. Qb8+ Nxb8 17. Rd8# 1-0
```)

// The final position: roster → info line, last move → caption, check → king glow.
#diagram(opera, at: "17w", check: true)
```

![Morphy – Allies (1858): the final mate, the black king glowing, captioned "Position after 17. Rd8#"](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/showcase-diagram.png)

## Move notation

Numbered movetext with figurine glyphs, inline **variations**, NAGs and comments,
localized to the document language — output no board-only package produces:

```typ
#let g = game("1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 (5... Nxe4!? 6. d4 b5) 6. Re1 b5 7. Bb3 d6 *")

#notation(g, figurine: true, variations: true, nags: true)
```

![Figurine Ruy Lopez notation with an inline variation and a “!?” annotation](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/showcase-notation.png)

## Tournament tables

Standings, cross-tables and progress tables straight from the games' result tags,
with Buchholz / Sonneborn-Berger tie-breaks:

```typ
#let gs = games(```
[White "Carlsen"][Black "Nakamura"][Result "1-0"][Round "1"] 1-0
[White "Caruana"][Black "Nepomniachtchi"][Result "1/2-1/2"][Round "1"] 1/2-1/2
[White "Carlsen"][Black "Caruana"][Result "1/2-1/2"][Round "2"] 1/2-1/2
[White "Nepomniachtchi"][Black "Nakamura"][Result "1-0"][Round "2"] 1-0
[White "Carlsen"][Black "Nepomniachtchi"][Result "1-0"][Round "3"] 1-0
[White "Nakamura"][Black "Caruana"][Result "0-1"][Round "3"] 0-1
```)

#standings-table(gs, caption: [Final standings])
```

![A final-standings table: rank, player, played, +/=/−, points, Buchholz and Sonneborn-Berger tie-breaks](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/showcase-table.png)

## Annotated diagrams

`%cal` / `%csl` drawing commands in a move's comment become arrows and highlights,
and a `!` / `?` grade becomes a move-quality badge — composited onto the board:

```typ
#let g = game("1. e4 e5 2. Nf3! {[%cal Gf3e5,Rf1c4][%csl Ge5]} Nc6 *")

#diagram(g, at: "2w", annotations: true, move-quality: true)
```

![Board after 2.Nf3 with a green and a red arrow, a highlighted square, and a blue “!” badge](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/showcase-annotations.png)

## Themed boards

Reusable `color-theme` / `board-theme` values — eleven built-ins each — cover
everything from a flat two-color pairing to a full "look": square patterns
(stripes, marble, wood) and a matching material band around the board:

```typ
#board(
  "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
  label-mode: "border",
  border-theme: "marble",
  color-theme: color-theme(base: "coral", pattern: "marble", brightness: -15%, contrast: 30%),
)
```

![A board with a marble-veined border band and marbled squares, the "coral" theme darkened and sharpened](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/showcase-marble.png)

The same machinery in wood — the grain runs across **both** square colors, so the
board reads as *inlaid* light and dark timber (set `pattern-light: false` for the
dark-squares-only look). The textures are monochrome by design: they carry light
and shadow only, so the hue always comes from your `color-theme`:

```typ
#board(
  "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
  label-mode: "border",
  border-theme: "wood",
  color-theme: color-theme(base: "wikipedia", pattern: "wood"),
)
```

![A board of inlaid light and dark timber with flowing grain on every square, framed by a matching wood band](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/showcase-wood.png)

## …and the basics

A **bare `board`** for an inline or decorative position; **`diagram`**
whenever you want it captioned, counted, `@`-referenceable and listed by an
outline. Sources are the same everywhere — a FEN string, a `position(..)` object,
or a squares dict:

```typ
#diagram("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")
```

![A chess diagram of the position after 1.e4 c5 2.Nf3, captioned "Black to move"](https://raw.githubusercontent.com/ndg6/staunton/v2.0.0/docs/img/quickstart-1.png)

## Features

- **PGN engine** — parse multi-game files, navigate the mainline and (nested)
  **variations** by locator, play "what-if" lines, and export FEN, all on a
  pure-Typst legal-move engine (lazy parsing stays fast on large files). Reads
  movetext written with **Unicode figurines** or **localized piece letters**, so
  games copied straight out of Informator-style and non-English sources.
- **Notation** — numbered movetext, inline/indented variations, figurine glyphs,
  NAGs, comments, and diagrams **embedded at markers**; localized piece letters.
- **Tournament tables** — standings, cross-tables and progress (player or team),
  with Buchholz / Sonneborn-Berger tie-breaks, and a curated set of styling
  options (rule presets, header / body fills including zebra rows, alignment,
  winner highlighting) settable per call or document-wide.
- **Annotations & markings** — `%cal` / `%csl` arrows and highlights from PGN, an
  in-check glow, move-quality badges, and an optional **last-move** marking
  (arrow or squares); add NAGs / comments / variations to a game
  programmatically, then render it like any parsed one. Every automatic marking
  comes from the game you pass, so a bare position is never marked.
- **Styling** — reusable `color-theme` / `board-theme` values (11 built-ins each,
  derivable from one another), brightness / contrast adjustment, square patterns
  (stripes, marble, wood), seven `"border"`-mode band looks including "wood" and
  "marble" material patterns, six label placements, flip, piece sets, grid;
  proportional highlights (filled / cross / circle / frame); arrows with a
  barbed or triangular tip and an optional fade along the shaft;
  size-adaptive layout.
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
  Download the compiled **[PDF](https://github.com/ndg6/staunton/releases/download/v2.0.0/manual.pdf)** (attached to each release), or build it yourself
  from its Typst source, [`docs/manual.typ`](https://github.com/ndg6/staunton/blob/v2.0.0/docs/manual.typ). The manual is part
  of the repo only — it is not shipped in the package bundle.
- **[Showcase](https://github.com/ndg6/staunton/blob/v2.0.0/docs/examples/showcase.typ)** — a runnable capability tour.

Compile the manual and the showcase locally with the package folder as root
(the manual's own styling uses a 0.15 builtin, so *building* it needs Typst
0.15+ even though *using* the package does not):

```sh
typst compile --root . docs/manual.typ docs/manual.pdf
typst compile --root . docs/examples/showcase.typ showcase.pdf
```

### API at a glance

| area | entry points |
|---|---|
| diagrams | `diagram`, `board` |
| positions | `position`, `play`, `to-fen`, `starting-fen`, `chess960-start-fen` |
| games (PGN) | `game`, `games`, `movetext`, `mainline`, `move-at`, `game-start`, `game-result`, `game-variant` |
| annotate / build | `with-nags`, `with-comments`, `with-line` |
| notation | `notation` |
| tables | `standings-table`, `crosstable-table`, `progress-table`, `games-by-event` (+ compute: `standings`, `crosstable`, `progress`) |
| outlines | `diagram-outline`, `table-outline`, `outlines` |
| themes | `color-theme`, `board-theme` |
| pieces & variants | `define-variant`, `named-piece-set`, `svg-piece-set`, `with-fallback`, `piece-content`, `parse-square`, `is-dark-square` |
| engine | `legal-moves`, `apply`, `in-check`, `move-to-san` |
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
the [manual](https://github.com/ndg6/staunton/blob/v2.0.0/docs/manual.typ).
(Other popular lichess sets carry non-commercial licenses and are not bundled.)
The manual and tests also embed **CC BY-SA 4.0** fairy demo art (under `docs/` and
`tests/`), which is *not* part of the shipped package — see [LICENSE-PIECES](LICENSE-PIECES).

## Repository layout

```
typst.toml          package manifest          LICENSE / LICENSE-PIECES  MIT / GPLv2+
lib.typ             public API + figure wrapper
src/                engine, FEN/PGN/SAN, notation, tournament, board renderer, i18n
src/assets/         piece-set SVGs (cburnett, merida), square/band pattern SVGs, i18n files
docs/manual.typ     user manual (-> PDF)      docs/examples/  runnable showcase
tests/              test suite (bash tests/run.sh)   scripts/  release bundle build
```

## Tests

```sh
bash tests/run.sh        # compiles pass-cases; asserts fail-cases error as expected
bash tests/run.sh -j1    # force serial (default: one worker per CPU)
bash tests/run.sh --system-fonts   # real fonts (slower) — the release gate
```

Test files are independent compiles, so the runner dispatches them across one
worker per CPU and skips the system-font scan by default (`--ignore-system-fonts`)
— together a multiple-times-faster suite. Fonts affect only rendered glyphs, never
pass/fail, so the release gate re-runs with `--system-fonts` for the visual eyeball.

The runner walks every `.typ` under `tests/`; a file with a `// EXPECT: <substr>`
header must error with that message, any other must compile. Files/dirs prefixed
`_` (shared fixtures) are skipped; `docs/examples/*.typ` are compiled too.

## Changelog

<!-- RELEASE NOTE (not user-facing): the top changelog section is the version
     currently in development. Keep its heading version-only (e.g. "### 0.3.0") —
     never add "(unreleased)" or similar to user-visible text.
     This applies to the IN-DEVELOPMENT heading only. A past entry may carry a
     factual distribution qualifier — see "### 1.1.0 — GitHub release only",
     which records that it never went to Universe. Do not strip that. -->

### 2.0.0

**Breaking.** 2.0.0 is a large-scale redesigns of the game / PGN surface around
two rules: 
- there is **one** way to do each thing, and 
- a move is something you *pass*, not something smuggled inside a value. Every rename
  below is a hard break — no aliases were kept.

- **Parsing**: `parse-pgn(x)` becomes **`games(x)`**, or **`game(x)`** when you
  expect exactly one (it errors if the input holds more). `parse-fen(x)` becomes
  **`position(x)`**, which auto-detects a FEN. `chess960-start(n)` becomes
  `position(chess960-start-fen(n))`.
- **Drawing a move**: `diagram-after(g, "17w")` becomes
  **`diagram(g, at: "17w")`**, and `board` accepts the same pair. Previously a
  position carried a hidden payload describing the move that produced it; it no
  longer does, so positions are uniform whatever built them. The consequence is
  the point of the release: the move-quality badge and `%cal` / `%csl`
  annotations are available **only** when you hand over the game together with
  `at:`. A bare position — from a FEN, a squares dict, or `apply` — has no move
  behind it and is never badged or annotated.
- **`position-after` is now internal.** It returned a bare position, silently
  discarding the move, which made `diagram(position-after(g, L))` quietly lose
  its badge and annotations. Pass the game with `at:` instead.
- **One positional argument, then named ones.** The shape of nearly every
  function is now `f(subject, setting: .., ..)` — the thing being acted on is
  positional, everything that configures the action is named. The transitional
  positional locator / payload forms are gone: `to-fen(source, at: ..)`,
  `play(source, moves: ..)`, `with-nags(game, nags: ..)`,
  `with-comments(game, comments: ..)`. Calls no longer depend on argument
  order, and adding an option can never shift the meaning of an existing one.

  The deliberate exceptions are the places where there is no single subject:
  `apply(position, move)`, `in-check(position, color)` and
  `move-to-san(position, move)` take two co-equal operands of one operation
  rather than a subject plus a setting; `is-dark-square(col, row)` and
  `piece-content(kind, color, size)` likewise take an inseparable tuple; and
  `position(..)` stays variadic so a board can be written as one row string
  per line.
- **One move accessor**: `move-san` and `move-node` are removed in favour of
  **`move-at(game, at: ..)`**, which returns the whole record — SAN, NAGs,
  comments, variations, and the resolved `from` / `to` / `piece` / `capture` /
  `promotion`.
- **Engine moves carry square names**: `legal-moves(pos).first()` is now
  `(from: "g1", to: "f3", ..)` rather than `(col, row)` tuples. `apply` and
  `move-to-san` speak the same shape.
- **`with-variation` becomes `with-line`**, and it now does two jobs:
  `with-line(g, at: "3w", moves: ..)` branches a variation as before, while
  `with-line(g, moves: ..)` *continues* the mainline — playing out a mate the
  source game stopped short of, which previously had no API at all.
- **Locators** honour a game's own starting move number (a game beginning at
  move 24 is addressed `"24w"`, not `"1w"`), and `into` is optional in a path
  hop, defaulting to the first variation.
- **Multi-game text**: a result token (`1-0`, `0-1`, `1/2-1/2`, `*`) now ends a
  game, so files without a tag roster between games split correctly. Movetext
  whose move numbers go backwards is rejected rather than silently merged.
- **Removed, having been public by accident**: `chess-style`, `style-keys`,
  `default-style`, `style-state` — re-exported but documented nowhere.

New in the same release:

- **Arrow styling.** `arrow-tip` can appear as `"triangle"` or `"hook"`, a barbed head
  whose wings sweep back to points; **`"hook"` is the new default**, so existing
  arrows change appearance. `arrow-fade` fades a shaft toward its tail to a
  given opacity, relative to the head's, and both are settable per arrow via
  `tip:` / `fade:` in an arrow entry.
- **`last-move`** marks the move that produced the drawn position — `"arrow"`
  draws it, `"squares"` marks the two squares — and like every other automatic
  marking it needs a game plus `at:`; a bare position gets nothing. Off by
  default, settable document-wide.
- **Figurine notation as input.** `game` / `games` accept movetext written with
  Unicode chess figurines (U+2654–U+265F, either colour set), as Chess Informator
  and many other publications typeset it. No `lang:` is needed — figurines are
  language-neutral, which is why publications use them.
- **Localized movetext as input**: `game(text, lang: "de")` reads German, French,
  Spanish, Italian, Portuguese or Russian piece letters and normalizes them to
  standard SAN, so the reading language and the printing language are
  independent.

### 1.1.0 — GitHub release only

*Never published to Typst Universe, which went from 1.0.0 straight to
2.0.0. The tag and the GitHub Release exist; if you install from Universe
you will not have seen this version, and its changes reach you as part of
2.0.0.*

- **Positions remember the move they came from.** `position-after` (and
  anything built on it) now folds a small provenance payload — locator, SAN,
  move quality, `%cal`/`%csl` annotations, raw tags, but never the game itself
  — into the position it returns. `board`/`diagram` read that payload at one
  shared seam, so the move-quality badge and imported annotations render
  correctly regardless of which function produced the position: badge
  legitimacy is a property of the *value* ("this came from a real move"), not
  of which function was called. No new public API — `diagram-after` is a
  one-line alias for `diagram(position-after(g, l))`.
- **New highlight shape `"frame"`** — a stroked rounded rectangle hugging the
  square border, reproducing the square highlight used by ChessBase. Unlike
  `"cross"` it carries no empty-square convention: it leaves the centre clear,
  so it reads over an occupied square. Four new style options, each taking
  `auto` / a ratio of the square / an absolute length: `frame-color` (green),
  `frame-width` (`auto` → 10%), `frame-margin` (`auto` → 3%) and `frame-radius`
  (`auto` → 22%, the outer corner radius). Because PGN `%csl` entries honour
  `highlight-shape`, setting `highlight-shape: "frame"` also renders imported
  square annotations as frames.
- **Thinner highlight marks — changes existing documents.** `cross-width`,
  `circle-width` and `frame-width` now default to **10%** of the square instead
  of 15%. At 15% the non-filled marks read heavy against the pieces. If you
  relied on the old weight, set it explicitly (`circle-width: 15%`); an explicit
  width was never affected. `arrow-width` deliberately **stays at 15%** — an
  arrow shaft spans several squares and reads as a hairline at 10% — so arrows
  now sit visibly heavier than the marks.
- **Documentation**: the Highlights section now says how to color and size a
  mark (per-entry `color:`, the shape's own `*-color` per call or via
  `set-board-defaults`, or a `board-theme`) — previously those options were
  listed only in the Board Style Options table.
- **Attribution**: the `"frame"` shape is credited to ChessBase, and the
  in-check glow's profile to Lichess, in the manual and in source.

### 1.0.0

**Breaking.** 1.0.0 deliberately *narrows* scope to western chess — standard
play, Chess960, non-standard boards and limited fairy pieces. Other traditions
(xiangqi, shogi, …) are out of scope and belong in their own packages.

- **Simpler API**: with one variant family to serve, the variant-named wrappers
  bought nothing, so `chess-board`, `chess960-board`, `chess-diagram`,
  `chess960-diagram` and `chess-notation` are **removed** — use the
  chess-variant-agnostic `board`, `diagram` and `notation`, which accept Chess960
  and fairy positions just as happily. `chess-moves` is renamed **`play`**. The
  outline functions lose their prefix too: `chess-diagram-outline`,
  `chess-table-outline` and `chess-outlines` become **`diagram-outline`**,
  **`table-outline`** and **`outlines`**. If a short name collides with something
  in your document, rename it on import (`board as chessboard`). Unchanged:
  `set-chess-defaults` (there the `chess-` prefix is a namespace, not a variant
  marker) and `game-variant`, now the way to tell a 960 game from a standard one.
- **Reworked wood and marble**: both materials are redrawn from scratch. The old
  textures were pure noise, which cannot produce the *structure* these materials
  have — wood now has real flowing grain with cathedral figure, and marble a
  branching, multi-scale vein network. The artwork is monochrome by design: it
  carries light and shadow only, so the hue comes from your `color-theme` and the
  same texture reads correctly on any palette.
- **Wood patterns light squares too** — a wood board now reads as *inlaid* light
  and dark timber rather than texture on half the squares. This changes how
  existing `pattern: "wood"` documents look; set **`pattern-light: false`** for
  the previous dark-squares-only behaviour. (The new field works for `"marble"`
  too, which always patterned both.)
- **Material bands follow the theme**: the `"wood"` and `"marble"` `border-theme`
  bands no longer use a fixed espresso / bottle-green. They derive from the
  board's own colors — the dark square darkened, with the light square as the
  label — so the band belongs to whatever `color-theme` is in play instead of
  clashing with it.

### 0.3.0

- **More border themes**: `border-theme` (the `label-mode: "border"` band) gains
  `"creme"` (creme band, saddle-brown labels) and `"light"` (light-grey band,
  charcoal labels — the mirror of `"dark"`), joining `"square"`, `"brown"` and
  `"dark"`.
- **Material border themes**: `border-theme` also gains `"wood"` and `"marble"`,
  the band counterparts of the `"wood"` / `"marble"` square `pattern`s — a
  wood-grain or marble-veining texture composited over the band, for matching
  a wood- or marble-patterned board. `"wood"` reuses `"brown"`'s exact band and
  label colors; `"marble"` is a bottle-green band with creme labels.
- **`"brown"` border theme retuned**: its band is now a lighter espresso brown
  (was a very dark near-black brown). ⚠️ This changes how existing documents
  using `border-theme: "brown"` look — the frame is visibly lighter. Set the old
  color explicitly if you need the previous appearance.
- **Color and board themes**: `color-theme(light:, dark:)` bundles a square-color
  pairing, and `board-theme(..)` bundles a full board look (any board style field
  plus a nested color theme). Both accept a built-in name or a constructor value,
  and are set via the new `color-theme` / `board-theme` board style fields
  (per-call or document-wide). Eleven built-ins ship: `"staunton-default"`,
  `"dutch-gray"`, and nine themes reproduced from kokopu-react (`"scid"`,
  `"wikipedia"`, `"xboard"`, `"coral"`, `"dusk"`, `"emerald"`, `"marine"`,
  `"sandcastle"`, `"wheat"`), whose square colors are reproduced from
  [kokopu-react](https://github.com/yo35/kokopu-react) (LGPL-3.0, © Yoann Le
  Montagner). See the manual for the full catalogue and the precedence rule.
- **Square patterns**: `color-theme(.., pattern: ..)` lays a texture over the
  squares — `"stripes"` (diagonal hatching on dark squares), `"marble"` (both
  squares) or `"wood"` (dark squares only). The overlay composites *over* the
  theme's own colors and never replaces them, so the result still follows the
  `light` / `dark` pair you pick.
- **Brightness and contrast**: `color-theme(.., brightness: .., contrast: ..)`
  post-adjusts a square-color pair — `brightness` shifts both toward white or
  black, `contrast` spreads or compresses the lightness gap between them. Both
  take signed ratios, are clamped to ±100%, and the pair is always held at least
  5% apart in lightness, so an extreme setting cannot collapse or invert the
  checkerboard.
- **Tournament-table styling**: standings tables, cross-tables and progress
  charts gain eight styling options — `grid` (`"complete"` / `"no-outer"` /
  `"header-rule"`), `header-align`, `header-fill`, `body-align`, `body-fill`
  (including `"zebra"` rows), `table-align`, `caption-bold` and
  `highlight-winners`. Each is settable per call or document-wide via the new
  `set-table-defaults(..)`, and raw `#table` arguments passed straight through
  still override any preset. Table headers now also repeat when a table breaks
  across a page boundary.
- **`move-to-san`**: names an engine-generated move from a bare position — the
  inverse of the SAN parser, with the same disambiguation, check / mate suffix
  and castling rules. Movetext can now be produced without a pre-existing PGN
  (puzzle solutions, generated lines, legal-move listings).
- **Faster board rendering**: the checkerboard is memoized, so diagrams sharing
  geometry and colors build it once instead of per board; square parsing has a
  fast path, and the in-check probe is gated so it only runs when a glow is
  actually requested.
- **Lower compiler floor — Typst 0.14.2**: the manifest previously required
  0.15. The library's only hard 0.15 dependency was the HTML-export path
  (`target()` / `html.frame`), which is now guarded on `sys.version`, so paged
  output works on 0.14.2. Verified on both compilers: 175/175 on 0.15.1, and on
  0.14.2 the only gaps are the two HTML-export tests plus two expected-fail
  fixtures whose asserted *error wording* differs between compiler versions —
  no behavioural difference in the library. ⚠️ HTML export still requires 0.15+.

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
- Developed with assistance from Claude models by Anthropic.

## License

Code: **MIT** (© 2026 Frank Lippert). Bundled piece images: **GPL-2.0-or-later**.
See [LICENSE](LICENSE) and [LICENSE-PIECES](LICENSE-PIECES).
