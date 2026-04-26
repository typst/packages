#import "@preview/chic-hdr:0.4.0": *
#import "@preview/unify:0.4.3": *
#import "@preview/linguify:0.4.0": *
#import "@preview/oxifmt:0.2.0": strfmt

#import "titlepage.typ": title-page

#let 宋体 = "SimSun"
#let 黑体 = "SimHei"

#let TITLE-FONT = 黑体
#let SUBTITLE-FONT = 黑体
#let TEXT-FONT = 宋体

#let supportedLanguages = ("zh", "en")

#let __template_db = eval(load_ftl_data("./L10n", supportedLanguages))

#let objectives = [
  = #linguify("objectives", from: __template_db)
]

#let principles = [
  = #linguify("principles", from: __template_db)
]

#let apparatus = [
  = #linguify("apparatus", from: __template_db)
]

#let procedure = [
  = #linguify("procedure", from: __template_db)
]

#let data = [
  = #linguify("data", from: __template_db)
]

#let analysis = [
  = #linguify("analysis", from: __template_db)
]

/// Setup the lab report document
/// - `course-name`: The name of the course
/// - `exper-name`: The name of the experiment
/// - `exper-date`: The date of the experiment
/// - `handin-date`: The date of handing in the report
/// - `week-no`: The week number of the experiment
/// - `exper-no`: The ordinal number of the experiment
/// - `student-no`: The student number
/// - `student-name`: The student name
/// - `faculty`: The faculty name
/// - `class`: The class name
#let labreport(
  course-name: none,
  exper-name: none,
  exper-date: none,
  handin-date: none,
  week-no: none,
  exper-no: none,
  student-no: none,
  student-name: none,
  faculty: none,
  class: none,
  logos: (none, none),
  doc,
) = {
  let ord-str = [
    #if exper-no != none {
      linguify("exper-ord", args: (exper-no: exper-no), from: __template_db)
    } else if week-no != none {
      linguify("exper-week", args: (week-no: week-no), from: __template_db)
    } else {
      none
    }
  ]
  
  // Generate title page
  title-page(
    title: course-name,
    subtitle: [
      #ord-str \
      #exper-name
    ],
    author: [
      #{
        let from = if class != none {
          if faculty != none {
            [#faculty #h(1em) #class]
          } else {
            [#class ]
          }
        } else {
          if faculty != none {
            [#faculty ]
          } else {
            none
          }
        }
        if from != none [
          #from \
        ] else {
          none
        }
      } #student-name \ #student-no
    ],
    bottom-text: [
      #linguify("exper-date", args: (exper-date: exper-date), from: __template_db) \
      #linguify("handin-date", args: (handin-date: handin-date), from: __template_db)
    ],
    logos: logos,
  )
  
  // Set header & footer
  show: chic.with(
    chic-footer(),
    chic-header(
      left-side: text(course-name, size: 9pt),
      center-side: text(ord-str, size: 9pt),
      right-side: text(exper-name, size: 9pt),
    ),
    chic-separator(0.5pt),
    chic-offset(16pt),
    chic-height(64pt),
  )
  
  // Miscellanous settings
  // Numbering
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1.")
  // Spacing
  set list(indent: 2em)
  set enum(
    indent: 2em,
    spacing: 2em,
  )
  set par(first-line-indent: 2em)
  show heading: content => [
    #content
    #if content.level <= 1 {
      v(0.5em)
    }
  ]
  // Fonts
  set text(
    font: TEXT-FONT,
    style: "normal",
    weight: "regular",
  )
  // Table
  set table(stroke: (thickness: 0.5pt, paint: black))
  doc
}
