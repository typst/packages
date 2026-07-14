# examy

A [Typst](https://typst.app) package for writing exams, quizzes, and homework
with automatically numbered questions, answer boxes, points accounting, smart
cross-references, and solutions that can be toggled on and off. This package
follows the spirit of the [exam class for LaTeX](https://ctan.org/pkg/exam?lang=en).

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/quiz.png" width="45%" alt="A quiz with empty answer boxes">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/quiz-solutions.png" width="45%" alt="The same quiz compiled with solutions shown">
</p>
<p align="center"><em><a href="https://github.com/siefkenj/typst-examy/blob/main/examples/quiz.typ">examples/quiz.typ</a>, compiled without and with solutions.</em></p>

See [examples/](https://github.com/siefkenj/typst-examy/tree/main/examples/) for usage examples.

## Quick start

```typst
#import "@preview/examy:0.2.0": *

#show: e.prepare()
#show: e.set_(config, show-solutions: false)

// A fill-in block (Name / Student ID) at the top of the page
#name-block()

#exam(
  questions: [
    #question(points: 2)[
      State the definition of a _continuous function_.
      #answer-box(width: 100%, height: 1fr)[
        #solution[A function $f$ is continuous at $a$ if ...]
      ]
    ]
    #question(points: 3)[
      Give an example of a continuous function that is not differentiable.
      #answer-box(width: 100%, height: 2fr)[
        #solution[$f(x) = |x|$ ...]
      ]
    ]
  ],
)
```

The two `#show` lines are required: `e.prepare()` enables
[elembic](https://typst.app/universe/package/elembic) elements and references,
and `e.set_(config, ...)` sets package options.

## Features

### Questions, parts, and subparts

A document is built out of an `#exam(..., questions: [...])`. Inside of `questions`, the commands
`#question[...]`, `#part[...]`, and `#subpart[...]` can be used to create a question hierarchy. 
Questions/parts/subparts can be assigned points, heights, etc.

From [examples/final-exam.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/final-exam.typ) (solutions
abridged), rendered below it:

```typst
#question[
  Let $f(x) = x^2 sin(1/x)$ for $x != 0$ and let $f(0) = 0$.
  #part(points: 2, label: <continuity>)[
    Show that $f$ is continuous at $x = 0$.
    #answer-box(width: 100%, height: 1fr)[
      #solution[...]
    ]
  ]
  #part(points: 3)[
    Is $f$ differentiable at $x = 0$? Justify your answer. (You may use
    your result from @continuity.)
    #answer-box(width: 100%, height: 1fr)[
      #solution[...]
    ]
  ]
]
```

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/question-page.png" width="60%" alt="A question with two parts and answer boxes">
</p>

Numbering can be customized per division with the `number:` argument:
`auto` (default), an integer to set the number (later divisions continue
from it), arbitrary content (e.g. `number: "★"`) shown verbatim, or `none`
for an unnumbered division. From
[examples/numbering.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/numbering.typ):

```typst
#question[An automatically numbered question.]
#question[Another one.]
#question(number: 10)[An integer sets the number.]
#question[...and numbering continues from it.]
#question(number: "★")[Content is shown verbatim.]
#question(number: none)[An unnumbered question.]
#question[The automatic counter ignores the previous two.]
```

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/numbering.png" width="70%" alt="Questions numbered 1, 2, 10, 11, a star, an unnumbered one, and 12">
</p>

### Points

Give any question/part/subpart giving a value to `points: x` will cause an "(x points)"
annotation to show next to the question/part/subpart.
Related to points is:

- `#points-table` render a scoring table.
- `#num-points` and `#num-questions` give total number of points and questions.
- `intent: "bonus"` bonus points are tracked separately and excluded from the
  regular totals.

From [examples/points.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/points.typ):

```typst
This exam has #num-questions questions worth #num-points points.

#{
  set align(center)
  points-table
}

#exam(questions: [
  #question(points: 2)[A question worth two points.]
  #question[
    Points on parts roll up to their question.
    #part(points: 1)[One point.]
    #part(points: 3)[Three points.]
  ]
  #question(points: 4)[
    Bonus points are tallied separately and excluded from the totals.
    #part(points: 2, intent: "bonus")[*Bonus:* not counted above.]
  ]
])
```

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/points.png" width="70%" alt="Questions with point badges, and a points table totalling 10">
</p>

### Answer boxes

`#answer-box(width: ..., height: ...)[...]` draws a box for students to write
in. A fixed height (`2cm`, `1in`, ...) gives a box of that size; a *fraction*
height (`1fr`, `2fr`, ...) makes the box grow to fill the remaining space on
the page — multiple `fr` boxes on one page share the leftover space
proportionally.

### Solutions

Wrap solutions in `#solution[...]` (anywhere in your document, including inside an answer box).
Solutions are only rendered when enabled, so the same source produces
both the exam and the answer key:

```bash
typst compile exam.typ                                 # whatever the document configures
typst compile --input show-solutions=false exam.typ    # student version (force solutions off)
typst compile --input show-solutions=true exam.typ     # answer key (force solutions on)
```

When given on the command line, the `show-solutions` input overrides the document setting
`#show: e.set_(config, show-solutions: ...)`. This can be used in
build scripts that must produce a specific variant regardless of what the
source file currently configures.

Both renders of [examples/solutions.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/solutions.typ), which puts
one solution inside an answer box and one inline:

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/solutions.png" width="45%" alt="Two questions with an empty answer box">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/solutions-key.png" width="45%" alt="The same questions with solutions shown in blue">
</p>

Alternatively, Typst's (experimental) *bundle* export can emit both PDFs
from a single compilation: wrap the exam in a function of the
`show-solutions` value and construct one `document` per variant. From
[examples/bundle.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/bundle.typ):

```typst
#let quiz(solutions) = {
  set page(paper: "us-letter", margin: 1in)
  show: e.prepare()
  show: e.set_(config, show-solutions: solutions)

  name-block()
  exam(questions: [
    ...
  ])
}

#document("quiz-nosolutions.pdf", quiz(false))
#document("quiz-solutions.pdf", quiz(true))
```

```bash
typst compile --features bundle -f bundle bundle.typ out/
# writes out/quiz-nosolutions.pdf and out/quiz-solutions.pdf
```

Solutions are wrapped in `context {...}`, which limits their use in some cases. You can manually access the
`show-solutions` config variable in these cases via elembic methods.

```typst
#e.get(get => {
  // `get(config).show-solutions` would read the raw config value; the
  // `show-solutions` helper also honors the command-line override.
  let solutions = show-solutions(get) != false
  let xs = lq.linspace(-2 * calc.pi, 2 * calc.pi, num: 200)
  lq.diagram(
    width: 12cm,
    height: 5.5cm,
    xlabel: $x$,
    ylabel: $y$,
    lq.plot(xs, xs.map(x => calc.sin(x)), mark: none, color: black, label: $f$),
    ..if solutions {
      (lq.plot(xs, xs.map(x => calc.cos(x)), mark: none, color: blue, stroke: 2pt),)
    } else { () },
  )
})
```

[examples/quiz.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/quiz.typ) uses this to add the answer curve of
a sketch-the-derivative question (drawn with
[lilaq](https://typst.app/universe/package/lilaq)) only on the answer key —
visible in the screenshot pair at the top of this page.

### Cross-references

Label a division with `label: <name>` and reference it with `@name`. The
displayed text adapts to where the reference appears: referencing question 1
part (a) shows "1 (a)" from inside question 2, but just "(a)" from elsewhere
in question 1. From
[examples/cross-references.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/cross-references.typ):

```typst
#question[
  #part(points: 2, label: <continuity>)[Show that $f$ is continuous at $0$.]
  #part[From a sibling part, @continuity displays as its short name.]
]
#question[From another question, @continuity displays with its question number.]
```

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/cross-references.png" width="70%" alt="References rendering as (a) from a sibling part and 1 (a) from another question">
</p>

### Page breaks inside questions

`#pagebreak()` works inside questions, parts, and subparts: the division
continues on the next page at the correct indentation, without repeating its
number.

### Name blocks

`#name-block()` renders a fill-in block (Name / Student ID by default). It
is ordinary content: put it at the top of a quiz page or on a cover page.
The rows are configurable with
`fields:` — an entry is either a `(prefix: ..., suffix: ...)` dictionary,
rendered as the prefix, an underline extending to the end of the line, and
the suffix sitting on the line at its right end. An optional `title:` is shown above the block.
From [examples/name-blocks.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/name-blocks.typ):

```typst
// The default block: a Name row and a Student ID row.
#name-block()

// Custom rows.
#name-block(fields: (
  (prefix: [#text(size: .85em)[(Given then Family)] \ NAME:]),
  (prefix: [Email address:], suffix: [`@university.edu`]),
  (prefix: [Student ID:]),
  {
    set align(center)
    text(size: .85em)[_Write legibly and darkly._]
  },
))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/name-blocks.png" width="70%" alt="A default name block and a custom one with a name hint, an email suffix, and a verbatim row">
</p>

Institution-specific layouts ship with the package as `presets`; the
University of Toronto block is `#name-block(fields:
presets.utoronto.name_fields)`.

### Exam cover page

A cover page is ordinary content before `#exam(...)`. Set the exam's
details (`institution`, `exam-name`, `term`, `duration`) on the `config`
object and render them with `#maketitle()`. Each configured value can
be overridden by passing arguments to `maketitle()`, e.g. `#maketitle(term: [Summer 2026])`.

From [examples/final-exam.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/final-exam.typ) (name fields
abridged), rendered below:

```typst
#show: e.set_(
  config,
  institution: [University of Examples],
  exam-name: [MAT 101 Final Exam],
  term: [Winter 2026],
  duration: duration(minutes: 150),
)

#maketitle()
#name-block(fields: (
  (prefix: [#text(size: .85em)[(Given then Family)] \ NAME:]),
  ..
))

#underline[_Instructions:_]
- Fill out your name and student information at the top of this page.
- Answer each question in the box provided; work outside the boxes will
  not be graded.
- The back of each page may be used for scratch work.
- No calculators or other aids are permitted.

#v(1fr)
#{
  set align(center)
  points-table
}
#pagebreak()

#exam(questions: [...])
```

See [examples/quiz.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/quiz.typ) for a minimal quiz,
[examples/final-exam.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/final-exam.typ) for a complete exam with
custom name fields, and
[examples/utoronto-exam.typ](https://github.com/siefkenj/typst-examy/blob/main/examples/utoronto-exam.typ) for the preset in
use.

<p align="center">
  <img src="https://raw.githubusercontent.com/siefkenj/typst-examy/main/examples/images/cover.png" width="60%" alt="An exam cover page with a points table">
</p>

## API Reference

<!-- API-DOCS-START — autogenerated by make_docs.sh from the elembic declarations and the DOCS constants in src/; do not edit by hand -->
All names below are exported by `#import "@preview/examy:0.2.0": *`.

### `question(body, points: none, intent: none, solution: none, rubric: none, number: auto, indent: 1.5em, label: none)`

### `part(body, points: none, intent: none, solution: none, rubric: none, number: auto, indent: 1.5em, label: none)`

### `subpart(body, points: none, intent: none, solution: none, rubric: none, number: auto, indent: 1.5em, label: none)`

Declare a question, part, or subpart — numbered `1.`, `(a)`, or `i.` respectively. The three functions take identical arguments; the numbering style is chosen by nesting depth, not by which function is called.

- `body: content` (required) — The body of the question.
- `points: int | float | none = none` — The number of points: shows a "(2 points)" badge and feeds the points table.
- `intent: "practice" | "bonus" | none = none` — Practice and bonus points are excluded from the regular totals; bonus points are tallied separately.
- `solution: content | none = none` — A solution, rendered at the end of the division when solutions are enabled.
- `rubric: content | none = none` — A grading rubric (accepted, but not yet rendered).
- `number: auto | int | content | none = auto` — `auto` numbers sequentially; an integer is the number as displayed (later divisions continue from it); content is shown verbatim; `none` omits the number.
- `indent: length = 1.5em` — Indentation of the body relative to the parent.
- `label: label | none = none` — Attach a label so the division can be referenced with `@name`.

### `answer-box(body, solution: none, width: auto, height: none, baseline: 50% - .3em, default_height: 2cm, default_width: 2cm)`

A box for students to write answers in.

- `body: content` (required) — Content shown inside the box (a prompt, `#solution[..]`, or nothing).
- `solution: content | none = none` — Solution content that fills the bottom of the box when solutions are enabled.
- `width: auto | length | ratio | relative = auto` — The width of the box; `auto` falls back to `default_width`.
- `height: length | fraction | none = none` — A fixed height gives a box of that size (`none` falls back to `default_height`); a fraction (`1fr`) makes the box grow to fill the remaining space on the page.
- `baseline: length | ratio | relative = 50% - .3em` — Baseline shift for small boxes sitting inline in a sentence; ignored for block-mode and full-width boxes.
- `default_height: length = 2cm` — The height used when `height` is `none`.
- `default_width: length = 2cm` — The width used when `width` is `auto` (inline boxes only).

### `solution(body, boxed: true)` (elembic element)

Declare a solution to a question, part, or subpart; this is only rendered if the config option to show solutions is enabled.

- `body: content` (required) — The solution content.
- `boxed: bool = true` — Whether to put the solution in a box.

### `show-solutions(get)`

Returns the effective show-solutions setting: the `--input show-solutions=..` command-line override if given, otherwise `config`'s value. Use it to conditionally render content that `#solution[..]` cannot wrap (e.g. one curve of a plot).

- `get: function` (required) — The accessor provided by `e.get(get => ..)`.

### `exam(questions: ..)` (elembic element)

Declare an exam.

- `questions: content | function` (required) — The questions in the exam or a function that accepts a `solutions_only` function and returns the exam questions.

### `maketitle(institution: auto, exam-name: auto, term: auto, duration: auto)`

The exam title block (in the spirit of LaTeX's `\maketitle`). Renders nothing if all four values resolve to `none`.

- `institution: auto | content | none = auto` — The institution name; `auto` takes `config`'s value, `none` suppresses it.
- `exam-name: auto | content | none = auto` — The exam name, shown bold; `auto` takes `config`'s value, `none` suppresses it.
- `term: auto | content | none = auto` — The term (e.g. Fall 2026); `auto` takes `config`'s value, `none` suppresses it.
- `duration: auto | duration | none = auto` — The exam length, shown under the term; `auto` takes `config`'s value, `none` suppresses it.

### `name-block(title: none, fields: ((prefix: [Name:]), (prefix: [Student ID:])))`

A block of fill-in rows for a cover page or quiz header.

- `title: content | none = none` — A heading shown centered above the block.
- `fields: (dictionary | content)[] = ((prefix: [Name:]), (prefix: [Student ID:]))` — One entry per row. A `(prefix: .., suffix: ..)` dictionary (both keys optional) renders the prefix, an underline extending to the end of the line, and the suffix sitting on the line at its right end; any other entry is content rendered verbatim as its own row.

### `config` (elembic element)

Package options. Set them with a show rule: `#show: e.set_(config, show-solutions: false, ...)`.

- `show-solutions: bool | none = none` — Whether to show solutions.
- `institution: content | none = none` — The institution name, shown by `maketitle`.
- `exam-name: content | none = none` — The name of the exam, shown by `maketitle`.
- `term: content | none = none` — The term of the exam (e.g. Fall 2026), shown by `maketitle`.
- `duration: duration | none = none` — The length of the exam, shown by `maketitle`.
- `show-rubric: bool | none = none` — Whether to show a rubric.
- `solution-background-color: color = rgb("#e6f1fb")` — The background color to use for solution boxes.
- `solution-text-color: color = rgb("#005dae")` — The text color to use for solution boxes.

### `presets`

Institution-specific argument sets. Currently `presets.utoronto.name_fields`: the University of Toronto name-block rows (NAME / Email address / UTORid).

### `num-points`

The total number of regular (non-bonus, non-practice) points. Works anywhere in the document.

### `num-questions`

The total number of questions in the exam. Works anywhere in the document.

### `points-table`

A scoring table with one column per question plus a total. Works anywhere in the document, even before the exam.

### `e`

A re-export of [elembic](https://typst.app/universe/package/elembic). Every document needs `#show: e.prepare()`; options are set with `#show: e.set_(config, ..)`; element state is read with `e.get(get => ..)`.
<!-- API-DOCS-END -->

### How `examy` Works

A straight-forward implementation of `examy` would wrap each question/part/subpart in a box
and apply an appropriate inset. Unfortunately, `#pagebreak()` cannot work inside a box and,
worse still, boxes can only negotiate fractional units if they are peers of each other. So, the
box approach would make it impossible to have a part and a subpart both share the remaining space
on the page.

Instead, `examy` flattens all question/part/subpart contents and tags the start and end of each
block with `metadata`. The flat stream is then parsed, indentation level is tracked, and peer
boxes are produced, so that `#pagebreak()` and `fr` units can negotiate space.

The downside of this parsing is that "click back" in tools like [tinymist](https://github.com/Myriad-Dreamin/tinymist)
can be broken. (Usually it works to click a sub-boxed item, like an equation.)

## License

MIT

