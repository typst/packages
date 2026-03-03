#import "@preview/elegant-polimi-thesis:0.2.0": *

#show: polimi-thesis.with(
  title: "Thesis Title",
  author: "Name Surname",
  advisor: "Advisor",
  coadvisor: "Coadvisor",
  tutor: "Tutor",
  academic-year: "2025-2026",
  cycle: "XXV",
  chair: none,
  frontispiece: sys.inputs.at("frontispiece"),
)
