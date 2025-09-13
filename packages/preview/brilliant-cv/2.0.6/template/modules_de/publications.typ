// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvPublication
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)


#cvSection("Veröffentlichungen")

#cvPublication(
  bib: bibliography("../src/publications.bib"),
  keyList: (
    "smith2020",
    "jones2021",
    "wilson2022",
  ),
  refStyle: "apa",
)
