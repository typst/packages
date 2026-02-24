// prefatory/toc.typ
// Table of Contents with automatic generation

#pagebreak()
#align(center)[
  #text(size: 12pt)[TABLE OF CONTENTS]
]
#v(14pt)

// Bold styling for chapter entries - applies ONLY within this file
#show outline.entry.where(level: 1): it => {
  v(0.5em)
  text(weight: "bold")[#it]
}

// Generate automatic table of contents
#outline(
  title: none,
  indent: auto,
  depth: 2, // Shows chapters (level 1) and sections (level 2)
)

#v(0.25in)

// Manually add appendices and references if needed - update page numbers after finalizing
// Uncomment and update these lines as needed:
APPENDIX: SUPPLEMENTAL FIGURES#box(width: 1fr, repeat[.#h(2pt)])28 //for a single appendix
// APPENDICES#box(width: 1fr, repeat[.#h(2pt)])00
// #pad(left: 0.5in)[
//   A. APPENDIX TITLE IN ALL CAPS#box(width: 1fr, repeat[.#h(2pt)])86 \
//   B. APPENDIX TITLE IN ALL CAPS#box(width: 1fr, repeat[.#h(2pt)])90
// ]

REFERENCES CITED#box(width: 1fr, repeat[.#h(2pt)])33 //update the page number after finalizing