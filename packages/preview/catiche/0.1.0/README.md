# Catiche

An unofficial template for University of Lille internship reports. 

## Quick start

```
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

## Disclaimer

The university logos found on the [university website](https://identite.univ-lille.fr/en-bref/identite-ulille) or in
the public domain, such as on [Wikipedia](https://pcd.wikipedia.org/wiki/Fichier:Logotype_Universit%C3%A9_de_Lille_2022.svg),
are protected by the [university’s trademark](https://www.univ-lille.fr/mentions-legales#:~:text=publication.-,Les,usage).
They are intended for use by students and other members of the university for educational and academic purposes only.

## Contributing

Contributions are welcome! If you improve the template or fix an issue,
please explain and justify your changes in the pull request.

## License

This project is licensed under the [MIT license].
[MIT license]: ./LICENSE
