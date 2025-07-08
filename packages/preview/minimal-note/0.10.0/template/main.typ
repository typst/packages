#import "@preview/minimal-note:0.10.0": *

#show: minimal-note.with(
  title: [Paper Title],
  author: [Your Name],
  date: datetime.today().display("[month repr:long], [year]"),
)

= Basic Probability Laws

== Chain Rule
<chain-rule>

For two events $A$ and $B$, the *Chain Rule* states $ PP(A inter B) = PP(B bar A) PP(A). $
== Test

Now, consider an application of the Chain Rule, mentioned in @chain-rule:

#green_box("Green Box", lorem(100))
#orange_box("Orange Box", lorem(100))