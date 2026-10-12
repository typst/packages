#import "../common/components/font_family.typ": font_family_math, font_family_mono, font_family_sans, font_family_serif
#import "../common/components/heading.typ": format_heading
#import "../common/style.typ": base_font_size, margin_bottom, margin_end, margin_start, margin_top
#import "../common/template.typ": template as common_template

#let template(
  doc,
  //
  // Font size.
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
  //
  // Whether to number pages and print its number on the header.
  should_number_pages: true,
) = {
  // ## Page. Página.
  set page(
    margin: (
      top: margin_top,
      right: margin_end,
      bottom: margin_bottom,
      left: margin_start,
    ),
    numbering: if should_number_pages { "1" } else { none },
    number-align: top + end,
  )

  // ## Headings. Títulos.
  // NBR 6024:2012.
  show heading: set heading(
    supplement: "Subseção",
  )
  show heading.where(
    level: 1,
  ): set heading(
    supplement: "Seção",
  )

  // ### Format. Formatação.
  show heading: it => {
    format_heading(
      should_use_larger_text_instead_of_uppercase_to_highlight: should_use_larger_text_instead_of_uppercase_to_highlight,
      it,
    )
  }

  common_template(
    doc,
    base_font_size: base_font_size,
    font_family_for_common_text: font_family_for_common_text,
    font_family_for_highlighted_text: font_family_for_highlighted_text,
    font_family_for_math_text: font_family_for_math_text,
    font_family_for_monospaced_text: font_family_for_monospaced_text,
    should_use_larger_text_instead_of_uppercase_to_highlight: should_use_larger_text_instead_of_uppercase_to_highlight,
  )
}
