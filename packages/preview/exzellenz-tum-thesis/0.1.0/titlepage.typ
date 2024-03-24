#import "cover.typ": covertitel

#let titlepage(
  title: "",
  titleGerman: "",
  degree: "",
  program: "",
  supervisor: "",
  advisors: (),
  author: "",
  startDate: none,
  submissionDate: none,
) = {
  
  covertitel(degree: degree, program: program)
  
  align(center, text(2em, weight: 700, title))
  

  align(center, text(2em, weight: 500, titleGerman))

  v(1fr)
  
  align(
    center,
    table(
      align: left,
      columns: 2,
      stroke: none,
      strong("Author: "), author,
      strong("Supervisor: "), supervisor,
      strong("Advisors: "), advisors.join(", \n"),
      //strong("Start Date: "), startDate,
      strong("Submission Date: "), submissionDate,
    )
  )

  pagebreak()
}