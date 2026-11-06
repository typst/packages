#import "@preview/touying:0.7.3": *
#import themes.university: *
#import "@preview/unofficial-monash-touying:0.1.0": *

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

Touying remains the authoring model. Use headings for sections and slides, and
use this package for the Monash-inspired theme and academic frame environments.

- Use headings to create sections and slides.
- Use `#slide` when you want manual slide control.
- Use Touying features such as `#pause` directly.

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

= Code

== Code

```python
def mse(y, pred):
    return ((y - pred) ** 2).mean()
```

== Closing

#slide[
  #align(center + horizon)[
    #text(size: 1.6em, fill: monash-blue, weight: "bold")[Thank you]
  ]
]
