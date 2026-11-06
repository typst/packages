#import "../common/components/heading.typ": format_heading
#import "../common/style/style.typ": margin_bottom, margin_end, margin_start, margin_top
#import "../common/template.typ": template as common_template

#let template(
  doc,
  color_of_links: none,
  should_number_pages: true,
  should_display_editor_notes: true,
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
      it,
    )
  }

  common_template(
    doc,
    color_of_links: color_of_links,
    should_display_editor_notes: should_display_editor_notes,
  )
}
