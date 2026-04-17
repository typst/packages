#import "../utils/translation.typ": translation

#let make-bibliographic-desc(
  student: none,
  description: none,
  language: none,
) = {
  pagebreak(weak: true)

  set text(lang: language)
  // TODO: adjust heading font EVERYWHERE (define with set... in conf.typ)
  align(
    left,
    heading(
      translation("Bibliographic Description"),
    ),
  )

  set par(spacing: 2em, leading: 2em)

  // these description keys always stay in english
  text(
    12pt,
    [
      *Author:* #text(student.name) \
      *Title:* #text(description.title-long) \
      *Metadata:* #text(description.metadata) \
      *Keywords:* #text(description.keywords)
    ],
  )
  linebreak()
  [
    #linebreak()
    #text(
      18pt,
      weight: "bold",
      translation("Goal"),
    ) \
    #text(12pt, description.goal) \
    #linebreak()
    #text(
      18pt,
      weight: "bold",
      translation("Content"),
    ) \
    #text(12pt, description.abstract)
  ]
  line(length: 100%, stroke: 0.5pt + gray)
}

