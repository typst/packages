# slr-visualizer

Takes a grammar and a sentence and walks through SLR(1) parsing: augmented
grammar, FIRST/FOLLOW, canonical LR(0) items, the DFA, the ACTION/GOTO
table, a shift-reduce trace, the parse tree. All computed in Typst, no
external script generating a table beforehand.

It's SLR(1) — LR(0) item sets, but reduce actions only go in when the
symbol's in FOLLOW(LHS). That's the whole difference from plain LR(0).

See `example.pdf` for what it looks like end to end on:

```
C → id ( A )
A → A , E | ε | E
E → E + T | T
T → id | num | C
```
parsing `id ( num + id , id ( num + id ) )`.

## Using it

```typst
#import "@preview/slr-visualizer:0.1.0": *

#let my-grammar = (
  ("C", ("id", "(", "A", ")")),
  ("A", ("A", ",", "E")),
  ("A", ("\\epsilon",)),
  ("A", ("E",)),
  ("E", ("E", "+", "T")),
  ("E", ("T",)),
  ("T", ("id",)),
  ("T", ("num",)),
  ("T", ("C",)),
)

#let my-sentence = ("id", "(", "num", "+", "id", ",", "id", "(", "num", "+", "id", ")", ")")

#show-grammar(my-grammar)
#show-parse-table(my-grammar)
#show-parse-trace(my-grammar, my-sentence)
#show-parse-tree(my-grammar, my-sentence)
```

A grammar is just a list of `(LHS, RHS)` pairs, RHS being a tuple of
symbols. First production's LHS = start symbol. Anything that's not a LHS
anywhere is a terminal. `"\\epsilon"` for empty productions. Don't use `"."`
as a symbol — it's the LR item dot internally and things will break in
confusing ways if it collides.

A sentence is just the terminals, no `$` at the end, that gets added for
you.

## What each function gives you

`show-grammar` / `show-aug-grammar` — the production list, plain or with the
`S' → S` row added.

`show-first-follow` — FIRST/FOLLOW per non-terminal.

`show-canonical-items` — every I_n state, with where it came from.

`show-automaton(grammar, width: 100%)` — the LR(0) DFA, rendered via
diagraph/Graphviz.

`show-parse-table` — ACTION/GOTO, conflicts called out in red if there are
any.

`show-parse-trace` / `show-parse-tree` — take `(grammar, sentence)`, give
you the stack-by-stack trace and the resulting tree.

All of them take the grammar *before* augmentation — that part's handled
for you.

## Known gaps

- SLR(1) conflict resolution, not LALR/LR(1) — if your grammar genuinely
  needs per-state lookahead to be unambiguous, you'll see conflicts here
  even though a stronger parser wouldn't have any.
- FIRST-set computation only skips direct left recursion (`A → A α`).
  Indirect left recursion through another non-terminal isn't handled.
- When there's a real shift/reduce or reduce/reduce conflict, whichever
  action got inserted first wins — there's no precedence/associativity
  table backing this, it's reported and left at that.
