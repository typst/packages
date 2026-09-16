#import "@preview/parsely:0.1.1"
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-venn:0.2.0"

#show "CeTZ": link.with("https://cetz-package.github.io/")

= Evaluating Boolean formulae <venn>

This example demonstrates how equations may be evaluated by parsing them and then converting the syntax tree into anonymous functions, which we can call with dictionary defining the equation's unknowns.

We define a simple grammar to parse Boolean operators which also defines how the operators are evaluated. For example, the `and` operator dictionary `(infix: $and$, prec: 2, eval: (a, b) => a and b)` has an `eval` field.
We evaluate and then plot the results of various formulae using CeTZ and its `cetz-venn` library.

After parsing, we perform a tree walk to transform the syntax tree into a callable function.
First, leaf nodes are transformed into anonymous functions accepting a dictionary of values.
For example, the leaf node "$A$" is mapped to `scope => scope.at("A")`.

Then, operators are transformed into functions which first evaluate their arguments and then combine them with some operation.
For example, the partially-evaluated node "$#`left` and #`right`$" becomes `scope => left(scope) and right(scope)`.

The final closure accepts a scope such as `("A": true, "B": false)`.
By testing on various inputs, you can then use the closure to plot Venn diagrams or a truth table.

#import parsely: slot
#let grammar = (
  "and":   (infix: $and$,  prec: 2, eval: (a, b) => a and b),
  "or":    (infix: $or$,   prec: 1, eval: (a, b) => a or b),
  "xor":   (infix: $xor$,  prec: 1, eval: (a, b) => a != b),
  "not":   (prefix: $not$, prec: 3, eval: a => not a),
  "impl":  (infix: $==>$,  prec: 0, eval: (a, b) => a <= b),
  "if":    (infix: $<==$,  prec: 0, eval: (a, b) => a >= b),
  "equiv": (infix: $<==>$, prec: 0, eval: (a, b) => a == b),
  "group": (match: $(slot("body*"))$),
  "true":  (match: $1$, eval: () => true),
  "false": (match: $0$, eval: () => false),
)

/// Parse a boolean formula and return a closure (scope => bool)
/// and an array of the names of the unknowns.
#let eval-eqn(eqn) = {
  let (tree, rest) = parsely.parse(eqn, grammar)

  let callback = parsely.walk(tree,
    leaf: it => {
      if repr(it.func()) == "symbol" {
        vars => vars.at(it.text)
      } else { panic("can't evaluate leaf", it) }
    },
    post: ((head, args, slots)) => {
      let op = grammar.at(head)
      if "eval" in op {
        vars => (op.eval)(..args.map(arg => arg(vars)))
      } else if head == "group" {
        vars => (slots.body)(vars)
      }
    }
  )

  let symbols = (parsely.walk(tree, post: ((args, slots)) => {
    args + slots.values()
  }),).flatten().dedup().map(sym => sym.text)

  (callback: callback, symbols: symbols)
}


#let venn-diagram(eqn) = {
  let (callback, symbols) = eval-eqn(eqn)

  let fill(..args) = {
    let on = callback(symbols.zip(args.pos()).to-dict())
    if on { yellow } else { white }
  }

  cetz.canvas(length: 4mm, {
    cetz.draw.set-style(venn: (padding: 0.4),)

    let labels = symbols.map(it => $italic(it)$)
    if symbols.len() <= 2 {
      cetz-venn.venn2(
        name: "venn",
        a-fill: fill(true, false),
        b-fill: fill(false, true),
        ab-fill: fill(true, true),
        not-ab-fill: fill(false, false),
      )
      cetz.draw.content("venn.a", labels.at(0, default: none))
      cetz.draw.content("venn.b", labels.at(1, default: none))
    } else if symbols.len() == 3 {
      cetz-venn.venn3(
        name: "venn",
        a-fill: fill(true, false, false),
        b-fill: fill(false, true, false),
        c-fill: fill(false, false, true),
        ab-fill: fill(true, true, false),
        ac-fill: fill(true, false, true),
        bc-fill: fill(false, true, true),
        abc-fill: fill(true, true, true),
        not-abc-fill: fill(false, false, false),
      )
      cetz.draw.content("venn.a", labels.at(0))
      cetz.draw.content("venn.b", labels.at(1))
      cetz.draw.content("venn.c", labels.at(2))
    }
  })
}

#let eqns = (
  $0$, $1$,
  $A$,
  $not A$,
  $A or B$,
  $A and B$,
  $A xor B$,
  $A <==> B$,
  $A ==> B$,
  $A <== B$,
  $A and not B$,
  $not (A ==> B)$,
  $A <==> B or C$,
  $A xor B xor C$,
  $not ( A ==> (B xor C))$,
  $A xor (B and C)$,
)

#grid(
  columns: 4*(1fr,),
  align: (right + top, left),
  row-gutter: 1em,
  ..eqns.map(eqn => $ #venn-diagram(eqn)\ #eqn $)
)



// truth table

#let eqns = (
  $A$,
  $B$,
  $not A$,
  $A or B$,
  $A xor B$,
  $A and B$,
  $A <==> B$,
  $A ==> B$,
  $A <== B$,
  $A and not B$,
  $1$,
)
#let callbacks = eqns.map(e => eval-eqn(e).callback)

#table(
  columns: eqns.len(),
  stroke: none,
  align: center,
  ..eqns,
  table.hline(),
  ..(false, true).map(B => {
    (false, true).map(A => {
      callbacks.map(f => {
        if f((A: A, B: B)) [$1$] else [$0$]
      })
    })
  }).flatten()
)
