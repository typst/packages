//#import "../lib.typ": *
#import "@preview/grotesk-cv:0.1.0": *

#show: layout

#set list(marker: [‣])

#createHeader(usePhoto: true)

#grid(
  columns: (71%, 25%),
  gutter: 20pt,
  stroke: none,
  stack(
    spacing: 20pt,
    importSection("profile"),
    importSection("experience"),
    importSection("education"),
    //importSection("references"),
  ),
  stack(
    spacing: 20pt,
    importSection("skills"),
    importSection("languages"),
    //importSection("personal"),
    importSection("other_experience"),
    importSection("references")
  ),
)
