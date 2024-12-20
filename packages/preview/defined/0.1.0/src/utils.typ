#import "@preview/valkyrie:0.2.1" as z

/// Raise an error.
/// - message (string): The error message.
#let error(message) = {
  let _ = z.parse(message, z.string())

  assert(false, message: message)
}

/// Perform a type check on a value.
/// - type (dictionary): The type to check the value against.
/// -> (function): A function that takes a value and checks it against the type.
#let type-check(value, schema) = {
  if type(schema) == dictionary {
    let _ = z.parse(value, schema)
    return
  }

  if type(value) != schema {
    error("Schema validation failed on argument: Expected " + (schema) + ". Got " + (type(value)))
  }
}

/// Convert a value to a string.
///
/// If the value is already a string, it will be returned as is.
///
/// - value (content): The value to convert.
/// -> (string): The string representation of the value.
#let stringfy(value) = {
  type-check(value, z.either(z.content(), z.string()))

  if type(value) == str {
    return value
  }

  if value.has("text") {
    return value.text
  }

  if value.has("children") {
    return value.children.fold("", (acc, child) => {
      acc + stringfy(child)
    })
  }

  return ""
}
