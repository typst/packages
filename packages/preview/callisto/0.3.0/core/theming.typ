// Default doc template
#let default-template(doc) = doc

// Resolve theme by name
#let _resolve-name(name, named-themes) = {
  if name not in named-themes {
    panic("theme name not found: " + name)
  }
  return named-themes.at(name)
}

// Resolve field value to a function
#let _resolve-field(key, value, named-themes) = {
  if value == none {
    return none
  }
  if type(value) == function {
    return ((key): value)
  }
  if type(value) == str {
    value = _resolve-name(value, named-themes)
  }
  if type(value) == dictionary {
    // Resolve the field in the value dictionary
    return _resolve-field(key, value.at(key, default: none), named-themes)
  }
  panic("invalid theme field type: " + str(type(value)))
}

// Normalize a theme name/dict/none to a dict of functions.
// The dict is guaranteed to contain at least the 'template' field.
#let resolve(value, named-themes) = {
  // Start with default value for doc template
  (template: default-template)

  if value == none { return }

  if type(value) == str {
    value = _resolve-name(value, named-themes)
  }
  if type(value) != dictionary {
    panic("invalid theme type: " + str(type(value)))
  }
  // Resolve each dict field
  for (k, v) in value {
    _resolve-field(k, v, named-themes)
  }
}
