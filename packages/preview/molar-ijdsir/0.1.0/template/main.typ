#import "@preview/molar-ijdsir:0.1.0": manuscript

#show: manuscript.with(
  title: [Title of Your Paper in Title Case],
  authors: (
    (name: "First Author", aff: 1),
    (name: "Second Author", aff: 1),
    (name: "Third Author", aff: 2),
  ),
  affiliations: (
    "Department and Designation, College and University, City and Country",
    "Department and Designation, College and University, City and Country",
  ),
  email: "first.author@example.com",
  corresponding: (
    name: "First Author",
    address: "Department and Designation, College and University, City and Country.",
    phone: "+00 0000000000",
    email: "first.author@example.com",
  ),
  conflicts: "Nil",
  volume: "1", issue: "1", period: "January – February - 2026", pages: "01 -03", year: "2026",
  // logo: image("logo.png"),   // optional journal logo in the masthead
  keywords: ("First keyword", "Second keyword", "Third keyword"),
  abstract: [
    State the aim of the study, the materials and methods used, the main results and the
    conclusion in a single paragraph. The abstract is set in the two-column body, directly after
    the title block.
  ],
)

= Introduction
Write the body of the paper here. Text is set in Times New Roman 11 pt with 1.5 line spacing in
two columns, and lines are broken the way Microsoft Word breaks them, so the result matches the
journal's Word template.

Level-one headings are numbered automatically ("1.", "2.", …). Level-two headings use letters.

= Materials and Methods
== Study Design
Describe the study design. Cite references in Vancouver style as [1].

== Statistical Analysis
Describe the statistical tests used.

= Results
#figure(
  table(
    columns: 3,
    [*Group*], [*n*], [*Mean ± SD*],
    [Control], [20], [12.4 ± 1.8],
    [Test], [20], [15.1 ± 2.2],
  ),
  caption: [Example table; the caption is placed above the table.],
)

= Discussion
Discuss the results in the context of previous studies.

= Conclusion
Summarise the main findings.

#heading(numbering: none)[References]
[1]. Author A, Author B. Title of the article. Journal Abbreviation. 2026;1(1):1-10.

[2]. Author C. Title of the book. 2nd ed. City: Publisher; 2026.
