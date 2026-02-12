#import "@preview/texst:0.1.1": paper, theorem, proof, nneq, caption_with_note

#show: doc => paper(
  title: [A Minimal Academic Paper],
  subtitle: [Demonstration of the texst Package],
  authors: (
    (name: [First Author]),
    (name: [Second Author]),
  ),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  abstract: [
    This is a minimal, generic example that demonstrates the package layout and
    theorem environments.
  ],
  doc,
)

#outline(title: [Contents])

#heading(level: 1)[Introduction]

This sample keeps content intentionally generic.

#heading(level: 1)[Core Examples]

#heading(level: 2)[Equation Example]

#nneq($
f(x) = alpha + beta x + epsilon
$)

#heading(level: 2)[Theorem Example]

#theorem[
For any real numbers $a$ and $b$, if $a = b$, then $a + 1 = b + 1$.
]

#proof[
Add 1 to both sides.
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

#heading(level: 1)[Appendix]

#heading(level: 2)[Additional Derivation]

This appendix section is included as an example of back matter.
