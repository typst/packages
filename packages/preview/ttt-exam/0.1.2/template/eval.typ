#import "@preview/ttt-utils:0.1.2": grading, components
#import "@preview/ttt-exam:0.1.2": small-grading-table

#let get-info(data) = {
  return data.at("info", default: (
    class:"unknown", 
    subject:"unknown",
    title: "1. Exam",
    subtitle: "",
    date: 2024-01-01,
    authors: "unknown",
  ))
}


#let process-students(students, grade-scale) = {
  students.pairs().map( ((name, points)) => {
    // sum points
    points = if type(points) == array { points.sum() } else { points }
    // get grade
    let grade = if type(points) == int or type(points) == float { grading.points-to-grade(points,grade-scale) } else { "" }
    // return dict for each student
    ("name": name, "points": points, "grade": grade)
  })
}


// get file from input.
#let file = sys.inputs.at("file", default: "meta.toml")

// read data from file
#let data = toml(file)

// page settings
#set page(
  "a4", 
  margin:2cm, 
  header: [#components.tag(get-info(data).class) -  #components.tag(fill: rgb("#C1E1C1"), get-info(data).subject) #h(1fr) #components.tag(fill: gray, get-info(data).title)]
)

#set text(font: "Rubik", lang: "de")
#set table(fill: (_,y) => if y == 0 { luma(230)})

// title
#align(center, text(16pt)[Auswertung])

// calculations
#let total-points = data.at("points", default: 0).at("total", default: 0)
#let grade-scale = grading.ihk-scale(total-points, step: 0.5, offset: 1)

#let grade-dist = state("grade-dist",("1":0,"2":0,"3":0,"4":0,"5":0,"6":0))

#let student-data = process-students(data.students, grade-scale)

#grid(
  rows: (1fr, auto),
  columns(2,table(
    columns: 3,
    inset: (_,y) => if (y < 1) { 0.5em } else {(x:0.5em, y:1em)},
    fill: (_,y) => if (y < 1) {luma(230)} else if calc.even(y) { luma(245)} else { none },
    align: center + horizon,  
    table.header("Name/ID", "Points", "Grade"),
    ..student-data.map(s => {
      let grade = if s.grade != none [
        *#s.grade* #grade-dist.update(d => { d.at(str(s.grade)) = d.at(str(s.grade)) + 1; d})
        ] else [ #text(red)[*X*] ]
    
      (s.name, [#s.points], grade)
    }).flatten()
  )),
  [
    = Verteilung

    #context small-grading-table(grade-scale, grade-dist.final())

    #stack(dir: ltr, spacing: 2em)[
      *Total-Points:* #total-points
    ][
      *Average-Grade:* #context grading.grade-average(grade-dist.final())
    ]
  ]
)
