#let conf(
  subtitle: none,
  authors: (),
  years: (2024, 2025),
  toc: true,
  lang: "fr",
  font: "Satoshi",
  date: none,
  title,
  doc,
) = {

  set text(lang: lang, font: font)
  v(32pt)
  figure(
    image("assets/MIAGE.png", width: 50%),
  )
  v(32pt)
  let count = authors.len()
  let ncols = 1
  if count > 3 {
      ncols = 2
  }
  v(32pt)

  align(center)[
    #line(length: 100%)
    #v(16pt)
    #text(32pt, title, weight: "semibold")\
    #v(16pt)
    #if (subtitle != none) {
      line(length: 10%)
      text(24pt, subtitle, weight: "medium")
    }
    #line(length: 100%)
    #v(64pt)
    #text(20pt)[Années universitaires: ]
    #text(20pt, years.map(year => str(year)).join("-"))

    #align(bottom)[
      #grid(
        columns: (0.5fr,) * ncols,
        row-gutter: 12pt,
        ..authors.map(author => [
          #text(16pt, author.name) \
        ]
        ),
      )]
  ]

  pagebreak()
  set align(left)
  show heading.where(level: 1):  it => [
    #pad(
      top: 6pt,
      text(22pt ,it.body)
    )
  ]

  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(it)
  }

  if toc {
    outline(indent: 2em, depth: 1)
    pagebreak()
  }
  set page(
    margin: (top: 42pt),
    header: [
      #set text(8pt)
      #smallcaps[#title]
      #if (date != none) {
        h(1fr) + text(date)
      }
      #line(length: 100%)
    ],
  )
  doc
}

#let c = counter("question")
#let question(title, counter: true) = {
  v(8pt)
  if (counter) {
    c.step()
    heading(level: 2, c.display() + ") " + title)
  } else {
    heading(level: 2, title)
  }  
  v(4pt)
}

#let code-block(code, language, title: none) = {
  v(6pt)

  if (title != none) {
    text(10pt, style: "italic", title) 
    linebreak()
  }
  raw(code, lang: language)
  v(6pt)
}

#let remarque(content, bg-color: silver, text-color: black) = {
  v(4pt)
  block(
    fill: bg-color,
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    text(10pt, content, fill: text-color)
  )
}
