// =============================================================================
// src/components/boxes.typ: Section containers and feedback/bibliography boxes
// =============================================================================

#import "../state.typ": _with-resolved-fill
#import "../utils.typ": _split-heading-sections

/// Unified internal table container with a colored header banner and 1..N body rows.
///
/// - title (str, content): Section header title.
/// - fill (color, str, auto): Header background color (defaults to package primary color).
/// - stroke (stroke, length): Border stroke.
/// - header-inset (length, dictionary): Inset padding for the header banner cell.
/// - body-inset (length, dictionary): Inset padding for the body cells.
/// - cells (array): Array of content cells to display under the header.
/// -> content
#let _section-table(
  title: "",
  fill: auto,
  stroke: black + 1pt,
  header-inset: 0.5em,
  body-inset: 0.5em,
  cells: (),
) = _with-resolved-fill(fill, active-fill => {
  table(
    align: left + horizon,
    stroke: stroke,
    inset: body-inset,
    columns: (1fr,),
    table.cell(
      fill: active-fill,
      inset: header-inset,
      align: center + horizon,
      text(weight: "bold", size: 11pt, fill: white)[#title],
    ),
    ..cells,
  )
})

/// Deprecated alias for backwards-compatibility; delegates to `_section-table`.
#let _titled-box(
  title: "",
  fill: auto,
  stroke: black + 1pt,
  inset: 0.5em,
  body,
) = _section-table(
  title: title,
  fill: fill,
  stroke: stroke,
  header-inset: 0.5em,
  body-inset: inset,
  cells: (body,),
)

/// Renders the ABET "SOLUCIÓN Y RESULTADOS" container section.
///
/// In the official ABET format, sections such as Solución de Ejercicios,
/// Solución del Cuestionario, and Conclusiones are rendered as individual,
/// bordered cells/rows inside the main table.
///
/// This function supports:
/// 1. Named parameters:
///    `#results-section(ejercicios: [...], cuestionario: [...], conclusiones: [...])`
/// 2. Chained positional content blocks:
///    `#results-section[...][...][...]`
/// 3. Passing an array of cells:
///    `#results-section(cells: (...))`
/// 4. Passing a single block with `= ` headings (automatically split into cells).
///
/// - title (str, content): Section header title.
/// - fill (color, str, auto): Header background color (defaults to package primary color).
/// - stroke (stroke, length): Border stroke (defaults to 0.5pt + black).
/// - inset (length, dictionary): Cell padding.
/// - ejercicios (content, none): Optional cell content for exercises/problems section.
/// - cuestionario (content, none): Optional cell content for questionnaire section.
/// - conclusiones (content, none): Optional cell content for conclusions section.
/// - cells (array, none): Optional explicit list of cell contents.
/// - ..args: Positional content block(s) representing table cells.
/// -> content
#let results-section(
  title: "SOLUCIÓN Y RESULTADOS",
  fill: auto,
  stroke: 0.5pt + black,
  inset: 1em,
  ejercicios: none,
  cuestionario: none,
  conclusiones: none,
  cells: (),
  ..args,
) = {
  let table-cells = ()

  for named-cell in (ejercicios, cuestionario, conclusiones) {
    if named-cell != none {
      table-cells.push(named-cell)
    }
  }

  if type(cells) == array {
    table-cells += cells
  } else if cells != none {
    table-cells.push(cells)
  }

  let pos = args.pos()
  if pos.len() == 1 and type(pos.at(0)) == array {
    table-cells += pos.at(0)
  } else if pos.len() == 1 and table-cells.len() == 0 {
    table-cells += _split-heading-sections(pos.at(0))
  } else {
    table-cells += pos
  }

  if table-cells.len() == 0 {
    table-cells.push([])
  }

  _section-table(
    title: title,
    fill: fill,
    stroke: stroke,
    header-inset: 0.5em,
    body-inset: inset,
    cells: table-cells,
  )
}

/// Renders the ABET "RETROALIMENTACIÓN GENERAL" box for instructor comments.
///
/// - title (str, content): Box header title.
/// - height (length): Height allocated for comments when empty.
/// - fill (color, str, auto): Header background color (defaults to package primary color).
/// - stroke (stroke, length): Border stroke.
/// - inset (length, dictionary): Content padding.
/// - content (content, none): Optional instructor feedback content.
/// - ..args: Optional trailing content.
/// -> content
#let feedback-box(
  title: "RETROALIMENTACIÓN GENERAL",
  height: 6em,
  fill: auto,
  stroke: black + 1pt,
  inset: 0.5em,
  content: none,
  ..args,
) = {
  let body = if content != none {
    content
  } else if args.pos().len() > 0 {
    args.pos().at(0)
  } else {
    block(height: height, width: 100%)[]
  }

  _section-table(
    title: title,
    fill: fill,
    stroke: stroke,
    header-inset: inset,
    body-inset: inset,
    cells: (body,),
  )
}

/// Renders the ABET "REFERENCIAS Y BIBLIOGRAFÍA" container box.
///
/// - title (str, content): Box header title.
/// - fill (color, str, auto): Header background color (defaults to package primary color).
/// - stroke (stroke, length): Border stroke.
/// - inset (length, dictionary): Content padding.
/// - ..args: Trailing bibliography content.
/// -> content
#let bibliography-box(
  title: "REFERENCIAS Y BIBLIOGRAFÍA",
  fill: auto,
  stroke: black + 1pt,
  inset: 0.5em,
  ..args,
) = {
  let body = if args.pos().len() > 0 {
    set bibliography(title: none)
    args.pos().at(0)
  } else {
    []
  }

  _section-table(
    title: title,
    fill: fill,
    stroke: stroke,
    header-inset: inset,
    body-inset: inset,
    cells: (body,),
  )
}
