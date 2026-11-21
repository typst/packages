///! Group and grand summary rows.
///!
///! An aggregation is any `values => value`, so the built-ins below and a
///! bespoke closure are interchangeable. They run on raw values, before the
///! format stage, which is what lets a summary cell format through the same
///! path as the body cells above it.

#import "../data.typ": column
#import "../format/apply.typ": matches-column, matches-label, nanoplot-columns
#import "../format/number.typ": to-decimal
#import "../utils/errors.typ": check
#import "substitutions.typ": is-missing

// Gaps are skipped rather than poisoning the result: a column with one missing
// reading still has a mean. Values arrive through the same door the formatters
// use, so a column of numeric strings aggregates as readily as it formats.
#let _numbers(values) = values.map(to-decimal).filter(value => value != none)

// Division and roots leave the decimal world, so the conversion happens at the
// point of arithmetic rather than on the way in: sum, min, and max stay exact.
#let _floats(values) = _numbers(values).map(float)

#let aggregate-sum(values) = {
  let numbers = _numbers(values)
  if numbers.len() == 0 { return none }
  numbers.sum()
}

// Every value that is present, of whatever type: a column of names has a count.
#let aggregate-count(values) = values.filter(value => not is-missing(value)).len()

#let aggregate-mean(values) = {
  let numbers = _floats(values)
  if numbers.len() == 0 { return none }
  numbers.sum() / numbers.len()
}

#let aggregate-min(values) = {
  let numbers = _numbers(values)
  if numbers.len() == 0 { return none }
  calc.min(..numbers)
}

#let aggregate-max(values) = {
  let numbers = _numbers(values)
  if numbers.len() == 0 { return none }
  calc.max(..numbers)
}

// Linear interpolation between order statistics, which is R's type 7 default;
// stated here because the nine competing definitions disagree.
#let aggregate-quantile(probability) = values => {
  check(
    probability >= 0 and probability <= 1,
    "aggregate-quantile",
    "probability must lie between 0 and 1",
    value: probability,
  )
  let numbers = _floats(values).sorted()
  if numbers.len() == 0 { return none }
  if numbers.len() == 1 { return numbers.first() }
  let position = probability * (numbers.len() - 1)
  let lower = int(calc.floor(position))
  let upper = int(calc.ceil(position))
  if lower == upper { return numbers.at(lower) }
  numbers.at(lower) + (position - lower) * (numbers.at(upper) - numbers.at(lower))
}

#let aggregate-median = aggregate-quantile(0.5)

// The sample definition, with n - 1 in the denominator.
#let aggregate-standard-deviation(values) = {
  let numbers = _floats(values)
  if numbers.len() < 2 { return none }
  let mean = numbers.sum() / numbers.len()
  calc.sqrt(numbers.map(value => calc.pow(value - mean, 2)).sum() / (numbers.len() - 1))
}

// `functions` is named rather than positional so the call reads as what it is,
// a dictionary of label to aggregation: summary-rows(functions: (Total: sum)).
#let summary-rows(functions: (:), columns: auto, groups: auto, format: none) = (
  kind: "summary",
  scope: "group",
  functions: functions,
  columns: columns,
  groups: groups,
  format: format,
)

#let grand-summary-rows(functions: (:), columns: auto, format: none) = (
  kind: "summary",
  scope: "grand",
  functions: functions,
  columns: columns,
  groups: auto,
  format: format,
)

// The label of each row a set of summary directives produces, in the order they
// are produced. The row plan counts these and the location DSL names them, so
// both must read the same order as `_rows-for` below: directive order, then the
// order the functions were written in.
#let summary-labels(directives) = directives.map(directive => directive.functions.keys()).flatten()

// How many rows a set of summary directives produces: one per named function.
#let summary-count(directives) = summary-labels(directives).len()

// Directives that apply to one group, so a groups selector actually narrows the
// rows it produces.
//
// The location DSL reads a group selector through the same matcher, which is
// what makes a summary row and a style addressing it mean one group. They were
// spelled separately and drifted.
#let directives-for(directives, label) = {
  directives.filter(directive => matches-label(directive.groups, label))
}

// One entry per summary row: its label and the aggregated value per column.
// Columns holding a value no aggregation can carry, with the first row that
// does. Every aggregation works in `decimal`, which has no infinity, so an
// infinite reading is dropped on the way in: the total printed under it would
// be the total of the other rows, claiming to be the total of the column.
#let infinite-columns(rows, columns) = {
  columns
    .map(name => (
      name: name,
      row: rows.position(row => row.at(name, default: none) in (float.inf, -float.inf)),
    ))
    .filter(entry => entry.row != none)
}

#let _rows-for(directives, rows, columns) = {
  directives
    .map(directive => directive.functions
      .pairs()
      .map(((label, aggregate)) => (
        label: label,
        format: directive.format,
        values: {
          let out = (:)
          for name in columns.filter(name => matches-column(directive.columns, name)) {
            out.insert(name, aggregate(column(rows, name)))
          }
          out
        },
      )))
    .flatten()
}

// Summaries per group, in group order, and then for the body as a whole.
//
// Nanoplot and combined columns are left out of every summary: a series of
// readings has no total, and a combined column holds content built from columns
// that are no longer shown. A column holding an infinity is left out for the
// same reason, since no aggregation can carry one. Naming any of them explicitly
// is refused when the spec is validated; this is what makes `columns: auto` skip
// them quietly.
#let summary-values(spec) = {
  let skip = (
    nanoplot-columns(spec.formats, spec.columns)
      + spec.combines.map(directive => directive.into)
      + infinite-columns(spec.data, spec.columns).map(entry => entry.name)
  )
  let columns = spec.columns.filter(name => name not in skip)
  let groups = spec.groups.map(group => _rows-for(
    directives-for(spec.summaries, group.label),
    group.rows.map(position => spec.data.at(position)),
    columns,
  ))
  (
    groups: groups,
    grand: _rows-for(spec.grand-summaries, spec.data, columns),
  )
}
