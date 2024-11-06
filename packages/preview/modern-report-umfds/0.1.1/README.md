# modern-report-umfds

A template for writing reports for the Faculty of Sciences of the University of Montpellier.

Basic usage:

```typst
#import "@preview/modern-report-umfds:0.1.1": umfds

#show: umfds.with(
  title: [Your report title],
  authors: (
    "Author 1",
    "Author 2",
    "Author 3",
    "Author 4"
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"), // or any string
  img: image("cover.png"), // optional
  abstract: [
    Your abstract, optional
  ],
  bibliography: bibliography("refs.bib", full: true), // optional
  lang: "en", // or "fr"
)

// Your report content
```
