#import "@preview/typxidian:0.1.2": *
#import "abbreviations.typ": abbreviations

#show: template.with(
  title: [TypXidian],
  authors: ("Giuseppe Verdi", ),
  supervisors: ("Prof. Mario Rossi", "Prof. Mario Bianchi"),
  subtitle: [A template for academic documents written in Typst],
  university: [University of Salerno],
  faculty: [Faculty of Science],
  degree: [Master's Degree in Machine Learning & Data Science],
  department: [Departmenent of Computer Science],
  academic-year: [2025/2026],
  abstract: lorem(150), 
  quote: [
    #lorem(20)
    \ \ #align(right, [-- John Doe])
  ],
  bib: bibliography("bibliography.bib"),
  abbreviations: abbreviations,
)

= Introduction
*TypXidian* is a template for academic writing, such as theses, dissertations, and reports.  

TypXidian comes with custom environments inspired by #link("https://obsidian.md/")[Obsidian] callout boxes. Some of the environments and styling choices, such as: headers and citation style, are inspired by @scardapane2024alicesadventuresdifferentiablewonderland. 
#linebreak()
The purpose of this document is to act both as a showcase of the template and as documentation.
TypXidian also comes with the following packages:
- `cetz:0.4.2`
- `booktabs:0.0.4`
- `wrap-it:0.1.1`
- `subpar:0.2.2`
- `headcount:0.1.0`
- `fontawesome:0.6.0`
- `decasify:0.10.1`
- a custom version of `acrostiche:0.6.0`
You may directly use any function available in these packages .

== Cover Page
The cover page supports two display modes:
- *Authors-only view*: for reports, notes, or shorter projects;
- *Supervisors + authors view*: for theses or dissertations.

You can switch between them by setting the `supervisors` parameter. If you pass an empty list (the default), the supervisors section will be hidden.

Additional metadata parameters include:
- `university`: name of the university;
- `logo`: university logo (defaults to `src/preview/figures/logo.svg`);
- `academic-year`: the academic year, e.g. *2024/2025* (defaults to `none`);
- `faculty`: the faculty name (defaults to `none`);
- `department`: the department name (defaults to `none`);
- `degree`: the degree program (defaults to `none`);
- `is-thesis`: if `true`, the “AUTHOR(S)” label changes to “CANDIDATE(S)” (defaults to `false`).

== Abstract & Citation
By setting the `abstract` and `citation` parameters, the template adds two additional pages *before* the table of contents.  

The citation page does *not* appear in the table of contents.

== Links, Citations and Refs Colors
You may customize the links, citations and refs colors by respectively setting the `link-color`, `citation-color` and `ref-color`.

== Additional Content
You may inject content directly via parameters:
- `before-content`: material inserted between the abstract/citation and the table of contents (defaults to `none`);
- `after-content`: material added immediately after the table of contents (defaults to `none`);

These are useful for dedicatory pages, acknowledgements, or institutional notices.

= Figures, Tables, Paragraphs and Equations

Figures, tables, paragraphs and equations numbering is dependent on the current chapter. For instance, a figure under the 1st chapter will be numbered as 'Figure 1.X' and so on. On each chapter, the counter resets.

The List of Figures and Tables are dynamic, meaning they will be appear only if there is at least an image or a table in the document.

== Subfigures

To assure consisten numbering of subfigures, you must use the `subfigure(..args)` function which has the same signature as `subpar.grid`. For instance, the following code:
```typ
#subfigure(
  columns: (1fr, 2fr),
  figure(
    image("assets/dog.jpg"),
    caption: [This is a dog.] 
  ),
  <dog>,
  figure(
    image("assets/cat.jpg"),
    caption: [This is a cat.]
  ),
  <cat>,
  caption: [This is a figure with subfigures.],
  label: <fig:example>
)
```
will output the @fig:example.

#subfigure(
  placement: auto,
  columns: (1fr, 2fr),
  figure(
    image("figures/dog.jpg"),
    caption: [This is a dog.] 
  ),
  <dog>,
  figure(
    image("figures/cat.jpg"),
    caption: [This is a cat.]
  ),
  <cat>,
  caption: [This is a figure with subfigures.],
  label: <fig:example>
)

== No number Equations

In this template, block equations are set to always be numbered. A utility function `nonum-eq` is available to write non-numbered equations. To use this function, just call it and write a block equation as you normally would:
```typ
#nonum-eq(
  $ sinh(x) + cosh(x) $ 
)
```
#nonum-eq(
  $ sinh(x) + cosh(x) $ 
)
Calling `nonum-eq` will not affect equation numbering:

$ sinh(x) + cosh(x) $ 

== Paragraphs
The `paragraph(title, body)` function mimics LaTeX's `\paragraph{}` command. For instance, the following code:
```typ
#paragraph([This is a paragraph], [#lorem(25)])
<par>
```
will output:
#paragraph([This is a paragraph], [#lorem(25)])
<par>
Paragraphs are also referenceable like any other figure environment: @par.
= Callouts, Definitions, Theorems & Proofs
Callouts environment can be used through any of the following functions: `info`, `danger`, `success`, `tip`, `faq`. 
#info([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $
  
  #lorem(10)
])
#faq([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $
  
  #lorem(10)
])
#tip([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $
  
  #lorem(10)
])
#success([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $
  
  #lorem(10)
])
#danger([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $
  
  #lorem(10)
])

For each, you may customize the following parameters:
- `title`: the title appearing next to the icon.
- `icon`: the icon of the callout.
- `fill`: background color.
- `title-color`: title color.
- `supplement`: the supplement for references as each callout can be referenced.

Other three custom environments are also available for definitions, theorems and proofs:
#definition([
  #lorem(20)

  $ x + y = 1 $
])

#theorem([
  #lorem(20)

  $ x + y = 1 $
])
<th-1>

#proof([
  #lorem(20)

  $ x + y = 1 $
], [@th-1])

For each, you may customize the following parameters:
- `title`: the title appearing next to the icon.
- `stroke-fill`: the fill of the column of the left.
- `supplement`: the supplement for references as each math environment can be referenced.

Definitions and theorems will be listed in the List of Definitions and List of Theorems respectively.

= Showcase
#acr("AI") #lorem(300)

#paragraph([ML], [ 
  #acr("ML") #lorem(15)
])

== Subsection
#lorem(250)

=== Subsubection
#lorem(100)
