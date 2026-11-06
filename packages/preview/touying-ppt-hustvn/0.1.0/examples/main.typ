#import "@preview/theorion:0.3.2": *
#import cosmos.simple: *
#show: show-theorion
#set heading(numbering: "1.1")

#import "@preview/touying:0.6.1": *
#import "@preview/touying-ppt-hustvn:0.1.0": *

#show: hust-theme.with(
  theme: "red",
  aspect-ratio: "16-9",
  config-common(
    frozen-counters: (theorem-counter,), // freeze theorem counter for animation
    datetime-format: "[day padding:none] [month repr:long] [year]",
  ),
  config-info(
    title: [An introduction to finite field theory],
    subtitle: [(IT4015 gatekept this absolute\ cinema of pure math from us sadge)],
    author: [Anonymous],
    date: datetime.today(),
  ),
)

#title-slide()

#outline-slide()

= Introduction

== Introduction

A field can be roughly described as a set with the operations $+$, $-$, $times$
and $div$, following the usual familiar rules (the *field axioms*) we are used
to.

#pause

Most field we encounter are *infinite* fields, like the real and complex
fields. But what about *finite* fields?

== The integer modulo $p$

We know that $ZZ_n$ forms a *ring* for every $n >= 1$, but can this be
extended to a field?

#pause

The answer is *sometimes*. More specifically, if $n$ is prime, then we have the
simplest example of a finite field.

#pause

But why does this only works for prime numbers?

#pagebreak()

For every $n >= 1$, $ZZ_n$ behaves _almost_ like a field, except that inverses
might not exist for every $m in ZZ_n$.

#pause

If $n$ can be factorized into $n = p q$ (where $p, q > 1$), then the inverse of
$p$ (and $q$) does not exist.

#pause

When $n$ is prime, we can prove that every element $p in ZZ_n$ has an inverse,
as the map $f: ZZ_n -> ZZ_n$:

$ f(q) = p q mod n $

is bijective.

== The polynomials modulo $g(x)$

With the same idea, we can construct a more general finite fields as follows.

Let $p$ be a prime number and $g(x) in ZZ_p [x]$ be a prime#footnote[A prime
polynomial is a polynomial that can't be factorized into two non-constant
polynomials.] polynomial with degree $m$.

Then, the polynomials with coefficients in $ZZ_p$ and degree less than $m$ form
a finite field.

#pause

*Why?* The same reason as $ZZ_p$.

#pause

#let GL = "GL"

Let's call this field $GL_p (g)$.

#pagebreak()

*How many elements are there in this field?*

#pause

Since there are only $m$ coefficients and $p$ values each, the answer is $p^m$.

#pause

*What if $m = 1$?*

#pause

This field is the same field as $ZZ_p$.

#pause

It turns out that, all finite fields of size $p^m$ are isomorphic to $GL_m
(g)$ for every prime $g$. And finite fields with other sizes do not exist!

= Proving isomorphism

== Primitive elements

Given a field $FF$, some $alpha in FF^*$#footnote[$FF^*$ is just $FF$ excluding
zero (the additive identity element).] is a *primitive element* of $FF$ if repeated
multiplication of $alpha$ with itself can produce all elements of $FF^*$, i.e.
for every $beta in FF^*$, there exists some $n in NN$ such that $ beta =
alpha^n. $

#pause

// We know that by Lagrange's theorem#footnote[This theorem states that the order
// of any subgroup must divides the order of the group, if the group is finite.],
This is equivalent to $alpha$ having a (multiplicative) order of $|FF| - 1$.

#pause

In a finite field $FF$, we can count the number of primitive elements.

#pagebreak()

#theorem[
  If $FF$ is a finite field and $n$ is a factor of $|FF| - 1$, then the number
  of elements with order $n$ is exactly $phi(n)$, where $phi$ is Euler's totient
  function.
]

#pause

// #proof[
*Proof.*
By Lagrange's theorem, if some $beta in FF$ has order $n$, then $n divides
  |FF| - 1$.

#pause

Such a $beta$ generates a (multiplicative) subgroup with order $n$ that is
isomorphic to $ZZ_n$. The $n$ elements in this subgroup coincides with the $n$
roots of the polynomial $x^n - 1$ in the field $FF$, i.e. elements with order
at most $n$. So the number of elements with order $n$ in $FF$ is exactly
$phi(n)$.

However, there is also the case where $n divides |FF| - 1$ but no such $beta$
does not exist.

#pagebreak()

But if we take the sum of all $phi(n)$, we have:

$ sum_(n divides |FF| - 1) phi(n) = |FF| - 1 = |FF^*|. $

#pause

The left-hand side expression is an upper bound of the number of elements with
some order $n$, while the right-hand side expression is the number of elements
in $FF$ with order (excluding zero), so this equality means that
all $n$ has some $beta$ with order $n$.
#align(right, math.qed)

#pause

From this theorem, we know that the number of primitive elements in a finite
field $FF$ is $phi(|FF| - 1)$.

== Field characteristic

Since $FF$ is a primitive field, we know that $1$ (the multiplicative identity)
must have an (additive) order $n$. We call $n$ the *characteristic* of $FF$.

#pause

Then, we can see that there seems to be a $ZZ_n$ in $FF$. Multiplication between
two multiples of 1 (in $FF$) corresponds to multiplication between corresponding
elements of $ZZ_n$.

#pause

But since multiplication of two non-zero elements of $FF$ is non-zero, the
products of two non-zero elements of $ZZ_n$ must also be non-zero.
This can only happen if $n$ is a prime.

#theorem[
  The characteristic of a finite field is prime.
]

== $FF[x]$ vs. $ZZ_p [x]$

Now that we know that $ZZ_p$ is a part of $FF$, we now need to differentiate
between the two polynomial rings: $FF[x]$ and $ZZ_p [x]$.

#pause

Before, when we said $g$ is a prime polynomial, we meant that $g$ is prime in
$ZZ_p [x]$.

#pause

However, $g$ might be factorable in $FF[x]$.

#pause

A helpful analogy is that even though $5$ is a prime number (in the traditional
sense), it can be factored into two _Gaussian primes_: $5 = (2 + i)(2 - i)$.

== Minimal polynomials

Given a finite field element $beta in FF$. A polynomial $p$ is a *minimal
polynomial* of $beta$ if and only if it's the polynomial in $ZZ_1 [x]$ with the
smallest degree that has $beta$ as a root.

By polynomial division, we know that $p$ must divides all polynomials (in $ZZ_1
[x]$) taking $beta$ as a root.

#pause

By Lagrange's theorem, we know that all field elements are roots of $x^abs(F) - x$,
so all minimal polynomials are factors of this polynomial as well.

#pause

In fact, each prime factor of this polynomial is a minimal polynomial of a
subset of elements in $FF$.

== Field homomorphism

Given an element $beta$ of a field $FF$ with characteristic $p$ and and some
polynomial $f$ that has $beta$ as root, we can establish a homomorphism between
$GL_f (p)$ and $FF$ as follows:

$ sigma: GL_f (p) &-> FF\ g &-> g(beta). $

#pause

If $f$ is a minimal polynomial of $beta$, then this homomorphism is injective.

#pause

If $beta$ is a primitive element of $FF$, then this homomorphism is surjective.

#pause

Hence, if $f$ is a minimal polynomial of a primitive element $beta$, $FF$ is isomorphic
to $GL_f (p)$. And this also implies that the size of a finite field must be
a prime power.

== Field isomorphism

We are not done. What we just did is proving $FF$ is isomorphic to some $GL_f
(p)$. Actually, we can freely pick $f$ as we want.

#pause

Assuming that $f$ has some root $beta$, then we have a surjective
homomorphism from $GL_g (p)$ to $FF$.

#pause

But since the two fields have the same size, this homomorphism has to be
injective as well, hence isomorphism!

#pause

Now that we see our argument works with all polynomials that has at least one
root, let's try to prove that all prime polynomials have this property.

#pagebreak()

#theorem[
  Prime polynomial $g$ with degree $m$ is a factor of $x^p^m - x$.
]

#pause

Consider the polynomial field $GL_p (g)$. Then, all elements of this field are
roots of $x^p^m - x$, including the polynomial $beta(x) = x$. Hence, $x^p^m - x$
equals the zero polynomial modulo $g$, or $g$ is a factor of $x^p^m - x$.

#pause

So all finite fields with the same size are isomorphic. Finally!

#pause

But is there a finite field for every prime power size we want? Or equivalently,
is there a prime polynomial in $ZZ_p$ of any degree $m$?

= Proving existence

== Freshman's dream

We know that $(a + b)^n != a^n + b^n$.

#pause

But this actually holds in $ZZ_p$ when $n = p$ is a prime.

#pause

Why? Consider the difference:

$ (a+b)^n - (a^n + b^n) = sum_(k = 1)^(n - 1) binom(n, k) a^k b^(n - k). $

Since $n$ is prime, $binom(n, k)$ is zero (on $ZZ_n$) for all $k$ from $1$ to $n - 1$ (this
does not hold for $k = 0$ or $k = n$ though), so the difference evaluates to $0$.

#pause

Note that $a$ and $b$ itself does not to be in $ZZ_p$, so the fact is that this
result also holds if $a$ and $b$ are field elements of a finite field $FF$ with
characteristic $p$.

== Roots of prime polynomials

From this result, it follows that:

#theorem[
  If $FF$ is a field with characteristic $p$, $f$ is a polynomial with
  coefficients in $FF$, then $f(x)^p = f(x^p)$ (polynomial equality) if and only
  if all the coefficients of $f$ are multiples of $1$, the (multiplicative)
  identity of $FF$.
] <thr-freshman-poly>

#pause

Hence, if $beta$ is a root of a prime polynomial $f$, then so does $beta^p$,
$beta^p^2$, and so on. This sequence continues until there is a cycle at
$beta^p^n = beta$.

#pagebreak()

Now, consider the polynomial $g(x) = product_(k = 0)^(n - 1) (x - beta^p^k)$.

#pause

This polynomial satisfies the conditions of @thr-freshman-poly, so all of its
coefficients are multiples of 1. But as prime $f$ divides $g$, the two
must be equal. Hence,

#pause

#theorem[
  If $beta in FF$ is a non-zero root of a prime factor $f$ of $x^p^m - x$, then
  $f$ can be written as
  $ f(x) = product_(k = 0)^(n - 1) (x - beta^p^k), $
  for some $n divides m$.
]<thr-prime-factor>

#pagebreak()

By evaluating the derivative of $x^p^m - x$, we know that this polynomial
can not have a repeated root, and so do all of its prime factors. So if we
denote $N(n)$ as the number of prime factors of $x^p^m - x$ with degree $n$,
then

$ p^m = sum_(n divides m) n N(n) $

#pause

From this, we have $p^n >= n N(n)$ for all $n$. Substituting this in yields

#pause

$ m N(m) >= p^m - sum_(n divides m\ n != m) p^n > 0 $

#pause

Hence, $N(m) > 0$, which confirms the existence of a prime polynomial of degree
$m$.

= Application: Linear-Feedback Shift Registers

== Linear-Feedback Shift Registers

*Linear-Feedback Shift Registers* (LFSRs) are a type of shift register that
have a special property: the output of the register is a linear combination
of the last $m$ outputs.

#pause

It could be thought of as a sequence of bits (field elements of $ZZ_2$) $c_0,
c_1, ...$ such that

$
  c_n = alpha_1 c_(n - 1) + alpha_2 c_(n - 2) + ... + alpha_m c_(n - m), forall
  n >= m,
$

where $alpha_1, alpha_2, ..., alpha_m in ZZ_2$ are the coefficients of the LFSR.

#pause

Since LFSRs are used to generate random sequences, it is important to know for
which values of $alpha_1, alpha_2, ..., alpha_m$ will give the LFSR a *long cycle
length*.

== Cycle length upper bound

By looking at the state of an LFSR, we can have an upper bound for the cycle
length as follows:

#theorem[
  The maximal cycle length of an LFSR is $2^m - 1$.
] <thr-upper-bound-lfsr>

Here, the $-1$ denotes the state where $c_(n - 1) = c_(n - 2) = ... = c_(n - m)
= 0$, which is a terrible state for a random number generator to continue on.

== Feedback polynomial

Since LFSRs are just linear recurrences with constant coefficients, we can
consider the characteristic polynomial

#pause

$ f(x) = x^m + alpha_1 x^(m - 1) + alpha_2 x^(m - 2) + ... + alpha_m $

Note that here we substituted the minus signs by plus signs, since they are the
same thing on $ZZ_2$. This is called the *feedback polynomial* of the LFSR.

#pause

There is a very interesting result that

#theorem[
  A LSFR attain maximal cycle length if its feedback polynomial is a minimal
  polynomial of a primitive element $lambda$ of $GL(p^m)$.
]

== Explicit formula of $c_n$

In this case, since minimal polynomials are prime, by @thr-prime-factor, its
roots must be $lambda, lambda^2, ..., lambda^2^(m - 1)$, which are all distinct).
Hence, there exists field elements $beta_0, beta_1, ..., beta_(m - 1)$ such that

$ c_n = sum_(i = 0)^(m - 1) beta_i lambda^(n 2^i). $

== Proving optimality of primitive polynomials

So if $N$ is the period of $c_n$, then,

$
  0 = c_(n + N) - c_n = sum_(i = 0)^(m - 1) beta_i lambda^(n 2^i) (lambda^(N 2^i) -
    1).
$

Consider the polynomial $P(x) = sum_(i = 0)^(m - 1) beta_i (lambda^(N 2^i) - 1)
x^(2^i)$. Then, $P(lambda^j) = 0$ for all sufficiently large#footnote[Actually
LFSRs are reversible, so this holds for all $j$.] $j$.

#pause

But since $lambda$ is a primitive element, $P(t) = 0$ for all non-zero field
element $t != 0$. There are $2^m - 1$ of such elements, but $P$ is only a
polynomial of degree $2^(m - 1)$ at most, so $P = 0$.

#pagebreak()

Hence, $lambda^(N 2^i) = 1$ for some $i$ such that $beta_i != 0$. Note that if
$beta_i = 0$ for all $i$, then $c_n = 0$ for all $n$.

#pause

This implies that $2^m - 1 divides N 2^i$, which implies $N >= 2^m - 1$. By
@thr-upper-bound-lfsr, it must be the case that $N = 2^m - 1$, hence the
optimality.

#ending-slide(title: [THANK YOU!])
