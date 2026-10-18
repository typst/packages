#set outline.entry(
  fill: grid(
    columns: 2,
    gutter: 0pt,
    repeat[#h(5pt).], h(11pt),
  ),
)

#show outline.entry: set text(size: 11pt)
#show outline.entry: set block(above: 10pt)

#{
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "semibold", size: 11pt)
  show outline.entry.where(level: 1): set block(above: 24pt)
  heading(level: 1, "Table of Contents", numbering: none, supplement: "toc")
  outline(depth: 3, indent: auto, title: none, target: heading)
}