// Student title page. Optional metadata is omitted when absent.
#let make-cover(
  title,
  authors: (),
  affiliation: none,
  faculty: none,
  institution: none,
  program: none,
  course: none,
  instructor: none,
  date: none,
  laboratory: none,
  practice: none,
  group: none,
  language: "es",
  top-space: 3em,
) = [
  #v(top-space)
  #align(center)[
    #set par(first-line-indent: 0pt, leading: 1em, spacing: 1em)
    #text(weight: "bold")[#title]
    #v(1.5em)
    #if authors.len() > 0 [#authors.join(", ") #linebreak()]
    #if affiliation != none [#affiliation #linebreak()]
    #if faculty != none [#faculty #linebreak()]
    #if institution != none [#institution #linebreak()]
    #if program != none [#program #linebreak()]
    #if course != none [#course #linebreak()]
    #if instructor != none [#instructor #linebreak()]
    #if laboratory != none [
      #if language == "en" [Laboratory: ] else [Laboratorio: ]
      #laboratory #linebreak()
    ]
    #if practice != none [#practice #linebreak()]
    #if group != none [
      #if language == "en" [Group: ] else [Grupo: ]
      #group #linebreak()
    ]
    #if date != none [#date]
  ]
]
