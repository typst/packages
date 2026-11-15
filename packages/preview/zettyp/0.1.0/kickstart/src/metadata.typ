#import "../../core/graph.typ"
#import "../../core/semantic.typ"

#let record = graph.schema.typed("metadata record", (dictionary,))
#let envelope = graph.schema.record("Metadata", (value: record, data: record))

#let record-fields(schema) = {
  let description = graph.schema.describe(schema)
  assert(
    description != none and description.kind == "record",
    message: "metadata data schema must describe a fixed record",
  )
  description.fields.keys()
}

/// Declare field ownership independently of defaults and supplied values.
#let metadata-schema(registry: (:), value: (:), data: none) = {
  let value = graph.schema.checked(value, record, scope: ("value",))
  let data = graph.schema.checked(
    data,
    graph.schema.record("MetadataData", (
      defaults: record,
      schema: graph.schema.opaque,
    )),
    scope: ("data",),
  )
  let names = record-fields(data.schema)
  assert.eq(
    names.filter(name => name in value),
    (),
    message: "fields cannot belong to both value and data",
  )
  assert.eq(
    data.defaults.keys().filter(name => name not in names),
    (),
    message: "data defaults contain undeclared fields",
  )
  (
    registry: registry,
    value: (
      defaults: value,
      shape: semantic.infer(value, registry, record: true),
    ),
    data: data + (fields: names),
  )
}

/// Validate the internal representation without applying defaults.
#let checked(schema, metadata) = {
  let metadata = graph.schema.checked(metadata, envelope)
  assert(
    semantic.matches(schema.value.shape, metadata.value, schema.registry),
    message: "metadata value violates its finite semantic schema",
  )
  let _ = graph.schema.checked(metadata.data, schema.data.schema, scope: (
    "data",
  ))
  metadata
}

/// Fill defaults and partition flat input according to the declared schema.
#let metadata(schema, ..args) = {
  assert.eq(args.pos(), (), message: "metadata fields must be named")
  let supplied = args.named()
  let names = schema.value.defaults.keys() + schema.data.fields
  assert.eq(
    supplied.keys().filter(name => name not in names),
    (),
    message: "unknown metadata fields",
  )
  let filled = schema.value.defaults + schema.data.defaults + supplied
  let select(names) = filled
    .pairs()
    .filter(((name, _)) => name in names)
    .to-dict()
  checked(schema, (
    value: select(schema.value.defaults.keys()),
    data: select(schema.data.fields),
  ))
}
