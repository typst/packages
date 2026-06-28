// Shared showcase body — an original mini-chapter that exercises every Scholia
// device. Include-only: it has NO `#show: scholia`, so don't compile it directly
// (theorems need the wrapper to be skinned). The entry files content.typ / dark.typ
// / book.typ apply the wrapper with different options and `#include` this body.
#import "@preview/scholia:0.1.0": *

#cover(
  "Descent",
  subtitle: "A fill-in primer on convexity and first-order methods",
  author: "Eric Yang",
  date: datetime.today().display("[month repr:long] [day], [year]"),
  kicker: "Optimization · Notebook 4",
)

= Convex Functions

A function is #keyword[convex] when its graph never climbs above any of its chords.
That single picture — a bowl with no false bottoms — is why some optimization is easy
and the rest is a fight to make problems look like this one.

#note[
Read this layer for the shape of the idea; fill the blanks and close the proof gaps to
make it yours. #whisper[The margin is where you argue back with the text.]
]

#definition[convex function][
$f: bb(R)^n -> bb(R)$ is convex if, for every $x, y$ and $lambda in [0, 1]$,
$ f(lambda x + (1 - lambda) y) <= lambda f(x) + (1 - lambda) f(y). $
] <def:convex>

#recall[Which way does the inequality face — and what happens to it for concave $f$?]

== The first-order picture

Once $f$ is differentiable, convexity wears a cleaner face: every tangent plane is a
global _underestimate_ of the function.

#lemma[first-order condition][
$f$ is convex if and only if, for all $x, y$,
$ f(y) >= f(x) + nabla f(x)^top (y - x). $
] <lem:fo>

#block-head[Reading the gradient]
The gradient $nabla f(x)$ is the slope of the best linear underestimate at $x$. A point
where $nabla f(x) = 0$ is therefore not merely flat — by @lem:fo it is a *global*
minimum. Convexity turns a local check into a global guarantee.

#trigger[Reach for @lem:fo whenever you must turn the words "it's convex" into an
inequality you can actually use.]

= Gradient Descent

#definition[$L$-smoothness][
$f$ is $L$-smooth if its gradient is $L$-Lipschitz:
$ ||nabla f(x) - nabla f(y)|| <= L ||x - y|| quad "for all" x, y. $
] <def:smooth>

Two assumptions now sit on the table — convex (a global shape) and smooth (a local
speed limit). Together they are exactly what a first-order method needs to make
promises.

#theorem[descent lemma][Nesterov §2.1][
If $f$ is $L$-smooth then, for all $x, y$,
$ f(y) <= f(x) + nabla f(x)^top (y - x) + L / 2 ||y - x||^2. $
] <thm:descent>

#proof[
Write $f(y) - f(x)$ as the integral of $nabla f$ along the segment from $x$ to $y$,
then add and subtract $nabla f(x)$ inside the integral.
#TODO[bound the leftover gradient difference using @def:smooth]
]

#corollary[the $O(1 slash t)$ rate][
On a convex, $L$-smooth $f$, gradient descent $x_(t+1) = x_t - eta nabla f(x_t)$ with
step $eta = 1 slash L$ satisfies
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

#example[one step on a quadratic][
For $f(x) = 1/2 x^top A x$ with $0 prec.eq A prec.eq L I$, the update with step
$eta = 1/L$ contracts the error: $||x_(t+1) - x^*|| = ||I - eta A|| dot ||x_t - x^*||$.
]

#yourturn[
Derive the contraction yourself. Expand $||x_(t+1) - x^*||^2$ for the quadratic,
then find the $eta$ that minimises the factor. What is the optimal $eta$?
$ eta^* = #fillin(width: 2cm) $
#workspace(n: 3)
]

#sidenote[What fails when $f$ is convex but *not* smooth? Subgradients survive, but the
rate slows to $O(1 slash sqrt(t))$.]

=== Stochastic steps, in one line

#remark[
Replace $nabla f$ with any unbiased estimate and the same machinery survives in
expectation — the quiet engine inside essentially every modern learning system.
]
