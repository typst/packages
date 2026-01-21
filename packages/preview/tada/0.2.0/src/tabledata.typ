#import "helpers.typ" as H
#import "display.typ": DEFAULT-TYPE-FORMATS


#let _get-n-rows(data) = {
  if data.values().len() == 0 { 0 } else { data.values().at(0).len() }
}

#let _data-to-records(data) = {
  let values = data.values()
  let records = range(_get-n-rows(data)).map(ii => {
    let row-values = values.map(arr => arr.at(ii))
    H.dict-from-pairs(data.keys().zip(row-values))
  })
  records
}

#let _eval-expressions(data, field-info) = {
  let computed-fields = field-info.keys().filter(key => "expression" in field-info.at(key))
  if computed-fields.len() == 0 {
    return (data, field-info)
  }

  // new data = (a: (), b: (), ...)
  // new values will be pushed to each array as they are computed
  let out-data = data + H.default-dict(computed-fields, value: ())
  let records = _data-to-records(data)
  for row in records {
    for key in computed-fields {
      let scope = row
      // Populate unspecified fields with default values
      for (key, info) in field-info.pairs() {
        if key not in row and "default" in info {
          scope.insert(key, info.at("default"))
        }
      }
      let expr = field-info.at(key).at("expression")
      let default-scope = field-info.at(key).at("scope", default: (:))
      let value = H.eval-str-or-function(
        expr,
        scope: default-scope + scope,
        mode: "code",
        keyword: scope,
      )
      out-data.at(key).push(value)
      // In case this field is referenced by another expression
      row.insert(key, value)
    }
  }
  // Expressions are now evaluated, discard them so they aren't re-evaluated when
  // constructing a followup table
  for key in computed-fields {
    let _ = field-info.at(key).remove("expression")
  }
  (out-data, field-info)
}

#let _infer-field-type(field, values) = {
  if values.len() == 0 {
    return "content"
  }
  let types = values.map(value => type(value)).dedup()
  if types.len() > 1 and type(none) in types {
    types = types.filter(typ => typ != type(none))
  }
  if types.len() > 1 {
    panic("Field `" + field + "` has multiple types: " + repr(types))
  }
  repr(types.at(0))
}

#let _resolve-field-info(field-info, field-defaults, type-info, data) = {
  // Add required, internal fields
  field-info = (__index: (hide: true, type: "index")) + field-info

  // Add fields that only appear in data, but weren't specified by the user otherwise
  for field in data.keys() {
    if field not in field-info {
      field-info.insert(field, (:))
    }
  }

  // Now that we have the comprehensive field list, add default properties that aren't
  // specified, and properties attached to the type
  for (field, existing-info) in field-info {
    // Take any "values" passed and give them directly to data
    if "values" in existing-info {
      data.insert(field, existing-info.remove("values"))
    }
    let type-str = existing-info.at("type", default: field-defaults.at("type", default: auto))
    if type-str == auto {
      type-str = _infer-field-type(field, data.at(field))
    }
    let type-info = DEFAULT-TYPE-FORMATS + type-info
    let defaults-for-field = field-defaults + type-info.at(type-str, default: (:))
    for key in defaults-for-field.keys() {
      if key not in existing-info {
        existing-info.insert(key, defaults-for-field.at(key))
      }
    }
    field-info.insert(field, existing-info)
  }

  // Not allowed to have any fields not in the data
  let extra-fields = field-info.keys().filter(key => key not in data)
  if extra-fields.len() > 0 {
    panic("`field-info` contained fields not in data: " + repr(extra-fields))
  }
  (field-info, data)
}

#let _validate-td-args(data, field-info, type-info, field-defaults, table-kwargs) = {
  // dict of lists
  // (field: (a, b, c), field2: (5, 10, 15), ...)
  H.assert-is-type(data, dictionary, "data")
  H.assert-rectangular-matrix(data.values())

  // dict of dicts
  // (field: (type: "integer"), field2: (display: "#text(red, value)"), ...)
  H.assert-list-of-type(field-info, dictionary, "field-info")

  // dict of dicts
  // (currency: (display: format-usd), percent: (display: format-percent), ...)
  H.assert-is-type(type-info, dictionary, "type-info")
  H.assert-list-of-type(type-info, dictionary, "type-info")

  // dict of values
  // (type: integer, title: #field-title-case, ...)
  H.assert-is-type(field-defaults, dictionary, "field-defaults")
  // dict of values
  // (auto-vlines: false, map-rows: () => {}, ...)
  H.assert-is-type(table-kwargs, dictionary, "table-kwargs")
}

/// Constructs a @TableData object from a dictionary of columnar data. See examples in
/// the overview above for metadata examples.
/// -> TableData
#let TableData(
  /// A dictionary of arrays, each representing a column of data. Every column must have
  /// the same length. Missing values are represented by `none`.
  /// -> dictionary
  data: none,
  /// A dictionary of dictionaries, each representing the properties of a field. The keys
  /// of the outer dictionary must match the keys of `data`. The keys of the inner
  /// dictionaries are all optional and can contain:
  /// A dictionary of dictionaries, each representing the properties of a field. The keys
  /// of the outer dictionary must match the keys of `data`. The keys of the inner
  /// dictionaries are all optional and can contain:
  /// - `type` (string): The type of the field. Must be one of the keys of `type-info`.
  ///   Defaults to `auto`, which will attempt to infer the type from the data.
  /// - `title` (string): The title of the field. Defaults to the field name, title-cased.
  /// - `display` (string): The display format of the field. Defaults to the display format
  ///   for the field's type.
  /// - `expression` (string, function): A string or function containing a Python expression that will be evaluated
  ///   for each row to compute the value of the field. The expression can reference any
  ///   other field in the table by name.
  /// - `hide` (boolean): Whether to hide the field from the table. Defaults to `false`.
  /// -> dictionary
  field-info: (:),
  /// A dictionary of dictionaries, each representing the properties of a type. These
  /// properties will be populated for a field if its type is given in `field-info` and the
  /// property is not specified already.
  /// -> dictionary
  type-info: (:),
  /// Default values for every field if not specified in `field-info`.
  /// -> dictionary
  field-defaults: (:),
  /// Keyword arguments to pass to `table()`. -> dictionary
  table-kwargs: (:),
  /// Reserved for future use; currently discarded.
  ..reserved,
) = {
  if reserved.pos().len() > 0 {
    panic("TableData() doesn't accept positional arguments")
  }
  _validate-td-args(data, field-info, type-info, field-defaults, table-kwargs)
  let n-rows = _get-n-rows(data)
  let initial-index = data.at("__index", default: range(_get-n-rows(data)))
  let index = initial-index
    .enumerate()
    .map(idx-val => {
      let (ii, value) = idx-val
      if value == none {
        value = ii
      }
      value
    })
  // Preserve ordering if the user specified an index, otherwise put at the front
  if "__index" in data {
    data.__index = index
  } else {
    data = (__index: index, ..data)
  }

  (data, field-info) = _eval-expressions(data, field-info)
  (field-info, data) = _resolve-field-info(field-info, field-defaults, type-info, data)

  (
    data: data,
    field-info: field-info,
    type-info: type-info,
    field-defaults: field-defaults,
    table-kwargs: table-kwargs,
  )
}

#let _resolve-row-col-ctor-field-info(field-info, n-columns) = {
  if field-info == auto {
    field-info = range(n-columns).map(str)
  }
  if type(field-info) == array {
    H.assert-list-of-type(field-info, str, "field-info")
    field-info = H.default-dict(field-info, value: (:))
  }
  return field-info
}

/// Constructs a @TableData object from a list of column-oriented data and their field info.
///
/// ```example
/// #let data = (
///   (1, 2, 3),
///   (4, 5, 6),
/// )
/// #let mk-tbl(..args) = to-table(from-columns(..args))
/// #set align(center)
/// #grid(columns: 2, column-gutter: 1em)[
///   Auto names:
///   #mk-tbl(data)
/// ][
///   User names:
///   #mk-tbl(data, field-info: ("a", "b"))
/// ]
/// ```
/// -> TableData
#let from-columns(
  /// A list of arrays, each representing a column of data. Every column must have the
  /// same length and columns.len() must match field-info.keys().len()
  /// -> array
  columns,
  /// See the `field-info` argument to @TableData for handling dictionary types. If an
  /// array is passed, it is converted to a dictionary of (key1: (:), ...).
  /// -> dictionary
  field-info: auto,
  /// Forwarded directly to @TableData -> dictionary
  ..metadata,
) = {
  if metadata.pos().len() > 0 {
    panic("from-columns() only accepts one positional argument")
  }
  field-info = _resolve-row-col-ctor-field-info(field-info, columns.len())
  if field-info.keys().len() != columns.len() {
    panic(
      "When creating a TableData from rows or columns, the number of fields must match "
        + "the number of columns, got: "
        + repr(field-info.keys())
        + " fields and "
        + repr(columns.len())
        + " columns",
    )
  }
  let data = H.dict-from-pairs(field-info.keys().zip(columns))
  TableData(data: data, field-info: field-info, ..metadata)
}

/// Constructs a @TableData object from a list of row-oriented data and their field info.
///
/// ```example
/// #let data = (
///   (1, 2, 3),
///   (4, 5, 6),
/// )
/// #to-table(from-rows(data, field-info: ("a", "b", "c")))
/// ```
/// -> TableData
#let from-rows(
  /// A list of arrays, each representing a row of data. Every row must have the same
  /// length and rows.at(0).len() must match field-info.keys().len()
  /// -> array
  rows,
  /// See the `field-info` to @from-columns() -> dictionary
  field-info: auto,
  /// Forwarded directly to @TableData -> dictionary
  ..metadata,
) = {
  from-columns(H.transpose-values(rows), field-info: field-info, ..metadata)
}


/// Constructs a @TableData object from a list of records.
///
/// A record is a dictionary of key-value pairs, Records may contain different keys, in
/// which case the resulting @TableData will contain the union of all keys present with
/// `none` values for missing keys.
///
/// ```example
/// #let records = (
///   (a: 1, b: 2),
///   (a: 3, c: 4),
/// )
/// #to-table(from-records(records))
/// ```
/// -> TableData
#let from-records(
  /// A list of dictionaries, each representing a record. Every record must have the same
  /// keys.
  /// -> array
  records,
  /// Forwarded directly to @TableData -> dictionary
  ..metadata,
) = {
  H.assert-is-type(records, array, "records")
  H.assert-list-of-type(records, dictionary, "records")
  let encountered-keys = H.unique-record-keys(records)
  let data = H.default-dict(encountered-keys, value: ())
  for record in records {
    for key in encountered-keys {
      data.at(key).push(record.at(key, default: none))
    }
  }
  TableData(data: data, ..metadata)
}

/// Extracts a single value from a @TableData that has exactly one field and one row.
///
/// ```example
/// #let td = TableData(data: (a: (1,)))
/// #item(td)
/// ```
/// -> any
#let item(
  /// The table to extract a value from -> TableData
  td,
) = {
  let filtered = H.remove-internal-fields(td.data)
  if filtered.keys().len() != 1 {
    panic("TableData must have exactly one field to call .item(), got: " + repr(td.data.keys()))
  }
  let values = filtered.values().at(0)
  if values.len() != 1 {
    panic("TableData must have exactly one row to call .item(), got: " + repr(values.len()))
  }
  values.at(0)
}

/// Creates a new @TableData with only the specified fields and/or indexes.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2), b: (3, 4), c: (5, 6)))
/// #to-table(subset(td, fields: ("a", "c"), indexes: (0,)))
/// ```
/// -> TableData
#let subset(
  /// The table to subset -> TableData
  td,
  /// The field or fields to keep. If `auto`, all fields are kept -> array | str | auto
  indexes: auto,
  /// The index or indexes to keep. If `auto`, all indexes are kept -> array | int | auto
  fields: auto,
) = {
  let (data, field-info) = (td.data, td.field-info)
  if type(indexes) == int {
    indexes = (indexes,)
  }
  if type(fields) == str {
    fields = (fields,)
  }
  // "__index" may be removed below, so save a copy for index filtering if needed
  let index = data.__index
  if fields != auto {
    data = H.keep-keys(data, keys: fields)
    field-info = H.keep-keys(field-info, keys: fields)
  }
  if indexes != auto {
    let keep-mask = index.map(ii => ii in indexes)
    let out = (:)
    for (field, values) in data {
      out.insert(field, values.zip(keep-mask).filter(pair => pair.at(1)).map(pair => pair.at(0)))
    }
    data = out
  }
  return TableData(..td, data: data, field-info: field-info)
}

/// Similar to @subset, but drops the specified fields and/or indexes instead of
/// keeping them.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2), b: (3, 4), c: (5, 6)))
/// #to-table(drop(td, fields: ("a", "c"), indexes: (0,)))
/// ```
/// -> TableData
#let drop(
  /// The table to drop fields from -> TableData
  td,
  /// The field or fields to drop. If `auto`, no fields are dropped -> array | str | auto
  fields: none,
  /// The index or indexes to drop. If `auto`, no indexes are dropped -> array | int | auto
  indexes: none,
) = {
  let keep-keys = auto
  if fields != none {
    if type(fields) == str {
      fields = (fields,)
    }
    keep-keys = td.data.keys().filter(key => key not in fields)
  }
  let keep-indexes = auto
  if indexes != none {
    if type(indexes) == int {
      indexes = (indexes,)
    }
    keep-indexes = td.data.__index.filter(ii => ii not in indexes)
  }
  subset(td, fields: keep-keys, indexes: keep-indexes)
}

/// Converts rows into columns, discards field info, and uses `__index` as the new fields.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2), b: (3, 4), c: (5, 6)))
/// #to-table(transpose(td))
/// ```
/// -> TableData
#let transpose(
  /// - td (TableData): The table to transpose
  td,
  /// The name of the field containing the new field names. If `none`, the new fields
  /// are named `0`, `1`, etc.
  /// -> str | none
  fields-name: none,
  /// Whether to ignore the types of the original table and instead use `content` for
  /// all fields. This is useful when not all columns have the same type, since a warning
  /// will occur when multiple types are encountered in the same field otherwise.
  /// -> bool
  ignore-types: false,
  /// Forwarded directly to @TableData -> dictionary
  ..metadata,
) = {
  let new-keys = td.data.at("__index").map(str)
  let filtered = H.remove-internal-fields(td.data)
  let new-values = H.transpose-values(filtered.values())
  let data = H.dict-from-pairs(new-keys.zip(new-values))
  let info = (:)
  if ignore-types {
    info = H.default-dict(data.keys(), value: (type: "content"))
  }
  if fields-name != none {
    let (new-data, new-info) = ((:), (:))
    new-data.insert(fields-name, filtered.keys())
    new-info.insert(fields-name, (:))
    data = new-data + data
    info = new-info + info
  }
  // None of the initial kwargs make sense: types, display info, etc.
  // since the transposed table has no relation to the original.
  // Therefore, don't forward old `td` info
  TableData(data: data, field-info: info, ..metadata)
}

#let _ensure-a-data-has-b-fields(td-a, td-b, a-name, b-name, missing-fill) = {
  let (a, b) = (td-a.data, td-b.data)
  let missing-fields = b.keys().filter(key => key not in a)
  if missing-fields.len() > 0 and missing-fill == auto {
    panic(
      "No fill value was specified, yet `"
        + a-name
        + "` contains fields not in `"
        + b-name
        + "`: "
        + repr(missing-fields),
    )
  }
  let fill-arr = (missing-fill,) * _get-n-rows(a)
  a = a + H.default-dict(missing-fields, value: fill-arr)
  a
}

#let _merge-infos(a, b, exclude: ("data",)) = {
  let merged = H.merge-nested-dicts(a, b)
  for key in exclude {
    let _ = merged.remove(key, default: none)
  }
  merged
}

#let _stack-rows(td, other, missing-fill: auto) = {
  let data = _ensure-a-data-has-b-fields(td, other, "td", "other", missing-fill)
  let other-data = _ensure-a-data-has-b-fields(other, td, "other", "td", missing-fill)
  // TODO: allow customizing how metadata gets merged. For now, `other` wins but keep
  // both
  let merged-info = _merge-infos(td, other)

  let merged-data = (:)
  for key in data.keys() {
    merged-data.insert(key, data.at(key) + other-data.at(key))
  }
  TableData(data: merged-data, ..merged-info)
}

#let _ensure-a-has-at-least-b-rows(td-a, td-b, a-name, b-name, missing-fill: auto) = {
  let (a, b) = (td-a.data, td-b.data)
  let (a-rows, b-rows) = (_get-n-rows(a), _get-n-rows(b))
  if _get-n-rows(a) < _get-n-rows(b) {
    panic(
      "No fill value was specified, yet `"
        + a-name
        + "` has fewer rows than `"
        + b-name
        + "`: "
        + repr(a-rows)
        + " vs "
        + repr(b-rows),
    )
  }
  let pad-arr = (missing-fill,) * (b-rows - a-rows)
  for key in a.keys() {
    a.insert(key, a.at(key) + pad-arr)
  }
  a
}

#let _stack-columns(td, other, missing-fill: auto) = {
  other.data = H.remove-internal-fields(other.data)
  let overlapping-fields = td.data.keys().filter(key => key in other.data)
  if overlapping-fields.len() > 0 {
    panic(
      "Can't stack `td` and `other` column-wise because they have overlapping fields: "
        + repr(overlapping-fields)
        + ". Either remove or rename these fields before stacking.",
    )
  }
  let data = _ensure-a-has-at-least-b-rows(td, other, "td", "other", missing-fill: missing-fill)
  let other-data = _ensure-a-has-at-least-b-rows(other, td, "other", "td", missing-fill: missing-fill)
  let merged-data = data + other-data

  let merged-info = _merge-infos(td, other)
  TableData(data: merged-data, ..merged-info)
}

/// Stacks two tables on top of or next to each other.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2), b: (3, 4)))
/// #let other = TableData(data: (c: (7, 8), d: (9, 10)))
/// #grid(columns: 2, column-gutter: 1em)[
///   #to-table(stack(td, other, axis: 1))
/// ][
///   #to-table(stack(
///     td, other, axis: 0, missing-fill: -4
///   ))
/// ]
/// ```
///
/// - td (TableData): The table to stack on
/// - other (TableData): The table to stack
/// - axis (int): The axis to stack on. 0 will place `other` below `td`, 1 will place
///   `other` to the right of `td`. If `missing-fill` is not specified, either the
///   number of rows or fields must match exactly along the chosen axis.
///   - #text(red)[*Note*!] If `axis` is 1, `other` may not have any field names that are
///     already in `td`.
/// - missing-fill (any): The value to use for missing fields or rows. If `auto`, an
///   error will be raised if the number of rows or fields don't match exactly along the
///   chosen axis.
/// -> TableData
#let stack(td, other, axis: 0, missing-fill: auto) = {
  if axis == 0 {
    _stack-rows(td, other, missing-fill: missing-fill)
  } else if axis == 1 {
    _stack-columns(td, other, missing-fill: missing-fill)
  } else {
    panic("Invalid axis: " + repr(axis))
  }
}

#let update-fields(td, replace: false, ..field-info) = {
  let field-info = field-info.named()
  if not replace {
    field-info = H.merge-nested-dicts(td.field-info, field-info)
  }
  TableData(..td, field-info: field-info)
}

/// Shorthand to easily compute expressions on a table.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2, 3)))
/// #to-table(add-expressions(td, b: `a + 1`))
/// ```
#let add-expressions(
  /// The table to add expressions to -> TableData
  td,
  /// An array of expressions to compute.
  /// - Positional arguments are converted to (`value`: (expression: `value`))
  /// - Named arguments are converted to (`key`: (expression: `value`))
  /// -> any
  ..expressions,
) = {
  let info = (:)
  for expr in expressions.pos() {
    info.insert(expr, (expression: expr))
  }
  for (field, expr) in expressions.named() {
    info.insert(field, (expression: expr))
  }
  update-fields(td, ..info)
}

/// Returns a @TableData with a single `count` column and one value -- the number of
/// rows in the table.
///
/// ```example
/// #let td = TableData(data: (a: (1, 2, 3), b: (3, 4, none)))
/// #to-table(count(td))
/// ```
/// -> TableData
#let count(
  /// The table to count -> TableData
  td,
) = {
  TableData(
    ..td,
    data: (count: (_get-n-rows(td.data),)),
    // Erase field info, but types and defaults are still, valid
    field-info: (:),
  )
}
