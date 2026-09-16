// ============================================================
// clari-docs — Lecture Notes Template
// ============================================================
// Detailed, flowing lecture notes on A4 with a full title page,
// table of contents, and running header.
// All components work identically to the slides document type.

#import "@preview/clari-docs:0.1.0": *

#show: clari-notes.with(
  category:       "professional",
  theme:          "midnight",
  font:           "Fira Sans",
  font-size:      11pt,
  title:          "Introduction to Topology",
  subtitle:       "MATH 401 — Spring 2026",
  author:         "Prof. Jane Doe",
  institution:    "University of Science",
  show-toc:       true,
  running-header: true,
)

= Metric Spaces

== Definition and Examples

A *metric space* is a pair $(X, d)$ where $X$ is a set and
$d: X times X -> RR$ is a *metric* (or *distance function*).

#definition[Metric][
  A function $d: X times X -> RR_(>=0)$ is a metric if for all $x, y, z in X$:
  + $d(x, y) = 0 iff x = y$ #h(1fr) _(identity of indiscernibles)_
  + $d(x, y) = d(y, x)$ #h(1fr) _(symmetry)_
  + $d(x, z) <= d(x, y) + d(y, z)$ #h(1fr) _(triangle inequality)_
]

The canonical examples are:

- *Euclidean metric* on $RR^n$: $d(x,y) = norm(x - y)_2$.
- *Discrete metric*: $d(x,y) = 0$ if $x=y$, else $1$.
- *$p$-adic metric* on $QQ$: $d_p(x,y) = |x-y|_p$.

#callout(type: "note")[
  Every normed space $(V, norm(dot))$ becomes a metric space via $d(x,y) = norm(x-y)$.
  The converse is false in general — not every metric arises from a norm.
]

== Open and Closed Sets

#definition[Open Ball][
  The *open ball* of radius $r > 0$ centred at $x in X$ is
  $ B(x, r) := { y in X mid(|) d(x, y) < r }. $
]

A set $U subset.eq X$ is *open* if every point of $U$ has a neighbourhood
contained in $U$: $forall x in U, exists r > 0, B(x,r) subset.eq U$.

#theorem(title: "Characterisation of closed sets", number: 1)[
  $F subset.eq X$ is closed iff it contains all its limit points, i.e.
  for every sequence $(x_n) subset F$ with $x_n -> x$, we have $x in F$.
]

#proof[
  ($=>$) Suppose $F$ is closed and $(x_n) subset F$, $x_n -> x$.
  If $x notin F$ then $x in U := X without F$, which is open, so
  $B(x, r) subset U$ for some $r$. But then $x_n notin B(x,r)$ for large $n$,
  contradicting $x_n -> x$.

  ($arrow.l$) Suppose $F$ contains all its limit points.
  If $U = X without F$ were not open, some $x in U$ would have every
  $B(x, 1/n)$ intersecting $F$; picking $x_n$ from each gives $x_n -> x in F$,
  contradiction. $square$
]

= Topological Spaces

== The Axioms

A *topology* on a set $X$ is a collection $tau subset.eq cal(P)(X)$ satisfying:

#step-list[
  $emptyset, X in tau$ (empty set and whole space are open).
][
  Arbitrary unions of sets in $tau$ are in $tau$.
][
  Finite intersections of sets in $tau$ are in $tau$.
]

The pair $(X, tau)$ is a *topological space*; elements of $tau$ are called
*open sets*.

#callout(type: "important")[
  Metric spaces are topological spaces via the metric topology — but topological
  spaces need not be metrizable. The Zariski topology on algebraic varieties is
  a classical non-metrizable example.
]

== Continuous Maps

#definition[Continuity][
  A map $f: (X, tau_X) -> (Y, tau_Y)$ is *continuous* if the preimage of
  every open set is open:
  $ forall V in tau_Y, quad f^(-1)(V) in tau_X. $
]

#cols[
  *Homeomorphism*: a bijective continuous map with continuous inverse.
  Two spaces are homeomorphic ($X tilde.equiv Y$) if a homeomorphism exists.
][
  #framed(title: "Key examples")[
    - $(0,1) tilde.equiv RR$ via $x mapsto tan(pi x - pi/2)$.
    - $S^1$ is *not* homeomorphic to $RR$ (compactness).
  ]
]

= Compactness

== Definition

#definition[Compact Space][
  $(X, tau)$ is *compact* if every open cover has a finite subcover:
  for every ${ U_alpha }_{alpha in A}$ with $X = union.big_alpha U_alpha$,
  there exist $alpha_1, dots, alpha_n$ such that $X = U_(alpha_1) union dots union U_(alpha_n)$.
]

#theorem(title: "Heine–Borel", number: 2)[
  A subset $K subset.eq RR^n$ is compact (in the Euclidean topology) if and only
  if it is *closed* and *bounded*.
]

#remark[
  Heine–Borel fails in infinite-dimensional normed spaces: the closed unit ball
  in $ell^2$ is closed and bounded but not compact.
]

== Compactness and Continuity

#theorem(number: 3)[
  The continuous image of a compact space is compact.
  In particular, a continuous $f: K -> RR$ on a compact $K$ attains its maximum and minimum.
]

#callout(type: "tip")[
  Use this theorem to prove that continuous functions on $[a,b]$ are bounded —
  no $epsilon$-$delta$ argument required.
]

= Connectedness

A space $X$ is *connected* if it cannot be written as a disjoint union of two
non-empty open sets. Equivalently, the only clopen (simultaneously open and
closed) subsets of $X$ are $emptyset$ and $X$ itself.

#comparison(
  left-title:  "Connected",
  right-title: "Path-Connected",
  [Every clopen set is trivial. \
   Preserved by continuous images. \
   Intermediate Value Theorem holds.],
  [Any two points joined by a continuous path $gamma: [0,1] -> X$. \
   Path-connected $=>$ connected; converse *fails*. \
   Topologist's sine curve is connected but not path-connected.],
)

#callout(type: "warning")[
  Path-connectedness is strictly stronger than connectedness.
  Always check which notion you actually need.
]
