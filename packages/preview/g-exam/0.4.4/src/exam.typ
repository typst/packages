#import "@preview/oxifmt:1.0.0": strfmt
// #import "@preview/valkyrie:0.2.2" as z
#import "./global.typ" : *
#import "./auxiliary.typ": *
#import "question.typ": *
#import "option.typ": *
#import "solution.typ": *
#import "clarification.typ": *
#import "sugar.typ": *
#import "pagination.typ": *
#import "decorator.typ": *

/// Template for creating an exam.
///
/// \ 
/// **Exaple**
/// ``` 
/// #show: exam.with()
/// ```
///  
///  \
/// 
/// - author: Infomation of author of exam.
///   - name (string, content): Name of author of exam.
///   - email (string): E-mail of author of exam.
///   - watermark (string): Watermark with information about the author of the document.
/// - school: Information of school.
///   - name (string, content): Name of the school or institution generating the exam.
///   - logo (none, content, bytes): Logo of the school or institution generating the exam.
/// - exam-info: Information of exam.
///   - academic-period (none, content, str): Academic period.
///   - academic-level (none, content, str): Academic level.
///   - academic-subject (none, content, str): Academic subname.
///   - number (none, content, str): Number of exam.
///   - content (none, content, str): Content of exam.
///   - model (none, content, str): Model of exam.
/// - date (none, auto, datetime): Date of generate document.
/// - keywords (string): Keywords of document.
/// - language (en, es, de, fr, pt, it, nl): Language of document. English, Spanish, German, French, Portuguese and Italian are defined.
/// - clarifications (string, content, array): Clarifications of exam. It will appear in a box on the first page.
/// - question-text-parameters: Parameter of text in question and subquestion. For example, it allows us to change the text size of the questions.
/// - show-student-data (none, true, false, "first-page", "all-pages", "odd-pages"): Show a box for the student to enter their details. It can appear on the first page, all pages or on all odd-numbered pages.
/// - show-student-number: (int) Number of student in student data.
/// - show-grade-table: (bool): Show the grade table.
/// - decimal-separator: (".", ","): Indicate the decimal separation character.
/// - question-points-position: (none, left, right): Position of question points.
/// - show-solutions: (true, false, "space", "spacex2", "spacex3"): Show the solutions.
/// - solution-color (none, color, str): Color of the text solution.
/// - draft: (true, false): It shows a draft label in the background.
/// - body (string, content): Body of exam.
/// -> content
#let exam(
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
  language: "en",
  localization: (
    grade-table-queston: none,
    grade-table-total: none,
    grade-table-points: none,
    grade-table-grade: none,
    point: none,
    points: none,
    page: none,
    page-counter-display: none,
    family-name: none,
    given-name: none,
    group: none,
    date: none,
    draft-label: none,
  ),
  date: auto,
  keywords: none,
  clarifications: none,
  question-text-parameters: none,
  show-student-data: "first-page",
  // show-student-data: (
  //   given-name: true,
  //   family-name: true,
  //   group: true,
  //   date: true
  // ),
  show-student-number: 1,
  show-grade-table: true,
  decimal-separator: ".",
  question-points-position: left,
  show-solutions: true,
  solution-color: none,
  draft: false,
  body,
) = {
  if type(show-student-data) != dictionary and type(show-student-data) != array {
    assert(show-student-data in (none, true, false, "first-page", "all-pages", "odd-pages"),
    message: "Invalid show studen data")
  }

  assert(question-points-position in (none, left, right),
      message: "Invalid question point position")

  assert(decimal-separator in (".", ","),
      message: "Invalid decimal separator")

  assert(show-solutions in (true, false, "space", "spacex2", "spacex3"),
      message: "Invalid show solutions value")

  assert(draft in (true, false, none) or type(draft) in (str, content),
      message: "Invalid show draft value")

  assert(date == none or date == auto or type(date) == datetime, 
      message: "Date must be none, auto or datetime."
  )
 
  assert(solution-color == none or type(solution-color) == color or type(solution-color) == str, 
      message: "Invalid solution color"
    )

  set document(
    title: __document-name(exam-info: exam-info),
    author: author.at("name", default:""), 
    date: date
  )

  let margin-top = 4cm + 1cm * show-student-number
  let margin-right = 2.5cm
  if (question-points-position == right) {
    margin-right = 3cm
  }

      set page(
      margin: (top: margin-top, right:margin-right),
      numbering: "1 / 1",
      number-align: right,
      header-ascent: 20%,

      header: {
        context{
          let __page-number = counter(page).at(here()).first()

          __show-header(
            page-number: __page-number,
            school: school, 
            exam-info: exam-info, 
            show-student-data: show-student-data, 
            show-student-number: show-student-number)
        }
      },

      background: {
        __show-draft(draft: draft)
      },

      footer: {
        context {
          line(length: 100%, stroke: 1pt + gray)       
          align(right)[
            #counter(page).display(__g-localization.final().page-counter-display, both: true,
            )
          ]

        __show-watermark(author: author, school: school, exam-info: exam-info, question-points-position:question-points-position)
        }
        [#hide[]<footer>]
      }
    )  

  show math.equation.where(block: false) : it => {
    if show-solutions != false {
      set text(
        top-edge: "bounds",
        bottom-edge: "bounds"
      )
      it
    }
    else {
      it
    }
  }

  __read-localization(language: language, localization: localization)
  __g-question-points-position-state.update(u => question-points-position)
  __g-question-text-parameters-state.update(question-text-parameters)

  set text(lang:language)

  if show-grade-table == true {
    context {
      __g-grade-table-header(
        decimal-separator: decimal-separator,
      )
    }
    v(10pt)
  }

  __g-show-solutions.update(show-solutions)

  __g-decimal-separator.update(decimal-separator)

  if solution-color != none {
    if type(solution-color) == str {
      solution-color = str.to.rgb(solution-color)
    }
    __g-solution-color-state.update(solution-color)
  }

  set par(justify: true) 

  if clarifications != none {
    __g-show_clarifications(clarifications: clarifications)
  }

  show: __sugar

  body
  
  [#hide[]<end-g-question-localization>]
  [#hide[]<end-g-exam>]
}

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
  language: "en",
  languaje: none,
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
  show-student-data: "first-page",
  show-grade-table: true,
  decimal-separator: ".",
  question-point-position: left,
  show-solution: true,
  body,
) = {
  panic("g-exam is obsolete, please use exam.")
}

