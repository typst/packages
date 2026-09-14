// The type system used by fields.
#import "../data.typ": data, special-data-values, type-key, custom-type-key, custom-type-data-key, eq, type-version, elem-funcs
#import "base.typ" as base: ok, err
#import "native.typ"

// The default value for a type.
#let default(type_) = {
  if type_.default == () {
    let prefix = if type_.type-kind in ("native", "union") { type_.type-kind + " " } else { "" }
    err(prefix + "type '" + type_.name + "' has no known default, please specify an explicit 'default: value' or set 'required: true' for the field")
  } else {
    ok(type_.default.first())
  }
}

#let typeof(value) = {
  let element-data
  if type(value) == dictionary and custom-type-key in value {
    if custom-type-data-key in value {
      base.custom-type
    } else {
      (value.at(custom-type-key).func)(__elembic_data: special-data-values.get-data).typeinfo
    }
  } else if type(value) == content and value.func() in elem-funcs and {
    element-data = data(value)
    element-data.eid != none
  } {
    if "name" in element-data and type(element-data.name) == str {
      base.element(element-data.name, element-data.eid)
    } else {
      base.element("unknown-element", element-data.eid)
    }
  } else {
    let (res, typeinfo) = native.typeinfo(type(value))
    if not res {
      assert(false, message: "elembic: types.typeof: " + typeinfo)
    }

    typeinfo
  }
}

// Literal type
// Only accepted if value is equal to the literal.
// Input and output are equal to the value.
//
// Uses base typeinfo information for information such as casts and whatnot.
#let literal(value) = {
  if value == none {
    native.none_
  } else if value == auto {
    native.auto_
  } else {
    base.literal(value, typeof(value))
  }
}

// Obtain the typeinfo for a type.
//
// Returns ok(typeinfo), or err(error) if there is no corresponding typeinfo.
#let validate(type_) = {
  if type(type_) == function {
    let data = type_(__elembic_data: special-data-values.get-data)
    let data-kind = data.at("data-kind", default: "unknown")
    if data-kind == "custom-type-data" {
      type_ = data.typeinfo
    } else if data-kind == "element" {
      type_ = base.element(data.name, data.eid)
    } else {
      return (false, "Received invalid type: " + repr(type_) + "\n  hint: use 'types.literal(value)' to indicate only that particular value is valid")
    }
  }

  if type(type_) == type {
    native.typeinfo(type_)
  } else if type(type_) == dictionary and type-key in type_ {
    (true, type_)
  } else if type(type_) == dictionary and custom-type-data-key in type_ {
    (true, type_.typeinfo)
  } else if type(type_) == function {
    (false, "A function is not a valid type. (You can use 'types.literal(func)' to only accept a particular function.)")
  } else if type_ == none or type_ == auto {
    // Accept none or auto to mean their types
    native.typeinfo(type(type_))
  } else if type(type_) not in (dictionary, array, content) {
    // Automatically accept literals
    (true, literal(type_))
  } else {
    (false, "Received invalid type: " + repr(type_) + "\n  hint: use 'types.literal(value)' to indicate only that particular value is valid")
  }
}

// Error when a value doesn't conform to a certain cast
#let generate-cast-error(value, typeinfo, hint: none) = {
  let message = if "any" not in typeinfo.input and base.typeid(value) not in typeinfo.input {
    if typeinfo.input == () {
      "type '" + typeinfo.name + "' does not accept any values"
    } else {
      (
        "expected "
        + typeinfo.input.map(t => if type(t) == dictionary and "name" in t { t.name } else { str(t) }).join(", ", last: " or ")
        + ", found "
        + base.typename(value)
      )
    }
  } else if typeinfo.at("error", default: none) != none {
    (typeinfo.error)(value)
  } else {
    "typecheck for " + typeinfo.name + " failed"
  }
  let given-hint = if hint == none { "" } else { "\n  hint: " + hint }

  message + given-hint
}

// Try to accept value via given typeinfo or return error
// Returns ok(value) a.k.a. (true, value) on success
// Returns err(value) a.k.a. (false, value) on error
#let cast(value, typeinfo) = {
  if type(typeinfo) != dictionary or type-key not in typeinfo {
    let (res, typeinfo-or-err) = validate(typeinfo)
    if not res {
      assert(false, message: "elembic: types.cast: " + typeinfo-or-err)
    }
    typeinfo = typeinfo-or-err
  }

  let kind = typeinfo.type-kind
  if kind == "any" {
    (true, value)
  } else {
    let value-type = type(value)
    if value-type == dictionary and custom-type-key in value {
      value-type = value.at(custom-type-key).id
    }

    if kind == "literal" and typeinfo.cast == none and ("__future_cast" not in typeinfo or typeinfo.__future_cast.max-version < type-version) {
      if eq(value, typeinfo.data.value) and (value-type in typeinfo.input or "any" in typeinfo.input) and (typeinfo.data.typeinfo.check == none or (typeinfo.data.typeinfo.check)(value)) {
        (true, value)
      } else {
        (false, generate-cast-error(value, typeinfo))
      }
    } else if (
      value-type not in typeinfo.input and "any" not in typeinfo.input
      or typeinfo.check != none and not (typeinfo.check)(value)
    ) {
      (false, generate-cast-error(value, typeinfo))
    } else if typeinfo.cast == none {
      (true, value)
    } else if kind == "native" and typeinfo.data == content and ("__future_cast" not in typeinfo or typeinfo.__future_cast.max-version < type-version) {
      (true, [#value])
    } else {
      (true, (typeinfo.cast)(value))
    }
  }
}

// Expected types for each typeinfo key.
#let overridable-typeinfo-types = (
  name: (check: a => type(a) == str, error: "string or function old name => new name"),
  input: (check: a => type(a) == array and a.all(x => x == "any" or x == "custom type" or type(x) == type or (type(x) == dictionary and "tid" in x)), error: "array of \"any\", \"custom type\", type, or custom type id (tid: ...), or function old input => new input"),
  output: (check: a => type(a) == array and a.all(x => x == "any" or x == "custom type" or type(x) == type or (type(x) == dictionary and "tid" in x)), error: "array of \"any\", \"custom type\", type, or custom type id (tid: ...), or function old output => new output"),
  check: (check: a => a == none or type(a) == function, error: "none or function receiving old function and returning a function value => bool"),
  cast: (check: a => a == none or type(a) == function, error: "none or function receiving old function and returning a function checked input => output"),
  error: (check: a => a == none or type(a) == function, error: "none or function receiving old function and returning a function checked input => error string"),
  default: (check: d => d == () or type(d) == array and d.len() == 1, error: "empty array for no default, singleton array for one default, or function old default => new default"),
  fold: (check: f => f == none or f == auto or type(f) == function, error: "none for no folding, auto to fold with sum (same as (a, b) => a + b), or function receiving old fold and returning either none or auto, or a new function (outer, inner) => combined value"),
)

// Wrap a type, altering its properties while keeping (or replacing) its input types and checks.
#let wrap(type_, ..data) = {
  assert(data.pos() == (), message: "elembic: types.wrap: unexpected positional arguments")
  let (res, typeinfo) = validate(type_)
  if not res {
    assert(false, message: "elembic: types.wrap: " + typeinfo)
  }

  let overrides = data.named()
  for (key, value) in overrides {
    let (check: validate-value, error: key-error) = overridable-typeinfo-types.at(key, default: (check: none, error: none))
    if validate-value == none or key-error == none {
      assert(false, message: "elembic: types.wrap: invalid key '" + key + "', must be one of " + overridable-typeinfo-types.keys().join(", ", last: " or "))
    }

    if type(value) == function {
      value = value(typeinfo.at(key, default: base.base-typeinfo.at(key)))
      overrides.at(key) = value
    }

    if not validate-value(value) {
      let array-hint = if key in ("input", "output", "default") and type(value) != array {
        "\n  hint: did you forget a comma at (value,) and wrote (value) instead? Make sure an array was given."
      } else {
        ""
      }

      assert(false, message: "elembic: types.wrap: invalid value for key '" + key + "', expected " + key-error + array-hint)
    }
  }

  if "any" not in typeinfo.output and "cast" in overrides and "output" not in overrides {
    // - If there is a cast and output is unchanged, then complain: please update the output
    assert(false, message: "elembic: types.wrap: please override 'output' whenever overriding 'cast', specifying which types the cast function may return, or '(\"any\",)' (note the comma!) to indicate the cast function may return any type (discouraged, disables some optimizations).\n\nYou can also tell elembic you are sure the new cast function may produce strictly the same output types as before with 'output: prev => prev'.")
  }

  if typeinfo.cast != none and "output" in overrides and "cast" not in overrides and "any" not in overrides.output and typeinfo.output.any(o => o not in overrides.output) {
    // If output was changed to a list which isn't 'any' and isn't a superset of the previous output,
    // then ensure casting is also changed, as it is no longer safe (might produce something that is
    // an invalid output)
    assert(false, message: "elembic: types.wrap: a type output was removed, but its cast was not changed, meaning the cast function might produce a now invalid output. Fix this by either providing a new cast function, setting 'cast: none' to disable casting entirely, or setting 'cast: prev => prev' if you're sure the previous cast function cannot produce one of the removed output types.")
  }

  if "output" in overrides and "any" in overrides.output {
    // - Collapse "any" + other types into just "any"
    overrides.output = ("any",)
  }

  if "input" in overrides and "any" in overrides.input {
    // - Collapse "any" + other types into just "any"
    overrides.input = ("any",)
  }

  if "default" not in overrides and typeinfo.default != () and ("check" in overrides or "output" in overrides and "any" not in overrides.output and typeinfo.output.any(o => o not in overrides.output)) {
    // Not sure if default would fit those criteria anymore:
    // 1. By overriding the check, it's possible that a type such as positive int (check: int > 0) would no longer
    // have an acceptable default when changing its check to, say, negative int (check: int < 0).
    // 2. By overriding the output and removing previous output types, it's possible the default no longer has a valid type (it must be a valid output).
    overrides.default = ()
  }

  let new-default = overrides.at("default", default: typeinfo.default)
  let new-output = overrides.at("output", default: typeinfo.output)
  let new-input = overrides.at("input", default: typeinfo.input)
  let new-cast = overrides.at("cast", default: typeinfo.cast)
  let new-check = overrides.at("check", default: typeinfo.check)
  assert(
    new-default == ()
    or "any" in new-output
    or base.typeid(new-default.first()) in new-output,

    message: "elembic: types.wrap: new default (currently " + repr(if new-default == () { none } else { new-default.first() }) + ") must have a type within possible 'output' types of the new type (currently " + if new-output == () { "empty" } else { new-output.map(t => if type(t) == dictionary { t.name } else { str(t) }).join(", ", last: " or ") } + "), since it is itself an output\n  hint: you can either change the default, or update possible output types with 'output: (new, list)' to indicate which native or custom types your wrapped type might end up as after casts (if there are casts)."
  )

  if new-check == none and new-cast == none and "any" not in new-output and (
    "any" in new-input or new-input.any(inp => inp not in new-output)
  ) {
    assert(false, message: "elembic: types.wrap: new type has no casting or checking, but not all of its input types are valid output types. Ensure 'output: (...)' and 'input: (...)' are identical to fix this.")
  }

  if new-cast == none and "any" not in new-input and new-output.any(out => out == "any" or out not in new-input) {
    assert(false, message: "elembic: types.wrap: new type has no casting, but list of valid output types includes invalid input types. Please ensure 'output' is a subset of 'input' in this case, or add a cast.")
  }

  if (
    (
      "check" in overrides and new-check != typeinfo.check
      or "output" in overrides and new-output != typeinfo.output
    )
    and "fold" not in overrides and typeinfo.fold != none
  ) {
    // Folding might not be valid anymore:
    // 1. By overriding the check, it's possible a fold that, say, adds two numbers, would no longer be valid
    // if, for example, the new check ensures each number is smaller than 59 (you might add up to that).
    //    In addition, the fold might now receive parameters that would fail the new check while being cast.
    // 2. By overriding the output:
    //    a. and removing old output, it's possible the fold produces invalid output.
    //    b. and adding new output, it's possible the fold receives parameters of an unexpected type.
    assert(false, message: "elembic: types.wrap: new type has overridden check and/or output types, but not 'fold', usually a function (outer output, inner output) => folded output\n  hint: it's possible the previous fold function could now produce a value that would never have passed the check or been a valid output type if kept, e.g. joining two single-element arrays would generate a two-element array which may violate a check that only allows casting single-element arrays into the new type\n  hint: either explicitly remove folding with 'fold: none', keep the previous fold function with 'fold: prev => prev' if you're sure it still works properly with the new check or list of output types, or override it with 'fold: prev => (outer, inner) => folded'")
  }

  base.wrap(typeinfo, overrides)
}

// Specifies that any from a given selection of types is accepted.
#let union(..args) = {
  let types = args.pos()
  assert(types != (), message: "elembic: types.union: please specify at least one type")

  let typeinfos = types.map(type_ => {
    let (res, typeinfo-or-err) = validate(type_)
    assert(res, message: if not res { "elembic: types.union: " + typeinfo-or-err } else { "" })

    typeinfo-or-err
  })

  base.union(typeinfos)
}

// An optional type (can be 'none').
#let option(type_) = union(type(none), type_)

// A type which can be 'auto'.
#let smart(type_) = union(type(auto), type_)

#let array_(type_) = {
  let (res, param) = validate(type_)
  if not res {
    assert(false, message: "elembic: types.array: " + param)
  }

  base.array_(
    native.array_,
    param,

    error: if param.check == none {
      a => {
        let (count, message) = a.enumerate().fold((0, ""), ((count, message), (i, element)) => {
          if "any" not in param.input and base.typeid(element) not in param.input {
            (count + 1, message + "\n  hint: at position " + str(i) + ": " + generate-cast-error(element, param))
          } else {
            (count, message)
          }
        })

        let n-elements = if count == 1 { "an element" } else { str(count) + " elements" }
        n-elements + " in an array of " + param.name + " did not typecheck" + message
      }
    } else {
      a => {
        let (count, message) = a.enumerate().fold((0, ""), ((count, message), (i, element)) => {
          if "any" not in param.input and base.typeid(element) not in param.input or not (param.check)(element) {
            (count + 1, message + "\n  hint: at position " + str(i) + ": " + generate-cast-error(element, param))
          } else {
            (count, message)
          }
        })

        let n-elements = if count == 1 { "an element" } else { str(count) + " elements" }
        n-elements + " in an array of " + param.name + " did not typecheck" + message
      }
    }
  )
}

#let dict_(type_) = {
  let (res, param) = validate(type_)
  if not res {
    assert(false, message: "elembic: types.array: " + param)
  }

  base.dict_(
    native.dict_,
    param,

    error: if param.check == none {
      d => {
        let (count, message) = d.pairs().fold((0, ""), ((count, message), (key, value)) => {
          if "any" not in param.input and base.typeid(value) not in param.input {
            (count + 1, message + "\n  hint: at key " + repr(key) + ": " + generate-cast-error(value, param))
          } else {
            (count, message)
          }
        })

        let n-elements = if count == 1 { "a value" } else { str(count) + " values" }
        n-elements + " in a dictionary of " + param.name + " did not typecheck" + message
      }
    } else {
      d => {
        let (count, message) = d.pairs().fold((0, ""), ((count, message), (key, value)) => {
          if "any" not in param.input and base.typeid(value) not in param.input or not (param.check)(value) {
            (count + 1, message + "\n  hint: at key " + repr(key) + ": " + generate-cast-error(value, param))
          } else {
            (count, message)
          }
        })

        let n-elements = if count == 1 { "a value" } else { str(count) + " values" }
        n-elements + " in a dictionary of " + param.name + " did not typecheck" + message
      }
    }
  )
}

// Native paint type. Can be used for fills, strokes and so on.
#let paint = union(color, gradient, native.tiling_)

// Force the type to only accept its outputs (disallow casting).
// Folding is kept if possible.
#let exact(type_) = {
  let (res, type_) = validate(type_)
  if not res {
    assert(false, message: "elembic: types.exact: " + type_)
  }

  let key = if type(type_) == dictionary and "type-kind" in type_ { type_.type-kind } else { none }
  if key == "union" {
    // exact(union(A, B)) === union(exact(A), exact(B))
    union(..type_.data.map(exact))
  } else if type(type_) == type or key == "native" {
    // exact(float) => can only pass float, not int
    // exact(stroke) => can only pass stroke, not length, gradient, dict, etc.
    let native-type = type_.data
    (
      ..native.generic-typeinfo(native-type),
      default: if type_.default != () and type(type_.default.first()) == native-type { type_.default } else { () },

      // Fold is an output => output function. The new output will be just (native-type,),
      // so if fold previously accepted that native type, it will still accept it, so it
      // can be kept.
      fold: if native-type in type_.output { type_.fold } else { none },
    )
  } else if key == "literal" {
    // exact(literal) => literal with base type modified to exact(base type)
    assert(type(type_.data.value) not in (dictionary, array), message: "elembic: types.exact: exact literal types for custom types, dictionaries and arrays are not supported\n  hint: consider customizing the check function to recursively check fields if the performance is acceptable")

    base.literal(type_.data.value, exact(type_.data.typeinfo))
  } else if key == "any" or key == "never" {
    // exact(any) => any (same)
    // exact(never) => never (same)
    type_
  } else if key == "collection" {
    if "base" in type_.data and "parameters" in type_.data {
      let base-kind = type_.data.base.at("type-kind", default: none)
      if base-kind == "native" and type_.data.base.data == array {
        array_(..type_.data.parameters.map(exact))
      } else if base-kind == "native" and type_.data.base.data == dictionary {
        dict_(..type_.data.parameters.map(exact))
      } else {
        assert(false, message: "elembic: types.exact: unknown collection with type kind '" + base-kind + "'" + if base-kind == "native" { ", base native type '" + type_.data.base.name + "'" } else { "" })
      }
    } else {
      assert(false, message: "elembic: types.exact: invalid collection given")
    }
  } else if key == "custom" {
    if type_.data.pre-casts == none {
      type_
    } else {
      type_.data.pre-casts
    }
  } else {
    assert(false, message: "elembic: types.exact: unsupported type kind " + key + ", supported kinds include native types, literals, custom types, arrays, dicts, 'any' and 'never'")
  }
}
