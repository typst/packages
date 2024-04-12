#import "@preview/scrutinize:0.1.0": grading, question, questions
// #import "@local/scrutinize:0.1.0": grading, question, questions
// #import "../src/lib.typ" as scrutinize: grading, question, questions
#import question: q
#import questions: free-text-answer, single-choice, multiple-choice, set-solution

// make the PDF reproducible to ease version control
#set document(date: none)

// toggle this comment to produce a sample solution
// #set-solution()

#set table(stroke: 0.5pt)

= Question

Write an answer.

#free-text-answer[
  An answer
]

= Question

Which of these is the fourth answer?

#single-choice(
  (
    [Answer 1],
    [Answer 2],
    [Answer 3],
    [Answer 4],
    [Answer 5],
  ),
  // 0-based indexing
  3,
)

= Question

Which of these answers are even?

#multiple-choice(
  (
    ([Answer 1], false),
    ([Answer 2], true),
    ([Answer 3], false),
    ([Answer 4], true),
    ([Answer 5], false),
  )
)
