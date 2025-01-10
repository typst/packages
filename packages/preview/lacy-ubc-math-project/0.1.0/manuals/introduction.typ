#import "@preview/mitex:0.2.4": mitex

= Introduction
This template is designed to help you write and format your math group projects. It is based on the existing (2024) LaTex template. Despite the limited initial purpose, it offers a clean layout for possibly other types of question-solution documents.

You are recommended to read the `getting-started` and `math` helps.

== Motivation
Why use this template? The previous two popular choices, MS Word and LaTex, each had significant drawbacks. MS Word might be easy to start with, but math formatting is a nightmare; plus, software support is not so good on non-Windows platforms. LaTex, on the other hand, is powerful but has a steep learning curve, the source document becomes hardly readable after a few edits; collaboration is not simple as Word, since a free Overlead account can only have one collaborator per document, while an upgrade is (in my opinion) drastically overpriced.

How about elegant math typesetting, blazingly fast automatic layout and unlimited collaboration? Typst seems to be the solution. Although still in development, it is more than enough for our use cases. Let's see:
#block(
  breakable: false,
  grid(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    inset: 8pt,
    [LaTex],
    ```latex
    \[ e^{-\frac{x^2}{3}} \]
    ```,
    mitex(`e^{-\frac{x^2}{3}}`),
    grid.hline(stroke: 0.25pt),
    [Typst],
    ```typst
    $ e^(-x^2 / 3) $
    ```,
    $ e^(-x^2 / 3) $,
  ),
)

Clearly, Typst's math syntax is way more intuitive and readable.

As another plus, Typst documents usually compile in milliseconds, whereas LaTex can take seconds or even longer. With this speed, every keystroke is immediately reflected in the preview, which can be a huge productivity boost.

The official Typst web app allows unlimited collaborators in a document, which is a huge advantage over Overleaf, given that there are often more than 2 people in a math group. Did I mention that team management is also a free feature?

