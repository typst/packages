// Monod template
#let monod(
  // Metadata
  title: "TITLE",
  author: "AUTHOR",
  header: "HEADER",
  date: datetime.today(),

  // Language
  language: "en",

  // Paper size
  paper-size: "a4",

  // Font faces
  body-font: "Source Serif 4",
  heading-font: "Source Sans 3",
  raw-font: "Source Code Pro",

  // Font size
  font-size: 11pt,

  // Colors
  link-color: rgb("#3282B8"),
  muted-color: luma(160),
  block-bg-color: luma(240),

  // The main document body
  body,
) = {
  // Configure page size
  set page(
    paper: paper-size,
    margin: (top: 2.625cm),
  )

  // Set the document's metadata
  set document(title: title, author: author, date: date)

  // Set the fonts
  set text(
    font: body-font,
    size: font-size,
    ligatures: true,
    discretionary-ligatures: true,
    lang: language,
  )
  show raw: set text(font: raw-font)

  show heading: it => {
    // Add vertical space before headings
    if it.level == 1 {
      v(2.5em, weak: true)
    } else {
      v(2.2em, weak: true)
    }

    // Set headings font
    set text(font: heading-font, weight: "medium")
    it

    // Add vertical space after headings
    v(1.8em, weak: true)
  }

  // Set paragraph properties
  set par(
    leading: 0.95em,
    spacing: 1.7em,
    justify: true,
    justification-limits: (
      spacing: (
        min: 100% * 2 / 3,
        max: 100% * 3 / 2,
      ),
      tracking: (
        min: -0.01em,
        max: 0.01em,
      ),
    ),
  )

  // Set list styling
  set enum(indent: 1.5em, numbering: "1.a.i.")
  set list(indent: 1.5em)
  set terms(indent: 1.5em, hanging-indent: 1.33em)
  // Redefine term list item in order to redefine the term font
  show terms.item: it => par(
    hanging-indent: terms.indent + terms.hanging-indent,
    {
      h(terms.indent)
      text(font: heading-font, weight: "medium", it.term)
      h(1.1em)
      it.description
    },
  )

  // Display block code with padding and shaded background
  show raw.where(block: true): block.with(
    inset: (x: 1.5em, y: 5pt),
    outset: (x: -1em),
    width: 100%,
    fill: block-bg-color,
  )
  show raw.where(block: true): set par(justify: false)

  // Display inline code with shaded background while retaining the correct baseline
  show raw.where(block: false): box.with(
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    fill: block-bg-color,
  )

  // Set block quote styling
  show quote.where(block: true): set pad(x: 1.5em)

  // Set link styling
  show link: it => {
    set text(fill: link-color)
    it
  }

  // Set page header and footer (numbering)
  set page(
    header: context {
      if counter(page).get().first() > 1 [
        #set text(
          font: heading-font,
          weight: "medium",
          fill: muted-color,
          size: 0.9em,
        )
        #header
        #h(1fr)
        #title
      ] else [
        #set text(
          font: heading-font,
          weight: "medium",
          size: 0.9em,
        )
        #header
      ]
    },
    numbering: (..nums) => {
      set text(
        font: heading-font,
        weight: "medium",
        fill: muted-color,
        size: 0.9em,
      )
      nums.pos().first()
    },
  )

  // Set title block
  {
    v(26pt)
    text(
      font: heading-font,
      weight: "bold",
      size: 2em,
      title,
    )
    linebreak()
    v(16pt)
    if type(author) == array {
      text(font: body-font, style: "italic", author.join(", "))
    } else {
      text(font: body-font, style: "italic", author)
    }
    if date != none {
      v(2pt)
      text(
        font: body-font,
        date.display(
          "[month repr:long] [day padding:zero], [year repr:full]",
        ),
      )
    }
    v(5em)
  }

  // Main body
  { body }
}
