# modern-report-umfds

A template for writing reports for the Faculty of Sciences of the University of Montpellier.

Basic usage:

```typst
#import "@preview/modern-report-umfds:0.1.2": umfds

#show: umfds.with(
  title: [Your report title],
  authors: (
    "Author 1",
    "Author 2",
    "Author 3",
    "Author 4"
  ),
  department: [Some Department], // optional
  date: datetime.today().display("[day] [month repr:long] [year]"), // optional
  img: image("cover.png"), // optional
  abstract: [
    Your abstract, optional
  ],
  full: false, // if the cover page should take all the first page (true by default)
  lang: "en", // or "fr"
)

// Your report content
```
