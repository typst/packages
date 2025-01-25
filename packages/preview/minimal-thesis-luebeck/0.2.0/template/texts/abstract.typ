#import "metadata.typ": *

#set text(
  font: body-font, 
  size: 12pt
)
#set par(
  leading: 1em,
  justify: true
)

// --- english Abstract ---
#set text(lang: "en")
#v(1fr)
#align(center, text(font: body-font, 1em, weight: "semibold", "Abstract"))

#lorem(100)

#v(1fr)

// --- german Abstract ---
#set text(lang: "de")
#v(1fr)
#align(center, text(font: body-font, 1em, weight: "semibold", "Zusammenfassung"))

#lorem(100)

#v(1fr)
