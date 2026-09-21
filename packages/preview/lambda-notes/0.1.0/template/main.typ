#import "@local/lambda-notes:0.1.0": *

#show: lambda-notes.with(
  title: "Algorithms and Data Structures",
  author: "Your Name",
  date: "Fall 2026",
  subject: "Lecture notes",
  keywords: ("algorithms", "data structures", "computer science"),
  color: blue,
)

= Introduction

These are example notes generated from the *lambda-notes* template. They show off
headings, notes, callouts, tables, code, algorithms, and cross-references.

Jump ahead to the @sorting section, or check out an external link like
#link("https://typst.app")[the Typst website].

#note[
  This is a plain *note* block — use it for asides that don't need a color.
]

#callout(title: "Tip", color: green)[
  Use `callout` with a `color` and an optional `title` to highlight tips,
  warnings, or definitions.
]

#callout(title: "Definition", color: orange)[
  A *graph* is a pair $(V, E)$ of vertices and edges.
]

== Comparing approaches

#table(
  columns: 3,
  [*Approach*], [*Time*], [*Space*],
  [Brute force], [$O(n^2)$], [$O(1)$],
  [Divide & conquer], [$O(n log n)$], [$O(n)$],
  [Dynamic programming], [$O(n)$], [$O(n)$],
)

```python
def fibonacci(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

= Sorting algorithms <sorting>

== Heapsort

#algorithm-figure(
  "Heapsort",
  {
    Procedure(
      "HEAPSORT",
      ("A", "n"),
      {
        Call("BUILD-MAX-HEAP", [A, n])
        For($i=n "DOWNTO" 2$, {
          Comment[Exchange $A[1]$ with $A[i]$]
          Assign[A.heap-size][A.heap.size-1]
          Call("MAX-HEAPIFY", [A, 1])
        })
      },
    )
  },
)

Heapsort runs in $O(n log n)$ time on a sorted array of size $n$.
