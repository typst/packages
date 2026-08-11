// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-publication


#cv-section("Publications")

#cv-publication(
  bib: bibliography("../assets/publications.bib"),
  key-list: (
    "smith2020",
    "jones2021",
    "wilson2022",
  ),
  ref-style: "apa",
)
