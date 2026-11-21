#import "@preview/thyme:0.1.0": *
#import blog: *

#show: post.with(
  title: [Fixed Points in Program Semantics],
  subtitle: [Monotone operators on pointed lattices and the denotation of loops],
  author: "Ada Lovelace",
  monograph: "EWD-02",
  created: datetime(year: 2026, month: 10, day: 20),
  modified: datetime(year: 2026, month: 10, day: 27),
  summary: [Constructing loop semantics via Kleene iteration, monotone transformers, and tabular state invariants.],
  tags: ("semantics", "lattices", "pl"),
)

#epigraph(source: [Dana S. Scott, 1970])[
  Recursive definitions do not pull meaning out of thin air; they select the least fixed point of a continuous functional.
]

To assign a mathematical meaning to an unbounded `while` loop without appealing to operational step counts, we interpret program states over a pointed partial order#sidenote[In denotational semantics, the bottom element $bot$ represents non-termination rather than an erroneous machine state.] and compute fixed points of monotone transformers. As noted in @minimal-bundles, authoring prose, proofs, and executable code in one Typst file keeps every symbol consistent across the site.

= Lattices & Scott Continuity <kleene-fp>

#definition[Pointed $omega$-CPO & Scott Continuity][
  A partial order $(D, subset.eq.sq)$ is an _$omega$-complete partial order_ ($omega$-CPO) with least element $bot in D$ if every ascending chain $d_0 subset.eq.sq d_1 subset.eq.sq dots.c$ admits a least upper bound $union.sq.big_(n >= 0) d_n in D$.
][
  A map $F : D -> D$ is _Scott-continuous_ when it preserves suprema of ascending chains: $F(union.sq.big_(n >= 0) d_n) = union.sq.big_(n >= 0) F(d_n)$. Every Scott-continuous map is automatically monotone.
]

Whenever a state transformer is Scott-continuous#sidenote[Finite lattices satisfy the ascending chain condition automatically, so monotonicity alone implies continuity.], its least fixed point can be approximated constructively from $bot$:

#theorem[Kleene's Fixed-Point Theorem][
  Let $(D, subset.eq.sq, bot)$ be a pointed $omega$-CPO and $F : D -> D$ a Scott-continuous functional. Then the least fixed point $"lfp"(F)$ exists and equals
  $ "lfp"(F) = union.sq.big_(n = 0)^infinity F^n (bot). $
]

#proof[
  Since $bot subset.eq.sq F(bot)$, monotonicity yields $F^n (bot) subset.eq.sq F^(n+1)(bot)$ by induction on $n$. Writing $d^* = union.sq.big_(n >= 0) F^n (bot)$, continuity gives $F(d^*) = union.sq.big_(n >= 0) F^(n+1)(bot) = d^*$. For any pre-fixed point $e$ with $F(e) subset.eq.sq e$, induction shows $F^n (bot) subset.eq.sq e$ for all $n$, hence $d^* subset.eq.sq e$.
]

= Loop Denotation & Finite Iteration <loop-denotation>

For a `while` command over store domain $Sigma$, define the characteristic functional $Phi(g)(sigma) = "if" cal(B)[[b]] sigma "then" g(cal(C)[[c]] sigma) "else" sigma$. On finite abstract domains we compute $"lfp"(Phi)$ directly by worklist stabilization#footnote[Standard `#footnote[...]` calls are automatically routed into the right margin so proofs remain uninterrupted.]:

#zebraw(
  highlight-lines: (4,),
  ```rust
  // Iterative least fixed point on a finite lattice
  pub fn lfp<D: Eq + Clone>(bot: D, step: impl Fn(&D) -> D) -> D {
      let mut cur = bot;
      loop {
          let next = step(&cur);
          if next == cur { return cur; }
          cur = next;
      }
  }
  ```,
)

#recipe[Tracing Kleene Approximates][
  To verify how fast $F^n (bot)$ stabilizes on a small sign lattice, tabulate the first iterates side by side:

  #grid-table[
    | *Iterate* | $x < 0$ | $x = 0$ | $x > 0$ |
    | --- | --- | --- | --- |
    | $F^0 (bot)$ | $bot$ | $bot$ | $bot$ |
    | $F^1 (bot)$ | $bot$ | $0$ | $bot$ |
    | $F^2 (bot)$ | $bot$ | $0$ | $0$ |
  ]
]
