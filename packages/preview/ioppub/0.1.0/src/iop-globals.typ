#let default-font = (
  text: ("STIX Two Text", "Times New Roman", "Charis SIL", "New Computer Modern"),
  header: ("Carlito", "Arial", "New Computer Modern"),
  math: ("XITS Math", "STIX Two Math", "New Computer Modern Math"),
  homepage: ("Roboto", "New Computer Modern"),
)

// Default paper information
#let paper-info-default = (
  paper-id: [123456],
  volume: "XXX",
  year: datetime.today().year(),
  issn: [0167-1234],
  received: [xxxxxx],
  accept: [xxxxxx],
  published: [xxxxxx],
  doi: "https://doi.org/XXXX/XXXX",
)

#let isappendix = state("isappendix", false)