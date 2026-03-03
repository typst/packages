#import "@preview/elegant-polimi-thesis:0.2.0": (
  acknowledgements, appendix, banner, polimi-article-format-thesis, proof, proposition, subfigure, theorem,
  theorems-init,
)

#let data = yaml("../shared_data.yaml")

#show: polimi-article-format-thesis.with(
  title: [`article-format` manual],
  author: data.author,
  advisor: data.advisor,
  coadvisor: data.coadvisor,
  academic-year: data.academic-year,
  abstract: [
    Here goes the Abstract in English of your thesis (in article format)
    followed by a list of keywords. The Abstract is a concise summary of the content
    of the thesis (single page of text) and a guide to the most important contributions
    included in your thesis. The Abstract is the very last thing you write. It should
    be a self-contained text and should be clear to someone who hasn’t (yet) read the
    whole manuscript. The Abstract should contain the answers to the main research
    questions that have been addressed in your thesis. It needs to summarize the
    motivations and the adopted approach as well as the findings of your work and
    their relevance and impact. The Abstract is the part appearing in the record
    of your thesis inside POLITesi, the Digital Archive of PhD and Master Theses
    (Laurea Magistrale) of Politecnico di Milano. The Abstract will be followed by
    a list of four to six keywords. Keywords are a tool to help indexers and search
    engines to find relevant documents. To be relevant and effective, keywords must
    be chosen carefully. They should represent the content of your work and be specific
    to your field or sub-field. Keywords may be a single word or two to four words.
  ],
)

#show: theorems-init

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

= Introduction

This document is intended to be both an example of the Polimi Typst template for Master Theses in article format, as well as a short introduction to its use. It is not intended to be a general introduction to Typst itself, and the reader is assumed to be familiar with the basics of creating and compiling Typst documents.

//(see \cite{oetiker1995not, kottwitz2015latex}).

The cover page of the thesis in article format must contain all the relevant information: title of the thesis, name of the Study Programme, name(s) of the author(s), student ID number, name of the supervisor, name(s) of the co-supervisor(s) (if any), academic year.

Be sure to select a title that is meaningful. It should contain important keywords to be identified by indexer. Keep the title as concise as possible and comprehensible even to people who are not experts in your field. The title has to be chosen at the end of your work so that it accurately captures the main subject of the manuscript.

It is convenient to break the article format of your thesis (in article format) into sections and subsections.  If necessary, subsubsections, paragraphs and subparagraphs can be used.

A new section is created by the command:
```typ
= Title of the section
```

The numbering can be turned off by using the complete function:
```typ
#heading(numbering: none, "Title of the section")
```

A new subsection is created by the command:
```typ
== Title of the subsection
```
and similarly the numbering can be turned off as earlier, but changing the level:
```typ
#heading(numbering: none, level: 2 "Title of the section")
```

It is recommended to give a label to each section by using the command:
```typ
= Title of the section<section-name>
```
where the argument is just a text string that you'll use to reference that part
as follows: ```typ @section-name```.

= Equations

In LaTeX, there are many environments (```tex equation, equation*, aligned```) -- in Typst there is just the equation environment called with dollars @typst-equation:

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

= Figures, Tables and Algorithms

Figures, Tables and Algorithms have to contain a Caption that describes their content, and have to be properly referred in the text.

== Figures

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

== Tables

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

#let frame(color) = (
  (x, y) => (
    left: color,
    right: color,
    top: if y < 2 {
      color
    } else {
      0pt
    },
    bottom: color,
  )
)

#figure(
  table(
    columns: 7,
    stroke: frame(black + 0.5pt),
    inset: 5pt,
    table.header("", ..range(1, 7).map(n => "column" + str(n))),
    "row1", ..range(1, 7).map(str),
    "row2", ..range(1, 7).map(n => numbering("a", n)).map(str),
    "row3", ..range(1, 7).map(n => numbering("α", n)).map(str),
    "row4", "alpha", "beta", "gamma", "delta", "phi", "omega",
  ),
  caption: "Highlighting the columns.",
)

== Algorithms

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

= Some further useful recommendations

Theorems have to be formatted as follows:
#theorem[
  Write here your theorem.
]
#proof[
  If useful you can report here the proof.
]
#v(0.3cm)

Propositions have to be formatted as follows:
#proposition[
  Write here your proposition.
]
#v(0.3cm)

#proof[
  If useful you can report here the proof.
]

Powered by @typst-great-theorems.

How to insert itemized lists:
- first item;
- second item.

How to insert numbered lists:
1. first item;
2. second item.

= Use of copyrighted material

Each student is responsible for obtaining copyright permissions, if necessary, to include published material in the thesis. This applies typically to third-party material published by someone else.

= Plagiarism

You have to be sure to respect the rules on Copyright and avoid an involuntary plagiarism. It is allowed to take other persons' ideas only if the author and his original work are clearly mentioned. As stated in the Code of Ethics and Conduct, Politecnico di Milano #emph("promotes the integrity of research, condemns manipulation and the infringement of intellectual property"), and gives opportunity to all those who carry out research activities to have an adequate training on ethical conduct and integrity while doing research. To be sure to respect the copyright rules, read the guides on Copyright legislation and citation styles available at:

#align(center, link("https://www.biblio.polimi.it/en/tools/courses-and-tutorials
"))

You can also attend the courses which are periodically organized on 'Bibliographic citations and bibliography management'.

= Conclusions

A final section containing the main conclusions of your research/study have to be inserted here.

= Bibliography and citations

Your thesis must contain a suitable Bibliography which lists all the sources consulted on developing the work. The list of references is placed at the end of the manuscript after the chapter containing the conclusions. It is suggested to use the BibTeX package and save the bibliographic references in the file `Thesis_bibliography.bib`.

#bibliography(
  data.bibliography,
  full: true,
)

#show: appendix

= Appendix A

If you need to include an appendix to support the research in your thesis, you can place it at the end of the manuscript. An appendix contains supplementary material (figures, tables, data, codes, mathematical proofs, surveys, ...) which supplement the main results contained in the previous sections.

= Appendix B

It may be necessary to include another appendix to better organize the presentation of supplementary material.

#pagebreak()

#heading(numbering: none, "Abstract in lingua italiana")

Qui va l'Abstract in lingua italiana della tesi seguito dalla lista di parole chiave.

#v(15pt)

#banner[*Parole chiave*: qui, le parole chiave, della tesi, in italiano]

#show: acknowledgements

= Acknowledgements

Here you might want to acknowledge someone.
