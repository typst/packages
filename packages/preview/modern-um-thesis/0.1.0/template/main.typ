#import "@preview/modern-um-thesis:0.1.0": *

// Optional third-party packages. Remove if unnecessary.
#import "@preview/cetz:0.4.1": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/wordometer:0.1.5": total-words, word-count

#let (
  // Metadata
  doctype,
  date,
  lang,
  info,
  // Layouts
  double-sided,
  doc,
  frontmatter,
  mainmatter,
  appendix,
  // Pages
  abstract,
  cover,
  declare,
  outline-image,
  outline-table,
  outline-table-image,
) = documentclass(
  doctype: "master",
  date: datetime.today(),
  lang: "en",
  double-sided: true,
  print: true,
  info: (
    // Fields ending with "-en" and the `lang` parameter are required
    title-en: [Title of Thesis],
    title-zh: [论文标题],
    title-pt: [Título da Tese],
    author-en: [Name of Author],
    author-zh: [作者姓名],
    author-pt: [Nome do Autor],
    degree-en: [Degree Title],
    degree-zh: [学位名称],
    degree-pt: [Doutorado],
    academic-unit-en: [Name of Academic Unit],
    academic-unit-zh: [学术单位名称],
    academic-unit-pt: [Nome da Unidade Acadêmica],
    supervisor-en: [Name of Supervisor],
    supervisor-zh: [导师姓名],
    supervisor-pt: [Nome do Supervisor],
    // Optional fields
    co_supervisor-en: [Name of Co-Supervisor],
    co_supervisor-zh: [共同导师姓名],
    co_supervisor-pt: [Nome do Co-Supervisor],
    department-en: [Name of Department],
    department-zh: [系名称],
    department-pt: [Nome do Departamento],
  ),
)

#show: doc

#cover()

// Move declaration to front matter for doctoral thesis
#declare(
  // date: datetime.today()
  // address: none, // For master thesis
  // telephone: none, // For master thesis
  // fax: none, // For master thesis
  // email: none, // For master thesis
)

#abstract()[
  The Faculty requires an Abstract for a master's or doctoral thesis.  It must be in both submitted copies and must follow the format given in the sample. The title of the thesis must appear exactly as it does on the Title Page. The name of your Supervisor must appear in full with his or her appropriate academic title (no professional titles may be used) and the name of the program authorized to offer the degree.

  The text of the Abstract must be one-and-one-half or double-spaced and must conform to margin requirements.

  All abstracts must not exceed 350 words or 35 lines (this requirement is inline with the requirement of Dissertation Abstracts International so that your abstract could be published in full there if necessary).

  It is requested by the publisher that the Abstract not include formulas, diagrams, or symbols. Should a formula, diagram, or symbol be essential to the text in the Abstract, it may not be handwritten. If Greek letters of the alphabet are to be used, they must be clearly inscribed.
] // Move abstract to front matter for doctoral thesis

#show: frontmatter

#outline()

#outline-image() // List of Figures

#outline-table() // List of Tables

// #outline-table-image() // List of Tables and Figures

#show: mainmatter

#show: codly-init.with()

#show: word-count // Start word counting

= Introduction <introduction>

This is a sample document of the University of Macau (UM) Typst thesis template.

== Second level heading <2nd-level-heading>

=== Third level heading <3rd-level-heading>

==== Fourth level heading <4th-level-heading>

#lorem(100)

== Footnotes <footnotes>

Footnotes contain additional textual material or references to specific citations in the text.#footnote()[When citing literature, give as much information on the page where the citation is made as is consistent with publication practice in the field of research. Footnotes, Chapter Notes, or End Notes do not take the place of a Bibliography or List of References.]

== Font <font>

The University of Macau (UM) is a comprehensive research-oriented public university of international standing. Since her establishment in 1981, UM has been dedicated to providing a multifaceted education through our unique educational model and residential college system and in accordance with the university motto: Humanity, Integrity, Propriety, Wisdom and Sincerity.

*In recent years, UM has been taking initiatives for a comprehensive and structural reform and entered a new era of unprecedented growth. We are pleased to see that our progress is being recognised globally as listed in the Times Higher Education World University Rankings and through our growing partnership with top academic institutions both at home and abroad. Locally, UM is the first institution to be awarded the Medal of Merit-Education by the Macao SAR government in recognition of the efforts and contributions of the university’s staff and students. We are confident that the rising reputation of UM will enable us to scale new heights in the international academic circles.*

_On behalf of UM, I would like to invite you to browse our website to get a better sense of our academic programmes and latest development. Also, I would like to welcome you to visit our gorgeous campus where you can see our strengths and advantages, interact with us, and experience the uniqueness of the UM community._

= Math And Citations <math-and-citations>

== Math <math>

=== Numbers and Units <numbers-and-units>

Numbers and units support are provided by `unify`:

- #num("12 345.678 90")
- #num("0.3e45")
- #unit("kg m s^-1")
- #unit("um") $unit("um")$
- #unit("ohm") $unit("ohm")$
- #qty("0.13", "mm")
- #numrange("10", "20")
- #qtyrange("10", "20", "celsius")

Typst also has special syntax and library functions to typeset mathematical formulas.

- $1 plus.minus 2 ii$
- $1.654 times 2.34 times 3.430$

=== Mathematical Symbols And Formulas <mathematical-symbols-and-formulas>

According to @ISO_math, an explicitly defined function not depending on the context is printed in upright type, e.g. $sin$, $exp$, $ln$, $Gamma$.

While mathematical constants, the values of which never change, are printed in upright type, e.g. $ee = num("2.718281828") dots$; $ppi = num("3.141592") dots$; $ii^2 = -1$.

Well-defined operators are also printed in upright type, e.g. $div$, $partial$ in $partial x$ and each $dif$ in $(dif f)/(dif x)$.

Formulas should be centered on a new line. Each formula should be numbered sequentially by chapter, with the number aligned to the right.

$ ee^(ii ppi) + 1 = 0 $

$ (dif^2 u)/(dif t^2) = integral f(x) dif x $

The end of the formula needs punctuation, whether a comma or a period, depending on the following sentence.

$
  (2h)/ppi integral_0^infinity sin(omega delta)/omega cos(omega x) dif omega
  = cases(
    h", " & abs(x) < delta ",",
    h/2", " & x=plus.minus delta",",
    0", " & abs(x) > delta "."
  )
$

When the formula is long, it is best to break the line at the equal sign "=".

$
    & I(X_3; X_4) - I(X_3; X_4 | X_1) - I(X_3; X_4 | X_2) \
  = & [I(X_3; X_4) - I(X_3; X_4 | X_1)] - I(X_3; X_4 | accent(X, tilde)_2) \
  = & I(X_1; X_3; X_4) - I(X_3; X_4 | accent(X, tilde)_2).
$

If breaking the line at the equal sign is difficult to achieve, you can also break the line at the $+$, $-$, $times$, $div$ operators. When breaking the line, the operator should only be written in front of the broken line and not repeated.

$
  1/2 Delta(f_(i j)f^(i j)) = 2(sum_(i<j) chi_(i j) (sigma_i - sigma_j)^2 + f^(i j) gradient_j gradient_i (Delta f)\
    + gradient_k f_(i j) gradient^k f^(i j) + f^(i j) f^k [2 gradient_i R_(j k) - gradient_k R_(i j)]).
$

=== Theorems <theorems>

`Theorion` is used in this template to set up environments for theorems, lemmas, and propositions.

@theorem is an example for a theorem:

#theorem(title: [Residue theorem])[
  Let $U$ be a simply connected open subset of the complex plane containing a finite list of points $a_1, dots, a_n, U_0 = U without {a_1, dots, a_n}$ and a function $f$ holomorphic on $U_0$. Letting $gamma$ be a closed rectifiable curve in $U_0$, and denoting the residue of $f$ at each point $a_k$ by $"Res"(f, a_k)$ and the winding number of $gamma$ around $a_k$ by $upright(*I*)(gamma, a_k)$, the line integral of $f$ around $gamma$ is equal to $2 ppi ii$ times the sum of residues, each counted as many times as $gamma$ winds around the respective point:

  $
    integral.cont_gamma f(z) dif z
    = 2 ppi ii sum_(k=1)^n upright(I)(gamma, a_k) "Res"(f, a_k).
  $

  If $gamma$ is a positively oriented simple closed curve, $upright(I)(gamma, a_k)$ is 1 if $a_k$ is in the interior of $gamma$ and 0 if not, therefore

  $
    integral.cont_gamma f(z) dif z
    = 2 ppi ii sum "Res"(f, a_k).
  $

  with the sum over those $a_k$ inside $gamma$.

  Proof of @theorem.

  #proof[
    First, according to ...\
    Next, we have ...\
    Finally, ...
  ]
] <theorem>

== Notation Of References <notation-of-references>

= Illustrations <illustrations>

The term _illustrations_ refers to informational material that illustrates and enhances the text. Figures, Maps, and tables are all examples of illustrations and are either inserted throughout the text, appearing as soon as possible after the references to them have been made, or grouped at the end of each chapter. Whichever method you choose, you must use it consistently for all the figures, tables, or other illustrations included.

== Figures <figures>

Figures may include photographs (original or photocopied), charts, diagrams, graphs, and drawings. If original photographs are used, they must be included in both copies. They must all be listed in the preliminary pages in a List of Figures. Figure numbers and captions appear below the figure.

Typst has a built-in `figure` function for inserting figures, which supports various image formats, including PNG, JPEG, PDF, and SVG.

=== Single Figure <single-figure>

A simple example of inserting a single figure is shown in @fig:single-figure.

#figure(
  canvas({
    import draw: *

    let csv_data = csv("assets/energy-distrib.csv", row-type: dictionary)
    let points = csv_data.map(row => (float(row.radial), float(row.energy)))
    let style = (stroke: none, fill: black)

    plot.plot(
      size: (9, 6),
      x-label: [$r$ (#unit("mm"))],
      y-label: [Energy (#unit("W/m^3"))],
      x-min: 0,
      x-max: 7,
      y-min: -1000,
      y-max: 11000,

      {
        plot.add(points, mark: "square", style: style)
        plot.annotate(
          content((2.4, 4000), $q_v=(sigma omega^2 abs(bf(A))^2)/2$),
        )
      },
    )
  }),
  caption: [Energy distribution as a function of radial distance.],
) <fig:single-figure>

=== Multiple Figures <multiple-figures>

#let subfig(body) = {
  canvas({
    import draw: *
    set-style(stroke: 0.4pt)

    rect((0, 0), (4, 3), name: "border", fill: gray)
    line("border.north-west", "border.south-east")
    line("border.north-east", "border.south-west")
    line("border.north", "border.south")
    line("border.east", "border.west")
    content("border.center", text(size: 2cm, font: "Noto Sans")[#body])
  })
}

A simple example of inserting multiple figures is shown in @fig:multiple-figures-single-numbering. These two horizontally aligned subfigures share a single figure counter and do not have individual subfigure titles.

#figure(
  grid(
    columns: (1fr, 1fr),

    subfig("A"), subfig("B"),
  ),
  caption: [Caption],
) <fig:multiple-figures-single-numbering>

If the figures are independent and do not share a common figure counter, then you can use the `grid` function, as shown in @fig:multiple-figures-multiple-numbering-a and @fig:multiple-figures-multiple-numbering-b.

#grid(
  columns: (1fr, 1fr),
  [#figure(
    subfig("A"),
    caption: [Caption for figure A],
  ) <fig:multiple-figures-multiple-numbering-a>],
  [#figure(
    subfig("B"),
    caption: [Caption for figure B],
  ) <fig:multiple-figures-multiple-numbering-b>],
)

If you want to create a single figure with multiple subfigures, you can use the `subfigure` function, as shown in @fig:multiple-figures-subfig-numbering-a and @fig:multiple-figures-subfig-numbering-b.

#figure(
  grid(
    columns: (1fr, 1fr),

    subfigure(
      subfig("A"),
      caption: [Caption for figure A],
      label: <fig:multiple-figures-subfig-numbering-a>,
    ),
    subfigure(
      subfig("B"),
      caption: [Caption for figure B],
      label: <fig:multiple-figures-subfig-numbering-b>,
    ),
  ),
  caption: [Caption for subfigures A and B],
) <fig:multiple-figures-subfig-numbering>

== Tables <tables>

=== Basic Tables <basic-tables>

Tables contain information placed in a columnar arrangement and are the only illustrations numbered and captioned above.

An example of a simple three line table is shown in @tab:simple.

#figure(
  table(
    columns: 3,

    toprule,
    table.header(
      table.cell(
        colspan: 2,
      )[Item],
      table.hline(end: 2, stroke: 0.05em),
      [],
      [Animal],
      [Description],
      [Price (\$)],
    ),
    midrule, [Gnat], [per gram],
    [13.65], [], [each],
    [0.01], [Gnu], [stuffed],
    [92.50], [Emu], [stuffed],
    [33.33], [Armadillo], [frozen],
    [8.99], bottomrule,
  ),
  caption: [An elegant three-line table],
) <tab:simple>

=== Complex Tables <complex-tables>

_To be implemented_

== Algorithms <algorithms>

_To be implemented_

== Code Blocks <code-blocks>

Though Typst has built-in support for code blocks, it is recommended not to put large blocks of code directly in the thesis document. If necessary, you can use the `codly` package to insert code blocks with syntax highlighting.

```C
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
int main() {
  pid_t pid;
  switch ((pid = fork())) {
    case -1:
      printf("fork failed\n");
      break;
    case 0:
      /* child calls exec */
      execl("/bin/ls", "ls", "-l", (char*)0);
      printf("execl failed\n");
      break;
    default:
      /* parent uses wait to suspend execution until child finishes */
      wait((int*)0);
      printf("is completed\n");
    break;
  }
  return 0;
}
```

= Conclusion <conclusion>

This chapter concludes the thesis.

#bibliography("./refs.bib", full: true, style: "apa")

#show: appendix

= Maxwell Equations <maxwell-equations>


For the two-dimensional case, the polarization vectors are as follows:
$
  bf(E) = E_z(r, theta) hat(bf(z)),
$
$
  bf(H) = H_r(r, theta) hat(bf(r)) + H_theta(r, theta) hat(bold(theta)).
$ <polarization-vectors>

Taking the curl of @eqt:polarization-vectors:
$
  nabla times bf(E) = 1 / r (partial E_z) / (partial theta) hat(bf(r)) - (partial E_z) / (partial r) hat(bold(theta)),
$
$
  nabla times bf(H) = [1 / r partial / (partial r) (r H_theta) - 1 / r (partial H_r) / (partial theta)] hat(bf(z)).
$

Since $macron(macron(mu))$ is diagonal in cylindrical coordinates, the curl of the electric field $bf(E)$ in Maxwell's equations is:
$
  nabla times bf(E) = upright(i) omega bf(B),
$
$
  1 / r (partial E_z) / (partial theta) hat(bf(r)) - (partial E_z) / (partial r) hat(bold(theta)) = upright(i) omega mu_r H_r hat(bf(r)) + upright(i) omega mu_theta H_theta hat(bold(theta)).
$

Therefore, the components of $bf(H)$ can be written as:
$
  H_r = 1 / (ii omega mu_r) 1 / r (partial E_z) / (partial theta),
$
$
  H_theta = 1 / (ii omega mu_theta) 1 / r (partial E_z) / (partial r).
$

Similarly, since $macron(macron(epsilon.alt))$ is diagonal in cylindrical coordinates, the curl of the magnetic field $bf(H)$ in Maxwell's equations is:
$
  nabla times bf(H) = -ii omega bf(D),
$
$
  [1 / r partial / (partial r) (r H_theta) - 1 / r (partial H_r) / (partial theta)] hat(bf(z)) = -ii omega macron(macron(epsilon.alt)) bf(E) = -ii omega epsilon.alt_z E_z hat(bf(z)),
$
$
  1 / r partial / (partial r)(r H_theta) - 1 / r (partial H_r) / (partial theta) = -ii omega epsilon.alt_z E_z.
$

From this, we obtain the wave equation for $E_z$:
$
  1 / (mu_theta epsilon.alt_z) 1 / r partial / (partial r) (r (partial E_z) / (partial r)) + 1 / (mu_r epsilon.alt_z) 1 / r^2 (partial^2 E_z) / (partial theta^2) + omega^2 E_z = 0.
$

= Flow Charts <flow-charts>

The `fletcher` package provides support for creating diagrams with arrows, including flow charts shown in @fig:flow-chart#footnote()[https://github.com/Jollywatt/typst-fletcher/blob/main/docs/readme-examples/2-flowchart-trap.typ] and state diagrams shown in @fig:state-diagram#footnote()[https://github.com/Jollywatt/typst-fletcher/blob/main/docs/readme-examples/3-state-machine.typ].

#figure(
  {
    import fletcher.shapes: diamond
    diagram(
      node-stroke: 1pt,
      node((0, 0), [Start], corner-radius: 2pt, extrude: (0, 3)),
      edge("-|>"),
      node(
        (0, 1),
        align(center)[
          Hey, wait,\ this flowchart\ is a trap!
        ],
        shape: diamond,
      ),
      edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1),
    )
  },
  caption: [Flow chart],
) <fig:flow-chart>

#figure(
  {
    set text(10pt)
    diagram(
      node-stroke: .1em,
      node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
      spacing: 4em,
      edge((-1, 0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
      node((0, 0), `reading`, radius: 2em),
      edge(`read()`, "-|>"),
      node((1, 0), `eof`, radius: 2em),
      edge(`close()`, "-|>"),
      node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
      edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
      edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
    )
  },
  caption: [State diagram],
) <fig:state-diagram>
