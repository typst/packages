#import "../components.typ": assignment-form-heading
#import "../../style.typ" as style

#let assignment(
  body,
  title: auto,
  degree: sym.space,
  field: sym.space,
  program: sym.space,
  author: (name: "", id: ""),
  mentor: (name: ""),
  date: sym.space,
  number: sym.space,
  copy-for: none,
  style: style,
  ..sink,
) = context [
  #import style: gray
  #show: style.form
  #set text(lang: "sr", region: "RS")

  #let _hairline = text.fill + 0.005em
  #let _very_thin = text.fill + 0.05em
  #let _medium = text.fill + 0.15em

  #assignment-form-heading(number: number, date: date, style: style)[Задатак за завршни рад]

  #show heading: upper
  #set list(marker: "-", indent: 1.5em, body-indent: 1.5em)
  #set table(stroke: _hairline)
  #set par(justify: true, first-line-indent: 0pt)

  #v(0.3fr)

  #align(right)[#text(style: "italic")[(Податке уноси предменти професор #sym.hyph ментор)]]
  #block(stroke: _medium, above: 0.67em)[
    #table(
      columns: 2,
      rows: 6,
      align: left + horizon,

      [Студијски \ програм], [#program],
      [Студент],
      table.cell(inset: 0pt)[
        #table(
          rows: 1,
          columns: (1fr, .4fr, .45fr),
          // align: (left, left, center),
          stroke: (top: none, bottom: none, left: none),

          author.name,
          [Број индекса:],
          text(tracking: 0.067em, size: 0.8em, fractions: false)[#upper(author.id)],
        )
      ],

      [Степен и врста \ студија:], degree,
      [Област:], field,
      [Ментор:], mentor.name,
      table.cell(
        colspan: 2,
        inset: (left: 0.69em, right: 0.01pt),
        stroke: (left: _medium, right: _medium, bottom: _medium),
        fill: gray,
      )[#text(size: 0.9em)[
        НА ОСНОВУ ПОДНЕТЕ ПРИЈАВЕ, ПРИЛОЖЕНЕ ДОКУМЕНТАЦИЈЕ И ОДРЕДБИ СТАТУТА ФАКУЛТЕТА \
        ИЗДАЈЕ СЕ ЗАДАТАК ЗА ЗАВРШНИ РАД, СА СЛЕДЕЋИМ ЕЛЕМЕНТИМА:
        - проблем -- тема рада;
        - начин решавања проблема и начин практичне провере резултата рада, ако је таква провера
          неопходна;
      ]],
    )
  ]

  #heading(level: 2, outlined: false, bookmarked: false)[Наслов завршног рада:]

  #rect(width: 100%, stroke: _medium, height: 0.7fr, inset: 0.67em, outset: 0pt)[
    #align(center + horizon, strong(if title == auto { context document.title } else { title }))
  ]

  #heading(level: 2, outlined: false, bookmarked: false)[Текст задатка:]

  #rect(width: 100%, stroke: _medium, height: 4fr, inset: 0.67em)[
    #body
  ]

  #align(bottom)[

    #box(stroke: _medium)[
      #table(
        rows: (auto, 1cm),
        columns: (1fr, 1fr),

        [Руководилац студијског програма:], [Ментор рада:],
        [], [],
      )
    ]

    #table(
      columns: (1fr,),
      stroke: _very_thin
    )[
      #stack(
        dir: ltr,
        spacing: 0.5em,

        [Примерак за:],
        [#if copy-for in ("student", [student]) { sym.ballot.cross } else { sym.ballot } #sym.hyph
          Студента;],
        [#if copy-for in ("mentor", [mentor]) { sym.ballot.cross } else { sym.ballot } #sym.hyph
          Ментора],
      )
    ]
  ]

  #align(right)[
    #text(size: 0.9em)[
      Образац *Q2.НА.04-03* - Издање 1
    ]
  ]

]

#assignment()[]
