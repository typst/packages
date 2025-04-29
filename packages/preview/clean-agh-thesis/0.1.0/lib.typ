#let agh(
  titles: (),
  bibliography: none,
  author: [Author],
  supervisor: [Supervisor],
  course: [Course],
  masters: bool,
  department: [Department],
  acknowledgements: (),
  body
) = {
  set document(title: titles.join(" "), author: author)
  set page(
    paper: "a4",
    margin: (top: 30mm, bottom: 30mm, left: 30mm, right: 20mm),
  )
  set text(spacing: 3pt, size: 12pt)
  set align(center)

  figure(
    image("agh.jpg", width: 15%)
  )

  v(0.5cm)

  text(
    upper("Akademia Górniczo-Hutnicza im. Stanisława Staszica w Krakowie"),
    weight: 900,
    size: 12pt
  )

  v(0cm)

  text(
    department,
    weight: 700,
    size: 12pt,
  )

  v(3cm)

  text(
    if masters [Praca dyplomowa] else [Projekt dyplomowy],
    weight: 800,
    size: 16pt,
  )

  v(0cm)

  for c in titles [
    #text(
      c,
      weight: 500,
      size: 16pt,
    )

    #v(0cm)
  ]
    

  align(bottom)[
    #table(
      stroke: (bottom: 0pt, left: 0pt, right: 0pt, top: 0pt),
      align: left,
      columns: 2,
      [Autor pracy:],
      author,
      [Kierunek studiów:],
      course,
      [Opiekun pracy:],
      supervisor,
    )

    #v(3cm)

    #let today = datetime.today()
    Kraków #today.year()
  ]

  pagebreak(to: "odd")

  align(bottom + right)[
    #block(width:70%)[
      #set align(right)
      #for a in acknowledgements [
        #a
        #v(0cm)
      ]
    ]
  ]

  pagebreak(to: "odd")

  set align(left)
  v(1cm)
  outline(title: [
    Spis treści
    #v(0.5cm)
    ],
  indent: 18pt)

  pagebreak(to: "odd")

  set page(numbering: "1")
  set heading(numbering: "1.1")
  set par(first-line-indent: 1.25cm)
  show heading: pad.with(left: 0cm, bottom: 0.5cm)

  show heading: it => block(inset: (left: (it.level - 1) * 1.25cm), [
    #it
  ])

  body
  pagebreak(to: "odd")
  bibliography
}