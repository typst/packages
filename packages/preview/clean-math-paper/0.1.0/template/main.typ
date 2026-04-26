#import "@preview/clean-math-paper:0.1.0": *

#let date = datetime.today().display("[month repr:long] [day], [year]")
#show: template.with(
  title: "Typst template for mathematical papers",
  authors: (
    (name: "Author 1", affiliation-id: 1, orcid: "0000-0000-0000-0000"),
    (name: "Author 2",  affiliation-id: "2,*"),
  ),
  affiliations: (
    (id: 1, name: "Affiliation 1, Address 1"),
    (id: 2, name: "Affiliation 2, Address 2"),
    (id: "*", name: "Corresponding author")
  ),
  date: date,
  heading-color: rgb("#2e44a6"),
  link-color: rgb("#12472b"),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: lorem(30),
  keywords: ("First keyword", "Second keyword", "etc."),
  AMS: ("65M70", "65M12", )
)

= Introduction
#lorem(20)

= Equations

The template uses #link("https://typst.app/universe/package/i-figured/")[`i-figured`] for labeling equations. Equations will be numbered only if they are labelled. Here is an equation with a label:

$
  sum_(k=1)^n k = (n(n+1)) / 2
$<equation>

We can reference it by `@eq:label` like this: @eq:equation, i.e., we need to prepend the label with `eq:`. The number of an equation is determined by the section it is in, i.e. the first digit is the section number and the second digit is the equation number within that section.

Here is an equation without a label:

$
  exp(x) = sum_(n=0)^oo (x^n) / n!
$

As we can see, it is not numbered.

= Theorems

The template uses #link("https://typst.app/universe/package/great-theorems/")[`great-theorems`] for theorems. Here is an example of a theorem:

#theorem(title: "Example Theorem")[
  This is an example theorem.
]<th:example>
#proof[
  This is the proof of the example theorem.
]

We also provide definitions, lemmas, remarks, examples, and questions among others. Here is an example of a definition:

#definition(title: "Example Definition")[
  This is an example definition.
]

Similar as for the equations, the numbering of the theorems is determined by the section they are in. We can reference theorems by `@label` like this: @th:example.

To get a bibliography, we also add a citation @Cooley65.

#lorem(50)

#bibliography("bibliography.bib")

// Create appendix section
#show: appendices
=

If you have appendices, you can add them after `#show: appendices`. The appendices are started with an empty heading `=` and will be numbered alphabetically. Any appendix can also have different subsections.

== Appendix section

#lorem(100)
