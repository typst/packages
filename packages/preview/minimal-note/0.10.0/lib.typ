// === Algorithmic Logistics ===
#import "@preview/algorithmic:1.0.0"
#import algorithmic: *


// === Template ===
#let minimal-note(
  title: [Paper Title],
  author: [Albert Einstein],
  date: datetime.today().display("[month repr:long], [year]"),
  doc
) = {
  // Styling Configurations
  set heading(numbering: "1.")
  
  show link: it => {
    let default-color = rgb("#57B9FF")
    let label-color = rgb("#57B94F")
  
    if type(it.dest) == label {
      underline(text(fill: label-color)[#it])
    } else {
      underline(text(fill: default-color)[#it])
    }
  }

  // Title and Date
  align(center, text(18pt)[*#title*])
  align(center)[#author \ #date]

  // Table of Contents
  outline()

  // Document
  doc
}


// === Prompting Boxes ===
#let color-box(header, body, color: rgb("B8F0D3")) = {
  set align(center)
  
  box(
    fill: color,
    inset: 13pt,
    radius: 10pt,
    width: 100%
  )[
    #set align(left)
    
    #place(top + left)[
      *#header*
    ] \
    #body
  ]
}

// To add additional box colors, follow the below function definitions and replace the color named argument.

#let green-box(header, body) = {
  color-box(header, body, color: rgb("B8F0D3"))
}

#let orange-box(header, body) = {
  color-box(header, body, color: rgb("FFDAB8"))
}

#let blue-box(header, body) = {
  color-box(header, body, color: rgb("B5EAFF"))
}
