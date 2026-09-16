#import "@preview/bizu-sheet:0.1.0": *

#show: cheat_sheet.with(
  title: "My Revision Sheet",
  subtitle: "Quick review",
  author: "Your name",
)

= First topic

#card(title: "Summary", tone: "info")[
  Write the key idea here.
]

#formula(
  title: "Important formula",
  $ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a) $,
)

#checklist((
  [Review the main definition.],
  [Check the units or conditions.],
  [Solve one application problem.],
))
