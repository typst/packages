#import "@preview/touying-ambrosia:0.1.0": *
#import "project-brand.typ": project-theme

// Edit these values in your IDE. No command-line inputs are required.
// project-theme adds only Ambrosia's own logo; ambrosia-theme starts unbranded.
#let flavor = "minimal" // simple | cambridge | darmstadt | dewdrop | stargazer | portico
#let palette = "ocean" // any built-in palette or ambrosia-palette(...) descriptor
#show: project-theme.with(
  flavor: flavor, palette: palette,
  navigation-buttons: false, // true adds transparent PDF navigation buttons
  config-info(title: [A Research Presentation], subtitle: [Methods, Evidence, And Perspectives],
    author: [Alex Researcher], email: "alex@example.org",
    short-author: [A. Researcher], short-title: [Research Presentation],
    date: datetime.today(),
  ),
)
#title-slide()
#outline-slide()
= Introduction
== A Clear Result
// Change style and kind to explore independent geometry and meaning.
#ambrosia-block(style: "poster", kind: "success", title: [Observation])[
  State one useful finding and explain its evidence.
  #pause // creates another animation frame of this logical slide
  An additional qualification.
]
== A Reference
A useful source #footcite(<knuth84>). Ordinary citations work too: @knuth84.
#bibliography-slide("references.bib")
#ending-slide(title: [Questions?])[]
#show: appendix
== Supporting Detail
Extra evidence remains visible without increasing the main slide total.
