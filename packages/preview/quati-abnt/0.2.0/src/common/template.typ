// # Template. Modelo.

#import "./components/figure.typ": figure_with_spacing_around
#import "./components/font_family.typ": (
  base_font_size_state, font_family_for_common_text_state, font_family_for_highlighted_text_state,
  font_family_for_math_text_state, font_family_for_monospaced_text_state, font_family_math, font_family_mono,
  font_family_sans, font_family_serif,
)
#import "./components/heading.typ": format_heading
#import "./components/quote.typ": format_quote
#import "style.typ": (
  base_font_size, indentation_for_paragraphs, indentation_for_subparagraphs, leading_for_common_text, paper_size,
  simple_leading_for_smaller_text, simple_spacing_for_smaller_text, spacing_for_common_text,
)


#let should_use_larger_text_instead_of_uppercase_to_highlight_state = state(
  "quati_abnt_should_use_larger_text_instead_of_uppercase_to_highlight",
  true,
)


#let template(
  doc,
  //
  // Base font size.
  base_font_size: base_font_size,
  //
  // Font families.
  font_family_for_common_text: font_family_serif,
  font_family_for_highlighted_text: font_family_sans,
  font_family_for_math_text: font_family_math,
  font_family_for_monospaced_text: font_family_mono,
  //
  // Whether to use uppercase as typographic highlight.
  should_use_larger_text_instead_of_uppercase_to_highlight: false,
) = {
  font_family_for_common_text_state.update(font_family_for_common_text)
  font_family_for_highlighted_text_state.update(font_family_for_highlighted_text)
  font_family_for_math_text_state.update(font_family_for_math_text)
  font_family_for_monospaced_text_state.update(font_family_for_monospaced_text)

  should_use_larger_text_instead_of_uppercase_to_highlight_state.update(
    should_use_larger_text_instead_of_uppercase_to_highlight,
  )
  base_font_size_state.update(base_font_size)

  // ## Page. Página.
  set page(
    paper: paper_size,
  )

  // ## Text. Texto.
  set text(
    lang: "pt",
    region: "br",
    font: font_family_for_common_text,
    size: base_font_size,
    hyphenate: true,
  )
  show raw: set text(
    font: font_family_for_monospaced_text,
  )
  show math.equation: set text(
    font: font_family_for_math_text,
  )

  // ## Paragraphs. Parágrafos.
  set par(
    first-line-indent: (
      amount: indentation_for_paragraphs,
      all: true,
    ),
    leading: leading_for_common_text,
    spacing: spacing_for_common_text,
    justify: true,
  )

  // ## Heading. Títulos.
  set heading(
    numbering: "1.1",
  )

  // ## Lists. Listas.
  set list(
    indent: indentation_for_subparagraphs,
  )
  show list: it => {
    set list(indent: 0em)
    it
  }
  set enum(
    indent: indentation_for_subparagraphs,
    numbering: "a)",
  )
  show enum: it => {
    set enum(indent: 0em)
    it
  }

  // ## Equations. Equações.
  // NBR 14724:2024 5.7
  set math.equation(
    numbering: "(1.1)",
    supplement: "Equação",
  )

  // ## Figures. Figuras.
  // NBR 14724:2024 5.8
  set figure.caption(
    // The caption of a figure should be on top of the figure
    position: top,
    // The indicator and numbering of the figure should be separated by a em-dash from the following caption text
    separator: [ #sym.dash.em ],
  )

  // ## Quotes. Citações.
  // NBR 10520:2023 7.1.1
  show quote: it => {
    // Long quotes (more than 3 lines) should be blocks.
    if it.block {
      format_quote(it)
    } else {
      it
    }
  }

  doc
}
