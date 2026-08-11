// Calmly-Touying Presentation Template
// A calm, modern presentation theme with Moloch-inspired design
//
// Documentation: https://github.com/YHan228/calmly-touying

#import "@preview/calmly-touying:0.2.0": *

// Configure your presentation
#show: calmly.with(
  config-info(
    title: [Your Presentation Title],
    subtitle: [Conference or Event Name],
    author: [Your Name],
    date: datetime.today(),
    institution: [Your Institution],
  ),
  // Theme options (all optional):
  // variant: "light",        // "light" | "dark"
  // colortheme: "tomorrow",  // "tomorrow" | "warm-amber" | "paper" | "dracula"
  // progressbar: "foot",     // "foot" | "head" | "frametitle" | "none"
  // header-style: "moloch",  // "moloch" | "minimal"
  // title-layout: "moloch",  // "moloch" | "centered" | "split"
)

#title-slide()

// =============================================================================
// Introduction
// =============================================================================

#section-slide[Introduction]

== Motivation

#highlight-box(title: "Research Question")[
  What problem are you solving, and why does it matter?
]

#v(0.8em)

- Provide context and background
- State the gap in existing work
- #alert[Highlight] the key challenge

#v(1fr)

== Approach

#v(1fr)

#two-col(
  [
    #alert-box(title: "Existing Methods")[
      Describe limitations of prior approaches.
    ]
  ],
  [
    #example-box(title: "Our Contribution")[
      Explain what your work adds.
    ]
  ],
)

#v(2fr)

// =============================================================================
// Methods
// =============================================================================

#section-slide[Methods]

== Algorithm

Code blocks get automatic syntax highlighting matched to your color theme:

```python
def gradient_descent(f, x0, lr=0.01):
    x = x0
    for _ in range(1000):
        x -= lr * grad(f, x)
    return x
```

#themed-block(title: "Complexity")[
  Time: $O(n dot T)$ where $T$ is the number of iterations.
]

== Pseudocode

#algorithm-box(title: "Algorithm 1: Gradient Descent")[
  *Input:* Function $f$, initial point $x_0$, learning rate $eta$ \
  *Output:* Approximate minimizer $x^*$

  1: $x <- x_0$ \
  2: *for* $t = 1, 2, dots, T$ *do* \
  3: #h(1em) $g <- nabla f(x)$ \
  4: #h(1em) $x <- x - eta dot g$ \
  5: *end for* \
  6: *return* $x$
]

#v(1fr)

== Formulation

#v(1fr)

#two-col(
  [
    The objective function:

    $ min_theta L(theta) = -1/n sum_(i=1)^n log p(x_i | theta) $
  ],
  [
    *Key variables*

    - $theta$ --- model parameters
    - $x_i$ --- observed data points
    - $n$ --- sample size
  ],
)

#v(2fr)

// =============================================================================
// Results
// =============================================================================

#section-slide(show-progress: true)[Results]

== Comparison

#v(1fr)

#table(
  columns: (1fr, auto, auto, auto),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  table.header(
    [*Method*], [*Precision*], [*Recall*], [*F1*],
  ),
  [Baseline], [0.72], [0.68], [0.70],
  [Improved], [0.85], [0.81], [0.83],
  [*Ours*], [*0.91*], [*0.89*], [*0.90*],
)

#v(2fr)

// =============================================================================
// Conclusion
// =============================================================================

// Use #focus-slide for high-impact statements:
// #focus-slide[Key Takeaway Message]

#section-slide[Conclusion]

== Summary

#three-col(
  [
    *Problem*

    Clearly defined the research gap.
  ],
  [
    *Method*

    Proposed a novel approach with formal guarantees.
  ],
  [
    *Result*

    Achieved state-of-the-art on standard benchmarks.
  ],
)

#v(1em)

#alert-box(title: "Future Work")[
  - Extend to larger-scale datasets
  - Explore alternative architectures
]

#v(1fr)

#ending-slide(
  title: [Thank You],
  subtitle: [Questions?],
  contact: (
    "your.email@example.com",
    "github.com/yourusername",
  ),
)
