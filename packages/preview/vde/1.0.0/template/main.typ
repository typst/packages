#import "@preview/vde:1.0.0": vde
//#import "../lib.typ": vde

#show: vde.with(
  title: [Test],
  authors: (
    (name: "Max Mustermann", affiliation: "1"),
    (name: "Erika Musterfrau", affiliation: "1,2")
  ),
  affiliations: (
    (id: "1", name: "University"),
    (id: "2", name: "Company")
  ),
  email: [{max,erika}\@university.de, erika\@company.de],
  lang: "en",
  abstract: [#lorem(100)],
)

= Introduction <intro>
#lorem(150)

== Subsection

In @intro we discussed already a lot. #lorem(150)

= Tables

@tab shows a table 
#lorem(150)

#figure(
  table(
    columns: 3,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  ),
  caption: [Caption],
  placement: top
) <tab>

== Subsection
#lorem(200)
=== Subsubsection
#lorem(100)
=== Subsubsection
#lorem(100)

= Pictures
#lorem(100)

#figure(
  image("image.jpg", width: 100%),
  caption: [A curious figure.], 
  placement: top
)

= Acknowledgements <nonumber>
The paper @henpat_19 is a very interesting paper.
#lorem(50)


#bibliography("library.bib")