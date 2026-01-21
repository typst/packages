#import "asserts.typ": *

// insert a value into an dict and return the dict
#let dict_insert_and_return(dict, key, value) = {
  assert.eq(type(dict), dictionary);
  assert.eq(type(key), str);
  dict.insert(key,value);
  return dict
}

#let _get_field_type(field) = {
  assert_bf-field(field);
  return field.at("field-type", default: none);
}

/// Check if a given field is a bf-field
#let is-bf-field(field) = {
  assert.eq(type(field), dictionary)
  field.at("bf-type", default: none) == "bf-field"
}

/// Check if a given field is a data-field
#let is-data-field(field) = {
  assert_bf-field(field);
  field.at("field-type", default: none) == "data-field"
}

/// Check if a given field is a note-field
#let is-note-field(field) = {
  assert_bf-field(field);
  field.at("field-type", default: none) == "note-field"
}

/// Check if a given field is a header-field
#let is-header-field(field) = {
  assert_bf-field(field);
  field.at("field-type", default: none) == "header-field"
}

/// Return the index of the next data-field
#let _get_index_of_next_data_field(idx, fields) = {
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

/// calculates the cell position, based on the start_bit and the column count.
#let _get_cell_position(start, columns: 32, pre_cols: 1, header_rows: 1) = {
  let x = calc.rem(start,columns) + pre_cols
  let y = int(start/columns) + header_rows 
  return (x,y)
}

/// calculates the max annotation level for both sides
#let _get_max_annotation_levels(annotations) = {
  let left_max_level = 0
  let right_max_level = 0
  for field in annotations {
    assert_bf-field(field)
    let (side, level, ..) = field.data;
    if (side == left) {
      left_max_level = calc.max(left_max_level,level)
    } else {
      right_max_level = calc.max(right_max_level,level)
    }
  }
  return (
    pre_levels: left_max_level +1,
    post_levels:  right_max_level +1,
  )
}

///
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