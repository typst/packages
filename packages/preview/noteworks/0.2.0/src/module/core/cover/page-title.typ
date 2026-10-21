#import "../../../core/setup.typ": nw-config, nw-theme

#let project(number: "", title: "", author: "", affiliation: "", date: none, body) = {
  counter(heading).update(0)

  // Extract page ID from number (e.g., "Section 01.01" -> "01.01").
  // When number is content (resolved via context by book.typ), there is
  // no string to derive a label from; book.typ emits its own anchor.
  let page-id = if type(number) != str {
    none
  } else if number != "" and number.contains(" ") {
    number.split(" ").last()
  } else {
    number
  }

  // Page numbering is scoped to content pages: covers, preface, and
  // TOC pages render their own page() calls without numbering.
  set page(numbering: "1")

  context {
    let theme = nw-theme()
    let c = nw-config()

    let chapters = query(selector(std.metadata).before(here())).filter(el => {
      // Guard: user content may contain unlabeled #metadata(...) elements
      el.has("label") and str(el.label).starts-with("chapter-")
    })
    let chapter = if chapters.len() > 0 { chapters.last() } else { none }

    if page-id != none and page-id != "" {
      [#std.metadata((number, title, chapter)) #label(page-id)]
    }

    let display_date = if date == none {
      datetime.today().display("[Month]/[day], [year]")
    } else {
      date
    }

    // set heading(numbering: "1.1.")
    show heading: it => block(below: 1em)[
      #text(weight: "bold", fill: theme.text-heading, font: c.font, it)
    ]

    // Title Block
    align(left)[
      #if number != "" [
        #block(below: 1em)[
          #text(size: 22pt, fill: theme.text-accent, font: c.title-font, number)
        ]
      ]
      #block(below: 1em)[
        #text(weight: "bold", style: "italic", size: 40pt, font: c.title-font, title)
      ]

      #if author != "" [
        #block(below: 0.5em)[
          #text(size: 16pt, font: c.font, author)
        ]
      ]

      #if affiliation != "" [
        #block(below: 0.5em)[
          #text(size: 13pt, font: c.font, fill: theme.text-muted, affiliation)
        ]
      ]
    ]
  }

  context {
    line(length: 100%, stroke: 1pt + nw-theme().text-muted)
  }

  body
}
