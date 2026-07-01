# diffst

`diffst` renders presentable side-by-side diff reports in Typst.

```typst
#import "@preview/diffst:0.1.0": diffst

#let old-file = path("old.typ")
#let new-file = path("new.typ")

#diffst(old-file, new-file)
```

The package reads two text files, sends their contents to a Rust WebAssembly
plugin powered by the Rust `similar` crate, and renders the structured diff as
Typst content. If you already have strings, use `diffst-content`.

## License

`diffst`'s Typst wrapper code and package-specific Rust code are licensed under
the MIT License; see `LICENSE-MIT`. The underlying Rust `similar` crate used by
the WebAssembly plugin is licensed under the Apache License 2.0; see
`LICENSE-APACHE`.

Want a report for everything changed between two commits? Use the
[`uv` runnable git-diff helper](#git-commit-diffs) from the
[`clvnkhr/diffst`](https://github.com/clvnkhr/diffst) source repository to
generate a Typst document from a pair of Git revisions.

## Quick Start

```typst
#import "@preview/diffst:0.1.0": diffst

#set page(height: auto)

#let old-file = path("draft-old.typ")
#let new-file = path("draft-new.typ")

#diffst(
  old-file,
  new-file,
  inline: "words",
)
```

For an unbroken review view, `#set page(height: auto)` lets the diff flow as
one continuous page instead of splitting tables across fixed-height pages.

By default, `diffst` collapses long unchanged regions. Use `display: "full"` to
show every line.

```typst
#diffst(
  old-file,
  new-file,
  display: "full",
)
```

`diffst(old-path, new-path, ..)` accepts paths or strings, with strings converted
to paths; for text you already have in Typst, call `diffst-content(...)`.

## Main Options

```typst
#diffst(
  old-file,
  new-file,
  old-label: "old draft",
  new-label: "new draft",
  algorithm: "histogram",
  inline: "words",
  unicode: true,
  semantic-cleanup: true,
  ignore-whitespace: false,
  show-whitespace: false,
  display: "collapsed",
  context-lines: 3,
  collapse-threshold: 14,
  table-layout: "split",
  table-style: "default",
)
```

- `algorithm`: `"histogram"`, `"myers"`, `"patience"`, `"lcs"`, or `"hunt"`.
  Histogram is the default because it tends to produce readable changed blocks
  for prose and reordered code. Myers is the classic baseline.
- `inline`: `"words"`, `"chars"`, or `"none"`. Word mode is the default because
  it reads better in reports; character mode is available for very fine-grained
  edits.
- `unicode`: when `true`, inline diffs use grapheme clusters and Unicode word
  boundaries.
- `semantic-cleanup`: uses `similar`'s compact inline diff adapter to make
  inline highlights less fragmented and easier to read. It is on by default for
  presentation; set it to `false` when you want more literal token-by-token
  inline spans.
- `ignore-whitespace`: compares lines while ignoring whitespace differences.
- `show-whitespace`: makes changed spaces and tabs visible, and marks trailing
  spaces or tabs on otherwise unchanged lines. Marker drawings are vector
  overlays, so PDF copy/paste keeps the underlying whitespace.
- `diffst-content`: use this instead of `diffst` when you want to pass strings
  directly. `old-label` and `new-label` control the rendered labels.
- `old-label` / `new-label`: optional labels shown above the two sides. For
  `diffst`, these default to the paths.
- `display`: `"full"` or `"collapsed"`.
- `context-lines`: unchanged lines to keep around collapsed regions.
- `collapse-threshold`: unchanged run length required before collapsing.
- `table-layout`: `"split"` or `"single"`. Split is the default and uses
  synchronized tables so old/new content columns are easier to copy separately.
  Single renders one Typst `table`.
- `table-style`: `"default"`, `"minimal"`, `default-table-style`,
  `minimal-table-style`, or a derived style dictionary.

## Styling

Override colors per report or document-wide:

```typst
#import "@preview/diffst:0.1.0": diffst, diffst-style, default-colors

#show: diffst-style.with(colors: default-colors + (
  replace: rgb("#e0f2fe"),
  inline-delete: rgb("#f0abfc"),
  inline-insert: rgb("#67e8f9"),
))

#diffst(
  old-file,
  new-file,
)
```

Available color keys:

`text`, `line-no`, `border`, `header`, `equal`, `delete`, `insert`, `replace`,
`inline-delete`, `inline-insert`, `inline-equal`, `delete-text`, `insert-text`,
`replace-text`, `marker`, and `collapsed`.

For printed papers or compact reports, use the minimal style:

```typst
#import "@preview/diffst:0.1.0": diffst, minimal-table

#show: minimal-table

#diffst(
  old-file,
  new-file,
)
```

`minimal-table` sets `minimal-colors` and `minimal-table-style`. The minimal
table keeps only the middle separator and the rule under the header while
retaining colored inline highlights.

Table style dictionaries control columns and stroke widths:

```typst
#import "@preview/diffst:0.1.0": diffst, default-table-style

#diffst(
  old-file,
  new-file,
  table-style: default-table-style + (
    columns: (2em, 1fr, 2em, 1fr),
    stroke-width: (header: 0.7pt, body: 0.35pt),
  ),
)
```

Prefer `#show table: set table(..)` and `#show table.cell: ...` for table
styling. Broad wrappers such as `#show table: it => block(..)[#it]` can affect
internal measurement tables used to synchronize row heights.

## Composition API

For custom reports, build from data upward:

```typst
#import "@preview/diffst:0.1.0": (
  diffst-report,
  diffst-summary,
  diffst-table,
  diffst-single-table,
)

#let report = diffst-report(
  read(path("paper-old.typ")),
  read(path("paper-new.typ")),
  old-label: "paper-old.typ",
  new-label: "paper-new.typ",
  inline: "words",
  semantic-cleanup: true,
)

#diffst-summary(report)

#v(8pt)

#diffst-table(report, range: (10, 18))

#v(8pt)

#diffst-single-table(report, range: (26, 34), range-side: "new")
```

The main composition layers are:

- `diffst(old-path, new-path, ..)` reads files and renders the default report.
- `diffst-content(old-text, new-text, ..)` renders the default report from
  already-read strings.
- `diffst-report(old-text, new-text, ..)` returns structured diff data and
  metadata from already-read strings.
- `diffst-summary(report, ..)` renders the file labels, line counts, and stat
  pills.
- `diffst-table(report, ..)` renders the default split-table diff.
- `diffst-single-table(report, ..)` renders the one-table version.
- `diffst-layout(report, ..)` renders the default full report: summary, spacing,
  and table.

`range: (start, end)` filters to an inclusive 1-based line range before
`display` is applied. By default, rows are kept when either the old or new line
number is in range. Use `range-side: "old"` or `range-side: "new"` to anchor the
range to one file.

Use `diffst-layout(..., body: (report, rows, colors) => ..)` when you want the
default row filtering, range handling, and color resolution, but a custom final
arrangement:

```typst
#diffst-layout(
  report,
  range: (10, 18),
  body: (report, rows, colors) => [
    #diffst-summary(report, colors: colors)
    #v(4pt)
    #diffst-single-table(report, rows: rows, colors: colors)
  ],
)
```

## Lower-Level Data Helpers

Use these when you want to compute your own layout:

- `report.labels`, `report.options`, `report.meta`, `report.stats`,
  `report.ops`, and `report.rows` expose the underlying diff data. The older
  `report.old` and `report.new` label aliases are also available.
- `diffst-rows(report, display: .., range: ..)` returns renderable row
  dictionaries without emitting content.
- `diffst-hunks(report, context-lines: ..)` returns hunk dictionaries with
  `ops`, `rows`, `old_start`, `old_len`, `new_start`, and `new_len`.
- `diffst-debug(report)` renders the raw report fields.

The similarity score is available as `report.stats.similarity`, from `0.0` to
`1.0`.

## Copy/Paste Notes

The default split layout uses separate synchronized tables for old line numbers,
old content, new line numbers, and new content. This makes it easier to select
one side of the diff in PDF viewers.

Long unbroken code spans are clipped to the table cell instead of being broken
with inserted characters. Visually wrapped lines may still copy with inserted
newlines depending on the PDF viewer; that is a PDF text-extraction behavior,
not an inserted character in the Typst source.

## Metadata

`report.meta` includes:

`algorithm`, `inline`, `unicode`, `ignore_whitespace`, `show_whitespace`,
`semantic_cleanup`, `old_trailing_newline`, `new_trailing_newline`,
`old_line_endings`, `new_line_endings`, and `messages`.

Line ending values are `"lf"`, `"crlf"`, `"cr"`, `"mixed"`, or `"none"`.
When only the final trailing newline differs, the rendered diff adds a note row;
raw newline and line-ending details remain available through `report.meta`.

The summary's `x% similar lines` score is based on exactly matched lines. A
prose diff with small edits on every line can therefore show `0% similar lines`
even when the lines look visually similar.

## Examples

Focused diff option examples live in `examples/diffs/`:

- algorithms: `algorithm-myers.typ`, `algorithm-patience.typ`,
  `algorithm-histogram.typ`, `algorithm-lcs.typ`, `algorithm-hunt.typ`
- inline modes: `inline-chars.typ`, `inline-words.typ`, `inline-none.typ`
- display: `display-full.typ`, `display-collapsed.typ`,
  `collapse-threshold.typ`, `context-lines.typ`
- whitespace: `ignore-whitespace.typ`, `show-whitespace.typ`,
  `trailing-whitespace.typ`, `trailing-newline.typ`
- other: `unicode.typ`, `semantic-cleanup.typ`, `long-lines.typ`,
  `table-layout.typ`, `debug.typ`, `hunks.typ`

Source fixtures used by the examples live in `examples/sources/`.

Larger examples:

- `examples/diffs/basic.typ`
- `examples/diffs/realistic.typ`
- `examples/diffs/custom-colors.typ`
- `examples/diffs/minimal-table.typ`
- `examples/diffs/show-rules.typ`
- `examples/diffs/manual-layout.typ`
- `examples/diffs/partial-report.typ`

### Git Commit Diffs

The `uv` runnable helper `scripts/git-diff.py` in the
[`clvnkhr/diffst`](https://github.com/clvnkhr/diffst) source repository
generates a Typst report for all files changed between two Git revisions. It
accepts full or short commit hashes, writes one section per changed file, and
adds an outline plus back-to-top links.

```sh
scripts/git-diff.py cece06a 8b48d70 --output examples/diffs/git-cece06a-8b48d70.typ
scripts/git-diff.py b8ccbd3 cece06a --output examples/diffs/git-b8ccbd3-cece06a.typ

typst compile --root . examples/diffs/git-cece06a-8b48d70.typ examples/diffs/git-cece06a-8b48d70.pdf
typst compile --root . examples/diffs/git-b8ccbd3-cece06a.typ examples/diffs/git-b8ccbd3-cece06a.pdf
```

## Build

Contributor setup, release checks, and Typst Universe PR packaging are
documented in the source repository.

```sh
rustup target add wasm32-unknown-unknown
sh scripts/smoke.sh
```

Development requires `wasm-opt` from Binaryen. The smoke script runs
`cargo test`, builds the WASM plugin, optimizes it with
`wasm-opt -Oz --enable-bulk-memory`, and compiles every example to
`${TMPDIR:-/tmp}/diffst-smoke`.

The package loads `plugin.wasm` from the repository root. `scripts/smoke.sh`
refreshes that package-local artifact from the optimized release build before
compiling examples.

For release checks, this package also works with community tooling:

```sh
scripts/package-pr.py
typst-package-check check --offline package-pr/packages/preview/diffst/0.1.0
(cd package-pr/packages/preview/diffst/0.1.0 && typship check)
```

`deadline-ms` is intentionally not exposed. The `similar` crate can use real
deadlines when a clock is available, but Typst plugins do not currently provide
the host clock imports needed for a reliable WASM wall-clock cutoff.
