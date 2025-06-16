#import "../g-exam.typ": g-exam, g-question, g-subquestion

#show: g-exam.with(
  author: (
    name: "Andrés Jorge Giménez Muñoz", 
    email: "matheschool@outlook.es", 
    watermark: "Teacher: andres",
  ),
  school: (
    name: "Sunrise Secondary School",
    logo: "./examples/logo.png",
  ),
  exam-info: (
    academic-period: "Academic year 2023/2024",
    academic-level: "1º Secondary Education",
    academic-subject: "Mathematics",
    number: "2nd Assessment 1st Exam",
    content: "Radicals and fractions",
    model: "Model A"
  ),
  
  languaje: "en",
  decimal-separator: ",",
  date: "November 21, 2023",
  show-studen-data: "first-page",
  show-grade-table: false,
  question-point-position: left,
  clarifications: "Answer the questions in the spaces provided. If you run out of room for an answer, continue on the back of the page."
)

#g-question[Given the equation $x^n + y^n = z^n$ for $(x,y,z)$ and $n$ positive integers.] 
#g-subquestion(point: 10)[For what values of $n$ is the statement in the previous question true?]
#v(1fr)
#g-subquestion(point: 10)[For $n=2$ there's a theorem with a special name. What's that name?] 
#v(1fr)

#g-subquestion(point: 10)[What famous mathematician had an elegant proof for this theorem but
there was not enough space in the margin to write it down?].
#v(1fr)

#g-question(point: 20)[Prove that the real part of all non-trivial zeros of the function $zeta(z) "is" 1/2$].
#v(1fr)
