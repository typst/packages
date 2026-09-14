/**
 * main.typ
 *
 * Example slides.
 */

#import "@preview/innovative-skoltech-slides:0.8.0": skoltech

#show: skoltech.with(
  title: [Low-Rank Adaptation],
  authors: (
    name: [Daniel Bershatsky],
    role: [second-year PhD, CDSE],
    institution: "Skoltech",
    comment: none,
  ),
  keywords: ("Skoltech", "LoRA", "LoTR"),
  date: datetime(year: 2025, month: 3, day: 17),
  bibliography: bibliography("main.bib"),
  appendix: none,
  aux: (:),
)

#let lora = smallcaps[LoRA]
#let lotr = smallcaps[LoTR]

= LoRA

== #lora: Low-Rank Adaptation

#lora @hu2021lora represents an update to a particular weight matrix (kernel)
in additive form where the first term $W$ is frozen original weights and the
second one is low-rank correction $delta W = B A^top$. Linear layer with #lora
adapter acts as follows

$ Y
  & = X (W^top + alpha A B^top) + bb(1)_N b^top \
  & = op("Aff")(X) + alpha X A B^top, $ <lora>

where $bb(1)_N$ is a vector of $N$ ones. Matrices $A in RR^(n_"in" times r)$
and $B in RR^(n_"out" times r)$ are of rank $r << n$.

#v(8pt)
*NB* Number of parmeters to fit $2 n r$  instead of $n^2$ in full fine-tuning.

#v(8pt, weak: true)
#align(center + horizon)[
Repeated pattern: can we exploit it?

Can we do generally better?
]

= LoTR

== #lotr: Tensorized Low-Rank Adaptation

#let see-it(href, supplement: [it]) = footnote(
  [See #supplement at #link(href, raw(href)).]
)

@bershatsky2024lotr #see-it("https://github.com/daskol/lotr", supplement:
[public repo]) acts on a set of its similarly shaped matrices $cal(W) =
{W_alpha}$, rank $r$ #lotr\-adaptation is a 3-tensor of corrections $delta
cal(W)$ s.t. the $s$-th linear layer acts on input $X in RR^(N times d)$ as

$ Y = op("Aff")(X) + alpha X A G_s B^top,
  space.quad alpha in RR, $

where $A in RR^(d times r)$ and $B in RR^(d times r)$ are shared among all
layers in training time while square matrix $S_s in RR^(r times r)$ is
specific to the $s$-th layer. Number of adjustable
parameters is $|cal(W)|r^2 + 2 r d$.

#v(1em)
#grid(columns: (1fr, 1fr))[
=== Byproducts

While working on the project, we published some ancillary work on GitHub.

- `gridy`
- `mpl-typst`
- `typst-templates`
][
#v(1em)
#figure(include "/fig/lotr-heatmap.typ")
]

== GLUE Performance

#lotr performs better than #lora on large models with respect to number of
parameters.

#figure(
  caption: none,
  include "tab/lotr-glue.typ") <lotr-glue>
