#let resume-init(title: none, author: "六个骨头", header: none, footer: none, body) = {
  set document(author: author, title: title)
  set page(margin: (x: 3.2em, y: 3.2em), header: header, footer: footer)
  set text(font: ("Source Han Sans"), lang: "zh")
  show emph: it => {
    text(it.body, font: ("Source Han Serif SC",), style: "italic")
  }
  show link: it => {
    set text(blue, font: ("Source Han Sans"), weight: "bold")
    it
  }
  show heading.where(level: 1): it =>{
    set text(rgb("#448"), size: 1em, font: "Source Han Sans")
    stack(dir: ttb, spacing: 0.55em, {
      it.body
    }, line(stroke: 1.5pt, length: 100%))
    v(0.5em, weak: true)
  }
  show par: set block(spacing: 0.65em)

  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]
  set par(justify: true)
  body
}

#let primary-achievement(name, decs, contrib) = {
  set box(
    fill: color.hsv(240deg, 10%, 100%),
    stroke: 1pt,
    inset: 5pt,
    radius: 3pt,
  )
  box()[
    #name #h(1fr) #decs
    #v(1em, weak: true)
    #contrib
  ]
}
#let achievement(name, decs, contrib) = {
  set box(stroke: 1pt, inset: 5pt, radius: 3pt)
  box()[
    #name #h(1fr) #decs
    #v(1em, weak: true)
    #contrib
  ]
}
#let resume-section(primary: true, name, decs, contrib) = {
  if primary {
    primary-achievement(name, decs, contrib)
  }else{
    achievement(name, decs, contrib)
  }
}
