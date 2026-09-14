# axiom

A Typst Math utility library providing notation shortcuts for recurrent operators absent for typst vanilla. Covers operators from various fields like probability or analysis.

## Usage

```typst
#import "@preview/axiom:0.1.0": *

$ expec[X] = mu quad variance(X) = sigma^2 $
$ X tilde.op gauss(0, 1) $
$ argmax_(theta) f(theta) $
```

## Reference

### Operators

| Name | Renders |
|------|---------|
| `argmax` | argmax (with limits) |
| `argmin` | argmin (with limits) |
| `indicator` | 1 (with limits) |

### Linear algebra

| Name | Renders |
|------|---------|
| `diag` | diag |
| `rank` | rank |
| `span` | Span |

### Probability

| Name | Syntax | Renders |
|------|--------|---------|
| `expec` | `expec[X]`, `expec(X)` | E[X], E(X) |
| `econd` | `econd(X, Y)` | E[X\|Y] |
| `proba` | `proba(A)`, `proba[A]` | P(A), P[A] |
| `pcond` | `pcond(A, B)` | P[A\|B] |
| `filt` | `filt_t` | F_t |
| `variance` | `variance(X)` | Var(X) |
| `cov` | `cov(X, Y)` | Cov(X, Y) |
| `corr` | `corr(X, Y)` | Corr(X, Y) |
| `bias` | `bias(hat(theta))` | Bias |
| `mse` | `mse(hat(theta))` | MSE |
| `iid` | `tilde.op^iid` | i.i.d. |

### Probability distributions

| Name | Syntax | Renders |
|------|--------|---------|
| `gauss` | `gauss(mu, sigma^2)` | N(mu, sigma^2) |
| `uniform` | `uniform([a, b])` | U([a, b]) |
| `bernoulli` | `bernoulli(p)` | Ber(p) |
| `binomial` | `binomial(n, p)` | Bin(n, p) |
| `poisson` | `poisson(lambda)` | Pois(lambda) |
| `exponential` | `exponential(lambda)` | Exp(lambda) |
| `gammadist` | `gammadist(alpha, beta)` | Gamma(alpha, beta) |
| `betadist` | `betadist(alpha, beta)` | Beta(alpha, beta) |
| `chisq` | `chisq(n)` | chi^2(n) |
| `student` | `student(n)` | T(n) |

### Analysis / topology

| Name | Renders |
|------|---------|
| `interior` | Int |
| `cl` | cl |
| `fr` | fr |
| `diam` | diam |
| `conv` | conv |

## Contributing

Contributions are welcome to complete the package with more commonly used operators and notations!
