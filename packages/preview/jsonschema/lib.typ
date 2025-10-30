
#let validate = {
  let plugin = plugin("jsonschema.wasm")

  /// Validate a JSON schema against a JSON data
  ///
  /// - schema (str): schema as string
  /// - data (str): json as string
  /// -> auto: json as typst data type
  let validate(schema, data) = {
    return json(plugin.validate(bytes(schema), bytes(data)))
  }

  validate
}

