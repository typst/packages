#let default-font = (
  text: "Charis SIL",
  math: "STIX Two Math",
  homepage: "Roboto",
)

// Licence information
#let cc-by = (
  name: "CC BY",
  url: "https://creativecommons.org/licenses/by/4.0/",
)

// Default paper information
#let paper-info-default = (
  paper-id: [123456],
  volume: 130,
  year: datetime.today().year(),
  issn: [0167-1234],
  received: [23 june 2024],
  revised: [23 june 2025],
  accept: [10 december 2025],
  online: [01 september 2025],
  doi: "https://doi.org/10.1016/j.mssp.2025.1234567",
  open: none
)

#let isappendix = state("isappendix", false)