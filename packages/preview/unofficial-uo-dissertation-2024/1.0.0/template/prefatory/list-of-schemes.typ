// prefatory/list-of-schemes.typ
// List of schemes with both automatic and manual entry options

#pagebreak()
#align(center)[
  #text(size: 12pt)[LIST OF SCHEMES]
]

#v(14pt)
#set par(leading: 1em, first-line-indent: 0pt)

// ===== OPTION 1: AUTOMATIC (RECOMMENDED) =====
// Uncomment this to auto-generate from all schemes in your document
#outline(
  title: none,
  target: figure.where(kind: "scheme"),
  indent: auto,
)

// ===== OPTION 2: MANUAL ENTRY =====
// Use this if you need custom short captions in the list
// Format: Scheme number. Short caption ........... page
// Replace these with your actual schemes:

// Scheme 1.1. Synthesis pathway#box(width: 1fr, repeat[.#h(2pt)])32

// Scheme 1.2. Reaction mechanism#box(width: 1fr, repeat[.#h(2pt)])38

// Scheme 2.1. Catalytic cycle#box(width: 1fr, repeat[.#h(2pt)])56

// Add more schemes as needed following the same format:
// Scheme X.Y. Short caption text#box(width: 1fr, repeat[.#h(2pt)])PageNumber