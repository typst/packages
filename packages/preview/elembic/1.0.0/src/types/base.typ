// The shared fundamentals of the type system.
#import "../data.typ": data, type-key, custom-type-key, custom-type-data-key, repr_, func-name, type-version, eq

// Typeinfo structure:
// - type-key: kind of type
// - version: 1
// - name: type name
// - input: list of native types / custom types of input
// - output: list of native types / custom types of output
// - data: data specific for this type key
// - check: none (only check inputs) or function x => bool
// - cast: none (input is unchanged) or function to convert input to output
// - error: none or function x => string to customize check failure message
// - default: empty array (no default) or singleton array => default value for this type
// - fold: none, auto (equivalent to (a, b) => a + b but more efficient) or function (prev, next) => folded value:
//         determines how to combine two consecutive values of this type in the stylechain
#let base-typeinfo = (
  (type-key): true,
  type-kind: "base",
  version: type-version,
  name: "unknown",
  input: (),
  output: (),
  data: none,
  check: none,
  cast: none,
  error: none,
  default: (),
  fold: none,
)

// Top type
// input and output have "any".
#let any = (
  ..base-typeinfo,
  type-kind: "any",
  name: "any",
  input: ("any",),
  output: ("any",),
)

// Bottom type
// input and output are empty.
#let never = (
  ..base-typeinfo,
  type-kind: "never",
  name: "never",
  input: (),
  output: (),
)

// Any custom type
#let custom-type = (
  ..base-typeinfo,
  (type-key): "custom type",
  name: "custom type",
  input: ("custom type",),
  output: ("custom type",),
)

#let _sequence = [].func()

#let element(name, eid) = (
  ..base-typeinfo,
  type-kind: "element",
  name: "element '" + name + "'",
  input: (content,),
  output: (content,),
  check: c => c.func() == _sequence and data(c).eid == eid,
  data: (name: name, eid: eid),
  error: c => "expected element " + name + ", found " + func-name(c),
)

#let native-elem(func) = {
  assert(type(func) == function, message: "elembic: types.native-elem: expected native element constructor, got " + str(type(func)))

  (
    ..base-typeinfo,
    type-kind: "native-element",
    name: "native element '" + repr(func) + "'",
    input: (content,),
    output: (content,),
    check: if func == _sequence { c => c.func() == _sequence and data(c).eid == none } else { c => c.func() == func },
    data: (func: func),
    error: c => "expected native element " + repr(func) + ", found " + func-name(c),
  )
}

// Get the type ID of a value.
// This is usually 'type(value)', unless value has a custom type.
// In that case, it has the format '(tid: ..., name: ...)'.
// This is the format expected by 'input' and 'output' arrays.
#let typeid(value) = {
  let value-type = type(value)
  if value-type == dictionary and custom-type-key in value {
    value-type = value.at(custom-type-key).id
  }
  value-type
}

// Returns the name of the value's type as a string.
#let typename(value) = {
  let value-type = type(value)
  if value-type == dictionary and custom-type-key in value {
    let id = value.at(custom-type-key).id
    if "name" in id {
      id.name
    } else {
      str(id)
    }
  } else {
    str(value-type)
  }
}

// Make a unique element or type ID based on prefix and name.
//
// Uses a separator and a "bit stuffing" technique to ensure
// the separator sequence doesn't appear in either of the
// prefix or the name in the final ID.
#let id-separator = "_---_"
#let trimmed-separator = id-separator.trim("_", at: end)
#let unique-id(kind, prefix, name) = {
  (
    kind + "_"
  ) + prefix.replace(
    trimmed-separator, trimmed-separator + "-"
  ) + id-separator + name.replace(
    trimmed-separator, trimmed-separator + "-"
  )
}

// Literal type
// Only accepted if value is equal to the literal.
// Input and output are equal to the value.
//
// Uses base typeinfo information for information such as casts and whatnot.
#let literal(value, typeinfo) = {
  let represented = "'" + if type(value) == str { value } else { repr_(value) } + "'"
  let value-type = typeid(value)

  let check = if typeinfo.check == none { x => eq(x, value) } else { x => eq(x, value) and (typeinfo.check)(x) }

  (
    ..typeinfo,
    type-kind: "literal",
    name: "literal " + represented,
    data: (value: value, typeinfo: typeinfo, represented: represented),
    check: check,
    error: _ => "given value wasn't equal to literal " + represented,
    default: (value,),
  )
}

// Union type (one of many)
// Data is the list of typeinfos.
// Accepted if the value corresponds to one of the given types.
// Does not check the validity of typeinfos.
#let union(typeinfos) = {
  // Flatten nested unions
  let typeinfos = typeinfos.map(t => if t.type-kind == "union" { t.data } else { (t,) }).sum(default: ()).dedup()
  if typeinfos == () {
    // No inputs accepted...
    return never
  }
  if typeinfos.len() == 1 {
    // Simplify union if there's nothing else
    return typeinfos.first()
  }
  if typeinfos.any(x => x.type-kind == "any") {
    // Union with 'any' is just any
    return any
  }

  let name = typeinfos.map(t => t.name).join(", ", last: " or ")
  let input = typeinfos.map(t => t.input).sum(default: ()).dedup()
  let output = typeinfos.map(t => t.output).sum(default: ()).dedup()

  let has-any-input = "any" in input
  let has-any-output = "any" in output

  if has-any-input {
    input = ("any",)
  }

  if has-any-output {
    output = ("any",)
  }

  // Try to optimize checks as much as possible
  let check = if typeinfos.all(t => t.check == none) {
    // If there are no checks, just checking inputs is enough
    none
  } else {
    let checked-types = typeinfos.filter(t => t.check != none)
    let unchecked-inputs = typeinfos.filter(t => t.check == none).map(t => t.input).sum(default: ()).dedup()
    if input.all(t => t in unchecked-inputs) {
      // Unchecked types include all possible input types, so some check will always succeed
      // Note that this check also works for input reduced to just "any". If "any" is an
      // unchecked input, then checks will never fail.
      none
    } else if checked-types.all(t => t.type-kind == "native-element" and ("__future_cast" not in t or t.__future_cast.max-version < type-version)) {
      // From here onwards, we can assume unchecked-inputs doesn't contain "any",
      // since it is a subset of input, therefore input would be just ("any",) and
      // the check above would have had to pass in that case.
      let all-funcs = checked-types.map(t => t.data.func)
      let non-seq-funcs = all-funcs.filter(f => f != _sequence)
      let has-seq = _sequence in all-funcs

      // Check sequence separately, as a sequence can also be a custom element,
      // so we must tell them apart.
      if has-seq {
        if non-seq-funcs == () {
          x => {
            let typ = type(x)
            if typ == dictionary and custom-type-key in x {
              // Custom type must be checked differently in inputs
              typ = x.at(custom-type-key).id
            }
            typ in unchecked-inputs or typ == content and x.func() == _sequence and data(x).eid == none
          }
        } else {
          x => {
            let typ = type(x)
            if typ == dictionary and custom-type-key in x {
              // Custom type must be checked differently in inputs
              typ = x.at(custom-type-key).id
            }
            typ in unchecked-inputs or typ == content and (x.func() in non-seq-funcs or x.func() == _sequence and data(x).eid == none)
          }
        }
      } else {
        x => {
          let typ = type(x)
          if typ == dictionary and custom-type-key in x {
            // Custom type must be checked differently in inputs
            typ = x.at(custom-type-key).id
          }
          typ in unchecked-inputs or typ == content and x.func() in non-seq-funcs
        }
      }
    } else if checked-types.all(t => t.type-kind == "element" and ("__future_cast" not in t or t.__future_cast.max-version < type-version)) {
      let all-eids = checked-types.map(t => t.data.eid)

      x => {
        let typ = type(x)
        if typ == dictionary and custom-type-key in x {
          // Custom type must be checked differently in inputs
          typ = x.at(custom-type-key).id
        }
        typ in unchecked-inputs or typ == content and x.func() == _sequence and data(x).eid in all-eids
      }
    } else if checked-types.all(t => t.type-kind == "literal" and ("__future_cast" not in t or t.__future_cast.max-version < type-version)) {
      let values-inputs-and-checks = checked-types.map(t => (t.data.value, t.input, t.data.typeinfo.check))
      x => {
        let typ = type(x)
        if typ == dictionary and custom-type-key in x {
          // Custom type must be checked differently in inputs
          typ = x.at(custom-type-key).id
        }
        typ in unchecked-inputs or values-inputs-and-checks.any(((v, i, check)) => eq(x, v) and (typ in i or "any" in i) and (check == none or check(x)))
      }
    } else {
      // If any check succeeds and the value has the correct input type, OK
      let checks-and-inputs = checked-types.map(t => (t.input, t.check))
      x => {
        let typ = type(x)
        if typ == dictionary and custom-type-key in x {
          // Custom type must be checked differently in inputs
          typ = x.at(custom-type-key).id
        }
        // If one of the types without checks accepts this type as an input then we don't need
        // to run any checks!
        typ in unchecked-inputs or checks-and-inputs.any(((inp, check)) => (typ in inp or "any" in inp) and check(x))
      }
    }
  }

  // Try to optimize casts
  let cast = if typeinfos.all(t => t.cast == none) {
    none
  } else {
    let casting-types = typeinfos.filter(t => t.cast != none)
    let first-casting-type = casting-types.first()
    if (
      // If the casting types are all native, and none of the types before them
      // accept their "cast-from" types, then we can fast track to a simple check:
      // if within the 'cast-from' types, then cast, otherwise don't.
      casting-types != ()
      and casting-types.all(t => t.type-kind == "native" and t.data in (float, content) and ("__future_cast" not in t or t.__future_cast.max-version < type-version))
      and typeinfos.find(t => t.input.any(i => i == "any" or i in first-casting-type.input)) == first-casting-type
      and (casting-types.len() == 1 or typeinfos.find(t => t.input.any(i => i == "any" or i in casting-types.at(1).input)) == casting-types.at(1))
    ) {
      if casting-types.len() >= 2 {  // just float and content
        x => if type(x) == int { float(x) } else if x == none or type(x) in (str, symbol) [#x] else { x }
      } else if first-casting-type.data == float {  // just float
        x => if type(x) == int { float(x) } else { x }
      } else { // just content
        x => if x == none or type(x) in (str, symbol) { [#x] } else { x }
      }
    } else {
      // Generic case
      x => {
        let typ = type(x)
        if typ == dictionary and custom-type-key in x {
          // Custom type must be checked differently in inputs
          typ = x.at(custom-type-key).id
        }
        let typeinfo = typeinfos.find(t => (typ in t.input or "any" in t.input) and (t.check == none or (t.check)(x)))
        if typeinfo.cast == none {
          x
        } else {
          (typeinfo.cast)(x)
        }
      }
    }
  }

  let error = if typeinfos.all(t => t.error == none) {
    none
  } else if typeinfos.all(t => t.type-kind == "literal" and ("__future_cast" not in t or t.__future_cast.max-version < type-version)) {
    let literals = typeinfos.map(t => str(t.data.represented)).join(", ", last: " or ")
    let message = "given value wasn't equal to literals " + literals
    x => message
  } else if typeinfos.all(t => t.type-kind == "native-element" and ("__future_cast" not in t or t.__future_cast.max-version < type-version)) {
    let funcs = typeinfos.map(t => repr(t.data.func)).join(", ", last: " or ")
    let head = "expected native elements " + funcs + ", found "
    x => head + {
      if type(x) == content { func-name(x) } else { "a(n) " + typename(x) }
    }
  } else if typeinfos.all(t => (t.type-kind == "element" or t.type-kind == "native-element") and ("__future_cast" not in t or t.__future_cast.max-version < type-version)) {
    let funcs = typeinfos.map(t => if t.type-kind == "element" { t.data.name } else { repr(t.data.func) + " (native)" }).join(", ", last: " or ")
    let head = "expected elements " + funcs + ", found "
    x => head + {
      if type(x) == content { func-name(x) } else { "a(n) " + typename(x) }
    }
  } else {
    let error-types = typeinfos.filter(t => t.error != none)
    x => {
      "all typechecks for union failed" + error-types.map(t => "\n  hint (" + t.name + "): " + (t.error)(x)).sum(default: "")
    }
  }

  let is-option = typeinfos.first().type-kind == "native" and typeinfos.first().data == type(none)
  let is-smart = typeinfos.first().type-kind == "native" and typeinfos.first().data == type(auto)

  if is-smart != is-option and typeinfos.len() == 3 and typeinfos.at(1).type-kind == "native" and typeinfos.at(1).data in (type(none), type(auto)) {
    // Both first types are (none, auto)
    is-smart = true;
    is-option = true;
  }

  let default = if is-option or is-smart {
    // Default of 'none' for option(...)
    // Default of 'auto' for smart(...)
    typeinfos.first().default
  } else {
    ()
  }

  let fold = if typeinfos.all(t => t.fold == none) or typeinfos.any(t => "any" in t.output) {
    // We'd like to handle folding with "any" output in the future, but for now, let's not
    none
  } else if (is-option or is-smart) and typeinfos.len() == 2 and typeinfos.last().fold != none {
    // Match built-in behavior by only folding option(T) or smart(T) if T can fold and the inner isn't explicitly none/auto
    let other-typeinfo = typeinfos.at(1)
    let other-fold = other-typeinfo.fold
    if is-option {
      if other-fold == auto {
        (outer, inner) => if inner != none and outer != none { outer + inner } else { inner }
      } else {
        (outer, inner) => if inner != none and outer != none { other-fold(outer, inner) } else { inner }
      }
    } else {
      if other-fold == auto {
        (outer, inner) => if inner != auto and outer != auto { outer + inner } else { inner }
      } else {
        (outer, inner) => if inner != auto and outer != auto { other-fold(outer, inner) } else { inner }
      }
    }
  } else if is-option and is-smart and typeinfos.len() == 3 and typeinfos.last().fold != none {
    // smart(option(T))
    // and option(smart(T))
    let other-typeinfo = typeinfos.last()
    let other-fold = other-typeinfo.fold
    if other-fold == auto {
      (outer, inner) => if inner != none and inner != auto and outer != none and outer != auto { outer + inner } else { inner }
    } else {
      (outer, inner) => if inner != none and inner != auto and outer != none and outer != auto { other-fold(outer, inner) } else { inner }
    }
  } else {
    // Arbitrary union folding is allowed if the different casted values would
    // belong to the same union type.
    // Otherwise, can't do much if e.g. an int could be typeinfo A (say, positive integer)
    // or typeinfo B (say, negative integer) because checks apply to inputs and not outputs
    // (unless, of course, there is no casting).
    // However, if there is only one typeinfo with a given output type, it is
    // not ambiguous and may fold.
    let unsure-outputs = () // array of (output type)
    let unsure-output-data = () // array of ((i, fold, output))
    let ambiguous-outputs = () // array of (output type)

    for (i, typeinfo) in typeinfos.enumerate() {
      for output in typeinfo.output.dedup() {
        // NOTE: we assume 'output != "any"' as we filter that out in a
        // previous conditional.
        if output in unsure-outputs {
          ambiguous-outputs.push(output)

          // Invariant: there are no duplicate output types in 'unsure-outputs'.
          // The only time we push to unsure-outputs is after this check fails,
          // so that is always true.
          let output-index = unsure-outputs.position(t => t == output)
          _ = unsure-outputs.remove(output-index)
          _ = unsure-output-data.remove(output-index)
        } else if output != "never" and output not in ambiguous-outputs {
          unsure-outputs.push(output)
          unsure-output-data.push((i, typeinfo.fold, output))
        }
      }
    }

    // No conflicts found for those types
    let unambiguous-outputs = unsure-output-data

    let func(outer, inner) = {
      let outer-id = typeid(outer)
      let inner-id = typeid(inner)
      let outer-output = unambiguous-outputs.find(((_, _, output)) => outer-id == output)
      let inner-output = unambiguous-outputs.find(((_, _, output)) => inner-id == output)
      let folder = if inner-output == none or outer-output == none or outer-output.first() != inner-output.first() {
        // They belong to different types in the union, so no folding can be
        // performed, even if they have the same fold function, since it still
        // expects them to have the appropriate type.
        //
        // This branch is also reached when neither type is found. This
        // suggests both belong to ambiguous output types and must not
        // be folded.
        return inner
      } else {
        // They belong to the same type with the same fold
        outer-output.at(1)
      }

      if folder == none {
        inner
      } else if folder == auto {
        // Caution: addition order matters!
        // Could be arrays, for example.
        outer + inner
      } else {
        folder(outer, inner)
      }
    }

    if unambiguous-outputs == () {
      none
    } else {
      func
    }
  }

  (
    ..base-typeinfo,
    type-kind: "union",
    name: name,
    data: typeinfos,
    input: input,
    output: output,
    check: check,
    cast: cast,
    error: error,
    default: default,
    fold: fold,
  )
}

// A result to indicate success and return a value.
#let ok(value) = {
  (true, value)
}

// A result to indicate failure, with an error value indicating what happened.
#let err(error) = {
  (false, error)
}

// Whether this result was successful.
#let is-ok(result) = {
  type(result) == array and result.len() == 2 and result.first() == true
}

// Wrap a typeinfo with some other data.
// Mostly unchecked variant of 'types.wrap'.
#let wrap(typeinfo, overrides) = {
  (
    (..typeinfo, type-kind: "wrapped", data: (base: typeinfo, extra: none))
    + for (key, default) in base-typeinfo {
      if key == type-key or key == "type-kind" {
        continue
      }

      if key in overrides {
        let override = overrides.at(key)

        if key == "data" {
          (data: (base: typeinfo, extra: override))
        } else {
          ((key): override)
        }
      }
    }
  )
}

// A particular collection of types.
#let collection(name, base, parameters, check: none, cast: none, error: none, ..args) = {
  if check == none {
    check = base.check
  }

  if cast == none {
    cast = base.cast
  }

  if check == none and error == none {
    error = base.error
  }

  let other-args = args.named()
  let default = if "default" in other-args {
    other-args.default
  } else {
    base.default
  }

  let fold = if "fold" in other-args {
    other-args.fold
  } else {
    base.fold
  }

  (
    ..base,
    type-kind: "collection",
    name: name + if parameters != () { " of " + parameters.map(t => t.name).join(", ", last: " and ") },
    data: (base: base, parameters: parameters),
    check: check,
    cast: cast,
    error: error,
    default: default,
    fold: fold,
  )
}

// Create an array collection with a uniform parameter typeinfo for its elements.
#let array_(base-type, param, error: none) = {
  assert(array in base-type.input or "any" in base-type.input)
  let kind = param.type-kind

  collection(
    "array",
    base-type,
    (param,),
    check: if param.check == none and "any" in param.input {
      none
    } else if param.input == () {
      // Propagate 'never'
      _ => false
    } else if "any" in param.input {
      // Only need to run checks
      a => a.all(param.check)
    } else {
      // Some optimizations ahead
      // The proper code is at the bottom
      let input = param.input
      let check = param.check
      if kind == "native" and param.data == dictionary and ("__future_cast" not in param or param.__future_cast.max-version < type-version) {
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
        a => a.all(x => typeid(x) in param.input)
      } else {
        a => a.all(x => typeid(x) in param.input and check(x))
      }
    },

    cast: if param.cast == none {
      none
    } else if kind == "native" and param.data == content and ("__future_cast" not in param or param.__future_cast.max-version < type-version) {
      a => a.map(x => [#x])
    } else {
      a => a.map(param.cast)
    },

    error: error
  )
}

// Create a dict with a uniform parameter typeinfo for its values.
// (Keys are always strings.)
#let dict_(base-type, param, error: none) = {
  assert(dictionary in base-type.input or "any" in base-type.input)
  let kind = param.type-kind

  collection(
    "dict",
    base-type,
    (param,),
    check: {
      // Simply check the array of values
      // (We can pass 'any' as the base type since that doesn't affect the 'check')
      let array-check = array_(any, param).check
      if array-check == none {
        none
      } else {
        d => array-check(d.values())
      }
    },

    cast: if param.cast == none {
      none
    } else if kind == "native" and param.data == content and ("__future_cast" not in param or param.__future_cast.max-version < type-version) {
      d => {
        for (k, v) in d {
          d.at(k) = [#v]
        }
        d
      }
    } else {
      let cast = param.cast
      d => {
        for (k, v) in d {
          d.at(k) = cast(v)
        }
        d
      }
    },

    error: error,

    fold: if param.fold == none {
      base-type.fold
    } else if param.fold == auto {
      (outer, inner) => {
        let combined = outer + inner

        for (k, v) in outer {
          if k in inner {
            combined.at(k) = v + inner.at(k)
          }
        }

        combined
      }
    } else if type(param.fold) == function {
      (outer, inner) => {
        let combined = outer + inner

        for (k, v) in outer {
          if k in inner {
            combined.at(k) = (param.fold)(v, inner.at(k))
          }
        }

        combined
      }
    } else {
      assert(false, message: "elembic: types.dict: parameter didn't have a valid fold function")
    }
  )
}
