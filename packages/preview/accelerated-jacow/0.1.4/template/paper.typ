/*
 * Paper template for JACoW conference proceedings
 *
 * Based on the JACoW guide for preparation of papers.
 * See https://jacow.org/ for more information.
 *
 * This file is part of the accelerated-jacow template.
 * Typst universe: https://typst.app/universe/package/accelerated-jacow
 * GitHub repository: https://github.com/eltos/accelerated-jacow
 */

#import "@preview/accelerated-jacow:0.1.4": jacow, jacow-table

#show: jacow.with(
  // Paper title
  title: [
    Accelerated JAC#lower[o]W paper template\
    for conference proceedings
  ],
  // Author list
  authors: (
    (name: "C. Author", at: "uni", email: "mail@example.com"),
    (name: "P. Coauthor", at: ("uni", "third")),
    (name: "J. Cockcroft", at: ("INP", "third")),
    (name: "C. D. Anderson", at: "INP"),
    (names: ("N. Bohr", "A. Einstein", "M. Curie", "E. Lawrence"), at: "INP"),
    //(names: ("A. Group", "O. F. People"), at: "Single Use Primary Affiliation, Shortcut Way"),
  ),
  affiliations: (
    uni: "Town University, City, Country",
    INP: "Insitute of Nobel Physics, Stockhold, Sweden",
    third: [The Third Institute, City, Country],
  ),
  // Funding note (optional, comment out if not applicable)
  funding: "Work supported by ...",
  // Paper abstract
  abstract: [
    This document demonstrates the usage of the accelerated-jacow paper template to compose papers for JACoW conference proceedings.
  ],
  // Writing utilities
  //draft-note: [*Draft 1* \u{2503} #datetime.today().display()],
  //page-limit: 3,
  //show-line-numbers: true,
  //show-grid: true,
)


// Other useful packages, see below for usage examples
#import "@preview/unify:0.7.1": unit, num, qty, numrange, qtyrange
#import "@preview/glossy:0.7.0": init-glossary
#import "@preview/lilaq:0.1.0" as lq
#import "@preview/physica:0.9.5": *



= Introduction

Typst @typst // a citation to the respective entry in "references.bib" (see below)
is a great, modern and blazingly fast typesetting system focussed on scientific papers.
Being markup based, it supports *strong* _emphasis_ of text, #underline[underlining], `monospace` font, smart "quotes" and much more.
Equations can be typeset inline like $beta_"x" (s)$, and in display mode:

$
  curl E &= - pdv(B, t) \
  integral.cont_(partial A) E dd(s) &= - integral.double_A pdv(B, t) dd(A)
$

By adding a label

$
  e^("i" pi) + 1 = 0 
$ <eq:mycustomlabel>

they can be referenced as in @eq:mycustomlabel. // a reference to a labelled equation
The same works for @fig:writer and @table:xydata too.
Remember to use the long form at the beginning of a sentence:
@fig:writer[Figure].
@eq:mycustomlabel[Equation].
Done.


= Template features

The accelerated-jacow template is based on the JACoW paper preparation guide @jacowguide @jacow.org. // citations
It takes care of proper page size, margins and spacing, generates the front matter with properly formatted title, author list, footnotes and abstract using the show-rule at the top of this document and formats headings, tables, references and more.

Headings are automatically transformed to all-caps and word-caps case respectively.
Should you require custom control on upper/lower case, this can be forced not only in the title (see above), but also in headings like so:

#let nacl = [#upper[N]#lower[a]#upper[C]#lower[l]]


== Subsection heading: #nacl, #upper[N]#lower[a]Cl, $"NaCl"$, $isotope("He", a:4, z:2)$

=== A third level heading
// <-- no blank line here!
Third-level headings are also supported, but mind that you must not leave a blank line after a third-level heading to get the desired run-in heading!


== Figures and tables

Floating figures can be added and their placement can be controlled easily like shown here with @fig:writer.

#figure(
  image("writer.svg"),
  placement: bottom, // `top`, `bottom` or `auto` for floating placement or `none` for inline placement
  caption: [Scientific writing (AI artwork).],
) <fig:writer>

For JACoW style tables, the `jacow-table` function is provided.
It takes the column alignment as first argument (here `lcrl` means left, center, right, left), followed by the table contents.
The optional `header` argument allows to adjust the appearance of the JACoW table style as shown in @table:specs.

#figure(
  jacow-table("lcrl",
    [No.], [$x$ / mm], [$y$], [Note],
    [1], [0.32], qty(70, "cm"), [Small],
    [2], [2.5],  qty(3, "dm"),  [Medium],
    [3], [18],  qty(1.5, "m"), [*Large*],
  ),
  //placement: none, // `top`, `bottom` or `auto` for floating placement or `none` for inline placement
  caption: [Dimensions],
) <table:xydata>


#figure(
  jacow-table("lccc", header: top+left, // top, left or none
    [], [Gen A], [Gen B], [Gen C],
    [Frequency], table.cell(qty(1234567.89, "Hz"), colspan: 3, align: center),
    [Voltage], qty(1, "kV"), qty(3, "kV"), qty(3, "kV"),
    [Cells], [3], [5], [9],
    [Quality], [100], [500], num(1000),
  ),
  //placement: none, // `top`, `bottom` or `auto` for floating placement or `none` for inline placement
  caption: [
    Imaginary specifications of a device for the three generations A, B and C
  ]
) <table:specs>



Finally, it is easy to create column spanning figures as shown in @fig:rect.
These support top, bottom or automatic placement as well.

#figure(
  box(fill: silver, width: 100%, height: 2cm),
  scope: "parent", // two column-figure
  placement: top, // `top`, `bottom` or `auto` for floating placement or `none` for inline placement
  caption: [A column spanning figure. #lorem(41)],
) <fig:rect>






= Packages

The Typst ecosystem features a broad range of community driven packages to make writing papers with Typst even more convenient.
These can be found by exploring the Typst Universe at https://typst.app/universe.

// See the import section near the top of this document


== Physical quantities

The *unify* package helps typesetting numbers and scientific quantities.
Examples include quantities like
#qty(1.2, "um") with reduced spacing between the number and unit
and features like digit grouping in $q=#num(0.12345678)$.
Uncertain quantities like $f_"rev"=qty("325.2+-0.1", "kHz")$
as well as tolerances such as $h=qty("8.3+0.1-0.2  e-2", "mm")$ are supported.

Plain units can be written as
#unit("tesla meter") or #unit("T m") (not Tm or T m which are something different).
More examples: #qty(3, "keV"), #qty(4, "GeV"), $qty("100", "kW")$, #qty(7, "um").
//
For details refer to the package documentation at https://typst.app/universe/package/unify.




== Plots

With the *lilaq* package, plots can be create directly in the document, so you can skip the additional plotting step in your workflow while ensuring that all plot elements are properly sized.
@fig:lilaq[Figure] gives an example and the full documentation is available at https://lilaq.org.

// general plot styling options
#show lq.selector(lq.diagram): set text(.9em)
#show: lq.set-tick(outset: 3pt, inset: 0pt)
#show: lq.set-diagram(xaxis: (mirror: (ticks: false)), yaxis: (mirror: (ticks: false)))

#figure(
  lq.diagram(
    
    // plot a sine function
    let x = lq.linspace(0, 10),
    let y = x.map(x => calc.cos(x)),
    lq.plot(x, y, mark: none, label: [$cos(x)$]),
    
    // plot some data (practically you can load data from a file using `json` etc.)
    lq.plot((1, 2, 3, 7, 9), (-1, 1.8, 0.7, -0.3, 1), yerr: 0.3, mark: "o", stroke: (dash: "dashed"), label: [Data]),
    
    // adjust plot layout
    height: 3cm,
    xlabel: [Angle ~ $x$ / rad], xlim: (0, 10),
    ylabel: [$y$ / m], ylim: (-1.5, 2.5),
    
  ),
  placement: auto, // `top`, `bottom` or `auto` for floating placement or `none` for inline placement
  caption: [A plot create with the Lilaq package directly inside the typst source code]
) <fig:lilaq>




== Abbreviations

// Abbreviation definitions
#show: init-glossary.with((
  JACoW: "Joint Accelerator Conferences Website",
  RF: "radio frequency",
))

The *glossy* package helps managing abbreviations,
automatically using the long form on first use of @JACoW
and the short form on subsequent uses of @JACoW.
But it can do much more:
@RF:a:cap device shows how capitalization is applied on sentence start, and in addition the article (a/an) is managed automatically, since it differs between the first and subsequent use of @RF:a device.
In addition, explicit forms are supported as in @RF:long, @RF:short and @RF:both,
and plural forms can be accessed like in @RF:pl.
For more details, refer to https://typst.app/universe/package/glossy.




= Citations
Reference formatting uses standard bib files.
The bib snippets can conveniently be copied by selecting the format type "BibTex" when using the JACoW reference search tool at https://refs.jacow.org/.
Examples are given below @typst @jacowguide @jacow.org @example-journal-article @example-report @example-book @example-book-chapter @example-thesis @example-jacow-unpublished.




#bibliography("references.bib")



// Workaround until balanced columns are available
// See https://github.com/typst/typst/issues/466
#place(
  bottom,
  scope: "parent",
  float: true,
  clearance: 70pt, // TODO: increase clearance for manual column balancing
  []
)

