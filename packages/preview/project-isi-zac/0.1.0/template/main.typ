#import "@preview/project-isi-zac:0.1.0": config

#show: config.with(
  display : ("title-page", "toc"), // pass the arguments you want to dispaly  horizon
  title: [Crazy Good Thesis Title],
  // Add affiliations to the authors
  authors: (
    "Author 1",
    "Author 2",
  ),
  uni-info : (
    department: [Some Department],
    university: [University name],
    faculty: [Faculty Name],
    academic_year: "2024/2025"
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"),
  // This is to make the template more general
  img: rect(width: 20em, height: 10em, fill: luma(240))[
    #align(center + horizon)[      #text(size: 2em, weight: "black")[Image]
    ]
  ],
)

// Example Usa
#include "chapters/chapter-1.typ"
#include "chapters/chapter-2.typ"
#include "chapters/conclusions.typ"

// ------------- Display Bibliography ------------- 

#bibliography("refs.bib", style: "apa")
