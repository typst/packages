#import "../src/lib.typ": *

#show: homework.with(
  title: "Stochastic Differential Equations and (Deep) Generative Models",
  author: "Reza Rezvan",
  email: "rezvan@school.com",
  course: "SDE 101",
  date: datetime.today(),
)

#set math.equation(numbering: "(1)")
#set enum(numbering: "1)")
#set text(font: "New Computer Modern")

#definition(title: "Definition of SDEs")[
  A stochastic differential equation (SDE) is an equation that describes the evolution of a random process over time.

  The general form of an SDE can be written as,

  $
  d x(t) = underbrace((x(t), t), "drift") thin d t + underbrace(L(x(t), t), "diffusion") d beta(t),
  $

  where,

  - $x(t)$ is the random process,
  - $f(x(t), t)$ is the drift term (deterministic part),
  - $L(x(t), t)$ is the diffusion term (stochastic part),
  - $d beta(t)$ is standard Brownian motion (Wiener process),
]

#problem(title: "Vector Spaces and Subspaces")[
  Let $V$ be a vector space over a field $F$. Prove the following properties:

  1. The zero vector $0_V$ is unique.
  2. For each $v in V$, the additive inverse $-v$ is unique.
  3. If $a in F$ and $a dot v = 0_V$ for some $v in V$, then either $a = 0$ or $v = 0_V$.
]

*1. Uniqueness of the zero vector:*

#theorem(title: "Uniqueness of Zero Vector")[
  In any vector space $V$, the zero vector $0_V$ is unique.
]

#proof[
  Suppose there exist two zero vectors, $0_V$ and $0'_V$. By definition of a zero vector:
  $0_V + 0'_V = 0'_V$ (since $0_V$ is a zero vector)
  $0_V + 0'_V = 0_V$ (since $0'_V$ is a zero vector)

  Therefore, $0_V = 0'_V$, proving that the zero vector is unique.
]

*2. Uniqueness of the additive inverse:*

#lemma(title: "Uniqueness of Additive Inverse")[
  For each vector $v$ in a vector space $V$, the additive inverse $-v$ is unique.
]

#proof[
  Suppose $v in V$ has two additive inverses, $w$ and $w'$. Then:
  $v + w = 0_V$ and $v + w' = 0_V$

  Adding $w$ to both sides of the second equation:

  $w + (v + w') = w + 0_V$
  $(w + v) + w' = w$
  $0_V + w' = w$
  $w' = w$

  Therefore, the additive inverse is unique.
]

#pagebreak()
#problem(title: "Comparison of Different Vector Space Properties")[
  Compare and contrast the following vector spaces.
]

#columns(count: 2)[
  #definition(title: "Real Vector Spaces")[
    A vector space over the field of real numbers $RR$.

    *Properties:*
    - Contains real-valued vectors
    - Operations: addition and scalar multiplication by real numbers
    - Examples: $RR^n$, continuous functions on an interval
  ]
][
  #definition(title: "Complex Vector Spaces")[
    A vector space over the field of complex numbers $CC$.

    *Properties:*
    - Contains complex-valued vectors
    - Operations: addition and scalar multiplication by complex numbers
    - Examples: $CC^n$, analytic functions
  ]
]

#pagebreak()
#problem(title: "Linear Transformations")[
  Explore the properties of linear transformations between vector spaces.
]

#theorem(title: "Rank-Nullity Theorem")[
  Let $T: V -> W$ be a linear transformation between finite-dimensional vector spaces. Then:

  $"dim"("ker"(T)) + "di"("im"(T)) = "dim"(V)$
]

#proof[
  Let $K = "ker"(T)$ and let $\{v_1, v_2, ..., v_k\}$ be a basis for $K$.

  Extend this to a basis $\{v_1, ..., v_k, v_(k+1), ..., v_n\}$ for $V$.

  We claim that $\{T(v_(k+1)), ..., T(v_n)\}$ is a basis for $"im"(T)$.

  For linear independence, suppose $sum_(i=k+1)^n a_i T(v_i) = 0$. Then $T(sum_(i=k+1)^n a_i v_i) = 0$, which means $sum_(i=k+1)^n a_i v_i \in K$.

  This implies $sum_(i=k+1)^n a_i v_i = sum_(j=1)^k b_j v_j$ for some scalars $b_j$.

  By the linear independence of the basis of $V$, all coefficients must be zero. So $\{T(v_(k+1)), ..., T(v_n)\}$ is linearly independent.

  For spanning, any $w in "im"(T)$ can be written as $w = T(v)$ for some $v in V$. We can write $v = sum_(i=1)^n c_i v_i$. Since $T(v_1) = ... = T(v_k) = 0$, we have $w = sum_(i=k+1)^n c_i T(v_i)$.

  Thus, $"dim"("im"(T)) = n - k = "dim"(V) - "dim"("ker"(T))$.
]

#columns(count: 2)[
  #corollary(title: "Injective Case")[
    If $T$ is injective, then $"ker"(T) = \{0\}$, so $"dim"("im"(T)) = "dim"(V)$.

    This means $T$ preserves dimension.
  ]
][
  #corollary(title: "Surjective Case")[
    If $T$ is surjective, then $"im"(T) = W$, so $"dim"("ker"(T)) = "dim"(V) - "dim"(W)$.
    If $"dim"(V) < "dim"(W)$, then $T$ cannot be surjective.
  ]
]
