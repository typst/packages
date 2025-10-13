# ULB Report Template
Unofficial Typst template for reports at the ULB.

This template is based on the [LaTeX template](https://www.overleaf.com/latex/templates/ulbreport-template/jzjgsqbnswmw)

## Usage

```Typst
#import "@preview/ulb-report:0.1.0": report

#show: report.with(
  title: "Exemple de titre",
  studies: "Année d'étude",
  course: "Nom du cours",
  date: datetime.today().display("[day]/[month]/[year]"),
  authors: ("Nom 1", "Nom 2"),
  teachers: ("Prof 1", "Superviseur"),
  logo: image("path/to/logo.png"), // optional
  seal: image("path/to/seal.png", width: 20cm, height: 20cm), // optional
  lang: "fr", // optional (default: "fr")
)

// If you want a table of content
#outline(depth: 2) 

// If you want a bibliography
#bibliography("path/to/bib.bib", style: "ieee")

// If you want an appendix
#set heading(numbering: "A.1 -")
#counter(heading).update(0)
```

## Changelog

**0.1.0 - Initial release**

- First page style
- Table of content
- Level 1 headings

