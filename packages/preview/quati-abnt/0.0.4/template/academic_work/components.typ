// # Components. Componentes.

#import "./packages.typ": (
  quati-abnt.academic_work.components.include_epigraph, quati-abnt.common.components.cite_prose,
  quati-abnt.common.components.create_status_note, quati-abnt.common.components.describe_figure,
  quati-abnt.common.components.done_note, quati-abnt.common.components.editor_note,
  quati-abnt.common.components.equation, quati-abnt.common.components.format_table,
  quati-abnt.common.components.progress_note, quati-abnt.common.components.todo_note,
)

// ## Note. Nota.

#let note_from_alice = (
  note: editor_note,
  it,
) => {
  let color = oklch(85%, 0.097, 19.33deg)
  note(
    prefixes: (
      (
        fill: color,
        body: "Alice",
        stroke: color.saturate(25%),
      ),
    ),
    it,
  )
}

#let note_from_eduardo = (
  note: editor_note,
  it,
) => {
  let color = oklch(80.43%, 0.1, 278.25deg)
  note(
    prefixes: (
      (
        body: "Eduardo",
        fill: color,
        stroke: color.saturate(25%),
      ),
    ),
    it,
  )
}
