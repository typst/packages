#import "CONFIG.typ": CONFIG, scaled, resized
#import "/RES/cover.b64.typ": cover
#import "/RES/chimg.b64.typ": chimg

// Top-level element settings
// --------------------------

#let ELEM = (
  page: (:),    // Page elements
  par: (:),     // Paragraph elements
  text: (:),    // Text elements
  block: (:),   // Block elements
)

// Page elements
// -------------

#let margins = (
  graphic: (x: 0.875in, y: 1.000in),
  normal: (x: 0.875in, y: 1.000in),
)

// blank page
#ELEM.page.insert("blank", (
  paper: CONFIG.paper,
  margin: margins.graphic,
  header: none,
  background: none,
  fill: none,
  numbering: none,
))

// half-title (book cover) page
#ELEM.page.insert("half-title", ELEM.page.blank + (
  background: image(cover, width: 100%),
))

// title page
#ELEM.page.insert("title", ELEM.page.blank + (
  background: image(chimg, width: 100%),
))

// blanket page
#ELEM.page.insert("blanket", ELEM.page.blank + (
  margin: margins.normal,
  fill: CONFIG.color.pages,
))

// roman page
#ELEM.page.insert("roman", ELEM.page.blanket + (
  numbering: "i",
))

// chapter heading page
#ELEM.page.insert("chapter", ELEM.page.blanket + (
  background: image(chimg, width: 100%),
  numbering: "1",
))

#import "@preview/hydra:0.6.2": hydra

// Normal page
#ELEM.page.insert("normal", ELEM.page.blanket + (
  header: context {
    set par(first-line-indent: 0pt)
    set text(
      size: resized(-1),
      weight: "bold"
    )
    stack(
      dir: ttb,
      if calc.odd(here().page()) {
        align(right, emph(hydra(1)))
      } else {
        align(left, emph(hydra(1)))
      },
      v(0.5em),
      line(
        length: 100%,
        stroke: 0.6pt + CONFIG.color.theme
      ),
    )
  },
  numbering: "1",
))

// Par elements
// ------------

// bare paragraph
#ELEM.par.insert("bare", (
  first-line-indent: (
    amount: 0pt,
    all: true,
  ),
  leading: 1em,
  spacing: 1.3em,
  justify: false,
))

// just paragraph
#ELEM.par.insert("just", ELEM.par.bare + (justify: true,))

// normal paragraph
#ELEM.par.insert("normal", ELEM.par.just + (
  first-line-indent: (
    amount: 0.4in,
    all: true,
  ),
))

// Text elements
// -------------

#ELEM.text.insert("lang", (
  lang: CONFIG.lang,
))

#ELEM.text.insert("foreign", (
  style: "italics",
)) // use #text(..ELEM.text.foreign + (lang: "xx"))[corpus]

#ELEM.text.insert("normal", ELEM.text.lang + (
  font: CONFIG.font.body,
  style: "normal",
  weight: "regular",
  stretch: 100%,
  size: CONFIG.size,
  fill: black,
  hyphenate: true,
))

#ELEM.text.insert("caption", ELEM.text.normal + (
  // smaller than normal by 1 short notch ÷(∜2) ~ ×(84%)
  size: resized(-1),
))

#ELEM.text.insert("footnote", (
  mark: ELEM.text.lang + (
    font: CONFIG.font.details,
  ),
  entry: ELEM.text.lang + (
    font: CONFIG.font.details,
    // smaller than normal by 1 short notch ÷(∜2) ~ ×(84%)
    size: resized(-1),
  ),
))

#ELEM.text.insert("raw", ELEM.text.lang + (
  font: CONFIG.font.mono,
  size: resized(-1),
  stretch: scaled(-1),
  weight: "medium",
))

#ELEM.text.insert("link", ELEM.text.lang + (
  font: CONFIG.font.mono,
  size: resized(-1),
  stretch: scaled(-1),
  fill: CONFIG.color.theme,
  weight: "bold",
))

#ELEM.text.insert("serif", ELEM.text.normal + (
  font: CONFIG.font.serif,
))

#ELEM.text.insert("sans", ELEM.text.normal + (
  font: CONFIG.font.sans,
))

#ELEM.text.insert("half-title", ELEM.text.serif + (
  // larger than normal by 6 notches ×(∜2⁶ ~ 283%)
  size: resized(+7),
  weight: "black",
  fill: CONFIG.color.cover.darken(40%),
  hyphenate: false,
))

#ELEM.text.insert("title", ELEM.text.half-title + (
  weight: "extrabold",
  fill: CONFIG.color.theme.darken(40%),
))

#ELEM.text.insert("heading", (
  // ELEM.text.heading.at(0) - displayed level 1
  ELEM.text.half-title + (
    size: resized(+6),
    fill: CONFIG.color.theme.darken(40%),
    hyphenate: false,
  ),
  // ELEM.text.heading.at(1)
  ELEM.text.serif + (
    // twice larger than normal
    size: resized(+4),
    fill: CONFIG.color.theme.darken(40%),
    weight: "black",
    hyphenate: false,
  ),
  // ELEM.text.heading.at(2)
  ELEM.text.serif + (
    // larger than normal by 1 short notch ×(∜2 ~ 119%)
    size: resized(+1),
    // Seldomly applying color theme
    fill: CONFIG.color.theme,
    weight: "black",
    hyphenate: false,
  ),
  // ELEM.text.heading.at(3)
  ELEM.text.sans + (
    // smaller than normal by 1 short notch ÷(∜2) ~ ×(84%)
    size: resized(-1),
    // Seldomly applying color theme
    fill: CONFIG.color.theme,
    weight: "black",
    hyphenate: false,
  ),
  // ELEM.text.heading.at(4)
  ELEM.text.sans + (
    // smaller than normal by 2 short notches ÷(∜2²) ~ ×(71%)
    size: resized(-2),
    // Seldomly applying color theme
    weight: "black",
    hyphenate: false,
  ),
  // Keep adding? Is it really needed?
))

// Block elements
// --------------

#ELEM.block.insert("half-title", (
  width: 85%,
))

#ELEM.block.insert("title", (
  width: 85%,
))

// New elements
// ============

// Exhibits
// --------

#ELEM.block.insert("exhibit", (
  width: 100%,
  inset: 8pt,
  radius: 8pt,
  fill: color.mix((CONFIG.color.theme, 33%), white),
  stroke: 0.6pt + black,
  breakable: true,
))

#let exh-count = counter("exhibit")

#let exhibit(
  body,
  caption: none,
) = {
  figure(
    block(..ELEM.block.exhibit)[#body],
    caption: caption,
    kind: "exhibit",
    supplement: "Exhibit",
    numbering: n => {
      let chp-count = counter(heading.where(level: 1)).at(here()).first()
      numbering("1" + CONFIG.num-sep.exh + "1", chp-count, n)
    },
  )
}

// Problems
// --------

#ELEM.block.insert("problem", (
  width: 92%,
  inset: 0pt,
  fill: none,
  stroke: none,
  breakable: true,
))

#let pro-count = counter("problem")

#let problem(body, id: "") = context [
  #figure([
    #set align(top)
    #stack(
      dir: ltr,
      block(width: 100% - ELEM.block.problem.width)[
        #let chp-count = counter(heading.where(level: 1)).at(here()).first()
        #let pro-count = counter("problem").get().at(0) + 1
        #set par(..ELEM.par.bare)
        #set text(..ELEM.text.serif)
        #text(weight: "black")[#chp-count#CONFIG.num-sep.pro#pro-count]
      ],
      block(..ELEM.block.problem)[
        #set par(..ELEM.par.just)
        #set text(..ELEM.text.serif)
        #body
      ],
    )],
    caption: none,
    kind: "problem",
    supplement: "Problem",
    numbering: n => {
      let chp-count = counter(heading.where(level: 1)).at(here()).first()
      numbering("1" + CONFIG.num-sep.pro + "1", chp-count, n)
    },
  ) #label(id)
]

#ELEM.text.insert("answer", ELEM.text.link + (
  size: resized(-2),
  stretch: scaled(-2),
  weight: "black",
))

#let answer(body) = {
  v(-0.50em)
  align(right)[
    #text(..ELEM.text.answer)[Answer: #body]
  ]
  v(+0.25em)
}
