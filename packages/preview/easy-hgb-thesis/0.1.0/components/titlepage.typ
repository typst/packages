#import "i8n.typ": i8n, i8n-date-short

#let titlepage(
  course-of-study, // Studiengang
  schoolyear,
  mentor-name,
  work-type: "bachelor-thesis",
) = context [
  #set par(leading: 0.5em, spacing: 0.5em, justify: false)
  #set align(center)
  #set page(
    footer: [
      #set align(left)
      #line(length: 100%)
      #i8n("submission-notes"):\
      #grid(
        columns: (1fr, 1fr),
        gutter: 1cm,
        [#i8n("date"):], [#i8n("mentor"):],
      )
    ],
    footer-descent: 0cm,
  )

  #grid(
    columns: (auto, 1fr, auto),
    column-gutter: 0.5cm,
    [],
    // placeholder for fh logo
    [
      #text(
        size: 1.5em,
        weight: "bold",
      )[#i8n("fh-upper-austria"), #i8n("campus-hagenberg")]

      4232 Hagenberg, Softwarepark 11
    ],
    [],
    // placeholder for öh logo
  )
  #line(length: 100%)

  #v(1cm)
  #set text(weight: "bold")
  #i8n("course-of-study")\ #course-of-study

  #v(1cm)
  #i8n("schoolyear") #schoolyear

  #v(2cm)
  #text(size: 30pt)[#upper(i8n(work-type))]
  #v(1cm)
  #show title: set text(size: 36pt, hyphenate: false)
  #title(auto)
  #v(1cm)
  #text(weight: "regular")[#document.description]

  #v(2cm)
  #set par(spacing: 1.5em)
  #set align(left)
  #set text(weight: "regular")
  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    [
      *#i8n("executed-by"):*

      #document.author.map(author => [#author]).join([#parbreak()])
    ],
    [
      *#i8n("mentor"):*

      #mentor-name
    ],
  )


  #v(1cm)
  #let date = if type(document.date) == datetime {
    document.date
  } else {
    datetime.today(offset: auto)
  }
  Hagenberg, #i8n("on-date") #i8n-date-short(date)
]
