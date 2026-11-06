// Utils for building schemas and verifying whether or not they are kept.
// Note: Even though some functions here are prefixed with underscores,
// that's just so they don't conflict with built-in functions and types.

// Ordered sequence of elements of type `ty`.
#let _array(ty) = (array: (ty: ty))

// Key-value mapping ordered by insertion timepoint.
// Technically the key check is redundant
// since in Typst, dict keys are guaranteed to be strings
// but eh, it fits my mental model better to specify it explicitly.
#let _dict(key, value) = {
  if key != str {
    panic("typst doesn't support non-string dictionary keys")
  }
  (dict: (key: key, value: value))
}

// Key-value mapping with specifically defined keys.
// May contain more keys than specified which are ignored.
// Effectively a very lenient product type.
#let _attrs(..args) = (attrs: args.named())

// If any of the specified types match, the value is valid,
// regardless of any other matching.
#let _any(..args) = (any: args.pos())

#let fmt(schema) = {
  let (prefix, parts) = if type(schema) == dictionary {
    if "array" in schema {
      ("array", (fmt(schema.array.ty),))
    } else if "dict" in schema {
      ("dictionary", (
        fmt(schema.dict.key),
        fmt(schema.dict.value),
      ))
    } else if "any" in schema {
      ("any", schema.any.map(fmt))
    } else if "attrs" in schema {
      (
        "dictionary",
        schema
          .attrs
          .pairs()
          .map(((key, value)) =>
            fmt(key)
            + ":"
            + fmt(value)
          ),
      )
    } else {
      (repr(schema), ())
    }
  } else {
    (repr(schema), ())
  }

  prefix

  if parts.len() == 0 {
    return
  }

  "<"
  parts
    .intersperse(", ")
    .join()
  ">"
}

// Checks if the given value adheres to the given expected type schema.
// The type schema needs to be constructed using the functions above.
// For collections, you should use the functions above.
// For primitives like `int` and `str`, you can just specify the types directly.
// (You can also specify `dictionary` for example, but that does not put any restrictions on the keys or values.)
//
// This is more specific than just comparing `type`
// since it also allows specifying the types of elements in collections.
// Returns a dictionary with the keys `expected`, `found`
// and optionally `key`
// if the typecheck fails,
// otherwise returns none.
#let check(value, expected) = {
  // to have the typecheck work with nested collections,
  // we just rely on recursion
  // i despise the Go-ish error handling but there are no usable alternatives here

  let actual = type(value)

  // handling direct type specifications
  if actual == expected {
    return none
  }

  // handling _any
  if type(expected) == dictionary and "any" in expected {
    for expected in expected.any {
      let err = check(value, expected)
      if err == none {
        return none
      }
    }

    return (
      expected: expected,
      found: value,
    )
  }

  // handling _array
  if actual == array {
    if type(expected) != dictionary or "array" not in expected {
      return (expected: expected, found: value)
    }

    for ele in value {
      let err = check(ele, expected.array.ty)
      if err != none {
        return (
          expected: expected.array.ty,
          found: ele,
        )
      }
    }
  } else if actual == dictionary {
    // was `expected` constructed using the functions above?
    if type(expected) != dictionary {
      return (expected: expected, found: value)
    }

    // handling _attrs
    if "attrs" in expected {
      for (key, value) in value {
        let expected = expected.attrs.at(key, default: none)
        if expected == none {
          continue
        }

        let err = check(value, expected)
        if err != none {
          return (
            expected: expected,
            found: value,
            key: key,
          )
        }
      }
    } else if "dict" in expected {
      // handling _dict
      for (key, value) in value {
        let err = check(value, expected.dict.value)
        if err != none {
          return (
            expected: expected.dict.value,
            found: value,
            key: key,
          )
        }
      }
    }
  } else {
    return (
      expected: expected,
      found: value,
    )
  }
}

// Panics if known fields do not contain their known types.
#let validate(it, schema) = {
  let err = check(it, schema)
  if err == none {
    return
  }

  panic(
    "failed typecheck"
    + if "key" in err {
      " at key `" + err.key + "`"
    } else {
      ""
    }
    + ". "
    + "expected: `" + _fmt-schema(err.expected) + "`, "
    + "actual: `" + repr(type(err.found)) + "`"
  )
}

