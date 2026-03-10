#import "@preview/polylux:0.4.0": *
#import "@preview/polylux:0.4.0": slide as s
#import "@preview/ez-today:0.3.0"
#import "math-utils.typ": *

// Debugging
#let debug = false

// States for basic Data
#let title-state = state("title", [])
#let author-state = state("author", [])
#let date-state = state("date", [])

// Color-Schemes
#let fma = rgb(209, 63, 88)
#let fma-light = rgb(232, 159, 171)
#let fma-lighter = rgb(251, 240, 242)

// Base-Theme
#let ovgu-fma-theme(
  text-font: "Liberation Sans",
  text-lang: "de",
  text-size: 20pt,
  author: [],
  title: [],
  date: [],
  body,
) = {
  set text(
    font: text-font,
    lang: text-lang,
    size: text-size,
  )
  set par(
    justify: true,
  )
  set page(
    paper: "presentation-16-9",
    margin: 0cm,
    header: none,
    footer: none,
  )
  show footnote.entry: set text(size: .75em)
  context {
    title-state.update(title)
    author-state.update(author)
    date-state.update(date)
  }
  body
}

/// Slide for the title
#let title-slide(
  author: none,
  date: none,
  title: none,
  subtitle: none,
  max-width: 75%,
) = {
  let content = context {
    set align(center + horizon)
    if text.lang == "de" {
      image("Signet_FMA_de.svg")
    } else if text.lang == "en" {
      image("Signet_FMA_en.svg")
    } else {
      image("Signet_FMA.svg")
    }
    v(-1.5em)
    block(
      width: max-width,
    )[
      #rect(
        stroke: (top: fma + 4pt, bottom: fma + 4pt),
        inset: 1em,
        [
          #text(size: 2em)[#if title == none [*#title-state.get()*] else [#title]] \
          #text(size: 1.5em)[#subtitle]
        ],
      )
    ]
    [
      #if author == none {
        author-state.get()
      } else {
        author
      } \
      #if date == none {
        date-state.get()
      } else {
        date
      }
    ]
  }
  s(content)
}

/// Base for the rest of the slides
#let slide-base(
  heading: none,
  show-section: true,
  block-height: none,
  body,
) = {
  set page(
    margin: (top: 20%, bottom: 10%),
    header-ascent: 30%,
    header: context {
      let pic_size = 100%
      table(
        align: (left + top, center + horizon, right + horizon),
        columns: (1fr, 1fr, 1fr),
        inset: 0pt,
        rows: 1fr,
        stroke: (bottom: fma + 3pt, left: 0pt, right: 0pt, top: 0pt),
        //LEFT
        table.cell(
          inset: (bottom: 3pt),
        )[
          #context {
            if text.lang == "de" {
              // rect(inset: 0cm,image("Signet_FMA_de.svg", height: pic_size))
              image("Signet_FMA_de.svg", height: pic_size)
            } else if text.lang == "en" {
              image("Signet_FMA_en.svg", height: pic_size)
            } else {
              image("Signet_FMA.svg", height: pic_size)
            }
          }
        ],
        //CENTER
        block(
          width: 100%,
          height: 100%,
        )[
          #set align(center)
          #set text(size: 0.9em)
          *#title-state.get()*
        ],
        //RIGHT
        table.cell(
          inset: (right: 10pt),
        )[
          #text(size: 0.7em)[#author-state.get()]
        ],
      )
    },
    footer: context {
      set text(
        fill: white,
        size: 0.8em,
      )
      table(
        fill: fma,
        columns: (1fr, 2fr, 1fr),
        rows: 100%,
        stroke: fma + 2pt,
        align: (horizon + left, horizon + center, horizon + right),
        table.cell()[
          #date-state.get()
        ],
        table.cell()[
          #if show-section {
            toolbox.all-sections(
              (sections, current) => [*#current*],
            )
          }
        ],
        table.cell()[
          #toolbox.slide-number / #toolbox.last-slide-number
        ],
      )
    },
  )
  // Main-Content of the slide starts here
  let margin = 20pt
  let content = {
    set par(justify: true)
    // HEADING ON SLIDE
    if heading != none {
      pad(
        x: margin,
      )[
        #text(size: 1.5em)[*#heading*]
      ]
      pad(
        x: margin,
      )[
        #block(
          width: 100%,
          height: if block-height == none { 85% } else { block-height },
        )[
          #if debug {
            rect(
              width: 100%,
              height: 100%,
              inset: 0pt,
            )[#body]
          } else {
            body
          }
        ]
      ]
    } else {
      // NO HEADING ON SLIDE
      pad(
        x: margin,
      )[
        #block(
          width: 100%,
          height: if block-height == none { 100% } else { block-height },
        )[
          #if debug {
            rect(
              width: 100%,
              height: 100%,
              inset: 0pt,
            )[#body]
          } else {
            body
          }
        ]
      ]
    }
  }
  //SLIDE
  s(content)
}

/// Basic slide type for the main content
#let slide(
  heading: none,
  block-height: none,
  show-section: true,
  body,
) = {
  let content = body
  slide-base(
    show-section: show-section,
    block-height: block-height,
    heading: heading,
  )[#content]
}

/// Slide to show a outline
#let outline-slide(
  heading: none,
) = {
  let head = context {
    if text.lang == "de" {
      "Gliederung"
    } else if text.lang == "en" {
      "Outline"
    } else {
      "Outline"
    }
  }
  slide-base(
    heading: [#if heading == none [#head] else { heading }],
  )[
    #toolbox.all-sections((sections, current) => {
      enum(
        ..sections,
        tight: false,
        indent: 1em,
        body-indent: 1em,
        spacing: 1.5em,
      )
    })
  ]
}

/// Slide to show a outline point
#let header-slide(
  body,
) = {
  //Register heading in polylux environment
  toolbox.register-section(body)
  //Define the page-content
  let content = {
    set align(center + horizon)
    block(height: 90%)[
      #rect(
        stroke: (top: fma + 4pt, bottom: fma + 4pt),
        inset: 1em,
        heading(bookmarked: true)[#body],
      )
    ]
  }
  //Show slide
  slide-base(show-section: false, content)
}
