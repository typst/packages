// # Footnotes. Notas de rodapé.
// NBR 14724:2024 5.2.1

#import "../common/style.typ": (
  font_size_for_smaller_text, simple_leading_for_smaller_text, simple_spacing_for_smaller_text,
)
#import "../common/components/font_family.typ": base_font_size_state


// ## Template. Modelo.
#let template(
  doc,
) = {
  set footnote.entry(
    gap: simple_leading_for_smaller_text,
    clearance: simple_spacing_for_smaller_text,
    separator: line(length: 5cm),
    indent: 0em,
  )

  show footnote.entry: it => context {
    let number = numbering(
      it.note.numbering,
      ..counter(
        footnote,
      ).at(
        it.note.location(),
      ),
    )
    let prefix = link(
      it.note.location(),
      number,
    )
    let body = it.note.body

    let footnote_block = block(
      inset: (left: it.indent),
      grid(
        columns: (auto, 1fr),
        gutter: 0.25em,
        prefix, body,
      ),
    )

    // If the user is using a common template that defines a base font size, adjust the footnotes to follow the same value
    let value_of_base_font_size_state = base_font_size_state.get()
    if value_of_base_font_size_state != none {
      set text(size: value_of_base_font_size_state)
      set text(size: font_size_for_smaller_text)
      footnote_block
    } else {
      set text(size: font_size_for_smaller_text)
      footnote_block
    }
  }

  doc
}
