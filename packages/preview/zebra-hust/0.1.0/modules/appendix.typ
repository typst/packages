#let appendix-page(title: none, font: ("TeX Gyre Termes", "FandolHei"), size: 18pt, body) = {
  pagebreak(weak: true)
  counter("appendix").step()
  context {
    let appendix-title = [附录 #counter("appendix").display("A")]
    if title != none {
      appendix-title += h(1em) + title
    }

    set heading(numbering: none)
    show heading.where(level: 1): set align(center)
    show heading.where(level: 1): set text(font: font, size: size, weight: "bold")

    heading(level: 1, numbering: none, appendix-title)
    body
  }
}

#let appendix-pages(entries: (), font: ("TeX Gyre Termes", "FandolHei"), size: 18pt) = {
  for entry in entries {
    appendix-page(title: entry.at("title", default: none), font: font, size: size, entry.body)
  }
}
