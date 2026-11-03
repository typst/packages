# HPI Thesis Template

This template is for HPI students writing their Bachelor's or Master's thesis.

## Disclaimer

- This template is not official.
- Official university guidelines may differ from the ones used in this template.

## Getting Started

```bash
typst init @preview/cleanified-hpi-thesis
```

## Configuration

An example configuration is located in [`example/`](./example/main.typ).

```typst
#import "@preview/cleanified-hpi-thesis:0.1.0": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  translation: "Eine adäquate Übersetzung meines Titels",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  study-program: "IT-Systems Engineering",
  chair: "Data-Intensive Internet Computing",
  professor: "Prof. Dr. Rosseforp Renttalp",
  advisors: ("This person", "Someone Else"),
  abstract: "Some abstract",
  abstract-de: "Der deutsche Abstract...",
  acknowledgements: "Thanks to ...",
  type: "Master",
  bibliography: bibliography("references.bib"),
  // lang: "de",
  // typography: (font: "STIX Two Text", body-text-size: 12pt),
  // layout: (for-print: true, toc-depth: 2),
  // appearance: (accent-color: rgb("#B1063A")),
  // labels: (declaration-city: "Berlin"),
)

... your content ...
```

## Logo Usage

Please note the logo usage guidelines of University of Potsdam ([UP Logo Usage Guidelines](https://www.uni-potsdam.de/fileadmin/projects/zim/files/MMP/PDF_Dateien_MMP/250509-Leitfaden_DigitalPrint-web.pdf)) and Hasso Plattner Institute ([HPI Logo Usage Guidelines](https://hpi.de/en/imprint/)). The logos are subject to copyright of the respective institutions.
