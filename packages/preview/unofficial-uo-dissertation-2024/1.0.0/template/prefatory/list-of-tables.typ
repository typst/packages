// prefatory/list-of-tables.typ
// List of tables with both automatic and manual entry options

#pagebreak()
#align(center)[
  #text(size: 12pt)[LIST OF TABLES]
]

#v(14pt)
#set par(leading: 1em, first-line-indent: 0pt)

// ===== OPTION 1: AUTOMATIC (RECOMMENDED) =====
// Uncomment this to auto-generate from all tables in your document
#outline(
  title: none,
  target: figure.where(kind: table),
  indent: auto,
)

// ===== OPTION 2: MANUAL ENTRY =====
// Use this if you need custom short captions in the list
// Format: Table number. Short caption ........... page
// Replace these with your actual tables:

Table 3.1. Experimental variables and measurement scales#box(width: 1fr, repeat[.#h(2pt)])18

// Add more tables as needed following the same format:
// Table X.Y. Short caption text#box(width: 1fr, repeat[.#h(2pt)])PageNumber