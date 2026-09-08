#import "@preview/sanor:0.2.1": *

// Set up presentation format.
#set page(paper: "presentation-16-9", fill: luma(20))
#set text(size: 25pt, fill: white)

#slide(s => (
  [
    #let tag = tag.with(s)
    = Simultaneous Animation
    #set align(center + horizon)

    #grid(columns: (1fr,) * 2, align: horizon)[
      #tag("Jack")[Jack]

      #tag("jtext")[Jack was a teacher.]
    ][
      #tag("Julie")[Julie]

      #tag("ltext")[Julie was a student.]
    ]

    #s.push((
      apply("Jack"),
      apply("Julie"),
    ))

    #s.push((
      once("Jack", circle.with(fill: blue)),
      once("jtext"),
    ))

    #s.push((
      once("Julie", circle.with(fill: fuchsia)),
      once("ltext"),
    ))
  ],
  s,
))