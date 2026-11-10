# Template for the _JUTI: Jurnal Ilmiah Teknologi Informasi_

The [_JUTI: Jurnal Ilmiah Teknologi Informasi_](https://juti.if.its.ac.id) focuses on publishing original research, communication, and notes resulting from original and high-quality research. The journal also invites well-known researchers to write review papers. JUTI accepts high-quality papers in the field of engineering, science, and technology (informatics/information technology). It is published biannually (January and July) and is available in an open-access electronic version, with P-ISSN 1412-6389 and E-ISSN 2406-8535.

## About the Journal

JUTI: Jurnal Ilmiah Teknologi Informasi (Scientific Journal of Information Technology) is published by the Department of Informatics, Institut Teknologi Sepuluh Nopember (ITS). It focuses on publishing original research, communication, and notes resulting from original and high-quality research, and also invites well-known researchers to write review papers, in the field of engineering, science, and technology.

The scope of JUTI encompasses, but is not limited to:

- Information Technology
- Computer Science
- Information System
- Computer Network
- Software Engineering
- Computer Vision

The journal is published biannually (January and July) and is fully open-access -- free of charge for both submission and publication, with no fees for authors or readers.

### Accreditation

JUTI has been re-accredited by the Ministry of Research, Technology, and Higher Education of the Republic of Indonesia as Sinta-3 (decree No. 21/E/KTP/2016, dated July 9, 2016, effective from Volume 14 Number 1, 2016), renewed through decree No. 164/E/KPT/2021, dated December 27, 2021.

### Indexing & Abstracting

JUTI is indexed by DOAJ, Cross Ref, Google Scholar, Sinta, Garuda (Garda Rujukan Digital), Dimensions, and Scilit.

## Usage

Start a new project with this template:

```
typst init @preview/juti:0.1.1
```

Or import it directly in an existing document:

```typ
#import "@preview/juti:0.1.1"

#show: juti.template.with(
  title: "Your Paper Title",
  authors: authors,
  corresponding-ref: 0,
  corresponding-email: "first-author@email.com",
  institutions: institutions,
  abstract: [...],
  keywords: ([Keyword1], [Keyword2], [Keyword3], [Keyword4]),
  bib: bibliography("references.bib"),
)
```

## Authors and contributions

Authors and their [CRediT](https://credit.niso.org/) contribution roles are declared with `juti.init-authors`:

```typ
#let authors = juti.init-authors((
  (
    name: "First Alpha Author",
    institution-ref: 0,
    contribution-refs: (0, 1, 2, 5, 6, 7, 8, 10, 13),
  ),
  (
    name: "Second Beta Author",
    institution-ref: 0,
    contribution-refs: (6, 9, 11),
  ),
))
```

Each entry in `contribution-refs` is an index into the standard CRediT taxonomy (0: Conceptualization, 1: Methodology, 2: Software, 3: Validation, 4: Formal analysis, 5: Investigation, 6: Resources, 7: Data Curation, 8: Writing -- Original Draft, 9: Writing -- Review & Editing, 10: Visualization, 11: Supervision, 12: Project Administration, 13: Funding Acquisition).

`institution-ref` points into the `institutions` array:

```typ
#let institutions = (
  (
    name: "Department and institution name of authors",
    address: "Address of the first institution",
  ),
)
```

## Template structure

Running `typst init` scaffolds:

- `main.typ` -- example paper using the template, including sections, table/figure/equation examples, and CRediT statement.
- `setup.typ` -- article metadata (volume, number, DOI, received/revised/accepted/online dates, start page).
- `references.bib` -- bibliography file (IEEE style is used by default).

## Links

- Journal website: https://juti.if.its.ac.id
- License: MIT
