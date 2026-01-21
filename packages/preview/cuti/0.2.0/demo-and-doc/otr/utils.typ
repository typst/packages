#import "@preview/sourcerer:0.2.1": code

#let example(source, sd: true) = {
  block(
    //breakable: false,
    {
      {
        code(
          radius: 0pt,
          inset: 10pt,
          line-offset: 10pt,
          text-style: (font: ("Fira Code", "Source Han Sans SC")),
          stroke: 0.5pt+luma(180),
          source
        )
      }
      if sd {
        v(-1.2em)
        block(
          fill: rgb("dcedc8"),
          stroke: 0.5pt + luma(180),
          inset: 10pt,
          width: 100%,
          eval("#import \"../../lib.typ\": * \n" + source.text, mode: "markup")
        )
      }
    }
  )
}

#let typebox(fill: "default", s) = {
  set text(size: 10pt)

  let fillcolor = if fill == "default" {
    (
      "int": rgb("#e7d9ff"),
      "str": rgb("#d1ffe2"),
      "bool": rgb("#ffedc1"),
      "none": rgb("#ffcbc4"),
      "content": rgb("#a6ebe6"),
      "angle": rgb("#e7d9ff"),
      "relative": rgb("#e7d9ff"),
    ).at(s.text, default: luma(220))
  } else {fill}

  box(
    inset: 3pt,
    fill: fillcolor,
    radius: 3pt,
    baseline: 3pt,
    raw(s.text)
  )
}