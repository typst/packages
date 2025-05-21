#let vibrant-color = (
  title: none, // title of the document
  date: none, // date of the document, type: datetime
  authors: (), // array of authors
  sub-authors: "4A ICY", // optional text above authors, e.g. group 2, 4A ICY
  subject: none, // subject of the document or text at the bottom
  description: none, // document description
  bib-yaml: none, // reference to a bibliography
  lang: "fr", // document language
  heading-numbering: false, // enable heading numbering
  theme: "blue-theme", // theme: pastel-theme, blue-theme, green-theme, red-theme
  image-cover: none, // cover image for the report, optional
  logo: none, // logo image for the report, optional
  doc,
) => {
  /* -------------------------------------------
  *  General
  *  ------------------------------------------- */
  // add numbering to titles if asked
  if heading-numbering {
    set heading(numbering: "I.A.1.")
  }

  // Theme color
  let theme-color = if theme == "blue-theme" {
    "#3AA5D8"
  } else if theme == "pastel-theme" {
    "#AB8EFF"
  } else if theme == "green-theme" {
    "#49B949"
  } else if theme == "red-theme" {
    "#F61359"
  } else {
    "#3AA5D8"
  }

  let format-date(date) = {
    /* formats date with French months (since not yet natively supported in typst) */
    let months = ("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "aout", "septembre", "octobre", "novembre", "décembre")
    date.display("[day] ") + months.at(date.month() - 1) + date.display(" [year]")
  }

  // Set date to today if not provided
  if date == none {
    date = datetime.today()
  }

  let date_fmt = date.display("[month]/[day]/[year]")

  if (lang == "fr") {
    date_fmt = format-date(date)
  } 

  // Metadata
  set document(author: authors, date: date, title: title)
  // Required fonts
  let heading-fonts = ("Stretch Pro", "Liberation Sans")
  let normal-fonts = ("Metropolis", "Liberation Sans")
  // Page
  set page("a4", margin: 0cm)
  // Text
  set text(lang: lang, font: normal-fonts)

  /* -------------------------------------------
  *  Cover page
  *  ------------------------------------------- */
  // Only for the title & description
  set par(leading: 0.25em)

  // Cover image
  place(image("assets/" + theme + "/" + theme + "-cover.png", width: 100%))

  if image-cover != none {
    place(
      dx: 5cm,
      dy: 11.88cm,
      box(
        height: 8.78cm,
        width: 13cm,
        align(
          center,
          box(fill: rgb(255, 255, 255, 120), image(image-cover, height: 100%)),
        ),
      ),
    )
  }

  // logo
  if logo != none {
       place(
    dx: 1.91cm,
    dy: 1.90cm,
    image(logo, width: 33%),
  )
  }
 

  set par(justify: false)

  // Title & Description
  place(
    dx: 2.30cm,
    dy: 4.55cm,
    stack(
      spacing: 0.6cm,
      // Title
      block(
        width: 16.581cm,
        text(
          font: heading-fonts,
          size: 38pt,
          hyphenate: false,
          fill: white,
          upper(title),
        ),
      ),
      // Description
      block(
        width: 16.581cm,
        par(
          justify: true,
          text(
            size: 11pt,
            fill: white,
            hyphenate: false,
            weight: "regular",
            description,
          ),
        ),
      ),
    ),
  )

  // Function to bold the first word, used for authors
  let first-bold = text => {
    let words = text.split(" ")
    upper(strong(words.first()) + " " + words.at(1))
  }

  // Reset leading to 0.75em
  set par(leading: 0.75em)

  // Authors
  place(
    dx: 3.95cm,
    dy: 20.9cm,
    box(
      height: 4.2cm,
      text(
        size: 14pt,
        fill: white,
        align(
          horizon,
          if sub-authors != none { strong(sub-authors + "\n") } else { }
            + authors.map(auteur => first-bold(auteur)).join("\n"),
        ),
      ),
    ),
  )

  // Date
  place(
    dx: 13.51cm,
    dy: 2.22cm,
    box(
      height: 1.39cm,
      width: 6.28cm,
      text(
        size: 15pt,
        fill: rgb(theme-color),
        font: normal-fonts,
        weight: "bold",
        align(
          center + horizon,
          upper(date_fmt),
        ),
      ),
    ),
  )

  // Subject
  place(
    dx: 2.24cm,
    dy: 25.95cm,
    box(
      height: 1cm,
      width: 10cm,
      // fill: red,
      align(
        horizon,
        text(
          size: 15pt,
          fill: rgb(theme-color),
          font: normal-fonts,
          weight: "bold",
          upper(subject),
        ),
      ),
    ),
  )

  /* -------------------------------------------
  *  Table of contents
  *  ------------------------------------------- */

  pagebreak()

  // Margin for the content of the table of contents
  set page(
    margin: (
      top: 6.14cm,
      bottom: 1cm,
      left: 3.14cm,
      right: 1.12cm,
    ),
    // Background
    background: place(
      dx: 0cm,
      dy: 0cm,
      image("assets/" + theme + "/" + theme + "-summary.png"),
    ),
  )

  // Header "SOMMAIRE" at the top
  set page(
    header: context [
      #place(
        dy: 2cm,
        text(
          size: 48pt,
          fill: white,
          font: heading-fonts,
          weight: "bold",
          if lang == "fr" [SOMMAIRE] else [SUMMARY],
        ),
      )
    ],
  )

  // Table of contents text
  set text(size: 12pt, fill: black, weight: "medium")

  set outline.entry(
    fill: line(
      start: (10pt, 0%),
      end: (100% - 10pt, 0%),
      stroke: 1pt + rgb(theme-color),
    ),
  )

  // Table of contents content
  outline(
    title: none,
    depth: 3,
    indent: 0.75cm,
  )

  pagebreak()

  /* -------------------------------------------
  *  Report body
  *  ------------------------------------------- */

  // Remove the table of contents header
  set page(header: context [])

  set par(justify: false)

  // Heading 1
  show heading.where(level: 1): it => [
    #set par(justify: false)
    #set par(leading: 0.25em)
    #block(
      below: 1em,
      stack(
        spacing: 0.3cm,
        text(
          hyphenate: false,
          size: 32pt,
          font: heading-fonts,
          weight: "bold",
          upper(it.body),
        ),
        rect(
          width: 30%,
          height: 10pt,
          fill: rgb(theme-color),
        ),
      ),
    )
  ]

  // Heading 2
  show heading.where(level: 2): it => [
    #set par(leading: 0.5em)
    #block(
      below: 1.7em,
      text(
        size: 24pt,
        font: normal-fonts,
        weight: "bold",
        underline(
          evade: false,
          background: true,
          stroke: 6pt + rgb(theme-color),
          it.body,
        ),
      ),
    )
  ]

  // Heading 3
  show heading.where(level: 3): it => [
    #block(
      below: 1em,
      text(
        size: 16pt,
        font: normal-fonts,
        weight: "bold",
        upper(it.body),
      ),
    )
  ]

  // Heading 4
  show heading.where(level: 4): it => [
    #block(
      below: 1.3em,
      text(
        size: 12pt,
        font: normal-fonts,
        fill: rgb(theme-color),
        weight: "medium",
        it.body,
      ),
    )
  ]

  // Page margins for writing
  set page(
    margin: (
      top: 1cm,
      bottom: 1cm,
      left: 2.2cm,
      right: 1.12cm,
    ),
    // Side bar
    background: place(
      dx: 0cm,
      dy: 0cm,
      image("assets/" + theme + "/" + theme + "-side.png"),
    ),
  )

  // Returns the author if there is only one, returns sub-authors otherwise
  let headerauthor() = context [
    #if authors.len() > 1 {
      text(strong(sub-authors), size: 12pt, fill: white)
    } else {
      text(first-bold(authors.first()), size: 12pt, fill: white)
    }
  ]

  // Displays the side-bar (placed in the "footer" element)
  set page(
    footer: context [
      // Title
      #rotate(-90deg)[#place(
          center,
          dy: -1.8cm,
          dx: 14cm,
          strong(upper(text(fill: white, subject + " : ")))
            + upper(text(fill: white, title)),
        )
      ]
      // Author/sub-authors
      #rotate(-90deg)[#place(
          right,
          dy: -1.8cm,
          dx: 28.9cm,
          headerauthor(),
        )]
      // Page number
      #place(
        dx: -1.8cm,
        dy: -0.7cm,
        text(
          fill: white,
          weight: "semibold",
          size: 12pt,
          counter(page).display("1"),
        ),
      )
    ],
  )

  /* -------------------------------------------
  *  Style for the document
  *  ------------------------------------------- */

  // Style for normal text
  set text(size: 11pt, weight: "regular")
  set par(justify: true)

  // Superscript and subscript (e.g. 'er' in '1er')
  set super(size: 0.7em)
  set sub(size: 0.7em)

  // Delimiter
  set line(stroke: rgb(theme-color))

  // Style for footnotes
  set footnote.entry(
    separator: line(length: 40%, stroke: 2pt + rgb(theme-color)),
  )

  // Custom quotes
  show quote: it => {
    align(
      center,
      rect(
        width: 100%,
        outset: (x: 1.12cm),
        fill: rgb(theme-color + "33"),
        inset: (x: 2cm, y: 0.5cm),
        stack(
          text(it.body),
          if it.attribution != none {
            box(width: 80%, align(right, emph(text("\n —  " + it.attribution))))
          },
        ),
      ),
    )
  }

  // Custom caption for images only
  show figure.where(kind: image): it => layout(sz => {
    let size = measure(it.body, width: sz.width).width
    set text(fill: white)

    stack(
      it.body,
      rect(
        fill: rgb(theme-color),
        width: size,
        it.caption.supplement.text
        + " "
        + it.caption.counter.display()
        + " - "
        + it.caption.body,
      ),
    )
  })

  show table: set align(left)

  // Table
  set table(
    stroke: (x, y) => if y > 0 {
      (
        top: (paint: rgb("aaaaaa"), thickness: 1pt),
      )
    } else {
      none
    },
  )

  // Table cells
  set table.cell(inset: (x: 1em, y: 0.5em))

  // Manually added horizontal lines
  set table.hline(stroke: 2pt + rgb(theme-color))

  // Manually added vertical lines
  set table.vline(stroke: 2pt + rgb(theme-color))

  // Links
  show link: it => {
    set text(
      fill: rgb(theme-color),
      weight: "medium",
    )
    underline(it)
  }

  // Highlight
  set highlight(fill: rgb(theme-color + "77"))

  show raw.where(block: false): {
    box.with(
      fill: rgb("202628"),
      inset: (x: 3pt),
      outset: (y: 4pt),
      radius: 2pt,
    )
  }

  // Inline code blocks
  show raw.where(block: false): set text(fill: white)

  /* -------------------------------------------
  *  Document
  *  ------------------------------------------- */

  doc

  /* -------------------------------------------
  *  Bibliography (if it exists)
  *  ------------------------------------------- */

  set bibliography(full: true)

  if bib-yaml != none {
    pagebreak()
    bibliography(bib-yaml)
  }

  /* -------------------------------------------
  *  End page
  *  ------------------------------------------- */

  pagebreak()

  set page(margin: 0cm, background: none)

  // Image
  place(right, image("assets/" + theme + "/" + theme + "-back.png"))

  set par(justify: true)
  set text(hyphenate: true)

  // Logo
  if logo != none { 
    place(
      left + bottom,
    dx: 10.51cm,
    dy: -1.5cm,
    image(logo, width: 45%),
  )
  }
  

  // Title & Description
  place(
    dx: 11.01cm,
    dy: 2.15cm,
    stack(
      spacing: 0.6cm,
      // Title
      block(
        width: 9.45cm,
        text(font: heading-fonts, size: 32pt, fill: white, upper(title)),
      ),
      // Description
      block(
        width: 9.45cm,
        text(
          size: 11pt,
          fill: white,
          font: normal-fonts,
          weight: "regular",
          description,
        ),
      ),
    ),
  )

  // Authors
  place(
    dx: -10.8cm,
    dy: 24.765cm,
    right,
    box(
      text(
        size: 14pt,
        fill: rgb(theme-color),
        font: normal-fonts,
        authors.map(auteur => first-bold(auteur)).join("\n"),
      ),
    ),
  )

  // Date
  place(
    right,
    dx: -10.8cm,
    dy: 22.37cm,
    box(
      text(
        size: 15pt,
        fill: rgb(theme-color),
        font: normal-fonts,
        weight: "bold",
        upper(date_fmt),
      ),
    ),
  )
}

#let codeblock(filename: "", line_number: true, content) = {
  set text(fill: white)

  let term = ((content.lang == "bash" or content.lang == "term") and filename == "")

  show raw.line: line => {
    if (line_number and not term) {
      text(fill: rgb("ffffff55"))[#line.number]
      h(2em)
    }
    line.body
  }

  align(
    center,
    // White text for contrast
    rect(
      width: 100%,
      outset: (x: 1.12cm),
      fill: rgb("202628"),
      inset: (x: 0cm, y: 0.7em), // Adds a bit of inner margin,
      stack(
        spacing: 0.7em,
        // Disable the bar to display terminal output
        if not (term) { 
          [#text(font: "DejaVu Sans Mono", size: 9pt, filename) #h(1fr) #text(
            font: "DejaVu Sans Mono",
            size: 9pt,
            content.lang,
          )]
          line(
            length: 100% + (2 * 1.12cm),
            stroke: 1pt + rgb("444444"),
          )
        },
        align(left, content),
      ),
    ),
  )
}

#let warning(content) = {
  box(
    stroke: (left: 7pt + rgb("F61359")),
    inset: (y: 1em, x: 1.3em),
    grid(
      columns: (0.5em, 95%),
      gutter: 2.7em,
      image("assets/warning.png", width: 0.8cm), align(horizon, text(content)),
    ),
  )
}

#let info(content) = {
  box(
    stroke: (left: 7pt + rgb("FFC13D")),
    inset: (y: 0.5em, x: 1.3em),
    grid(
      columns: (0.2em, 95%),
      gutter: 3em,
      image("assets/info.png", width: 0.8cm), align(horizon, text(content)),
    ),
  )
}

#let comment(theme: "blue-theme", content) = {
  box(
    stroke: (left: 7pt + rgb("999999")),
    inset: (y: 0.5em, x: 1.3em),
    grid(
      columns: (1em, 95%),
      gutter: 2.3em,
      image("assets/comment.png", width: 0.8cm), align(horizon, text(content)),
    ),
  )
}
