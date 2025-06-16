#import "@preview/scrutinize:0.1.0": grading, question, questions
// #import "@local/scrutinize:0.1.0": grading, question, questions
// #import "../src/lib.typ" as scrutinize: grading, question, questions
#import question: q
#import questions: free-text-answer, single-choice, multiple-choice, set-solution, unset-solution

// make the PDF reproducible to ease version control
#set document(date: none)

#set table(stroke: 0.5pt)

#question.all(qs => {
  let total = grading.total-points(qs)

  [The candidate achieved #h(3em) out of #total points.]
})

= Instructions

#set-solution()

Use a pen. For multiple choice questions, make a cross in the box, such as in this example:

#pad(x: 5%)[
  Which of these numbers are prime?

  #multiple-choice(
    (([1], false), ([2], true), ([3], true), ([4], false), ([5], true)),
  )
]

// comment this line to produce a sample solution
#unset-solution()

#show heading: it => {
  question.current(q => [#it.body #h(1fr) / #q.points])
}

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
