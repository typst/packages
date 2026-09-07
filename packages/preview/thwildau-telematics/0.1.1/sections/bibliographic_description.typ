#import "../utils/translation.typ": translation

#let make-bibliographic-desc(
  student: none,
  description: none,
  language: none,
) = {
  pagebreak(weak: true)

  set text(12pt, lang: language)
  // TODO: adjust heading font EVERYWHERE (define with set... in conf.typ)
  align(
    left,
    heading(
      translation("Bibliographic Description", override-lang: language), // need to override-lang here, because otherwise it will render the title in the outline using the outlines language, not the text language from the context here
    ),
  )

  set par(spacing: 2em, leading: 2em)

  // these description keys always stay in english
  text(
    [
      *Author:* #text(student.name) \
      *Title:* #text(description.title-long) \
      *Metadata:* #text(description.metadata) \
      *Keywords:* #text(description.keywords)
    ],
  )

  linebreak()
  linebreak()

  // goal
  block(
    text(18pt, weight: "bold", translation("Goal")),
  )
  par(leading: 1.2em, description.goal)

  linebreak()

  // content/acstract
  block(
    text(18pt, weight: "bold", translation("Content")),
  )
  par(leading: 1.2em, description.abstract)

  linebreak()

  line(length: 100%, stroke: 0.5pt + gray)
}

