#import "@preview/politemplate:0.1.0": politemplate

#show: politemplate.with(
  title: [Poli Template],
  students: (
    ([Student 1],[13685478]),
    ([Student 2]),
  ),
  teachers: (
    [Teacher 1],
    [Teacher 2],
  ),
  front_header: [
    departamento de engenharia elétrica\
    PRO3821 - Fundamentos da economia\
    Turma 1
  ],
  location: [São Paulo, SP],
  logo: image("./logo.jpg"),
  bibliography: bibliography(
    "./references.bib",
    style: "associacao-brasileira-de-normas-tecnicas",
    full: true,
  ),
  footer_ignore: ("Conclusão",)
)

= A

#lorem(100)

== A.a

#lorem(100)
== A.b

#lorem(100)

// By default, a pagebreak is placed before all headings. To Ignore this behaviour, add #metadata("nobreak") at the header's end
= B #metadata("nobreak")

#lorem(100)

== B.a

#lorem(100)
== B.b

#lorem(100)

= C

#lorem(100)

== C.a

#lorem(100)
== C.b

#lorem(100)

= Conclusão

#lorem(200)
