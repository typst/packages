#import "@preview/oxifmt:0.2.1": strfmt


#let assert-dict(arg, var_name) = {
  assert.eq(type(arg),dictionary, message: strfmt("expected {} to be a dictionary, found {}",var_name, type(arg)));
}


/// fail if field is not a bf-field
#let assert-bf-field(field) = {
  assert-dict(field, "field")
  let bf-type = field.at("bf-type", default: none)
  assert.eq(bf-type, "bf-field", message: strfmt("expected bf-type of 'bf-field', found {}",bf-type));
  let field-type = field.at("field-type", default: none)
  assert.ne(field-type, none, message: strfmt("could not find field-type at bf-field {}", field));
}

/// fail if field is not a bf-field of type data-field
#let assert-data-field(field) = {
  assert-bf-field(field);
  let field-type = field.at("field-type", default: none)
  assert.eq(field-type, "data-field", message: strfmt("expected field-type == data-field, found {}",field-type))
  let size = field.data.size;
  assert(type(size) == int, message: strfmt("expected integer for parameter size, found {} ", type(size)))
}

/// fail if field is not a bf-field of type data-field
#let assert-note-field(field) = {
  assert-bf-field(field);
  // Check for correct field-type
  let field-type = field.at("field-type", default: none)
  assert.eq(field-type, "note-field", message: strfmt("expected field-type == note-field, found {}",field-type))
  // Check if it has a valid anchor id 
  let row = field.data.row
  assert(type(row) == int, message: strfmt("expected integer for parameter anchor, found {} ", type(row)))
  
  // Check side 
  assert(field.data.side == left or field.data.side == right, message: strfmt("expected left or right for the notes side argument."))
}

/// fail if it does not match
#let assert-header-field(field) = {
  assert-bf-field(field);
}

/// fail if cell is not a bf-cell 
#let assert-bf-cell(cell) = {
  assert-dict(cell, "cell");
  // Check bf-type
  let bf-type = cell.at("bf-type", default: none)
  assert.eq(bf-type, "bf-cell", message: strfmt("expected bf-type of 'bf-cell', found {}",bf-type));
  // Check cell-type is not none
  let cell-type = cell.at("cell-type", default: none)
  assert.ne(cell-type, none, message: strfmt("could not find cell-type at bf-cell {}", cell));
}



