#import "@preview/mousse-notes:1.0.0": *
#set page(paper: "us-letter")
#show: book.with(
  title: [WUNK 101],
  subtitle: [Introduction to Wunkematics],
  subsubtitle: [
    Lecture notes, Fall 2023
  ],
  subsubsubtitle: [
    Professor #smallcaps[Jonathan Bingus], University of Ipsum.
  ],
  author: "John S. Student",
  epigraph: quote(
    attribution: [Jonathan Bingus],
  )[This is a tremendously inspirational quote that sets the tone of this course; truly, one of the epigraphs of all time.],
)

// This is a demo of how Mousse looks like for taking notes:

= The Pond

== Introduction

We begin our study of wunk analysis by investigating the pond.
The pond is a central structure in applied wunkebra,
because of its use in telecommunications and biology.
Intuitively, a pond can be compared to a body of water (as in the usual sense of the word);
it comprises a liquid medium, and it may contain objects within the medium.

#definition[
  A *pond* is a set of wunks $P$ along with a *medium element* $M$ that satisfies the following properties (pond axioms):
  + For all distinct wunks $w_1, w_2 in P$ such that both $w_1$ and $w_2$ are fish,
    if $w_1$ is dancing, then $w_2$ is not dancing.#footnote[
      Informally, this axiom is often stated as "two fish may not dance in the same pond."
    ] (Fish axiom)
  + For each wunk $w in P$, there exists an anti-wunk $overline(w) in P$
    such that the combination of $w$ and $overline(w)$ results in annihilation,
    i.e. $w overline(w) = M$. (Anti-wunk axiom)
]

#indent
The most commonly used pond
is $PP_1$, where the medium $M$ is water, and
the wunks are acidic ($A$) and basic ($B$) fish:
$
A = {a_1, a_2, ...}, quad B = {b_1, b_2, ...}, \
PP_1 = A union B.
$

#proposition[The set $PP_1$ is a pond.]
#proof[
  We show that $PP_1$ satisfies the pond axioms.
  + This part of the proof has been left as an exercise to the reader.
  + For acidic wunks, the basic wunk is the anti-wunk, and vice-versa.
    The combination of an acidic and basic wunk produces water, which
    is by definition the medium of $PP_1$.
    Therefore, $PP_1$ is a pond. $qed$
]

== Wunk Transfer

A *pond chain* is an ordered list of $n$ ponds ($n in NN$),
where consecutive ponds are made to overlap.
In the overlap between pond $i$ and pond $i + 1$, a dancing fish $f_i$ is placed.

#example[
  Suppose we construct a pond chain of length $n in NN$,
  where each pond is isomorphic to $PP_1$.
  Alice (at pond 1) makes a fish other than $f_1$ dance.
  What does Bob (observing pond $n$) see with his fish?
  Notably, does fish $f_n$ annihilate or stop dancing?
]

#solution[
  We examine the cases where $n$ is even, and $n$ is odd. By induction on $n$, we
]




= Guide to Mousse Notes <ch_guide>

#let mousse = smallcaps[Mousse]

== Introduction

#mousse is a template intended for writing lecture notes, specifically intended
for use in STEM courses. Each Typst file is supposed to represent a complete
textbook for an individual course. #mousse's design is inspired by old-ish math
books. The name of the template itself is just a random French word,
because French sounds fancy. For up-to-date information, see the source code of
this template at
https://github.com/dogeystamp/mousse-notes.

#mousse is intended to be batteries-included, and provides tools you might need
to write notes, e.g. Theorem and Example environments. This chapter shows by
example how to use the functions provided in #mousse. Please reference the
source code of this document while reading to see how the functions are used.

== Document Structure <sec_struct>

To use #mousse, call the `book()` function. See the start of this document for an
example. As of now, `book()` is the only format supported; perhaps in the future
there will be others.

In `book()`, one Typst file represents a book, and first level headings (`=`)
represent chapters. Second and third level headings (`==`, `===`) are sections
and subsections. As always, you can reference sections and chapters using
normal Typst methods: @sec_struct, @ch_guide.

=== Subsection
This is what a subsection looks like.

== Math Equations

Math equations look like this:
$
  1 + 1 = 2
$
When you add a label to an equation, it gains a number:
$
  1 + 1 = 2
$ <eq_important>
You can then reference the equation with the label, e.g. see @eq_important.

Due to limitations with Typst,
#footnote[See: https://github.com/typst/typst/issues/3206]
you can not break a paragraph after a math equation. That is, after a math
equation, there will never be an indent.
#mousse provides a workaround for this:
whenever you need an indent, use `#indent`.
For example:
$
  1 + 1 = 2
$
#indent This is a new paragraph (visually, at least).
The indent in front of this paragraph was manually added.

The other visual workaround function provided by #mousse is `glue()`.
Sometimes, Typst will put a awkward pagebreak between a paragraph and an equation.
By wrapping the paragraph with glue, it will stick to the next element.

#glue[
  For instance, this paragraph is glued to this equation:
]
$
  1 + 1 = 2.
$

== Theorem Environments

Mousse provides the `theorem()`, `proposition()`, `lemma()`, `corollary()`,
`definition()`, `example()`, `solution()`, `proof()` and `remark()`
environments by default. You can also create your own; see the source
code in `lib.typ` to see how to do that.

You can make unnamed theorems:
#theorem[
  For all $x in RR$, we have something.
]
You can set a name:
#theorem(name: "Pythagorean")[
  Bla bla bla $a^2 + b^2 = c^2$.
]
You can also assign a label to the theorem with the `id:` optional parameter,
then reference the theorem.
See @thm_bla.
#theorem(id: "thm_bla")[For all $x in CC$, we have something.]

#indent If you need to break a paragraph after a theorem,
you again have to use `#indent`,
otherwise everything will be in the same paragraph visually.

For proofs, you must add `$qed$` by yourself. In #mousse, `$qed$` is intended
to be next the the content, rather than at the end of the line.
For example:
#proof[
  #lorem(20) $qed$
]

== Figures

#mousse provides fancy formatted tables with the function `tablef()`,
which is a thin wrapper over `table()`.
Use these the same way you'd use Typst's default tables.

#figure(
  tablef(columns: 2, $A$, table.vline(), $not A$, table.hline(), $T$, $F$, $F$, $T$),
  caption: [Truth table for negation "not $A$".],
)

Image figures in #mousse also work.


