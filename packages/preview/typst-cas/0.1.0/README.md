# typst-cas

A lightweight Computer Algebra System (CAS) written in pure Typst.

## Features

typCAS provides a set of tools for symbolic mathematics directly within your Typst documents.

- **Symbolic Arithmetic:** Simplification of algebraic expressions, fractions, and powers.
- **Calculus:** Derivatives (including higher-order), integrals (definite and indefinite), limits, and Taylor series expansions.
- **Equation Solving:** Linear and quadratic equation solvers, and polynomial factoring.
- **Matrix Algebra:** Symbolic matrix operations including determinant, inverse, transpose, and solving linear systems.
- **Parser:** Parse mathematical strings (e.g., "x^2 + 3x - 1") into CAS expressions.
- **Display:** Pretty-printing of expressions in standard mathematical notation.
- **Evaluation:** Numeric evaluation of expressions and substitution.

## Usage

Import the library in your Typst document:

// Use the local path or the package name if installed/published
#import "@preview/typst-cas:0.1.0": *
```

### Parsing and Display

You can parse strings into expressions and display them:

```typst
#let expr = cas-parse("x^2 + 3x - 1")
$ #cas-display(expr) $
```

### Derivatives

```typst
#let expr = cas-parse("sin(x) * x^2")
#let deriv = simplify(diff(expr, "x"))
$ d/dx (sin(x) dot x^2) = #cas-display(deriv) $
```

### Integration

```typst
#let expr = cas-parse("x^2")
#let result = definite-integral(expr, "x", 0, 1)
$ integral_0^1 x^2 dx = #cas-display(result) $
```

### Solving Equations

```typst
#let eq = cas-parse("x^2 - 4")
#let solutions = solve(eq, 0, "x")
$ x^2 - 4 = 0 arrow.r.double x = #solutions.map(s => cas-display(s)).join(" or ") $
```

## License

MIT License. See LICENSE file for details.
