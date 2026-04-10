#import "@preview/texst:0.1.2": paper, theorem, proof

#show: doc => paper(
  title: [Paper Title],
  subtitle: [Optional Subtitle],
  authors: (
    (name: [Author One]),
    (name: [Author Two]),
  ),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  abstract: [
    Write a concise abstract summarizing your research question, method, and findings.
  ],
  doc,
)

#outline(title: [Contents])

#heading(level: 1)[Introduction]

Start your paper here.

#heading(level: 1)[Main Result]

#theorem[
State your main theorem or proposition.
]

#proof[
Add your proof or argument.
]

#heading(level: 1)[Appendix]

#heading(level: 2)[Additional Material]

Place supplementary derivations, robustness checks, or extended tables here.
