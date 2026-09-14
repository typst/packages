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
    let title_str = ""
    if lang == "de" {
      title_str = "Inhaltsverzeichnis"
    } else {
      title_str = "Contents"
    }
    // Set the title of the TOC
    outline(
      title: {
        text(font: sans-font, title_str, size: 15pt)
      },
      indent: 2em
    )
  }

}
