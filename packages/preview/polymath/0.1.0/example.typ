#import "lib.typ": *

#show: template

#header(
  name: "Rank, Nullity, and Injectivity",
  author: "Deep Hayer",
  course: "Math 110 — Linear Algebra",
  date: "March 25, 2026",
  professor: "Prof. Sheldon Axler",
)

#epigraph(attribution: [Polymath example])[
  A good set of notes should make room for proofs, calculations, and the side
  remarks that explain why the proof was worth writing down.
]

#defn(title: [null space and range])[
  Let $T : V -> W$ be linear. The _null space_ of $T$ is
  $"null" T = {v in V : T(v) = 0}$ and the _range_ of $T$ is
  $"range" T = {T(v) : v in V}$.
]

#notn(title: [coordinate maps])[
  When $V = RR^n$ and $W = RR^m$, a linear map is often easiest to study by
  writing explicit equations for its coordinates.
]

#lemma(title: [injectivity through the null space])[
  A linear map $T : V -> W$ is injective if and only if $"null" T = {0}$.
]

#prf[
  If $T$ is injective and $v in "null" T$, then $T(v) = 0 = T(0)$, so $v = 0$.
  Conversely, if $"null" T = {0}$ and $T(u) = T(v)$, then
  $T(u - v) = 0$, hence $u - v = 0$ and $u = v$.
]

#thm(title: [rank-nullity])[
  If $V$ is finite-dimensional and $T : V -> W$ is linear, then
  $dim V = dim "null" T + dim "range" T$.
]

#cor(title: [dimension blocks injectivity])[
  If $dim V > dim W$, then no linear map $T : V -> W$ can be injective.
]

#prf[
  If $T$ were injective, then $"null" T = {0}$ by the lemma, so
  $dim "null" T = 0$. Rank-nullity would give
  $dim V = dim "range" T <= dim W$, a contradiction.
]

#note[
  This theorem is valuable because it turns a structural question such as
  injective or surjective into a short dimension count.
]

#eg(title: [projection onto the first two coordinates])[
  Let $P : RR^3 -> RR^2$ be given by $P(x, y, z) = (x, y)$. Then
  $"null" P = {(0, 0, z) : z in RR}$, so $dim "null" P = 1$, and
  $"range" P = RR^2$, so $dim "range" P = 2$.
]

#qs(title: [Let $T : RR^3 -> RR^2$ be defined by $T(x, y, z) = (x + y, y + z)$.])[
  #pt(title: [Find the null space of $T$.])[
    #ans[
      We solve
      $ x + y = 0 quad and quad y + z = 0. $
      Hence $x = -y$ and $z = -y$, so every vector in the null space has the
      form $(-t, t, -t)$ for some $t in RR$. Therefore
      $ "null" T = {(-t, t, -t) : t in RR}. $
    ]
  ]

  #pt(title: [Is $T$ injective? Is it surjective?])[
    #ans[
      The null space is not trivial, so $T$ is not injective.
      To show surjectivity, let $(a, b) in RR^2$ and choose $(x, y, z) = (a, 0, b)$.
      Then $T(a, 0, b) = (a, b)$, so every vector in $RR^2$ lies in the range.
      Thus $T$ is surjective.
    ]
  ]
]

#ex(num: 7, loc: [section 3.2])[
  #ans[
    Suppose $S : RR^2 -> RR^2$ is injective. Then $"null" S = {0}$, so
    rank-nullity gives $2 = 0 + dim "range" S$. Hence $dim "range" S = 2$,
    which forces $"range" S = RR^2$. Therefore $S$ is surjective.
  ]
]

#aside[
  Coordinate computations are not a retreat from abstraction. They are often
  the quickest way to see which dimensions are being forced.
]

#blockquote(attribution: [A margin note to future you])[
  When the algebra starts to branch, count dimensions before expanding formulas.
]
