#import "@preview/unofficial-monash-touying:0.1.2": *

#set text(font: ("Arial", "New Computer Modern"))

#let title-background = image(
  "../template/assets/monash-presentation/background/bg-02.png",
  width: 100%,
  height: 100%,
  fit: "cover",
)

#show: monash-theme.with(
  titlegraphic: title-background,
  config-info(
    title: [Unofficial Monash Touying],
    short-title: [Monash Touying],
    subtitle: [Example deck and usage guide],
    author: [Your Name],
    institution: [Monash University],
    date: datetime.today(),
  ),
)

#show: show-monash-frames

#title-slide()

= Quick Start

== Minimal Preamble

Import only this package, then install the Monash-inspired theme as a document
show rule. The starter places a global outline after the title slide by default;
set `toc: false` in `monash-theme.with(...)` if a deck should start directly
with the first section.

```typst
#import "@preview/unofficial-monash-touying:0.1.2": *

#show: monash-theme.with(
  config-info(
    title: [Presentation Title],
    subtitle: [Subtitle],
    author: [Your Name],
    institution: [Institution],
    date: datetime.today(),
  ),
)

#show: show-monash-frames

#title-slide()
```

== Title Graphics and Logos

The starter template includes a logo-free title background. Projects with
appropriate rights can pass their own logo or title graphic as content.

```typst
#let title-background = image("assets/title-background.png", fit: "cover")

#show: monash-theme.with(
  titlegraphic: title-background,
  logo: image("assets/logo.svg", height: 1.25em),
  config-info(title: [Presentation Title]),
)
```

== Turning Off the Outline

The outline is on by default because most academic talks benefit from an early
agenda slide. Disable it in the theme call when a deck should move directly
from title to content.

```typst
#show: monash-theme.with(
  toc: false,
  config-info(title: [Presentation Title]),
)
```

= Authoring Model

== Native Touying Slides

Use standard Touying structure through this package's exports. The package does
not introduce a separate slide wrapper.

- Level-one headings create sections.
- Level-two headings create slides.
- `#pause` works normally.
  - Nested bullets use the triangle marker.

Each level-one heading also creates a Monash-styled section divider with a
progressive outline that highlights the current section.

#pause

Paused content continues on the same slide.

== Manual Slides

Use `#slide` for custom one-off layouts.

#slide[
  #align(center + horizon)[
    #block(width: 70%)[
      #set align(center)
      #text(size: 1.4em, fill: monash-blue, weight: "bold")[
        Manual slide content
      ]

      #v(.5em)
      This is ordinary presentation content inside the Monash-inspired theme.
    ]
  ]
]

=== Styled Content Heading

Level-three headings use Monash blue for compact subsections.

==== Detail Heading

Level-four headings remain lightweight for dense slide content.

== Two-Column Content

Use Typst and exported layout primitives directly.

#slide(composer: (1fr, 1fr))[
  *Research question*

  How does the method behave when the input distribution changes?
][
  *Evaluation plan*

  - compare against a baseline
  - report the failure case
  - keep one takeaway visible
]

= Academic Frames

== Independent Numbering

Definitions, theorems, lemmas, corollaries, notes, and warnings are numbered
independently by environment type.

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

== Proofs and Remarks

Proofs are not framed and end with a square. Remarks are intentionally
unnumbered.

#lemma[Descent Lemma][
  Smoothness gives an upper bound on one optimization step.
]

#proof[Sketch][
  Apply the descent lemma at each iterate and telescope the resulting
  inequalities.
]

#remark[Design][
  Use remarks for short interpretation, context, or side comments.
]

== Notes and Warnings

#note[Usage][
  Frame environments can be placed directly inside any Touying slide.
]

#warning[Scope][
  This package does not define pseudocode syntax. Import a dedicated algorithm
  package when a deck needs pseudocode.
]

== Mixed Academic Content

#definition[Empirical Risk][
  The empirical risk is the average loss over a finite training set:
  $hat(R)(theta) = 1 / n sum_(i=1)^n "loss"(f_theta(x_i), y_i)$.
]

The display remains compact enough for slide use while preserving ordinary
Typst math syntax.

== Hiding Frame Numbers

Install the frame show rule with `numbering: false` when a deck should keep the
frame styling but hide counters.

```typst
#show: show-monash-frames.with(numbering: false)
```

#show: show-monash-frames.with(numbering: false)

#definition[Unnumbered Definition][
  The frame style remains the same when numbering is hidden.
]

#theorem[Unnumbered Theorem][
  Theorem-like blocks can be used without visible counters.
]

= Code Blocks

== Inline and Fenced Code

Inline code such as `#slide` uses a light wash. Ordinary fenced raw blocks are
styled by `zebraw` without changing authoring syntax.

```python
def mse(y, pred):
    return ((y - pred) ** 2).mean()
```

```typst
#definition[Term][
  A definition can be placed directly inside a slide.
]
```

== Code With Context

Place code beside the idea it supports when the audience needs both.

#slide(composer: (1fr, 1fr))[
  The raw block keeps normal Typst syntax and is styled by the theme.
][
```python
def normalize(x):
    return (x - x.mean()) / x.std()
```
]

= Closing

== Final Slide

#slide[
  #align(center + horizon)[
    #text(size: 1.6em, fill: monash-blue, weight: "bold")[Thank you]
  ]
]
