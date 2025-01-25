# modern-report-umfds

A template for writing reports for the Faculty of Sciences of the University of Montpellier.

Basic usage:

```typst
#import "@preview/modern-report-umfds:0.1.0": umfds

#show: umfds.with(
  title: [Your report title],
  abstract: [
    Your abstract, optional
  ],
  authors: (
    "Author 1",
    "Author 2",
    "Author 3",
    "Author 4"
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"), // or any string
  bibliography: bibliography("refs.bib", full: true), // optional
  lang: "en", // or "fr"
)

// Your report content
```
