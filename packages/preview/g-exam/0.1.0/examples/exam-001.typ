#import "../g-exam.typ": g-exam, g-question, g-subquestion

#show: g-exam.with(
  author: (
    name: "Andrés Jorge Giménez Muñoz", 
    email: "matheschool@outlook.es", 
    watermark: "Teacher: andres",
  ),
  school: (
    name: "Sunrise Secondary School",
    logo: read("./logo.png", encoding: none),
  ),
  exam-info: (
    academic-period: "Academic year 2023/2024",
    academic-level: "1º Secondary Education",
    academic-subject: "Mathematics",
    number: "2nd Assessment 1st Exam",
    content: "Radicals and fractions",
    model: "Model A"
  ),
  // localization: (
  //   grade-table-queston: none,
  //   grade-table-total: none,
  //   grade-table-points: none,
  //   grade-table-calification: none,
  //   point: none,
  //   points: none,
  //   page: none,
  //   page-counter-display: none,
  //   family-name: "Apellidos *4",
  //   personal-name: none,
  //   group: none,
  //   date: none
  // ),
  
  languaje: "en",
  decimal-separator: ",",
  date: "November 21, 2023",
  // show-studen-data: "first-page",
  show-studen-data: "odd-pages",
  // show-studen-data: none,
  show-grade-table: true,
  question-point-position: right,
  // question-point-position: left,
  // question-point-position: none,
  clarifications: (
    [This test must be performed with a blue or black non-erasable pen.],
    [Cheating, talking, getting up from the chair or disturbing the rest of the class can be reasons for withdrawal from the test, which will be valued with a zero.],
    [All operations must appear, it is not enough to just indicate the result.],
  )
)

#g-question(point: 2)[Calculate the following operations and simplify if possible:
  #g-subquestion[$display(5/12 dot 9/15=)$]
  // #v(1fr)

  #g-subquestion[$display(10 dot 9/15=)$]
  // #v(1fr)

  #g-subquestion[$display(5/12 : 4/15=)$]
  #v(1fr)

  #g-subquestion[$display(2 : 5/3 =)$]
  #v(1fr)
]
#pagebreak()

#g-question(point: 2)[Calculate the following operations and simplify if possible:
  #g-subquestion[$display(4/11+5/11-2/11=)$]
  #v(1fr)

  #g-subquestion[$display(3+2/5=)$]
  #v(1fr)

  #g-subquestion[$display(7/12+2/9=)$]
  #v(1fr)

  #g-subquestion[$display(1-9/13=)$]
  #v(1fr)
]
#pagebreak()

#g-question(point: 2)[Calculate the following operations and simplify if possible:
  #g-subquestion[$display(3/5 - (1-7/10) = )$]
  #v(1fr)

  #g-subquestion[$display((3-5/3) dot (2-7/5) =)$]
  #v(1fr)
]
#pagebreak()

#g-question(point: 2)[Sort the following fractions from highest to lowest:
      \ \
      #align(center, [$ 2/3 ; 3/8 ; 4/6 ; 1/2 $])
      #v(1fr)
]    

#g-question(point: 2)[In a garden we have 20 red, 10 white and 15 yellow rose bushes.
  #g-subquestion[What fraction does each color represent?]
  #v(1fr)

  #g-subquestion[If we have pruned red rose bushes, what fraction do we have left to prune?]
  #v(1fr)
]

#g-question(point: 2)[#lorem(30)
  #g-subquestion[#lorem(35)]
  // #v(1fr)

  #g-subquestion(point: 1)[#lorem(130)]
  // #v(1fr)
]