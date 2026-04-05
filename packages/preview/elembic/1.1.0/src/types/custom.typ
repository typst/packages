// Custom types!
#import "../data.typ": special-data-values, custom-type-key, custom-type-data-key, type-key, custom-type-version
#import "base.typ"
#import "types.typ"
#import "../fields.typ" as field-internals

// Default folding procedure for custom types.
// Combines each inner type individually.
#let auto-fold(foldable-fields) = if foldable-fields == (:) {
  // No fields to fold, so 'inner' always fully overwrites 'outer'.
  // In that case, we can just sum inner with outer, adding its fields
  // on top.
  auto
} else {
  (outer, inner) => {
    let combined = outer + inner

    for (field-name, fold-data) in foldable-fields {
      if field-name in inner {
        let outer = outer.at(field-name, default: fold-data.default)
        if fold-data.folder == auto {
          combined.at(field-name) = outer + inner.at(field-name)
        } else {
          combined.at(field-name) = (fold-data.folder)(outer, inner.at(field-name))
        }
      }
    }

    combined
  }
}

#let auto-cast(from, fields: (:), constructor: none) = {
  if from == dictionary {
    value => constructor(..value)
  } else {
    assert(false, message: "elembic: types.auto-cast: invalid auto cast type: 'from' must be dictionary.")
  }
}

#let auto-cast-check(from, fields: (:), parse-args: none) = {
  if from == dictionary {
    value => parse-args(arguments(..value)).first()
  } else {
    assert(false, message: "elembic: types.auto-cast: invalid auto cast type: 'from' must be dictionary.")
  }
}

#let auto-cast-error(from, fields: (:), parse-args: none) = {
  if from == dictionary {
    value => parse-args(arguments(..value)).at(1)
  } else {
    assert(false, message: "elembic: types.auto-cast: invalid auto cast type: 'from' must be dictionary.")
  }
}

#let declare(
  name,
  fields: none,
  prefix: none,
  doc: none,
  default: none,
  parse-args: auto,
  typecheck: true,
  allow-unknown-fields: false,
  construct: none,
  scope: none,
  casts: none,
  fold: auto,
) = {

  let fields-hint = if type(fields) == dictionary { "\n  hint: check if you didn't forget to add a trailing comma for a single field: write 'fields: (field,)', not 'fields: (field)'" } else { "" }
  let casts-hint = if type(casts) == dictionary { "\n  hint: check if you didn't forget to add a trailing comma for a single cast: write 'casts: ((from: ..., with: ...),)', not 'casts: ((from: ..., with: ...))'" } else { "" }
  assert(type(fields) == array, message: "elembic: types.declare: please specify an array of fields, creating each field with the 'field' function." + fields-hint)
  assert(prefix != none, message: "elembic: types.declare: please specify a 'prefix: ...' for your type, to distinguish it from types with the same name. If you are writing a package or template to be used by others, please do not use an empty prefix.")
  assert(type(prefix) == str, message: "elembic: types.declare: the prefix must be a string, not '" + str(type(prefix)) + "'")
  assert(doc == none or type(doc) == str, message: "elembic: types.declare: 'doc' must be none or a string (add documentation)")
  assert(parse-args == auto or type(parse-args) == function, message: "elembic: types.declare: 'parse-args' must be either 'auto' (use built-in parser) or a function (default arg parser, fields: dictionary, typecheck: bool) => (user arguments, include-required: true) => (bool (true on success, false on error), dictionary with parsed fields (or error message string if the bool is false)).")
  assert(type(typecheck) == bool, message: "elembic: types.declare: the 'typecheck' argument must be a boolean (true to enable typechecking in the constructor, false to disable).")
  assert(type(allow-unknown-fields) == bool, message: "elembic: types.declare: the 'allow-unknown-fields' argument must be a boolean.")
  assert(construct == none or type(construct) == function, message: "elembic: types.declare: 'construct' must be 'none' (use default constructor) or a function receiving the original constructor and returning the new constructor.")
  assert(default == none or type(default) == function, message: "elembic: types.declare: 'default' must be none or a function receiving the constructor and returning the default.")
  assert(scope == none or type(scope) in (dictionary, module), message: "elembic: types.declare: 'scope' must be either 'none', a dictionary or a module")
  assert(
    casts == none
    or type(casts) == array and casts.all(
      d => (
        type(d) == dictionary
        and "from" in d
        and d.keys().all(k => k in ("from", "with", "check"))
        and ("with" not in d or type(d.with) == function)
        and ("check" not in d or d.check == none or type(d.check) == function)
      )
    ),
    message: "elembic: types.declare: 'casts' must be either 'none' or an array of dictionaries in the form (from: type, check (optional): none or casted value => bool, with (optional when 'from' is dictionary): constructor => casted value => your type)." + casts-hint
  )
  assert(fold == none or fold == auto or type(fold) == function, message: "elembic: types.declare: 'fold' must be 'none' (no folding), 'auto' (fold each field individually) or a function 'default constructor => auto (same as (a, b) => a + b but more efficient) or function (outer, inner) => combined value'.")

  let type-args = (
    name: name,
    fields: fields,
    prefix: prefix,
    doc: doc,
    default: default,
    parse-args: parse-args,
    typecheck: typecheck,
    allow-unknown-fields: allow-unknown-fields,
    construct: construct,
    scope: scope,
    casts: casts,
    fold: fold,
  )

  let tid = base.unique-id("t", prefix, name)
  let fields = field-internals.parse-fields(fields, allow-unknown-fields: allow-unknown-fields)
  let (all-fields, user-fields, foldable-fields) = fields
  let auto-fold = if fold == auto { auto-fold(foldable-fields) } else { none }

  let default-arg-parser = field-internals.generate-arg-parser(
    fields: fields,
    general-error-prefix: "elembic: type '" + name + "': ",
    field-error-prefix: field-name => "field '" + field-name + "' of type '" + name + "': ",
    typecheck: typecheck
  )

  let parse-args = if parse-args == auto {
    default-arg-parser
  } else {
    let parse-args = parse-args(default-arg-parser, fields: fields, typecheck: typecheck)
    if type(parse-args) != function {
      assert(false, message: "elembic: types.declare: 'parse-args', when specified as a function, receives the default arg parser alongside `fields: fields dictionary` and `typecheck: bool`, and must return a function (the new arg parser), and not " + base.typename(parse-args))
    }

    parse-args
  }

  let default-fields = fields.user-fields.values().map(f => if f.required { (:) } else { ((f.name): f.default) }).sum(default: (:))

  let typeid = (tid: tid, name: name)

  // We will specify default in a bit, once we declare the constructor
  let typeinfo = (
    ..base.base-typeinfo,
    type-kind: "custom",
    name: name,
    input: (typeid,),
    output: (typeid,),
    data: (
      id: typeid,

      // Original type before adding casts
      // or none if this is already the type before casts
      // (used for 'exact()')
      pre-casts: none
    )
  )

  let type-data = (
    (custom-type-data-key): true,
    (custom-type-key): (
        data-kind: "type-instance",
        fields: (
          version: custom-type-version,
          tid: tid,
          id: typeid,
        ),
        func: declare,
        default-constructor: declare,
        tid: "b_custom type",
        id: "custom type",
        fields-known: true,
        valid: true
    ),
    version: custom-type-version,
    name: name,
    doc: doc,
    tid: tid,
    id: typeid,
    // We will add this here once the constructor is declared
    typeinfo: none,
    scope: scope,
    parse-args: parse-args,
    default-fields: default-fields,
    user-fields: user-fields,
    all-fields: all-fields,
    fields: fields,
    typecheck: typecheck,
    allow-unknown-fields: allow-unknown-fields,
    default-constructor: none,
    func: none,
    type-args: type-args,
  )

  let process-casts = if casts == none {
    none
  } else {
    // Trick: We assign cast to each cast-from type and create a union,
    // and use its generated check/cast functions as our own
    default-constructor => {
      let typeinfos = casts.map(cast => {
        let (res, from) = types.validate(cast.from)
        if not res {
          assert(false, message: "elembic: types.declare: invalid cast-from type: " + from)
        }

        let (cast-check, with, cast-error) = if "with" in cast {
          (cast.at("check", default: none), (cast.with)(default-constructor), none)
        } else if from.type-kind == "native" and from.data == dictionary {
          assert(fields.required-pos-fields == (), message: "elembic: types.declare: cannot generate automatic cast from dict when there are required positional fields.")

          if "check" in cast {
            (
              cast.check,
              auto-cast(dictionary, fields: fields, constructor: default-constructor),
              none,
            )
          } else {
            (
              auto-cast-check(dictionary, fields: fields, parse-args: parse-args),
              auto-cast(dictionary, fields: fields, constructor: default-constructor),
              auto-cast-error(dictionary, fields: fields, parse-args: parse-args),
            )
          }
        } else {
          assert(
            false,
            message: "elembic: types.declare: cast 'with' can only be omitted for 'from: dictionary'. It must receive the default constructor and return a function 'casted value => your type'."
          )
        }

        if type(with) != function {
          assert(
            false,
            message: "elembic: types.declare: cast 'with' must receive the default constructor and return a function 'casted value => your type'. Received " + base.typename(with)
          )
        }

        let from-cast = from.cast

        types.wrap(
          from,
          check: from-check => if from-check == none {
            if cast-check == none {
              none
            } else if from.cast == none {
              cast-check
            } else {
              value => cast-check(from-cast(value))
            }
          } else if cast-check == none {
            from-check
          } else if from.cast == none {
            value => from-check(value) and cast-check(value)
          } else {
            value => from-check(value) and cast-check(from-cast(value))
          },

          output: (typeid,),

          cast: from-cast => if from-cast == none {
            with
          } else {
            value => with(from-cast(value))
          },

          default: (),
          fold: none,
          ..if cast-error == none { (:) } else { (
            error: if "check" not in from or from.check == none {
              _ => cast-error
            } else {
              from-error => value => if from-error == none or from-check(value) { cast-error(value) } else { from-error(value) }
            },
          ) }
        )
      })

      // Accept our own typeinfo first and foremost
      let union = base.union((typeinfo,) + typeinfos)

      assert(
        union.output == (typeid,) and union.default == () and union.fold == none,
        message: "elembic: types.declare: internal error: cast generated invalid union: " + repr(union)
      )

      (
        input: union.input,
        output: union.output,
        check: union.check,
        cast: union.cast,
        error: if union.error == none {
          _ => "failed to cast to custom type '" + name + "'"
        } else {
          x => (union.error)(x).replace("all typechecks for union failed", "all casts to custom type '" + name + "' failed")
        },
        data: typeinfo.data + (pre-casts: typeinfo)
      )
    }
  }

  let default-constructor(..args, __elembic_data: none, __elembic_func: auto) = {
    if __elembic_func == auto {
      __elembic_func = default-constructor
    }

    let default-constructor = default-constructor.with(__elembic_func: __elembic_func)
    if __elembic_data != none {
      return if __elembic_data == special-data-values.get-data {
        let typeinfo = typeinfo + if process-casts != none { process-casts(default-constructor) } else { (:) }
        if default != none {
          typeinfo.default = (default(default-constructor),)
        }

        if auto-fold != none {
          typeinfo.fold = auto-fold
        } else if type(fold) == function {
          let fold = fold(default-constructor)
          if fold != auto and type(fold) != function {
            assert(false, message: "elembic: types: custom type did not specify a valid fold, must be a function default constructor => value, got " + base.typename(fold))
          }
          typeinfo.fold = fold
        }

        (data-kind: "custom-type-data", ..type-data, typeinfo: typeinfo, func: __elembic_func, default-constructor: default-constructor)
      } else {
        assert(false, message: "elembic: types: invalid data key to constructor: " + repr(__elembic_data))
      }
    }

    let (res, args) = parse-args(args, include-required: true)
    if not res {
      assert(false, message: args)
    }

    let final-fields = default-fields + args

    if foldable-fields != (:) {
      // Fold received arguments with defaults
      for (field-name, fold-data) in foldable-fields {
        if field-name in args {
          let outer = default-fields.at(field-name, default: fold-data.default)
          if fold-data.folder == auto {
            final-fields.at(field-name) = outer + args.at(field-name)
          } else {
            final-fields.at(field-name) = (fold-data.folder)(outer, args.at(field-name))
          }
        }
      }
    }

    final-fields.insert(
      custom-type-key,
      (
        data-kind: "type-instance",
        fields: final-fields,
        func: __elembic_func,
        default-constructor: default-constructor,
        tid: tid,
        id: (tid: tid, name: name),
        scope: scope,
        fields-known: true,
        valid: true
      )
    )

    final-fields
  }

  default = if default == none {
    ()
  } else {
    let default = default(default-constructor)
    assert(
      type(default) == dictionary and custom-type-key in default and default.at(custom-type-key).id == typeid,
      message: "elembic: types.declare: the 'default' function must return an instance of the new type using the provided constructor, not " + repr(default)
    )


    (default,)
  }

  fold = if auto-fold != none {
    auto-fold
  } else if type(fold) == function {
    let fold = fold(default-constructor)
    if fold != auto and type(fold) != function {
      assert(false, message: "elembic: types.declare: a valid fold was not specified, must be a function default constructor => value, got " + base.typename(fold))
    }
    fold
  } else {
    none
  }

  if process-casts != none {
    typeinfo += process-casts(default-constructor)
  }
  typeinfo.default = default
  typeinfo.fold = fold
  type-data.typeinfo = typeinfo

  let final-constructor = if construct != none {
    {
      let test-construct = construct(default-constructor)
      assert(type(test-construct) == function, message: "elembic: types.declare: the 'construct' function must receive the default constructor and return the new constructor, a new function, not '" + str(type(test-construct)) + "'.")
    }

    let final-constructor(..args, __elembic_data: none) = {
      if __elembic_data != none {
        return if __elembic_data == special-data-values.get-data {
          (data-kind: "custom-type-data", ..type-data, func: final-constructor, default-constructor: default-constructor.with(__elembic_func: final-constructor))
        } else {
          assert(false, message: "elembic: types: invalid data key to constructor: " + repr(__elembic_data))
        }
      }

      construct(default-constructor.with(__elembic_func: final-constructor))(..args)
    }

    final-constructor
  } else {
    default-constructor
  }

  type-data.default-constructor = default-constructor.with(__elembic_func: final-constructor)
  type-data.func = final-constructor

  final-constructor
}
