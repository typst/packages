# Ulille

An unofficial template for University of Lille internship reports. 

## Quick start

```
#import "@preview/ulille:0.1.0": report

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
  company-logo: image("./inria.svg"),
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
  // Optional: acknowledgments
  acknowledgments: [Thank you all!],
  abstracts: (
    abstract: [That was an insane internship!],
    abstract-translated: (
      lang: "fr",
      content: [C'était un stage incroyable !],
    ),
  ),
  // Optional: references support
  references: bibliography("refs.bib"),
  // Optional: glossary support
  glossary: entry-list,
)

= Introduction
#lorem(500)
```

The template automatically generates a list of figures and a list of tables.

## Contributing

Contributions are welcome! If you improve the template or fix an issue,
please explain and justify your changes in the pull request.

## License

This project is licensed under the [MIT license].
[MIT license]: ./LICENSE
