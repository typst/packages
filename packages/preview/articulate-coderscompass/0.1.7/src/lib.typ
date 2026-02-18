#import "@preview/zebraw:0.5.5": zebraw, zebraw-init, zebraw-themes
#import "@preview/cmarker:0.1.6"
#import "@preview/mitex:0.2.5": mitex

// --------------------------------------------------------------
// Shared constants for the article template and helper functions
// --------------------------------------------------------------

#let cc-primary-yellow = "#f8d7b0"
#let cc-secondary-brown = "#392518"
#let cc-accent-blue = "#7bd4ff"
#let cc-lighter-blue = "#cceeff"
#let cc-accent-green = "#90ee90"
#let cc-light-grey = "#666666"
#let cc-divider-grey = "#dddddd"
#let cc-code-background = "#f8f9fa"
#let block-radius-value = 2pt


// ------------------------------------------------
// Main article template for Coders' Compass papers
// ------------------------------------------------

/// articulate-coderscompass provides the main structure and design for papers
/// published in by Coders' Compass.
/// -> content
#let articulate-coderscompass(
  /// The paper title
  title: [Paper Title],

  /// Optional subtitle for the paper.
  subtitle: none,

  /// List of authors.
  /// Each author is a tuple with name, email, and affiliation.
  authors: (
    (name: "Sample Author", email: "sample@coderscompass.org", affiliation: "Coders' Compass"),
  ),

  /// The abstract of the paper. It is recommended to keep it concise and informative.
  abstract: [
    "This is a sample abstract for the paper. It summarizes the key points and findings of the research conducted by the authors."
  ],

  /// Keywords for the paper included after the abstract.
  keywords: (
    "sample",
    "keywords",
    "for",
    "the",
    "paper",
  ),

  /// The version of the paper.
  version: "1.0.0",

  /// The date of the paper.
  date: datetime.today(),

  /// Reading time of the paper in minutes. Optional.
  reading-time: none,

  /// Watermark for the paper, if any. Optional.
  watermark: none,

  /// Website URL for the paper, if any. Optional.
  website-url: "https://coderscompass.org/articles/",

  /// Result of a call to the bibliography function, or none if no bibliography is provided.
  bibliography: none,

  /// Name of the publication or journal where the paper is published. Optional.
  publication: "Coders' Compass Texts",

  // Design configs that can be overriden.
  // These are optional and can be used to customise the appearance of the document.

  /// Do we use Coders' Compass brand fonts?
  /// If false, it uses the default available fonts in the Typst environment.
  /// For instructions on how to use the brand fonts, see the README.md file.
  use-brand-fonts: false,

  /// The main content of the paper.
  body
) = {
  // Basic properties of the document
  set document(
    author: authors.map(a => a.name),
    title: title,
    date: date,
    keywords: keywords,
    description: abstract,
  )

  // Definitions for design elements
  let regularFont = if use-brand-fonts {
    "Work Sans"
  } else {
    "Libertinus Serif"
  }
  let headingFont = if use-brand-fonts {
    "Ultra"
  } else {
    "Libertinus Serif"
  }
  let sourceCodeFont = if use-brand-fonts {
    "Source Code Pro"
  } else {
    "DejaVu Sans Mono"
  }

  // The regular header appears on all pages except the first.
  // It includes the publication name and the (truncated) title of the paper.
  let regular-header() ={
    let short-title = if title.len() > 40 {
      title.slice(0, 37) + "..."
    } else {
      title
    }

    grid(
      columns: (1fr, auto),
      align: (left, right),
      gutter: 1em,
      [
        #text(size: 0.8em, weight: "semibold", fill: rgb(cc-secondary-brown))[
          #publication
        ]
      ],
      [
        #text(size: 0.8em, style: "italic", fill: rgb(cc-secondary-brown))[
          #short-title
        ]
      ],
    )
    line(length: 100%, stroke: 0.5pt + rgb(cc-divider-grey))
  }

  // The first page header is an article metadata bar
  let article-metadata() = {
    rect(
        width: 100%,
        fill: rgb(cc-primary-yellow),
        stroke: rgb(cc-secondary-brown),
        inset: .6em,
        radius: block-radius-value
    )[
      #grid(
        columns: (1fr, auto),
        gutter: 1em,
        [
          #text(size: 0.9em, fill: rgb(cc-secondary-brown))[
            *Category:* Article
            #if reading-time != none [ • *Reading time:* #reading-time ]
          ]
        ],
        [
          #text(size: 0.9em, fill: rgb(cc-secondary-brown))[
            #date.display("[day] [month repr:long] [year]")
          ]
        ]
      )
    ]
  }

  // Combined header function that decides which header to use based on the page number
  let header() = {
    context if counter(page).get().first() > 1 [
      #regular-header()
    ] else [
      #article-metadata()
    ]
  }

  // Footer function that includes author names, page number, and optional watermark
  let footer() = {
    let author-text = if authors.len() > 0 {
      if authors.len() == 1 {
        authors.first().name
      } else if authors.len() == 2 {
        authors.first().name + " and " + authors.last().name
      } else {
        authors.first().name + " et al."
      }
    } else {
      ""
    }

    line(length: 100%, stroke: 0.5pt + rgb(cc-divider-grey))
    grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      gutter: 1em,
      [
        #text(size: 0.8em, fill: rgb(cc-light-grey))[
          #author-text
        ]
      ],
      [
        #context counter(page).get().first()
      ],
      [
        #text(size: 0.7em, fill: rgb(cc-light-grey), style: "italic")[
          #if watermark != none [
              #watermark
          ] else [
            #if version != none [
                *Version:* #version
            ]
          ]
        ]
      ]
    )
  }

  set page(
    margin: (x: 1.9cm, y: auto),
    header: header(),
    footer: footer(),
    paper: "a4",
  )

  // Main font for the document
  set text(font: regularFont, lang: "en")

  // Make links underlined to be visible
  show link: underline

  // Heading styles
  show heading: set text(
    font: headingFont,
  )

  set heading(
    numbering: "1.1.",
  )

  show heading: it => {
    set text(font: headingFont)
    it
    v(0.5em)
  }

  // ------------
  // Code styling
  // ------------
  // Inline code
  show raw.where(block: false): it => {
    text(font: sourceCodeFont, size: 0.9em)[#it]
  }

  // Code blocks use Zebraw for syntax highlighting
  show: zebraw-init.with(
    ..zebraw-themes.zebra-reverse,
    numbering-separator: true,
    lang: true,

  )
  show raw.where(block: true): it => {
    v(1.2em)
    zebraw(
      it
    )
  }

  // -------------------------------------
  // Main content of the paper starts here
  // -------------------------------------

  // Title block with Coders' Compass logo, title, and optional subtitle
  align(center)[
    #image("../assets/images/cc-icon.png", width: 1cm)
    // #v(1em)
    #block(
      text(
        font: headingFont,
        size: 24pt,
        title
      )
    )
  ]

  // Subtitle (if provided)
  if subtitle != none {
    v(0.5em)
    align(center)[
      #block(text(
        weight: "medium",
        size: 1.4em,
        fill: rgb(cc-light-grey),
        subtitle
      ))
    ]
  }

  // Author information.
  pad(
    top: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        #block(text(
          weight: "semibold",
          author.name
        ))
        #text(size: .8em, author.email) \
        #text(size: .8em, author.affiliation)
      ]),
    ),
  )

  // Abstract (if provided)
  if abstract != none {
    rect(
      width: 100%,
      fill: rgb(cc-lighter-blue),
      stroke: (left: 3pt + rgb(cc-accent-blue)),
      inset: 1.2em,
      radius: block-radius-value,
    )[
      #set par(justify: true)
      #heading(outlined: false, numbering: none, text(0.85em)[Abstract])
      #abstract
      // Keywords (if provided)
      #if keywords.len() > 0 {
        v(1em)
        text(size: 10pt, fill: rgb(cc-light-grey))[
          *Keywords:* #keywords.join(", ")
        ]
      }

      // The website URL
      #text(size: 0.9em, fill: rgb(cc-light-grey))[
        *Latest Version:* #link(website-url)[#website-url]
      ]
    ]
    v(0.5em)
  }


  // Content of the paper
  set par(justify: true)
  show: columns.with(2, gutter: 1.3em)

  body


  // Bibliography section if provided
  if bibliography != none {
    line(length: 100%, stroke: 0.5pt + rgb(cc-divider-grey))
    bibliography
  }
}

// -------------------------------
// Utility functions for the paper
// -------------------------------


/// callout function to create a styled note box.
/// It takes a title, an icon, a color, and the body content. Only
/// the body is required, the rest are optional.
/// -> content
#let callout(
  /// The title of the callout box. Optional.
  title: "Note",
  /// The icon to display in the callout box. Optional.
  icon: emoji.notepad,
  /// The color of the callout box. Optional, defaults to Coders' Compass accent blue.
  color: rgb(cc-accent-blue),
  /// The body content of the callout box. This is required.
  body
) = {
  rect(
    width: 100%,
    fill: color.lighten(95%),
    stroke: (left: 3pt + color),
    inset: 1em,
    radius: block-radius-value,
  )[
    #text(
      weight: "semibold",
      fill: color.darken(40%),
      size: 1.2em,
    )[
      #icon #h(0.3em) #title
    ]
    #v(0.2em)
    #body
  ]
}

/// cc-quote overrides the default quote rendering to add a custom style for
/// block quotes. Matches the styling used for callouts.
/// It takes the same parameters as the default quote function.
/// -> content
#let cc-quote(block: false, attribution: none, ..body) = {
  if not block {
    // Handle inline quotes normally
    return quote(block: block, attribution: attribution, ..body)
  }

  let colour = rgb(cc-accent-blue)
  let content = body.pos().join()

  return rect(
    width: 100%,
    fill: colour.lighten(95%),
    stroke: (left: 3pt + colour),
    inset: 1em,
    radius: block-radius-value,
  )[
    #content
  ]
}

/// render-markdown renders markdown content with support for
/// callout boxes using the quote function. It uses cmarker's
/// rendering capabilities with math support via mitex.
/// -> content
#let render-markdown(markdown-content) = {
  cmarker.render(
    markdown-content,
    math: mitex,
    scope: (
      quote: cc-quote
    )
  )
}
