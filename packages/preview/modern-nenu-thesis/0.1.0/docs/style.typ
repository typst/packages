#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": codly, codly-init, no-codly
#import "@preview/codly-languages:0.1.1": *

// Color to highlight function names in
#let function-name-color = rgb("#4b69c6")
#let rainbow-map = ((rgb("#7cd5ff"), 0%), (rgb("#a6fbca"), 33%), (rgb("#fff37c"), 66%), (rgb("#ffa49d"), 100%))
#let gradient-for-color-types = gradient.linear(angle: 7deg, ..rainbow-map)
#let gradient-for-tiling = gradient.linear(angle: -45deg, rgb("#ffd2ec"), rgb("#c6feff")).sharp(2).repeat(5)

#let default-type-color = rgb("#eff0f3")

// Colors for Typst types
#let colors = (
  "default": default-type-color,
  "content": rgb("#a6ebe6"),
  "string": rgb("#d1ffe2"),
  "str": rgb("#d1ffe2"),
  "none": rgb("#ffcbc4"),
  "auto": rgb("#ffcbc4"),
  "bool": rgb("#ffedc1"),
  "boolean": rgb("#ffedc1"),
  "integer": rgb("#e7d9ff"),
  "int": rgb("#e7d9ff"),
  "float": rgb("#e7d9ff"),
  "ratio": rgb("#e7d9ff"),
  "length": rgb("#e7d9ff"),
  "angle": rgb("#e7d9ff"),
  "relative length": rgb("#e7d9ff"),
  "relative": rgb("#e7d9ff"),
  "fraction": rgb("#e7d9ff"),
  "symbol": rgb(219, 254, 227),
  "array": rgb(248, 224, 255),
  "dictionary": rgb(248, 224, 255),
  "arguments": rgb(248, 224, 255),
  "selector": rgb(200, 214, 233),
  "datetime": rgb(200, 214, 233),
  "module": rgb(210, 212, 250),
  "stroke": default-type-color,
  "function": rgb("#f9dfff"),
  "color": gradient-for-color-types,
  "gradient": gradient-for-color-types,
  "tiling": gradient-for-tiling,
  "signature-func-name": rgb("#4b69c6"),
)

// Clone of fauxreilly: https://typst.app/universe/package/fauxreilly
// There is a bug in it regarding the `pic` argument, see issue:
#let orly(
  font: "",
  color: blue,
  top-text: "",
  pic: "",
  title: "",
  title-align: left,
  subtitle: "",
  publisher: "",
  publisher-font: ("Latin Modern Roman Caps", "Apple Chancery"),
  signature: "",
  margin: (top: 0in),
) = {
  page(
    margin: margin,
    [
      /**************
       * VARIABLES
       ***************/

      // Layout
      #let top-bar-height = 0.33em          // how tall to make the colored bar at the top of the page

      // Title block
      #let title-text-color = white
      #let title-text-leading = 0.5em
      #let title-block-height = 12em

      // Subtitle
      #let subtitle-margin = 0.5em         // space between title block and subtitle text
      #let subtitle-text-size = 1.4em

      // "Publisher" / signature
      #let publisher-text-size = 2em
      #let signature-text-size = 0.9em

      // *********************************************************

      #set text(font: font) if font != ""

      #grid(
        rows: (
          top-bar-height,
          1em, // top text
          1fr, // pre-image spacing
          auto, // image
          .3fr, // spacing between image and title block
          title-block-height,
          subtitle-margin, // spacing between title and subtitle
          subtitle-text-size, // subtitle
          1fr, // spacing between subtitle and "publisher"
          publisher-text-size,
        ),
        rect(width: 100%, height: 100%, fill: color),
        // color bar at top
        align(center + bottom)[#emph[#top-text]],
        // top text
        [],
        // pre-image spacing
        image(pic, width: 100%, fit: "contain", height: 4cm),
        // image
        [],
        // spacing between image and title block
        block(width: 100%, height: title-block-height, inset: (x: 2em), fill: color)[    // title block
          #set text(fill: title-text-color, size: 3em)
          #set par(leading: title-text-leading)
          #set align(title-align + horizon)
          #title
        ],
        [],
        // spacing between title block and subtitle
        align(right)[
          #set text(size: subtitle-text-size)
          #emph[#subtitle]
        ],
        [],
        [
          #text(weight: "bold", size: publisher-text-size)[
            #if publisher == "" {
              [O RLY#text(fill: color)[#super[?]]]
            } else {
              emph(publisher)
            }
          ]
          #if signature != "" {
            box(width: 1fr, height: 100%)[
              #set align(right + bottom)
              #set text(size: signature-text-size)
              #emph[#signature]
            ]
          }
        ],
      )
    ],
  )
}


#let module(
  code,
  name: none,
  label-prefix: "",
  ..args,
) = {
  context {
    let module = tidy.parse-module(
      code,
      name: name,
      label-prefix: label-prefix,
    )
    tidy.show-module(
      module,
      first-heading-level: 3,
      colors: colors,
    )
    pagebreak(weak: true)
  }
}

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  font: "",
  color: blue,
  top-text: "",
  pic: "",
  title: "",
  title-align: left,
  subtitle: "",
  publisher: "",
  publisher-font: ("Latin Modern Roman Caps", "Apple Chancery"),
  signature: "",
  margin: (top: 0in),
  url: none,
  date: none,
  version: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: signature, title: title)
  set page(numbering: "1", number-align: center)
  set heading(numbering: (first, ..other) => {
    let len = other.pos().len()
    if len == 0 { return first }
  })
  show heading: it => {
    set block(below: 1.25em, above: 1.25em)
    it
  }
  show outline: it => {
    show heading: set align(center)
    it
  }
  show list: pad.with(x: 5%)

  // show link: set text(fill: purple.darken(30%))
  show link: it => {
    let dest = str(it.dest)
    if "." in dest and not "/" in dest { return underline(it, stroke: luma(60%), offset: 1pt) }
    set text(fill: rgb("#1e8f6f"))
    underline(it)
  }

  // Cover
  orly(
    font: font,
    color: color,
    top-text: top-text,
    pic: pic,
    title: title,
    title-align: title-align,
    subtitle: subtitle,
    publisher: publisher,
    publisher-font: publisher-font,
    signature: signature,
    margin: margin,
  )

  // Main body.
  set text(lang: "zh", font: ("Times New Roman", "Songti SC"))
  show raw: set text(font: ("Courier New", "Menlo", "Monaco Nerd Font"))
  show raw.where(block: true): set par(first-line-indent: 0pt)
  set par(justify: true)
  v(7em)

  pad(x: 10%, outline(depth: 2, indent: 2em))
  pagebreak()

  show: codly-init.with()
  codly(languages: codly-languages)
  body
}

#let ref-fn(name) = link(label(name), raw(name))

