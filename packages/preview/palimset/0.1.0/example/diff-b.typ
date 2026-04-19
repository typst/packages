#import "@preview/charged-ieee:0.1.4": ieee
#import "@preview/cetz:0.4.2" as cetz

#show: ieee.with(
  title: [Complex Document Example],
  authors: (
    (
      name: "Example Author",
      department: [Department of Examples],
      organization: [Example University],
      location: [Example City, EX 12345, Country],
      email: "diff-doc@example.edu"
    ),
  ),
  abstract: [
    This is an example of a complex document created using the typographic markup language.
    It includes sections such as Abstract, Introduction, Numerical Methods, Results, Discussion, and Conclusion, along with mathematical equations and figures.
  ],
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"),
)

= Introduction

This section serves as an introduction to a largely fictional study.
The purpose of this document is not to address a real scientific problem, but to provide a clear and well-structured example text for testing document comparison tools.
Despite its meaningless content, the writing style follows common conventions found in academic publications.

The reader is encouraged not to search for physical interpretations or deep mathematical rigor in the following sections.


= Example of Mathematical Expressions

In this section, we present several mathematical expressions that resemble those commonly used in scientific articles.

A representative equation is given by
$
  f(x) = alpha x^2 + beta x + gamma
$
where $alpha$, $beta$, and $gamma$ are arbitrary constants with no particular physical meaning.

Another example involves a summation:
$
  S = sum_(k=1)^N k^2
$
which is introduced solely to demonstrate the appearance of inline
and displayed mathematical formulas in a document.

= Example of Figures

Figures are essential components of technical documents,
even when the data being visualized are entirely artificial.

#figure(
  cetz.canvas({
    import cetz.draw: *

    merge-path({
      for x in range(80).map(n => 0.1*n){
        line((x, calc.sin(x)), (x+0.1, calc.sin(x+0.1)))
      }
    })
  }),
  caption: [figure sample]
)<fig-sample>

@fig-sample illustrates a hypothetical relationship between two variables.
Although the plotted curve appears smooth and well-behaved, it is generated using simple mathematical functions without any empirical basis.

All figures included in this document should be interpreted
as placeholders rather than meaningful results.

= Conclusion

This document has presented a fabricated example of an academic-style text.
It included an introduction, mathematical expressions, a brief description of figures, and a concluding section.

The primary goal was to create a structured document suitable for testing diff tools and document comparison workflows.
Future revisions may introduce small textual changes in order to generate visible and instructive differences.
