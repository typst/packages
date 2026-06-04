#import "@preview/supercharged-dhbw:2.0.0": *
#import "acronyms.typ": acronyms

#show: supercharged-dhbw.with(
  title: "Exploration of Typst for the Composition of a University Thesis",
  authors: (
    (name: "Max Mustermann", student-id: "7654321", course: "TIS21", course-of-studies: "IT-Security", company: (
      (name: "YXZ GmbH", post-code: "70435", city: "Stuttgart")
    )),
    (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
      (name: "ABC S.L.", post-code: "08005", city: "Barcelona", country: "Spain")
    )),
  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  language: "en", // en, de
  supervisor: (company: "John Appleseed"),
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Ravensburg Campus Friedrichshafen",
  // for more options check the package documentation (https://typst.app/universe/package/supercharged-dhbw)
)

// Edit this content to your liking

= Introduction

#lorem(100)

#lorem(100)

#lorem(100)

= Examples

#lorem(30)

== Acronyms

Use the `acr` function to insert acronyms, which looks like this #acr("HTTP").

#acrlpl("API") are used to define the interaction between different software systems.

#acrs("REST") is an architectural style for networked applications.

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

#figure(caption: "Image Example", image(width: 4cm, "assets/ts.svg"))

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