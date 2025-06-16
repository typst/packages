#import "@preview/i-figured:0.2.2"
#import "@preview/tablex:0.0.6": cellx, tablex, gridx, hlinex, vlinex, colspanx, rowspanx
#import "@preview/algo:0.3.3": algo, i, d, comment, code

#import "utils.typ": *

#let draw-binding() = {
  place("|", dx: -1.6cm, dy: 2.3cm)
  place("|", dx: -1.6cm, dy: 2.9cm)
  place("|", dx: -1.6cm, dy: 3.5cm)
  place("|", dx: -1.6cm, dy: 4.1cm)
  place("|", dx: -1.6cm, dy: 4.7cm)
  place("|", dx: -1.6cm, dy: 5.3cm)
  place("|", dx: -1.6cm, dy: 5.9cm)
  place("|", dx: -1.6cm, dy: 6.5cm)
  place("|", dx: -1.6cm, dy: 7.1cm)
  place("|", dx: -1.6cm, dy: 7.7cm)
  place("装", dx: -1.8cm, dy: 8.3cm)
  place("|", dx: -1.6cm, dy: 8.9cm)
  place("|", dx: -1.6cm, dy: 9.5cm)
  place("|", dx: -1.6cm, dy: 10.1cm)
  place("|", dx: -1.6cm, dy: 10.7cm)
  place("|", dx: -1.6cm, dy: 11.3cm)
  place("订", dx: -1.8cm, dy: 11.9cm)
  place("|", dx: -1.6cm, dy: 12.5cm)
  place("|", dx: -1.6cm, dy: 13.1cm)
  place("|", dx: -1.6cm, dy: 13.7cm)
  place("|", dx: -1.6cm, dy: 14.3cm)
  place("|", dx: -1.6cm, dy: 14.9cm)
  place("线", dx: -1.8cm, dy: 15.5cm)
  place("|", dx: -1.6cm, dy: 16.1cm)
  place("|", dx: -1.6cm, dy: 16.7cm)
  place("|", dx: -1.6cm, dy: 17.3cm)
  place("|", dx: -1.6cm, dy: 17.9cm)
  place("|", dx: -1.6cm, dy: 18.5cm)
  place("|", dx: -1.6cm, dy: 19.1cm)
  place("|", dx: -1.6cm, dy: 19.7cm)
  place("|", dx: -1.6cm, dy: 20.3cm)
  place("|", dx: -1.6cm, dy: 20.9cm)
  place("|", dx: -1.6cm, dy: 21.5cm)
}

#let empty-par() = {
  v(-1.2em)
  box()
}

#let make-cover(cover) = align(center)[
  #image("figures/tongji.svg", height: 2.25cm)
  #text(
    "TONGJI UNIVERSITY",
    font: font-family.hei,
    size: font-size.at("-2"),
    weight: "bold",
  )

  #v(30pt)
  #text("本科毕业设计（论文）", font: font-family.hei, size: font-size.at("-0"))
  #v(60pt)

  #set text(font: font-family.hei, size: font-size.at("-2"))
  #grid(
    columns: (5em, auto),
    gutter: 16pt,
    ..cover.enumerate().map(((idx, value)) => {
      set text(size: font-size.at("-2"))
      if calc.even(idx) {
        let arr = value.clusters()
        let k = (4 - arr.len()) / (arr.len() - 1)
        arr.join([#h(1em * k)])
      } else {
        block(
          width: 100%,
          inset: 4pt,
          stroke: (bottom: 1pt + black),
          align(center, value),
        )
      }
    }),
  )
]

#let make-abstract(title: "", abstract: "", keywords: (), prompt: (), is-english: false) = {
  align(
    center,
  )[
    #v(1em)
    #text(font: font-family.hei, size: font-size.at("-2"), weight: "bold", title)
    #v(1.5em)
  ]
  heading(prompt.at(0), numbering: none, outlined: false)

  set par(first-line-indent: 2em)
  text(abstract)

  v(5mm)
  set par(first-line-indent: 0em)
  text(font: font-family.xiaobiaosong, weight: "bold", prompt.at(1))
  let keywords-string = if is-english {
    keywords.join(", ")
  } else {
    keywords.join("，")
  }
  text(keywords-string)
}

#let make-outline(title: "目录", depth: 3, indent: true) = {
  // outline(title: "目录", depth: 3)
  heading(title, numbering: none, outlined: false)
  set par(first-line-indent: 0pt, leading: 0.9em)
  locate(
    it => {
      let elements = query(heading.where(outlined: true), it)

      for el in elements {
        // Skip headings that are too deep
        if depth != none and el.level > depth { continue }

        let el_number = if el.numbering != none {
          numbering(el.numbering, ..counter(heading).at(el.location()))
          h(0.5em)
        }

        let line = {
          if indent {
            let indent-width = if el.level == 1 {
              0pt
            } else if el.level == 2 {
              1em
            } else if el.level == 3 {
              4em
            } else {
              0pt
            }

            h(indent-width)
          }

          link(el.location(), el_number)
          link(el.location(), el.body)
          box(width: 1fr, h(0.25em) + box(width: 1fr, repeat[·#h(1pt)]) + h(0.25em))
          link(el.location(),str(counter(page).at(el.location()).first()))

          linebreak()
        }

        // link(el.location(), line)
        line
      }
    },
  )
}

#let heavyrulewidth = .08em
#let lightrulewidth = .05em
#let cmidrulewidth = .03em

#let toprule(stroke: heavyrulewidth) = {
  hlinex(stroke: stroke)
}

#let midrule(stroke: lightrulewidth) = {
  hlinex(stroke: stroke)
}

#let bottomrule(stroke: heavyrulewidth) = {
  hlinex(stroke: stroke)
}

#let cmidrule(start: 0, end: -1, stroke: cmidrulewidth) = {
  hlinex(start: start, end: end, stroke: stroke)
}