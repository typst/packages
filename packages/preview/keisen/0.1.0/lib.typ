///! Public facade for keisen.
///!
///! Every user-facing function is re-exported here.
///!
///! Typst has no privacy: a wildcard import re-exports every module-level
///! binding, including the helpers this file needs for itself. Those are
///! aliased with a leading underscore to mark them as internal, which is a
///! convention rather than an enforcement: `_build-spec` does reach a user's
///! scope, it merely announces that it is not for them.
///! tests/unit/test-exports.typ holds the rest of the surface to the grammar.

#import "src/spec.typ": build-spec as _build-spec
#import "src/spec/serialised.typ": resolve-serialised as _resolve-serialised
#import "src/render/assemble.typ": assemble as _assemble
#import "src/theme/presets.typ": theme-booktabs, theme-compact, theme-default, theme-minimal
#import "src/theme/options.typ": table-options
#import "src/parts/header.typ": table-header
#import "src/parts/stub.typ": table-row-group, table-stub
#import "src/parts/summaries.typ": (
  aggregate-count, aggregate-max, aggregate-mean, aggregate-median, aggregate-min,
  aggregate-quantile, aggregate-standard-deviation, aggregate-sum, grand-summary-rows, summary-rows,
)
#import "src/parts/columns.typ": (
  columns-align, columns-combine, columns-hide, columns-label, columns-move, columns-width,
)
#import "src/parts/spanners.typ": table-spanner
#import "src/parts/notes.typ": table-footnote, table-source-note
#import "src/parts/substitutions.typ": substitute-missing, substitute-zero
#import "src/parts/colour.typ": data-colour
#import "src/style.typ": style, table-style
#import "src/locations.typ": (
  cells-body, cells-column-labels, cells-column-spanners, cells-footnotes, cells-grand-summary,
  cells-row-groups, cells-source-notes, cells-stub, cells-stubhead, cells-summary, cells-title,
)
#import "src/format/number.typ": format, format-cell, format-integer, format-number
#import "src/format/currency.typ": format-currency
#import "src/format/bytes.typ": format-bytes
#import "src/format/date.typ": format-date
#import "src/format/markup.typ": format-markup
#import "src/format/scientific.typ": format-scientific
#import "src/format/percent.typ": format-percent
#import "src/format/nanoplot.typ": format-nanoplot
#import "src/format/renderers.typ": nanoplot-bar, nanoplot-line, nanoplot-points
#import "src/utils/errors.typ": check as _check

// Build a display table from data and any number of directives.
//
// Data and directives arrive through one sink rather than as a required
// positional parameter, so that `display-table(spec: ..)` needs no placeholder
// data: that path is how a generator in another language reaches this pipeline.
#let display-table(..arguments, theme: theme-default(), spec: none) = {
  // A sink swallows named arguments as readily as positional ones, so a
  // misspelled option would vanish without a word.
  let unexpected = arguments.named().keys()
  _check(
    unexpected.len() == 0,
    "display-table",
    "unknown argument " + unexpected.join(", "),
    hint: "The named arguments are theme and spec.",
  )

  let resolved = if spec != none {
    _check(
      type(spec) == dictionary and spec.at("kind", default: none) == "display-table",
      "display-table",
      "spec is not a display-table specification",
      value: spec,
      hint: "Pass data and directives instead, or a specification in the serialised form.",
    )
    // A specification that reached Typst as data names its formatters instead
    // of carrying them, and is resolved back into directives before rendering.
    if spec.at("built", default: false) {
      spec
    } else {
      _resolve-serialised(spec, _build-spec, theme: theme)
    }
  } else {
    let positional = arguments.pos()
    _check(
      positional.len() > 0,
      "display-table",
      "no data given",
      hint: "Pass data as the first argument, or a built specification as spec.",
    )
    _build-spec(positional.first(), positional.slice(1), theme)
  }
  _assemble(resolved)
}
