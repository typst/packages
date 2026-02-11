#import "./src/lib.typ": paper, theorem, proof, caption_with_note, nneq

#show: doc => paper(
  title: [A Generic Research Paper],
  subtitle: [A LaTeX-Like Typst Template Demo],
  authors: (
    (name: [First Author]),
    (name: [Second Author]),
  ),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  abstract: [
    This document demonstrates the texst package with neutral placeholder content.
    It is intentionally free of project-specific or personal information.
  ],
  doc,
)

#heading(level: 1, outlined: false)[Introduction]

This sample illustrates how to structure an academic manuscript.

#heading(level: 2, outlined: false)[Equation Example]

#nneq($
f(x) = alpha + beta x + epsilon
$)

#heading(level: 2, outlined: false)[Theorem Example]

#theorem[
If two quantities are equal, adding the same constant to each preserves equality.
]

#proof[
Suppose $a=b$. For any constant $c$, adding $c$ to both sides gives $a+c=b+c$.
]

#figure(
  table(
    columns: 3,
    [Variable], [Estimate], [Std. Error],
    [Intercept], [0.42], [0.11],
    [Treatment], [0.18], [0.07],
  ),
  caption: caption_with_note(
    [Illustrative Regression Output],
    [Values are placeholders for demonstration only.],
  ),
)
