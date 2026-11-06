# HPI Thesis Template

This template is for HPI students writing their Bachelor's or Master's thesis.

**Note:** This is an unofficial template; current university guidelines take precedence.

## Getting Started

```bash
typst init @preview/cleanified-hpi-thesis
```

## Configuration

An example configuration is located in [`example/`](./example/main.typ).

```typst
#import "@preview/cleanified-hpi-thesis:0.3.0": *

#show: project.with(
  title: "My Thesis",
  translation: "Meine Abschlussarbeit",
  name: "Max Mustermann", date: "17. Juli 2026", type: "Master",
  study-program: "IT-Systems Engineering", chair: "Data-Intensive Internet Computing",
  professors: ("Prof. Erika Mustermann",), advisors: ("Dr. Karla Musterfrau",),
  // lang: "de",
  // typography: (font: "STIX Two Text", body-text-size: 12pt),
  // layout: (for-print: true, toc-depth: 2),
  // appearance: (accent-color: rgb("#B1063A")),
  // labels: (declaration-city: "Berlin"),
)

#abstract[English abstract.]
#abstract-de[Deutsche Zusammenfassung.]
#acknowledgements[Thanks to ...]
#acronyms[API -- Application Programming Interface]
#ai-declaration[Describe your use of generative AI tools.]

= Introduction
Write your thesis here.

#bibliography("references.bib")

#appendix[
  == Additional Results
]
```

## Logo Usage

Please note the logo usage guidelines of University of Potsdam ([UP Logo Usage Guidelines](https://www.uni-potsdam.de/fileadmin/projects/zim/files/MMP/PDF_Dateien_MMP/250509-Leitfaden_DigitalPrint-web.pdf)) and Hasso Plattner Institute ([HPI Logo Usage Guidelines](https://hpi.de/en/imprint/)). The logos are subject to copyright of the respective institutions.

## Changelog

| Version tag | Breaking | Core changes |
| --- | --- | --- |
| `0.3.0` | Yes | On-demand section markers, native bibliography, appendices, and layout refinements. |
| `0.2.0` | Yes | Tuple-based professors and advisors, acronyms, and AI declarations. |
| `0.1.0` | Yes | Package rename and grouped configuration API. |
| `0.0.1` | No | Initial HPI thesis template. |
