# Scrutinize

Scrutinize is a library for building exams, tests, etc. with Typst.
It has three general areas of focus:

- It helps with grading information: record the points that can be reached for each question and make them available for creating grading keys.
- It provides a selection of question writing utilities, such as multiple choice or true/false questions.
- It supports the creation of sample solutions by allowing to switch between the normal and "pre-filled" exam.

Right now, providing a styled template is not part of this package's scope.
Also, visual customization of the provided question templates is currently nonexistent.

See the [manual](docs/manual.pdf) for details.

## Example

A rendered version of this example can be found in the [gallery](gallery/).

```typ
#import "@preview/scrutinize:0.2.0": grading, question, questions

#import question: q
#import questions: free-text-answer, single-choice, multiple-choice, set-solution, unset-solution

// toggle this comment or pass `--input solution=true` to produce a sample solution
// #questions.solution.update(true)

#set table(stroke: 0.5pt)

#context [
  #let total = grading.total-points(question.all())

  The candidate achieved #h(3em) out of #total points.
]

= Instructions

#with-solution(true)[
  Use a pen. For multiple choice questions, make a cross in the box, such as in this example:

  #pad(x: 5%)[
    Which of these numbers are prime?

    #multiple-choice(
      (([1], false), ([2], true), ([3], true), ([4], false), ([5], true)),
    )
  ]
]

#show heading: it => [
  #it.body #h(1fr) / #question.current().points
]

#q(points: 2)[
  = Question 1

  Write an answer.

  #free-text-answer(height: 4cm)[
    An answer
  ]
]

#q(points: 1)[
  = Question 2

  Select the largest number:


  #single-choice(
    ([5], [20], [25], [10], [15]),
    2, // 0-based index
  )
]
```
