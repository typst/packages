#import "@preview/tidy:0.2.0"

#import "template.typ": *

#import "../src/lib.typ": grading, question, questions

#let package-meta = toml("../typst.toml").package
// #let date = none
#let date = datetime(year: 2024, month: 3, day: 16)

#show: project.with(
  title: "Scrutinize",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Scrutinize_ is a library for building exams, tests, etc. with Typst.
    It provides utilities for common question types and supports creating grading keys and sample solutions.
  ],
  url: package-meta.repository,
  version: package-meta.version,
  date: date,
)

// the scope for evaluating expressions and documentation
#let scope = (grading: grading, question: question, questions: questions)

#let transform-raw-lines(original, func) = {
  let (text, ..fields) = original.fields()
  text = text.split("\n")
  text = func(text)
  text = text.join("\n")
  raw(text, ..fields)
}

#let example(code, lines: none, cheat: none) = {
  // eval can't access the filesystem, so no imports.
  // for displaying, we add the imports ...
  let preamble = raw(
    "#import \"@preview/" + package-meta.name + ":" + package-meta.version + "\"" +
    ": grading, question, questions\n",
    lang: "typ",
    block: true,
  )
  // ... and for running, we have the imported entries in `scope`

  let code-to-display = transform-raw-lines(code, l => {
    // the code to display should contain imports including a blank line
    let l = preamble.text.split("\n") + l

    // if there is a line selection, apply it (the preamble counts)
    if lines != none {
      l = l.slice(lines.at(0) - 1, lines.at(1))
    }

    l
  })

  let code-to-run = if cheat == none {
    code.text
  } else {
    // for when just executing the code as-is doesn't work in the docs
    cheat.text
  }

  [
    #code-to-display

    #tidy-output-figure(eval(code-to-run, mode: "markup", scope: scope))
  ]
}

#let question-example(question, lines: none) = {
  let preamble = ```typ
  #import questions: with-solution

  #let q = [
  ```
  let epilog = ```typ
  ]

  #grid(
    columns: (1fr, 1fr),
    with-solution(false, q),
    with-solution(true, q),
  )
  ```

  let cheat = transform-raw-lines(question, l => {
    preamble.text.split("\n") + l + epilog.text.split("\n")
  })

  example(question, lines: lines, cheat: cheat)
}

= Introduction

_Scrutinize_ has three general areas of focus:

- It helps with grading information: record the points that can be reached for each question and make them available for creating grading keys.
- It provides a selection of question writing utilities, such as multiple choice or true/false questions.
- It supports the creation of sample solutions by allowing to switch between the normal and "pre-filled" exam.

Right now, providing a styled template is not part of this package's scope.

= Questions and question metadata

Let's start with a really basic example that doesn't really show any of the benefits of this library yet:

#example(```typ
// you usually want to alias this, as you'll need it often
#import question: q

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

After importing the library's modules and aliasing an important function, we simply get the same output as if we didn't do anything. The one peculiar thing here is ```typc points: 2```: this adds some metadata to the question. Any metadata can be specified, but `points` is special insofar as it is used by the `grading` module. There are two additional pieces of metadata that are automatically available:

- `body`: the complete content that was rendered as the question
- `location`: the location where the question started and the Typst `metadata` element was inserted

The body is rendered as-is, but the location and custom fields are not used unless you explicitly do; let's look at how to do that. Let's say we want to show the points in each question's header:

#example(lines: (6, 9), ```typ
// you usually want to alias this, as you'll need it often
#import question: q

#show heading: it => {
  // here, we need to access the current question's metadata
  [#it.body #h(1fr) / #question.current().points]
}

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

Here we're using the #ref-fn("question.current()") function to access the metadata of the current question. This function requires #link("https://typst.app/docs/reference/context/")[context] to know where in the document it is called, which a show rule already provides.

= Grading

The next puzzle piece is grading. There are many different possibilities to grade a test; Scrutinize tries not to be tied to specific grading strategies, but it does assume that each question gets assigned points and that the grade results from looking at some kinds of sums of these points. If your test does not fit that schema, you can simply use less of the related features.

The first step in creating a typical grading scheme is determining how many points can be achieved in total, using #ref-fn("grading.total-points()"). We also need to use #ref-fn("question.all()") to get access to the metadata distributed throughout the document:

#example(lines: (13, 27), ```typ
// you usually want to alias this, as you'll need it often
#import question: q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  [#it.body #h(1fr) / #question.current().points]
}

#context [
  #let qs = question.all()
  #let total = grading.total-points(qs)
  #let hard = grading.total-points(qs, filter: q => q.points >= 5)

  Total points: #total

  Points from hard questions: #hard
]

#q(points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```, cheat: ```typ
// you usually want to alias this, as you'll need it often
#import question: q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  [#it.body #h(1fr) / #question.current().points]
}

#context [
  #let qs = question.all().slice(2, 4)
  #let total = grading.total-points(qs)
  #let hard = grading.total-points(qs, filter: q => q.points >= 5)

  Total points: #total

  Points from hard questions: #hard
]

#q(points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

#pagebreak(weak: true)

Once we have the total points of the text figured out, we need to define the grading key. Let's say the grades are in a three-grade system of "bad", "okay", and "good". We could define these grades like this:

#example(lines: (13, 22), ```typ
// you usually want to alias this, as you'll need it often
#import question: q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  [#it.body #h(1fr) / #question.current().points]
}

#context [
  #let qs = question.all()
  #let total = grading.total-points(qs)

  #let grades = grading.grades(
    [bad], total * 2/4, [okay], total * 3/4, [good]
  )

  #grades
]

#q(points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```, cheat: ```typ
// you usually want to alias this, as you'll need it often
#import question: q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  [#it.body #h(1fr) / #question.current().points]
}

#context [
  #let qs = question.all().slice(4, 6)
  #let total = grading.total-points(qs)

  #let grades = grading.grades(
    [bad], total * 2/4, [okay], total * 3/4, [good]
  )

  #grades
]

#q(points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

Obviously we would not want to render this representation as-is, but #ref-fn("grading.grades()") gives us a convenient way to have all the necessary information, without assuming things like inclusive or exclusive point ranges. The `test.typ` example in the gallery has a more complete demonstration of a grading key.

#pagebreak(weak: true)

= Question templates and sample solutions

With the test structure out of the way, the next step is to actually write questions. There are endless ways of formulating questions, but some recurring formats come up regularly.

#pad(x: 5%)[
  _Note:_ customizing the styles is currently very limited/not possible. I would be interested in changing this, so if you have ideas on how to achieve this, contact me and/or open a pull request. Until then, feel free to "customize using copy/paste".
]

Each question naturally has an answer, and producing sample solutions can be made very convenient if they are stored with the question right away. To facilitate this, this package provides

- #ref-fn("questions.solution"): this boolean state controls whether solutions are currently shown in the document.
- #ref-fn("questions.with-solution()"): this function sets the solution state temporarily, before switching back to the original state. The `small-example.typ` example in the gallery uses this to show an answered example question at the beginning of the document.

Additionally, the solution state can be set using the Typst CLI using `--input solution=true` (or `false`, which is already the default), or by regular state updates. Within context expressions, a question can use `questions.solution.get()` to find out whether solutions are shown. This is also used by Scrutinize's question templates.

Let's look at a free text question as a simple example:

== Free text questions

In free text questions, the student simply has some free space in which to put their answer:

#question-example(```typ
#import questions: free-text-answer

// toggle the following comment or pass `--input solution=true`
// to produce a sample solution
// #questions.solution.update(true)

Write an answer.

#free-text-answer[An answer]

Next question
```)

Left is the unanswered version, right the answered one. Note that the answer occupies the same space regardless of whether it is displayed or not, and that the height can also be overridden - see #ref-fn("questions.free-text-answer()"). The content of the answer is of course not limited to text.

== single and multiple choice questions

These question types allow making a mark next to one or multiple choices. See #ref-fn("questions.single-choice()") and #ref-fn("questions.multiple-choice()") for details.

#question-example(```typ
#import questions: single-choice, multiple-choice

Which of these is the fourth answer?

#single-choice(
  range(1, 6).map(i => [Answer #i]),
  // 0-based indexing
  3,
)

Which of these answers are even?

#multiple-choice(
  range(1, 6).map(i => ([Answer #i], calc.even(i))),
)
```)

#pagebreak(weak: true)

= Module reference

// == `scrutinize`

// #{
//   let module = tidy.parse-module(
//     read("src/lib.typ"),
//     scope: scope,
//   )
//   tidy.show-module(
//     module,
//     sort-functions: none,
//     style: tidy.styles.minimal,
//   )
// }

== `scrutinize.question`

#{
  let module = tidy.parse-module(
    read("../src/question.typ"),
    label-prefix: "question.",
    scope: scope,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}

== `scrutinize.grading`

#{
  let module = tidy.parse-module(
    read("../src/grading.typ"),
    label-prefix: "grading.",
    scope: scope,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}

== `scrutinize.questions`

#{
  let module = tidy.parse-module(
    read("../src/questions.typ"),
    label-prefix: "questions.",
    scope: scope,
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}
