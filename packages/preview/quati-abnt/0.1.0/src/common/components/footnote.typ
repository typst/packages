// # Footnotes. Notas de rodapé.
// NBR 14724:2024 5.2.1

#import "../style/style.typ": font_size_for_smaller_text

#let format_footnote_entry(body) = context {
  set text(size: font_size_for_smaller_text)

  grid(
    columns: 2,
    gutter: 3pt,
    body.note, body.note.body,
  )
}
