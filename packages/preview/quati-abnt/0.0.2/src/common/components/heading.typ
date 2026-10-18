// # Headings. Títulos.

#import "../style/style.typ": (
  font_size_for_common_text, font_size_for_level_1_headings, font_size_for_level_2_headings,
  font_size_for_level_3_and_beyond_headings, leading_for_level_1_headings, leading_for_level_2_headings,
  leading_for_level_3_and_beyond_headings, spacing_for_level_1_headings, spacing_for_level_2_headings,
  spacing_for_level_3_and_beyond_headings,
)

#let get_styling_for_heading(body) = {
  // NBR 6024:2012 4.1.
  // The format of headings should represent their hierarchical level.

  let font_size = font_size_for_common_text
  let leading = leading_for_level_3_and_beyond_headings
  let spacing = spacing_for_level_3_and_beyond_headings
  let font_weight = "regular"
  let text_style = "normal"
  let capitalize = false

  if body.level == 1 {
    capitalize = true
    font_size = font_size_for_level_1_headings
    font_weight = "bold"
    leading = leading_for_level_1_headings
    spacing = spacing_for_level_1_headings
  } else if body.level == 2 {
    capitalize = true
    font_size = font_size_for_level_2_headings
    leading = leading_for_level_2_headings
    spacing = spacing_for_level_2_headings
  } else if body.level == 3 {
    font_weight = "bold"
    font_size = font_size_for_level_3_and_beyond_headings
  } else if body.level == 4 {} else if body.level >= 5 {
    text_style = "italic"
  }

  return (
    capitalize,
    font_size,
    font_weight,
    leading,
    spacing,
    text_style,
  )
}

#let format_heading(
  body,
) = {
  // NBR 14724:2024 5.2.2.

  let (
    capitalize,
    font_size,
    font_weight,
    leading,
    spacing,
    text_style,
  ) = get_styling_for_heading(body)
  let text_before_numbering = none
  let text_after_numbering = none
  let column_gutter = measure(sym.dash).width

  set par(
    leading: leading,
    spacing: spacing,
    first-line-indent: 0cm,
  )
  set text(
    size: font_size,
    weight: font_weight,
    style: text_style,
  )

  if body.supplement == [Apêndice] {
    // NBR 14724:2024 4.2.3.3.
    // Appendixes must have the supplement "APÊNDICE" before its numbering and an em-dash after it.
    text_before_numbering = "APÊNDICE"
    text_after_numbering = sym.dash.em
    column_gutter = measure(sym.space).width
  }
  if body.supplement == [Anexo] {
    // NBR 14724:2024 4.2.3.4.
    // Annexes must have the supplement "ANEXO" before its numbering and an em-dash after it.
    text_before_numbering = "ANEXO"
    text_after_numbering = sym.dash.em
    column_gutter = measure(sym.space).width
  }

  let heading_text = [
    #if capitalize {
      upper(body.body)
    } else {
      body.body
    }
  ]

  // NBR 14724:2024 5.2.2.
  // Headings must have a blank space of 1.5 above and below.
  let space_around = v(spacing * 2, weak: true)

  space_around
  if body.numbering == none {
    // NBR 6024:2012 4.1.
    // Headings without numbering should be aligned to the center.
    align(center)[
      #block(
        above: spacing,
        below: spacing,
      )[#heading_text]
    ]
  } else {
    block(
      above: spacing,
      below: spacing,
      // NBR 6024:2012 4.1.
      // For headings with multiple lines, each subsequent line should be aligned with the first one.
      grid(
        columns: 2,
        rows: 1,
        // Numbering indicator should be separated from the title by a single space.
        column-gutter: column_gutter,
        [
          #text_before_numbering
          #counter(heading).display(body.numbering)
          #text_after_numbering
        ],
        [#heading_text],
      ),
    )
  }
  space_around
}
