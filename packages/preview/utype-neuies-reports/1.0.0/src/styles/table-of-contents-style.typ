#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/styles/outline-entry-fill-style.typ": outline-entry-fill-style

#let table-of-contents-style(content) = {
  // Ana hat ayarları. [Outline settings.]
  set outline(
    depth: 3,
    indent: n => n * 1em,
    target: heading,
    title: upper(translator(key: language-keys.TABLE-OF-CONTENTS)),
  )

  // Ana hattaki girdi satırlarının içeriğindeki doldurma stili. [Outline entry content's fill style.]
  show: outline-entry-fill-style

  // Düzey 1 satırlardaki metni kalın yap. [Set Level 1 outlines' text bold.]
  show outline.entry.where(level: 1): set text(weight: "bold")

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
