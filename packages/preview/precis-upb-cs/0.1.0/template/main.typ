#import "@preview/precis-upb-cs:0.1.0": upb-thesis, abstract, synopsis

#show: upb-thesis.with(
  langs: ("en", "ro"),
  title: (en: "Title", ro: "Titlu"),
  subtitle: (en: "Subtitle", ro: "Subtitlu"),
  author: "Author",
  advisor: "Advisor",
  year: "2026",
  project-type: (en: "DIPLOMA PROJECT", ro: "PROIECT DE DIPLOMĂ"),
  logo-left: image("images/logo-university.png", width: 3cm),
  logo-right: image("images/logo-faculty.png", width: 5cm),
)

#synopsis[
  Lorem Ipsum
]

#abstract[
  Lorem Ipsum
]

= Introduction

#lorem(80)

= Related Work

#lorem(30) @example2024 #lorem(30)

= Conclusion

#lorem(40)

#bibliography("refs.bib", title: "References", style: "ieee")
