#import "helpers.typ": *
#import "display.typ": display

#let TableData(
  rows: (),
  field-info: (:),
  tablex-kwargs: (:),
  add-row-fields: false,
  ..unused
) = {
  let types = rows.map(el => type(el)).dedup()
  if types.len() > 0 and types != (dictionary,) {
    panic("Row data must be a list of dictionaries, got types" + repr(types))
  }

  field-info = (__index: (hide: true, type: "index")) + field-info
  rows = rows.enumerate().map(idx_row_pair => {
    let (ii, row) = idx_row_pair
    if "__index" not in row {
      row.insert("__index", ii)
    }
    row
  })
  if add-row-fields {
    for field in unique-row-keys(rows) {
      if field not in field-info {
        field-info.insert(field, (:))
      }
    }
  }

  (
    rows: rows,
    field-info: field-info,
    table: display((rows: rows, field-info: field-info), ..tablex-kwargs),
    tablex-kwargs: tablex-kwargs,
  )

}

#let with-row-fields(td) = {
  TableData(..td, add-row-fields: true)
}

#let table-data-from-columns(..columns-and-metadata) = {
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

#let with-field(td, field, ..info) = {
  let field-dict = (:)
  field-dict.insert(field, info.named())
  td.insert("field-info", td.field-info + field-dict)
  return TableData(..td)
}

#let with-row(td, ..row) = {
  td.rows.push(row.named())
  return TableData(..td)
}

// Using the above functions decorated with `.with()` makes readability pretty
// difficult. This is a workaruond
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
    rows: rows,
    field-info: filtered-dict(field-info, keys: fields),
    tablex-kwargs: td.tablex-kwargs,
  )
}

#let transpose(td, fields-name: none, ignore-types: false) = {
  let (rows, field-info) = (td.rows, td.field-info)
  let indexes = rows.map(row => row.__index)
  let fields = field-info.keys()
  let out-rows = ()
  for field in unique-row-keys(rows).filter(is-external-field) {
    let idx-field-maps = rows.map(row => {
      let out = (:)
      if fields-name != none {
        out.insert(fields-name, field)
      }
      if field in row {
        out.insert(str(row.__index), row.at(field))
      }
      out
    })
    out-rows.push(idx-field-maps.sum())
  }
  let info = (:)
  if fields-name != none {
    info.insert(fields-name, (type: "content"))
  }
  if ignore-types {
    for row in rows {
      info.insert(str(row.__index), (type: "content"))
    }
  }
  TableData(rows: out-rows, field-info: info, tablex-kwargs: td.tablex-kwargs)
}