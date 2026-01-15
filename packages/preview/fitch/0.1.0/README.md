# Fitch

> Typst package for Fitch-style natural deduction proofs.

## Usage

Import the package in your Typst document:

```typst
#import "@preview/fitch:0.1.0: *"
```

Then, you can create proofs using the `proof` environment:

$A \rightarrow \neg A \quad \vdash \quad \neg A$

```typst
#proof(
  premise(1, $A -> not A$),
  subproof(
    assume(2, $A$),
    step(3, $not A$, rule: "MP 1, 2"),
  ),
  subproof(
    assume(4, $not A$),
    step(5, $not A$, rule: "R 4"),
  ),
  step(6, $not A$, rule: "LEM 2-3, 4-5"),
)
```

The output will look like this:

[![Example 1](docs/assets/example1.svg)](docs/assets/example1.typ)
[![Example 2](docs/assets/example2.svg)](docs/assets/example2.typ)
