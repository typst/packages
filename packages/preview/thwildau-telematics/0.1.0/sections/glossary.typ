#import "../utils/translation.typ": translation

#let make-glossary(glossary: ()) = {
  pagebreak(weak: true)
  [= #translation("Glossary")]
  table(
    columns: (1fr, auto),
    table.header(translation("Term"), translation("Description")),
    ..glossary.flatten(),
  )
}

