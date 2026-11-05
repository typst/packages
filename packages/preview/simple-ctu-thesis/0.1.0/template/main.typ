#import "@preview/simple-ctu-thesis:0.1.0": thesis

#show: thesis.with(
  thesis-type: "Bachelor's thesis",
  title: (
    en: "Example Thesis",
    cs: "Ukázková práce",
  ),
  author: "John Doe",
  faculty: "Faculty of Electrical Engineering",
  department: "Department of Cybernetics",
  study-program: "Open Informatics",
  supervisors: ("Dr. Alex Smith",),
  abstract: (
    en: [This thesis explores a simple example problem and outlines an approach to its solution.],
    cs: [Tato práce se zabývá jednoduchým příkladem problému a nastiňuje přístup k jeho řešení.],
  ),
  keywords: (
    en: ("example",),
    cs: ("příklad",),
  ),
  acknowledgements: [Thanks to everyone who helped.],
  list-of-figures: true,
  list-of-tables: true,
  list-of-abbreviations: (
    ("CTU", "Czech Technical University in Prague"),
    ("FEE", "Faculty of Electrical Engineering"),
  ),
  bibliography: bibliography("refs.bib"),
  appendices: [
    = Supplementary Notes

    Additional details.

    #figure(
      table(
        columns: 2,
        [*Key*], [*Value*],
        [A], [1],
        [B], [2],
      ),
      caption: [A table in an appendix.],
    )

    = Example Data

    A small sample.
  ],
)

= Introduction <intro>

#lorem(50) @knuth1984

== Goals

#lorem(100)

#lorem(100)

= Features

This chapter shows the elements the template numbers per chapter. See @intro for the introduction.

== Figures and tables

#figure(
  rect(width: 60%, height: 2cm),
  kind: image,
  caption: [A placeholder figure.],
) <fig:example>

#figure(
  table(
    columns: 3,
    [*Name*], [*Value*], [*Unit*],
    [Voltage], [3.3], [V],
    [Current], [120], [mA],
  ),
  caption: [A small table.],
) <tab:example>

Both @fig:example and @tab:example restart their numbering in each chapter.

== Code and equations

#figure(
  ```python
  def square(x):
      return x * x
  ```,
  caption: [A code listing.],
) <lst:example>

Equations are numbered per chapter too:

$ E = m c^2 $ <eq:energy>

See @lst:example and @eq:energy and maybe @esp32s3.
