// The type system used by fields.
#import "../data.typ": data, special-data-values, type-key, custom-type-key, custom-type-data-key
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

#let sequence_ = [].func()
#let typeof(value) = {
  let element-data
  if type(value) == dictionary and custom-type-key in value {
    if custom-type-data-key in value {
      base.custom-type
    } else {
      (value.at(custom-type-key).func)(__elembic_data: special-data-values.get-data).typeinfo
    }
  } else if type(value) == content and value.func() == sequence_ and {
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
      assert(false, message: "types.typeof: " + typeinfo)
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
      assert(false, message: "types.cast: " + typeinfo-or-err)
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

    if kind == "literal" and typeinfo.cast == none {
      if value == typeinfo.data.value and (value-type in typeinfo.input or "any" in typeinfo.input) and (typeinfo.data.typeinfo.check == none or (typeinfo.data.typeinfo.check)(value)) {
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
    } else if kind == "native" and typeinfo.data == content {
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
  assert(data.pos() == (), message: "types.wrap: unexpected positional arguments")
  let (res, typeinfo) = validate(type_)
  if not res {
    assert(false, message: "types.wrap: " + typeinfo)
  }

  let overrides = data.named()
  for (key, value) in overrides {
    let (check: validate-value, error: key-error) = overridable-typeinfo-types.at(key, default: (check: none, error: none))
    if validate-value == none or key-error == none {
      assert(false, message: "types.wrap: invalid key '" + key + "', must be one of " + overridable-typeinfo-types.keys().join(", ", last: " or "))
    }

    if type(value) == function {
      value = value(typeinfo.at(key, default: base.base-typeinfo.at(key)))
    }

    if type(value) != function and not validate-value(value) {
      assert(false, message: "types.wrap: invalid value for key '" + key + "', expected " + key-error)
    }
  }

  if "any" not in typeinfo.output and "cast" in overrides and "output" not in overrides or "output" in overrides and "any" in overrides.output {
    // - Collapse "any" + other types into just "any";
    // - If there is a cast and output is unknown, then set it to any for safety (should we error?)
    overrides.output = ("any",)
  }

  if typeinfo.cast != none and "output" in overrides and "cast" not in overrides and "any" not in overrides.output and typeinfo.output.any(o => o not in overrides.output) {
    // If output was changed to a list which isn't 'any' and isn't a superset of the previous output,
    // then remove casting as it is no longer safe (might produce something that is invalid)
    // (TODO: Should we error?)
    overrides.cast = none
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

  if ("check" in overrides or "output" in overrides) and "fold" not in overrides {
    // Folding might not be valid anymore:
    // 1. By overriding the check, it's possible a fold that, say, adds two numbers, would no longer be valid
    // if, for example, the new check ensures each number is smaller than 59 (you might add up to that).
    //    In addition, the fold might now receive parameters that would fail the new check while being cast.
    // 2. By overriding the output:
    //    a. and removing old output, it's possible the fold produces invalid output.
    //    b. and adding new output, it's possible the fold receives parameters of an unexpected type.
    overrides.fold = none
  }

  let new-default = overrides.at("default", default: typeinfo.default)
  let new-output = overrides.at("output", default: typeinfo.output)
  assert(
    new-default == ()
    or "any" in new-output
    or base.typeid(new-default.first()) in new-output,

    message: "types.wrap: new default (currently " + repr(if new-default == () { none } else { new-default.first() }) + ") must have a type within possible 'output' types of the new type (currently " + if new-output == () { "empty" } else { new-output.map(t => if type(t) == dictionary { t.name } else { str(t) }).join(", ", last: " or ") } + "), since it is itself an output\n  hint: you can either change the default, or update possible output types with 'output: (new, list)' to indicate which native or custom types your wrapped type might end up as after casts (if there are casts)."
  )

  base.wrap(typeinfo, overrides)
}

// Specifies that any from a given selection of types is accepted.
#let union(..args) = {
  let types = args.pos()
  assert(types != (), message: "types.union: please specify at least one type")

  let typeinfos = types.map(type_ => {
    let (res, typeinfo-or-err) = validate(type_)
    assert(res, message: if not res { "types.union: " + typeinfo-or-err } else { "" })

    typeinfo-or-err
  })

  base.union(typeinfos)
}

// An optional type (can be 'none').
#let option(type_) = union(type(none), type_)

// A type which can be 'auto'.
#let smart(type_) = union(type(auto), type_)

// Force the type to only accept its outputs (disallow casting).
// Folding is kept if possible.
#let exact(type_) = {
  let (res, type_) = validate(type_)
  if not res {
    assert(false, message: "types.exact: " + type_)
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
    assert(type(type_.data.value) not in (dictionary, array), message: "types.exact: exact literal types for custom types, dictionaries and arrays are not supported\n  hint: consider customizing the check function to recursively check fields if the performance is acceptable")

    base.literal(type_.data.value, exact(type_.data.typeinfo))
  } else if key == "any" or key == "never" {
    // exact(any) => any (same)
    // exact(never) => never (same)
    type_
  } else if key == "custom" {
    if type_.data.pre-casts == none {
      type_
    } else {
      type_.data.pre-casts
    }
  } else {
    assert(false, message: "types.exact: unsupported type kind " + key + ", supported kinds include native types, literals, custom types, 'any' and 'never'")
  }
}

#let array_(type_) = {
  let (res, param) = validate(type_)
  if not res {
    assert(false, message: "types.array: " + param)
  }

  let kind = param.type-kind

  base.collection(
    "array",
    native.array_,
    (param,),
    check: if param.check == none and "any" in param.input {
      none
    } else if param.input == () {
      // Propagate 'never'
      _ => false
    } else if "any" in param.input {
      // Only need to run checks
      a => a.all(x => (param.check)(x))
    } else {
      // Some optimizations ahead
      // The proper code is at the bottom
      let input = param.input
      let check = param.check
      if kind == "native" and param.data == dictionary {
        a => a.all(x => type(x) == dictionary and custom-type-key not in x)
      } else if param.input.all(i => type(i) == type) and dictionary not in param.input {
        // No custom types accepted (the check above excludes '(tid: ..., name: ...)' as well as "any")
        // If this is a custom type, it will return type(x) = dictionary, so it will fail
        // (Also excludes "custom type": the type of custom types)
        // So that suffices
        if input.len() == 1 {
          let input = input.first()
          if check == none {
            a => a.all(x => type(x) == input)
          } else {
            a => a.all(x => type(x) == input and check(x))
          }
        } else if input.len() == 2 {
          let first = input.first()
          let second = input.at(1)
          if check == none {
            a => a.all(x => type(x) == first or type(x) == second)
          } else {
            a => a.all(x => (type(x) == first or type(x) == second) and check(x))
          }
        } else if check == none {
          a => a.all(x => type(x) in input)
        } else {
          a => a.all(x => type(x) in input and check(x))
        }
      } else if param.check == none {
        a => a.all(x => base.typeid(x) in param.input)
      } else {
        a => a.all(x => base.typeid(x) in param.input and check(x))
      }
    },

    cast: if param.cast == none {
      none
    } else if kind == "native" and param.data == content {
      a => a.map(x => [#x])
    } else {
      a => a.map(param.cast)
    },

    error: if param.check == none {
      a => {
        let (count, message) = a.enumerate().fold((0, ""), ((count, message), (i, element)) => {
          if "any" not in param.input and base.typeid(element) not in param.input {
            (count + 1, message + "\n  hint: at position " + str(i) + ": " + generate-cast-error(element, param))
          } else {
            (count, message)
          }
        })

        let n-elements = if count == 1 { "an element" } else { str(count) + "elements" }
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

        let n-elements = if count == 1 { "an element" } else { str(count) + "elements" }
        n-elements + " in an array of " + param.name + " did not typecheck" + message
      }
    }
  )
}

// Native paint type. Can be used for fills, strokes and so on.
#let paint = union(color, gradient, native.tiling_)
