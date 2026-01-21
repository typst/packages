#import "@preview/scrutinize:0.2.0": grading, question, questions
// #import "../src/lib.typ" as scrutinize: grading, question, questions
#import question: q
#import questions: free-text-answer, single-choice, multiple-choice, with-solution

// make the PDF reproducible to ease version control
#set document(date: none)

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
