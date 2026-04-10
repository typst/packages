#import "../includes.typ" as inc
#import "/isc_templates.typ" as isc

// Adapted from https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main

#let cover_page(
  supervisors: none,
  expert: none,
  font: "",
  title: "",
  sub-title: "",
  semester: "",
  academic-year: "",
  school: "",
  programme: "",
  major: "",
  cover-image: "",
  cover-image-height: "",
  cover-image-caption: "",
  cover-image-kind: "",
  cover-image-supplement: "",
  authors: "",
  submission-date: "",
  logo: none,
  language: "",
) = {
  let i18n = isc.i18n.with(extra-i18n: none, language)

  // Set the document's basic properties.
  set page(margin: (left: 0mm, right: 0mm, top: 0mm, bottom: 0mm), numbering: none, number-align: center)

  // School logo
  place(top + right, dx: -8mm, dy: 10mm, image("../assets/hei_logo.svg", width: 180pt))

  // Title etc.
  pad(left: 38mm, top: 75mm, right: 18mm, stack(
    // Type
    let thesis-title = i18n("bachelor-thesis-title"),
    upper(text(thesis-title, size: 14pt, weight: "bold")),
    v(2mm),
    // Author
    text(authors, size: 14pt),
    v(25mm),
    // Title
    par(leading: 11pt, text(title, size: 28pt, weight: 620)),
    v(5mm),
    line(start: (0pt, 0pt), length: 2.5cm, stroke: .7mm),
    v(5mm),
    // // Faculty
    // text(school, size: 14pt, weight: "bold"),
    // v(2mm),
    // Programme
    text(programme, size: 14pt),
  ))

  // University name text
  place(right + bottom, dx: -16mm, dy: -25mm, box(align(left, stack(
    line(start: (0pt, 0pt), length: 3cm, stroke: 0.6mm),
    v(3mm),
    text(i18n("hes-so"), size: 12pt, weight: "bold"),
    v(2mm),
    text(i18n("faculty"), size: 12pt),
    v(2mm),
    text(school, size: 12pt),
  ))))

  // Second cover page
  isc.cleardoublepage()

  set page(margin: (left: 31.5mm, right: 32mm, top: 55mm, bottom: 25mm), numbering: none, number-align: center)
  
  stack(
    // Author
    align(center, text(authors, size: 18pt)),
    v(23mm),
    // Title
    align(center, par(leading: 13pt, text(title, size: 22pt, weight: 620))),
    v(22mm),
  )

  v(1fr)

  stack(
    // Content
    stack(
      spacing: 3mm,
      text(i18n("thesis-submitted")),
      text(programme + " – " + major + " major", style: "italic"),
      text(school),
    ),
    v(6mm),
    line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),
    v(6mm),
    // Supervision
    if supervisors.len() > 0 {
      if type(supervisors) != array {
        text(i18n("supervising-examiner") + ": " + text(upper(supervisors), weight: "bold"), size: 10pt)
      } else {
        text(i18n("supervising-examiner") + ": " + text(upper(supervisors.first()), weight: "bold"), size: 10pt)

        if supervisors.len() > 1 {
          linebreak()
          text(i18n("supervising-second-examiner") + ": " + text(upper(supervisors.at(1)), weight: "bold"), size: 10pt)
        }
      }
    },
    if expert != none {    
      linebreak()
      text(i18n("supervising-expert") + ": " + text(upper(expert), weight: "bold"), size: 10pt)
    },
    // Submission date
    if submission-date != none {
      stack(v(6mm), line(start: (0pt, 0pt), length: 25pt, stroke: 1mm), v(6mm), text(
        i18n("submitted-on") + ": " + inc.custom-date-format(submission-date, i18n("date-format"), language),
        size: 10pt,
      ))
    },
  )
  
}