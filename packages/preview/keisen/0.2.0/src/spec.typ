///! Directive folding into the display-table spec, and spec validation.
///!
///! Directives are plain dictionaries applied in declaration order, so a
///! generator in another language can build a spec directly rather than
///! emitting markup. Validation runs once on the folded spec rather than inside
///! each directive, which is what makes directive order free.

#import "data.typ": column-names, group-rows, normalise
#import "parts/spanners.typ": validate-spanners
#import "parts/summaries.typ": infinite-columns
#import "parts/stub.typ": stub-column-names
#import "format/apply.typ": (
  check-rows, check-selector, matches-column, matches-label, matches-row, named, nanoplot-columns,
)
#import "spec/order.typ": apply-alignments, apply-combines, apply-moves
#import "theme/options.typ": validate-options
#import "utils/columns.typ": check-addressable
#import "utils/errors.typ": check, check-column, fail

// Every directive kind the fold below handles, named once so the hint it prints
// cannot fall behind the branches it describes. It listed thirteen while the
// fold handled seventeen, and omitted width, align, options and summary.
#let HANDLED-KINDS = (
  "header",
  "stub",
  "row-group",
  "labels",
  "hide",
  "combine",
  "spanner",
  "move",
  "format",
  "style",
  "substitute",
  "colour",
  "footnote",
  "options",
  "width",
  "align",
  "summary",
  "source-note",
)

#let _empty = (
  kind: "display-table",
  // Set by build-spec alone, so the entry point can tell a resolved
  // specification from one that arrived as data and named its formatters.
  built: true,
  data: (),
  // Every column the data carries, rendered or not, so validation can tell an
  // unknown name from a hidden one.
  data-columns: (),
  columns: (),
  hidden: (),
  labels: (:),
  header: (title: none, subtitle: none),
  stub: (rowname: none, group: none, label: none, indent: none),
  row-groups: (),
  groups: (),
  spanners: (),
  moves: (),
  combines: (),
  formats: (),
  styles: (),
  substitutions: (),
  colours: (),
  footnotes: (),
  summaries: (),
  grand-summaries: (),
  widths: (:),
  // Recorded in the order they were written, and resolved into `align` once the
  // table knows which columns it has.
  alignments: (),
  align: (:),
  source-notes: (),
  options: (:),
)

// Declared groups, in the order they were written, resolved against the data.
//
// A row claimed twice belongs to the last group that claims it, so a group
// written later corrects the one before it rather than duplicating its rows. A
// group left with nothing of its own is dropped: a label over no rows is noise
// the reader has to account for.
#let _declared-groups(rows, directives) = {
  let claimed = directives
    .enumerate()
    .map(((index, directive)) => rows
      .filter(row => matches-row(directive.rows, row))
      .map(row => (position: row._index, owner: index)))
    .flatten()
    .fold((:), (owners, claim) => {
      owners.insert(str(claim.position), claim.owner)
      owners
    })

  directives
    .enumerate()
    .map(((index, directive)) => (
      label: directive.label,
      rows: rows
        .map(row => row._index)
        .filter(position => claimed.at(str(position), default: -1) == index),
    ))
    .filter(group => group.rows.len() > 0)
}

// A summary naming a group the table does not carry produced no row and said
// nothing, while the location DSL refuses the same name, so a style could
// address a summary row the directive never made.
//
// Run after grouping rather than inside `_validate`, because there is no group
// list before it. Held to the labels a caller could legitimately name: the ones
// declared plus the ones derived, rather than `spec.groups`, since a declared
// group that matched no rows is dropped from that and naming it is not a typo.
// `_group-labels` in `src/locations.typ` reads the same rule, so a summary and
// the style addressing it agree on which groups exist.
//
// Only what the selector spells out is checked, as everywhere else: `auto` and a
// predicate match nothing in silence.
#let _check-summary-groups(spec) = {
  let known = (
    spec.row-groups.map(directive => directive.label) + spec.groups.map(group => group.label)
  ).dedup()
  for directive in spec.summaries {
    let selector = directive.groups
    if selector == auto or type(selector) == function { continue }
    let candidates = if type(selector) == array { selector } else { (selector,) }
    for candidate in candidates {
      if type(candidate) == function { continue }
      if known.any(label => matches-label(candidate, label)) { continue }
      fail(
        "summary-rows",
        "unknown group " + repr(candidate),
        hint: if known.len() == 0 {
          "The table has no groups."
        } else {
          "Known groups: " + known.map(repr).join(", ") + "."
        },
      )
    }
  }
}

// The directive the caller wrote, so a grand summary is not reported as a group
// summary. The unsummarisable check below named `summary-rows` for both.
#let _summary-scope(directive) = (
  if directive.scope == "group" { "summary-rows" } else { "grand-summary-rows" }
)

#let _validate(spec) = {
  let stub-columns = stub-column-names(spec.stub)
  let known = spec.columns + spec.hidden + stub-columns

  // The stub names data columns, which exist whether or not they are rendered;
  // everything else names columns the table knows about.
  for name in stub-columns { check-column(spec.data-columns, "table-stub", name) }

  // Combines are checked before the hidden columns, because they hide their own
  // sources: an unknown source reported as a columns-hide typo would name a
  // directive the caller never wrote.
  for directive in spec.combines {
    check(
      type(directive.from) == array and directive.from.len() > 0,
      "columns-combine",
      "from must name the columns to combine",
      value: directive.from,
      hint: "Give an array of column names, in the order the pattern reads them.",
    )
    check(
      type(directive.pattern) == function,
      "columns-combine",
      "pattern must be a function of the source columns",
      value: directive.pattern,
      hint: "Write (estimate, error) => [#estimate (#error)], one parameter per source.",
    )
    for name in directive.from { check-column(spec.data-columns, "columns-combine", name) }
    check(
      directive.into in directive.from or directive.into not in spec.data-columns,
      "columns-combine",
      "into names an existing column, " + directive.into,
      hint: "Give the combined column a name of its own, or combine into one of its sources.",
    )
  }

  // A hidden column that does not exist is a typo, and leaving it unchecked
  // would whitelist the same typo for every other directive.
  for name in spec.hidden { check-column(spec.data-columns, "columns-hide", name) }

  // A summary row is an aggregate of a column with no row behind it. The
  // column-wide path already leaves cell formatters out, through covering() in
  // src/render/layout.typ; a format named on the summary itself bypasses that
  // and would reach the closure with the aggregate, failing as a Typst type
  // error that names neither the directive nor the reason.
  for directive in spec.summaries + spec.grand-summaries {
    let scope = _summary-scope(directive)
    // A formatter function or a format directive, which is what the design
    // documents. Anything else reached the field access below and failed as a
    // Typst error about closures, naming neither the directive nor the reason.
    check(
      directive.format == none
        or type(directive.format) == function
        or (type(directive.format) == dictionary and directive.format.at("kind", default: none) == "format"),
      scope,
      "format is not a formatter",
      value: directive.format,
      hint: "Give a formatter function, or one of the format-* directives.",
    )
    check(
      type(directive.format) != dictionary or not directive.format.at("cell", default: false),
      scope,
      "format cannot be a cell formatter",
      hint: "A summary row has no row to read; use format() or one of the format-* directives.",
    )
  }

  // Groups come from the data or from the document, never from both: a table
  // whose grouping had two sources would need a rule for which one wins, and
  // the rule nobody writes down is the one every reader gets wrong.
  check(
    spec.row-groups.len() == 0 or spec.stub.group == none,
    "table-row-group",
    "the groups already come from a column",
    hint: "Drop the group column from table-stub, or drop the table-row-group calls.",
  )

  // An index outside the data is a typo by definition; a predicate that matches
  // no row is not, since a table built from filtered data legitimately has
  // fewer rows on some renderings than on others. The same reading answers a
  // location, so a group and a style say the same thing about the same row.
  for directive in spec.row-groups {
    check-rows("table-row-group", directive.rows, spec.data.len())
  }

  check(
    spec.summaries.len() == 0 or spec.stub.group != none or spec.row-groups.len() > 0,
    "summary-rows",
    "there are no groups to summarise",
    hint: "Give table-stub a group column, declare groups with table-row-group, or use grand-summary-rows for the whole body.",
  )

  if spec.stub.indent != none {
    for row in spec.data {
      let depth = row.at(spec.stub.indent, default: 0)
      check(
        type(depth) == int and depth >= 0,
        "table-stub",
        "indent level in row " + str(row._index) + " is not a whole number of steps",
        value: depth,
        hint: "An indent column holds non-negative integers.",
      )
    }
  }

  // A nanoplot column holds series rather than quantities, and a combined
  // column holds content built from columns that are no longer shown. Neither
  // has a total, so a summary over every column leaves both out. Naming one is
  // a different thing: it says the reader expected an aggregate that cannot
  // exist, so it is refused rather than answered with a blank cell.
  let unsummarisable = (
    nanoplot-columns(spec.formats, spec.columns).map(name => (
      name: name,
      why: "holds nanoplots",
      hint: "Name the other columns: aggregating series of readings has no meaning.",
    ))
      + spec.combines.map(directive => (
        name: directive.into,
        why: "is combined from other columns",
        hint: "Summarise its sources instead; a combined column holds content, not quantities.",
      ))
      + infinite-columns(spec.data, spec.columns).map(entry => (
        name: entry.name,
        why: "holds an infinite value in row " + str(entry.row),
        hint: "Aggregations work in decimal, which has no infinity; name the other columns.",
      ))
  )
  for directive in spec.summaries + spec.grand-summaries {
    if directive.columns == auto { continue }
    for column in unsummarisable.filter(entry => matches-column(directive.columns, entry.name)) {
      fail(
        _summary-scope(directive),
        "column " + column.name + " " + column.why + " and cannot be summarised",
        hint: column.hint,
      )
    }
  }

  // A summary naming a column the table does not carry rendered a bold Total row
  // with every cell blank, which reads as data that did not add up rather than
  // as a typo.
  for directive in spec.summaries + spec.grand-summaries {
    for name in named(directive.columns, str) {
      check-addressable(
        name,
        _summary-scope(directive),
        columns: spec.columns,
        hidden: spec.hidden,
        stub: stub-columns,
        hidden-hint: "Summarise a visible column: columns-hide removes one, and columns-combine hides its sources unless hide-sources is false.",
        stub-hint: "The stub labels the rows; a summary aggregates the columns beside it.",
      )
    }
  }

  for name in spec.labels.keys() { check-column(known, "columns-label", name) }
  for name in spec.widths.keys() { check-column(known, "columns-width", name) }
  // Alignment is not checked here. It is checked by apply-alignments, beside
  // where it is resolved, because the stub takes an alignment and a hidden
  // column refuses one, so `known` is the wrong set to hold it to.

  // A directive naming a column the table does not have formats nothing and said
  // nothing, which is the typo the two checks above already catch. Each is
  // reported under the name the caller wrote, so `format-date` is named rather
  // than the shared constructor behind it.
  //
  // The rows are read here as well, for the reason `named` gives. The kind is
  // held and the position is not, which is where these part from a group and
  // from a location: a format that lands on no row leaves the table as it was,
  // while a group that claims no row is dropped from the table altogether, and
  // a style addresses a cell that has to exist.
  for directive in spec.formats {
    for name in named(directive.columns, str) {
      check-column(known, directive.at("scope", default: "format"), name)
    }
    check-selector(directive.rows, int)
  }
  for directive in spec.substitutions {
    for name in named(directive.columns, str) {
      check-column(known, "substitute-" + directive.test, name)
    }
    check-selector(directive.rows, int)
  }
  for directive in spec.colours {
    // The target is read here rather than where the colour is drawn, because a
    // hidden column and the stub leave spec.columns and so are drawn by nobody.
    // A misspelling on one of those used to be read by nobody either.
    check(
      directive.target in ("fill", "text"),
      "data-colour",
      "target must be fill or text",
      value: directive.target,
    )
    // The palette is stretched over the domain, so it takes a low and a high.
    // Anything else was dropped without a word, and the column came out plain.
    check(
      directive.domain == auto
        or (
          type(directive.domain) == array
            and directive.domain.len() == 2
            and directive.domain.all(edge => type(edge) in (int, float, decimal))
        ),
      "data-colour",
      "domain must be auto or a low and a high",
      value: directive.domain,
      hint: "Write domain: (0, 100), or leave it auto to span the data.",
    )
    for name in named(directive.columns, str) { check-column(known, "data-colour", name) }
    check-selector(directive.rows, int)
  }

  spec
}

#let build-spec(data, directives, theme) = {
  let spec = _empty
  spec.data = normalise(data)
  // A column store names its columns even when it holds no rows, so filtered
  // data still renders its header rather than losing every column.
  spec.data-columns = if type(data) == dictionary and spec.data.len() == 0 {
    data.keys()
  } else {
    column-names(spec.data)
  }
  spec.columns = spec.data-columns
  check(
    type(theme) == dictionary,
    "display-table",
    "theme must be an option dictionary",
    value: theme,
    hint: "Call the preset: theme: theme-booktabs().",
  )
  spec.options = validate-options(theme, "display-table")

  for directive in directives {
    check(
      type(directive) == dictionary and "kind" in directive,
      "display-table",
      "argument is not a directive",
      value: directive,
      hint: "Pass directives such as table-header() or format-number().",
    )

    if directive.kind == "header" {
      spec.header = (title: directive.title, subtitle: directive.subtitle)
    } else if directive.kind == "stub" {
      check(
        spec.stub.rowname == none and spec.stub.group == none,
        "table-stub",
        "the stub is already defined",
        hint: "One table-stub per table; put every stub column in that one call.",
      )
      check(
        directive.rowname != none or directive.label == none,
        "table-stub",
        "label needs a rowname",
        hint: "A stubhead labels the row-name column, so name one with rowname.",
      )
      spec.stub = directive
      // The stub columns label the table rather than carry data, so they leave
      // the column list while staying in the row store for predicates.
      let promoted = stub-column-names(directive)
      spec.columns = spec.columns.filter(name => name not in promoted)
    } else if directive.kind == "row-group" {
      spec.row-groups.push(directive)
    } else if directive.kind == "labels" {
      spec.labels = spec.labels + directive.labels
    } else if directive.kind == "hide" {
      spec.hidden = spec.hidden + directive.columns
      spec.columns = spec.columns.filter(name => name not in directive.columns)
    } else if directive.kind == "combine" {
      // Checked here rather than in `_validate`: `into` is read as a dictionary
      // key by the label below and by the ordering pass, both of which run
      // first, so a value that is not a string fails as a Typst error before
      // any check in `_validate` is reached.
      check(
        type(directive.into) == str,
        "columns-combine",
        "into must be the name of the column to build",
        value: directive.into,
        hint: "Give a column name as a string.",
      )
      // Recorded rather than applied, exactly as a move is: where the combined
      // column goes depends on which columns the table ends up with, so it is
      // resolved once the fold is done and reads the same wherever it is written.
      spec.combines.push(directive)
      if directive.label != auto { spec.labels.insert(directive.into, directive.label) }
    } else if directive.kind == "spanner" {
      spec.spanners.push(directive)
    } else if directive.kind == "move" {
      // Recorded rather than applied: ordering resolves once the table knows
      // which columns it has, so a move reads the same wherever it is written.
      spec.moves.push(directive)
    } else if directive.kind == "format" {
      spec.formats.push(directive)
    } else if directive.kind == "style" {
      spec.styles.push(directive)
    } else if directive.kind == "substitute" {
      spec.substitutions.push(directive)
    } else if directive.kind == "colour" {
      spec.colours.push(directive)
    } else if directive.kind == "footnote" {
      spec.footnotes.push(directive)
    } else if directive.kind == "options" {
      spec.options = spec.options + directive.options
    } else if directive.kind == "width" {
      check(
        type(directive.widths) == dictionary,
        "columns-width",
        "widths must map column names to lengths",
        value: directive.widths,
      )
      spec.widths = spec.widths + directive.widths
    } else if directive.kind == "align" {
      // Recorded rather than applied, exactly as a move or a combine is. A
      // selector resolved mid-fold reads a column list that a later stub, hide
      // or combine still changes, so a blanket alignment never reached a
      // combined column and an array selector filtered a typo away in silence.
      spec.alignments.push(directive)
    } else if directive.kind == "summary" {
      if directive.scope == "group" {
        spec.summaries.push(directive)
      } else {
        spec.grand-summaries.push(directive)
      }
    } else if directive.kind == "source-note" {
      spec.source-notes.push(directive.note)
    } else {
      fail(
        "display-table",
        "unknown directive",
        value: directive.kind,
        hint: "This version handles " + HANDLED-KINDS.join(", ") + ".",
      )
    }
  }

  // Ordering first, so spanner adjacency and every column check see the order
  // the table will actually render in. Alignment resolves after the ordering
  // rather than before it, because an unknown column is reported with the known
  // ones listed, and that list should read in the order the table renders in.
  // Validation then runs once, before grouping, which would otherwise die
  // inside the data layer rather than naming the offending directive.
  let validated = validate-spanners(_validate(apply-alignments(apply-moves(apply-combines(spec)))))
  // Derived from the column when the stub names one, declared by the document
  // otherwise. Validation has already refused both at once.
  validated.groups = if validated.row-groups.len() > 0 {
    _declared-groups(validated.data, validated.row-groups)
  } else {
    group-rows(validated.data, validated.stub.group)
  }
  _check-summary-groups(validated)
  validated
}
