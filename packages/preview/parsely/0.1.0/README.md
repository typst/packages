# Parsely

_Parse equations with Typst_.

[![Manual](https://img.shields.io/badge/v0.1.0-manual.pdf-green)](https://github.com/Jollywatt/typst-parsely/releases/download/v0.1.0/manual.pdf)

Tools to parse Typst equations into structured syntax trees using user-specified grammars, supporting prefix/infix/postfix operators, precedence, associativity and recursive pattern matching allowing complex mathematical expressions to be parsed.

```typ
#import "@preview/parsely:0.1.0"
```


Minimal example: from the equation `$A x + b$` obtain the abstract syntax tree
```typ
(head: "add", args: ((head: "mul", args: ($A$, $x$)), $b$))
```
using the main function `parsely.parse(eqn, grammar)` where the  grammar
```typ
#let grammar = (
  add: (infix: $+$, prec: 1, assoc: true),
  mul: (infix: $$, prec: 2, assoc: true),
)
```
defines the syntax of the operators that form the nodes in the tree.


See [the manual](https://github.com/Jollywatt/typst-parsely/releases/download/v0.1.0/manual.pdf) for documentation and complete usage examples, including:
- drawing expression trees from equations
- numerically evaluating equations
- turning equations into functions for plotting