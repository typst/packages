#import "@preview/modern-tud-thesis:1.0.0": *

// optional (en and de possible):
// #set text(lang: "de")

#show: modern-tud-thesis.with(
  target: "print", // alternative values: "digital" or "print-alternating"
  title: "Title of your paper",
  thesis-type: "Master thesis",
  faculty: "Faculty of example",
  chair: "Chair of example",
  authors: (
    (
      name: "Surname, Name",
      birthdate: datetime(year: 2000, month: 1, day: 1),
      birthplace: "Dresden",
      course: "Example Course"
    ),
    // ...
  ),
  supervisors: (
    "Prof. Dr.-Ing. First Supervisor ",
    // ...
  ),
  submissionplace: "Dresden",
  // optional (default to today):
  // submissiondate: datetime(day: 1, month: 1, year: 2000),
  abstract: "Abstract",
  // optional:
  // number-of-attachments: 1,
  // optional:
  // appearance: (
  //   titlepage: "shape-1",
  //   ...
  // )
)

= Main content
// It is recommended to use `note-figure` for figure source attribution
#note-figure(
  table(
    columns: 2,
    [A], [B]
  ),
  caption: "A and B",
  note: "Source: Own table"
)

#show: backmatter
// backmatter content (remove if not needed)

#declaration-of-originality[
  // your declaration-of-originality here (remove if not needed)
]

#show: appendix
// Appendix (remove if not needed)