#let formation = (
  PREP-TRANSI: image("media/Prepa-t.jpg"),
  A7: image("media/Toulouse-INP-A7.jpg"),
  ENSAT: image("media/Toulouse-INP-Ensat.jpg"),
  FC: image("media/Toulouse-INP-FC.jpg"),
  LA_PREPA: image("media/Toulouse-INP-LaPrepa.jpg"),
  N7: image("media/Toulouse-INP-N7.jpg"),
  INP: image("media/Toulouse-INP.jpg"),
)

#let tlseinp(
  title: "Toulouse INP Template",
  subtitle: "Subtitle",
  page-header: "Toulouse INP Template",
  author: "Your name",
  group: none,
  year: "2024",
  class: none,
  formation-image: formation.INP,
  project-image: none,
  lang: "en",
  body,
) = {

  // Set the document's basic properties.
  set document(author: author, title: title)
  set text(lang: lang, 11pt)

  // First page
  align(center + horizon, text(3em, weight: "semibold", title))
  v(2em, weak: true)
  align(center, text(1.7em, weight: "regular", subtitle))

  if group != none {
    align(center + bottom, text(1.3em, weight: "light", group))
    v(1em, weak: true)
  }
  align(center + bottom, text(1.3em, weight: "light", author))
  v(4em, weak: true)
  align(center + bottom, text(1.3em, weight: "light", class))
  v(1em, weak: true)
  align(center + bottom, text(1.3em, weight: "light", year))
  
  set image(width: 7cm)
  place(top + left, formation-image)
  if project-image != none {
    place(top + right, project-image)
  }

  // heading numberin
  set text(hyphenate: false)
  set heading(numbering: (..n) => {
    if n.pos().len() <= 5 {
      numbering("1.1", ..n)
    } 
  })
  show heading: it => {
    set text(weight: "semibold")
    smallcaps(it+ v(0.5em))
  }

  
  // link style
  show link: it => underline(text(fill: rgb("1947BA"), it))
  
  //customize inline raw code
  show raw.where(block: false) : it =>  text(style: "italic", it)
  show raw.where(block: true): block.with(fill: luma(240), inset: 10pt, radius: 4pt)

  // modify list indent
  set enum(indent: 1em)

  // modify unordered list indent and marker
  set list(indent: 1em, marker: n => [#text("•")])

  // figure
  show figure.where(kind: image): set figure(supplement: "Figure")
  show figure.where(kind: list): set figure(supplement: "Listing")

  // outline
  set outline(depth: 5)
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  pagebreak()

  // Main body.
  set page(
    header: {
      emph()[#page-header #h(1fr) #author]
      line(length: 100%)
    },
    numbering: "1", 
    number-align: center,
  )
  
  set par(first-line-indent: 1em, justify: true)
  
  body
}

// show a list of livrables
#let deliverables(headingName: "Deliverables", dict) = {
  [= #headingName]
  for (name, desc) in dict {
    list(
      [*#name* - #desc],
    )
  }
}

// show the list of figures in the document
#let figures(headingName: "Table of figures", kind: image) = {  
  // reset outline style
  show outline.entry.where(level: 1): it => text([#it.body #box(width: 1fr, repeat[.]) #it.page])

  if kind == none {
    outline(target: figure, title: [#headingName])
  } else {
    outline(target: figure.where(kind: kind), title: [#headingName])
  }
}

// show the list of appendices (if show-outline is true) and includean other file with all appendices
#let appendices(title: "Table of appendices", show-outline: true, import-files) = {
  set heading(numbering: none)
  if show-outline {
    // reset outline style
    show outline.entry.where(level: 1): it => text([#it.body #box(width: 1fr, repeat[.]) #it.page])
    
    context {
      outline(target: selector(heading).after(here()), title: [#title])
    }
  }
    
  import-files
}