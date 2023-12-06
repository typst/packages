#import "./tabledata.typ": TableData, with-field
#import "./helpers.typ": is-external-field

// -----------------------------------------
// agg() and friends
// -----------------------------------------
#let _resolve-fields-indexes-axis(fields, indexes, axis) = {
  let (return-single-field, return-single-row) = (false, false)
    if type(fields) == str {
      fields = (fields,)
      return-single-field = true
    }
    if type(indexes) == int {
      indexes = (indexes,)
      return-single-row = true
    }
    if axis == auto {
      axis = if return-single-field {
        0
      } else if return-single-row {
        1
      } else {
        panic("When fields and indexes are array-like, axis must be specified")
      }
    }
    if axis not in (0, 1) {
      panic("axis must be 0 or 1, got " + repr(axis))
    }
    (fields, indexes, axis, return-single-row, return-single-field)
}

#let _call-agg-func(func, values, axis) = {
  let out = ()
  if axis == 0 {
    for ii in range(values.at(0).len()) {
      let arr = values.map(row => row.at(ii))
      out.push(func(arr))
    }
  } else if axis == 1 {
    out = values.map(func)
  } else {
    panic("axis must be 0 or 1, got " + repr(axis))
  }
  out
}

#let _result-to-table-data(values, fields, tablex-kwargs, naming-function, field-info, axis) = {
  let (rows, info) = ((), (:))
  if axis == 0 {
    // Rows were collapsed, add field to each value
    let single-row = (:)
    for (value, field) in values.zip(fields) {
      single-row.insert(field, value)
      // Expressions are already evaluated at this point, and the backing fields
      // may be gone. So remove this information
      let title-info = (:)
      if naming-function != none {
        title-info.insert("title", naming-function(field))
      }
      let this-field-info = field-info.at(field) + title-info
      let _ = this-field-info.remove("expression", default: none)
      info.insert(field, this-field-info)
    }
    rows = (single-row,)
  } else {
    // Columns were collapsed, make a new one from this function name
    values = (values.map(val => {
      let out = (:)
      out.insert(func-name, val)
      out
    }))
    // No field info is valid anymore
    rows = values
  }
  TableData(rows: rows, field-info: info, tablex-kwargs: tablex-kwargs)
}

#let _eval-name-for-agg-field(field, format-str: "", agg-func: none) = {
  eval(
    format-str, scope: (field: field, function: agg-func), mode: "markup"
  )
}


#let agg(
  td, using: none, fields: auto, indexes: auto, axis: auto, title: none, ..args
) = {
  if using == none {
    panic("agg() requires a function to use for aggregation")
  }
  if title == auto {
    title = "#repr(function)\(#field\)"
  }
  let (rows, field-info) = (td.rows, td.field-info)
  let (fields, indexes, axis, _, _) = _resolve-fields-indexes-axis(
    fields, indexes, axis
  )
  if fields == auto {
    fields = field-info.keys().filter(is-external-field)
  }
  if indexes == auto {
    indexes = rows.map(row => row.__index)
  }
  let values = rows.filter(row => row.__index in indexes).map(row => {
    let out = ()
    for field in fields {
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
  _result-to-table-data(values, fields, td.tablex-kwargs, naming-func, field-info, axis)
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


#let collect(td) = {
  let (rows, field-info) = (td.rows, td.field-info)
  let computed-fields = field-info.keys().filter(
    key => "expression" in field-info.at(key)
  )
  let processed-rows = ()
  for row in rows {
    for key in computed-fields {
      let scope = row
      // Populate unspeicified fields with default values
      for (key, info) in field-info.pairs() {
        if key not in row and "default" in info {
          scope.insert(key, info.at("default"))
        }
      }
      let expr = field-info.at(key).at("expression")
      let value = none
      if type(expr) == str {
        let mode = field-info.at(key).at("mode", default: "code")
        value = eval(expr, scope: scope, mode: mode)
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
  td.insert("rows", processed-rows)
  td.insert("field-info", field-info)
  TableData(..td)
}

#let filter(td, axis: 0, expression: none) = {
  let td = collect(with-field(td, "__filter", expression: expression))
  let keep-rows = td.rows.filter(row => row.__filter).map(row => {
    let _ = row.remove("__filter")
    row
  })
  td.insert("rows", keep-rows)
  TableData(..td)
}
