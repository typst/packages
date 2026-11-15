/// Elembic metadata. Types and defaults are Typst expressions; field traits
/// are YAML values. Evaluate local custom types through an explicit scope.
#import "@preview/elembic:1.1.1" as e

#let __codly-prefix = "@preview/codly:v2.0.0"
#let __codly-args = yaml("args.yaml")

#let __field-options(definition, scope: (:)) = {
  let ty = eval(definition.remove("type"), mode: "code", scope: (e: e) + scope)
  if "default" in definition {
    definition.default = eval(definition.default, mode: "code", scope: (e: e) + scope)
  }
  (ty, definition)
}

#let __fields(definitions, scope: (:)) = (
  definitions
    .pairs()
    .map(((name, definition)) => {
      let (ty, options) = __field-options(definition, scope: scope)
      e.field(name, ty, ..options)
    })
)

/// Callout entries inherit all defaults. Callout components inherit bubble
/// styling; bubble components own it and drop the bubble- name prefix.
#let __callout-fields(entry: false, bubble: false) = {
  let result = ()
  for (name, definition) in __codly-args.at("field-groups").callout {
    let styling = name.starts-with("bubble-") or name.starts-with("pointer-")
    if bubble and not styling { continue }
    let (ty, options) = __field-options(definition)
    if entry or (not bubble and styling) {
      ty = e.types.union(ty, auto)
      options.default = auto
    }
    result.push(e.field(
      if bubble and name.starts-with("bubble-") { name.slice(7) } else { name },
      ty,
      ..options,
    ))
  }
  result
}

/// Return the arguments shared by element.declare and types.declare.
#let __declaration(kind, name, scope: (:)) = {
  let definition = __codly-args.at(kind).at(name)
  let definitions = definition.remove("fields")
  let fields = __fields(definitions, scope: scope)
  let groups = definition.remove("field-groups", default: ())
  for group in groups.rev() {
    assert(
      group.name == "callout",
      message: "codly: unknown declaration field group: " + group.name,
    )
    assert(
      group.mode in ("entry", "callout", "bubble"),
      message: "codly: unknown callout field mode: " + group.mode,
    )
    let index = definitions.keys().position(name => name == group.after)
    assert(index != none, message: "codly: missing field-group insertion point: " + group.after)
    index += 1
    let extra = __callout-fields(entry: group.mode == "entry", bubble: group.mode == "bubble")
    fields = fields.slice(0, index) + extra + fields.slice(index)
  }
  definition + (fields: fields)
}

/// Read a declared default for runtime fallbacks and theme presets.
#let __default(element, field, scope: (:)) = {
  eval(
    __codly-args.elements.at(element).fields.at(field).default,
    mode: "code",
    scope: (e: e) + scope,
  )
}
