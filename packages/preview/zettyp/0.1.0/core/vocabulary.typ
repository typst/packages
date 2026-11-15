/// Named finite types with dictionary field access to their enum values.

#let supported(value) = type(value) in (str, label, bool, int)

#let checked(options) = {
  assert(
    type(options) == dictionary,
    message: "vocabulary must be a dictionary",
  )
  assert(
    options.values().all(supported),
    message: "vocabulary values must be strings, labels, booleans, or integers",
  )
  options
}

// Enum values retain exactly the identity and payload supplied at registration.
#let enum-value(value) = (
  type(value) == dictionary
    and value.keys().sorted() == ("type", "value", "variant")
    and type(value.type) == str
    and value.type != ""
    and type(value.variant) == str
    and supported(value.value)
)

/// Type names identify vocabularies; variant names identify their members.
#let register(name, ..options) = {
  assert(
    type(name) == str and name != "",
    message: "vocabulary type name must be a non-empty string",
  )
  assert(options.pos().len() == 0, message: "vocabulary choices must be named")
  checked(options.named())
    .pairs()
    .fold((:), (members, pair) => {
      let (variant, value) = pair
      members.insert(variant, (type: name, variant: variant, value: value))
      members
    })
}

/// Capture named vocabularies; each key must match the registered type name.
#let registry(..types) = {
  assert(types.pos().len() == 0, message: "registry types must be named")
  let entries = types.named()
  for (name, members) in entries {
    assert(name != "", message: "registry type name must not be empty")
    assert(
      type(members) == dictionary,
      message: "registered vocabulary must be a dictionary",
    )
    assert(
      members
        .pairs()
        .all(((variant, value)) => (
          enum-value(value) and value.type == name and value.variant == variant
        )),
      message: "invalid vocabulary registration: " + name,
    )
  }
  entries
}

/// Boolean or an exact registered member; altered payloads are not new members.
#let contains(registry, value) = {
  if type(value) == bool { return true }
  if not enum-value(value) { return false }
  if value.type not in registry { return false }
  let members = registry.at(value.type)
  value.variant in members and value == members.at(value.variant)
}
