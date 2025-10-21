// prefatory/list-of-figures.typ
// List of figures with both automatic and manual entry options
// ===== INSTRUCTIONS =====
// 1. Choose either automatic OR manual (comment out the one you don't use)
// 2. For manual entries:
//    - Use format: Figure X.Y. Caption text#box(width: 1fr, repeat[.#h(2pt)])PageNum
//    - X = chapter number, Y = figure number within chapter
//    - Update page numbers after finalizing your document
//    - Keep captions short (1-2 lines maximum)
// 3. Ensure figure numbers match those used in your chapters

#pagebreak()
#align(center)[
  #text(size: 12pt)[LIST OF FIGURES]
]

#v(14pt)
#set par(leading: 1em, first-line-indent: 0pt)

// ===== OPTION 1: AUTOMATIC (RECOMMENDED) =====
// Uncomment this to auto-generate from all figures in your document
#outline(
  title: none,
  target: figure.where(kind: image),
  indent: auto,
)

// ===== OPTION 2: MANUAL ENTRY =====
// Use this if you need custom short captions in the list
// Format: Figure number. Short caption ........... page
// Replace these with your actual figures:

Figure 2.1 Nataraja#box(width: 1fr, repeat[.#h(2pt)])15

Figure 2.2 Dunning-Kruger Effect#box(width: 1fr, repeat[.#h(2pt)])16

// Add more figures as needed following the same format:
// Figure X.Y. Short caption text#box(width: 1fr, repeat[.#h(2pt)])PageNumber
