#import "../src/lib.typ": *

#show: book

#cover([BooxType Template], image("coffee.jpg"), authors: ("Isaac Fei",))

#preface(
  )[
This is A Typst template for books.

You can create a preface using `preface` template:

```typ
#preface()[
  Your preface goes here...
]
```

The preface chapter will not be numbered or outlined in the table of contnets.

You may change the title of the preface:

```typ
#preface(title: [My Preface])[
  Your preface goes here...
]
```

I generated a long paragraph of lorem ipsum text below so that you can see the
page number at the top of the page. Note that the page number is Roman numeral
before the first chapter.

#lorem(1500)
]

#outline()

= Introduction

== Mathematical Context

The following sentance shows how to reference a theorem and make an index entry:

```typ
@thm:1 is known as #index[Fermat's Last Theorem].
```

@thm:1 is known as #index[Fermat's Last Theorem].

State a theorem and give it a label so that you can reference it:

```typ
#theorem(title: "Fermat's Last Theorem")[
  No three positive integers $a$, $b$, and $c$ can satisfy the equation
  $ a^n + b^n = c^n $
  for any integer value of $n$ greater than $2$.
]<thm:1>
```

The `title` argument is optional. The round brackets will not be shown if the
title is not given.

#theorem(title: "Fermat's Last Theorem")[
  No three positive integers $a$, $b$, and $c$ can satisfy the equation
  $ a^n + b^n = c^n $
  for any integer value of $n$ greater than $2$.
]<thm:1>

Prove a theorem:

```typ
#proof[
  I have discovered a truly marvelous proof of this, which this margin is too
  narrow to contain.
]
```

#proof[
  I have discovered a truly marvelous proof of this, which this margin is too
  narrow to contain.
]

The templates `theorem`, `proposition`, `lemma`, `corollary`, `definition`,
`example`, `note`, `exercise` and `solution` can be used in the same way.

#theorem(
  title: "Rank-Nullity Theorem",
)[
  Let $T: V -> W$ be a linear map between two finite-dimensional vector spaces.
  Then
  $ dim V = dim ker T + dim im T $
]

#definition[
  The number $e$ is defined as
  $ e := sum_(n = 0)^oo 1 / n! $
]

#note[
  Though some texts define $e$ as $lim_(n -> oo) (1 + 1 / n)^n$, the above
  definition is more convenient for our purpose.
]

#definition(title: [Definiton of the Exponential Function])[
  The exponential function, denoted by $exp(x)$, is defined as
  $ exp(x) := sum_(n = 0)^oo x^n / n! $<eq:1>
]<def:1>

Putting $x = 1$ in @eq:1, we obtain $exp(1) = e$.

#exercise[
  Show that $exp(x + y) = exp(x) exp(y), space forall x, y in RR$.
]

#solution[
  I am too lazy to write the solution 🤪. But I know I need to apply the Cauchy
  product.
]

#lorem(500)

== Figures

Reference a figure:

```typ
@fig:1 depicts the topologist's sine curve.
```

@fig:1 depicts the topologist's sine curve.

Insert a figure:

```typ
#figure(
  image("topologist-sine-curve.svg", width: 60%),
  caption: "Topologist's sine Curve.",
)<fig:1>
```

#figure(
  image("topologist-sine-curve.svg", width: 60%),
  caption: "Topologist's sine Curve.",
)<fig:1>

= Point-Set Topology

The knowledge from topology is too important to be neglected. The following
content is mainly based on the book _Topology_ by James R. Munkres
@munkresTopology2000.

== Topology

Topology is the collection of all open subsets in a set.

#definition[
  A #index[topology] on a set $X$ is a collection $cal(T)$ of subsets of $X$ having
  the following properties:
  + $emptyset, X in cal(T)$.
  + $cal(T)$ is closed under arbitrary unions, i.e., $U_alpha in cal(T) space forall alpha in I ==> union.big_(alpha in I) U_alpha in cal(T)$.
  + $cal(T)$ is closed under finite intersections, i.e., $U_1, U_2 in cal(T) ==> U_1 sect U_2 in cal(T)$.
]

A set for which a topology has been specified is called a #index(entry: [topological spaces])[topological space],
and is denoted by $(X, cal(T))$. If the topology is clear from the context, we
simply write $X$ instead of $(X, cal(T))$.

#example[
  The only topology on the empty set $emptyset$ is the singleton $cal(T) = {emptyset}$.
]

#example[
  For a set $X$, the topology containing only $emptyset$ and $X$ is called the #index[trivial topology].
]

#example[
  The power set $cal(P)(X)$ of a set $X$ is a topology on $X$, and is referred to
  as the #index[discrete topology].
]

== Continuous Functions

#definition[
  Let $f: X -> Y$ be a function between two topological spaces. We say $f$ is
  continuous if for any open set $U subset.eq Y$, its preimage $f^(-1)(U)$ is also
  open in $X$.
]

== Compact Spaces

A collection $cal(A) = {A_alpha | alpha in I}$ of subsets in $X$ is said to #index(entry: [covering of a topological space])[cover] $X$,
or to be a #index(entry: [covering of a topological space])[covering] or $X$, if
the union $union.big_(alpha in I) A_alpha$ equals $X$.

And a #index(entry: [subcovering of a topological space])[subcovering] $cal(A)'$ of $cal(A)$ is
a subcollection of $cal(A)$ that also covers $X$.

#definition[
  A topological space $X$ is #index(entry: [compact topological spaces])[compact] if
  every open covering of $X$ has a finite subcovering. Formally, if
  $
    X = union.big_(alpha in I) U_alpha
  $
  where each $U_alpha$ is open in $X$, then there exist $alpha_1, ..., alpha_k in I$ such
  that
  $
    X = union.big_(j=1)^k U_(alpha_j)
  $
]

If $Y$ is a subspace of $X$, to check whether $Y$ is compact, it is usually more
convenient to consider the subsets in $X$ rather than those in $Y$.

A collection $cal(A) = {A_alpha | alpha in I}$ of subsets in $X$ is said to
cover subspace $Y$ if $Y subset.eq union.big_(alpha in I) A_alpha$.

The following proposition states that a subspace $Y$ of $X$ is compact if and
only if any open covering of $Y$ in $X$ has a finite subcovering.

#proposition[
  Let $Y$ be a subspace of $X$. Then $Y$ is compact if and only if every open
  covering of $Y$ in $X$ has a finite subcovering.
]

#proof[
  We prove each direction separately.

  *Proof of $==>$:* Suppose $Y$ is compact. Let ${U_alpha | alpha in I}$ be an
  open covering of $Y$ in $X$. Let $V_alpha = U_alpha sect Y, space alpha in I$.
  Note that $V_alpha$ is open in $Y$. Then, due to the compactness of $Y$, there
  exists a finite subset $J$ of the index set $I$, i.e., $J subset.eq I$ and $abs(J) < oo$,
  such that
  $
    Y = union.big_(alpha in J) V_(alpha) = union.big_(alpha in J) (U_alpha sect Y) subset.eq union.big_(alpha in J) U_alpha
  $
  This shows that ${U_alpha | alpha in J}$ is a finite subcovering of $Y$.

  *Proof of $<==$:* Suppose
  $
    Y = union.big_(alpha in I) V_alpha
  $
  where each $V_alpha$ is open in $Y$. There exists $U_alpha$ open in $X$ such
  that $V_alpha = U_alpha sect Y$. Then, we have
  $
    Y = union.big_(alpha in I) V_alpha = union.big_(alpha in I) (U_alpha sect Y) subset.eq union.big_(alpha in I) U_alpha
  $
  By the given condition, there exists a finite subcovering ${U_alpha | alpha in J}$ of $Y$.
  Consequently, $Y subset.eq union.big_(alpha in J) U_alpha$. It then follows that
  $
    Y = (union.big_(alpha in J) U_(alpha)) sect Y = union.big_(alpha in J) (U_alpha sect Y)
    = union.big_(alpha in J) V_alpha
  $
  This proves that ${V_alpha | alpha in J}$ is a finite subcovering of $Y$, and
  hence $Y$ is compact.
]

#theorem[
  Let $X$ be a compact space. If subset $K subset.eq X$ is closed in $X$, then $K$ is
  also compact.
]<thm:3>

Continuous functions preserve compactness.

#theorem[
  Let $f: X -> Y$ be a continuous function between two topological spaces. If
  $X$ is compact, then $f(X)$ is also compact.
]

#proof[
  Let ${V_alpha | alpha in I}$ be an open covering of $f(X)$ in $Y$. Then, we have $f(X) subset.eq union.big_(alpha in I) V_alpha$.
  It follows that $X subset.eq union.big_(alpha in I) f^(-1)(V_alpha)$. Note that ${f^(-1)(V_alpha) | alpha in I}$ is
  an open covering of $X$. Because $X$ is compact, there exists a finite
  subcovering ${f^(-1)(V_alpha) | alpha in J}$ of $X$. Then, the image $f(X)$ can
  be covered by ${V_alpha | alpha in J}$ of $f(X)$. This proves that $f(X)$ is
  compact.
]

// References
#bibliography("references.bib", title: "References")

// Index page
#index-page()
