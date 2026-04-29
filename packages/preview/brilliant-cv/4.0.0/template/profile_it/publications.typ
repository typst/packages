// Imports
#import "@preview/brilliant-cv:4.0.0": cv-publication, cv-section


#cv-section("Pubblicazioni")

#cv-publication(
  bib: bibliography("../assets/publications.bib"),
  key-list: (
    "smith2020",
    "jones2021",
    "wilson2022",
  ),
  ref-style: "apa",
)
