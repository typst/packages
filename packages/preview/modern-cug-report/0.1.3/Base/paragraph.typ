#let p-compact(it, spacing: 1.24em, leading: 1em) = {
  // leading: 行距; spacing: 段距
  set par(spacing: spacing, leading: leading)
  it
}

#let set-heading(it, fake-par: false, margin: 0.15em) = {
  // https://github.com/typst/typst/issues/1896
  // https://github.com/shuosc/SHU-Bachelor-Thesis-Typst/issues/12
  show heading: it => {
    // v(margin)
    it
    // v(margin)
  }

  show heading.where(level: 1): it => {
    set text(fill: blue) // size: 14pt, , weight: "regular"
    set par(leading: 1.0em, spacing: 1.24em)
    show "、": [、#h(0.2em)]
    show "，": [，#h(0.2em)]
    // counter(math.equation).update(0)
    // counter(figure.where(kind: image)).update(0)
    // counter(figure.where(kind: table)).update(0)
    // counter(figure.where(kind: raw)).update(0)
    // it.fields()
    v(0.5em)
    it.body
  }

  show heading.where(level: 2): it => {
    set text(fill: black, weight: "bold") // size: 13pt, 
    it
    v(0.4em)
  }

  show heading.where(level: 3): it => {
    it
    v(0.3em)
  }

  show heading.where(level: 4): it => {
    it
    v(0.25em)
  }

  show heading.where(level: 5): it => {
    it
    v(0.25em)
  }
  it
}
