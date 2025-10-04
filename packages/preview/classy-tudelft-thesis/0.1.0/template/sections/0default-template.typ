#import "@preview/classy-tudelft-thesis:0.1.0": *
#import "@preview/physica:0.9.6": *
#import "@preview/unify:0.7.1": num, numrange, qty, qtyrange
#import "@preview/zero:0.5.0"


= Introduction

This chapter summarizes the extra features available in this template.

== Packages included
When first importing this template (during ```typ #import "@preview/classy-tudelft-thesis:0.1.0": *```)
at the top of `main.typ`, several imports occur. These are:
- `wrap-it`, version `0.1.1`. The function here are used, and slightly modified for proper caption sizing.
- `equate`, version `0.3.1`. Is imported to enable multi-line equation numbering out of the box, and sets the defaults ```typc  show: equate.with(breakable: false, sub-numbering: false)```. For more information, please visit the documentation of `equate`.

In addition to these "included" imports, at the top of `main.typ`, the following packages are also imported:
```typc
// Physics-reltated tools for equations
#import "@preview/physica:0.9.6": *
// Specifying quantities and units
#import "@preview/unify:0.7.1": num, numrange, qty, qtyrange
// Formatting of uncertainties
#import "@preview/zero:0.5.0"

```
For more imformation on these packages, please consult their documentation.

== Equations

Here follows a small overview of equation-related behaviour in this template.

For example, here is a new paragraph containing two aligned equations:
$
  e^(pi i) & = -1 #<eulers_formula> \
    (n+1)! & = integral_0^infinity t^n e^(-t) dif t #<cauchy_factorial>
$
Here @eulers_formula is Euler's formula, and @cauchy_factorial is Cauchy's formula for a factorial. Note that the ability to refer to them individually is via the `equate` package. Additionally, here is a single-lined equation:
$
  a^2 + b^2 = c^2
$ <eq:pythagoras>
To specify quantities (with units) and uncertainties, please refer to the `unify` and `zero` packages.

== Page layout

The page layout is set as A4, with margins of #qty("25", "mm"). As an A4 page is #qty(210, "mm"), wide, full-width figures should be at most #qty(160, "mm") wide. Each page that is not the start of a chapter has a header, containing the current chapter name on the left in #smallcaps[Smallcaps] font, and your name on the right side of the header. The bottom of the page contains the page number, which uses lowercase roman numerals in the front matter, and arabic numerals for the main text.

== Floating elements
Tables and images can be inserted into the document via the `#figure` function. Here follow some examples, which are @fig:large-image and @fig:small-image. Please check out the source code of this text to understand how.

#figure(
  rect(place(center + horizon, [A rectangle of $70 times 160 "mm"$.]), width: 160mm, height: 70mm, stroke: 1pt + black),
  caption: [An example of a large figure. Full-width figures should be #qty(160, "mm") wide.],
) <fig:large-image>


#let fig = [
  #figure(
    image("./../img/sample-image.svg", width: 7cm),
    caption: [An example of a small figure. Illustration by #link("https://unsplash.com/@fezeikahapra?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash")[karem adem] on #link("https://unsplash.com/illustrations/planets-stars-and-space-aPazlNkm25o?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash")[Unsplash].],
  ) <fig:small-image>
]

#wrap-content(
  fig,
  [For smaller figures, it is also possible wrap them within text. For example, @fig:small-image. Below, a small table can be found. Note the alignment of the decimal columns achieved via the `zero` package. \ #lorem(60)],
  alignment: top + right,
)

#[

  // For numberical tables, I recommend using zero to format columns
  #set table.hline(stroke: 0.8pt)

  #show table: zero.format-table(
    (uncertainty-mode: "compact"),
    (uncertainty-mode: "compact"),
  )
  #figure(
    table(
      columns: (2cm, 2cm),
      stroke: none,
      doubleline(),
      [A], [B],
      table.hline(),
      [1.0], [2.0],
      [10.0], [0.35],
      doubleline(),
    ),
    caption: "A small table.",
  )
]

== Referencing stuff <sec:refs>

Tables, Figures and Equations are numbered by section. When refering to one of these items, the number becomes green (color is customizable). For example, this is @sec:refs and the afterwards we have @subsec:chem. For figures, it is possible to attach an additional supplement to a figure, for example @fig:large-image could have subpanels like @fig:large-image[a], which you can specify via ```typ @fig:label[a]```.
References are formatted as @yamanaka_nanoscale_2000. Several references are joined according to @asmatulu_characterization_2019@binnig_atomic_1986@boussinesq_application_1885.

=== Chemical formula <subsec:chem>

Here is a chemical formula: #chem[H2O]. This works via a simple function ```typ #chem``` which subscripts all numbers.


== Fonts

The main font used in this template is `Stix Two Text`, `11pt`, with equations typeset using `STIX Two Math`. The large headings for title, subtitle and name on the cover and title pages are typeset using `Roboto`. The big numbers in chapter titles are typset using `Lora`. These fonts are included by default in the online typst editor, but should be installed when compiling locally. In addition, the main text and math fonts are customizable.

= Full template example

Here follows a full example of how to use the template. This example is the same a what is specified in `main.typ` after initializing the template.\ \
#let text = read("../main.typ")
#raw(text, lang: "typst", block: true)
