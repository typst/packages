#import "@preview/catiche:0.1.0": report
// Optional: glossary support
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, gls, glspl

#show: make-glossary

#let entry-list = (
  (
    key: "ulille",
    short: "ulille",
    long: "University of Lille",
    description: "The university of Lille.",
  ),
)

#register-glossary(entry-list)

#show: report.with(
  lang: "en",
  title: "My super internship",
  author: (
    "Porco Rosso",
    "Master génie logiciel",
    "2024 - 2026",
    "porco.rosso.etu@univ-lille.fr"
  ),
  // Optional: company logo support
  // company-logo: image("./company-logo.svg"),
  supervisors: (
    (
      "Fio Piccolo",
      "Aircraft manufacturer",
      "Milan",
      "fio.piccolo@univ-lille.fr"
    ),
    (
      "Donal Curtis",
      "Airplane pilot",
      "United States",
      "donald.curtis@univ-lille.fr"
    )
  ),
  // Optional: acknowledgments support
  acknowledgments: "Thank you all!",
  abstracts: (
    abstract: "That was an insane internship!",
    abstract-translated: (
      lang: "fr",
      content: "C'était un stage incroyable !"
    )
  ),
  // Optional: references support
  // references: bibliography("refs.bib"),
  // Optional: glossary support
  glossary: entry-list,
)

= Introduction
#lorem(500)
