#import "colors.typ": color-schema

#let outline-rules(body) = {
  set outline(title: [Contents], depth: 3, indent: auto)

  show outline.entry.where(level: 1): it => {
    // Add some space above
    v(12pt, weak: true)

    // Entry style
    // If the entry refers to a numbered chapter
    // then show "Chapter" at the beginning of the entry
    if it.element.numbering == "1.1" {
      text(weight: "bold", size: 12pt, fill: color-schema.blue.dark)[
        Chapter
        #smallcaps(it)
      ]
    } else {
      // If the entry refers to an unnumbered chapter
      // then only show the title
      text(weight: "bold", size: 12pt, fill: color-schema.blue.dark)[
        #smallcaps(it)
      ]
    }
  }

  show outline: it => {
    // Outline content
    it

    // Reset the page counter
    // at the end of the outline
    counter(page).update(0)
  }

  // The rest of the document
  body
}