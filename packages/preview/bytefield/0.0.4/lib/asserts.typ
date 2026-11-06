#import "@preview/oxifmt:0.2.0": strfmt

// fail if field is not a bf-field
#let assert_bf-field(field) = {
  assert.eq(type(field),dictionary, message: strfmt("expected field to be a dictionary, found {}", type(field)));
  let bf-type = field.at("bf-type", default: none)
  assert.eq(bf-type, "bf-field", message: strfmt("expected bf-type of 'bf-field', found {}",bf-type));
  let field-type = field.at("field-type", default: none)
  assert.ne(field-type, none, message: strfmt("could not find field-type at bf-field {}", field));
}

// fail if field is not a bf-field of type data-field
#let assert_data-field(field) = {
  assert_bf-field(field);
  let field-type = field.at("field-type", default: none)
  assert.eq(field-type, "data-field", message: strfmt("expected field-type == data-field, found {}",field-type))
  let size = field.data.size;
  assert(type(size) == int, message: strfmt("expected integer for parameter size, found {} ", type(size)))
}
