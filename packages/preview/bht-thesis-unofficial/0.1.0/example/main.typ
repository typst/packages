// For local development, replace the import below with:
// #import "../template/lib.typ": *
#import "@preview/bht-thesis-unofficial:0.1.0": *

#let kurzfassung = [
  Die Kurzfassung gibt ein kurzes und prägnantes Bild der gesamten Arbeit.
]

#let abstract = [
  This is a very good abstract.
]

#let ai-statement = [
  This thesis was authored with the assistance of Artificial Intelligence (AI).
]

#let acknowledgements = [
  Thanks to ...
]

#let declaration = [
  I hereby declare that I have written this thesis independently without outside help and that I have used no sources or aids other than those cited. Passages taken verbatim or in substance from other works are identified as such, with the sources indicated.

  #v(4cm)
  #line(length: 100%, stroke: 0.5pt)
  #v(-0.3em)
  #grid(
    columns: (1fr, 1fr),
    align: (left, right),
    text(size: 0.8em)[Date],
    text(size: 0.8em)[Signature],
  )
]

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  subtitle: "An Adequate Subtitle",
  name: "Toni Musterperson",
  student-id: "123456",
  date: "31 July 2026",
  degree: "Bachelor",
  // field: "Engineering",  // "Science" (B.Sc./M.Sc.) (default), "Engineering" (B.Eng./M.Eng.), "Arts" (B.A./M.A.)
  study-program: "Computer Science",
  department: "VI – Informatik und Medien",
  committee: (  // Shown on the cover in this order, entries with the same role share one header
    (role: "Advisor and First Examiner", name: "Prof. Dr. Kim Beispiel", institution: "Berliner Hochschule für Technik"),
    (role: "Second Examiner", name: "Prof. Dr.-Ing. Robin Muster", institution: "Berliner Hochschule für Technik"),
  ),
  pre-toc: (  // Front-matter sections shown before the table of contents
    (title: "Kurzfassung", body: kurzfassung),
    (title: "Abstract", body: abstract, own-page: false),  // Continues on the Kurzfassung page
    (title: "Statement on the Use of AI Tools", body: ai-statement),
    (title: "Acknowledgements", body: acknowledgements),
    (title: "Plagiarism Statement", body: declaration),  // "Erklärung" in German theses
  ),
  // pre-body: [  // Optional content to be placed between the table of contents and the main body
  //   #list-of-figures()
  //   #list-of-tables()
  // ],
  bibliography: bibliography("references.bib"),
  appendix: [  // Optional appendix, rendered after the bibliography with A.1.1.1 numbering
    = Additional Material <app-material>
    #lorem(50)
  ],
  post-body: [  // Optional back matter at the very end
    #list-of-figures()
    #list-of-tables()
  ],
  // lang: "de",  // Switch all labels to German defaults
  // labels: (date-label: "Handed in on"),  // Override any label
  // typography: (font: "STIX Two Text", body-text-size: 12pt),
  // layout: (
  //   margin: (left: 35mm, right: 35mm, top: 30mm, bottom: 30mm),
  //   chapter-pagebreak: false,
  //   for-print: true,  // Optimize for printing (blank pages before odd-numbered ones)
  //   toc-depth: 2,
  //   show-header: false,
  // ),
  // appearance: (
  //   accent-color: bht-colors.blue,
  //   bht-logo-width: 2.25cm,
  // ),
)

= Introduction
#lorem(80)

As shown by Doe and Smith @example2025, this approach is effective.

#figure(
  rect(width: 50%, height: 3cm, fill: bht-colors.turquoise),
  caption: [An example figure],
) <fig-example>

== In this paper
#lorem(20)

=== Contributions
As @fig-example and @tab-example show, #lorem(10)

#figure(
  table(
    columns: 3,
    table.header[Approach][Speed][Quality],
    [Ours], [fast], [high],
    [Baseline], [slow], [low],
  ),
  caption: [An example table],
) <tab-example>

==== Really Small Stuff
#lorem(20)

= Related Work
Supplementary details can be found in @app-material.

#lorem(500)
