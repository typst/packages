/// Structural graph types. Validation preserves inputs without applying defaults.
///
/// Each schema is a Valkyrie type that also carries a plain-data descriptor of
/// the same rule under `zettyp`. checked first interprets the descriptor
/// without passing checked values into closures; only a rejected value is
/// parsed again by Valkyrie, which stays authoritative and reports the error.
/// Define schemas only through these constructors, so that descriptors cannot
/// drift from the Valkyrie rules they mirror. Schemas without a descriptor are
/// always parsed by Valkyrie.
#import "@preview/valkyrie:0.2.2" as z

#let describe(schema) = schema.at("zettyp", default: none)
#let described(schema, descriptor) = schema + (zettyp: descriptor)

// A composite is described only when all of its children are.
#let composite(children, descriptor) = if none in children { none } else {
  descriptor + (depth: 1 + calc.max(0, ..children.map(item => item.depth)))
}

/// Interpret a descriptor breadth-first. Each level visits one schema depth,
/// so the loop is bounded by the descriptor tree. Valkyrie replaces none and
/// auto with the default none, which only opaque values accept; type checks
/// reject both directly. Opaque children are never visited.
#let valid(value, descriptor) = {
  let frontier = ((value, descriptor),)
  for _ in range(descriptor.depth) {
    let next = ()
    for (item, rule) in frontier {
      let kind = rule.kind
      if kind == "id" {
        if type(item) != str or item == "" { return false }
      } else if kind == "type" {
        if type(item) not in rule.types { return false }
      } else if kind == "integer" {
        if type(item) != int { return false }
        if rule.min != none and item < rule.min { return false }
      } else if kind == "one-of" {
        if type(item) != str or item not in rule.values { return false }
      } else if kind == "array" {
        if type(item) != array { return false }
        if rule.min != none and item.len() < rule.min { return false }
        if rule.max != none and item.len() > rule.max { return false }
        if rule.item.kind != "any" {
          for entry in item { next.push((entry, rule.item)) }
        }
      } else if kind == "record" {
        if type(item) != dictionary { return false }
        if item.len() != rule.fields.len() { return false }
        for (key, field) in rule.fields {
          if key not in item { return false }
          if field.kind != "any" { next.push((item.at(key), field)) }
        }
      } else if kind == "indexed" or kind == "dictionary-of" {
        if type(item) != dictionary { return false }
        for (key, entry) in item {
          if kind == "indexed" and key == "" { return false }
          if rule.item.kind != "any" { next.push((entry, rule.item)) }
        }
      } else if kind == "tagged" {
        if type(item) != dictionary { return false }
        let tag = item.at(rule.field, default: none)
        if type(tag) != str or tag not in rule.cases { return false }
        next.push((item, rule.cases.at(tag)))
      }
    }
    frontier = next
  }
  true
}

#let checked(value, schema, scope: ("argument",)) = {
  let descriptor = schema.at("zettyp", default: none)
  if descriptor == none or not valid(value, descriptor) {
    let _ = z.parse(value, schema, scope: scope)
  }
  value
}

/// Fixed records require every declared field and reject unknown fields.
#let record(name, fields) = described(
  z.base-type(name: name, types: (dictionary,))
    + (
      handle-descendents: (self, value, ctx: z.z-ctx(), scope: ()) => {
        for key in fields.keys() {
          if key not in value {
            return (self.fail-validation)(
              self,
              value,
              ctx: ctx,
              scope: scope + (key,),
              message: "Missing required field",
            )
          }
        }
        for (key, item) in value {
          if key not in fields {
            return (self.fail-validation)(
              self,
              value,
              ctx: ctx,
              scope: scope + (key,),
              message: "Unknown field",
            )
          }
          let _ = z.parse(item, fields.at(key), ctx: ctx, scope: scope + (key,))
        }
        value
      },
    ),
  {
    let children = fields.values().map(describe)
    composite(children, (
      kind: "record",
      fields: fields.keys().zip(children).to-dict(),
    ))
  },
)

#let id = described(z.string(min: 1), (kind: "id", depth: 1))
#let opaque = described(z.any(), (kind: "any", depth: 1))
/// Values whose type is one of the given Typst types, without inspecting them.
#let typed(name, types) = described(
  z.base-type(name: name, types: types),
  (kind: "type", types: types, depth: 1),
)
#let integer(min: none) = described(
  z.integer(min: min),
  (kind: "integer", min: min, depth: 1),
)
#let one-of(values) = described(
  z.string(assertions: (z.assert.one-of(values),)),
  (kind: "one-of", values: values, depth: 1),
)

/// Validate every element without rebuilding the array. Only length assertions
/// run on the array itself, so discarding parsed elements preserves their checks.
#let array(item, min: none, max: none) = described(
  z.array(item, min: min, max: max, default: none)
    + (
      handle-descendents: (self, value, ctx: z.z-ctx(), scope: ()) => {
        for (index, entry) in value.enumerate() {
          let _ = (self.descendents-schema.validate)(
            self.descendents-schema,
            entry,
            ctx: ctx,
            scope: scope + (str(index),),
          )
        }
        value
      },
    ),
  composite((describe(item),), (
    kind: "array",
    item: describe(item),
    min: min,
    max: max,
  )),
)

/// Dynamic dictionary keys are graph identities; values follow the given type.
#let indexed(item) = described(
  z.base-type(name: "identity-indexed dictionary", types: (dictionary,))
    + (
      handle-descendents: (self, value, ctx: z.z-ctx(), scope: ()) => {
        for (key, entry) in value {
          let _ = z.parse(key, id, ctx: ctx, scope: scope + (key, "key"))
          let _ = z.parse(entry, item, ctx: ctx, scope: scope + (key,))
        }
        value
      },
    ),
  composite((describe(item),), (kind: "indexed", item: describe(item))),
)

/// Dictionaries with unconstrained names whose values follow the given type.
#let dictionary-of(name, item) = described(
  z.base-type(name: name, types: (dictionary,))
    + (
      handle-descendents: (self, value, ctx: z.z-ctx(), scope: ()) => {
        for (key, entry) in value {
          let _ = z.parse(entry, item, ctx: ctx, scope: scope + (key,))
        }
        value
      },
    ),
  composite((describe(item),), (kind: "dictionary-of", item: describe(item))),
)

/// Dictionaries whose string field selects the schema for the whole value.
#let tagged(name, field, cases) = {
  let tag = one-of(cases.keys())
  described(
    z.base-type(name: name, types: (dictionary,))
      + (
        handle-descendents: (self, value, ctx: z.z-ctx(), scope: ()) => {
          let selected = z.parse(
            value.at(field, default: none),
            tag,
            ctx: ctx,
            scope: scope + (field,),
          )
          let _ = z.parse(
            value,
            cases.at(selected),
            ctx: ctx,
            scope: scope,
          )
          value
        },
      ),
    {
      let children = cases.values().map(describe)
      composite(children, (
        kind: "tagged",
        field: field,
        cases: cases.keys().zip(children).to-dict(),
      ))
    },
  )
}

#let node-declaration = record("NodeDeclaration", (
  id: id,
  value: opaque,
  origin: opaque,
))
#let edge-declaration = record("EdgeDeclaration", (
  id: id,
  source: id,
  target: id,
  value: opaque,
  origin: opaque,
))

#let fragment = record("GraphFragment", (
  nodes: array(node-declaration),
  edges: array(edge-declaration),
))
#let fragments = array(fragment)
#let endpoints = record("Endpoints", (source: id, target: id))
#let graph = record("Graph", (nodes: array(id), edges: indexed(endpoints)))
#let assignments = record("Assignments", (
  nodes: indexed(opaque),
  edges: indexed(opaque),
))
#let state = record("GraphState", (graph: graph, values: assignments))
