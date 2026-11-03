// example.typ — the Scholia showcase. Compile THIS file to see every device.
// For dark or book mode, uncomment an option below (mirrors template/main.typ).
#import "@preview/scholia:0.1.0": *

#show: scholia.with(
  // theme: "dark",   // light (default) | dark (slate)
  // prose: "book",   // notes (default) | book (first-line indent, tight)
)

#cover(
  "Descent",
  subtitle: "A fill-in primer on convexity and first-order methods",
  author: "Eric Yang",
  date: datetime.today().display("[month repr:long] [day], [year]"),
  kicker: "Optimization · Notebook 4",
)

// ===========================================================================
// NOTATION AND SETUP
// Shows: notation, axiom, assumption, keyword, sidenote, recall
// ===========================================================================

= Notation and Setup

Before the main arguments, we fix symbols and state the #keyword[standing hypotheses]
that hold throughout without being repeated.

#notation[Throughout this chapter][
  $x, y, z in bb(R)^n$ are vectors; $f, g: bb(R)^n -> bb(R)$ are real-valued.
  The Euclidean inner product is $x^top y$ and the induced norm $||x|| = sqrt(x^top x)$.
  We write $f^* = inf_x f(x)$ for the global minimum value and $x^*$ for any minimiser.
]

#axiom[Finite-dimensional Hilbert space][
  $bb(R)^n$ is equipped with the standard inner product $x^top y$, which is bilinear,
  symmetric, and positive-definite. Every bounded sequence has a convergent subsequence
  (Bolzano–Weierstrass).
]

#assumption[Regularity][
  Unless stated otherwise, $f$ is #keyword[convex], continuously differentiable, and
  bounded below: a minimiser $x^*$ exists so that $f^* > -infinity$.
]

#sidenote[Non-differentiable convex $f$ needs *subgradients* — the subject of a later notebook.]

#recall[Why must we assume $f^* > -infinity$? Give a convex $f$ for which it fails.]

// ===========================================================================
// CONVEX FUNCTIONS
// Shows: note + whisper, definition, lemma, cross-ref @, block-head, trigger
// ===========================================================================

= Convex Functions

A function is #keyword[convex] when its graph never climbs above any of its chords.
That single picture — a bowl with no false bottoms — is why some optimisation is easy
and the rest is a fight to make problems look like this one.

#note[
  Read this layer for the shape of the idea; fill the blanks and close the proof gaps
  to make it yours. #whisper[The margin is where you argue back with the text.]
]

#definition[convex function][
  $f: bb(R)^n -> bb(R)$ is #keyword[convex] if, for every $x, y$ and $lambda in [0, 1]$,
  $ f(lambda x + (1 - lambda) y) <= lambda f(x) + (1 - lambda) f(y). $
  It is #keyword[strictly convex] when the inequality is strict for $x != y, lambda in (0,1)$.
] <def:convex>

#recall[Which way does the inequality face — and what becomes of it for concave $f$?]

== The first-order picture

Once $f$ is differentiable, convexity wears a cleaner face: every tangent plane is a
global _underestimate_ of the function.

#lemma[first-order condition][
  $f$ is convex if and only if, for all $x, y$,
  $ f(y) >= f(x) + nabla f(x)^top (y - x). $
] <lem:fo>

#block-head[Reading the gradient]
The gradient $nabla f(x)$ is the slope of the best linear underestimate at $x$.
A point where $nabla f(x) = 0$ is therefore not merely flat — by @lem:fo it is a
*global* minimum. Convexity turns a local check into a global guarantee.

#trigger[Reach for @lem:fo whenever you must turn "it's convex" into an inequality.]

// ===========================================================================
// GRADIENT DESCENT
// Shows: definition (L-smooth), theorem + tag badge, proof + claim + TODO,
//        corollary, table + label-it, proposition, conjecture,
//        example, yourturn + fillin + workspace, sidenote, remark
// ===========================================================================

= Gradient Descent

#definition[$L$-smoothness][
  $f$ is #keyword[$L$-smooth] if its gradient is $L$-Lipschitz:
  $ ||nabla f(x) - nabla f(y)|| <= L ||x - y|| quad "for all" x, y. $
] <def:smooth>

Two assumptions now sit on the table — convex (a global shape) and smooth (a local
speed limit on gradients). Together they are exactly what a first-order method needs
to make promises.

// The middle slot [Nesterov §2.1] is a visible source badge, independent of <thm:descent>.
#theorem[descent lemma][Nesterov §2.1][
  If $f$ is $L$-smooth then, for all $x, y$,
  $ f(y) <= f(x) + nabla f(x)^top (y - x) + L / 2 ||y - x||^2. $
] <thm:descent>

#proof[
  Write the remainder $r(y) = f(y) - f(x) - nabla f(x)^top(y-x)$ as an integral.

  #claim[
    $r(y) = integral_0^1 [nabla f(x + t(y-x)) - nabla f(x)]^top (y-x) d t.$
  ]

  Apply the triangle inequality, then bound the bracketed gradient difference
  using @def:smooth.
  #TODO[carry out the Lipschitz bound on $||nabla f(x + t(y-x)) - nabla f(x)||$]
]

#corollary[the $O(1 slash t)$ rate][
  On a convex, $L$-smooth $f$, gradient descent $x_(t+1) = x_t - eta nabla f(x_t)$
  with step $eta = 1 slash L$ satisfies
  $ f(x_t) - f^* <= (||x_0 - x^*||^2) / (2 eta t). $
  Bounded suboptimality, no luck required — it leans on @thm:descent and @lem:fo.
] <cor:rate>

The cost of each assumption is legible in the rate it buys:

#table(
  columns: (1fr, auto),
  stroke: none,
  table.header[#label-it[assumptions]][#label-it[rate of $f(x_t) - f^*$]],
  table.hline(stroke: 0.4pt),
  [convex + $L$-smooth], [$O(1 slash t)$],
  [$mu$-strongly convex + $L$-smooth], [$O((1 - mu slash L)^t)$ — linear],
)

#proposition[strong convexity buys speed][
  If $f$ is additionally $mu$-strongly convex, the rate of @cor:rate sharpens to linear:
  $f(x_t) - f^* <= (1 - mu slash L)^t (f(x_0) - f^*)$.
]

#conjecture[lower bound on first-order methods][
  No deterministic first-order method on convex, $L$-smooth objectives can achieve
  convergence faster than $O(1 slash t)$ per gradient query without momentum.
  #whisper[Nesterov's accelerated gradient achieves $O(1 slash t^2)$ under the same
  assumptions — suggesting the tight lower bound is below $O(1 slash t)$. The exact
  constant is still an active research question.]
]

#example[one step on a quadratic][
  For $f(x) = 1/2 x^top A x$ with $0 prec.eq A prec.eq L I$, the gradient step
  $x_1 = x_0 - eta A x_0$ gives the error contraction
  $ ||x_1 - x^*|| = ||I - eta A|| dot ||x_0 - x^*||. $
  With $x^* = 0$: the worst-case shrink factor is $max(|1 - eta lambda_"min"|, |1 - eta lambda_"max"|)$.
]

#yourturn[
  Derive the contraction yourself. Expand $||x_(t+1) - x^*||^2$ for the quadratic
  $f(x) = 1/2 x^top A x$, then find the step $eta$ that minimises the contraction factor.
  What is the optimal $eta$?
  $ eta^* = #fillin(width: 2cm) $
  #workspace(n: 3)
]

#sidenote[What fails when $f$ is convex but *not* smooth? Subgradients survive,
but the rate slows to $O(1 slash sqrt(t))$.]

=== Stochastic steps, in one line

#remark[
  Replace $nabla f$ with any unbiased gradient estimate and the same convergence
  machinery survives in expectation — the quiet engine inside essentially every modern
  learning system.
]
