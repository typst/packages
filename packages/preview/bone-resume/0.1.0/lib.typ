#let resume-init(title: none, author: "六个骨头", footer: none, body) = {
  set document(author: author, title: title)
  set page(margin: (x: 4em, y: 5em), footer: footer)
  set box(fill: color.hsv(240deg, 10%, 100%), inset: 5pt, radius: 3pt)
  set text(
    font: ("Hack Nerd Font", "Source Han Sans"),
    lang: "zh",
  )
  show emph: it => {
    text(it.body,  style: "italic")
  }
  show link: it => {
    set text(blue, font: (
      "Source Han Serif SC",
    ), weight: "bold")
    it
  }
  show heading.where(level: 1): it =>{
    set text(rgb("#448"), size: 16pt, font: "Source Han Sans CN")
    stack(dir: ttb, spacing: 12pt, {
      it.body
    }, line(length: 100%))
    v(8pt, weak: true)
  }

  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]
  set par(justify: true)
  body
}

#let resume-section(name, decs, contrib) = {
  box()[
    #name #h(1fr) #decs 
    #v(1em, weak: true)
    #contrib
  ]
}
