#import "../common/style/style.typ": margin_bottom, margin_end, margin_start, margin_top, paper_size
#import "../common/template.typ": template as common_template
#import "../common/util/font_family.typ": font_family_math, font_family_mono, font_family_sans, font_family_serif
#import "./components/heading.typ": format_heading
#import "./components/page.typ": format_header, should_consider_only_odd_pages as should_consider_only_odd_pages_state

#let template(
  doc,
  //
  // Color to format links.
  color_of_links: none,
  //
  // Font families.
  font_family_for_common_text: font_family_serif,
  font_family_for_highlighted_text: font_family_sans,
  font_family_for_math_text: font_family_math,
  font_family_for_monospaced_text: font_family_mono,
  font_family_for_editor_notes: font_family_sans,
  //
  // Whether to use uppercase as typographic highlight.
  should_use_larger_text_to_highlight: false,
  //
  // Whether to print content on the back of pages.
  should_consider_only_odd_pages: true,
  //
  // Whether to number pages and print its number on the header.
  should_number_pages: false,
  //
  // Whether to display editor notes.
  should_display_editor_notes: true,
) = {
  should_consider_only_odd_pages_state.update(should_consider_only_odd_pages)

  // ## Page. Página.
  // NBR 14724:2024 5.1
  // When the document is printed double-sided, the inner margin should be larger than the outer margin
  let margin = if should_consider_only_odd_pages {
    (
      top: margin_top,
      right: margin_end,
      bottom: margin_bottom,
      left: margin_start,
    )
  } else {
    (
      top: margin_top,
      outside: margin_end,
      bottom: margin_bottom,
      inside: margin_start,
    )
  }
  set page(
    paper: paper_size,
    margin: margin,
    header: format_header(
      should_number_pages: should_number_pages,
    ),
  )

  // ## Headings. Títulos.
  // NBR 14724:2024.
  show heading: set heading(
    supplement: "Subseção",
  )
  show heading.where(level: 1): set heading(supplement: "Capítulo")
  show heading.where(level: 2): set heading(supplement: "Seção")

  // ### Format. Formatação.
  show heading: it => {
    format_heading(
      should_use_larger_text_to_highlight: should_use_larger_text_to_highlight,
      it,
    )
  }

  common_template(
    doc,
    color_of_links: color_of_links,
    font_family_for_common_text: font_family_for_common_text,
    font_family_for_highlighted_text: font_family_for_highlighted_text,
    font_family_for_math_text: font_family_for_math_text,
    font_family_for_monospaced_text: font_family_for_monospaced_text,
    font_family_for_editor_notes: font_family_for_editor_notes,
    should_use_larger_text_to_highlight: should_use_larger_text_to_highlight,
    should_display_editor_notes: should_display_editor_notes,
  )
}
