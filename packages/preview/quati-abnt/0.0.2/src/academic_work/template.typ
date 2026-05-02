#import "../common/style/style.typ": margin_bottom, margin_end, margin_start, margin_top, paper_size
#import "../common/template.typ": template as common_template
#import "./components/heading.typ": format_heading
#import "./components/page.typ": consider_only_odd_pages as consider_only_odd_pages_state, format_header

#let template(
  doc,
  // Color to format links.
  color_of_links: none,
  // Whether to print content on the back of pages.
  consider_only_odd_pages: true,
  // Whether to number pages and print its number on the header.
  should_number_pages: false,
  // Whether to display editor notes.
  should_display_editor_notes: true,
) = {
  consider_only_odd_pages_state.update(consider_only_odd_pages)

  // ## Page. Página.
  // NBR 14724:2024 5.1
  // When the document is printed double-sided, the inner margin should be larger than the outer margin
  let margin = if consider_only_odd_pages {
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
    header: format_header(should_number_pages),
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
      it,
    )
  }

  common_template(
    doc,
    color_of_links: color_of_links,
    should_display_editor_notes: should_display_editor_notes,
  )
}
