# Moremath

Additional notation, constants and utilities for doing math in [Typst](https://typst.app/).

To use, just import:

```typst
#import "@preview/moremath:0.1.0": *
```

## Features

### Bracket sizing

When parentheses/brackets get too nested, it can be useful to force some of them to be larger.
`moremath` provides two helpers for this:

**`big`**: instead of writing `[(a + b) + c]`, to make the brackets bigger, you can write `big([(a + b) + c])`. This works for any kind of surrounding brackets/parentheses/braces.

**`bigp`**: instead of writing `((a + b) + c)`, to make the external parentheses bigger, you can write `bigp((a + b) + c)`. This is essentially the same as `big`, simply avoiding an extra set of parentheses.

### Numbered equations

Until we get better equation numbering built-in (e.g., for numbering only equations that are labelled), we have to manually indicate which equations to number. In order to make this easier, one can use our `numbered` function:

```typst
$ f(x) = x^2 $  // non-numbered

#numbered[ $ f(x) = x^2 $ <my-label> ]  // numbered
```

### Handy caligraphic letters

Caligraphic letters (e.g., `cal(G)`) are very common in math. In order to make them easier to typeset, and akin to Typst's built-in handy blackboard letters (e.g., `RR`), we provide aliases for caligraphic letters via double lowercase letters.
So, for example, `gg` becomes `cal(G)`, and `aa` becomes `cal(A)`. Except for `oo`, that's infinity, as in plain Typst.

### Additional notation

We also provide a bunch of additional notation for mathematics in general.
Do note, however, that what we provide is heavily skewed towards the author's current research interests :)

If you have suggestions for more notation to be added, feel free reach out and contribute!

#### Probability theory

- `indep`: Independence symbol (double perp).
- `nindep`: Crossed out `indep`, for denoting non-independence.
- `Pr`: alternative notation for probability.
- `Ex`: alternative notation for expectation.
- `Var`: variance.
- `Cov`: covariance.
- `ind`: indicator function, denoted by `bb(1)`.
- `iid`: text holding "iid". Can be used, e.g., as `X_1, ..., X_n ~^iid P`.

#### Analysis

- `oh`: small oh
- `Oh`: big oh
- `ohmega`: small omega
- `Ohmega`: big omega
- `Thetah`: big theta
- `deriv`: general derivative operator
- `dist`: upright "d", for metrics

#### Misc

- `sign`: sign function.
- `argmin`: `arg min` operator, supporting limits.
- `argmax`: `arg max` operator, supporting limits.
