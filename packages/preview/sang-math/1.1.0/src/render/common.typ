#import "../core/normalize.typ": normalize-question
#import "../core/validate.typ": validate-question
#import "student.typ": render-student
#import "teacher.typ": render-teacher
#import "solution.typ": render-solution
#import "answer-key.typ": render-answer-key

#let render-question-data(q, mcq, tf, short, written, mode: "student", ..args) = {
  let q = normalize-question(q)
  let _ = validate-question(q)
  let answer = q.at("answer", default: none)
  if q.kind == "mcq" and type(answer) == dictionary and answer.at("kind", default: none) == "choice" {
    q = (..q, choices: q.choices.enumerate().map(((i, c)) => (..c, correct: i + 1 == answer.value)))
  }
  if q.kind == "true-false" and type(answer) == array {
    if answer.len() != q.choices.len() { panic("sang-math: true-false answer length must match choices") }
    q = (..q, choices: q.choices.enumerate().map(((i, c)) => (..c, correct: answer.at(i))))
  }
  if mode == "student" { render-student(q, mcq, tf, short, written, ..args) }
  else if mode == "teacher" { render-teacher(q, mcq, tf, short, written, ..args) }
  else if mode == "solution" { render-solution(q, mcq, tf, short, written, ..args) }
  else if mode == "answer-key" { render-answer-key(q, num: args.named().at("num", default: none)) }
  else { panic("sang-math: render mode must be student, teacher, solution, or answer-key") }
}
