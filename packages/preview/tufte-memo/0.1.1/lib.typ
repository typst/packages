#import "@preview/drafting:0.2.0": *

#let wideblock(content) = block(width:100%+2.5in,content)

// Fonts used in front matter, sidenotes, bibliography, and captions
#let sans-fonts = (
    "Gill Sans MT",
    "TeX Gyre Heros",
    "Noto Sans"
  )

// Fonts used for headings and body copy
#let serif-fonts = (
  "Lucida Bright",
  "New CM",
  "Linux Libertine",
)

#let template(
  title: [Paper Title],
  shorttitle: none,
  subtitle: none,
  authors: (
    (
      name: "First Last",
      role: none,
      organization: none,
      location: none,
      email: none
    ),
  ),
  date: datetime.today(),
  document-number: none,
  draft: false,
  distribution: none,
  abstract: none,
  publisher: none,
  toc: false,
  bib: none,
  footer-content: none,
  doc
) = {
  // Document metadata
  set document(title: title, author: authors.map(author => author.name))

  // Just a suttle lightness to decrease the harsh contrast
  set text(fill:luma(30))

  // Tables and figures
  show figure: set figure.caption(separator: [.#h(0.5em)])
  show figure.caption: set align(left)
  show figure.caption: set text(font: "Gill Sans MT")

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(numbering: "I")
  
  show figure.where(kind: image): set figure(supplement: [Figure], numbering: "1")
  
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): set figure(supplement: [Code], numbering: "1")
  show raw: set text(font: "Lucida Console", size: 10pt)

  // Equations
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  show link: underline

  // Lists
  set enum(
    indent: 1em,
    body-indent: 1em,
  )
  show enum: set par(justify: false)
  set list(
    indent: 1em,
    body-indent: 1em,
  )
  show list: set par(justify: false)

  // Headings
  set heading(numbering: none,)
  show heading.where(level:1): it => {
    v(2em,weak:true)
    text(size:14pt, weight: "bold",it)
    v(1em,weak: true)
  }

  show heading.where(level:2): it => {
    v(1.3em, weak: true)
    text(size: 13pt, weight: "regular",style: "italic",it)
    v(1em,weak: true)
  }

  show heading.where(level:3): it => {
    v(1em,weak:true)
    text(size:11pt,style:"italic",weight:"thin",it)
    v(0.65em,weak:true)
  }

  show heading: it => {
    if it.level <= 3 {it} else {}
  }

  // Page setup
  set page(
    paper: "us-letter",
    margin: (
      left: 1in,
      right: 3.5in,
      top: 1.5in,
      bottom: 1.5in
    ),
    header: context {
      set text(font: "Gill Sans MT")
      block(width: 100% + 3.5in - 1in,{
      if counter(page).get().first() > 1 {
        if document-number != none {document-number}
        h(1fr)
        if shorttitle != none {upper(shorttitle)} else {upper(title)}
        if publisher != none {
          linebreak()
          h(1fr)
          upper(publisher)
        }
      }})
    },
    footer: context {
      set text(font: "Gill Sans MT",size: 8pt)
      block(width: 100% +3.5in - 1in,{
      if counter(page).get().first() == 1 {
        if type(footer-content) == array {
          footer-content.at(0)
          linebreak()
        } else {
          footer-content
          linebreak()
        }
        if draft [
          Draft document, #date.display().
        ]
        if distribution != none [
          Distribution limited to #distribution.
        ]
      } else {
        if type(footer-content) == array {
          footer-content.at(1)
          linebreak()
        } else {
          footer-content
          linebreak()
        }
        if draft [
          Draft document, #date.display().
        ]
        if distribution != none [
          Distribution limited to #distribution.
        ]
        linebreak()
        [Page #counter(page).display()]
      }
    })},
    background: if draft {rotate(45deg,text(font:"Gill Sans MT",size:200pt, fill: rgb("FFEEEE"))[DRAFT])}
  )

  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1em
  )
  show par: set block(
    spacing: 0.65em
  )

  // Frontmatter
  let titleblock(title: none,subtitle: none,) = wideblock({
      set text(
        hyphenate: false,
        size: 20pt,
        font: sans-fonts
      )
      set par(
        justify: false,
        leading:0.2em,
        first-line-indent: 0pt
      )
      upper(title)
      set text(size: 11pt)
      v(-0.65em)
      upper(subtitle)
    })
  let authorblock(authors) = wideblock({
    set text(font: "Gill Sans MT", size: 11pt)
    v(1em)
    for i in range(calc.ceil(authors.len() / 3)) {
      let end = calc.min((i + 1) * 3, authors.len())
      let is-last = authors.len() == end
      let slice = authors.slice(i * 3, end)
      grid(
        columns: slice.len() * (1fr,),
        gutter: 11pt,
        ..slice.map(author => align(left, {
          upper(author.name)
          if "role" in author [
            \ #author.role
          ]
          if "organization" in author [
            \ #author.organization
          ]
          if "email" in author [
            \ #author.email
          ]
        }))
      )

      if not is-last {
        v(16pt, weak: true)
      }
    }})
  let abstractblock(abstract) = wideblock({
      set text(font: "Gill Sans MT")
      set par(hanging-indent: 3em)
      h(3em)
      abstract
    })
  let tocblock() = wideblock({
      set text(font: "Gill Sans MT")
      outline(indent:1em,title:none,depth:2)
    })

  titleblock(title:title, subtitle:subtitle)
  authorblock(authors)
  text(size:11pt,font: "Gill Sans MT",{
    if date != none {upper(date.display("[month repr:long] [day], [year]"))}
    linebreak()
    if document-number != none {document-number}
  })
  

  if abstract != none {abstractblock(abstract)}
  if toc {tocblock()}

  // Finish setting up sidenotes
  set-page-properties()
  set-margin-note-defaults(
    stroke: none,
    side: right,
    margin-right: 2.35in,
    margin-left: 1.35in,
  )

  // Body text
  set text(
    font: serif-fonts,
    style: "normal",
    weight: "regular",
    hyphenate: true,
    size: 11pt
  )

  doc

  show bibliography: set text(font:sans-fonts)
  show bibliography: set par(justify:false)
  set bibliography(title:none)
  if bib != none {
    heading(level:1,[References])
    bib
  }
}

/* Sidenotes
Display content in the right margin with the `note()` function.
Takes 2 optional keyword and 1 required argument:
  - `dy: length` Adjust the vertical position as required (default `0pt`).
  - `numbered: bool` Display a footnote-style number in text and in the note (default `true`).
  - `content: content` The content of the note.
*/
#let notecounter = counter("notecounter")
#let note(dy:-2em, numbered:true, content) = {
  if numbered {
    notecounter.step()
    text(weight:"bold",super(notecounter.display()))
  }
  text(size:9pt,font: "Gill Sans MT",margin-note(if numbered {
    text(weight:"bold",font:"Lucida Bright",size:11pt,{
      super(notecounter.display())
      text(size: 9pt, " ")
    })
    content
  } else {
    content}
    ,dy:dy))
  }

/* Sidenote citation
Display a short citation in the right margin with the `notecite()` function.
Takes 2 optional keyword and 1 required argument.
  - `dy: length` Adjust the vertical position as required (default `0pt`).
  - `supplement: content` Supplement for the in-text citation (e.g., `p.~7`), (default `none`).
  - `key: label` The bibliography entry's label.

CAUTION: if no bibliography is defined, then this function will not display anything.
*/
#let notecite(dy:-2em,supplement:none,key) = context {
  let elems = query(bibliography)
  if elems.len() > 0 {
    cite(key,supplement:supplement,style:"ieee")
    note(
      cite(key,form: "full",style: "template/short_ref.csl"),
      dy:dy,numbered:false
    )
  }
}