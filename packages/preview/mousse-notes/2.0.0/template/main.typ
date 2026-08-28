#import "@preview/mousse-notes:2.0.0": *

#set document(title: [WUNK 101], author: "John Student")

// US Letter size folded in half.
// Readable on screens, and readable as a folded booklet.
#set page(height: 215.9mm, width: 279.4mm / 2)

// Alternatively, use us-letter.
// #set page(paper: "us-letter")

// This must be the last show or set rule
// (because of the `_box-blocks` rule).
#show: style

#title-page(
  subtitle: upper[Introduction to Wunkematics],
  primary: upper[
    Lectures delivered by \
    _Jonathan Bingus_ \
  ],
  secondary: upper[University of Ipsum \ Fall 2026],
)

// The first chapter is a demo of how Mousse looks like for taking
// notes. A manual is available afterwards.

= The Pond

#epigraph(attribution: [Jonathan Bingus])[
  This is a tremendously inspirational quote that sets the tone of this course; truly, one of the epigraphs of all time.
]

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

== WunkPy

The WunkPy library provides many convenient utilities
for working with wunks. See @lst_pond for a usage example.

#figure(
  ```python
  from wunkpy import Pond, Wunk

  p = Pond()
  for w in (Wunk(dancing=True), Wunk(dancing=False)):
    p.add(w)
  ```,
  caption: [Initializing a pond in WunkPy],
) <lst_pond>

== Examples

#example[
  Suppose we construct a pond chain of length $n in NN$,
  where each pond is isomorphic to $PP_1$.
  Alice (at pond 1) makes a fish other than $f_1$ dance.
  What does Bob (observing pond $n$) see with his fish?
  Notably, does fish $f_n$ annihilate or stop dancing?
]

#solution[
  We examine the cases where $n$ is even, and $n$ is odd.
  Using proof by I said so, the statement holds. $qed$
]


= Guide to Mousse <ch_guide>

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

In #mousse, first level headings (`=`) represent chapters. Second and third
level headings (`==`, `===`) are sections and subsections. As always, you
can reference sections and chapters using normal Typst methods:
@sec_struct, @ch_guide.

=== Subsection
This is what a subsection looks like.

==== Subsubsection

And a subsubsection.

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

== Indent control

Due to limitations with Typst, #footnote[See:
  https://github.com/typst/typst/issues/3206] you can not break a paragraph after
a math equation. That is, after a math equation, there will never be an indent.
#mousse provides a workaround for this which lets you add an indent.

$
1 + 1 = 2
$

If you add a newline after an equation, it will give an indent
to the next paragraph.
$
1 + 1 = 2
$
If you don't, it will consider the following text to be part of the same
paragraph, so no indent will be added.

The method used to provide this feature is hacky, and has the notable
limitation that it can't recurse into containers like `#block`, or even `#set`
and `#show`. The feature may break in future releases of the Typst compiler, or
it may no longer be necessary.

== Theorem Environments

#mousse provides the `theorem()`, `proposition()`, `lemma()`, `corollary()`,
`definition()`, `example()`, `solution()`, `proof()` and `remark()`
environments by default. You can also create your own; see the source code in
`src/_theorems.typ` to see how to do that.

You can make unnamed theorems:

#theorem[
  For all $x in RR$, we have something.
]
You can set a name:

#theorem(name: "Pythagorean")[
  Bla bla bla $a^2 + b^2 = c^2$.
]
You can reference theorems (see @thm_bla):

#theorem[For all $x in CC$, we have something.] <thm_bla>

For proofs, you must add `$qed$` by yourself. In #mousse, `$qed$` is intended
to be next the the content, rather than at the end of the line.
For example:

#proof[
  #lorem(20) $qed$
]

Due to implementation details,
theorem environments can not be broken across different pages.
Also, you should be careful with newlines around theorems,
as they affect formatting.

- Always put a newline before a theorem.

- Use a newline after a theorem to make following line part of a new paragraph and be indented.

- Omit the newline after a theorem to make the following line continue the current paragraph.

These rules may change with no warning depending on the Typst compiler version.

== Further Configuration

#mousse is an opinionated template, and offers no configuration options. The
recommended way for you to change the style of the template is to fork the
repository. (If you make an improvement that can benefit all users of this
template, please consider making a PR.)

The Typst compiler does not usually have large breaking changes, so you should
be able to use your fork indefinitely without having to backport changes from
the upstream #mousse package.
