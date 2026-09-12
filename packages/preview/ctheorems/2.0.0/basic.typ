#import "lib.typ": *
#import thm-state: thm-restate
#import thm-themes.ams: *
#show: thm-rules.with(qed-symbol: $square$)

#set document(title: "Basic")
#set page(width: 16cm, height: auto, margin: 1.5cm)
#set heading(numbering: "1.")
#show heading: set block(below: 1em)

#let theorem = theorem.with(
  outset: 1em,
  spacing: 2em,
  fill: rgb("#eeffee"),
)


= Random variables

#definition[Expectation][
  The expectation of a random variable $X$ on a probability space $(Omega, cal(E), PP)$ is $
    EE[X] = integral X dif PP,
  $ whenever well-defined.
] <expectation>

#remark[
  We require at least one of $EE[X^+], EE[X^-]$ to be finite.
]

#proposition[
  For any $A in cal(E)$, $
    PP(X in A) = EE[bold(1)_A (X)].
  $
] <prob-exp>

#theorem[Markov][
  Let $X >= 0$. For all $a > 0$, $
    PP(X > a) <= EE[X] / a.
  $
] <markov>
#proof([of @markov], defer: true)[
  $
    PP(X > a)
      &= EE[bold(1)_((a, oo))(X)]   #tag[(@prob-exp)] \
      &<= EE[(X / a) bold(1)_((a, oo))(X)] \
      &<= EE[X] / a. #qedhere
  $
]

#corollary[Chebyshev][
  Let $EE[X] = mu$, $"var"[X] = sigma^2$. Then, $
    PP(|X - mu| >= k sigma) <= 1 / k^2.
  $
] <chebyshev>


#counter(heading).update(0)
#set heading(numbering: "A.")
= Appendix

#thm-restate()
