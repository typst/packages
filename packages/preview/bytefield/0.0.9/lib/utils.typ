#import "asserts.typ": *

// insert a value into an dict and return the dict
#let dict-insert-and-return(dict, key, value) = {
  assert.eq(type(dict), dictionary);
  assert.eq(type(key), str);
  dict.insert(key,value);
  return dict
}

#let get-field-type(field) = {
  assert-bf-field(field);
  return field.at("field-type", default: none);
}

/// Check if a given field is a bf-field
#let is-bf-field(field) = {
  assert.eq(type(field), dictionary)
  field.at("bf-type", default: none) == "bf-field"
}

/// Check if a given field is a data-field
#let is-data-field(field) = {
  assert-bf-field(field);
  field.at("field-type", default: none) == "data-field"
}

/// Check if a given field is a note-field
#let is-note-field(field) = {
  assert-bf-field(field);
  field.at("field-type", default: none) == "note-field"
}

/// Check if a given field is a header-field
#let is-header-field(field) = {
  assert-bf-field(field);
  field.at("field-type", default: none) == "header-field"
}

/// Return the index of the next data-field
#let get-index-of-next-data-field(idx, fields) = {
  let res = fields.sorted(key: f => f.field-index).find(f => f.field-index > idx and is-data-field(f))
  if res != none { res.field-index } else { none }
}

/// Check if a field spans over multiple rows
#let is-multirow(field, bpr) = {
  // if range.start is at the beginn of a new row
  if (calc.rem(field.data.range.start, bpr) != 0) { return false }
  // field size is multiple of bpr
  if (calc.rem(field.data.size, bpr) != 0) { return false }
  
  return true
}

/// calculates the max annotation level for both sides
#let get-max-annotation-levels(annotations) = {
  let left_max_level = -1
  let right_max_level = -1
  for field in annotations {
    assert-bf-field(field)
    let (side, level, ..) = field.data;
    if (side == left) {
      left_max_level = calc.max(left_max_level,level)
    } else {
      right_max_level = calc.max(right_max_level,level)
    }
  }
  return (
    pre-levels: left_max_level +1,
    post-levels:  right_max_level +1,
  )
}

/// Check if given dict is a bf-cell
#let is-bf-cell(cell) = {
  cell.at("bf-type", default: none) == "bf-cell"
}

/// Check if bf-cell is a data cell.
#let is-data-cell(cell) = {
  cell.at("cell-type", default: none) == "data-cell" 
}

/// Check if bf-cell is a note cell.
#let is-note-cell(cell) = {
  cell.at("cell-type", default: none) == "note-cell" 
}

/// Check if bf-cell is a header cell.
#let is-header-cell(cell) = {
  cell.at("cell-type", default: none) == "header-cell" 
}

/// Check if a string is empty
#let is-empty(string) = {
  assert.eq(type(string), str, message: "expected string, found " + type(string))
  string == none or string == ""
}

/// Check if a string or content is not empty
#let is-not-empty(string) = {
  // assert.eq(type(string), str, message: strfmt("expected string, found {}",type(string)))
  if (type(string) == str) {
    return string != none and string != ""
  } else if (type(string) == content) {
    return string != []
  }
}

/// Return the current index of a field or cell 
#let get-index(f) = {
  if is-bf-field(f) {
    return f.field-index
  } else if is-bf-cell(f) {
    return f.cell-index
  } else {
    none
  }
}

/// Check if in a certain grid
#let is-in-main-grid(cell) = {
  center == cell.position.grid
}

/// Check if in a certain grid
#let is-in-left-grid(cell) = {
  left == cell.position.grid
}

/// Check if in a certain grid
#let is-in-right-grid(cell) = {
  right == cell.position.grid 
}

/// Check if in a certain grid
#let is-in-header-grid(cell) = {
  top == cell.position.grid
}
