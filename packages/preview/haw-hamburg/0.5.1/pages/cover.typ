#import "../translations.typ": translations

#let cover_page(
  is-thesis: true,
  is-master-thesis: false,
  is-bachelor-thesis: true,
  is-report: false,

  title: "",
  author: "",
  faculty: "",
  department: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
) = {
  // Set the document's basic properties.
  set page(
    margin: (left: 0mm, right: 0mm, top: 0mm, bottom: 0mm),
    numbering: none,
    number-align: center,
  )

  // HAW Logo
  place(
    top + right,
    dx: -13mm,
    dy: 10mm,
    image("../assets/logo.svg", width: 164pt)
  )

  // Title etc.
  pad(
    left: 57mm,
    top: 66mm,
    right: 18mm,
    stack(
      // Type
      if is-thesis {
        let thesis-title = translations.bachelor-thesis
        if is-master-thesis {
          thesis-title = translations.master-thesis
        }
        upper(text(thesis-title, size: 9pt, weight: "bold"))
        v(2mm)
      },
      // Author
      text(author, size: 9pt),
      v(13mm),
      // Title
      par(
        leading: 9pt,
        text(title, size: 31pt, weight: 500),
      ),
      v(5mm),
      line(start: (0pt, 0pt), length: 30pt, stroke: 1mm),
      v(12mm),
      // Faculty
      text(translations.faculty-of + " " + faculty, size: 10pt, weight: "bold"),
      v(2mm),
      // Department
      text(translations.department-of + " " + department, size: 10pt),
    )
  )

  // University name text
  place(
    right + bottom,
    dx: -11mm,
    dy: -35mm,
    box(
      align(
        left,
        stack(
          line(start: (0pt, 0pt), length: 25pt, stroke: 0.9mm),
          v(3mm),
          text("HOCHSCHULE FÜR ANGEWANDTE", size: 9pt, weight: "bold"),
          v(2mm),
          text("WISSENSCHAFTEN HAMBURG", size: 9pt, weight: "bold"),
          v(2mm),
          text("Hamburg University of Applied Sciences", size: 9pt),
        )
      )
    )
  )

  if (is-report) {
    set text(size: 11pt)
    place(
      left + top,
      dx: 18mm,
      dy: 240mm,
      stack(
        // Submission date
        if submission-date != none {
          text(
            translations.submitted + ": " + submission-date.display("[day]. [month repr:long] [year]"),
          )

          v(10pt)
        },

        // Supervision
        if supervisors.len() > 0 and type(supervisors) != array {
          text(
            translations.supervising-examiner + ": " + text(upper(supervisors))
          )
        } else if supervisors.len() > 0 {
          stack(
            text(
              translations.supervising-examiner + ": " + text(supervisors.first())
            ),
            if supervisors.len() > 1 {
              v(10pt)
              text(
                translations.second-examiner + ": " + text(supervisors.at(1))
              )
            }
          )
        },
      )
    )
  }
  

  if is-thesis {
    // Second cover page
    pagebreak()

    // Set the document's basic properties.
    set page(
      margin: (left: 31.5mm, right: 32mm, top: 55mm, bottom: 67mm),
      numbering: none,
      number-align: center,
    )

    // Title etc.
    stack(
      // Author
      align(
        center,
        text(author, size: 14pt),
      ),
      v(23mm),
      // Title
      align(
        center,
        par(
          leading: 13pt,
          text(title, size: 18pt),
        ),
      ),
      v(22mm),
    )

    v(1fr)

    stack(
      // Content
      stack(
        spacing: 3mm,
        if is-bachelor-thesis {
          text(translations.bachelor-thesis-submitted-for-examination-in-bachelors-degree)
        },
        if is-master-thesis {
          text(translations.master-thesis-submitted-for-examination-in-masters-degree)
        },
        text(translations.in-the-study-course + " " + text(study-course, style: "italic")),
        text(translations.at-the-department + " " + department),
        text(translations.at-the-faculty-of + " " + faculty),
        text(translations.at-university-of-applied-science-hamburg),
      ),

      v(4mm),
      line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),
      v(4mm),

      // Supervision
      if supervisors.len() > 0 {
        if type(supervisors) != array {
          text(translations.supervising-examiner + ": " + text(upper(supervisors), weight: "bold"), size: 10pt)
        } else {
          text(translations.supervising-examiner + ": " + text(upper(supervisors.first()), weight: "bold"), size: 10pt)

          if supervisors.len() > 1 {
            linebreak()
            text(translations.second-examiner + ": " + text(upper(supervisors.at(1)), weight: "bold"), size: 10pt)
          }
        }
      },
    
      // Submission date
      if submission-date != none {
        stack(
          v(4mm),
          line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),
          v(4mm),
          text(
            translations.submitted + ": " + submission-date.display("[day]. [month repr:long] [year]"),
            size: 10pt,
          ),
        )
      },
    )
  }
}
