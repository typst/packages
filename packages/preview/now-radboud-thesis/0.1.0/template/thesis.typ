#import "@preview/now-radboud-thesis:0.1.0": radboud-thesis, appendix

#show: radboud-thesis.with(
  title: "Title",
  subtitle: "Subtitle",
  author: (
    name: "Author",
    student-number: "s1234567",
  ),
  supervisors: (("Supervisor", "dr. Dewey Duck"), ("Second reader", "prof. dr. Louie Duck")),
  abstract: [Template for Radboud University Bachelor's/Master's thesis

    Source code can be found at https://github.com/Jorritboer/radboud-thesis-typst.
  ],
  thesis-type: "Master's Thesis",
  study: "Computing Science",
  date: datetime.today(),
)

#outline()

= Introduction
#lorem(100)

Reference @reference

= Preliminaries
#lorem(100)

= Results
#lorem(100)

= Related Work
#lorem(100)

= Conclusion
#lorem(100)

#bibliography("bibliography.bib", style: "association-for-computing-machinery")

#show: appendix

= Proofs
#lorem(100)

