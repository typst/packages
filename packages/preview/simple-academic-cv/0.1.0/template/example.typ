#import "@preview/simple-academic-cv:0.1.0": *

#set par(justify: true)
#show link: underline

#show: cv.with(
  name: "HUGH MANN",
  me: "Mann",                           // emboldens matching name in publications, etc
  // me: (first: "Hugh",  last: "Mann"),   // in case there are shared last names. If it really comes down to it, add some invisible unicode characters in other people's names (or your own) to differentiate them.
  spacing: 0.8, // tighter vertical spacing
  header-columns: (
    [Department of Sociology\ Some University],
    [+00 0 00 00 00 00],
    [#link("mailto:notarealemailaddress@domain.something")[fake\@email.net]],
  ),
  header-columns-separator: [$integral$],
  bib: bibliography("example.bib", style: "apa"),
)

#section("Education")[
  #entry[*Some University*][Wherever that is]
  #details[_PhD_ in *Something*][Mar. 2020]
  #entry[*Some other School*][Some other town]
  #details[_Degree Name_ in *Something else* ][Jan. 1970]
]

#section("Employment")[

  #job[Institute of Molecular Vibes][Sep. 2022 – Sep. 2023][Human Resources][
    Developed theory of theoretical theorizing. Also responsible for~:
    - modelling of polyatomic atoms
    - raisin humidity testing
  ]

  #job[McWendy's][Jun. 2019 – Aug. 2022][Fry cook][
    Lots of responsibilities
  ]

]

#section("Research Support")[
  #funding(
    [Totally real award],
    budget: [7.00 USD],
    Agency: [National Science Foundation],
    Program: [Some specific program name],
    Effective: [Aug. 1980 – Aug. 1989]
  )
]

#section("Publication and Talks")[
  #set enum(reversed: true)

  #subsection("Peer-Reviewed Publications")
  + #cite(<example2>,  form: "full")
  + #cite(<example1>,  form: "full")

  #subsection("Yap sessions")

  + #talk(
    [Electron-driven electricity],
    author: "H. Mann, Me, Myself, and I",
    ([Contributed Talk],    [Annual something meeting, Somewhere, XX, Country], [Month YEAR]),
    ([Poster Presentation], [Annual other meeting, Somewhere else, XX, Country], [Month YEAR]),
  )

  + #talk(
    [Drift tubes],
    author: "H. Mann",
    kind: "Contributed Talk",
    ([Location], [Date]),
  )


]

#section("Service")[
  #rows(
    ([Referee], [FIFA]),
    ([Organizer], [Some committee or conference or such], [2020 – 2021]),
  )
]
