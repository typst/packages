#import "@preview/unofficial-monash-touying:0.1.2": *

#set text(font: ("Arial", "New Computer Modern"))

// Replace this with your own approved title graphic, or remove `titlegraphic`
// from `monash-theme.with(...)` to use a plain title slide.
#let monash-titlegraphic = image(
  "assets/monash-presentation/background/bg-02.png",
  width: 100%,
  height: 100%,
  fit: "cover",
)

#show: monash-theme.with(
  titlegraphic: monash-titlegraphic,
  config-info(
    title: [Unofficial Monash Touying],
    short-title: [Monash Touying],
    subtitle: [Academic presentation starter],
    author: [Your Name],
    institution: [Monash University],
    date: datetime.today(),
  ),
)

// Install the academic frame environments:
// `definition`, `theorem`, `lemma`, `corollary`, `note`, `warning`, `remark`,
// and `proof`. Use `.with(numbering: false)` to hide frame numbers.
#show: show-monash-frames

#title-slide()

= Overview

== Why This Starter

This package wraps Touying's authoring model. Use headings for sections and
slides, and use the exported Monash-inspired theme and academic frame
environments.

- Use headings to create sections and slides.
- Use `#slide` when you want manual slide control.
- Use presentation features such as `#pause` directly.
- Use `toc: false` in `monash-theme.with(...)` if you do not want the automatic
  outline after the title slide.

== A Typical Research Slide

Use compact claims, short evidence, and one visual emphasis point per slide.

#grid(
  columns: (1fr, 1fr),
  gutter: 1cm,
  [
    - State the problem.
    - Name the method.
    - Report the key result.
  ],
  [
    #block(
      width: 100%,
      height: 4.6em,
      fill: monash-blue-wash,
      stroke: (left: (paint: monash-orange, thickness: monash-frame-rule)),
      inset: (x: .75em, y: .6em),
    )[
      #align(center + horizon)[
        #text(fill: monash-blue, weight: "bold")[
          Replace this panel with a figure, table, or quote.
        ]
      ]
    ]
  ],
)

= Academic Frames

== Theorem-Like Content

#definition[Loss Function][
  A loss function maps a prediction and target to a scalar penalty:
  $"loss": cal(Y) times cal(Y) -> RR$.
]

#theorem[Convergence Sketch][
  If $f$ is convex and $L$-smooth, gradient descent with a suitable step size
  satisfies $f(x_t) - f(x^*) = O(1 / t)$.
]

#proof[Sketch][
  Apply the theorem assumptions and simplify.
]

== Notes and Warnings

#note[Usage][
  Use notes for implementation details, assumptions, or presentation reminders.
]

#warning[Scope][
  Keep slide claims narrow enough that the supporting evidence fits on the same
  slide or the next one.
]

= Code

== Code

```python
def mse(y, pred):
    return ((y - pred) ** 2).mean()
```

Inline code such as `#slide` is styled consistently with fenced code blocks.

== Closing Checklist

- Replace the title metadata.
- Add or remove sections.
- Swap in approved title graphics and logos when appropriate.
- Run `typst compile main.typ` before presenting.

== Closing

#slide[
  #align(center + horizon)[
    #text(size: 1.6em, fill: monash-blue, weight: "bold")[Thank you]
  ]
]
