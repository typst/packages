#import "@local/ergo:0.1.0": *
#show: ergo-init.with(colors: "bw")

#set page(
  width: 18cm,
  height: 20cm,
  margin: 1em
)

#let unif = $<-^(\$)$


#prob([
  Let $G: {0, 1}^n -> {0, 1}^(2 n)$ be a pseudorandom generator.
  Let $s unif {0, 1}^n, r unif {0, 1}^(2 n)$ and $y = G(s)$.
  Consider the function $P_(r, y)$ defined by:
  1. On input $x in {0, 1}^n$, check that $G(x) xor r = y$.
  2. If true output $1$; otherwise, output $0$.

  Show for any PPT $cal(A)$ with input $(r, y)$ and output $x in {0, 1}^n$, $
    Pr[P_(r, y) (x) = 1 : x <- cal(A) (r, y)]
      &lt.eq nu(n).
  $
], [
  Consider the following sequence of manipulations: $
    &Pr[P_(r, y) (x) = 1 : x <- cal(A) (r, y), r <- {0, 1}^(2 n), y <- G(s), s <- {0, 1}^n] \
    &= Pr[G(x) xor r = y : x <- cal(A) (r, y), r <- {0, 1}^(2 n), y <- G(s), s <- {0, 1}^n] \
    &= Pr[G(x) xor r = G(s) : x <- cal(A) (r, G(s)), r <- {0, 1}^(2 n), s <- {0, 1}^n] \
    &= Pr[G(x) = r xor G(s) : x <- cal(A) (r, G(s)), r <- {0, 1}^(2 n), s <- {0, 1}^n] \
    &= Pr[G(x) = r xor a : x <- cal(A) (r, a), r <- {0, 1}^(2 n), a <- {0, 1}^(2 n)] \
    &= Pr[G(x) = r xor a : x <- cal(A) (r xor a, a), r <- {0, 1}^(2 n), a <- {0, 1}^(2 n)] \
    &= Pr[G(x) = b : x <- cal(A) (b, a), b <- {0, 1}^(2 n), a <- {0, 1}^(2 n)] \
    &= Pr[G(x) = G(d) : x <- cal(A) (G(d), a), d unif {0, 1}^(2 n), a unif {0, 1}^(2 n)] Pr[b in G({0, 1}^(2 n)) : b unif {0, 1}^(2 n)]\
      &quad + 0 dot Pr[b in.not G({0, 1}^(2 n)) : b unif {0, 1}^(2 n)]\
    &lt.eq Pr[G(x) = G(d) : x <- cal(A) (G(d), a), d unif {0, 1}^(2 n), a unif {0, 1}^(2 n)] \
    &= Pr[G(cal(A) (G(d), a)) = G(d) : d unif {0, 1}^(2 n), a unif {0, 1}^(2 n)] \
    &lt.eq nu(n),
  $ where $nu(n)$ is a negligible function.
  Notice we used the fact that that $G$ is a one-way function because it's a pseudorandom generator.
  Further, we equated $cal(A) (r, a)$ and $cal(A)(r xor a, a)$, since the adversary $cal(A)$ can recover $r$ with $(r xor a) xor a$.
  Therefore, we have that for any PPT $cal(A)$ with input $(r, y)$ and output $x in {0, 1}^n$, we have $
    Pr[P_(r, y) (x) = 1 : x <- cal(A) (r, y)]
      &lt.eq nu(n).
  $
])

