#import "@preview/versatile-apa:7.1.3": *

// Document titles should be formatted in title case (https://capitalizemytitle.com/)
#let doc-title = [American Psychological Association (APA) Style Template for Typst]

#show: versatile-apa.with(
  title: doc-title,

  // authors with different affiliations
  // authors: (
  //   (
  //     name: [Author Name 1],
  //     affiliations: ("AF-1", "AF-2"),
  //   ),
  //   (
  //     name: [Author Name 2],
  //     affiliations: ("AF-3",),
  //   ),
  //   (
  //     name: [Author Name 3],
  //     affiliations: ("AF-4", "AF-5", "AF-6"),
  //   ),
  // ),
  // affiliations: (
  //   (
  //     id: "AF-1",
  //     name: [Affiliation Department 1],
  //   ),
  //   (
  //     id: "AF-2",
  //     name: [Affiliation Department 2],
  //   ),
  //   (
  //     id: "AF-3",
  //     name: [Affiliation Department 3],
  //   ),
  //   (
  //     id: "AF-4",
  //     name: [Affiliation Department 4],
  //   ),
  //   (
  //     id: "AF-5",
  //     name: [Affiliation Department 5],
  //   ),
  //   (
  //     id: "AF-6",
  //     name: [Affiliation Department 6],
  //   )
  // ),

  // authors with shared affiliations
  authors: (
    (
      name: [Author Name 1],
      affiliations: ("AF-1", "AF-2", "AF-3"),
    ),
    (
      name: [Author Name 3],
      affiliations: ("AF-1", "AF-2", "AF-3"),
    ),
  ),
  affiliations: (
    (
      id: "AF-1",
      name: [Affiliation Department 1],
    ),
    (
      id: "AF-2",
      name: [Affiliation Department 2],
    ),
    (
      id: "AF-3",
      name: [Affiliation Department 3],
    ),
  ),

  // custom-authors: [Author Name],
  // custom-affiliations: [Affiliation Department, Affiliation Name],

  // Student-specific fields
  course: [Course Code: Course Name],
  instructor: [Instructor Name],
  // At the moment only supports English
  due-date: datetime.today().display(),

  // Professional-specific fields
  running-head: [running head],
  author-notes: [
    #include-orcid([Author Name], "0000-0000-0000-0000")

    #lorem(50)
  ],
  keywords: ("APA", "template", "Typst"),
  abstract: lorem(100),

  // Common fields
  font-family: "Libertinus Serif",
  font-size: 12pt,
  region: "us",
  language: "en",
  paper-size: "us-letter",
  implicit-introduction-heading: false,
  abstract-as-description: true,
)

#outline()
#pagebreak()
#outline(target: figure.where(kind: table), title: [Tables])
#pagebreak()
#outline(target: figure.where(kind: image), title: [Figures])
#pagebreak()
#outline(target: figure.where(kind: math.equation), title: [Equations])
#pagebreak()
#outline(target: figure.where(kind: raw), title: [Listings])
#pagebreak()

= #doc-title // Implicit introduction heading level 1, remove if implicit-introduction-heading is true
#include "sections/introduction.typ"

#pagebreak()
#include "sections/lists.typ"

#pagebreak()
#include "sections/quotes.typ"

#pagebreak()
#include "sections/computer-code.typ"

#pagebreak()
#include "sections/math.typ"

#pagebreak()
#bibliography(
  "bibliography/ref.bib", // or ref.yml
  style: "csl/apa.csl",
  full: true,
  title: auto,
)

#show: appendix

#include "sections/appendix.typ"
