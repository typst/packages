#import "@preview/supercharged-dhbw:1.2.0": *

#let abstract = lorem(100)

#show: supercharged-dhbw.with(
  title: "Exploration of Typst for the Composition of a University Thesis",
  authors: (
    (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
      (name: "ABC AG", post-code: "08005", city: "Barcelona", country: "Spain")
    )),
    (name: "Max Mustermann", student-id: "7654321", course: "TIS21", course-of-studies: "IT-Security", company: (
      (name: "YXZ GmbH", post-code: "70435", city: "Stuttgart", country: "")
    )),
  ),
  language: "en", // en, de
  at-dhbw: false, // if true the company name on the title page and the confidentiality statement are hidden
  show-confidentiality-statement: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-acronyms: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-code-snippets: true,
  show-appendix: false,
  show-abstract: true,
  show-header: true,
  numbering-style: "1 of 1", // https://typst.app/docs/reference/model/numbering
  numbering-alignment: center, // left, center, right
  abstract: abstract, // displays the abstract defined above
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Ravensburg Campus Friedrichshafen",
  supervisor: "John Appleseed",
  date: datetime.today(),
  bibliography: bibliography("sources.bib"),
  logo-left: image("assets/logos/dhbw.svg"),
  // logo-right: image("assets/logos/company.svg"),
  // logo-size-ratio: "2:1" // ratio between the right logo and the left logo height (left-logo:right-logo) only the right logo is resized
) 

// Edit this content to your liking

= Introduction

#lorem(100)

#lorem(100)

#lorem(100)

= Examples

#lorem(30)

== Acronyms

Use the `acro` function to insert acronyms, which looks like this #acro("API").

#acro("AWS")

== Lists

Create bullet lists or numbered lists.

- These bullet
- points
- are colored

+ It also
+ works with
+ numbered lists!

== Figures and Tables

Create figures or tables like this:

=== Figures

#figure(caption: "Image Example", image(width: 4cm, "assets/images/ts.svg"))

=== Tables

#figure(caption: "Table Example", table(
  columns: (1fr, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*Area*], [*Parameters*],
  ),
  text("cylinder.svg"),
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],
  text("tetrahedron.svg"),
  $ sqrt(2) / 12 a^3 $,
  [$a$: edge length]
))<table>

== Code Snippets

Insert code snippets like this:

#figure(caption: "Codeblock Example", sourcecode[```typ
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```])

== References

Cite like this #cite(form: "prose", <iso18004>).
Or like this @iso18004.

You can also reference by adding `<ref>` with the desired name after figures or headings.

For example this @table references the table on the previous page.

= Conclusion

#lorem(100)

#lorem(120)

#lorem(80)