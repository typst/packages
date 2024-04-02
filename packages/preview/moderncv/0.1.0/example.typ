#import "moderncv.typ": *

#show: project.with(
  title: "Master Frobnicator",
  author: "John Doe",
  github: "johndoe1337",
  phone: "+01 234 56 7890",
  email: "john@example.com"
)

= Education

#cventry(
  start: (month: "October", year: 2100),
  end: (month: "October", year: 2101),
  role: [Frobnication Engineering],
  place: "University of Central Mars City, M.Sc."
)[
  #v(1em)
  _with a grade of 110/110 with honors_
]

#cventry(
  start: (month: "October", year: 2099),
  end: (month: "October", year: 2100),
  role: [Frobnication Science and Engineering],
  place: "University of Central Mars City, B.Sc."
)[
  #v(1em)
  _with a grade of 110/110 with honors_
]


= Work Experience

#cventry(
  start: (month: "December", year: 2101),
  end: (month: "", year: "Present"),
  role: [Junior Frobnication Engineer],
  place: "WeDontWork Inc.",
  lorem(40)
)

= Side Projects

#cventry(
  start: (month: "December", year: 2099),
  end: (month: "", year: "Present"),
  role: [Quux Master],
  place: "MasterQuuxers.mars",
  lorem(40)
)

#cventry(
  start: (month: "March", year: 2098),
  end: (month: "August", year: 2099),
  role: [Full-bar frobnicator],
  place: "M.O.O.N. Inc",
  lorem(40)
)

= Languages

#cvlanguage(
  language: [Martian],
  description: [Mother tongue]
)

#cvlanguage(
  language: [Klingon],
  description: [C64 level],
  certificate: [Earth Klingon Certificate -- Certificate in Advanced Klingon (CAK64)]
)

#pagebreak()

= Technical Skills

#cvcol[
  ==== Programming Languages

  #grid(
    columns: (1fr, 1fr, 1fr),
    row-gutter: 0.5em,
    [- Java],
    [- C],
    [- C++],
    [- Python],
    [- Martian],
    [- English],
    [- ChatGPT],
    [- Ancient Greek],
    [- Legalese]
  )
]

#cvcol[
  ==== Environments

  - Earth (development and server management)
  - Wind (development)
  - Fire (development)
]

#cvcol[
  ==== Misc

  Various university-related and personal projects, some available on my GitHub profile.
]

= Other

#cvcol[
  - Best Pizza Cook Central Mars City 2091 Championship Winner
  - Coffee Conossieur
  - If You Are Reading This You Are Awesome
]

#v(1fr)

#align(center)[_(Last updated: February 2102)_]