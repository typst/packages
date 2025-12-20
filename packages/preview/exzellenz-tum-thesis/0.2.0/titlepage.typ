#import "cover.typ": covertitel

#let titlepage(
  title: "",
  titleDe: "",
  degree: "",
  program: "",
  school: "",
  examiner: "",
  supervisors: (),
  author: "",
  submissionDate: none,
) = {
  
  covertitel(degree: degree, program: program, school: school)
  
  align(center, text(2em, weight: 700, title))
  

  align(center, text(2em, weight: 500, titleDe))

  v(1fr)
  
  align(
    center,
    table(
      align: left,
      columns: 2,
      stroke: none,
      strong("Author: "), author,
      strong("Examiner: "), examiner,
      strong(if supervisors.len() == 1 { "Supervisor: " } else { "Supervisors: " }), supervisors.join(", \n"),
      strong("Submission Date: "), submissionDate,
    )
  )

  pagebreak()
}