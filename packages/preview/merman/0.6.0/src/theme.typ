#import "options.typ": options-bytes
#import "plugin.typ": merman-plugin

#let encoded-json-input(value, name) = {
  if type(value) == str {
    if value.trim() == "" {
      panic(name + " must not be empty")
    }
    bytes(value)
  } else if type(value) == dictionary {
    bytes(json.encode(value))
  } else {
    panic(name + " must be a dictionary or JSON string")
  }
}

#let theme-operation(operation, input, options) = {
  let envelope = json(
    merman-plugin.theme_operation_json(
      bytes(operation),
      input,
      options-bytes(options),
    ),
  )
  if envelope.operation != operation {
    panic("merman Typst plugin returned an unexpected theme operation")
  }
  if envelope.ok { envelope.data.result } else { envelope }
}

#let materialize-theme(definition, options: none) = {
  theme-operation(
    "materialize-theme-json",
    encoded-json-input(definition, "merman theme definition"),
    options,
  )
}

#let describe-theme-support(query, options: none) = {
  theme-operation(
    "describe-theme-support-json",
    encoded-json-input(query, "merman theme support query"),
    options,
  )
}

#let export-theme-preset(preset-id, options: none) = {
  if type(preset-id) != str or preset-id.trim() == "" {
    panic("merman theme preset ID must be a non-empty string")
  }
  theme-operation(
    "export-theme-preset-json",
    bytes(preset-id),
    options,
  )
}

#let theme-catalog() = {
  let envelope = json(merman-plugin.theme_catalog_json())
  if envelope.operation != "theme-catalog" {
    panic("merman Typst plugin returned an unexpected theme catalog operation")
  }
  if envelope.ok { envelope.data.result } else { envelope }
}
