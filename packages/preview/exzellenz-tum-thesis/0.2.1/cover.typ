#let covertitel(
  degree: "",
  program: "",
  school: "",
) = {
  // --- Cover ---
  v(1cm)
  align(center, image("TUM_logo.svg", width: 26%))

  upper(align(center, text(font: "New Computer Modern", 1.75em, weight: 700, school)))
  upper(align(center, text(font: "New Computer Modern", 1.45em, weight: 500, program)))
  upper(align(center, text(font: "New Computer Modern", 1.45em, weight: 500, "Technische Universität München")))

  v(15mm)

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


