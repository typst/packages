// src/utils.typ - Reusable utility functions

#import "colors.typ": *

// Create a highlighted info box
#let info-box(title, content) = {
  block(
    width: 100%,
    fill: background,
    stroke: (left: 3pt + accent),
    inset: (x: 1em, y: 0.75em),
    radius: (right: 4pt),
  )[
    #text(weight: "bold", fill: primary)[#title]
    #v(0.3em)
    #content
  ]
}

// Create a warning box
#let warning-box(title, content) = {
  block(
    width: 100%,
    fill: rgb("#fffbeb"),
    stroke: (left: 3pt + warning),
    inset: (x: 1em, y: 0.75em),
    radius: (right: 4pt),
  )[
    #text(weight: "bold", fill: warning)[#title]
    #v(0.3em)
    #content
  ]
}

// Format a definition term
#let definition(term, description) = {
  block(
    width: 100%,
    inset: (y: 0.5em),
  )[
    #text(weight: "bold")[#term:] #description
  ]
}

// Create a quote block with attribution
#let quote-block(content, author: none) = {
  block(
    width: 100%,
    fill: luma(248),
    inset: 1em,
    radius: 4pt,
  )[
    #set text(style: "italic")
    "#content"
    #if author != none {
      v(0.5em)
      align(right)[— #author]
    }
  ]
}

// Horizontal rule with spacing
#let divider() = {
  v(1em)
  line(length: 100%, stroke: 0.5pt + border)
  v(1em)
}

// Todo marker (for drafts)
#let todo(content) = {
  box(
    fill: rgb("#fed7d7"),
    inset: (x: 0.5em, y: 0.2em),
    radius: 2pt,
  )[
    #text(fill: error, weight: "bold", size: 0.9em)[TODO: #content]
  ]
}

