#import "/src/constants/document-settings-constants.typ": SINGLE-LINE-PARAGRAPH-LEADING-SIZE
#import "/src/styles/outline-entry-fill-style.typ": outline-entry-fill-style

// Matematiksel Denklemler listesinin girdilerinin stili. [Style of the entries of the Math Equation lists.]
#let table-of-contents-outline-entry-style(content) = {
  // Ana hattaki girdi satırlarının içeriğindeki doldurma stili. [Outline entry content's fill style.]
  show: outline-entry-fill-style

  // Düzey 1 satırlardaki metni kalın yap. [Set Level 1 outlines' text bold.]
  show outline.entry.where(level: 1): set text(weight: "bold")

  // Düzey 1 satırları arasında, paragraflardaki satırlar arası tek satırlık boşluğa ek olarak satır üstüne 10pt boşluk bırak. [Between Level 1 lines, leave a 10pt space above the line, in addition to the single line space between lines in paragraphs.]
  show outline.entry.where(level: 1): set block(above: SINGLE-LINE-PARAGRAPH-LEADING-SIZE + 10pt)

  // Düzey 2 satırları arasında, paragraflardaki satırlar arası tek satırlık boşluğa ek olarak satır üstüne 3pt boşluk bırak. [Between Level 2 lines, leave a 3pt space above the line, in addition to the single line space between lines in paragraphs.]
  show outline.entry.where(level: 2): set block(above: SINGLE-LINE-PARAGRAPH-LEADING-SIZE + 3pt)

  // Düzey 3 satırları arasında, paragraflardaki satırlar arası tek satırlık boşluğa ek olarak satır üstüne 3pt boşluk bırak. [Between Level 3 lines, leave a 3pt space above the line, in addition to the single line space between lines in paragraphs.]
  show outline.entry.where(level: 3): set block(above: SINGLE-LINE-PARAGRAPH-LEADING-SIZE + 3pt)

  /*
  // Set headings and special appendices numbering
  show outline.entry.where(level: 1).or(outline.entry.where(level: 2)).or(outline.entry.where(level: 3)): it => {
    let cc = if it.element.numbering != none {
      numbering(it.element.numbering, ..counter(heading).at(it.element.location()))
    }

    //let indent = h(1.5em + ((it.level - 2) * 1.5em))
    /*
      box(
        grid(
          columns: (auto, 1fr, auto),
          indent + link(it.element.location())[#cc #h(0.1em) #it.element.body #h(5pt)],
          it.fill,
          box(width: 1.5em, align(right, it.page)),
        ),
      )
    */
    it
  }
  */

  content
}
