#import "data.typ": type-key, custom-type-key, current-field-version, eq
#import "types/types.typ"

#let field-key = "__elembic_field"
#let fields-key = "__elembic_fields"

#let _missing() = {}

// Specifies an element field's properties.
#let field(
  name,
  type_,
  doc: none,
  required: false,
  named: auto,
  synthesized: false,
  default: _missing,
  folds: true,
  internal: false,
  meta: (:),
) = {
  assert(type(name) == str, message: "elembic: field: Field name must be a string, not " + str(type(name)))

  let error-prefix = "elembic: field '" + name + "': "
  assert(doc == none or type(doc) == str, message: error-prefix + "'doc' must be none or a string (add documentation)")
  assert(type(synthesized) == bool, message: error-prefix + "'synthesized' must be a boolean (true: field is automatically synthesized and cannot be specified or overridden by the user; false: field can be manually specified and overridden by the user)")
  assert(type(required) == bool, message: error-prefix + "'required' must be a boolean")
  assert(type(folds) == bool, message: error-prefix + "'folds' must be a boolean")
  assert(type(internal) == bool, message: error-prefix + "'internal' must be a boolean")
  assert(type(meta) == dictionary, message: error-prefix + "'meta' must be a dictionary")
  assert(named == auto or type(named) == bool, message: error-prefix + "'named' must be a boolean or auto")
  let typeinfo = {
    let (res, value) = types.validate(type_)
    assert(res, message: if not res { error-prefix + value } else { "" })
    value
  }

  if not required and default == _missing {
    let (res, value) = types.default(typeinfo)
    assert(res, message: if not res { error-prefix + value } else { "" })

    default = value
  }

  default = if required or synthesized {
    // This value should be ignored in that case
    auto
  } else {
    let (success, value) = types.cast(default, typeinfo)
    if not success {
      assert(false, message: error-prefix + value + "\n  hint: given default for field had an incompatible type")
    }

    value
  }

  let fold = if folds and not synthesized and "fold" in typeinfo and typeinfo.fold != none {
    assert(typeinfo.fold == auto or type(typeinfo.fold) == function, message: error-prefix + "type '" + typeinfo.name + "' doesn't appear to have a valid fold field (must be auto or function)")
    let fold-default = if required {
      // No field default, use the type's own default to begin folding
      let (res, value) = types.default(typeinfo)
      assert(res, message: if not res { error-prefix + value } else { "" })

      value
    } else {
      // Use the field default as starting point for folding
      default
    }

    (
      folder: typeinfo.fold,
      default: fold-default,
    )
  } else {
    none
  }

  if named == auto {
    // Pos arg is generally required
    named = not required
  }

  if synthesized and (required or not named) {
    assert(false, message: error-prefix + "synthesized field cannot be required or positional, since it cannot be specified by the user")
  }

  (
    (field-key): true,
    version: current-field-version,
    name: name,
    doc: doc,
    typeinfo: typeinfo,
    default: default,
    required: required,
    synthesized: synthesized,
    named: named,
    fold: fold,
    folds: folds,
    internal: internal,
    meta: meta,
  )
}

#let parse-fields(fields, allow-unknown-fields: false) = {
  assert(type(allow-unknown-fields) == bool, message: "elembic: element.fields: 'allow-unknown-fields' must be a boolean, not " + str(type(allow-unknown-fields)))

  let required-pos-fields = ()
  let optional-pos-fields = ()
  let required-named-fields = ()
  let optional-named-fields = ()
  let all-fields = (:)
  let user-named-fields = (:)
  let foldable-fields = (:)
  let user-fields = (:)
  let synthesized-fields = (:)

  for field in fields {
    assert(type(field) == dictionary and field.at(field-key, default: none) == true, message: "elembic: element.fields: Invalid field received, please use the 'e.fields.field' constructor.")
    assert(field.named or not field.required or optional-pos-fields == (), message: "elembic: element.fields: field '" + field.name + "' cannot be positional and required and appear after other positional but optional fields. Ensure there are only optional fields after the first positional optional field.")
    assert(field.name not in all-fields, message: "elembic: element.fields: duplicate field name '" + field.name + "'")

    if field.required {
      if field.named {
        required-named-fields.push(field)
      } else {
        required-pos-fields.push(field)
      }
    } else if field.named {
      optional-named-fields.push(field)
    } else {
      optional-pos-fields.push(field)
    }

    if field.fold != none {
      foldable-fields.insert(field.name, field.fold)
    }

    if field.synthesized {
      synthesized-fields.insert(field.name, field)
    } else {
      user-fields.insert(field.name, field)

      if field.named {
        user-named-fields.insert(field.name, field)
      }
    }

    all-fields.insert(field.name, field)
  }

  (
    (fields-key): true,
    version: current-field-version,
    required-pos-fields: required-pos-fields,
    optional-pos-fields: optional-pos-fields,
    required-named-fields: required-named-fields,
    optional-named-fields: optional-named-fields,
    foldable-fields: foldable-fields,
    user-named-fields: user-named-fields,
    user-fields: user-fields,
    all-fields: all-fields,
    allow-unknown-fields: allow-unknown-fields,
  )
}

// Generates an argument parser function with the given general error
// prefix (for listing missing fields) and per-field error prefix function
// (for an invalid field; receives the field name).
//
// You can customize 'field-term' to customize what the word "field" is
// in error messages. It should be either a string or a two-element
// array with (singular, plural). Setting 'typecheck: false' also fully
// disables typechecking.
//
// Parse arguments into a dictionary of fields and their casted values.
// By default, include required arguments and error if they are missing.
// Setting 'include-required' to false will error if they are present
// instead.
#let generate-arg-parser(
  fields: none,
  general-error-prefix: "",
  field-error-prefix: _ => "",
  field-term: "field",
  typecheck: true,
) = {
  assert(type(fields) == dictionary and fields-key in fields, message: "elembic: generate-arg-parser: please use 'parse-fields' to generate the fields input.")
  assert(type(general-error-prefix) == str, message: "elembic: generate-arg-parser: 'general-error-prefix' must be a string")
  assert(type(field-error-prefix) == function, message: "elembic: generate-arg-parser: 'field-error-prefix' must be a function receiving field name and returning string")
  assert(type(typecheck) == bool, message: "elembic: generate-arg-parser: 'typecheck' must be a boolean, not " + str(type(typecheck)))

  let (field-singular, field-plural) = if type(field-term) == str {
    (field-term, field-term + "s")
  } else if type(field-term) == array and field-term.len() == 2 and field-term.all(term => type(term) == str) {
    field-term
  } else {
    assert(false, message: "elembic: generate-arg-parser: 'field-term' must either be a string (plural with 's') or a two-element array of strings (singular, plural).")
  }

  let (required-pos-fields, optional-pos-fields, required-named-fields, optional-named-fields, all-fields, user-fields, user-named-fields, allow-unknown-fields) = fields
  let required-pos-fields-amount = required-pos-fields.len()
  let optional-pos-fields-amount = optional-pos-fields.len()
  let total-pos-fields-amount = required-pos-fields-amount + optional-pos-fields-amount
  let all-pos-fields = required-pos-fields + optional-pos-fields

  let has-required-fields = required-pos-fields-amount + required-named-fields.len() != 0

  // If we allow unknown named fields, we still need to check whether a
  // positional or synthesized field was accidentally specified as a named field.
  let is-unknown-named-field = if allow-unknown-fields {
    f => f in all-fields and f not in user-named-fields
  } else {
    f => f not in user-named-fields
  }

  // Disable typechecking anyway if all fields are 'any'
  //
  // Have a separate typecheck option so type information can be kept in fields
  // even if typechecking is undesirable
  // Note: we don't parse args for synthesized fields, so we can exclude them when
  // checking whether we will typecheck when parsing args
  let typecheck = typecheck and user-fields.values().any(f => f.typeinfo.type-kind != "any")

  // Parse args (no typechecking)
  let parse-args-no-typechecking(args, include-required: true) = {
    let pos = args.pos()

    if include-required and pos.len() < required-pos-fields-amount {
      // Plural
      let term = if required-pos-fields-amount - pos.len() == 1 { field-singular } else { field-plural }

      return (false, general-error-prefix + "missing positional " + term + " " + fields.required-pos-fields.slice(pos.len()).map(f => "'" + f.name + "'").join(", "))
    }

    if pos.len() > if include-required { total-pos-fields-amount } else { optional-pos-fields-amount } {
      let expected-arg-amount = if include-required { total-pos-fields-amount } else { optional-pos-fields-amount }
      let excluding-required-hint = if include-required { "" } else { "\n  hint: only optional fields are accepted here" }
      return (false, general-error-prefix + "too many positional arguments, expected " + str(expected-arg-amount) + excluding-required-hint)
    }

    let named-args = args.named()
    if include-required {
      if required-named-fields.any(f => f.name not in named-args) {
        let missing-fields = required-named-fields.filter(f => f.name not in named-args)
        let term = if missing-fields.len() == 1 { field-singular } else { field-plural }

        return (false, general-error-prefix + "missing required named " + term + " " + missing-fields.map(f => "'" + f.name + "'").join(", "))
      }
    } else if required-named-fields.any(f => f.name in named-args) {
      let field = required-named-fields.find(f => f.name in named-args)
      return (false, field-error-prefix(field.name) + "this " + field-singular + " cannot be specified here\n  hint: only optional " + field-plural + " are accepted here")
    }

    // Here we simultaneously check for unknown fields and for positional fields
    // being wrongly specified as named. If there are no positional fields and
    // unknown fields are allowed, there is no point in doing this check.
    if (not allow-unknown-fields or total-pos-fields-amount > 0) and named-args.keys().any(is-unknown-named-field) {
      let field-name = named-args.keys().find(is-unknown-named-field)
      let field = all-fields.at(field-name, default: none)
      let expected-pos-hint = if field == none or field.named { "" } else { "\n  hint: this " + field-singular + " must be specified positionally" }
      let is-synthesized-hint = if field != none and field.synthesized { "\n  hint: this " + field-singular + " is synthesized and cannot be specified manually" } else { "" }

      return (false, general-error-prefix + "unknown named " + field-singular + " '" + field-name + "'" + expected-pos-hint + is-synthesized-hint)
    }

    let pos-fields = if include-required { all-pos-fields } else { optional-pos-fields }
    let i = 0
    for value in pos {
      let pos-field = pos-fields.at(i)
      named-args.insert(pos-field.name, value)

      i += 1
    }

    (true, named-args)
  }

  // Parse args (with typechecking)
  let parse-args(args, include-required: true) = {
    let result = (:)

    let pos = args.pos()
    if include-required and pos.len() < required-pos-fields-amount {
      // Plural
      let term = if required-pos-fields-amount - pos.len() == 1 { field-singular } else { field-plural }

      return (false, general-error-prefix + "missing positional " + term + " " + fields.required-pos-fields.slice(pos.len()).map(f => "'" + f.name + "'").join(", "))
    }

    let expected-arg-amount = if include-required { total-pos-fields-amount } else { optional-pos-fields-amount }

    if pos.len() > expected-arg-amount {
      let excluding-required-hint = if include-required { "" } else { "\n  hint: only optional fields are accepted here" }
      return (false, general-error-prefix + "too many positional arguments, expected " + str(expected-arg-amount) + excluding-required-hint)
    }

    let named-args = args.named()

    if include-required and required-named-fields.any(f => f.name not in named-args) {
      let missing-fields = required-named-fields.filter(f => f.name not in named-args)
      let term = if missing-fields.len() == 1 { field-singular } else { field-plural }

      return (false, general-error-prefix + "missing required named " + term + " " + missing-fields.map(f => "'" + f.name + "'").join(", "))
    }

    for (field-name, value) in named-args {
      if allow-unknown-fields and field-name not in all-fields {
        continue
      }

      let field = all-fields.at(field-name, default: none)

      if field == none or field.synthesized or not field.named {
        let expected-pos-hint = if field == none or field.named { "" } else { "\n  hint: this " + field-singular + " must be specified positionally" }
        let is-synthesized-hint = if field != none and field.synthesized { "\n  hint: this " + field-singular + " is synthesized and cannot be specified manually" } else { "" }

        return (false, general-error-prefix + "unknown named " + field-singular + " '" + field-name + "'" + expected-pos-hint + is-synthesized-hint)
      }

      if not include-required and field.required {
        return (false, field-error-prefix(field-name) + "this " + field-singular + " cannot be specified here\n  hint: only optional " + field-plural + " are accepted here")
      }

      let typeinfo = field.typeinfo
      let kind = typeinfo.type-kind

      if kind != "any" {
        let (res, casted) = types.cast(value, typeinfo)
        if not res {
          return (false, field-error-prefix(field-name) + casted)
        }
        named-args.insert(field-name, casted)
      }
    }

    let pos-fields = if include-required { all-pos-fields } else { optional-pos-fields }
    let i = 0
    for value in pos {
      let pos-field = pos-fields.at(i)
      let typeinfo = pos-field.typeinfo
      let kind = typeinfo.type-kind
      let casted = value

      if kind != "any" {
        let res
        (res, casted) = types.cast(value, typeinfo)
        if not res {
          return (false, field-error-prefix(pos-field.name) + casted)
        }
      }

      named-args.insert(pos-field.name, casted)

      i += 1
    }

    (true, named-args)
  }

  if typecheck {
    parse-args
  } else {
    parse-args-no-typechecking
  }
}
