#let conf(title: none, doc) = {
  set page(
    header: [
      #align(
        right + horizon,
        [#title])
      ],
    )
    set text(
      font: "PT Mono",
      size: 12pt,
    )
    doc
  }

  #let character = (name) => [
    #upper(name.slice(0, 3)).
  ]

  #let log(number-lines: 5, body) = {
    set terms(separator: h(2em), hanging-indent: 5em, spacing: 1em)
    set par.line(
      numbering: i => if calc.rem(i, number-lines) == 0 {i},
      number-margin: right,
    )
    block(stroke: (left: 4pt), inset: 1em)[
      #body
    ]
  }

  #let say = (name, saying) => [/ #character(name): #saying]
