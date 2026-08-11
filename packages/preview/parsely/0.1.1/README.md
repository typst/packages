# Parsely

_Parse equations with Typst_.

[![Package manual (PDF)](https://img.shields.io/badge/v0.1.1-manual.pdf-green)](./docs/manual.pdf)

_Parsely_ provides tools to parse Typst equations into structured syntax trees using user-specified grammars.

Supports prefix/infix/postfix operators, precedence, associativity and recursive pattern matching allowing complex mathematical expressions to be parsed.


## Usage examples

Self-contained usage examples can be found in [the manual](./docs/manual.pdf):
- drawing expression trees from equations (using [CeTZ](https://cetz-package.github.io/))
- performing engineering calculations with units (using [Pariman](https://github.com/pacaunt/pariman))
- turning equations into functions for plotting (using [Lilaq](https://lilaq.org))


## Minimal example

```typ
#import "@preview/parsely:0.1.1"
```

From the equation `$A x + b$` obtain the abstract syntax tree
```typ
(head: "add", args: ((head: "mul", args: ($A$, $x$)), $b$))
```
using the main function `parsely.parse(eqn, grammar)` where the _grammar_
```typ
#let grammar = (
  add: (infix: $+$, prec: 1, assoc: true),
  mul: (infix: $$, prec: 2, assoc: true),
)
```
defines the syntax of the operators that form the nodes in the tree.


## Change log

### v0.1.1
- Add operator guards and rewrite rules.
- Improve documentation.
- Fix usage examples.
- Improve the default `parsely.common.arithmetic` grammar.

### v0.1.0
- Initial concept.
