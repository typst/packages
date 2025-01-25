#let covertitel(
  degree: "",
  program: "",
  school: "",
) = {
  // --- Cover ---
  v(1cm)
  align(center, image("TUM_logo.svg", width: 26%))

  v(5mm)
  upper(align(center, text(font: "New Computer Modern", 1.55em, weight: 600, "Technical University of Munich")))

  v(5mm)
  smallcaps(align(center, text(font: "New Computer Modern", 1.38em, weight: 500, "School of Computation, Information and Technology \n Informatics")))
  
  v(25mm)

  align(center, text(1.3em, weight: 100, degree + "’s Thesis in " + program))
  
  v(15mm)
}


#let cover(
  title: "",
  degree: "",
  program: "",
  author: "",
  school: "",
) = {
  
  covertitel(degree: degree, program: program, school: school)

  align(center, text(2em, weight: 700, title))
  
  v(10mm)
  align(center, text(2em, weight: 500, author))
  
  pagebreak()
}


