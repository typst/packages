#import "@preview/craken-book:0.2.0": *

= Recursion, or trusting your future self

#lede[Every recursive function makes a small promise: hand me a smaller version of the problem, and I’ll hand you back the answer. This chapter is about keeping that promise.]

== A tiny example first

Let’s start with the Fibonacci numbers, where each number is the sum of the two before it. We write $F_n$ for the $n$-th one#note[Some books start at $F_1 = 1$. We start at zero, like Python does.] so that

$ F_0 = 0, quad F_1 = 1, quad F_n = F_(n-1) + F_(n-2). $ <eq:fib>

That definition is already a program. Read @eq:fib out loud and you have almost written the code: the first two cases are the #dfn[base cases], and the last one is the #dfn[recursive case].

#listing(title: [fib.py], lang: [Python], numbers: true, caption: [The definition, translated word for word.])[
```python
def fib(n: int) -> int:
    if n < 2:  # F(0) = 0, F(1) = 1
        return n
    return fib(n - 1) + fib(n - 2)
```
] <lst:fib>

It works, and it is slow. Not a little slow: `fib(40)` takes long enough to make a cup of tea.#note[About 330 million calls. @ex:calls asks you to find the exact count.] Before fixing it, let’s see where the time goes.

#tip[When a recursive function misbehaves, print the argument on the way in and the result on the way out. Indent by depth, and the trace draws the call tree for you.]

#let node(x, y, r, label, fill: palette.peach, mark: false) = {
  if mark { place(dx: x - r - 3.5pt, dy: y - r - 3.5pt, circle(radius: r + 3.5pt, stroke: 1.4pt + palette.coral)) }
  place(dx: x - r, dy: y - r, circle(radius: r, fill: fill, stroke: ink-line))
  place(dx: x - r, dy: y - r, box(width: 2 * r, height: 2 * r, align(center + horizon, text(size: 8.5pt, label))))
}
#let edge(a, b) = place(line(start: a, end: b, stroke: ink-line))

#figure(
  box(width: 260pt, height: 128pt, {
    edge((130pt, 18pt), (75pt, 53pt))
    edge((130pt, 18pt), (195pt, 53pt))
    edge((75pt, 53pt), (45pt, 88pt))
    edge((75pt, 53pt), (105pt, 88pt))
    edge((45pt, 88pt), (25pt, 113pt))
    edge((45pt, 88pt), (65pt, 113pt))
    edge((195pt, 53pt), (170pt, 88pt))
    edge((195pt, 53pt), (220pt, 88pt))
    node(130pt, 18pt, 11pt)[4]
    node(75pt, 53pt, 11pt)[3]
    node(45pt, 88pt, 10pt)[2]
    node(105pt, 88pt, 9pt, fill: palette.paper-warm)[1]
    node(25pt, 113pt, 8pt, fill: palette.paper-warm)[1]
    node(65pt, 113pt, 8pt, fill: palette.paper-warm)[0]
    node(195pt, 53pt, 10pt, mark: true)[2]
    node(170pt, 88pt, 8pt, fill: palette.paper-warm, mark: true)[1]
    node(220pt, 88pt, 8pt, fill: palette.paper-warm, mark: true)[0]
  }),
  caption: [The calls made by `fib(4)`. Small circles are base cases; coral rings mark work we already did on the left.],
) <fig:tree>

#question(answer: [Five times, which is $F_5$. The repeats grow like the Fibonacci numbers themselves.])[
  @fig:tree computes `fib(2)` twice. How many times would `fib(6)` compute it?
]

#sbreak()

The pattern in @fig:tree has a name. When the same smaller problem shows up again and again, we say the problems #dfn[overlap]. Overlap is the whole reason `fib` is slow, and it is also the key to making it fast.

== Remembering what we already know

The cure is to write each answer down the first time we compute it. Python will do the bookkeeping for us with one line:

#code(title: [fib_memo.py], lang: [Python])[
```python
from functools import cache

@cache
def fib(n: int) -> int:
    """Return the n-th Fibonacci number."""
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)

print(fib(80))  # 23416728348467685
```
]

Now each $F_k$ is computed only once, so `fib(n)` does $n + 1$ real computations instead of $2F_(n+1) - 1$ calls. The difference is easy to feel:

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, right, right),
    table.header[$n$][naive calls][with `@cache`],
    [10], [177], [11],
    [20], [21 891], [21],
    [30], [2 692 537], [31],
  ),
  caption: [Work done by `fib(n)`: every call without the cache, real computations with it.],
)

#try-this[Remove `@cache`, add a global counter that goes up on every call, and check the middle column of the table yourself.]

=== How deep does it go?

Caching fixes the time, not the depth: `fib(5000)` still nests five thousand calls and hits Python’s recursion limit.#note[The default limit is 1000. You can raise it with `sys.setrecursionlimit`, but a loop is the honest fix.] For a recursion that halves its input at each step, like merge sort, the depth is only $log_2 n$ and the running time obeys

$ T(n) = 2 T(n/2) + n, $ <eq:merge>

which unrolls to $T(n) = Theta(n log n)$. Unlabelled display math, like Gauss’s formula below, gets no number:

$ sum_(i=1)^n i = (n(n+1))/2 . $

== Exercises

#exercises[
  #exercise(difficulty: 1, solution: [`def sum_to(n): return 0 if n == 0 else n + sum_to(n - 1)`. The base case $n = 0$ is the smallest one that works for every $n >= 0$.])[
    Write `sum_to(n)` recursively, so that `sum_to(4)` returns 10. What is the smallest base case that works?
  ]
  #exercise(difficulty: 2, solution: [For $n = 1$ both sides are 1. If it holds for $n$, add $n + 1$ to both sides: $n(n+1)\/2 + (n+1) = (n+1)(n+2)\/2$, which is the formula for $n + 1$.])[
    Prove by induction that $sum_(i=1)^n i = n(n+1)\/2$.
  ]
  #exercise(difficulty: 3, solution: [Let $C(n)$ count the calls. Then $C(n) = 1 + C(n-1) + C(n-2)$ with $C(0) = C(1) = 1$, which solves to $C(n) = 2F_(n+1) - 1$.])[
    How many calls does the naive `fib(n)` make in total? Write your answer in terms of Fibonacci numbers.
  ] <ex:calls>
]

#solutions()
