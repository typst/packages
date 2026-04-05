#import "@preview/g-exam:0.4.1": *

#show: exam.with(
  school: (
    name: "My School",
    logo: image("./logo.png")
  ),
  exam-info: (
    academic-period: "Academic year 2023/2024",
    academic-level: "1st Secondary Education",
    academic-subject: "Mathematics",
    number: "2nd Assessment 1st Exam",
    content: "Proofs",
    model: "Model A"
  ),
  
  language: "en",
  decimal-separator: ",",
  show-grade-table: true,
  question-points-position: left,
  clarifications: "Answer the questions in the spaces provided. If you run out of room for an answer, continue on the back of the page."
)

#question[Given the equation $x^n + y^n = z^n$ for $(x,y,z)$ and $n$ positive integers.] 
#subquestion(points:2)[For what values of $n$ is the statement in the previous question true?]
#v(1fr)
#subquestion(points:3)[For $n=2$ there's a theorem with a special name. What's that name?] 
#v(1fr)

#subquestion[What famous mathematician had an elegant proof for this theorem but
there was not enough space in the margin to write it down?].
#v(1fr)

#question(points:5)[Prove that the real part of all non-trivial zeros of the function $zeta(z) "is" 1/2$].
#v(1fr)

