//***************************************************************
// AIAA TYPST TEMPLATE
// 
// The author of this work hereby waives all claim of copyright
// (economic and moral) in this work and immediately places it 
// in the public domain; it may be used, distorted or 
// in any manner whatsoever without further attribution or notice
// to the creator. The author is not responsible for any liability 
// from the usage or dissemination of this code.
//
// Author: Isaac Weintraub, Alexander Von Moll
// Date: 03 DEC 2024
// BAMDONE!
//***************************************************************

// This function gets your whole document as its `body` and formats
// it as an article in the style of the AIAA.

#let aiaa(
  // The paper's title.
  title: (),

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors-and-affiliations: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography: none,

  // The paper's content.
  body,
) = {
  // Set document metdata.
  set document(
    title: title, 
    author: authors-and-affiliations.filter(a => "name" in a).map(a => a.name)
  )

  // Set the body font.
  set text(
    font: "Times New Roman",
    top-edge: 5pt,
  )


  // Configure the page.
  set page(
    paper: paper-size,

    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      ( 
        x: (72pt / 216mm) * 100%,
        top: (72pt / 279mm) * 100%,
        bottom: (72pt / 279mm) * 100%,
      )
    }
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)", supplement: [Eq.])
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      link(
        el.label,
        [#el.supplement #numbering(
          el.numbering,
          ..counter(eq).at(el.location())
        )]
      )
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  
  // Configure headings.
  set heading(
    numbering: "I.A.1."
    )
  show heading: it => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).get()
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }
 
    set text(11pt, weight: "bold", font: "Times New Roman")
    
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
      #v(1.65em, weak: true)
      #set align(center)
      #set text(size: 11pt, weight: "bold", font: "Times New Roman")
      // #show: smallcaps
      
      // #v(20pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering("I.", deepest)
        // h(7pt, weak: true)
      }
      #it.body
      #v(0.65em, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #v(1.65em, weak: true)
      #set par(first-line-indent: 0pt)
      // #v(16pt, weak: true)
      #set text(weight: "bold", size: 10pt)
      // #v(11pt, weak: true)
      #if it.numbering != none {
        numbering("A.", deepest)
        h(7pt, weak: true)
      }
      #it.body

    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering( "1)" , deepest)
        [ ]
      }
      _#(it.body):_
    ]
  }

  // Display the paper's title.
  v(3pt, weak: true)
  align(center, text(weight: "bold", 24pt, font: "Times New Roman", title))
  v(8.35mm, weak: true)

  // Display the authors and affiliations list.
  {
    set align(center)
    for author-or-affil in authors-and-affiliations {
      // entry is an author
      if "name" in author-or-affil {
        set text(16pt, top-edge:16pt)
        let author-footer = {
          if "job" in author-or-affil [#author-or-affil.job]
          if "department" in author-or-affil [, #author-or-affil.department]
          if "aiaa" in author-or-affil [, #author-or-affil.aiaa]
          [.]
        }
        [#author-or-affil.name #footnote[#author-footer] ]
      // the entry is an affiliation
      } else {  
          set text(12pt, top-edge: 10pt, style:"italic")
          [\ #author-or-affil.institution]
          if "city" in author-or-affil [, #author-or-affil.city]
          if "state" in author-or-affil [, #author-or-affil.state]
          if "zip" in author-or-affil [, #author-or-affil.zip]
          if "country" in author-or-affil [, #author-or-affil.country]
          [\ ]
      }
    }
  }
  
  // Configure Figures
  show figure.caption: strong
  set figure.caption(separator:"   ")
  set figure(numbering: "1", supplement: [Fig.])

  // Configure Tables
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(supplement: [Table])

  // Configure paragraph properties.
  show: columns.with(1, gutter: 0pt)
  set par(justify: true, first-line-indent: 1.5em, spacing: 0.65em)

  // Display abstract and index terms.
  if abstract != none [
    #text(10pt, weight: "bold",
      table(
        stroke: none,
        align: left,
        gutter: 0pt,
        columns: (36pt, auto, 36pt),
        [],[ #h(1.5em) #abstract], []
      )
    )
  ]

  // Display the paper's contents.
  body

  // Display bibliography.

  // Style bibliography.
  show std.bibliography: set text(9pt)
  // show std.bibliography: set block(spacing: 0.5em)
  set std.bibliography(title: text(10pt)[References], style: "american-institute-of-aeronautics-and-astronautics")

  bibliography

  // if bibliography-file != none {
  //   show bibliography: set text(9pt)
  //   bibliography(bibliography-file, title: text(10pt)[References], style: "american-institute-of-aeronautics-and-astronautics")
  // }
}

#let bEquation = it => { 
    [#set math.equation(numbering: "(1)", supplement: "Equation")
      #show math.equation: set block(spacing: 0.65em)
      // Configure appearance of equation references
      #show ref: it => {
        let eq = math.equation
        let el = it.element
        if el != none and el.func() == eq {
          // Override equation references.
          link(
            el.label,
            [Equation #numbering(
            el.numbering,
            ..counter(eq).at(el.location())
          )]
        )
      } else {
      // Other references as usual.
      it
    }
  }
#it ]
}

#let nomenclature(..quantities) = {
  let q = quantities.pos()
  [= Nomenclature

  #table(
    stroke: none,
    row-gutter: -3pt,
    columns: (auto, auto, auto),
    align: left,
    ..q.map(
      ((k,v)) => ([#k], [$=$], v)
    ).flatten()
  )
  ] 
}


// DROPCAP TOOL

// Element function for space.
#let space = [ ].func()

// Elements that can be split and have a 'body' field.
#let splittable = (strong, emph, underline, stroke, overline, highlight)

// Sets the font size so the resulting text height matches the given height.
//
// If not specified otherwise in "text-args", the top and bottom edge of the
// resulting text element will be set to "bounds".
//
// Parameters:
// - height: The target height of the resulting text.
// - threshold: The maximum difference between target and actual height.
// - text-args: Arguments to be passed to the underlying text element.
// - body: The content of the text element.
//
// Returns: The text with the set font size.
#let sized(height, ..text-args, threshold: 0.1pt, body) = style(styles => {
  let text = text.with(
    top-edge: "bounds",
    bottom-edge: "bounds",
    ..text-args.named(),
    body
  )

  let size = height
  let font-height = measure(text(size: size), styles).height

  // This should only take one iteration, but just in case...
  while calc.abs(font-height - height) > threshold {
    size *= 1 + (height - font-height) / font-height
    font-height = measure(text(size: size), styles).height
  }
  
  return text(size: size)
})

// Attaches a label after the split elements.
//
// The label is only attached to one of the elements, preferring the second
// one. If both elements are empty, the label is discarded. If the label is
// empty, the elements remain unchanged.
#let attach-label((first, second), label) = {
  if label == none {
    (first, second)
  } else if second != none {
    (first, [#second#label])
  } else if first != none {
    ([#first#label], second)
  } else {
    (none, none)
  }
}

// Tries to extract the first letter of the given content.
//
// If the first letter cannot be extracted, the whole body is returned as rest.
//
// Returns: A tuple of the first letter and the rest.
#let extract-first-letter(body) = {
  if type(body) == str {
    let letter = body.clusters().at(0, default: none)
    if letter == none {
      return (none, body)
    }
    let rest = body.clusters().slice(1).join()
    return (letter, rest)
  }

  if body.has("text") {
    let (text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (letter, rest) = extract-first-letter(body.text)
    return attach-label((letter, func(rest)), label)
  }

  if body.func() in splittable {
    let (body: text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (letter, rest) = extract-first-letter(text)
    return attach-label((letter, func(rest)), label)
  }

  if body.has("child") {
    // We cannot create a 'styled' element, so set/show rules are lost.
    let (letter, rest) = extract-first-letter(body.child)
    return (letter, rest)
  }

  if body.has("children") {
    let child-pos = body.children.position(c => {
      c.func() not in (space, parbreak)
    })

    if child-pos == none {
      return (none, body)
    }

    let child = body.children.at(child-pos)
    let (letter, rest) = extract-first-letter(child)
    if body.children.len() > child-pos {
      rest = (rest, ..body.children.slice(child-pos+1)).join()
    }
    return (letter, rest)
  }
}

// Gets the number of words in the given content.
#let size(body) = {
  if type(body) == str {
    body.split(" ").len()
  } else if body.has("text") {
    size(body.text)
  } else if body.has("child") {
    size(body.child)
  } else if body.has("children") {
    body.children.map(size).sum()
  } else if body.func() in splittable {
    size(body.body)
  } else {
    1
  }
}

// Tries to split the given content at a given index.
//
// Content is split at word boundaries. A sequence can be split at any of its
// childrens' word boundaries.
//
// Returns: A tuple of the first and second part.
#let split(body, index) = {
  if type(body) == str {
    let words = body.split(" ")
    if index >= words.len() {
      return (body, none)
    }
    let first = words.slice(0, index).join(" ")
    let second = words.slice(index).join(" ")
    return (first, second)
  }

  if body.has("text") {
    let (text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second) = split(text, index)
    return attach-label((func(first), func(second)), label)
  }

  if body.func() in splittable {
    let (body: text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second) = split(text, index)
    return attach-label((func(first), func(second)), label)
  }

  if body.has("child") {
    // We cannot create a 'styled' element, so set/show rules are lost.
    let (first, second) = split(body.child, index)
    return (first, second)
  }

  if body.has("children") {
    let first = ()
    let second = ()

    // Find child containing the splitting point and split it.
    for (i, child) in body.children.enumerate() {
      let child-size = size(child)
      index -= child-size
      
      if index <= 0 {
        // Current child contains splitting point.
        let sub-index = child-size + index
        let (child-first, child-second) = split(child, sub-index)
        first.push(child-first)
        second.push(child-second)
        second += body.children.slice(i + 1) // Add remaining children
        break
      } else {
        first.push(child)
      }
    }

    return (first.join[], second.join[])
  }

  // Element cannot be split, so put everything in second part.
  return (none, body)
}

