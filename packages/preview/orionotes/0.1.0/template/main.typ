#import "@preview/orionotes:0.1.0": orionotes

#show: orionotes.with(
  title: [Title of your work],
  authors: ("Your name",),
  professors: ("Your professors name",),
  date: "Academic Year",
  university: [Your university],
  degree: [Your degree],
  // If you want it insert and image object
  front-image: none,
  preface: [The preface to your notes],
  appendix: (
    enabled: true,
    title: "Appendices",
    body: [
      = Example
      Here go the appendices.
    ]
  ),
  bib: bibliography("example.bib")
)

// Here goes the body of your notes
