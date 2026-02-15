# axiom

Math utility library providing commonly used operators, sets, and notation shortcuts.

## Usage

```typst
#import "axiom.typ": *

$ expec[X] = mu quad variance(X) = sigma^2 $
$ X tilde.op gauss(0, 1) $
$ argmax_(theta) f(theta) $
```

## Reference

### Classical sets

| Name | Renders | Variants |
|------|---------|----------|
| `NN` | N | `NN-star` |
| `RR` | R | `RR-plus`, `RR-minus`, `RR-star`, `RR-plus-star`, `RR-minus-star` |
| `ZZ` | Z | `ZZ-star` |
| `CC` | C | `CC-star` |
| `QQ` | Q | `QQ-star` |
| `KK` | K | `KK-star` |

```typst
$ x in NN quad f: RR -> RR-plus $
```

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
| `tr` | tr |
| `rank` | rank |
| `Span` | Span |
| `ker` | Ker |
| `im` | Im |

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

Contributions are welcome!
