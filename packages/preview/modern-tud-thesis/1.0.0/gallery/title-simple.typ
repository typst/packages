#import "@preview/modern-tud-thesis:1.0.0": *

#show: modern-tud-thesis.with(
  title: "Title of your paper",
  thesis-type: "Master thesis",
  faculty: "Faculty of example",
  chair: "Chair of example",
  authors: (
    (
      name: "Surname, Name",
      birthdate: datetime(year: 2000, month: 1, day: 1),
      birthplace: "Dresden"
    ),
    // ...
  ),
  supervisors: (
    "Prof. Dr.-Ing. First Supervisor ",
    // ...
  ),
  submissionplace: "Dresden",
  abstract: none,
  appearance: (
    bibliography: false,
    outlines: false
  )
)