#import "@preview/oxifmt:0.2.0": strfmt
#import "./global.typ" : *
#import "./auxiliary.typ": *
#import "./g-question.typ": *
#import "./g-solution.typ": *
#import "./g-clarification.typ": *

/// Template for creating an exam.
/// 
/// - autor: Infomation of autor of exam.
///  - name (string, content): Name of author of exam.
///  - email (string): e-mail of author of exam.
///  - watermark (string): Watermark with information about the author of the document.
/// - scholl: Information of scholl.
///  - name (string, content): Name of the school or institution generating the exam.
///  - logo (none, content, bytes): Logo of the school or institution generating the exam.
/// - exam-info: Information of exam
///  - academic-period(none, content, str): academic period.
///  - academic-level(none, content, str): acadmic level.
///  - academic-subject(none, content, str): acadmic subname,
///  - number(none, content, str): Number of exam.
///  - content(none, content, str): Conten of exam.
///  - model(none, content, str): Model of exam.
/// - date (sting): Date of generate document.
/// - keywords (string): keywords of document.
/// - languaje (en, es, de, fr, pt, it): Languaje of docuemnt. English, Spanish, German, Portuguese and Italian are defined.
///     Ejemplo buy bonito:
/// - clarifications (string, content, array): Clarifications of exam. It will appear in a box on the first page.
/// - question-text-parameters: Parameter of text in question and subquestion. For example, it allows us to change the text size of the questions.
/// - show-studen-data(none, true, false, "first-page", "odd-pages"): It shows a box for the student to enter their details. It can appear on the first page or on all odd-numbered pages.
/// - show-grade-table: (bool): Show grade table.
/// - decimal-separator: (".", ","): Indicates the decimal separation character.
/// - question-point-position: (none, left, right): Position of question point.
/// - show-solution: (true, false): It shows the solutions to the questions.
#let g-exam(
  author: (
    name: "",
    email: none,
    watermark: none
  ),
  school: (
    name: none,
    logo: none,
  ),
  exam-info: (
    academic-period: none,
    academic-level: none,
    academic-subject: none,
    number: none,
    content: none,
    model: none
  ),
  languaje: "en",
  localization: (
    grade-table-queston: none,
    grade-table-total: none,
    grade-table-points: none,
    grade-table-calification: none,
    point: none,
    points: none,
    page: none,
    page-counter-display: none,
    family-name: none,
    given-name: none,
    group: none,
    date: none
  ),
  date: none,
  keywords: none,
  clarifications: none,
  question-text-parameters: none,
  show-studen-data: "first-page",
  show-grade-table: true,
  decimal-separator: ".",
  question-point-position: left,
  show-solution: true,
  body,
) = {
  
  assert(show-studen-data in (none, true, false, "first-page", "odd-pages"),
      message: "Invalid show studen data")

  assert(question-point-position in (none, left, right),
      message: "Invalid question point position")

  assert(decimal-separator in (".", ","),
      message: "Invalid decimal separator")

  assert(show-solution in (true, false),
      message: "Invalid show solution value")

  set document(
    title: __document-name(exam-info: exam-info).trim(" "),
    author: author.name
  )

  let margin-right = 2.5cm
  if (question-point-position == right) {
    margin-right = 3cm
  }

  set page(
    paper: "a4", 
    margin: (top: 5cm, right:margin-right),
    numbering: "1 / 1",
    number-align: right,
    header-ascent: 20%,
    header:locate(loc => {
        let page-number = counter(page).at(loc).first()
        if (page-number==1) { 
          align(right)[#box(
            width:108%,
            grid(
              columns: (auto, auto),
              gutter:0.7em,        
              align(left + top)[
                #if(school.at("logo", default : none) != none) {
                  set image(height:2.5cm, width: 2.7cm, fit:"contain")
                  if(type(school.logo) == "content") {
                    school.logo
                  }
                  else if(type(school.logo) == "bytes") {
                    image.decode(school.logo, height:2.5cm, fit:"contain")
                  }
                  else {
                    assert(type(school.logo) in (none, "content", "bytes") , message: "school.logo be of type content or bytes.")
                  }
                }
              ],
              grid(
                rows: (auto, auto, auto),
                gutter:1em,    
                  grid(
                    columns: (auto, 1fr, auto),
                    align(left  + top)[
                      #school.name \  
                      #exam-info.academic-period \
                      #exam-info.academic-level
                    ],
                    align(center + top)[
                    // #exam-info.number #exam-info.content \
                    ],
                    align(right + top)[
                      #exam-info.at("academic-subject", default: none)  \  
                      #exam-info.number \
                      #exam-info.content 
                    ],
                  ),
                  line(length: 100%, stroke: 1pt + gray),
                  if show-studen-data in (true, "first-page", "odd-pages") {
                    __g-student-data()
                  }
              )
          )
          )]
        }
        else if calc.rem-euclid(page-number, 2) == 1 {
            grid(
              columns: (auto, 1fr, auto),
              gutter:0.3em,
              align(left  + top)[
                #school.name \  
                #exam-info.academic-period \
                #exam-info.academic-level
              ], 
              align(center + top)[
                // #exam-info.number #exam-info.content \
              ],
              align(right + top)[
                #exam-info.at("academic-subject", default: none) \
                #exam-info.number \
                #exam-info.content 
              ]
            )
            line(length: 100%, stroke: 1pt + gray) 
            if show-studen-data == "odd-pages" {
              __g-student-data(show-line-two: false)
            }
        }
        else {
           grid(
              columns: (auto, 1fr, auto),
              gutter:0.3em,
              align(left  + top)[
                #school.name \  
                #exam-info.academic-period \
                #exam-info.academic-level
              ], 
              align(center + top)[
                // #exam-info.number #exam-info.content \
              ],
              align(right + top)[
                #exam-info.at("academic-subject", default: none) \
                #exam-info.number \
                #exam-info.content \
              ]
            )
            line(length: 100%, stroke: 1pt + gray) 
        }
      } 
    ),

    footer: locate(loc => {
        line(length: 100%, stroke: 1pt + gray) 
        align(right)[
            #__g-localization.final(loc).page
            #counter(page).display(__g-localization.final(loc).page-counter-display, both: true,
            )
        ]
        // grid(
        //   columns: (1fr, 1fr, 1fr),
        //   align(left)[#school.name],
        //   align(center)[#exam-info.academic-period],
        //   align(right)[
        //     Página 
        //     #counter(page).display({
        //       "1 de 1"},
        //       both: true,
        //     )
        //   ]
        // )

        __show-watermark(author: author, school: school, exam-info: exam-info, question-point-position:question-point-position)
      }
    )
  )

  set par(justify: true) 
  set text(font: "New Computer Modern")
  
  __read-localization(languaje: languaje, localization: localization)
  __g-question-point-position-state.update(u => question-point-position)
  __g-question-text-parameters-state.update(question-text-parameters)

  set text(lang:languaje)

  if show-grade-table == true {
    __g-grade-table-header(
      decimal-separator: decimal-separator,
    )
    v(10pt)
  }

  __g-show-solution.update(show-solution)

  set par(justify: true) 

  if clarifications != none {
    __g-show_clarifications(clarifications: clarifications)
  }

  show regex("=\?"): it => {
      let (sugar) = it.text.split()
      g-question[]
    }

  show regex("=\? (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-question[#rest.join(" ")]
    }

  show regex("=\? [[:digit:]] (.+)"): it => {
      let (sugar, point, ..rest) = it.text.split()
      g-question(point:float(point))[#rest.join(" ")]
    }

  show regex("==\?"): it => {
      let (sugar) = it.text.split()
      g-subquestion[]
    }

  show regex("==\? (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-subquestion[#rest.join(" ")]
    }

  show regex("==\? [[:digit:]] (.+)"): it => {
      let (sugar, point, ..rest) = it.text.split()
      g-subquestion(point:float(point))[#rest.join(" ")]
    }

  show regex("=! (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-solution[#rest.join(" ")]
    }

  show regex("=% (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-clarification[#rest.join(" ")]
    }

  body
  
  [#hide[]<end-g-question-localization>]
  [#hide[]<end-g-exam>]
}
