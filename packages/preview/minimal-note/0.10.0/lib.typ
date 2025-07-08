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
    let default_color = rgb("#57B9FF")
    let label_color = rgb("#57B94F")
  
    if type(it.dest) == label {
      underline(text(fill: label_color)[#it])
    } else {
      underline(text(fill: default_color)[#it])
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
#let color_box(header, body, color: rgb("B8F0D3")) = {
  set align(center)
  
  box(
    fill: color,
    inset: 13pt,
    radius: 10%,
  )[
    #set align(left)
    
    #place(top + left)[
      *#header*
    ] \
    #body
  ]
}

// To 

#let green_box(header, body) = {
  color_box(header, body, color: rgb("B8F0D3"))
}

#let orange_box(header, body) = {
  color_box(header, body, color: rgb("FFDAB8"))
}
