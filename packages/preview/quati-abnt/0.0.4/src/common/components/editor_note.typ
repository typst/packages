// # Note. Nota.

#import "../style/style.typ": simple_spacing_for_smaller_text
#import "../util/font_family.typ": font_family_for_editor_notes_state

#let should_display_editor_notes_state = state("quati_abnt_should_display_editor_notes", true)

#let color_of_fill_of_notes = oklch(100%, 0, 90deg)
#let paint_of_stroke_of_notes = oklch(80.78%, 0, 0deg)
#let thickness_of_stroke_of_notes = 1.5pt

#let handle_stroke = stroke_definition => {
  let converted_stroke = stroke(stroke_definition)
  let paint = converted_stroke.paint
  let thickness = converted_stroke.thickness

  if (paint == auto) {
    paint = paint_of_stroke_of_notes
  }
  if (thickness == auto) {
    thickness = thickness_of_stroke_of_notes
  }

  stroke(
    cap: converted_stroke.cap,
    dash: converted_stroke.dash,
    join: converted_stroke.join,
    miter-limit: converted_stroke.miter-limit,
    paint: paint,
    thickness: thickness,
  )
}

#let stroke_of_notes = handle_stroke(
  paint_of_stroke_of_notes + thickness_of_stroke_of_notes,
)

#let join_strokes = (
  new_stroke: none,
  old_stroke: stroke_of_notes,
) => {
  let cap = if (new_stroke.cap == none) {
    old_stroke.cap
  } else {
    new_stroke.cap
  }

  let dash = if (new_stroke.dash == none) {
    old_stroke.dash
  } else {
    new_stroke.dash
  }

  let join = if (new_stroke.join == none) {
    old_stroke.join
  } else {
    new_stroke.join
  }

  let miter-limit = if (new_stroke.miter-limit == none) {
    old_stroke.miter-limit
  } else {
    new_stroke.miter-limit
  }

  let paint = if (new_stroke.paint == none) {
    old_stroke.paint
  } else {
    new_stroke.paint
  }

  let thickness = if (new_stroke.thickness == none) {
    old_stroke.thickness
  } else {
    new_stroke.thickness
  }

  stroke(
    cap: cap,
    dash: dash,
    join: join,
    miter-limit: miter-limit,
    paint: paint,
    thickness: thickness,
  )
}

#let box_of_prefix = (
  fill_of_note: none,
  prefix: (
    body: none,
    fill: none,
    stroke: none,
  ),
) => {
  set text(weight: "bold")

  let fill_of_prefix = if (
    prefix.keys().contains("fill")
  ) {
    prefix.fill
  } else {
    none
  }
  if (fill_of_prefix == none) {
    fill_of_prefix = fill_of_note.mix(color.luma(95%))
  }

  box(
    fill: fill_of_prefix,
    inset: 6pt,
    prefix.body,
  )
}


#let get_stroke_of_prefix = (
  prefix: none,
  stroke_of_note: none,
) => {
  let stroke_of_prefix = if (
    prefix.keys().contains("stroke")
  ) {
    prefix.stroke
  } else {
    none
  }
  if (stroke_of_prefix == none) {
    stroke_of_prefix = join_strokes(
      old_stroke: stroke_of_note,
      new_stroke: stroke(
        paint: stroke_of_note.paint,
      ),
    )
  }
  handle_stroke(stroke_of_prefix)
}

#let block_of_note(
  fill: none,
  prefixes: none,
  stroke: none,
  it,
) = context {
  if (should_display_editor_notes_state.get() == true) {
    set text(
      font: font_family_for_editor_notes_state.get(),
    )
    set par(first-line-indent: 0pt)
    block(
      breakable: false,
      clip: true,
      fill: fill,
      radius: 6pt,
      stroke: stroke,

      grid(
        rows: 2,

        if (prefixes != none) {
          // Converts a prefix dictionary into an array of a single element, in case the user has inputted the prefixes incorrectly as not an array.
          let handled_prefixes = if (type(prefixes) == dictionary) {
            (prefixes,)
          } else {
            prefixes
          }

          set par(
            spacing: simple_spacing_for_smaller_text,
          )

          let boxes_of_prefixes = handled_prefixes.map(
            prefix => {
              let stroke_of_prefix = get_stroke_of_prefix(
                prefix: prefix,
                stroke_of_note: stroke,
              )
              grid.cell(
                stroke: stroke_of_prefix,
                inset: stroke_of_prefix.thickness / 2,
                box_of_prefix(
                  fill_of_note: fill,
                  prefix: prefix,
                ),
              )
            },
          )

          grid(
            columns: boxes_of_prefixes.len(),
            gutter: thickness_of_stroke_of_notes,
            ..boxes_of_prefixes,
          )
        },

        block(
          inset: 6pt,
          it,
        ),
      ),
    )
  }
}

#let editor_note = (
  fill: color_of_fill_of_notes,
  prefixes: none,
  stroke: stroke_of_notes,
  it,
) => {
  block_of_note(
    fill: fill,
    prefixes: prefixes,
    stroke: handle_stroke(stroke),
    it,
  )
}

#let create_status_note = (
  fill: color_of_fill_of_notes,
  prefixes: none,
  status: "NOTA",
  stroke: stroke_of_notes,
  it,
) => {
  let prefix_of_status = (body: status)

  editor_note(
    fill: fill,
    prefixes: (
      ..prefixes,
      prefix_of_status,
    ),
    stroke: stroke,
    it,
  )
}

#let todo_note = (
  prefixes: none,
  it,
) => {
  let color = oklch(91.95%, 0.117, 93.14deg)
  create_status_note(
    fill: color,
    prefixes: prefixes,
    status: "AFAZER",
    stroke: color.saturate(75%),
    it,
  )
}

#let progress_note = (
  prefixes: none,
  it,
) => {
  let color = oklch(90.73%, 0.142, 115.79deg)
  create_status_note(
    fill: color,
    prefixes: prefixes,
    status: "PROGRESSO",
    stroke: color.saturate(90%).darken(5%),
    it,
  )
}

#let done_note = (
  prefixes: none,
  it,
) => {
  let color = oklch(85.66%, 0.082, 235.93deg)
  create_status_note(
    fill: color,
    status: "FEITO",
    prefixes: prefixes,
    stroke: color.saturate(75%),
    it,
  )
}

#let open_discussion_note = (
  prefixes: none,
  it,
) => {
  let color = oklch(78.14%, 0.117, 248.13deg)
  create_status_note(
    fill: color,
    status: "ABERTO",
    prefixes: prefixes,
    stroke: color.saturate(75%),
    it,
  )
}

#let closed_discussion_note = (
  prefixes: none,
  it,
) => {
  let color = oklch(78.14%, 0.05, 248.13deg)
  create_status_note(
    fill: color,
    status: "FECHADO",
    prefixes: prefixes,
    stroke: color.saturate(25%),
    it,
  )
}
