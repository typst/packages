#import "./tabledata.typ": TableData, with-field
#import "./helpers.typ": is-external-field

// -----------------------------------------
// agg() and friends
// -----------------------------------------
#let _call-agg-func(func, values, axis) = {
  let out = ()
  if axis == 0 {
    for ii in range(values.at(0).len()) {
      let arr = values.map(row => row.at(ii)).filter(v => v != none)
      out.push(func(arr))
    }
  } else if axis == 1 {
    out = values.map(arr => arr.filter(v => v != none)).map(func)
  } else {
    panic("axis must be 0 or 1, got " + repr(axis))
  }
  out
}

#let _result-to-table-data(td, values, naming-function, axis) = {
  let (rows, info) = ((), (:))
  if axis == 0 {
    // Rows were collapsed, add field to each value
    let single-row = (:)
    for (value, field) in values.zip(td.field-info.keys()) {
      single-row.insert(field, value)
      let title-info = (:)
      if naming-function != none {
        title-info.insert("title", naming-function(field))
      }
      let this-field-info = td.field-info.at(field) + title-info
      info.insert(field, this-field-info)
    }
    rows = (single-row,)
  } else {
    // Columns were collapsed, make a new one from this function name
    if naming-function == none {
      naming-function = (field) => field
    }
    values = (values.map(val => {
      let out = (:)
      out.insert(naming-function(field), val)
      out
    }))
    // No field info is valid anymore
    rows = values
  }
  TableData(..td, rows: rows, field-info: info)
}

#let _eval-name-for-agg-field(field, format-str: "", agg-func: none) = {
  eval(
    format-str, scope: (field: field, function: agg-func), mode: "markup"
  )
}


#let agg(
  td, using: none, axis: 0, title: none, ..args
) = {
  if using == none {
    panic("`agg()` requires a function to use for aggregation")
  }
  if title == auto {
    title = "#repr(function)\(#field\)"
  }
  let values = td.rows.map(row => {
    let out = ()
    for field in td.field-info.keys() {
      out.push(row.at(field, default: none))
    }
    out
  })
  values = _call-agg-func(using, values, axis)
  let naming-func = title
  if type(naming-func) == str {
    naming-func = _eval-name-for-agg-field.with(
      format-str: title, agg-func: using
    )
  }
  _result-to-table-data(td, values, naming-func, axis)
}


// -----------------------------------------
// misc operations small enough where helper functions are overkill
// -----------------------------------------

#let chain(td, ..operations) = {
  for op in operations.pos() {
    if type(op) == array {
      td = op.at(0)(td, ..op.slice(1))
    } else {
      td = op(td)
    }
  }
  td
}


#let filter(td, expression: none) = {
  let td = with-field(td, "__filter", expression: expression)
  let keep-rows = td.rows.filter(row => row.__filter).map(row => {
    let _ = row.remove("__filter")
    row
  })
  let _ = td.field-info.remove("__filter")
  TableData(..td, rows: keep-rows)
}
