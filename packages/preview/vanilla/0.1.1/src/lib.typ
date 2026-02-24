#let par-single-spaced(..args, body) = {
  set par(leading: .15em, ..args)
  body
}

#let par-double-spaced(..args, body) = {
  set par(leading: 1.3em, ..args)
  body
}

///////////////////////////////////////////////////////////
#let vanilla(
  margins: (left: 1in, right: 1in, top: 1in, bottom: 1in),
  body-font-family: "Libertinus Serif",
  body-font-size: 12pt,
  body-line-spacing: "single",
  body-first-line-indent: 0in,
  footnote-font-size: 10pt,
  footnote-line-spacing: "single",
  list-line-spacing: "single",
  justified: false,
  doc,
) = {
  // let par-single-spaced(body, ..args) = {
  //   set par(leading: .15em, ..args)
  //   body
  // }

  // let par-double-spaced(body, ..args) = {
  //   set par(leading: 1.3em, ..args)
  //   body
  // }

  // Creates a box with a shadow effect
  // dx, dy: offset of the shadow (default: 3pt)
  let shadow-box(..args, content, fill: white, stroke: 1pt + black, dx: 3pt, dy: 3pt) = {
    box(
      layout(size => {
        let content = box(fill: fill, width: size.width, stroke: stroke, ..args, content)
        let (height,) = measure(content)
        let shadow = box(fill: silver, width: size.width, height: height, ..args)
        place(dx: dx, dy: dy, shadow)
        content
      }),
    )
  }

  ///////////////////////////////////////////////////////////
  // Set the page to one inch margins on all sides.
  set page(
    paper: "us-letter",
    margin: margins,
  )

  ///////////////////////////////////////////////////////////
  // Normalize text placement
  set text(
    font: body-font-family,
    size: body-font-size, // 1pt factor allows for setting font with an integer in a configuration file
    top-edge: 1em,
    bottom-edge: "baseline",
  )

  ///////////////////////////////////////////////////////////
  // Paragraph spacing (single or double-spacing)
  set par(
    leading: 1.3em,
    justify: true,
    first-line-indent: (amount: body-first-line-indent, all: true),
  )

  let body-leading = .15em
  if body-line-spacing == "double" {
    body-leading = 1.3em
  }
  set par(leading: body-leading, justify: justified)

  let list-leading = .15em
  if list-line-spacing == "double" {
    list-leading = 1.3em
  }

  ///////////////////////////////////////////////////////////
  // Bullet list (single-spacing, 0.5in padding)
  set list(body-indent: 1em)
  show list: it => {
    set par(leading: list-leading)
    block(inset: (left: 0.5in, right: 0.5in), it)
  }

  ///////////////////////////////////////////////////////////
  // Numbered list (single-spacing, 0.5in padding)
  set enum(body-indent: 1em, numbering: "(a)")
  show enum: it => {
    set par(leading: list-leading)
    pad(left: 0.5in, right: 0.5in, it)
  }

  ///////////////////////////////////////////////////////////
  // Heading styling
  show heading: it => [

    #set text(size: body-font-size, top-edge: 1em, bottom-edge: "baseline")

    #if counter(heading).get().len() == 1 {
      block(width: 100%, above: 1.3em, below: 1.3em)[
        #set align(center)
        #set par(leading: .15em, justify: false, first-line-indent: 0em)
        #it.body
      ]
    } else {
      let indent = 0.5in * (counter(heading).get().len() - 1)
      block(inset: (left: indent), above: 1.3em, below: 1.3em)[
        #set par(leading: .15em, justify: false, first-line-indent: 0em)
        #place(dx: -0.5in, counter(heading).display())
        #it.body
      ]
    }
  ]

  ///////////////////////////////////////////////////////////
  // Heading mumbering
  set heading(
    numbering: (..numbers) => {
      let level = numbers.pos().len()
      if (level == 1) {
        return none
      }
      if (level == 2) {
        return numbering("I.", numbers.pos().at(level - 1))
      } else if (level == 3) {
        return numbering("A.", numbers.pos().at(level - 1))
      } else if (level == 4) {
        return numbering("1.", numbers.pos().at(level - 1))
      } else if (level == 5) {
        return numbering("a.", numbers.pos().at(level - 1))
      } else {
        return numbering("(1)", numbers.pos().at(level - 1))
      }
    },
  )

  ///////////////////////////////////////////////////////////
  // Footnote
  set footnote.entry(gap: 1em)
  set footnote.entry(indent: 0em)
  show footnote.entry: it => {
    set par(leading: .15em, justify: true)
    set text(size: footnote-font-size, top-edge: 1em, bottom-edge: 0em)
    h(1em)
    it.note
    h(0.5em)
    it.note.body
  }

  ///////////////////////////////////////////////////////////
  // Blockquote
  show quote: it => {
    set text(size: 12pt, top-edge: 1em, bottom-edge: "baseline")
    set par(leading: .15em, justify: true)
    set block(above: 1.3em, below: 1.3em)
    pad(left: 1.0in, right: 1.0in, it.body)
  }

  ///////////////////////////////////////////////////////////
  // Table
  set table(
    inset: (top: .1em, left: .5em, right: .5em, bottom: .5em),
    fill: (x, y) => {
      if y == 0 { silver }
    },
  )
  show table.cell: it => {
    par-single-spaced(it)
  }

  ///////////////////////////////////////////////////////////
  // Figure
  set figure(supplement: none)
  show figure: it => {
    {
      set text(top-edge: "cap-height", bottom-edge: 0pt, size: 12pt)
      set par(leading: .6em, justify: false)
      shadow-box(inset: 1em, radius: 3pt, it.body)
    }
    set text(top-edge: "cap-height", bottom-edge: 0pt, size: 12pt)
    align(center, it.caption)
  }

  ///////////////////////////////////////////////////////////
  // Link
  show link: it => text(fill: navy, underline(it))

  doc
}
