// elsearticle.typ
// Author: Mathieu Aucejo
// Github: https://github.com/maucejo
// License: MIT
// Date : 07/2024

#let font-size = (
  script: 7pt,
  footnote: 8pt,
  small: 10pt,
  normal: 11pt,
  author: 12pt,
  title: 17pt,
)

#let linespace = (
  preprint: 1em,
  review: 1.5em,
)

#let indent-size = 2em

#let margins = (
  review: (left: 105pt, right: 105pt, top: 130pt, bottom: 130pt),
  preprint: (left: 105pt, right: 105pt, top: 130pt, bottom: 130pt),
  one_p: (left: 105pt, right: 105pt, top: 140pt, bottom: 140pt),
  three_p: (left: 64pt, right: 64pt, top: 110pt, bottom: 110pt),
  five_p: (left: 37pt, right: 37pt, top: 80pt, bottom: 80pt)
)

#let isappendix = state("isappendix", false)

// Equations
#let nonumeq(body) = {
  set math.equation(numbering: none)
  body
}

// Figures
#let subfigure = figure.with(
    kind: "subfigure",
    supplement: [],
    numbering: "(a)",
)

// Appendix
#let appendix(body) = {
  set heading(numbering: "A.1.")
  // Reset heading counter
  counter(heading).update(0)

  // Equation numbering
  let numbering-eq = n => {
    let h1 = counter(heading).get().first()
    numbering("(A.1)", h1, n)
  }
  set math.equation(numbering: numbering-eq)

  // Figure and Table numbering
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("A.1", h1, n)
  }
  show figure.where(kind: image): set figure(numbering: numbering-fig)
  show figure.where(kind: table): set figure(numbering: numbering-fig)

  isappendix.update(true)

  body
}

#let elsearticle(
  // The article's title.
  title: none,

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // Your article's abstract. Can be omitted if you don't have one.
  abstract: none,

  // Journal name
  journal: none,

  // Keywords
  keywords: none,

  // For integrating future formats (1p, 3p, 5p, final)
  format: "review",

  // Number of columns
  numcol: 1,

  // Bibliography
  bibliography-file: none,

  // The document's content.
  body,
) = {
  // Text
  set text(size: font-size.normal, font: "New Computer Modern")

  // Conditional formatting
  let els-linespace = if format == "review" {linespace.review} else {linespace.preprint}

  let els-margin = if format == "review" {margins.review}
  else if format == "preprint" {margins.preprint}
  else if format == "1p" {margins.one_p}
  else if format == "3p" {margins.three_p}
  else if format == "5p" {margins.five_p}
  else {margins.review}

  let els-columns = if format == "1p" {1}
  else if format == "5p" {2}
  else {if numcol > 2 {2} else {if numcol <= 0  {1} else {numcol}}}

  // Heading
  set heading(numbering: "1.")

  show heading: it => block(above: els-linespace, below: els-linespace)[
    #if it.numbering != none {
      if it.level == 1 {
        set par(leading: 0.75em, hanging-indent: 1.25em)
        set text(font-size.normal)
        numbering(it.numbering, ..counter(heading).at(it.location()))
        text((" ", it.body).join())

        // Update math counter at each new appendix
        if isappendix.get() {
          counter(math.equation).update(0)
          counter(figure.where(kind: image)).update(0)
          counter(figure.where(kind: table)).update(0)
        }
      } else {
        set text(font-size.normal, weight: "regular", style: "italic")
        numbering(it.numbering, ..counter(heading).at(it.location()))
        text((" ", it.body).join())
      }
    } else {
      text(size: font-size.normal, it.body)
    }
  ]

  // Equations
  set math.equation(numbering: "(1)", supplement: [Eq.])

  // Figures, subfigures, tables
  // Updates reference counter properly
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind == "subfigure" {
        context{
          let fignum = counter(figure.where(kind: image)).at(here()).first() + 1
          let subfignum = numbering("a", counter(figure.where(kind: "subfigure")).at(el.location()).first())
          if isappendix.get(){
            let heading-counter = numbering("A.1", counter(heading).get().first())
            link(it.target, [Fig. #heading-counter.#fignum#subfignum])
          } else {
            link(it.target, [Fig. #fignum#subfignum])
          }
        }
      } else if el != none and el.func() == figure and repr(el.kind) == "image" {
        let fignum = counter(figure.where(kind: image)).at(el.location()).first()
        if isappendix.get() {
          let heading-counter = numbering("A.1", counter(heading).get().first())
          link(it.target, [Fig. #heading-counter.#fignum])
        } else {
          link(it.target, [Fig. #fignum])
        }
    } else {
      it
    }
  }

  // Formatting figures and tables properly
  show figure: it => align(center)[
    #if repr(it.kind) == "table" {
    block(
      [
        #text(it.caption, top-edge: 0.15em, size: font-size.small)
        #it.body
     ]
    )
    } else {
      if repr(it.kind).slice(0, 5) == "\"subf" {
        block(
        [
          #it.body
          #it.supplement #it.counter.display(it.numbering) #it.caption
        ]
        )
      } else {
        block(
        [
          #it.body
          #v(0.5em)
          #align(left)[#text(it.caption, top-edge: 0.15em, size: font-size.small)]
        ]
        )
        counter(figure.where(kind: "subfigure")).update(0)
      }
    }
  ]

  // Paragraph
  set par(justify: true, first-line-indent: indent-size, leading: els-linespace)

  // Page
  set page(
        paper: "a4",
        numbering: "1",
        margin: els-margin,

        // Set journal name and date
        footer: context{
          let i = counter(page).at(here()).first()
          if i == 1 {
            set text(size: font-size.small)
            emph(("Preprint submitted to ", journal).join())
            h(1fr)
            emph(datetime.today().display("[month repr:long] [day], [year]"))
          } else {align(center)[#i]}
        },
      )

  // Set authors and affiliation
  let names = ()
  let names_meta = ()
  let affiliations = ()
  let coord = none
  for author in authors {
    let auth = (author.name, super(author.id))
    if author.corr != none {
      if author.id != none {
        auth.push(super((",", text(baseline: -1.5pt, "*")).join()))
      } else {
        auth.push(super(text(baseline: -1.5pt, "*")))
      }
      coord = ("Corresponding author. E-mail address: ", author.corr).join()
    }
    names.push(auth.join())
    names_meta.push(author.name)

    if author.affiliation == none {
      continue
    }
    else {
      affiliations.push((super(author.id), author.affiliation, v(font-size.script)).join())
    }
  }

  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: " and ")
  }

  // Set document metadata.
  set document(title: title, author: names_meta)

  // Display title and affiliation
  align(center,{
    par(leading: 0.75em, text(size: font-size.title, title))
    v(0pt)
    text(size: font-size.author, author-string)
    v(font-size.small)
    par(leading: 1em, text(size: font-size.small, emph(affiliations.join()), top-edge: 0.5em))
    v(1.5em)
  })

  // Corresponding author
  v(-2em)
  hide(footnote(coord, numbering: "*"))
  counter(footnote).update(0)

  // Display the abstract
  if abstract != none {
    line(length: 100%)
    text(weight: "bold", [Abstract])
    v(1pt)
    h(-indent-size); abstract
    linebreak()
    if keywords !=none {
      let kw = ()
      for keyword in keywords{
        kw.push(keyword)
      }

    let kw-string = if kw.len() > 1 {
        kw.join(", ")
      } else {
        kw.first()
      }
      text((emph("Keywords: "), kw-string).join())
    }
    line(length: 100%)
  }

  // bibliography
  set bibliography(title: "References")
  show bibliography: set heading(numbering: none)
  show bibliography: set text(size: font-size.normal)

  show: columns(els-columns, body)
}
