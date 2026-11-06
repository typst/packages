///////////////////////////////////////////////////////////
/// body()
///
#let body(..style, it) = context {
  let spacing = style.at("spacing", default: false)
  let (leading, spacing) = if spacing == "single" {
    (.167em, .167em)
  } else if spacing == "double" {
    (1.33em, 1.33em)
  } else if type(spacing) == int {
    let multiple = spacing - 1
    if multiple < 0 {
      panic("`spacing` cannot be a multiple less than one")
    }
    (multiple * 1em, multiple * 1em)
  } else if type(spacing) == length {
    let size = text.size
    ((spacing - size) / size * 1em, (spacing - size) / size * 1em)
  } else if spacing == false {
    (par.leading, par.spacing)
  } else {
    panic("Invalid `spacing`: " + spacing)
  }

  let indent = style.at("first-line-indent", default: par.first-line-indent)
  if type(indent) == dictionary {
    indent = indent.amount
  }

  let justify = style.at("justify", default: par.justify)

  [
    #set par(leading: leading)
    #set par(spacing: spacing)
    #set par(justify: justify)
    #set par(first-line-indent: (amount: indent, all: true))
    #it
  ]
}

///////////////////////////////////////////////////////////
/// vanilla()
///
#let vanilla(
  margins: (left: 1in, right: 1in, top: 1in, bottom: 1in),
  styles: (:),
  doc,
) = {
  ///////////////////////////////////////////////////////////
  // Set defaults
  //
  styles.body = (
    (
      font: "Libertinus Serif",
      size: 12pt,
      first-line-indent: 0in,
      spacing: "single",
      justify: false,
      after: 0pt,
    )
      + styles.at("body", default: (:))
  )
  styles.heading = (
    (
      font: auto,
      size: auto,
      after: 1em,
    )
      + styles.at("heading", default: (:))
  )
  styles.footnote = (
    (
      font: auto,
      size: 10pt,
      spacing: "single",
      after: 0pt,
    )
      + styles.at("footnote", default: (:))
  )
  styles.list = (
    (
      font: auto,
      size: auto,
      spacing: "single",
      after: 0pt,
    )
      + styles.at("list", default: (:))
  )
  styles.enum = (
    (
      font: auto,
      size: auto,
      spacing: "single",
      after: 0pt,
    )
      + styles.at("enum", default: (:))
  )
  styles.quote = (
    (
      font: auto,
      size: auto,
      spacing: "single",
      padding: 1in,
      after: 0pt,
    )
      + styles.at("quote", default: (:))
  )


  ///////////////////////////////////////////////////////////
  // Normalize text

  if styles.heading.font == auto {
    styles.heading.font = styles.body.font
  }

  if styles.heading.size == auto {
    styles.heading.size = styles.body.size
  }

  if styles.footnote.font == auto {
    styles.footnote.font = styles.body.font
  }

  if styles.footnote.size == auto {
    styles.footnote.size = styles.body.size
  }

  if styles.list.font == auto {
    styles.list.font = styles.body.font
  }

  if styles.list.size == auto {
    styles.list.size = styles.body.size
  }

  if styles.quote.font == auto {
    styles.quote.font = styles.body.font
  }

  if styles.quote.size == auto {
    styles.quote.size = styles.body.size
  }

  set text(
    font: styles.body.font,
    size: styles.body.size,
    top-edge: 1em,
    bottom-edge: "baseline",
  )

  ///////////////////////////////////////////////////////////
  /// resolve-spacing
  ///
  let resolve-spacing = (spacing, size) => {
    if spacing == "single" {
      return (.167em, .167em)
    } else if spacing == "double" {
      return (1.33em, 1.33em)
    } else if type(spacing) == int {
      let multiple = spacing - 1
      if multiple < 0 {
        panic("`spacing` cannot be a multiple less than one")
      }
      return (multiple * 1em, multiple * 1em)
    } else if type(spacing) == length {
      return ((spacing - size) / size * 1em, (spacing - size) / size * 1em)
    } else {
      panic("Invalid `spacing`: " + spacing)
    }
  }

  ///////////////////////////////////////////////////////////
  // Paragraph spacing (single or double-spacing)

  let (body-leading, body-spacing) = resolve-spacing(styles.body.spacing, styles.body.size)

  set par(
    leading: body-leading,
    spacing: body-spacing,
    justify: styles.body.justify,
    first-line-indent: (amount: styles.body.first-line-indent, all: true),
  )

  ///////////////////////////////////////////////////////////
  // Bullet list (single-spacing, 0.5in padding)
  let (list-leading, list-spacing) = resolve-spacing(styles.list.spacing, styles.list.spacing)

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

    #set text(size: styles.heading.size, top-edge: 1em, bottom-edge: "baseline")

    #if counter(heading).get().len() == 1 {
      block(width: 100%, above: auto, below: styles.heading.after)[
        #set align(center)
        #set par(leading: .167em, justify: false, first-line-indent: 0em)
        #it.body
      ]
    } else {
      let indent = 0.5in * (counter(heading).get().len() - 1)
      block(inset: (left: indent), above: auto, below: styles.heading.after)[
        #set par(leading: .167em, justify: false, first-line-indent: 0em)
        #place(dx: -0.5in, counter(heading).display())
        #it.body
      ]
    }
  ]

  ///////////////////////////////////////////////////////////
  // Heading mumbering
  set heading(
    numbering: (..numbers) => {
      let level = numbers.pos().len() - 1
      let heading-numbering = (none, "I.", "A.", "1.", "a.", "(1)")
      return numbering(heading-numbering.at(level), numbers.pos().at(level))
    },
  )

  ///////////////////////////////////////////////////////////
  // Footnote
  set footnote.entry(gap: 1em)
  set footnote.entry(indent: 0em)
  show footnote.entry: it => {
    set par(leading: .15em, justify: true)
    set text(size: styles.footnote.size, top-edge: 1em, bottom-edge: 0em)
    h(1em)
    it.note
    h(0.5em)
    it.note.body
  }

  ///////////////////////////////////////////////////////////
  // Blockquote
  show quote: it => {
    set text(size: styles.quote.size, top-edge: 1em, bottom-edge: "baseline")
    set par(leading: .167em, justify: true)
    set block(above: 1.33em, below: 1.33em)
    pad(left: styles.quote.padding, right: styles.quote.padding, it.body)
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
    body(spacing: "single", justify: false, it)
  }

  ///////////////////////////////////////////////////////////
  // Figure

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

  set figure(supplement: none)
  show figure: it => {
    {
      set text(top-edge: "cap-height", bottom-edge: 0pt, size: styles.body.size)
      set par(leading: .6em, justify: false, spacing: body-spacing)
      shadow-box(inset: 1em, radius: 3pt, it.body)
    }
    set text(top-edge: "cap-height", bottom-edge: 0pt, size: styles.body.size)
    align(center, it.caption)
  }

  ///////////////////////////////////////////////////////////
  // Link
  show link: it => text(fill: navy, underline(it))

  doc
}
