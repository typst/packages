#import "@preview/non-boring-notes:0.1.0": *

#show: template.with(
  title: [Non-boring notes],
  subtitle: [A clean and modular Typst template],
  short_title: "Usual Notes",
  description: [An usual description],
  abstract: [
    This template provides a robust structure for taking notes, whether they are for lectures,
    chapters, or personal projects. It features color-coded environments, and a modular content
    system.
  ],
  creation_date: datetime(year: 2025, month: 08, day: 11),
  authors: (
    (
      name: "Aru",
      link: "https://aruzdh.dev",
    ),
  ),
  bibliography_file: path("/bibliography/bibliography.bib"),
  paper_size: "us-letter",
  cols: 1,
  h1_prefix: "lecture",
  text_lang: "en",
)

= Introduction to Modern Analysis

This entry showcases the various capabilities of the *Non-boring notes* template. We will explore
mathematical structures, code implementations, and complex layouts.
//
== Core Definitions and Theorems

#definition("Metric Space")[
  A *metric space* is a set $M$ together with a function $d: M times M arrow RR$ (called a metric)
  that satisfies:
  1. $d(x, y) >= 0$ (non-negativity)
  2. $d(x, y) = 0 <==> x = y$ (identity of indiscernibles)
  3. $d(x, y) = d(y, x)$ (symmetry)
  4. $d(x, z) <= d(x, y) + d(y, z)$ (triangle inequality)
] <def_metric_space>

#theorem("Banach Fixed-Point Theorem")[
  Let $(X, d)$ be a non-empty complete metric space with a contraction mapping $T: X arrow X$. Then $T$ has a unique fixed point $x^*$ in $X$.
]

#proof[
  The proof proceeds by considering the sequence $x_n$ defined by $x_{n+1} = T(x_n)$.
  Since $T$ is a contraction:
  $ d(x_{n+1}, x_n) = d(T(x_n), T(x_{n-1})) <= q d(x_n, x_{n-1}) $
  By the triangle inequality and completion of the space, $x_n arrow x^*$.
]

== Advanced Layouts

#indent[
  Using the `#indent` command, you can create focused blocks of text that stand out from the main flow. This is perfect for auxiliary explanations or side-quests in your notes.
]

We also have specialized math boxes for emphasizing results:

#align(center)[
  #mathbox(
    $
      sum_(i = 1)^n i = frac(n(n+1), 2)
    $,
  )
]

And for complex diagrams, we have `fletcher` integrated:

#align(center)[
  #diagram(
    node((0, 0), $X$, radius: 2em),
    node((2, 0), $Y$, radius: 2em),
    edge((0, 0), (2, 0), [f], "->", bend: 20deg),
    edge((0, 0), (2, 0), [g], "->", bend: -20deg),
  )
]

== Computer Science Features

Code blocks are automatically styled with language tags and soft backgrounds.

#important("Performance")[
  Always consider the time complexity when implementing recursive algorithms.
]

```python
def fibonacci(n):
    """A simple recursive fibonacci with memoization."""
    memo = {0: 0, 1: 1}
    def f(n):
        if n not in memo:
            memo[n] = f(n-1) + f(n-2)
        return memo[n]
    return f(n)
```

== Citation and References

The template handles citations seamlessly. For instance, the foundations of linear algebra are beautifully covered in #cite(<friedberg2018linear>, form: "prose").

#exercise[
  Verify that the $L^2$ norm satisfies the triangle inequality for the metric space in  @def_metric_space
]

#tip[
  Use the Table of Contents to navigate quickly between your entries!
]

