#import "@preview/tyniverse:0.2.3": homework.complex-question, homework.simple-question, template

#show: template.with(
  title: "Question Frame Manual",
  author-infos: ("Fr4nk1in",),
)
#show raw.where(block: true): block.with(
  width: 100%,
  fill: luma(93%),
  inset: 5pt,
  spacing: 0.7em,
  breakable: false,
  radius: 0.35em,
)
#set raw(lang: "typc")

#set heading(numbering: "1.")

= The `question` function

```typc
let question(
  heading-counter: false,
  number: auto,
  display-number: none,
  display-desc: none,
  display-frame: none,
  desc,
) = content
```

- `heading-counter`: `boolean` \
  Whether to show heading counter or not.
- `number`: `auto` | `int` | `str` | `content` \
  Question number, defaults to `auto`.
  - If `auto`, it would be the number of the questions (whose `number` are `auto`) up to this point.
  - Both `auto` and `int` works with `heading-counter`, while `str` and `content` do not and fail the compilation.
  - Both `auto` and `int` are treated as the `..numbers` in the `display-number` function. `str` and `content` are treated as the `override`.
- `display-number` : `(override: str | content, ..numbers: int) => content` \
  How to display the question number.
- `display-desc`: `(content) => content` \
  How to display the question description
- `display-frame`: `(content) => content` \
  How to display the question frame


To enable the heading counter argument `heading-counter`, you need to set the heading numbering rule first. For example:
```typ
#set heading(numbering: "1.")
```

= Presets and Examples

We also provide two presets for the `question` function: `simple-question` and `complex-question`.

== The `simple-question` preset

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  align: start + top,
  ```typc
  simple-question[Default Configuration]
  ```,
  simple-question[Default Configuration],

  ```typc
  simple-question(
    number: 1024,
  )[Custom Numbering]
  ```,
  simple-question(number: 1024)[Custom Integer Numbering],

  ```typc
  simple-question(
    number: "Number."
  )[Custom Numbering]
  ```,
  simple-question(number: "Number.")[Custom Numbering],

  ```typc
  simple-question(
    number: $gamma$
  )[Custom Numbering]
  ```,
  simple-question(number: $gamma$)[Custom Numbering],

  ```typc
  simple-question[
    Second Default Configuration
  ]
  ```,
  simple-question[
    Second Default Configuration
  ],

  ```typc
  simple-question(
    heading-counter: true
  )[With Heading Counter]
  ```,
  simple-question(heading-counter: true)[With Heading Counter],

  ```typc
  simple-question(
    heading-counter: true,
    number: 1024,
  )[Custom Numbering]
  ```,
  {
    simple-question(heading-counter: true, number: 1024)[
      Custom Integer Numbering
    ]

    [Works with `heading-counter`]
  },

  ```typc
  simple-question(
    display-number: (
      override: none,
      ..numbers,
    ) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Numbering Rule],
  ```,
  simple-question(
    display-number: (
      override: none,
      ..numbers,
    ) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Numbering Rule],

  ```typc
  simple-question(
    heading-counter: true,
    display-number: (
      override: none,
      ..numbers,
    ) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Numbering Rule],
  ```,
  simple-question(
    heading-counter: true,
    display-number: (
      override: none,
      ..numbers,
    ) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Numbering Rule],

  ```typc
  simple-question(
    heading-counter: true,
    number: 1024,
    display-number: (
      override: none,
      ..numbers,
    ) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Integer Numbering]
  ```,
  {
    simple-question(
      heading-counter: true,
      number: 1024,
      display-number: (
        override: none,
        ..numbers,
      ) => {
        strong(numbering("I.", ..numbers))
      },
    )[
      Custom Integer Numbering
    ]

    [Works with `display-number`]
  },

  ```typc
  simple-question(
    display-desc: it => strong(emph(it))
  )[Custom Description Style],
  ```,
  simple-question(display-desc: it => strong(emph(it)))[Custom Description Style],

  ```typc
  simple-question(
    display-frame: it => {
      it
      v(-0.9em)
      line(length: 100%, stroke: red)
      v(-0.6em)
    },
  )[Custom Frame Style],
  ```,
  simple-question(
    display-frame: it => {
      it
      v(-0.9em)
      line(length: 100%, stroke: red)
      v(-0.6em)
    },
  )[Custom Frame Style],
)

== The `complex-question` preset

#complex-question[
  Default Configuration

  ```typc
  complex-question[Default Configuration]
  ```
]

#complex-question(number: 1024)[
  Custom Integer Numbering

  ```typc
  complex-question(number: 1024)[Custom Integer Numbering]
  ```
]

#complex-question(number: "Number.")[
  Custom Numbering

  ```typc
  complex-question(number: "Number.")[Custom Numbering]
  ```
]

#complex-question(number: $gamma$)[
  Custom Numbering

  ```typc
  complex-question(number: $gamma$)[Custom Numbering]
  ```
]

#complex-question[
  Second Default Configuration

  ```typc
  complex-question[Second Default Configuration]
  ```
]

#complex-question(heading-counter: true)[
  With Heading Counter

  ```typc
  complex-question(heading-counter: true)[With Heading Counter]
  ```
]

#complex-question(heading-counter: true, number: 1024)[
  Custom Integer Numbering with Heading

  ```typc
  complex-question(heading-counter: true, number: 1024)[Custom Integer Numbering]
  ```
]

#complex-question(
  display-number: (override: none, ..numbers) => {
    strong(numbering("I.", ..numbers))
  },
)[
  Custom Numbering Rule

  ```typc
  complex-question(
    display-number: (override: none, ..numbers) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Numbering Rule]
  ```
]

#complex-question(
  heading-counter: true,
  display-number: (override: none, ..numbers) => {
    strong(numbering("I.", ..numbers))
  },
)[
  Custom Numbering Rule with Heading

  ```typc
  complex-question(
    heading-counter: true,
    display-number: (override: none, ..numbers) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Numbering Rule with Heading]
  ```
]

#complex-question(
  heading-counter: true,
  number: 1024,
  display-number: (override: none, ..numbers) => {
    strong(numbering("I.", ..numbers))
  },
)[
  Custom Integer Numbering with Custom Numbering Rule

  ```typc
  complex-question(
    heading-counter: true,
    number: 1024,
    display-number: (override: none, ..numbers) => {
      strong(numbering("I.", ..numbers))
    },
  )[Custom Integer Numbering with Custom Numbering Rule]
  ```
]

#complex-question(display-desc: emph)[
  Custom Description Style

  ```typc
  complex-question(display-desc: emph)[Custom Description Style]
  ```
]

#complex-question(display-frame: rect.with(width: 100%, radius: 5pt, stroke: red))[
  Custom Frame Style

  ```typc
  complex-question(
    display-frame: rect.with(width: 100%, radius: 5pt, stroke: red),
  )[Custom Frame Style]
  ```
]
