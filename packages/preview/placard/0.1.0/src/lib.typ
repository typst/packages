
// Internal states for global access
#let _placard-colors = state("placard-colors", (:))
#let _placard-sizes = state("placard-sizes", (:))
#let _placard-fonts = state("placard-fonts", (:))
#let _placard-styles = state("placard-styles", (:))

// ------------------------------------------
// THEMES
// 
#let _default-themes = (
  light: (
    paper-fill: rgb("#fdfbf8"), 
    card-fill: rgb("#ffffff"),  
    card-border: rgb("#aba6a6"),
    title: rgb("#1a1a1a"),      
    heading: rgb("#1a1a1a"),
    text: rgb("#1a1a1a"),
    accent: rgb("#1a1a1a"),
    footer-text: rgb("#535755"),
  ),
  dark: (
    paper-fill: rgb("#1a1a1a"), 
    card-fill: rgb("#141414"),  
    card-border: rgb("#3f3f3f"),
    title: rgb("#ffffff"),      
    heading: rgb("#ffffff"),
    text: rgb("#ffffff"),
    accent: rgb("#fffdfe"),
    footer-text: rgb("#808080"),
  )
)

// ------------------------------------------
// SIZES
// 
#let _default-sizes = (
  title: 65pt,
  authors: 22pt,
  body: 20pt,
  h1: 35pt,
  h2: 29pt,
  card: 20pt,
  footer: 24pt,
)

// ------------------------------------------
// FONTS
// 
#let _default-fonts = (
  title: "Libertinus Serif",
  authors: "Libertinus Serif",
  body: "Libertinus Serif",
  headings: "Libertinus Serif",
  card: "Libertinus Serif",
  footer: "Libertinus Serif",
)

// ------------------------------------------
// STYLES
// 
#let _default-styles = (
  title-smallcaps: false,
  h1-smallcaps: true,
  h2-smallcaps: true,
)

// ------------------------------------------
// PLACARD element
// 
#let placard(
  title: "Poster Title",
  authors: (),
  scheme: "light",
  paper: "a1", 
  num-columns: 2,
  gutter: 1.5em,
  scaling: 1.0,
  colors: (:),
  sizes: (:),
  fonts: (:),
  styles: (:),
  margin: (:),
  flipped: false,
  footer: (
    content: [],
    logo: none,
    logo-placement: right,
    text-placement: left,
  ),
  body,
) = {
  let c = _default-themes.at(scheme) + colors 
  let f = _default-fonts + fonts
  let st = _default-styles + styles
  let marg = (top: 3.5cm * scaling, bottom: 6cm * scaling, x: 2.5cm * scaling) + margin
  let foot = (
    content: [],
    logo: none,
    logo-placement: right,
    text-placement: left,
  ) + footer

  let base-s = _default-sizes + sizes
  let s = (:)
  for (k, v) in base-s {
    s.insert(k, v * scaling)
  }

  set page(
    paper: paper,
    margin: marg,
    fill: c.paper-fill,
    flipped: flipped,
    footer: [
      #set text(font: f.footer, size: s.footer, fill: c.footer-text)
      #line(length: 100%, stroke: 2pt + c.accent)
      #v(0.5em)
      #grid(
        columns: (1fr, 1fr, 1fr),
        align(foot.text-placement + horizon, foot.content),
        align(center + horizon, if foot.text-placement == center { foot.content }),
        align(foot.logo-placement + horizon, if foot.logo != none { 
          if type(foot.logo) == str { image(foot.logo, height: 2.5cm) } else { foot.logo }
        }),
      )
    ],
  )

  set text(font: f.body, weight: "light", size: s.body, fill: c.text)
  set par(justify: true)

  let render-title(title-text) = [
    #set align(center)
    #block(inset: (bottom: 1em))[
    #set text(font: f.title, size: s.title, weight: "bold", fill: c.title)
    #if st.title-smallcaps { smallcaps(title-text) } else { title-text }
    ]
    #line(length: 100%, stroke: 2pt + c.accent)
  ]

  show heading.where(level: 1): it => [
    #set text(font: f.headings, fill: c.heading, size: s.h1, weight: "semibold")
    #if st.h1-smallcaps { smallcaps(it) } else { it }
  ]
  
  show heading.where(level: 2): it => [
    #set text(font: f.headings, fill: c.accent, size: s.h2, weight: "semibold")
    #if st.h2-smallcaps { smallcaps(it) } else { it }
  ]

  _placard-colors.update(c)
  _placard-sizes.update(s)
  _placard-fonts.update(f)
  _placard-styles.update(st)

  render-title(title)
  grid(
    columns: authors.map(_ => 1fr),
    gutter: 1em,
    ..authors.map(a => align(center, text(font: f.authors, size: s.authors, weight: "bold", a)))
  )
  v(1.5em)

  columns(num-columns, gutter: gutter, body)
}

// ------------------------------------------
// CARD Element
// 
#let card(title: "", fill: none, border-stroke: none, gap: none, body) = {
  context {
    let c = _placard-colors.get()
    let s = _placard-sizes.get()
    let f = _placard-fonts.get()
    
    let card-bg = if fill != none { fill } else if c != (:) { c.card-fill } else { white }
    let card-stroke = if border-stroke != none { border-stroke } else if c != (:) { c.card-border } else { gray }

    block(
      fill: card-bg,
      width: 100%,
      inset: 2em, 
      radius: 13pt,
      stroke: 2pt + card-stroke, 
      [
        #if title != "" {
          heading(level: 1, title)
          v(0.5em)
        }
        #set text(font: f.card, weight: "regular", size: s.card)
        #body
      ],
    )
    v(if gap != none {gap} else {1em})
  }
}