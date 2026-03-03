#import "@preview/elegant-polimi-thesis:0.2.0": *

#let data = yaml("../shared_data.yaml")

#show: polimi-thesis.with(
  title: [`polimi-thesis` manual],
  author: data.author,
  advisor: data.advisor,
  coadvisor: data.coadvisor,
  tutor: "Minto Zelante",
  chair: data.chair,
  academic-year: data.academic-year,
  frontispiece: "phd",
)

#show: theorems-init

#show: frontmatter

#toc
#list-of-figures
#list-of-tables

#let nomenclature_ = (
  "Polimi": "Politecnico di Milano",
  "CdL": "Corso di Laurea",
  "CCS": "Consigli di Corsi di Studio",
  "CFU": "Crediti Formativi Universitari",
)

#nomenclature(
  nomenclature_,
  indented: false,
)

#show: mainmatter

= Chapter one

#import "@preview/metalogo:1.2.0": LaTeX, TeX
#show "LaTeX": LaTeX

#let Typst = {
  text(
    fill: eastern,
    font: "Libertinus Serif",
    weight: "semibold",
    "Typst",
  )
}
#show "Typst": Typst

In this section there will be useful information about how to style chapters, sections and so on. Be sure to read the Typst guide for LaTeX users @typst-latex.

== Sections and subsection

In LaTeX, there are specific function dedicated to chapters, sections and so on -- in Typst, there are just headings @typst-headings (similar to Markdown) -- so, for what concers this package, the LaTeX system maps to:
```typ
= Chapter           // Heading level 1
== Section          // Heading level 2
=== Subsection      // Heading level 3
==== Subsubsection  // Heading level 4
```

If you need to turn off the numbering you will call the ```Typst heading``` function:
```typ
#heading("Heading title", level: n, numbering: none)
```

== Equations

In LaTeX, there are many equation environments (```tex equation, equation*, aligned```) -- in Typst there is just one, invoked with dollars @typst-equation:

$
  cases(
    Delta dot bold(D) & = rho\,,
    Delta times bold(E) + display((partial bold(B))/(partial t)) & = 0\,,
    Delta dot bold(B) & = 0\,,
    Delta times bold(H) - display((partial bold(D))/(partial t)) & = bold(J).
  )
$

By default, the equations are *not* numbered -- however if you need to:
#math.equation(
  numbering: "(1.1)",
  block: true,
  $
    lr(
      \{
      #block[$                                            Delta dot bold(D) & = rho\, \
      Delta times bold(E) + display((partial bold(B))/(partial t)) & = 0\, \
                                                 Delta dot bold(B) & = 0\, \
      Delta times bold(H) - display((partial bold(D))/(partial t)) & = bold(J). $]
    )
  $,
)<maxwell-equation>

And to reference it just type @maxwell-equation.

== Figures, Tables and Algorithms

=== Figures

Via the ```Typst figure``` environment @typst-figure, as you would do in LaTeX:
#figure(image("../../src/img/logo_ingegneria.svg"), caption: [Caption in the List of Figures.])

However, since Typst does not _natively_ support subfigures (see #link("https://github.com/typst/typst/issues/246", "related issue")), the packages smartaref @typst-smartaref and hallon @typst-hallon have been integrated:

#figure(
  grid(
    columns: (1fr, 1fr),
    align: horizon,
    subfigure(
      image("../../src/img/logo_ingegneria.svg", width: 50%),
      caption: [
        Left Polimi logo.
      ],
      label: <a>,
    ),

    subfigure(
      image("../../src/img/logo_ingegneria.svg", width: 50%),
      caption: [
        Right Polimi logo.
      ],
      label: <b>,
    ),
  ),
  caption: [A figure composed of two sub figures, similar to ```latex \subfloat{}```.],
)<full>

You can reference either the main @full; or a single subfigure: @a, or @b.

=== Tables

#let frame(color) = (
  (x, y) => (
    left: if x > 0 {
      0pt
    } else {
      color
    },
    right: color,
    top: if y < 2 {
      color
    } else {
      0pt
    },
    bottom: color,
  )
)

#let shading(color) = (
  (x, y) => {
    if y == 0 {
      color
    } else {
      none
    }
  }
)

#show table.cell: it => {
  if (it.x == 0 or it.y == 0) {
    text(weight: "bold", it)
  } else {
    it
  }
}

#set table(align: center)

#figure(
  table(
    columns: 4,
    stroke: frame(black),
    fill: shading(rgb("#B7CDDA")),
    table.header([], [Column 1], [Column 2], [Column 3]),
    [row 1], [1], [2], [3],
    [row 2], $alpha$, $beta$, $gamma$,
    [row 3], [alpha], [beta], [gamma],
  ),
  caption: [Caption of the Table to appear in the List of Tables.],
)

As you can see, it could be useful to implement a default style for every table @typst-tables.

=== Algorithms

For algorithms, there are a lot of packages on Typst universe @typst-universe. The following are my recommendations.

- `lovelace` @typst-lovelace
#import "@preview/lovelace:0.3.0": *

#figure(
  kind: "algorithm",
  supplement: [Algorithm],

  pseudocode-list(booktabs: true, numbered-title: [My cool algorithm])[
    + Initial instructions
    + *for* _for − condition_ *do*
      + Some instructions
      + *if* _if − condition_ *then*
      + Some other instructions
      + *end if*
    + *end for*
    + *while* _while − condition_ *do*
      + Some further instructions
    + *end while*
    + Final instructions
  ],
) <first-algorithm>

See @first-algorithm.

// #pagebreak()

- `algo` @typst-algo
#import "@preview/algo:0.3.6": *

#algo(header: [Name of Algorithm])[
  Initial instructions \
  *for* _for − condition_ *do* #i\
  Some instructions \
  *if* _if − condition_ *then* #i\
  Some other instructions #d\
  *end if* #d\
  *end for* \
  *while* _while − condition_ *do* #i\
  Some further instructions #d\
  *end while* \
  Final instructions
]

== Theorems, propositions and lists

== Theorems

Theorems have to be formatted as:

#theorem[
  Write here your theorem.
]

#proof[
  If useful you can report here the proof.
]

== Propositions

Propositions have to be formatted as:

#proposition[
  Write here your proposition.
]

Powered by @typst-great-theorems.

== Lists

Normal list:
- First item
- Second item

Numbered list:
+ First item
+ Second item

== Plagiarism

You have to be sure to respect the rules on Copyright and avoid an involuntary plagia-
rism. It is allowed to take other persons’ ideas only if the author and his original work are clearly mentioned. As stated in the Code of Ethics and Conduct, Politecnico di Milano promotes the integrity of research, condemns manipulation and the infringement of intellectual property, and gives opportunity to all those who carry out research activities to have an adequate training on ethical conduct and integrity while doing research. To be sure to respect the copyright rules, read the guides on Copyright legislation and citation styles available at:

#align(center, link("https://www.biblio.polimi.it/en/tools/courses-and-tutorials"))

You can also attend the courses which are periodically organized on "Bibliographic cita-
tions and bibliography management".

== Bibliography and citations

Your thesis must contain a suitable Bibliography which lists all the sources consulted on developing the work. The list of references is placed at the end of the manuscript after the chapter containing the conclusions. We suggest to use the BibTeX package @bibtex-cheat-sheet and save the bibliographic references in the file `Thesis_bibliography.bib`. This is indeed a database containing all the information about the references.

To cite in your manuscript, use the `cite` @typst-cite command as follows:

#align(center, emph([Here is how you cite bibliography entries: @knuth74 or chained @knuth92@lamport94.]))

As it would have been in LaTeX, the bibliography @typst-bibliography is automatically generated.

#show: backmatter

#bibliography(
  data.bibliography,
  full: false,
)
