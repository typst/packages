/***********************/
/* MONASH COLOR SCHEME */
/***********************/

// Monash University Official Brand Colors
// Source: Monash University Brand Guidelines

// Primary Colors
#let monash-blue = rgb(0, 93, 166)        // Monash Blue - Primary brand color
#let monash-bright-blue = rgb(0, 102, 204)  // Bright Blue - Secondary
#let monash-yellow = rgb(255, 209, 0)    // Monash Yellow - Accent color

// Secondary Blues
#let monash-deep-blue = rgb(0, 51, 102)  // Deep Blue - Dark variant
#let monash-light-blue = rgb(230, 242, 255)  // Light Blue - Light variant
#let monash-navy = rgb(0, 83, 156)       // Navy - Medium variant

// Usage Guidelines:
// - Primary text/headings: monash-blue
// - Secondary headings: monash-bright-blue  
// - Accent elements: monash-yellow
// - Dark backgrounds: monash-deep-blue
// - Light backgrounds: monash-light-blue
// - Medium contrast: monash-navy

// Applied Colors in Template:
// - Cover title: monash-blue
// - H1 headings: monash-blue
// - H2 headings: monash-bright-blue
// - H3 headings: monash-navy
// - Header text: monash-blue

/**************************/
/* MODERN ENHANCEMENTS */
/**************************/

// Modern text styling
#let modern-text(
  body,
  size: 11pt,
  weight: "regular",
  fill: rgb(0, 0, 0),
  style: "normal"
) = {
  set text(size: size, weight: weight, fill: fill, style: style)
  body
}

// Modern quote styling
#let modern-quote(body) = {
  block(
    width: 85%,
    inset: (left: 20pt, top: 10pt, bottom: 10pt),
    fill: monash-blue.with(a: 5%),
    radius: 4pt,
    stroke: (left: 2pt + monash-blue)
  )[
    #set text(style: "italic")
    #body
  ]
}

// Modern code block styling
#let modern-code(code) = {
  block(
    width: 100%,
    inset: (x: 15pt, y: 10pt),
    fill: monash-light-blue,
    radius: 6pt,
    stroke: (top: 1pt + monash-blue.with(a: 30%), bottom: 1pt + monash-blue.with(a: 30%))
  )[
    #set text(font: "Courier New", size: 10pt)
    #code
  ]
}

// Modern table styling
#let modern-table(..args) = {
  table(
    ..args,
    stroke: (x: none, y: 1pt + monash-blue.with(a: 20%)),
    fill: (x, y) => if y == 0 { monash-blue.with(a: 10%) } else { none }
  )
}

// Modern figure caption
#let modern-figure(body, caption) = {
  figure(
    body,
    caption: [
      #set text(size: 10pt, fill: monash-navy)
      #caption
    ]
  )
}

// Modern section break
#let section-break() = {
  v(1em)
  align(center)[
    #box(width: 30%, height: 1pt, fill: monash-blue.with(a: 30%))
  ]
  v(1em)
}

// Modern highlight box
#let highlight-box(title, body) = {
  block(
    width: 100%,
    inset: (x: 20pt, y: 15pt),
    fill: monash-blue.with(a: 8%),
    radius: 8pt,
    stroke: 1pt + monash-blue.with(a: 40%)
  )[
    #set text(weight: "bold", fill: monash-blue)
    #title
    #v(0.5em)
    #set text(weight: "regular", fill: rgb(0, 0, 0))
    #body
  ]
}