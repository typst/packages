///! Specifications that reach Typst as data.
///!
///! A specification from `json()`, or from a generator in another language,
///! cannot carry closures. It therefore names what it wants, and the names are
///! resolved here into the directives a Typst caller would have written.
///!
///! The subset is deliberately small: comparisons composed with and, or, and
///! not, and built-ins named as strings. Anything more expressive belongs in a
///! Typst literal specification, which keeps this from drifting into an
///! expression language nobody wanted to write.
///!
///! A failure here names the directive the key resolves into, so a reader can
///! look the name up: `colours` gives `data-colour`, `widths`, `moves` and
///! `alignments` give `columns-width`, `columns-move` and `columns-align`, and
///! `header`, `stub`, `row-groups`, `combines`, `spanners` and `footnotes` give
///! `table-header`, `table-stub`, `table-row-group`, `columns-combine`,
///! `table-spanner` and `table-footnote`.
///!
///! Two keys resolve through one shared reader and are still named apart, since
///! each answers to a directive of its own: `summaries` gives `summary-rows` and
///! `grand-summaries` gives `grand-summary-rows`.
///!
///! Where no one directive answers to the key, the scope becomes `display-table`
///! and the key opens the problem instead. `format`, `style` and `inset` are
///! there: each resolves into a family or into a property of one, and the
///! `align` of a style is a property of `style()` rather than the directive
///! `columns-align`. So is `substitutions`, whose `test` picks between
///! `substitute-missing` and `substitute-zero`: one key, two directives, and no
///! single name to take.
///!
///! No key reports under a name of its own invention. A scope here is a public
///! directive, or it is `display-table` with the key said in the problem.
///!
///! `predicate` is the one scope outside that rule, and it is not a key. A row
///! predicate is a value the subset spells out, `(column: .., op: .., value:
///! ..)`, where a Typst caller writes a closure and so has no name to share.
///! The scope names what the reader wrote, which the reference calls a
///! predicate too.

#import "../format/bytes.typ": format-bytes
#import "../format/currency.typ": format-currency
#import "../format/date.typ": format-date
#import "../format/markup.typ": format-markup
#import "../format/number.typ": format-integer, format-number
#import "../format/percent.typ": format-percent
#import "../format/scientific.typ": format-scientific
#import "../locations.typ": PARTS, TITLE-PARTS
#import "../parts/substitutions.typ": is-missing
#import "../parts/summaries.typ": (
  aggregate-count, aggregate-max, aggregate-mean, aggregate-median, aggregate-min,
  aggregate-standard-deviation, aggregate-sum,
)
#import "../utils/errors.typ": check, fail, fail-enum

// Every formatter that takes no closure. `format`, `format-cell` and
// `format-nanoplot` are absent by nature rather than by omission: each is given
// a function, and JSON has no way to write one.
#let FORMATTERS = (
  "format-number": format-number,
  "format-integer": format-integer,
  "format-percent": format-percent,
  "format-currency": format-currency,
  "format-scientific": format-scientific,
  "format-bytes": format-bytes,
  "format-date": format-date,
  "format-markup": format-markup,
)

#let AGGREGATIONS = (
  "aggregate-sum": aggregate-sum,
  "aggregate-mean": aggregate-mean,
  "aggregate-median": aggregate-median,
  "aggregate-min": aggregate-min,
  "aggregate-max": aggregate-max,
  "aggregate-count": aggregate-count,
  "aggregate-standard-deviation": aggregate-standard-deviation,
)

// `op` is one of OPERATORS, held to it by resolve-predicate before the closure
// that calls this is built. A caller that skips that check reads none rather
// than a boolean, so the check belongs there and is not repeated here.
#let _compare(op, left, right) = {
  if op == "<" { left < right } else if op == "<=" { left <= right } else if op == ">" {
    left > right
  } else if op == ">=" { left >= right } else if op == "==" { left == right } else if op == "!=" {
    left != right
  }
}

#let OPERATORS = ("<", "<=", ">", ">=", "==", "!=")

// The two halves of one reading of a descriptor: the keys it may carry, and the
// keys it must. They sit together because a directive is usually held to both,
// and because a reader looking for one goes looking for the other.
// `subject` names the descriptor the key was written in, for the callers whose
// scope is the directive rather than the key. Several of them share the scope
// `display-table`, and without it a bad key in a format, a style, an inset, an
// alignment or the specification itself would all read the same.
#let _keys(descriptor, allowed, scope, subject: none) = {
  for key in descriptor.keys() {
    if key not in allowed {
      fail(
        scope,
        if subject == none { "unknown key " + key } else { subject + " has an unknown key " + key },
        hint: "Known keys: " + allowed.join(", ") + ".",
      )
    }
  }
}

// The hint belongs to the caller, since each descriptor says a different thing
// about what it needs.
#let _required(descriptor, keys, scope, hint) = {
  for key in keys {
    if key not in descriptor {
      fail(scope, "missing " + key, value: descriptor, hint: hint)
    }
  }
}

// A comparison, or and/or/not over comparisons, as a one-argument predicate.
// Anything that is already a selector in its own right passes straight through,
// so an index or an array of indices means what it means everywhere else.
#let resolve-predicate(descriptor) = {
  if type(descriptor) != dictionary { return descriptor }

  if "and" in descriptor {
    let parts = descriptor.at("and").map(resolve-predicate)
    return row => parts.all(test => test(row))
  }
  if "or" in descriptor {
    let parts = descriptor.at("or").map(resolve-predicate)
    return row => parts.any(test => test(row))
  }
  if "not" in descriptor {
    let inner = resolve-predicate(descriptor.at("not"))
    return row => not inner(row)
  }

  _required(
    descriptor,
    ("column", "op", "value"),
    "predicate",
    "A comparison is (column: .., op: .., value: ..), composed with and, or, not.",
  )

  // Reported while resolving, not on the first row: a location matching no rows
  // would otherwise never reach the comparison and never complain.
  if descriptor.op not in OPERATORS {
    fail-enum("predicate", "op", descriptor.op, OPERATORS)
  }

  row => {
    let value = row.at(descriptor.column, default: none)

    // Comparing against null is how the subset asks whether a cell is empty:
    // there would otherwise be no way to write it, and JSON has no other
    // spelling for absence.
    if descriptor.value == none {
      let missing = is-missing(value)
      return if descriptor.op == "==" { missing } else if descriptor.op == "!=" {
        not missing
      } else {
        fail(
          "predicate",
          "null compares only with == and !=",
          value: descriptor.op,
          hint: "Ordering an empty cell has no meaning.",
        )
      }
    }

    // A gap satisfies nothing. It is whatever the package calls missing, not
    // just none: an empty string is what a generator writes for NA.
    if is-missing(value) { return false }

    let numeric = (int, float, decimal)
    let comparable = type(value) == type(descriptor.value) or (
      type(value) in numeric and type(descriptor.value) in numeric
    )
    if not comparable {
      fail(
        "predicate",
        "cannot compare " + descriptor.column + " with the given value",
        value: (value, descriptor.value),
        hint: "The column and the value must be the same kind of thing.",
      )
    }

    _compare(descriptor.op, value, descriptor.value)
  }
}

// `subject` names the descriptor, as in `_keys`, for the caller whose scope is
// the directive rather than the key. It travels with `what`, since a message
// that names the key must also say what the name it wanted stands for.
#let _named(table, descriptor, scope, subject: none, what: "built-in") = {
  if "name" not in descriptor {
    fail(
      scope,
      if subject == none { "no name given" } else { subject + " names no " + what },
      value: descriptor,
      hint: "Name the built-in: (name: \"" + table.keys().first() + "\", ..).",
    )
  }
  let name = descriptor.name
  if name not in table {
    fail(
      scope,
      if subject == none { "unknown name" } else { subject + " names an unknown " + what },
      value: name,
      hint: "Known names: " + table.keys().join(", ") + ".",
    )
  }
  table.at(name)
}

// Text arrives as strings, since JSON has no content type.
#let _content(value) = if type(value) == str { [#value] } else { value }

// A hex colour, which is also how a stroke written as one string is told apart
// from a stroke written as a thickness: both are strokes Typst takes, and JSON
// has one spelling for the two.
//
// The lengths are the ones `rgb` reads: three or four digits, six, or eight. A
// looser range let "#12345" through this test and into `rgb`, which reported it
// in Typst's words rather than in the package's.
#let _is-colour(value) = (
  type(value) == str and value.match(regex("^#([0-9A-Fa-f]{3,4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$")) != none
)

// Colours arrive as strings too, since JSON has no way to spell rgb(). A
// string that is not a colour is reported here rather than inside the renderer.
//
// The scope is the caller's, since a palette belongs to `data-colour` while a
// fill belongs to no public directive at all. `key` names the key the caller
// wrote, which is what tells one colour in a style from another.
#let _colour(value, scope, key) = {
  if type(value) != str { return value }
  if not _is-colour(value) {
    fail(
      scope,
      key + " is not a colour",
      value: value,
      hint: "Write it as a hex string, for example \"#08519c\".",
    )
  }
  rgb(value)
}

#let _selector(value) = if value == none { auto } else { value }

// Alignments are Typst values, so a serialised one arrives as the name it is
// written under. Only the horizontal set: a column has no vertical alignment of
// its own, and the theme carries cell-vertical-align.
#let ALIGNMENTS = (
  "start": start,
  "end": end,
  "center": center,
  "left": left,
  "right": right,
)

// A currency symbol sits at one end of its number, so `format-currency` reads
// two of the five names. The serialised path refuses the other three here rather
// than passing them on, which would report them a second time, under the
// formatter's scope and against a shorter list than the one just offered.
#let POSITIONS = ("start": start, "end": end)

// `key` is the key the caller wrote, since one directive spells this `alignment`
// and a currency option spells it `position`, and the scope names neither.
// `names` is what that key takes, which is not the same set for the two.
#let _alignment(value, scope, key, names: ALIGNMENTS) = {
  if type(value) != str { return value }
  if value not in names {
    fail-enum(scope, key, value, names.keys())
  }
  names.at(value)
}

// A cell places itself on both axes, unlike a column: the renderer takes an
// explicit style's alignment as written, its vertical part included. So a cell
// style reads the vertical names too, and the two axes are written together the
// way Typst writes them, "center + horizon".
#let VERTICAL-ALIGNMENTS = (
  "top": top,
  "horizon": horizon,
  "bottom": bottom,
)

#let _cell-alignment(value) = {
  if type(value) != str { return value }
  let names = value.split("+").map(name => name.trim())
  let known = ALIGNMENTS + VERTICAL-ALIGNMENTS
  for name in names {
    if name not in known { fail-enum("display-table", "align", name, known.keys()) }
  }
  // One name per axis. Two horizontal names are a contradiction rather than a
  // sum, and Typst reports the sum in its own words.
  check(
    names.filter(name => name in ALIGNMENTS).len() <= 1,
    "display-table",
    "align names two horizontal edges",
    value: value,
    hint: "Write one of " + ALIGNMENTS.keys().join(", ") + ", optionally added to a vertical name.",
  )
  check(
    names.filter(name => name in VERTICAL-ALIGNMENTS).len() <= 1,
    "display-table",
    "align names two vertical edges",
    value: value,
    hint: "Write one of " + VERTICAL-ALIGNMENTS.keys().join(", ") + ", optionally added to a horizontal name.",
  )
  names.map(name => known.at(name)).sum()
}

// A width arrives as a string, since JSON has no length type. The number and the
// unit are read apart, so an unknown unit is named rather than parsed into
// silence, and a bare number is refused rather than guessed at.
#let UNITS = (
  "pt": 1pt,
  "mm": 1mm,
  "cm": 1cm,
  "in": 1in,
  "em": 1em,
  "fr": 1fr,
  "%": 1%,
)

// `what` names the thing being measured, since the same reading serves a column
// width, a cell inset and the thickness of a rule, and a message about a width
// sends the reader to the wrong key.
#let _length(value, scope, what: "a width") = {
  if value == none or value == "auto" { return auto }
  if type(value) in (int, float) {
    fail(
      scope,
      what + " needs a unit",
      value: value,
      hint: "Write it as a string, for example \"2cm\" or \"1fr\".",
    )
  }
  if type(value) != str { return value }
  let found = value.trim().match(regex("^(-?[0-9]*\\.?[0-9]+)(pt|mm|cm|in|em|fr|%)$"))
  if found == none {
    fail(
      scope,
      "not " + what,
      value: value,
      hint: "Write a number and one of " + UNITS.keys().join(", ") + ", or \"auto\".",
    )
  }
  float(found.captures.first()) * UNITS.at(found.captures.last())
}

// The sides Typst reads an inset per. Named here so a side the caller invented
// is reported against the ones that exist rather than handed to Typst, which
// reads a key it does not know as no inset at all.
#let INSET-SIDES = ("left", "right", "top", "bottom", "x", "y", "rest")

// An inset is one length, or one per side, and each side is a length.
#let _inset(value) = {
  if type(value) != dictionary { return _length(value, "display-table", what: "an inset") }
  _keys(value, INSET-SIDES, "display-table", subject: "inset")
  let out = (:)
  for (side, length) in value {
    out.insert(side, _length(length, "display-table", what: "an inset"))
  }
  out
}

// A stroke is a colour, a thickness, or a dictionary carrying both and whatever
// else Typst reads: `dash`, `cap`, `join`, `miter-limit`. Written as one string
// it is a colour when it is spelled as one and a thickness otherwise, which are
// the two things a single value can mean.
#let _stroke(value) = {
  if value == none { return none }
  if type(value) == str {
    // `rgb` rather than `_colour`: the string was just read as a colour, so the
    // check `_colour` would run again cannot fail.
    return if _is-colour(value) { rgb(value) } else {
      _length(value, "display-table", what: "a thickness")
    }
  }
  // A bare number is a thickness with no unit, which is refused rather than
  // guessed at, exactly as a bare width is.
  if type(value) in (int, float) { return _length(value, "display-table", what: "a thickness") }
  if type(value) != dictionary { return value }
  let out = value
  if "paint" in out { out.insert("paint", _colour(out.paint, "display-table", "stroke paint")) }
  if "thickness" in out {
    out.insert("thickness", _length(out.thickness, "display-table", what: "a thickness"))
  }
  out
}

// The style properties a cell understands, resolved out of what JSON can write.
// Colours were resolved and everything else was passed through as written, so
// `align`, `inset` and `stroke` had no spelling that worked: the string reached
// the renderer and failed there, as a Typst type error pointing into this
// package rather than as a message naming the key the caller wrote.
#let _properties(given) = {
  let out = (:)
  for (key, value) in given {
    out.insert(
      key,
      if key == "fill" {
        _colour(value, "display-table", "fill")
      } else if key == "align" {
        _cell-alignment(value)
      } else if key == "inset" {
        _inset(value)
      } else if key == "stroke" {
        _stroke(value)
      } else if key == "text" and type(value) == dictionary {
        // The two properties inside `text` that JSON cannot spell: a colour and
        // a length. Everything else Typst reads as written.
        let inner = value
        if "fill" in inner { inner.insert("fill", _colour(inner.fill, "display-table", "text fill")) }
        if "size" in inner {
          inner.insert("size", _length(inner.size, "display-table", what: "a text size"))
        }
        inner
      } else { value },
    )
  }
  out
}

#let FORMAT-OPTIONS = (
  "format-number": (
    "decimals",
    "significant",
    "grouping",
    "group-separator",
    "decimal-separator",
    "scale",
    "sign",
    "rounding",
    "negative-zero",
    "prefix",
    "suffix",
    "infinity",
  ),
  "format-integer": ("grouping", "group-separator", "scale", "sign", "prefix", "suffix"),
  "format-percent": ("decimals", "significant", "scale", "symbol", "space"),
  "format-currency": ("currency", "decimals", "significant", "symbol", "position", "space"),
  "format-scientific": (
    "decimals",
    "exponent",
    "decimal-separator",
    "sign",
    "rounding",
    "negative-zero",
    "infinity",
  ),
  "format-bytes": (
    "base",
    "decimals",
    "grouping",
    "group-separator",
    "decimal-separator",
    "sign",
    "rounding",
    "infinity",
  ),
  "format-date": ("pattern",),
  "format-markup": (),
)

// Options whose Typst value is not a JSON scalar. Everything else passes
// through as written.
#let OPTION-KINDS = (
  "prefix": "content",
  "suffix": "content",
  "symbol": "content",
  "infinity": "content",
  "position": "alignment",
)

#let _format(descriptor) = {
  let builder = _named(FORMATTERS, descriptor, "display-table", subject: "format", what: "formatter")
  _keys(
    descriptor,
    ("name", "columns", "rows") + FORMAT-OPTIONS.at(descriptor.name),
    "display-table",
    subject: "format",
  )
  let options = (:)
  for (key, value) in descriptor {
    if key in ("name", "columns", "rows") { continue }
    let kind = OPTION-KINDS.at(key, default: none)
    options.insert(
      key,
      if kind == "content" { _content(value) } else if kind == "alignment" {
        _alignment(value, "display-table", key, names: POSITIONS)
      } else { value },
    )
  }
  builder(
    _selector(descriptor.at("columns", default: auto)),
    rows: resolve-predicate(_selector(descriptor.at("rows", default: auto))),
    ..options,
  )
}

// The keys a location descriptor may carry, named once: a style and a footnote
// address cells the same way, and two lists would drift.
#let LOCATION-KEYS = ("part", "columns", "rows", "groups", "spanners", "notes", "parts")

#let _location(descriptor) = (
  kind: "location",
  part: descriptor.at("part", default: PARTS.body),
  columns: _selector(descriptor.at("columns", default: auto)),
  rows: resolve-predicate(_selector(descriptor.at("rows", default: auto))),
  groups: _selector(descriptor.at("groups", default: auto)),
  // Spanner labels are content once resolved, so a selector written as a
  // string would never match the label it plainly names.
  spanners: {
    let given = _selector(descriptor.at("spanners", default: auto))
    if given == auto { auto } else if type(given) == array {
      given.map(_content)
    } else { _content(given) }
  },
  notes: _selector(descriptor.at("notes", default: auto)),
  parts: {
    let given = descriptor.at("parts", default: TITLE-PARTS)
    if type(given) == array { given } else { (given,) }
  },
)

#let _style(descriptor) = {
  _keys(descriptor, ("style",) + LOCATION-KEYS, "display-table", subject: "style")
  (
  kind: "style",
  style: _properties(descriptor.at("style", default: (:))),
  locations: _location(descriptor),
  )
}

// `directive` is the public name the key resolves into, which the two summary
// keys do not share: `summaries` gives `summary-rows` and `grand-summaries`
// gives `grand-summary-rows`. It is passed rather than derived from `scope`, so
// the caller that knows which key it is reading is the one that says so.
#let _summary(descriptor, scope, directive) = {
  _keys(descriptor, ("name", "label", "columns", "groups"), directive)
  (
  kind: "summary",
  scope: scope,
  functions: ((descriptor.at("label", default: "Total")): _named(AGGREGATIONS, descriptor, directive)),
  columns: _selector(descriptor.at("columns", default: auto)),
  groups: _selector(descriptor.at("groups", default: auto)),
  format: none,
  )
}

// A combine pattern arrives as a template, because JSON cannot carry a closure.
// Positions count from one in `from` order, which is how a person writing the
// generator would number them.
//
// The returned function takes a sink rather than fixed parameters: Typst
// closures fail on arity mismatch, and the arity here is whatever `from` turned
// out to be.
#let _template(text) = (..parts) => {
  let values = parts.pos()
  let out = []
  let at = 0
  for found in text.matches(regex("\{(\d+)\}")) {
    out += [#text.slice(at, found.start)]
    let position = int(found.captures.first())
    if position < 1 or position > values.len() {
      fail(
        "columns-combine",
        "pattern names source " + str(position),
        value: text,
        hint: "Sources count from 1 in from order, and this combine has " + str(values.len()) + ".",
      )
    }
    out += values.at(position - 1)
    at = found.end
  }
  out + [#text.slice(at)]
}

#let SERIALISED-KEYS = (
  "kind",
  "data",
  "header",
  "stub",
  "row-groups",
  "labels",
  "hidden",
  "combines",
  "moves",
  "spanners",
  "widths",
  "alignments",
  "formats",
  "substitutions",
  "colours",
  "summaries",
  "grand-summaries",
  "styles",
  "footnotes",
  "source-notes",
  "options",
)

// A serialised specification is turned back into ordinary directives and folded
// through the same path as a hand-written table, so the two cannot drift: there
// is one pipeline, entered two ways.
#let resolve-serialised(serialised, build, theme: (:)) = {
  _keys(serialised, SERIALISED-KEYS, "display-table", subject: "the specification")

  let directives = ()

  let header = serialised.at("header", default: (:))
  _keys(header, ("title", "subtitle"), "table-header")
  if header.at("title", default: none) != none or header.at("subtitle", default: none) != none {
    directives.push((
      kind: "header",
      title: _content(header.at("title", default: none)),
      subtitle: _content(header.at("subtitle", default: none)),
    ))
  }

  let stub = serialised.at("stub", default: (:))
  _keys(stub, ("rowname", "group", "label", "indent"), "table-stub")
  if stub.len() > 0 and stub.values().any(value => value != none) {
    directives.push((
      kind: "stub",
      rowname: stub.at("rowname", default: none),
      group: stub.at("group", default: none),
      label: _content(stub.at("label", default: none)),
      indent: stub.at("indent", default: none),
    ))
  }

  for descriptor in serialised.at("row-groups", default: ()) {
    _keys(descriptor, ("label", "rows"), "table-row-group")
    _required(
      descriptor,
      ("label", "rows"),
      "table-row-group",
      "A declared group needs a label and the rows it claims.",
    )
    directives.push((
      kind: "row-group",
      label: _content(descriptor.label),
      rows: resolve-predicate(descriptor.rows),
    ))
  }

  let labels = serialised.at("labels", default: (:))
  if labels.len() > 0 {
    let mapped = (:)
    for (name, label) in labels { mapped.insert(name, _content(label)) }
    directives.push((kind: "labels", labels: mapped))
  }

  let hidden = serialised.at("hidden", default: ())
  let hidden = if type(hidden) == str { (hidden,) } else { hidden }
  if hidden.len() > 0 { directives.push((kind: "hide", columns: hidden)) }

  for descriptor in serialised.at("combines", default: ()) {
    _keys(descriptor, ("into", "from", "pattern", "label", "hide-sources"), "columns-combine")
    _required(
      descriptor,
      ("into", "from", "pattern"),
      "columns-combine",
      "A combine needs the column it builds, the columns it reads, and the pattern joining them.",
    )
    directives.push((
      kind: "combine",
      into: descriptor.into,
      from: descriptor.from,
      pattern: _template(descriptor.pattern),
      label: _content(descriptor.at("label", default: auto)),
      hide-sources: descriptor.at("hide-sources", default: true),
    ))
  }

  for descriptor in serialised.at("moves", default: ()) {
    _keys(descriptor, ("columns", "before", "after"), "columns-move")
    let columns = descriptor.at("columns", default: ())
    directives.push((
      kind: "move",
      columns: if type(columns) == str { (columns,) } else { columns },
      before: descriptor.at("before", default: none),
      after: descriptor.at("after", default: none),
    ))
  }

  for spanner in serialised.at("spanners", default: ()) {
    _keys(spanner, ("label", "columns", "level"), "table-spanner")
    _required(
      spanner,
      ("label", "columns"),
      "table-spanner",
      "A spanner needs a label and the columns it covers.",
    )
    directives.push((
      kind: "spanner",
      label: _content(spanner.label),
      columns: spanner.columns,
      level: spanner.at("level", default: 1),
    ))
  }

  let widths = serialised.at("widths", default: (:))
  if widths.len() > 0 {
    let mapped = (:)
    for (name, given) in widths { mapped.insert(name, _length(given, "columns-width")) }
    directives.push((kind: "width", widths: mapped))
  }

  for descriptor in serialised.at("alignments", default: ()) {
    _keys(descriptor, ("alignment", "columns"), "columns-align")
    if "alignment" not in descriptor {
      fail(
        "columns-align",
        "no alignment named",
        value: descriptor,
        hint: "Name one of " + ALIGNMENTS.keys().join(", ") + ".",
      )
    }
    directives.push((
      kind: "align",
      alignment: _alignment(descriptor.alignment, "columns-align", "alignment"),
      columns: _selector(descriptor.at("columns", default: auto)),
    ))
  }

  for descriptor in serialised.at("formats", default: ()) { directives.push(_format(descriptor)) }

  for descriptor in serialised.at("substitutions", default: ()) {
    // One key, two directives: `test` picks between `substitute-missing` and
    // `substitute-zero`, so there is no single name to report under. The scope
    // is `display-table` and the key opens the problem, as it does for a format,
    // a style and an inset.
    _keys(
      descriptor,
      ("test", "columns", "rows", "replacement"),
      "display-table",
      subject: "substitutions",
    )
    let test = descriptor.at("test", default: "missing")
    if test not in ("missing", "zero") {
      fail-enum("display-table", "substitutions test", test, ("missing", "zero"))
    }
    directives.push((
      kind: "substitute",
      test: test,
      columns: _selector(descriptor.at("columns", default: auto)),
      rows: resolve-predicate(_selector(descriptor.at("rows", default: auto))),
      replacement: _content(descriptor.at("replacement", default: [--])),
    ))
  }

  for descriptor in serialised.at("colours", default: ()) {
    _keys(
      descriptor,
      ("palette", "columns", "rows", "domain", "target", "missing", "reverse"),
      "data-colour",
    )
    if "palette" not in descriptor {
      fail(
        "data-colour",
        "no palette given",
        value: descriptor,
        hint: "Give one hex string, or an array of them for a gradient.",
      )
    }
    // A hex string is the one spelling JSON has for a colour, and `data-colour`
    // hands it to `rgb` as written, so a string that is not one is read here.
    // Left to the renderer it would be reported in Typst's words.
    directives.push((
      kind: "colour",
      palette: {
        let given = descriptor.palette
        let stops = if type(given) == array { given } else { (given,) }
        stops.map(stop => _colour(stop, "data-colour", "palette"))
      },
      columns: _selector(descriptor.at("columns", default: auto)),
      rows: resolve-predicate(_selector(descriptor.at("rows", default: auto))),
      domain: _selector(descriptor.at("domain", default: auto)),
      target: descriptor.at("target", default: "fill"),
      missing: {
        let given = descriptor.at("missing", default: none)
        if given == none { none } else { _colour(given, "data-colour", "missing") }
      },
      reverse: descriptor.at("reverse", default: false),
    ))
  }

  for descriptor in serialised.at("summaries", default: ()) {
    directives.push(_summary(descriptor, "group", "summary-rows"))
  }
  for descriptor in serialised.at("grand-summaries", default: ()) {
    directives.push(_summary(descriptor, "grand", "grand-summary-rows"))
  }

  for descriptor in serialised.at("styles", default: ()) { directives.push(_style(descriptor)) }

  for descriptor in serialised.at("footnotes", default: ()) {
    _keys(descriptor, ("note", "locations", "mark"), "table-footnote")
    if "note" not in descriptor {
      fail(
        "table-footnote",
        "no note given",
        value: descriptor,
        hint: "A footnote needs the text it prints.",
      )
    }
    let given = descriptor.at("locations", default: none)
    directives.push((
      kind: "footnote",
      note: _content(descriptor.note),
      locations: if given == none { none } else if type(given) == array {
        given.map(_location)
      } else { _location(given) },
      mark: {
        let mark = descriptor.at("mark", default: none)
        if mark == none { auto } else { _content(mark) }
      },
    ))
  }

  for note in serialised.at("source-notes", default: ()) {
    directives.push((kind: "source-note", note: _content(note)))
  }

  // The third argument is the theme, not the option set: passing options there
  // silently replaced the theme, so a serialised table drew none of its rules.
  // Options belong on top of whatever theme the caller asked for.
  build(
    serialised.at("data", default: ()),
    directives,
    theme + serialised.at("options", default: (:)),
  )
}
