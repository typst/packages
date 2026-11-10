// Imports
#import "@preview/brilliant-cv:3.1.1": cv-section, cv-publication


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
