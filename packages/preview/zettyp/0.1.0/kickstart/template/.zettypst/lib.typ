// Importing configuration never reads the source manifest.
#import "@preview/zettyp:0.1.0": core, kickstart, lsp
#import core: graph, observation, policy, vocabulary
#import "sources.typ"
#import kickstart: display-value, evaluation-issues, without-root

// Vocabulary and metadata.
#let lifecycle = vocabulary.register(
  "lifecycle",
  active: "active",
  legacy: "legacy",
  archived: "archived",
)
#let colors = vocabulary.register(
  "relation",
  ref: kickstart.reference-color.value,
  replaces: <zk.replaces>,
  evolves-from: <zk.evolves-from>,
)
#let registry = vocabulary.registry(lifecycle: lifecycle, relation: colors)
#let text-field = graph.schema.typed("text", (str,))
#let metadata-schema = kickstart.metadata-schema(
  registry: registry,
  // Finite semantic values: booleans, registered enums, and their records.
  value: (lifecycle: lifecycle.active),
  // Open data is structurally checked; its value space need not be finite.
  data: (
    defaults: (aliases: (), abstract: "", tags: ()),
    schema: graph.schema.record("NoteData", (
      aliases: graph.schema.array(text-field),
      abstract: text-field,
      tags: graph.schema.array(text-field),
    )),
  ),
)
// Notes supply flat fields; the schema determines value/data ownership.
#let zk_metadata = kickstart.metadata.with(metadata-schema)
#let zettel = kickstart.zettel.with(metadata-schema, metadata: zk_metadata)
#let replaces = kickstart.colored-edge.with(registry, colors.replaces)
#let evolves-from = kickstart.colored-edge.with(registry, colors.evolves-from)

// Named neighbor projections are publication data, not policy assignments.
#let projections = (
  replaced-by: (color: colors.replaces, direction: "incoming"),
  evolved-into: (color: colors.evolves-from, direction: "incoming"),
)
#let project-notes = kickstart.project-notes.with(projections: projections)
#let load = kickstart.load.with(manifest: sources.manifest, read: sources.note)

// Native policy wiring; origins are bound separately for every project.
#let lifecycle-rule = kickstart.lifecycle-policy.with(
  metadata-schema,
  field: "lifecycle",
  archived: lifecycle.archived,
  legacy: lifecycle.legacy,
  replaces: colors.replaces,
  evolves-from: colors.evolves-from,
)
#let program(project) = policy.assemble(
  (
    policy.invocation("semantic", lifecycle-rule(project.origins), inputs: (
      "initial",
    )),
  ),
  inputs: ("initial",),
)
#let evaluate = kickstart.evaluate.with(
  registry: registry,
  program: program,
  inputs: project => (project.state,),
)

// Publication selects an explicitly declared observation.
#let observations = (
  observation.binding(
    "final",
    observation.definition(state => state, on-error: error => none),
    at: "semantic",
  ),
)
#let final-observation = kickstart.observe.with(
  bindings: observations,
  name: "final",
)

// Presentation callbacks receive the same projected note records.
#let route(note) = note.id + "/index.html"
#let announce-editor = kickstart.announce-editor.with(
  lsp,
  project-notes: project-notes,
  hover: kickstart.lsp.hover,
)
#let announce-project = kickstart.announce-project.with(
  project-notes: project-notes,
)
#let publish = kickstart.publish.with(
  final-observation: final-observation,
  editor-output: announce-editor,
  project-output: announce-project,
)
#let export-html = kickstart.export-html.with(
  final-observation: final-observation,
  project-notes: project-notes,
  route: route,
  card: kickstart.site.card,
)
