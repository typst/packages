#import "helpers.typ": unique-row-keys, remove-internal-fields, assert-is-type, assert-list-of-type, keep-keys

#import "display.typ": DEFAULT-TYPE-FORMATS

#let _eval-expressions(rows, field-info) = {
  let computed-fields = field-info.keys().filter(
    key => "expression" in field-info.at(key)
  )
  let processed-rows = ()
  for row in rows {
    for key in computed-fields {
      let scope = row
      // Populate unspecified fields with default values
      for (key, info) in field-info.pairs() {
        if key not in row and "default" in info {
          scope.insert(key, info.at("default"))
        }
      }
      let expr = field-info.at(key).at("expression")
      let value = none
      if type(expr) == str {
        value = eval(expr, scope: scope, mode: "code")
      } else {
        assert(
          type(expr) == function,
          message: "expression must be a string or function, got: " + type(expr)
        )
        value = expr(..scope)
      }
      row.insert(key, value)
    }
    processed-rows.push(row)
  }
  // Expressions are now evaluated, discard them so they aren't re-evaluated when
  // constructing a followup table
  for key in computed-fields {
    let _ = field-info.at(key).remove("expression")
  }
  (processed-rows, field-info)
}

#let _infer-field-type(field, rows) = {
  if rows.len() == 0 {
    panic("Can't infer type of field " + repr(field) + " from empty table")
  }
  let values = rows.filter(row => field in row).map(row => row.at(field))
  let types = values.map(value => type(value)).dedup()
  if types.len() > 1 {
    panic("Field " + repr(field) + " has multiple types: " + repr(types))
  }
  repr(types.at(0))
}

#let _resolve-field-info(field-info, field-defaults, type-info, rows) = {
  // Add required, internal fields
  field-info = (__index: (hide: true, type: "index")) + field-info

  // Add fields that only appear in rows, but weren't specified by the user otherwise
  for field in unique-row-keys(rows) {
    if field not in field-info {
      field-info.insert(field, (:))
    }
  }

  // Now that we have the comprehensive field list, add default properties that aren't
  // specified, and properties attached to the type
  for (field, existing-info) in field-info {
    let type-str = existing-info.at("type", default: field-defaults.at("type", default: auto))
    if type-str == auto {
      type-str = _infer-field-type(field, rows)
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
  field-info
}

#let _validate-td-args(rows, field-info, type-info, field-defaults, tablex-kwargs) = {
  assert-is-type(rows, array, "rows")
  assert-list-of-type(rows, dictionary, "rows")

  assert-is-type(field-info, dictionary, "field-info")
  assert-list-of-type(field-info, dictionary, "field-info")

  assert-is-type(type-info, dictionary, "type-info")
  assert-list-of-type(type-info, dictionary, "type-info")

  assert-is-type(field-defaults, dictionary, "field-defaults")
  assert-is-type(tablex-kwargs, dictionary, "tablex-kwargs")

}


#let TableData(
  rows: (),
  field-info: (:),
  type-info: (:),
  field-defaults: (:),
  tablex-kwargs: (:),
  ..unused
) = {
  _validate-td-args(rows, field-info, type-info, field-defaults, tablex-kwargs)

  rows = rows.enumerate().map(idx_row_pair => {
    let (ii, row) = idx_row_pair
    if "__index" not in row {
      row.insert("__index", ii)
    }
    row
  })

  (rows, field-info) = _eval-expressions(rows, field-info)
  field-info = _resolve-field-info(field-info, field-defaults, type-info, rows)
  
  (
    rows: rows,
    field-info: field-info,
    type-info: type-info,
    field-defaults: field-defaults,
    tablex-kwargs: tablex-kwargs,
  )
}

#let from-columns(..columns-and-metadata) = {
  let (columns, meta) = (columns-and-metadata.pos().at(0), columns-and-metadata.named())
  let lengths = columns.values().map(col => col.len())
  assert(
    lengths.dedup().len() == 1,
    message: "Columns must have at least one element and be the same length,"
      + " got lengths: " + repr(lengths),
  )
  let rows = range(lengths.at(0)).map(ii => {
    let row = (:)
    for (key, col) in columns.pairs() {
      row.insert(key, col.at(ii))
    }
    row
  })
  TableData(rows: rows, ..meta)
}

#let values(td) = {
  remove-internal-fields(td.rows).map(row => row.values())
}

#let item(td) = {
  let raw-values = values(td)
  if raw-values.map(row => row.len()).sum() != 1 {
    panic(
      "TableData must have exactly one value to call .item(), got: " + repr(raw-values)
    )
  }
  raw-values.at(0).at(0)
}

#let with-field(td, field, preserve-existing: true, ..info) = {
  let to-insert = info.named()
  if preserve-existing {
     to-insert = td.field-info.at(field, default: (:)) + to-insert
  }
  let field-dict = (:)
  field-dict.insert(field, to-insert)
  td.insert("field-info", td.field-info + field-dict)
  return TableData(..td)
}

#let with-row(td, ..row) = {
  td.rows.push(row.named())
  return TableData(..td)
}

// Using the above functions decorated with `.with()` makes readability pretty
// difficult. This is a workaround
#let concat(td, row: none, field: none, ..field-info) = {
  if row != none {
    td = with-row(td, row)
  }
  if field != none {
    td = with-field(td, field, ..field-info)
  }
  return td
}

#let subset(td, indexes: auto, fields: auto) = {
  let (rows, field-info) = (td.rows, td.field-info)
  
  if fields == auto {
    fields = field-info.keys()
  }
  if indexes == auto {
    indexes = range(rows.len())
  }
  if type(indexes) == int {
    indexes = (indexes,)
  }
  if type(fields) == str {
    fields = (fields,)
  }
  let rows = rows.filter(row => row.__index in indexes).map(row => {
    let out = (:)
    for field in fields.filter(field => field in row) {
      out.insert(field, row.at(field))
    }
    out
  })
  return TableData(
    ..td,
    rows: rows,
    field-info: keep-keys(field-info, keys: fields),
  )
}

#let transpose(td, fields-name: none, ignore-types: false) = {
  let (rows, field-info) = (td.rows, td.field-info)
  let indexes = rows.map(row => row.__index)
  let fields = field-info.keys()
  let out-rows = ()
  for field in fields {
    if field == "__index" {
      continue
    }
    let out-row = (:)
    for row in rows {
      if field in row {
        out-row.insert(str(row.__index), row.at(field))
      }
    }
    if fields-name != none {
      out-row.insert(fields-name, field)
    }
    out-rows.push(out-row)
  }
  let info = (:)
  if fields-name != none {
    info.insert(fields-name, (type: "content"))
  }
  for row in rows {
    let type-data = (:)
    if ignore-types {
      type-data = (type: "content")
    }
    info.insert(str(row.__index), type-data)
  }
  // None of the initial kwargs make sense: types, display info, etc.
  // since the transposed table has no relation to the original.
  // Therefore, don't forward old `td` info
  TableData(rows: out-rows, field-info: info)
}