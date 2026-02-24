= Chapter one

#import "@preview/metalogo:1.2.0": TeX, LaTeX

#show "LaTeX": LaTeX

#let typst = {
  text(
    fill: eastern,
    font: "Libertinus Serif",
    weight: "semibold",
    "typst",
  )
}
#show "typst": typst

In this section there will be useful information about how to style chapters, sections and so on. Be sure to read the typst guide for LaTeX users @typst-latex.

== Sections and subsection

In #LaTeX, the canonical sections division is as follows:
```tex
\chapter{}
\section{}
\subsection{}
\subsubsection{}
```
in typst, there are just headings @typst-headings (similarly to Markdown) -- so the LaTeX system maps to:
```typst
= Chapter           // Heading level 1
== Section          // Heading level 2
=== Subsection      // Heading level 3
==== Subsubsection  // Heading level 4
```
// #grid(
//   columns: (auto, 1cm, auto),
//   align: (x,y) => {
//     if y > 0 {
//       left + horizon
//     } else {
//       center
//     }
//   },
//   gutter: 0.5cm,
//   grid.header(LaTeX, "", typst),
//   raw("\chapter{}", lang: "tex"), $|->$, raw("= Chapter", lang: "typc"),
//   raw("\section{}", lang: "tex"), $|->$, raw("== Section", lang: "typc"),
//   raw("\subsection{}", lang: "tex"), $|->$, raw("=== Subsection", lang: "typc"),
//   raw("\subsubsection{}", lang: "tex"), $|->$, raw("==== Subsubsection", lang: "typc"),
// )

If you need to turn off the numbering you will call the ```typst heading``` function:
```typst
#heading("Heading Title", level: n, numbering: none)
```

== Equations

In LaTeX, there are many environments (```tex equation, equation*, aligned```) -- in typst there is just the equation environment called with dollars @typst-equation:

- Inline math, same as LaTeX:
#columns[
  #set align(center)
  ```typst
  $a^2 + b^2 = c^2$
  ```
  #colbreak()
  $a^2 + b^2 = c^2$
]

- Block math, by adding spaces before and after the content:
#columns[
  #set align(center)
  ```typst
  $ a^2 + b^2 = c^2 $
  ```
  #colbreak()
  $ a^2 + b^2 = c^2 $
]

For a more complex equation the LaTeX code is:
```tex
\begin{subequations}
  \label{eq:maxwell}
  \begin{align}[left=\empheqlbrace]
  \nabla\cdot \bm{D} & = \rho, \label{eq:maxwell1} \\
  \nabla \times \bm{E} + \frac{\partial \bm{B}}{\partial t} & = \bm{0}, \label{eq:maxwell2} \\
  \nabla\cdot \bm{B} & = 0, \label{eq:maxwell3} \\
  \nabla \times \bm{H} - \frac{\partial \bm{D}}{\partial t} &= \bm{J}. \label{eq:maxwell4}
  \end{align}
\end{subequations}
```
while the typst version:
#grid(
  columns: (65%, 35%),
  align: left + horizon,
  ```typm
    $
    lr(\{
      #block[$
        Delta dot bold(D) &= rho\, \
        Delta times bold(E)
          + display((partial bold(B))/(partial t))
          &= 0\, \
        Delta dot bold(B) &= 0\, \
        Delta times bold(H)
          - display((partial bold(D))/(partial t))
          &= bold(J).
      $]
    )
  $
  ```
  ,
  $
    lr(\{
    #block[$
      Delta dot bold(D) &= rho\, \
      Delta times bold(E) + display((partial bold(B))/(partial t)) &= 0\, \
      Delta dot bold(B) &= 0\, \
      Delta times bold(H) - display((partial bold(D))/(partial t)) &= bold(J).
    $]
  )
  $
)

This is quite an _advanced way_ to get things done. To put it simply, this is the typst equivalent of LaTeX's ```tex \left{ equation \right.``` --- though if you don't understand how/why it works, that's ok -- I'll break it down, but first have a read at the `lr()` function documentation @typst-lr.

- The equations must be aligned to the center and I achieve that with `&`, the same as LaTeX

- Then, the left part must have a `{` to wrap around it: in order to do, typst needs to have an element to compute the size for, which will be the `block[]` part

- In the block, I'll insert all the equations by linebreaking with `\` (in LaTeX this is done via ```latex \\```, a double backslash)

- Finally, I'll wrap both the parenthesis AND the block in the same `lr()` call, effectively sizing everything

I highly encourage you to mess with the above code to see how it changes. It will dramatically help you to understand how typst works.

The "normal" representation would have been just to use the ```typst cases()``` function:
```typm
$
  cases(
    Delta dot bold(D) &= rho\, \
    Delta times bold(E) + display((partial bold(B))/(partial t)) &= 0\, \
    Delta dot bold(B) &= 0\, \
    Delta times bold(H) - display((partial bold(D))/(partial t)) &= bold(J).
  )
$
```
$
  cases(
    Delta dot bold(D) &= rho\, \
    Delta times bold(E) + display((partial bold(B))/(partial t)) &= 0\, \
    Delta dot bold(B) &= 0\, \
    Delta times bold(H) - display((partial bold(D))/(partial t)) &= bold(J).
  )
$

By default, the equations are *not* numbered -- however if you need to:
#math.equation(
  numbering: "(1.1)",
  block: true,
  $
    lr(\{
    #block[$
      Delta dot bold(D) &= rho\, \
      Delta times bold(E) + display((partial bold(B))/(partial t)) &= 0\, \
      Delta dot bold(B) &= 0\, \
      Delta times bold(H) - display((partial bold(D))/(partial t)) &= bold(J).
    $]
  )
  $,
)<maxwell-equation>

And to reference it just type @maxwell-equation.

== Figures, Tables and Algorithms

=== Figures

Via the ```typst figure``` environment @typst-figure, as you would done in LaTeX:
#figure(
  image("../../src/img/logo_ingegneria.svg"),
  caption: [Caption in the List of Figures.],
)

However, since typst does not _natively_ support subfigures, one could make use of the `subpar` package @typst-subpar:

#import "@preview/subpar:0.2.2": *

#grid(
  figure(
    image("../../src/img/logo_ingegneria.svg", width: 50%),
    caption: [
      Left Polimi logo.
    ],
  ),
  <a>,
  figure(
    image("../../src/img/logo_ingegneria.svg", width: 50%),
    caption: [
      Right Polimi logo.
    ],
  ),
  <b>,
  columns: (1fr, 1fr),
  align: horizon,
  caption: [A figure composed of two sub figures, similar to ```latex \subfloat{}```.],
  label: <full>,
)

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
    fill: shading(aqua.darken(20%)),
    table.header([], [Column 1], [Column 2], [Column 3]),
    [row 1], [1], [2], [3],
    [row 2], $alpha$, $beta$, $gamma$,
    [row 3], [alpha], [beta], [gamma],
  ),
  caption: [Caption of the Table to appear in the List of Tables],
)

As you can see, it could be useful to implement a default style for every table @typst-tables.

=== Algorithms

For algorithms, there are a lot of packages on typst universe. The following are my recommendations.

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

#pagebreak()

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

#import "@preview/elegant-polimi-thesis:0.1.0": *

I have implemented my own version of the classic LaTeX environments:

#theorem[
  Write here your theorem.
]

#proposition[
  Write here your theorem.
]

#proof[
  If useful you can report here the proof.
]

However the `ctheorems` package @typst-ctheorems probably handles them in a better way.

Normal list:
- First item
- Second item

Numbered list:
+ First item
+ Second item

== Plagiarism

You have to be sure to respect the rules on Copyright and avoid an involuntary plagia-
rism. It is allowed to take other persons’ ideas only if the author and his original work are clearly mentioned. As stated in the Code of Ethics and Conduct, Politecnico di Milano promotes the integrity of research, condemns manipulation and the infringement of intellectual property, and gives opportunity to all those who carry out research activities to have an adequate training on ethical conduct and integrity while doing research. To be sure to respect the copyright rules, read the guides on Copyright legislation and citation styles available at:

#align(
  center,
  link("https://www.biblio.polimi.it/en/tools/courses-and-tutorials"),
)

You can also attend the courses which are periodically organized on "Bibliographic cita-
tions and bibliography management".

== Bibliography and citations

Your thesis must contain a suitable Bibliography which lists all the sources consulted on developing the work. The list of references is placed at the end of the manuscript after the chapter containing the conclusions. We suggest to use the BibTeX package @bibtex-cheat-sheet and save the bibliographic references in the file `Thesis_bibliography.bib`. This is indeed a database containing all the information about the references.

To cite in your manuscript, use the `cite` @typst-cite command as follows:

#align(
  center,
  emph([Here is how you cite bibliography entries: @knuth74 or chained @knuth92@lamport94.]),
)

As it would have been in LaTeX, the bibliography @typst-bibliography is automatically generated.
