#import "@preview/glossy:0.7.0": *

#let glossary-theme = (
  section: (title, body) => {
    heading(level: 1, numbering: none)[#title]
    body
  },
  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      heading(level: 2, numbering: none)[#name]
    }
    body
  },
  entry: (entry, index, total) => {
    let label = text(weight: "bold")[
      #entry.short#entry.label
      #if entry.long != none {
        " (" + entry.long + ")"
      }
    ]
    let description = entry.description

    block(breakable: false)[
      #grid(
        columns: (auto, 1fr, auto),
        label, h(1fr), entry.pages,
      )
      #v(-0.1cm)
      #description
      #v(0.1cm)
    ]
  },
)

#let styled-glossary = context {
  // Glossy creates metadata for each defined term during init-glossary
  // Check if any terms are actually used/referenced in the document
  let all-metadata = query(metadata)

  // Get all defined term keys from metadata
  let term-keys = all-metadata.filter(m => type(m.value) == str).map(m => m.value)

  // Check if any of these terms have been referenced
  // Glossy creates labels with "__gloss:<key>" prefix for term references
  let has-referenced-terms = term-keys.any(key => {
    query(label("__gloss:" + key)).len() > 0
  })

  if has-referenced-terms {
    glossary(theme: glossary-theme)
  }
}
