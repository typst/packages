#import "@preview/ioppub:0.1.0": *

#show: ioppub.with(
  title: "Article Title",
  keywords: (
    "IOP Publishing",
    "Typst",
    "Template",
  ),
  authors: (
    (
      name: (
        "John", // First name
        "Doe", // Last name
      ),
      institutions: ("1",),
      corresponding: true,
      orcid: "0000-0001-2345-6789",
      email: "john.doe@example.com",
    ),
    (
      name: (
        "Jane",
        "Rue",
      ),
      institutions: ("2",),
      orcid: "0000-0001-2345-6789",
      email: "jane.rue@example.com",
    ),
  ),
  institutions: (
    "1": [Department One, Institution One, City One, Country One],
    "2": [Department Two, Institution Two, City Two, Country Two],
  ),
  abstract: "Sample text inserted for illustration. Replace with abstract text. Your abstract should give readers a brief summary of your article. It should concisely describe the contents of your article, and include key terms. It should be informative, accessible and not only indicate the general scope of the article but also state the main results obtained and conclusions drawn. The abstract should be complete in itself; it should not contain undefined abbreviations and no table numbers, figure numbers, references or equations should be referred to. It should be suitable for direct inclusion in abstracting services and should not normally be more than 300 words.",
)

= Introduction

#lorem(50)
$ f_j^((k+1)) = f_j^((k)) product_i (g_i / sum_l H_(i l) f_l^((k)))^(lambda H_(i j)). $<eq:intro1>

Equation @eq:intro1 shows an example of an equation in the introduction @a2020.

#lorem(50):

- #lorem(10)
- #lorem(10)
- #lorem(10)

#lorem(50)

== Section
#lorem(40) @a2020 @b2019 @c2024.

=== Subsection
#lorem(40)

= Methodology

#lorem(40)

== Section
#lorem(150)
(See Fig. @fig:figure1).

#figure(
  image("images/typst-logo.svg"),
  caption: [All figures must have a caption. Provide a short description of the figure, including the key points illustrated by the image. The caption must also reference the source of the figure if the figure has been reused from elsewhere, including any permission statement required.],
) <fig:figure1>

#lorem(100)

== Section

#lorem(150)
(see Table @tab:table1).

#figure(
  table(
    columns: 4,
    table.header([Column heading], [Column heading], [Column heading], [Column heading]),
    [Data Row 1], [1.0], [1.5], [2.0],
    [Data Row 2], [2.0], [2.5], [3.0],
    [Data Row 3], [3.0], [3.5], [4.0],
    table.hline(),
  ),
  caption: [All tables must have a caption. Provide a short description of the table, including the key points illustrated by the data.],
) <tab:table1>

= Results and Discussion

#lorem(150) (see Fig.~@fig:figure2).

#figure(
  image("images/typst-logo.svg"),
  caption: [#lorem(20)],
  scope: "parent",
) <fig:figure2>

= Conclusion

#lorem(40)

+ #lorem(15)
+ #lorem(15)

Future work will focus on:
- #lorem(10)
- #lorem(10)


#heading([Acknowledgments], numbering: none)

This work was supported by the Example Society Grant No. 12345678.
The authors thank Dr. Example Collaborator for helpful discussions.


#heading([Data Availability], numbering: none)

The data that support the findings of this study are available from the corresponding author upon reasonable request.

// Load references from .bib file
// Uncomment and modify the path to your .bib file when you have references
#bibliography("ref.bib", style: "institute-of-physics-numeric")

#show: appendix

= Appendix

#lorem(20) (see Eq.~@eq:app-eq1).

$
  y = x^2
$ <eq:app-eq1>

= Appendix

#lorem(20) (see Eq.~@eq:app-eq2).

$
  y = exp(x/(2a))
$ <eq:app-eq2>
