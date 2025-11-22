
#let project(
  paper-code: "",
  title: "",
  abstract: [],
  authors: (),
  organizations: (),
  keywords: (),
  header: [],
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(
    paper: "us-letter",
    header: align(center, text(8pt, header)),
    footer: grid(
      columns: (1fr, 1fr),
      align(left)[
        #paper-code
      ],
      align(right)[
        Page
        #counter(page).display(
          "1 of 1",
          both: true,
        )
      ],
    ),
  )
  set text(font: "Times New Roman", lang: "en", size: 10pt)

  // Paper code
  align(center)[
    #block(text(paper-code))
    #v(1.3em, weak: true)
  ]

  // Title row.
  align(center)[
    #block(text(weight: 700, title))
    #v(1.3em, weak: true)
  ]

  // Authors
  align(center)[
    #authors.enumerate(start: 1).map(ia => [
      #let (index, author) = ia
      #let author_key = numbering("a", index)
      #set text(weight: "bold")
      #box[#author.name#super(author_key)#if author.at("corresponding", default: false) {
          sym.ast.basic
        }]]).join(", ")
    #v(1.3em, weak: true)
  ]

  // Author affiliations
  align(left)[
    #authors.enumerate(start: 1).map(ia => [
      #let (index, author) = ia
      #let author_key = numbering("a", index)
      #set text(style: "italic")
      #let org = organizations.find(o => o.name == author.affiliation)
      #super(author_key) #org.display#if author.email != none {
        [, #text(style: "normal",underline[#link("mailto:" + author.email)])]
      }
    ]).join(linebreak())
    #linebreak()
    #sym.ast.basic Corresponding Author
  ]
  v(1.3em, weak: true)

  // Abstract.
  align(center)[*Abstract*]
  {
    set par(justify: true, first-line-indent: 0.5cm)
    abstract
  }

  // Keywords.
  if keywords.len() > 6 {
    panic("Too many keywords. Please limit to 6.")
  } else if keywords.len() > 0 {
    [*Keywords:* #keywords.join(", ")]
  }

  v(1.3em, weak: true)

  // Main body.
  set heading(numbering: (..numbers) => if numbers.pos().len() <= 1 {
    numbers.pos().map(str).join(".") + "."
  } else {
    numbers.pos().map(str).join(".")
  })
  show heading.where(level: 1): it => {
    {
      set text(size: 10pt)
      set heading(numbering: "1.1.1")
      it
    }
    let a = par(box())
    a
    v(-0.45 * measure(2 * a).width)
  }
  show heading.where(level: 2): it => {
    {
      set text(size: 10pt, weight: "regular", style: "italic")
      it
    }
    let a = par(box())
    a
    v(-0.45 * measure(2 * a).width)
  }
  show heading.where(level: 3): it => {
    {
      set text(size: 10pt, weight: "regular", style: "italic")
      it
    }
    let a = par(box())
    a
    v(-0.45 * measure(2 * a).width)
  }

  // Figure show rule
  show figure.where(kind: image): set figure(supplement: [Fig.])
  show figure.where(kind: image): it => align(center)[
    #v(0.65em)
    #block(below: 0.65em)[#it.body]
    #it.supplement #it.counter.display(it.numbering). #it.caption.body
    #v(0.65em)
  ]

  // Table show rule
  show figure.where(kind: table): it => align(center)[
    #v(0.65em)
    #it.supplement #it.counter.display(it.numbering). #it.caption.body
    #block(above: 0.65em)[#it.body]
    #v(0.65em)
  ]

  set table(stroke: (x, y) => (
    left: 0pt,
    right: 0pt,
    top: if y < 1 {
      1.5pt
    } else if y < 2 {
      0.5pt
    } else {
      0pt
    },
    bottom: 1.5pt,
  ))

  show par: set block(spacing: 0.65em)
  set par(justify: true, first-line-indent: 0.5cm)
  show: columns.with(2, gutter: 1.3em)
  set math.equation(numbering: "(1)")

  body
}
