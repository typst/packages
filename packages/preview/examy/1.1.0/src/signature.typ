/// Plain functions whose arguments are declared the way elembic declares an
/// element's fields, with `e.field`, so that a function and its API
/// documentation come from one declaration.
///
/// Several of examy's exports must stay plain functions rather than elembic
/// elements: `question` and its kin emit their markers eagerly, for the exam
/// pipeline's content scans, and `answer-box` must not hide behind a
/// `context`. Typst cannot introspect a plain function's parameters, so their
/// names, types, defaults and docs would otherwise be written twice, once in
/// the parameter list and once in the docs. Here they are written once, in a
/// spec, which both checks the arguments of every call and is read by
/// docs/api.typ to document the function, exactly as it reads an element's
/// `e.data(..)`.
///
/// The arguments are only *checked* against the declared types, never cast:
/// the function receives each value as it was given. (elembic's own casts
/// would turn a length into a `relative`, a `none` into empty content, or a
/// dictionary of sides into a `stroke`.) A field's *default* is cast all the
/// same, by `e.field` itself, so a union holding a default of `none` lists
/// `none` before `content`, which takes `none` too and would make it `[]`
/// (`e.types.option` does this already); tests/unit/signature.typ checks the
/// defaults.

#import "prelude.typ": e

/// A field's type as a type expression, the way the docs and the error
/// messages write it: `auto | length | none`, with `none` last.
#let describe_type(ti) = {
  let kind = ti.at("type-kind", default: none)
  if kind == "wrapped" {
    // A type that takes more than it says (`e.types.wrap`), as the type
    // inside it.
    describe_type(ti.data.base)
  } else if kind == "union" {
    let parts = ti.data.map(describe_type)
    let rest = parts.filter(p => p != "none")
    let nones = parts.filter(p => p == "none")
    (rest + nones).dedup().join(" | ")
  } else if kind == "native" {
    (
      boolean: "bool",
      integer: "int",
      string: "str",
      dictionary: "dictionary",
      "relative length": "relative",
    ).at(ti.name, default: ti.name)
  } else if kind == "any" {
    "any"
  } else if kind == "literal" {
    repr(ti.data.value)
  } else if kind == "collection" {
    let base = ti.data.base.name
    let params = ti.data.parameters.map(describe_type)
    if base == "array" {
      let p = params.first()
      if p.contains("|") { "(" + p + ")[]" } else { p + "[]" }
    } else {
      base + "(" + params.join(", ") + ")"
    }
  } else {
    ti.at("name", default: "any").replace(" or ", " | ")
  }
}

/// A value as an error message shows it: as Typst would print it, cut short
/// when long, and a function by name only (its repr is often `(..) => ..`).
#let _shown(value) = {
  if type(value) == function { return "a function" }
  let s = repr(value)
  let cs = s.clusters()
  if cs.len() > 60 { cs.slice(0, 60).join() + "…" } else { s }
}

/// Declare a plain function's signature.
///
/// - `name`: the name the function is exported under; error messages start
///   with it.
/// - `doc`: what the function does, for the API reference.
/// - `fields`: its arguments, each an `e.field(..)`, in order. A field with
///   `named: false` is positional; positional fields are taken in the order
///   given, required ones first. Two keys of a field's `meta` are read:
///   `check`, a function of the given value that returns `none` when it is
///   acceptable, or a message saying why not (it may also fail itself), and
///   runs before the type is checked, so that it can name a likely mistake;
///   and `hint`, added to a message about the field's type.
/// - `aliases`: names an author might reach for in place of an argument,
///   each mapped to a hint naming the right one.
/// - `positional-error`: a function of the number of positional arguments
///   given, when there are too many, returning the message.
/// - `takes`: what the function takes, for the message about an unknown
///   argument (it ends "`name` takes .."); by default its named arguments,
///   listed.
/// - `rest`: named arguments it takes beyond its fields, any number of
///   them, documented as one: `(name, doc, fields)`, `fields` a dictionary
///   of `e.field`s by name. The API reference shows them as `..name`; the
///   fields are for checking them (see `exam`'s `_EXAM_ARGS`).
/// - `group`, `alias-of`: passed through to the API reference (see
///   docs/api.typ).
#let declare_function(
  name,
  doc: none,
  fields: (),
  aliases: (:),
  positional-error: none,
  takes: none,
  ..extra,
) = {
  assert(type(name) == str, message: "declare_function: name must be a string")
  let all = (:)
  for f in fields {
    assert(
      type(f) == dictionary and f.at("__elembic_field", default: false),
      message: "declare_function(" + name + "): every field must be made with `e.field`",
    )
    assert(f.name not in all, message: "declare_function(" + name + "): duplicate field `" + f.name + "`")
    all.insert(f.name, f)
  }
  let positional = fields.filter(f => not f.named)
  let required_after_optional = positional
    .enumerate()
    .any(((i, f)) => f.required and positional.slice(0, i).any(g => not g.required))
  assert(
    not required_after_optional,
    message: "declare_function(" + name + "): a required positional field cannot follow an optional one",
  )
  (
    kind: "function",
    name: name,
    doc: doc,
    fields: all,
    positional: positional,
    aliases: aliases,
    positional-error: positional-error,
    takes: takes,
    ..extra.named(),
  )
}

/// Check one value against its field: its `meta.check`, then its type.
/// Returns `none` if it is acceptable, or the message saying why not.
#let _check_value(spec, field, value) = {
  let check = field.meta.at("check", default: none)
  if check != none {
    let message = check(value)
    if message != none { return message }
  }
  let (ok, _) = e.types.cast(value, field.typeinfo)
  if ok { return none }
  let hint = field.meta.at("hint", default: none)
  (
    spec.name
      + ": `"
      + field.name
      + "` must be "
      + describe_type(field.typeinfo)
      + ", got "
      + _shown(value)
      + if hint != none { " — " + hint } else { "" }
  )
}

/// Parse `args` against `spec`: `(true, values)`, with every field's value
/// (its default where not given), or `(false, message)`.
#let parse_args(spec, args) = {
  let pos = args.pos()
  let named = args.named()
  let positional = spec.positional
  if pos.len() > positional.len() {
    let message = if spec.positional-error != none {
      (spec.positional-error)(pos.len())
    } else if positional.len() == 0 {
      spec.name + ": takes no positional arguments, got " + str(pos.len())
    } else {
      (
        spec.name
          + ": takes at most "
          + str(positional.len())
          + " positional argument"
          + if positional.len() == 1 { "" } else { "s" }
          + " ("
          + positional.map(f => "`" + f.name + "`").join(", ")
          + "), got "
          + str(pos.len())
      )
    }
    return (false, message)
  }
  let values = (:)
  for (i, f) in positional.enumerate() {
    if i < pos.len() {
      values.insert(f.name, pos.at(i))
    } else if f.required {
      return (false, spec.name + ": missing its `" + f.name + "` argument")
    }
  }
  for (key, value) in named {
    let f = spec.fields.at(key, default: none)
    if f == none or not f.named {
      if key in spec.aliases {
        return (false, spec.name + ": unknown argument `" + key + "`; " + spec.aliases.at(key))
      }
      let message = if f != none {
        spec.name + ": `" + key + "` is given by position, not by name"
      } else {
        let takes = if spec.takes != none {
          spec.takes
        } else {
          spec.fields.values().filter(f => f.named and not f.internal).map(f => "`" + f.name + "`").join(", ")
        }
        spec.name + ": unknown argument `" + key + "`; `" + spec.name + "` takes " + takes
      }
      return (false, message)
    }
    values.insert(key, value)
  }
  for f in spec.fields.values() {
    if f.name in values {
      let message = _check_value(spec, f, values.at(f.name))
      if message != none { return (false, message) }
    } else if f.required {
      return (false, spec.name + ": missing the required argument `" + f.name + "`")
    } else {
      values.insert(f.name, f.default)
    }
  }
  (true, values)
}

/// The values of `args`, parsed against `spec`; a mistake fails the call.
#let check_args(spec, args) = {
  let (ok, result) = parse_args(spec, args)
  assert(ok, message: if ok { "" } else { result })
  result
}

/// A function taking the arguments `spec` declares, which calls `impl` with
/// a dictionary of their values.
#let define(spec, impl) = (..args) => impl(check_args(spec, args))

