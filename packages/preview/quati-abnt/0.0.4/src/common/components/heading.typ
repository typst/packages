// # Headings. Títulos.

#import "../../common/util/font_family.typ": font_family_for_highlighted_text_state
#import "../style/style.typ": (
  font_size_for_common_text, font_size_for_larger_text, leading_for_common_text, leading_for_larger_text,
  spacing_for_common_text, spacing_for_larger_text,
)

#let get_styling_for_heading(
  should_use_larger_text_to_highlight: false,
  body,
) = {
  // NBR 6024:2012 4.1.
  // The format of headings should represent their hierarchical level.

  let font_size = font_size_for_common_text
  let leading = leading_for_common_text
  let spacing = spacing_for_common_text
  let font_weight = "regular"
  let text_style = "normal"
  let should_capitalize = false
  let should_underline = false

  if body.level == 1 {
    font_weight = "bold"
    if should_use_larger_text_to_highlight {
      font_size = font_size_for_larger_text
      let leading = leading_for_larger_text
      let spacing = spacing_for_larger_text
    } else {
      should_capitalize = true
    }
  } else if body.level == 2 {
    if should_use_larger_text_to_highlight {
      font_size = font_size_for_larger_text
      let leading = leading_for_larger_text
      let spacing = spacing_for_larger_text
    } else {
      should_capitalize = true
    }
  } else if body.level == 3 {
    font_weight = "bold"
  } else if body.level == 4 {} else if body.level >= 5 {
    text_style = "italic"
  }

  return (
    font_size,
    leading,
    spacing,
    should_capitalize,
    font_weight,
    text_style,
    should_underline,
  )
}

#let capitalize_or_underline_if_needed = (
  should_capitalize: false,
  should_underline: false,
  it,
) => {
  if should_capitalize {
    it = upper(it)
  }
  if should_underline {
    it = underline(it)
  }
  it
}

#let format_heading(
  should_use_larger_text_to_highlight: false,
  body,
) = context {
  // NBR 14724:2024 5.2.2.

  set text(
    font: font_family_for_highlighted_text_state.get(),
  )

  let (
    font_size,
    leading,
    spacing,
    should_capitalize,
    font_weight,
    text_style,
    should_underline,
  ) = get_styling_for_heading(
    should_use_larger_text_to_highlight: should_use_larger_text_to_highlight,
    body,
  )
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
    text_before_numbering = "Apêndice"
    text_after_numbering = sym.dash.em
    column_gutter = measure(sym.space).width
  } else if body.supplement == [Anexo] {
    // NBR 14724:2024 4.2.3.4.
    // Annexes must have the supplement "ANEXO" before its numbering and an em-dash after it.
    text_before_numbering = "Anexo"
    text_after_numbering = sym.dash.em
    column_gutter = measure(sym.space).width
  }

  let prefix = numbering => capitalize_or_underline_if_needed(
    should_capitalize: should_capitalize,
    should_underline: should_underline,
  )[
    #text_before_numbering
    #counter(heading).display(numbering)
    #text_after_numbering
  ]

  let heading_text = capitalize_or_underline_if_needed(
    should_capitalize: should_capitalize,
    should_underline: should_underline,
    body.body,
  )

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
        prefix(body.numbering), heading_text,
      ),
    )
  }
  space_around
}
