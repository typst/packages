/// A node-local knowledge observation, before global reference classification.
///
/// Local = (
///   node: graph.node declaration,
///   references: array<graph.edge declaration>,
///   data: dictionary,
/// )
///
/// The node value holds semantic assignments; data holds open values such as
/// titles and abstracts. Origins stay on declarations. This constructor does
/// not prescribe a semantic vocabulary or verify that values form a finite
/// domain; those checks belong to the configured semantic schema.
#import "../graph.typ"
#import "schema.typ"

/// Declare one raw -> Local observer. Bind configuration with closures or
/// .with before declaring it. The function returns one local(...) result;
/// raw has no prescribed type. Declaration does not execute the observer.
/// This is a function contract, not a static proof of its return type.
#let raw-to-local(observe) = schema.checked(
  (stage: "raw-to-local", observe: observe),
  schema.raw-to-local,
)

/// Register named raw-to-local declarations in an immutable definition table.
///
/// let observers = register(note: raw-to-local(read-note))
/// (observers.note.observe)(raw)
///
/// Calling observe during Typst evaluation performs the local observation.
/// Collection and knowledge assembly remain explicit outer steps.
#let register(..definitions) = {
  let _ = schema.checked(
    definitions.pos(),
    schema.no-positional,
    scope: ("positional",),
  )
  schema.checked(definitions.named(), schema.registry)
}

/// Declare a reference occurrence; its source is supplied by local.
#let reference(id, target: none, value: none, origin: none) = schema.checked(
  (id: id, target: target, value: value, origin: origin),
  schema.reference,
)

/// Construct one local observation, not necessarily one source file.
///
/// References describe outgoing occurrences with independent edge IDs. Their
/// targets may denote knowledge nodes, document anchors, or other objects;
/// knowledge assembly decides which references become graph edges.
///
/// Build references with reference above. Source ownership follows directly
/// from construction; target membership and uniqueness are resolved globally.
#let local(id, value: (:), data: (:), origin: none, references: ()) = {
  let references = schema.checked(
    references,
    schema.references,
    scope: ("references",),
  )
  schema.checked(
    (
      node: graph.node(id, value: value, origin: origin),
      references: references.map(item => graph.edge(
        item.id,
        source: id,
        target: item.target,
        value: item.value,
        origin: item.origin,
      )),
      data: data,
    ),
    schema.local,
  )
}
