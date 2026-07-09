#import "../lib.typ": ensl-internship

#show: ensl-internship.with(
  title: "A simple report template created with Typst",
  subtitle: "Master's degree final-year internship",
  keywords: ("Kerlyon", "Lorem", "Ipsum"),
  abstract: lorem(25),
  lang: "en",
  authors: ("Author 1", "Author 2"),
  mentors: ("Mentors 1", "Mentors 2"),
  logo: image("../assets/Logo_CNRS.png", height: 50pt),
  place: "Place of the intership",
  date: "Beginning date",
  table-of-contents: true,
  bibliography: bibliography("refs.yaml"),
)

= First chapter
== Section 1

#lorem(200) @code

== Section 2

#lorem(200) @electronic

= Second chapter

#par("Bonum vinum laetificat cor hominis")

#lorem(400)
