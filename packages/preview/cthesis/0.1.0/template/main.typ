#import "@preview/cthesis:0.1.0": cth-thesis, appendix, caption

#set text(lang: "en")

#show: cth-thesis.with(
  title: "Unofficial Thesis Template for Chalmers University of Technology",
  type: "master", // or "bachelor"
  gu: true,
  subtitle: "Optional Subtitle",
  authors: ("First Author", "Second Author"),
  program: "[program]",
  department: "[department]",
  abstracts: (
    en: lorem(75),
    sv: lorem(75),
  ),
  keywords: ("chalmers", "typst", "thesis", "template"),
  supervisors: ("[supervisor's name]", ),
  examiner: "[examiner's name]",
  advisor: "[optional advisor's name]",
  co-examiner: "[optional co-examiner's name]",
  cover: (
    image: [],
    description: "[optional cover image]",
  ),
  preface: lorem(75),
  acknowledgments: lorem(75),
  year: datetime.today().year(),
  abbreviations: (
    "CTH" : "Chalmers Tekniska Högskola",
    "GU": "Göteborgs Universitet",
  ),
  nomenclature: (
    "Category A": (
      "A1": lorem(5),
      "A2": lorem(5),
    ),
    "Category B": (
      "B1": lorem(5),
      "B2": lorem(5),
    ),
  ),
  print: false, 
)

= Introduction
#lorem(30)

== Figures
#figure(
  rect(width: 50%, height: 100pt, stroke: (dash: "dashed")),
  caption: caption(
    [Example figure with a long description and reference @ChalmersUniversityWebsite.], 
    [Example figure with a short description.]
  )
)

== Tables
#figure(
  table(
    columns: 2,
    [*Column A*], [*Column B*],
    [1], [#lorem(5)],
    [2], [#lorem(6)],
  ),
  caption: "Example table"
)

#bibliography("references.yaml")

#show: appendix
= Appendix
