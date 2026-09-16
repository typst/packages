// # Components. Componentes.

#import "./data/terms.typ": get_term
#import "./packages.typ": (
  quati-abnt, quati-abnt.academic_work.components.include_epigraph, quati-abnt.academic_work.components.print_people,
  quati-abnt.academic_work.components.print_person, quati-abnt.common.components.cite_prose,
  quati-abnt.common.components.closed_discussion_note, quati-abnt.common.components.create_status_note,
  quati-abnt.common.components.describe_figure, quati-abnt.common.components.done_note,
  quati-abnt.common.components.editor_note, quati-abnt.common.components.equation,
  quati-abnt.common.components.foreign_text, quati-abnt.common.components.format_table,
  quati-abnt.common.components.open_discussion_note, quati-abnt.common.components.progress_note,
  quati-abnt.common.components.source_for_content_created_by_authors, quati-abnt.common.components.todo_note,
)


// ## Editor notes. Notas de editor.

#let review_note = (
  prefixes: none,
  it,
) => {
  let color = oklch(82.01%, 0.159, 323.15deg)
  create_status_note(
    fill: color,
    prefixes: prefixes,
    status: "REVISAR",
    stroke: color.saturate(50%),
    it,
  )
}

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

#let note_from_gabriel = (
  note: editor_note,
  it,
) => {
  let color = oklch(80.43%, 0.1, 278.25deg)
  note(
    prefixes: (
      (
        body: "Gabriel",
        fill: color,
        stroke: color.saturate(25%),
      ),
    ),
    it,
  )
}
