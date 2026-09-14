// --- Table of Contents ---
#let toc(
  body-font: "",
  sans-font: "",
  dark-color: black
) = {
  // Make chapters bold but only in the TOC
  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(text(it, font: sans-font, fill: dark-color))
  }

  context {
    let lang = text.lang
    let x = ""
    if lang == "de" {
      x = "Inhaltsverzeichnis"
    } else {
      x = "Contents"
    }
    // Set the title of the TOC
    outline(
      title: {
        text(font: sans-font, x)
      },
      indent: 2em
    )
  }

}
