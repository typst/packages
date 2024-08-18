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

#g-question[Is it true that $x^n + y^n = z^n$ if $(x,y,z)$ and $n$ are positive integers?. Explain.] 
#v(1fr)

#g-question[Prove that the real part of all non-trivial zeros of the function $zeta(z) "is" 1/2$].
#v(1fr)

#g-question[Compute
$ integral_0^infinity (sin(x))/x $
]
#v(1fr)
