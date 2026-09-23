#import "../../../core/setup.typ": nw-config, nw-meta, nw-theme

// Preface page. Pass the preface text as the body:
//   #preface[Welcome to my notes...]
#let preface(
  authors: auto,
  affiliation: auto,
  body,
) = {
  page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    header: none,
    footer: none,
  )[
    #context {
      let theme = nw-theme()
      let c = nw-config()
      let m = nw-meta()
      let pick(v, d) = if v == auto { d } else { v }
      let authors = pick(authors, m.authors)
      let affiliation = pick(affiliation, m.affiliation)

      [
        #line(length: 100%, stroke: 1pt + theme.text-muted)

        #v(2cm)

        #text(
          font: c.title-font,
          size: 36pt,
          weight: "bold",
          tracking: 1pt,
          fill: theme.text-heading,
        )[Preface]

        #v(1.5cm)

        #line(length: 100%, stroke: 1pt + theme.text-muted)

        #v(2cm)

        #text(font: c.font, fill: theme.text-main, size: 11pt)[
          #body
        ]

        #v(2em)

        #line(length: 100%, stroke: 0.5pt + theme.text-muted)

        #v(1em)

        #align(right)[
          #text(
            font: c.title-font,
            fill: theme.text-main,
            size: 12pt,
            style: "italic",
          )[
            #if type(authors) == array {
              authors.join(" & ")
            } else {
              authors
            }\
            #text(size: 10pt, fill: theme.text-muted)[
              #affiliation
            ]
          ]
        ]
      ]
    }
  ]
  counter(page).step()
}
