# epsilon

*Numerical root-finding in [Typst](https://typst.app/).*

## Overview

*epsilon* is a package which allows numerical root finding directly in Typst.
It supports various methods such as Newton, bisection and secant.

The easiest way to use this package is the `find-root` function.
It automatically selects a method based on the provided arguments.
However, you can also call the respective methods directly if you want to.
See the following example
```typst
#import "@preview/epsilon:0.1.0": *

// Find the root of $f(x) = cos(x) - x$ using the bisection method implicitly
// returns 0.7390851336531341
#find-root(x => calc.cos(x) - x, 0, x1: 2)
// Find the root of $f(x) = cos(x) - x$ using the Newton method implicitly
// returns 0.7390851332151607
#find-root(x => calc.cos(x) - x, 0, f-d: x => - calc.sin(x) - 1)
// Find the root of $f(x) = cos(x) - x$ using the secant method explicitly
// returns 0.7390851332151612
#secant(x => calc.cos(x) - x, 0, 2)
```

For more detailed examples see the [manual](https://gitlab.com/netzwerk2/epsilon/-/blob/v0.1.0/docs/epsilon-docs.pdf).
It also includes detailed documentation of all the functions.

## Supported Methods
- bisection
- Newton
- secant