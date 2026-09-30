#import "@preview/quizforge:0.1.0": *

// This file IS the master: compiled as-is it renders the answer key.
// Student papers:  typst compile main.typ set-A.pdf --input set=A --input mode=exam
// Grading data:    typst query main.typ "<answerkey>" --field value --one --input set=A

#show: quiz.with(
  id: "my-quiz-1", // seeds the shuffles — freeze once the paper is printed
  course: "CS 101: My Course",
  title: "Quiz 1",
  date: "2026-01-15",
  duration: "60 minutes",
  sets: ("A", "B"),
  answer-grid: true,
)

= Multiple Choice

Choose the single best answer.

+ #m(2) What is $2 + 2$?
  - 3
  - ✓ 4
  - 5
  - None of the above
  #explain[Basic arithmetic.]

= Fill in the Blanks

+ #m(1) The capital of France is #blank[Paris].

= Long Answers

+ #m(4) Explain your favorite theorem.
  #answer(6cm, rubric: [+2 statement; +2 significance.])[A model answer, shown
    only in the key.]
