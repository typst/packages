#import "@local/homework-template:0.1.0": *

#header(
  name: "Deep Hayer",
  course: "Math 110 — Linear Algebra",
  hw: "3",
  date: "March 4, 2026",
  professor: "Prof. Sheldon Axler",
)

// ─────────────────────────────────────────────────────────────────────────────
// Background definitions the homework builds on
// ─────────────────────────────────────────────────────────────────────────────

#defn(title: [vector space])[
  A _vector space_ over $FF$ is a set $V$ together with addition and scalar
  multiplication satisfying commutativity, associativity, additive identity,
  additive inverses, multiplicative identity, and distributive properties.
]

#notn(title: [$FF^n$])[
  $FF^n$ denotes the set of all lists of length $n$ with entries in $FF$
  (either $RR$ or $CC$).
]

// ─────────────────────────────────────────────────────────────────────────────
// Questions
// ─────────────────────────────────────────────────────────────────────────────

#qs(title: [Let $V$ be a vector space over $FF$. Prove each of the following.])[
  #pt(title: [The additive identity $0 in V$ is unique.])[
    #prf[
      Suppose $0$ and $0'$ are both additive identities in $V$. Then
      $ 0 = 0 + 0' = 0', $
      where the first equality uses the fact that $0'$ is an identity and
      the second uses the fact that $0$ is an identity. Hence $0 = 0'$.
    ]
  ]

  #pt(title: [Every element of $V$ has a unique additive inverse.])[
    #prf[
      Let $v in V$ and suppose $w, w'$ are both additive inverses of $v$. Then
      $ w = w + 0 = w + (v + w') = (w + v) + w' = 0 + w' = w'. $
      Hence the additive inverse is unique.
    ]
  ]

  #pt(title: [$0 v = 0$ for every $v in V$, where the left $0$ is the scalar and the right $0$ is the zero vector.])[
    #prf[
      For any $v in V$,
      $ 0 v = (0 + 0) v = 0 v + 0 v. $
      Adding $-(0 v)$ to both sides gives $0 = 0 v$.
    ]
  ]
]
#v(10em)
#qs(title: [Let $U = {(x_1, x_2, x_3, x_4) in FF^4 : x_1 + 2 x_2 = 0 "and" x_3 = 5 x_4}$.])[
  #pt(title: [Show that $U$ is a subspace of $FF^4$.])[
    #ans[
      We verify the three subspace conditions.

      #pt(title: [Additive identity])[
        $(0,0,0,0)$ satisfies $0 + 2(0) = 0$ and $0 = 5(0)$, so $0 in U$.
      ]

      #pt(title: [Closed under addition])[
        Let $(x_1,x_2,x_3,x_4),(y_1,y_2,y_3,y_4) in U$. Then
        $ (x_1+y_1) + 2(x_2+y_2) = (x_1+2x_2) + (y_1+2y_2) = 0+0 = 0, $
        and $x_3+y_3 = 5x_4+5y_4 = 5(x_4+y_4)$. So the sum is in $U$.
      ]

      #pt(title: [Closed under scalar multiplication])[
        Let $lambda in FF$ and $(x_1,x_2,x_3,x_4) in U$. Then
        $ lambda x_1 + 2(lambda x_2) = lambda(x_1 + 2x_2) = 0, $
        and $lambda x_3 = lambda(5 x_4) = 5(lambda x_4)$. So $lambda (x_1,dots,x_4) in U$.
      ]

      Hence $U$ is a subspace of $FF^4$.
    ]
  ]

  #pt(title: [Find a basis for $U$ and state $dim U$.])[
    #ans[
      The constraints $x_1 = -2x_2$ and $x_3 = 5x_4$ leave $x_2$ and $x_4$
      as free variables. Setting $(x_2, x_4) = (1,0)$ and $(0,1)$ gives
      $
        e_1 = (-2, 1, 0, 0), quad e_2 = (0, 0, 5, 1).
      $
      These two vectors span $U$ and are linearly independent, so
      ${e_1, e_2}$ is a basis and $dim U = 2$.
    ]
  ]
]
#v(17em)
#qs(title: [Suppose $T : V -> W$ is a linear map. Using the theorem below, answer the following.])[
  #thm(title: [fundamental theorem of linear maps])[
    $ dim V = dim "null" T + dim "range" T. $
  ]

  #pt(title: [If $dim V = 7$ and $dim W = 3$, what are the possible values of $dim "null" T$?])[
    #ans[
      Since $dim "range" T <= dim W = 3$, we have $dim "range" T in {0,1,2,3}$.
      By the fundamental theorem,
      $ dim "null" T = 7 - dim "range" T in {4, 5, 6, 7}. $
    ]
  ]

  #pt(title: [Can $T$ be injective if $dim V > dim W$?])[
    #ans[
      No. If $T$ is injective then $dim "null" T = 0$, so $dim "range" T = dim V > dim W$,
      contradicting $dim "range" T <= dim W$.
    ]
  ]
]
#qs(title: [Let $v_1, dots, v_m in V$ and define the linear map $T : FF^m -> V$ by $T(c_1, dots, c_m) = c_1 v_1 + dots.c + c_m v_m$.])[
  #eg(title: [span as range])[
    The range of $T$ is exactly $"span"(v_1, dots, v_m)$. For instance, if
    $v_1 = (1,0)$ and $v_2 = (0,1)$ in $FF^2$, then $T : FF^2 -> FF^2$ is
    the identity and $"range" T = FF^2$.
  ]

  #pt(title: [Show that $v_1, dots, v_m$ spans $V$ if and only if $T$ is surjective.])[
    #ans[
      $T$ is surjective $<==>$ $"range" T = V$ $<==>$ every $v in V$ is a linear
      combination of $v_1, dots, v_m$ $<==>$ $"span"(v_1, dots, v_m) = V$.
    ]
  ]

  #pt(title: [Show that $v_1, dots, v_m$ is linearly independent if and only if $T$ is injective.])[
    #ans[
      $T$ is injective $<==>$ $"null" T = {0}$ $<==>$ the only solution to
      $c_1 v_1 + dots.c + c_m v_m = 0$ is $c_1 = dots.c = c_m = 0$
      $<==>$ $v_1, dots, v_m$ is linearly independent.
    ]
  ]
]

#qs(title: [Let $vc(u) = (1, 2, -1)$ and $vc(v) = (3, 0, 2)$ in $RR^3$. Compute $vc(u) + 2 vc(v)$ and verify it lies in $"span"{vc(u), vc(v)}$.])[
  #note[
    The notation $vc(w)$ denotes a vector $w$ with an arrow, used here to
    distinguish vectors from scalars.
  ]

  #ans[
    $
      vc(u) + 2 vc(v) = (1,2,-1) + (6,0,4) = (7, 2, 3).
    $
    Since $(7,2,3) = 1 dot vc(u) + 2 dot vc(v)$, it is a linear combination
    of $vc(u)$ and $vc(v)$, so it lies in $"span"{vc(u), vc(v)}$.
  ]
]
