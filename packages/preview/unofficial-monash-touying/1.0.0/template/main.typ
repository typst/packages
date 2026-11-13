#import "@preview/unofficial-monash-touying:1.0.0": *

#show: monash-theme.with(
  // For the Monash look, use Arial where it is installed:
  // font: "Arial",
  // Your institution's logo, saved under assets/ (see the README's Logos section):
  // logo: image("assets/logo.svg"),
  config-info(
    title: [Presentation Title],
    short-title: [Short Title],
    subtitle: [Subtitle],
    author: [Your Name],
    institution: [Monash University],
    date: datetime.today(),
  ),
)

#show: show-monash-frames

#title-slide()

= Introduction

== Motivation

- State the problem in one sentence.
- Say why it matters.
  - Add detail at a second level when needed.

#pause

Content after `#pause` appears on the next click.

== Plan

+ Background
+ Method
+ Results

= Method

== Key Definition

#definition[Term][
  A definition states exactly what a word means in this talk.
]

#theorem[Main Result][
  Under the stated assumptions, the method converges.
] <main-result>

#proof[
  Sketch the argument in one or two sentences.
]

== Code and Data

```python
def mean(values):
    return sum(values) / len(values)
```

#table(
  columns: 3,
  table.header[Method][Accuracy][Time (s)],
  [Baseline], [71.2%], [12.4],
  [Ours], [78.9%], [10.1],
)

= Results

== Findings

@main-result holds on every dataset we tried.

#note[
  Replace this note with the one thing the audience should remember.
]

#ending-slide[
  Your Name \
  your.name\@monash.edu
]
