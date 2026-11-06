// --- Table of Contents ---
#let toc(
  body-font: "",
  sans-font: "",
  dark-color: black
) = {
  // Make chapter bold but only in the TOC
  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(text(it, font: sans-font, fill: dark-color))
  }

  outline(
    title: {
      text(font: body-font, 1.5em, weight: 700, "Contents")
      v(15mm)
    },
    indent: 2em
  )
}
