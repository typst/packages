// ============================================================
// clari-docs — Summary Template
// ============================================================
// A compact, single-page-style A4 summary.
// All components (callout, definition, theorem, …) work identically
// to the slides document type — the same import, different #show rule.

#import "@preview/clari-docs:0.1.0": *

#show: clari-summary.with(
  category:    "math",
  theme:       "ocean",
  font:        "Fira Sans",
  font-size:   11pt,
  title:       "Linear Algebra — Key Results",
  subtitle:    "Semester 2 Summary Sheet",
  author:      "Jane Doe",
  institution: "University of Science",
  show-toc:    false,
)

= Vector Spaces

A #stress[vector space] $V$ over a field $FF$ is a set closed under vector addition
and scalar multiplication satisfying the usual eight axioms.

#definition[Subspace][
  A subset $W subset.eq V$ is a *subspace* if it is itself a vector space under the
  inherited operations. Equivalently: $0 in W$, closed under addition, and closed
  under scalar multiplication.
]

#callout(type: "tip")[
  To check a subspace it is enough to verify: $bold(0) in W$ and $W$ is closed
  under linear combinations.
]

= Linear Maps

#theorem(title: "Rank–Nullity", number: 1)[
  For any linear map $T: V -> W$ between finite-dimensional spaces:
  $ dim(V) = "rank"(T) + "nullity"(T). $
]

#proof[
  Choose a basis $e_1, dots, e_k$ for $ker(T)$ and extend to a basis of $V$.
  The images of the extension form a basis for $"im"(T)$. $square$
]

#lemma(title: "Injective iff trivial kernel")[
  $T$ is injective $iff$ $ker(T) = {bold(0)}$.
]

= Eigenvalues & Diagonalisation

#cols[
  *Finding eigenvalues*
  - Solve $det(A - lambda I) = 0$
  - Roots are the eigenvalues $lambda_i$

  *Diagonalisable iff*
  - $n$ linearly independent eigenvectors exist
  - Equivalently: algebraic $=$ geometric multiplicity for all $lambda_i$
][
  #callout(type: "warning")[
    Not every matrix is diagonalisable over $RR$. Rotation matrices $R(theta)$ for
    $theta eq.not 0, pi$ have no real eigenvalues.
  ]
]

= Inner Product Spaces

#definition[Inner Product][
  A map $angle.l dot, dot angle.r : V times V -> FF$ that is conjugate-symmetric,
  linear in the first argument, and positive-definite.
]

#theorem(title: "Cauchy–Schwarz")[
  $ |angle.l u, v angle.r|^2 <= angle.l u, u angle.r dot angle.l v, v angle.r. $
  Equality holds iff $u$ and $v$ are linearly dependent.
]

#highlight-box[
  *Gram–Schmidt* turns any basis into an orthonormal one — apply iteratively,
  subtracting projections onto already-orthonormalised vectors.
]
