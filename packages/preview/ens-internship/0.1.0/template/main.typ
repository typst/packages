#import "../lib.typ": ens-internship

#show: ens-internship.with(
  title: "A simple report template created with Typst",
  subtitle: "Master's degree final-year internship",
  lang: "en",
  authors: ("Author 1", "Author 2"),
  mentors: ("Mentors 1", "Mentors 2"),
  logo: "template/logo.png",
  place: "Place of the intership",
  date: "Beginning date",
  table-of-contents: true,
  bibliography: bibliography("refs.yaml"),
)

= First chapter
== Section 1

#lorem(200) @harry

== Section 2

#lorem(200) @electronic

= Second chapter

#lorem(800)
