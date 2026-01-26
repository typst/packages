// --- DOCUMENT LAYOUT AND STYLING ---

#let project(body) = {
  set page(
    margin: (left: 10mm, right: 10mm, top: 10mm, bottom: 10mm),
  )
  set text(
    font: "Inter", 
    size: 10pt, 
    lang: "en"
  )
  set par(justify: true, leading: 0.6em)
  body
}

#let section(title) = {
  v(1em, weak: true)
  block(width: 100%)[
    #set text(weight: "bold", size: 11pt)
    #stack(
      spacing: 0.35em,
      title,
      line(length: 100%, stroke: 0.7pt + rgb("#802020"))
    )
  ]
}

#let entry(
  title: "",
  sub-title: "", 
  date: "",
  location: "",
  description: []
) = {
  pad(bottom: 0.6em)[
    #grid(
      columns: (1fr, auto),
      row-gutter: 0.45em,
      [*#title*], [#text(weight: "regular")[#date]],
      [#emph(sub-title)], [#text(style: "italic", size: 9pt)[#location]]
    )
    #v(0.1em)
    #text(size: 9.5pt)[#description]
  ]
}

// Diubah dari project_entry ke project-entry
#let project-entry(
  title: "",
  category: "",
  description: []
) = {
  pad(bottom: 0.6em)[
    *#title* \
    #v(-0.45em) 
    #emph(text(size: 9pt)[#category]) \
    #v(-0.2em)  
    #text(size: 9.5pt)[#description]
  ]
}
