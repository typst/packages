#import "theme.typ": ink, muted, border

#let risk-report(title: "Analyse de risque", organization: "", author: "", date: "", version: "0.1", classification: "Diffusion à définir", font: "Libertinus Serif", body) = {
  set document(title: title, author: author)
  set text(font: font, size: 10pt, lang: "fr", fill: ink)
  set page(
    paper: "a4", margin: (x: 17mm, top: 19mm, bottom: 19mm),
    header: context {
      if counter(page).get().first() > 1 {
        set text(size: 8pt, fill: muted)
        grid(columns: (1fr, auto), gutter: 12pt,
          organization,
          classification,
        )
        v(5pt)
        line(length: 100%, stroke: 0.5pt + border)
      }
    },
    footer: context {
      set text(size: 8pt, fill: muted)
      grid(columns: (1fr, auto), gutter: 10pt,
        [Version #version],
        [#counter(page).display("1") / #counter(page).final().first()],
      )
    },
  )
  set par(leading: 0.65em, justify: false)
  set heading(numbering: none)
  show heading.where(level: 1): set text(size: 21pt, weight: "semibold", fill: ink)
  show heading.where(level: 2): set text(size: 12pt, weight: "bold", fill: ink)
  show heading.where(level: 2): set block(above: 14pt, below: 7pt)
  show link: set text(fill: ink)
  block(above: 0pt, below: 20pt)[
    #text(size: 11pt, fill: muted, organization)
    #v(14pt)
    #text(size: 30pt, weight: "semibold", title)
    #v(14pt)
    #text(size: 9pt)[#author #h(1fr) #date · Version #version]
    #v(8pt)
    #line(length: 100%, stroke: 0.7pt + ink)
    #v(4pt)
    #text(size: 8pt, fill: muted, classification)
  ]
  body
}
