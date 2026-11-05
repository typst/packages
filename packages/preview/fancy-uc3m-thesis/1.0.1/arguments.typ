// "THE BEER-WARE LICENSE" (Revision 42):
// L. Daniel Casais <@rajayonin> wrote this file. As long as you retain this
// notice you can do whatever you want with this stuff. If we meet some day, and
// you think this stuff is worth it, you can buy me a beer in return.



/// Formats a value to a string
///
/// - value (any): Value to format.
/// -> str
#let format-value(value) = {
  // base types
  if value == none {
    return "none"
  } else if value == auto {
    return "auto"
  } else if type(value) == bool {
    return if value { "true" } else { "false" }
  } else if type(value) == str {
    return "\"" + value + "\""
  } else if type(value) == content {
    return "[...]" // I don't want to deal with sequences, smartquotes, and such
  } else if type(value) == raw {
    return "`" + value + "`"
  } // compound types
  else if type(value) == array {
    return "(" + value.map(x => format-value(x)).join(", ") + ")"
  } else if type(value) == dictionary {
    return (
      "("
        + value.pairs().map(((k, v)) => k + ": " + format-value(v)).join(", ")
        + ")"
    )
  }

  str(value)
}


/// Validates the type of an argument.
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - value (any): Argument value.
/// - target-types (array): List of valid types. For arrays and dictionaries, you can specify the subtypes (e.g. `(array, str)`).
/// - optional (bool): Whether the argument is optional.
/// -> array
#let _validate-type(value, target-types, optional) = {
  let argument-type = type(value)
  // FIXME: if argument-type is `auto`, things break

  for t in target-types {
    // check for optionals
    if optional and value == none and argument-type != none {
      return (true, none)
    }

    // check subtypes for compound types
    if (
      type(t) == array
        and t.len() == 2
        and (array, dictionary).contains(t.at(0))
    ) {
      let subtype = t.at(1)
      t = t.at(0) // unpack base type for further checking

      if t != argument-type { continue }

      let values = if t == dictionary { value.values() } else { value }

      for (i, el) in values.enumerate() {
        let (ok, err) = _validate-type(el, (subtype,), false)
        if not ok {
          return (false, "Element " + str(i) + ": " + err)
        }
      }
    }

    if (t == argument-type) {
      // found it
      return (true, none)
    }
  }

  return (
    false,
    "Expected '"
      + target-types.map(t => format-value(t)).join(", ")
      + "', got '"
      + format-value(argument-type)
      + "'.",
  )
}


/// Validates a dictionary against the defined schema (another dictionary, whose values are the types)
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - value (dictionary):
/// - schema (dictionary):
/// -> array
#let _validate-dictionary(value, schema) = {
  let keys = value.keys()

  for (key, config) in schema.pairs() {
    let optional = config.at("optional", default: false)

    // check key is present
    if not (optional or keys.contains(key)) {
      return (false, "Missing key '" + key + "'.")
    }

    // validate config
    assert(
      config.keys().contains("target-type"),
      message: "Missing 'target-type' for " + "'" + key + "' schema",
    )

    for k in config.keys() {
      assert(
        (
          "optional",
          "target-type",
          "min-len",
          "max-len",
          "schema",
          "possible-values",
        ).contains(k),
        message: "Invalid key '" + k + "' for " + "'" + key + "' config schema",
      )
    }

    // validate values

    // I'd _like_ to have a `_validate-argument` and do something like:
    // ```typstc
    // let (ok, err) = _validate-argument(
    //   value,
    //   config.target-type,
    //   config.at("optional", default: false),
    //   // ...
    // )
    // if not ok {
    //   return (false, "Invalid field '" + key + "': " + err)
    // }
    // ```
    //
    // BUT, Typst doesn't allow mutually recursive functions, that is:
    // ```typstc
    // let foo() = { bar() } // <- error: unknown variable: bar
    // let bar() = { foo() }
    // ```
    //
    // because a function HAS to be defined before it can be used, so... we'll
    // have to do it manually... again...

    // check value type
    let ok = true
    let err = ""

    if type(config.target-type) == dictionary {
      (ok, err) = _validate-dictionary(value.at(key), config.schema)
    } else if not (optional and value.at(key, default: none) == none) {
      (ok, err) = _validate-type(
        value.at(key),
        if type(config.target-type) == array {
          config.target-type
        } else { (config.target-type,) },
        optional,
      )
    }

    // check enum values
    if (
      config.keys().contains("possible-values")
        and config.possible-values.len() > 0
        and not config.possible-values.contains(value.at(key))
        and not (optional and value.at(key, default: none) == none)
    ) {
      return (
        false,
        "Invalid "
          + key
          + " "
          + format-value(value.at(key))
          + ". Possible values are: "
          + config.possible-values.map(format-value).join(", ")
          + ".",
      )
    }

    // check array lenght
    if (
      config.keys().contains("target-type") and config.target-type == array
    ) {
      if (
        config.at("min-len", default: none) != none
          and value.at(key).len() < config.min-len
      ) {
        return (
          false,
          "Size of '"
            + key
            + "' must be bigger or equal to "
            + str(config.min-len)
            + ".",
        )
      }

      if (
        config.at("max-len", default: none) != none
          and value.at(key).len() > config.max-len
      ) {
        return (
          false,
          "Size of '"
            + key
            + "' must be smaller or equal to "
            + str(config.max-len)
            + ".",
        )
      }
    }

    if not ok {
      return (false, "Invalid type for field '" + key + "'. " + err)
    }
  }

  (true, "")
}



/// Validates an argument.
///
/// - name (str): Name of the argument, used for the error message.
/// - value (any): Value to check.
/// - optional (bool): If the argument is optional
/// - target-type? (): Valid type, or types. For arrays, you can specify the subtypes (e.g. `(array, str)`). If `possible-values` is set, it is ignored.
/// - possible-values? (array): Check against a list of valid values.
/// - min-len? (number): Check minimum array lenght. Only applies to arrays.
/// - max-len? (number): Check maximum array lenght. Only applies to arrays.
/// - schema? (dictionary): Validate dictionary against schema definition. Only applies to dictionaries.
/// -> none
#let validate-argument(
  name,
  value,
  target-type: none,
  optional: false,
  possible-values: (),
  min-len: none,
  max-len: none,
  schema: none,
) = {
  let argument-type = type(value)

  // check it exists
  if not optional {
    assert(value != none, message: "Missing argument '" + name + "'.")
  }

  // check enum values
  if possible-values.len() > 0 {
    assert(
      possible-values.contains(value),
      message: "Invalid "
        + name
        + " "
        + format-value(value)
        + ". Possible values are: "
        + possible-values.map(format-value).join(", ")
        + ".",
    )
  } else {
    // check type
    let (ok, err) = _validate-type(
      value,
      // specify one or multiple types
      if type(target-type) == array { target-type } else { (target-type,) },
      optional,
    )
    assert(ok, message: "Invalid type for '" + name + "'. " + err)
  }

  // check array lenght
  if target-type == array {
    if min-len != none {
      assert(
        value.len() >= min-len,
        message: "Size of '"
          + name
          + "' must be bigger or equal to "
          + str(min-len)
          + ".",
      )
    }

    if max-len != none {
      assert(
        value.len() <= max-len,
        message: "Size of '"
          + name
          + "' must be smaller or equal to "
          + str(max-len)
          + ".",
      )
    }
  }

  // check dictionary schema
  if (
    schema != none
      and (
        target-type == dictionary
          or type(target-type) == array
            and target-type.contains(dictionary)
            and type(value) == dictionary
      )
      and not (optional and value == none)
  ) {
    let (ok, err) = _validate-dictionary(value, schema)
    assert(ok, message: "Invalid format for '" + name + "'. " + err)
  }
}
