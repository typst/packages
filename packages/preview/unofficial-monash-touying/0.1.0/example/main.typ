#import "@preview/touying:0.7.3": *
#import themes.university: *
#import "@preview/unofficial-monash-touying:0.1.0": *

#set text(font: ("Arial", "New Computer Modern"))

#let monash-titlegraphic = image(
  "../template/assets/monash-presentation/background/bg-02.png",
  width: 100%,
  height: 100%,
  fit: "cover",
)

#show: monash-theme.with(
  titlegraphic: monash-titlegraphic,
  config-info(
    title: [Unofficial Monash Touying],
    short-title: [Monash Touying],
    subtitle: [Example deck and feature guide],
    author: [Your Name],
    institution: [Monash University],
    date: datetime.today(),
  ),
)

#show: show-monash-frames

#title-slide()

= Authoring Model

== Native Touying Syntax

This package keeps Touying as the slide authoring model.

- Level-one headings create sections.
- Level-two headings create slides.
- Touying features such as `#pause` can be used directly.
  - Nested bullets use the Monash triangle marker.

#pause

After the pause, the same slide continues without package-specific wrappers.

=== Styled Content Heading

Use level-three headings for compact content sections.

==== Detail Heading

Use level-four headings for smaller subdivisions inside dense slides.

= Frame Environments

== Numbered Academic Frames

#definition[Loss Function][
  A loss function maps a prediction and target to a scalar penalty:
  $"loss": cal(Y) times cal(Y) -> RR$.
]

#theorem[Convergence Sketch][
  If $f$ is convex and $L$-smooth, gradient descent with a suitable step size
  satisfies $f(x_t) - f(x^*) = O(1 / t)$.
]

#corollary[Rate][
  Under the same assumptions, the average regret decreases sublinearly.
]

== Lemma and Proof

#lemma[Descent Lemma][
  Smoothness gives an upper bound on one optimization step.
]

#proof[Sketch][
  Apply the descent lemma at each iterate and telescope the resulting
  inequalities.
]

== Notes, Remarks, and Warnings

#note[Usage][
  Frame environments can be inserted in any Touying slide.
]

#remark[Design][
  Remarks are intentionally unnumbered for short interpretive comments.
]

#warning[Scope][
  This package does not define an algorithm DSL. Import a dedicated package when
  a deck needs pseudocode.
]

== Hidden Frame Numbers

#show: show-monash-frames.with(numbering: false)

#definition[Unnumbered Mode][
  Use `#show: show-monash-frames.with(numbering: false)` to hide numbers in a
  deck or section.
]

#theorem[Display Choice][
  The frame style remains the same when numbering is hidden.
]

= Code and Closing

== Code Blocks

Inline code such as `#slide` uses a light Monash wash. Fenced code blocks use
the same visual language without a language badge.

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
