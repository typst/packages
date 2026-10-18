
#import "@preview/i-figured:0.2.4": show-equation

#let year = 2026
#let default-department-info = ("University name", "Institute name", "Chair name")
#let default-course = "Course title"
#let default-semester = "Winter semester 2026/2027"
#let default-teachers = ("Prof. Teacher 1", "M. Sc. Teacher 2")

#let art
#if "art" not in (sys.inputs.keys()) {
    art = "S"
} else {
    art = sys.inputs.art
}

#let long-number(number) = {
  if number >= 10 {
    number
  } else {
    [0#number]
  }
}

#let sheet-title(
    department-info: none,
    course: none,
    semester: none,
    teachers: none,
    deadline: none,
    discussed-on: none,
    catalogue: false,
    number: 0
    ) = {
    // set par(spacing: 0.5em)
    set par(leading: 0.4em)
    table(
        // columns: 3,
        columns: (50%, 50%),
        align: (left, right),
        stroke: 0pt,
        if department-info != none {
            for l in department-info {
                [*#l*\ ]
            }
        },
        if teachers != none {
            for teacher in teachers {
                [*#teacher* \ ]
            }
        }
    )
    line(length: 100%, stroke: .5pt)
    set text(size: 14pt)
    align(center)[
        #if course != none {
            [*#course*\ ]
        }
        #if semester != none {
            [*#semester*\ ]
        }
        #if (catalogue) {
            [*Problem catalogue#if (art == "S" or art == "T") {
                [, ]
                if (art == "T") {
                    [Tutor ]
                }
                [solutions]
            }* \ ]
        } else {
            [*Sheet #long-number(number)#if (art == "S" or art == "T") {
                [, ]
                if (art == "T") {
                    [Tutor ]
                }
                [solutions]
            }* \ ]
            if deadline != none {
                [*Deadline: #deadline*\ ]
            }
            if discussed-on != none {
                [*Discussed on #discussed-on*\ ]
            }
        }
    ]
    line(length: 100%, stroke: .5pt)
}

#let my-show-equation = show-equation.with(
  only-labeled: true,
  prefix: "eq:",
  numbering: (..nums) => [(#nums.at(1))]
)

#let my-show-ref = it => {
//   let eq = math.equation
  let el = it.element
  if el.func() == math.equation {
    link(el.location(), text(rgb("0000ff"))[Equation #numbering(
        el.numbering,
        ..counter(math.equation).at(el.location())
    )])
  } else if el.func() == figure {
    link(el.location(), text(rgb("0000ff"))[
      #if (el.kind == "algorithm") {
        [Algorithm]
      } else {
        [Figure]
      }
      #numbering(
        el.numbering,
        ..counter(figure).at(el.location())
    )])
  } else if el.func() == table {
    link(el.location(), text(rgb("0000ff"))[Table #numbering(
        "1",
        ..counter(table).at(el.location())
    )])
  } else if el != none and el.func() == enum.item {
    link(el.location(), text(rgb("0000ff"))[#numbering(enum.numbering, el.number)])
  } else {
    link(el.location(), text(rgb("0000ff"))[TODO: #el.func()])
  }
}

#let problems = counter("problemcounter")

#let problem(title: none, body) = {
    problems.step()
    [\ *Problem #context problems.display()*]
    if title != none {
        [*: #title*]
    }
    [.\ ]
    body
}

#let solution(student: true, body) = {
    if (art == "T" or (student and art == "S")) {
        [\ *Solution:* #h(0.5em)]
        body
    }
}

#let exercise-sheet(
    doc,
    course: none,
    semester: none,
    teachers: none,
    department-info: none,
    discussed-on: none,
    deadline: none,
    number: 0,
    catalogue: false,
) = [
    #show math.equation: my-show-equation
    #show ref: my-show-ref
    // #show figure: my-show-figure
    // #show figure.caption: my-show-figure-caption
    #show link: set text(rgb("0000ff"))
    #show math.equation.where(block: true): block.with(width: 100%)

    #set text(font: "New Computer Modern")
    #set page(
        margin: (left: 12%, right: 12%, top: 7%),
        numbering: "1"
    )
    #set par(
    spacing: 0.8em,
    justify: true,
    leading: 0.5em
    )

    #if "number" in sys.inputs.keys() {number = int(sys.inputs.number)}

    #set document(title: [Exercise sheet #long-number(number)]);

    #set enum(numbering: "(a)", spacing: 1em, indent: 0em)
    #set list(spacing: 1em, indent: 1em)

    #if catalogue {
        sheet-title(
            course: course,
            semester: semester,
            teachers: teachers,
            department-info: department-info,
            catalogue: true
        )
    } else {
        sheet-title(
            course: course,
            semester: semester,
            teachers: teachers,
            department-info: department-info,
            discussed-on: discussed-on,
            deadline: deadline,
            number: number
        )
    }

    #doc
]



// * Commands

#let skp(v, w) = $chevron.l #v, #w chevron.r$
#let span = "span"
#let sign = "sign"
#let argmin = $op("arg min", limits: #true)$
#let argmax = $op("arg max", limits: #true)$

#let maximum(xs) = {
    let max = xs.at(0)
    for x in xs {
        if x > max {
            max = x
        }
    }
    max
}

#let minimum(xs) = {
    let min = xs.at(0)
    for x in xs {
        if x < min {
            min = x
        }
    }
    return min
}

#let extrema(xs) = (minimum(xs), maximum(xs))

#let inv(A) = $#A^(-1)$

#let cond = $cal(K)$

#let farg = $space.hair dot space.hair$
