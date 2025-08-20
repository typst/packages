// --- Table of Contents ---
#let toc(body-font, sans-font) = {
  // Make chapter bold but only in the TOC
  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(text(it, font: sans-font))
  }

  outline(
    title: {
      text(font: body-font, 1.5em, weight: 700, "Contents")
      v(15mm)
    },
    indent: 2em
  )
}
