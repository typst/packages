#import "@preview/mantys:0.1.4": *
#import "@preview/cheq:0.1.0": *

#show: checklist.with(fill: eastern.lighten(95%), stroke: eastern, radius: .2em)

#let TeX = style(styles => {
  set text(font: "New Computer Modern")
  let e = measure("E", styles)
  let T = "T"
  let E = text(1em, baseline: e.height * 0.31, "E")
  let X = "X"
  box(T + h(-0.15em) + E + h(-0.125em) + X)
})

#let LaTeX = style(styles => {
  set text(font: "New Computer Modern")
  let a-size = 0.66em
  let l = measure("L", styles)
  let a = measure(text(a-size, "A"), styles)
  let L = "L"
  let A = box(scale(x: 110%, text(a-size, baseline: a.height - l.height, "A")))
  box(L + h(-a.width * 0.67) + A + h(-a.width * 0.25) + TeX)
})

//-------------------------------------------------------------------------------------
#let abstract = [
  #package[Elsearticle] is a Typst template that aims to mimic the Elsevier article #LaTeX class, a.k.a. elsearticle.cls, provided by Elsevier to format manuscript properly for submission to their journals.
]

#show: mantys.with(
  name: "Elsearticle class for Typst",
  version: "0.4.1",
  date: datetime.today(),
  license: "MIT",
  authors: ("Mathieu Aucejo"),
  abstract: abstract
)

= About

#package[Elsearticle] is a Typst template that aims to mimic the Elsevier article #LaTeX class, a.k.a. elsearticle.cls, provided by Elsevier to format manuscript properly for submission to their journals.

#package[Elsearticle] is designed to be as close as possible to the original class, whose specification can be found in the #link("http://assets.ctfassets.net/o78em1y1w4i4/3ro3yQff1q67JHmLi1sAqV/1348e3852f277867230fc4b84a801734/elsdoc-1.pdf")[#text("documentation", fill: eastern)].  The template is still in development and may not be fully compatible with all Elsevier journals.

This manual provides an overview of the features of the #package[Elsearticle] template and how to use it.


#wbox[The template is provided as is by the Typst community and is not affiliated with Elsevier.]

= Usage

== Using Elsearticle

To use the #package[Elsearticle] template, you need to include the following line at the beginning of your `typ` file:
#codesnippet[```typ
#import "@preview/elsearticle:0.4.2": *
```
]

== Initializing the template

After importing #package[Elsearticle], you have to initialize the template by a show rule with the #cmd[elsearticle] command. This function takes an optional argument to specify the title of the document.
#codesnippet[```typ
#show: elsearticle.with(
  ...
)
```
]

#cmd[elsearticle] takes the following arguments:
#command("elsearticle", ..args(
  title: none,
  authors: (),
  abstract: none,
  journal: none,
  keywords: none,
  format: "preprint",
  numcol: 1,
  line-numbering: false,
  [body])
)[#argument("title", default: none, types: "string")[Title of the paper]

#argument("authors", default: (), types: "array")[List of the authors of the paper

Each element of the #dtype("array") is a #dtype("dict") definining an author. The author #dtype("dictionary") has the following keys:
- `name` #dtype("string"): Name of the author
- `affiliation` #dtype("string") (optional): Affiliation of the author
- `corr` #dtypes("string", none) (optional): email address of the corresponding author
- `id` #dtype("string") (optional): ID of the author

#codesnippet[```typc
authors: (
    (
      name: "J. Doe",
      affiliation: "Laboratory 1, University 1, City 1",
      corr: "jdoe@univ.edu",
      id: "a",
    ),
    (
      name: "J. Smith",
      affiliation: "Laboratory 2, University 2, City 2",
      id: "b"
    ),
    (name: "J. Dupont"), // J. Dupont is in the same laboratory as J. Doe
  )
```]
]

#argument("abstract", default: none, types: "content")[Abstract of the paper]

#argument("journal", default: none, types: "string")[Name of the journal]

#argument("keywords", default: none, types: "array")[List of the keywords of the paper

Each element of the #dtype("array") is a #dtype("string") representing a keyword

#codesnippet[```typc
keywords: ("Keyword 1", "Keyword 2")
```]
]

#argument("format", default: "review", types: "string")[Format of the paper. Possible values are "preprint", "review", "1p", "3p" and "5p"
]

#argument("numcol", default: 1, types: "number")[Number of columns of the paper. Possible values are 1 and 2

#ibox[According to the documentation of `elsearticle.cls` (see #link("https://assets.ctfassets.net/o78em1y1w4i4/3ro3yQff1q67JHmLi1sAqV/1348e3852f277867230fc4b84a801734/elsdoc-1.pdf", "here")), the number of columns is related to the format of the paper:
- 1p: Single column only
- 3p: Single or double column possible
- 5p: Double column only

To avoid unexpected behaviors, the value of the `numcol` argument is set to 1 by default and restricted to 1 or 2.]
]

#argument("line-numbering", default: false, types: "bool")[Enable line numbering in the document]
]

== Additional features

The #package[Elsearticle] template provides additional features to help you format your document properly.

=== Appendix

The template allows you to create appendices using the #cmd["appendix"] environment. The appendices are then numbered with capital letters (A, B, C, etc.). Figures, tables and equations are numbered accordingly, e.g. Eq. (A.1).

To activate the appendix environment, all you have to do is to place the following command in your document:
#codesnippet[
  ```typ
  #show: appendix

  // Appendix content here
  ```
]

=== Subfigures

Subfigures are not built-in features of Typst, but the #package[Elsearticle] template provides a way to handle them. It is based on the #package[subpar] package that allows you to create subfigures and properly reference them.

To create a subfigure, you can use the following syntax:

#codesnippet[
  ```typc
  #subfigure(
    figure(image("image1.png"), caption: []), <figa>,
    figure(image("image2.png"), caption: []), <figb>,
    columns: (1fr, 1fr),
    caption: [(a) Left image and (b) Right image],
    label: <fig>
  )
  ```
]

#ibox[The #cmd("subfigure") function is a wrapper around the #cmd[subpar.grid] function. The numbering is adapted to the context of the document (normal section or appendix).]

=== Equations

The equations are numbered with the format "(1)", "(2)" in normal sections and with the format "(A.1)", "(A.2)" in appendices. In addition to these numbering patterns, the #package[Elsearticle] template provides the #cmd("nonumeq") to create unnumbered equations. The latter function can be used as follows:

#codesnippet[
  ```typ
  #nonumeq[$
    y = f(x)
    $
  ]
  ```
]

= Roadmap

The #package[Elsearticle] template is still in development. Here are some of the features that are planned for future releases :

*Article format*

- [x] Preprint
- [x] Review
- [x] 1p
- [x] 3p
- [x] 5p

*Environment*

- [x] Implementation of the `appendix` environment

*Figures and tables*

- [x] Implementation of the `subfigure` environment
- [x] Proper referencing of figure, subfigures and tables w.r.t. the context
- [x] Recreation of the `link` to cross-reference figures, subfigures and tables

*Equations*

- [x] Proper referencing of equations w.r.t. the context
- [x] Use of the `equate` package to number each equation of a system as "(1a)"

*Other features*

- [x] Line numbering - Use the built-in `par.line` function available from Typst v0.12