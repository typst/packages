// Official Typst package for the Forum Acusticum 2026 conference.
//
// Authors: Felix Holzmüller, Thomas Röck
// This package is based on the charged-ieee template https://github.com/typst/templates
//
#import "@preview/pubmatter:0.2.2": get-corresponding-author, load as pm_load
#import "helpers.typ": *

#let conferenceedition = [12#super[th]]
#let conferencedate = [8#super[th] -- 12#super[th] September]
#let conferenceyear = [2026]
#let conferencelocation = [Graz, Austria]

#let fa2026(
  // The paper's title.
  title: [Paper Title],
  // An array of authors. For each author you can specify a name,
  // an affiliation and, if they are the corresponding author, their email.
  authors: (),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // A list of index terms to display after the abstract.
  keywords: (),
  // Whether the paper undergoes peer review.
  peer-review: false,
  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,
  // The paper's content.
  body,
) = {
  // Process authors and affiliations.
  let fm = pm_load((authors: authors))

  // Set document metadata.
  // set document(title: title, author: authors.map(author => author.name))

  let blueAcoustics = rgb("#3977aa")

  // Set footer color and image based on peer-review status.
  let logo_eaa = "assets/footer_logo_eaa_bw.pdf"
  let logo_oega = "assets/footer_logo_oega_bw.jpg"
  let logo_fa = "assets/fa26_banner_white_rgb.png"
  let review_notice = "This contribution has been accepted based on the submitted abstract. The submitted manuscript was not reviewed and is reproduced here without edits or corrections by the conference board. Neither the EAA nor the AAA take responsibility for its contents."

  if peer-review {
    logo_eaa = "assets/footer_logo_eaa.jpg"
    logo_oega = "assets/footer_logo_oega.jpg"
    logo_fa = "assets/fa26_banner_light_rgb.png"
    review_notice = "This paper is a revised version of the authors' submitted manuscript that was peer-reviewed by at least two anonymous reviewers."
  }

  // Set the main font.
  set text(font: "Latin Modern Roman", size: 10pt)

  // Enums numbering
  set enum(numbering: "1)a)i)")

  // Tables & figures
  show figure: set block(spacing: 1.5em + 0.5pt)
  show figure: set place(clearance: 1.5em + 0.5pt)
  show figure.where(kind: table): set figure.caption(position: top)

  show list: set block(above: 1em, below: 1em)

  // Adapt supplement in caption independently from supplement used for
  // references.
  set figure.caption(separator: [: #h(0.5em)])
  show figure: fig => {
    let prefix = [#fig.supplement]
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    show figure.caption: it => {
      set text(size: 9pt)
      layout(size => context [
        #let figure-caption = block[*#prefix~#numbers#it.separator*#it.body]
        #let text-size = measure(
          figure-caption,
          width: size.width,
        )
        #let supplement-size = measure(it.supplement)
        #if text-size.height > supplement-size.height {
          align(left, figure-caption)
        } else {
          align(center, figure-caption)
        }
      ])
    }
    fig
  }

  // Code blocks
  show raw: set text(
    font: "Latin Modern Mono",
    ligatures: false,
    size: 1em / 0.8,
    spacing: 100%,
  )

  // Configure the page and multi-column properties.
  set columns(gutter: 0.8cm)
  set page(
    columns: 2,
    paper: "a4",
    // The margins depend on the paper size.
    margin: (x: 2cm, top: 2cm, bottom: 3.5cm),
    footer-descent: 24pt,
    footer: grid(
      columns: (1fr, 5fr, 1fr),
      align: (left + bottom, center + bottom, right + bottom),
      inset: (0pt, 7pt, 0pt),
      [#link("https://euracoustics.org/", image(logo_eaa, height: 1.36cm))],
      [
        #text(
          size: 10pt,
          weight: "bold",
          spacing: 100%,
          fill: color.black,
        )[#conferenceedition #h(0.5em, weak: true) Convention of the European Acoustics Association]
        #linebreak()
        #text(
          size: 9pt,
          fill: color.black,
        )[#set text(spacing: 140%)
          #conferencelocation #sym.bullet #conferencedate #conferenceyear #sym.bullet #h(22pt)]],
      [#link("http://aaa-oega.org/", image(logo_oega, height: 1.36cm))],
    ),
  )


  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), [Eq. #numbering(
          it.element.numbering,
          ..counter(math.equation).at(it.element.location()),
        )])
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  //
  set heading(numbering: "1.1.1.")
  show heading: it => {
    let levels = counter(heading).get()
    if it.level == 1 {
      if levels == () {
        levels = (1,)
      }
      set text(size: 12pt, weight: "bold")
      show: block.with(above: 0.5em + 8pt, below: 0.5em + 1pt, sticky: true)
      if (it.numbering == none) {
        it
      } else {
        numbering("1.1.1.", levels.at(0))
        h(0.5em, weak: true)
        it.body
      }
    } else if it.level == 2 {
      if levels == () {
        levels = (1, 1)
      }
      set text(size: 10pt, weight: "bold")
      show: block.with(above: 0.5em + 6pt, below: 0.5em + 1pt, sticky: true)
      numbering("1.1.1.", levels.at(0), levels.at(1))
      h(0.5em, weak: true)
      it.body
    } else if it.level == 3 {
      if levels == () {
        levels = (1, 1, 1)
      }
      set text(size: 10pt, weight: "regular", style: "italic")
      show: block.with(above: 0.5em + 4pt, below: 0.5em + 1pt, sticky: true)
      numbering("1.1.1.", levels.at(0), levels.at(1), levels.at(2))
      h(0.5em, weak: true)
      it.body
    } else {
      it
    }
  }

  set footnote.entry(separator: line(length: 40%, stroke: 0.3pt), clearance: 0.5em)
  // Style bibliography.
  set std.bibliography(title: text(12pt)[References], style: "ieee")

  set text(spacing: 3pt)

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  place(
    top + center,
    dy: -47pt,
    float: true,
    scope: "parent",
    clearance: -22pt,
    {
      set align(center)

      image(logo_fa, width: 12.5cm)
      v(5pt)

      set text(size: 14pt)
      block(below: 15pt, upper[*#title*])

      // Display the authors list.
      show-authors(fm, size: 12pt)
      linebreak()
      v(-8pt)
      show-affiliations(fm, separator: linebreak(), size: 10pt)
      linebreak()
      v(-30pt)
      set text(size: 8pt, spacing: 150%)
      set align(left)
      set par(justify: true, leading: 2.5pt)
      review_notice
    },
  )


  // Set values to replicate LaTeX default behavior
  set par(justify: true, first-line-indent: 0em, spacing: 0.45em, leading: 0.45em)

  // Display abstract and index terms.
  if abstract != none {
    align(center)[#text(size: 12pt, weight: "bold")[Abstract]]
    v(0.5em)
    abstract

    let first_author = fm.authors.at(0).name

    if fm.len() > 1 {
      first_author = first_author + " et al."
    }

    let corresponding = link("mailto:" + get-corresponding-author(fm).email)
    let copyright_body = text(size: 8pt, style: "italic")[
      #set align(left)
      #set par(justify: true, leading: 3.5pt)
      #v(-1.5em)
      *Corresponding author: *#corresponding
      #linebreak()
      *Copyright: *#sym.copyright#conferenceyear #first_author This is an open-access article distributed under the terms of the Creative Commons Attribution 3.0 Unported License, which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited.
    ]
    show-copyright(copyright_body)

    if keywords != () {
      parbreak()
      v(0.5em)
      text(9pt)[*Keywords: *] + text(9pt, style: "italic")[#keywords.join[, ]]
    }
    v(-1pt)
  }

  // Display the paper's contents.
  body

  // Display bibliography.
  bibliography
}
