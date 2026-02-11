#import "@preview/texst:0.1.0": paper, theorem, proof

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

#heading(level: 1, outlined: false)[Introduction]

Start your paper here.

#heading(level: 1, outlined: false)[Main Result]

#theorem[
State your main theorem or proposition.
]

#proof[
Add your proof or argument.
]
