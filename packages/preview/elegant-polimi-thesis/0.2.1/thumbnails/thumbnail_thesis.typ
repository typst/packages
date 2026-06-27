#import "@preview/elegant-polimi-thesis:0.2.1": *

#show: polimi-thesis.with(
  title: "Thesis Title",
  author: "Name Surname",
  supervisor: "Prof. Supervisor",
  cosupervisor: "Prof. Cosupervisor",
  tutor: "Prof. Tutor",
  academic-year: "2025-2026",
  frontispiece: sys.inputs.at("frontispiece"),
)
