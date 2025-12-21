#set page(numbering: none)

// style level 1 headings
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true) // space above
  text(it, weight: 700, size: 14pt)
}

// style level 2 headings
#show outline.entry.where(level: 2): it => {
  v(4pt) // space above
  text(it, weight: 500, size: 13pt)
}

// style level 3 headings
#show outline.entry.where(level: 3): it => {
  text(it, weight: 300, size: 12pt)
}

// custom title
#align(center)[#text(size: 18pt)[*Obsah*]]

#v(14pt)

// outline itself
#outline(title: none, indent: 1.6em)
