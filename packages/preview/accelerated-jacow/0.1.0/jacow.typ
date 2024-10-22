/*
 * Typst template for papers to be published with JACoW
 *
 * Based on the JACoW guide for preparation of papers.
 * See https://jacow.org/ for more information.
 * Requires Typst version 0.12 for compiling
 *
 * This document is licensed under CC BY 4.0.
 * https://creativecommons.org/licenses/by/4.0
 * Copyright (c) 2024 Philipp Niedermayer (github.com/eltos)
 */

#let jacow(
  paper-size: "jacow",
  title: "Title goes here",
  authors: (),
  affiliations: (),
  abstract: none,
  funding: none,
  body,
) = {

  // ensure author affiliation is a list
  authors = authors.map(a => {
    if type(a.affiliation) == str {
      a.insert("affiliation", (a.remove("affiliation"),));
    }; a
  })
  // sort authors: corresponding first, then alphabetic by last name
  authors = authors.sorted(key: a => if "email" in a {" "} + a.name.split(" ").last())


  /// Helper for custom footnote symbols
  let titlenotenumbering(i) = {
    if i < 6 { ("*", "#", "§", "¶", "‡").at(i - 1) + " " }
    else { (i - 4)*"*" + " " }
  }

  /// Capitalize all characters in the text, e.g. "THIS IS AN ALLCAPS HEADING"
  let allcaps = upper

  /// Capitalize major words, e.g. "This is a Word-Caps Heading"
  let wordcaps(body) = {
    if body.has("text") {
      let txt = lower(body.text)
      let words = txt.matches(regex("^()(\\w+)")) // first word
      words += txt.matches(regex("([.:;?!]\s+)(\\w+)")) // words after punctuation
      words += txt.matches(regex("()(\\w{4,})")) // words with 4+ letters
      for m in words {
        let (pre, word) = m.captures
        word = upper(word.at(0)) + word.slice(1)
        txt = txt.slice(0, m.start) + pre + word + txt.slice(m.end)
      }
      txt
    } else if body.has("children") {
      body.children.map(it => wordcaps(it)).join()
    } else {
      body
    }
  }





  // metadata

  set document(title: title, author: authors.map(author => author.name))



  // layout

  set page(..{
    if paper-size == "a4" {
      (paper: "a4", margin: (top: 37mm, bottom: 19mm, x: 20mm))
    } else if paper-size == "us-letter" {
      (paper: "us-letter", margin: (y: 0.75in, left: 0.79in, right: 1.02in))
    } else if paper-size == "jacow" { // jacow size is intersection of both
      (width: 209.9mm, height: 279.4mm, margin: (x: 20mm, y: 0.75in))
    } else {
      panic("Unsupported paper-size, use 'a4', 'us-letter' or 'jacow'!")
    }}
  )

  set text(
    font: "TeX Gyre Termes",
    size: 10pt
  )

  set par(
    first-line-indent: 1em,
    justify: true,
    spacing: 0.65em,
    leading: 0.5em,
  )


  // TODO: footnotes should not span both columns, but be in left column only
  show footnote.entry: set align(left)
  set footnote.entry(
    separator: [
      #set align(left)
      #line(length: 20%, stroke: 0.5pt)
    ]
  )



  /*
   * Title
   */

  set align(center)
  text(size: 14pt, weight: "bold", [
    #allcaps(title)
    #if funding!=none{
      footnote(numbering: titlenotenumbering, funding)
    }
  ])
  v(8pt)



  /*
   * Author list
   */

  text(size: 12pt, {
    let also_at = ();
    for aff in authors.map(a => a.affiliation.at(0)).dedup() {
      for auth in authors.filter(a => a.affiliation.at(0) == aff) {
        // author name with superscripts
        auth.name
        for aff2 in auth.affiliation.slice(1) {
          if aff2 not in also_at { also_at += (aff2,) }
          super(str(also_at.len()))
        }
        if "email" in auth {footnote(numbering: titlenotenumbering, auth.email)}
        ", "
      }
      // primary affiliations
      affiliations.at(aff) + "\n"
    };
    // secondary affiliations
    for i in range(also_at.len()) {
      super(str(i + 1))
      "also at " + affiliations.at(also_at.at(i)) + "\n"
    };
  })
  v(8pt)



  /*
   * Contents
   */

  // paragraph
  set align(left)
  show: columns.with(2, gutter: 0.2in)

  // headings
  show heading: it => [
    #if it.level == 1 { // SECTION HEADINGS
      set align(center)
      set text(size: 12pt, weight: "bold", style: "normal")
      block(
        below: 2pt,
        allcaps(it.body)
      )
      h(1em)
    } else if it.level == 2 { // Subsection Headings
      set align(left)
      set text(size: 12pt, weight: "regular", style: "italic")
      block(
        below: 2pt,
        wordcaps(it.body)
      )
      h(1em)
    } else if it.level == 3 { // Third-Level Headings
      v(6pt)
      text(size: 10pt, weight: "bold", style: "normal", wordcaps(it.body))
      h(0.5em)
    }
  ]

  // lists
  show list: set list(indent: 1em)

  // figures
  show figure: set figure(placement: auto)
  show figure.caption: it => {
    set par(first-line-indent: 0em)
    layout(size => context {
      align( // center for single-line, left for multi-line captions
        if measure(it).width < size.width { center } else { left },
        block(width: size.width, it)
      )
    })
  }

  // tables
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  // references
  set ref(supplement: it => {
    if it.func() == figure and it.kind == image {
      "Fig."
    } else if it.func() == math.equation {
      "Eq."
    } else {
      it.supplement
    }
  })



  // abstract
  if abstract != none [
    == Abstract
    #abstract
  ]

  // references
  show bibliography: set text(9pt)
  set bibliography(title: [References], style: "jacow.csl")
  show link: it => text(font: "DejaVu Sans Mono", size: 7.2pt, it)


  body


}

// numbered equations
#let eqnum(eq) = math.equation(block: true, numbering: "(1)", eq)
