#import "../translations.typ": translations

#let cover_page(
  title: "",
  author: "",
  faculty: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  margin: none,
  logo: none,
) = {
  // Set the document's basic properties.
  set page(
    margin: (left: 0mm, right: 0mm, top: 0mm, bottom: 0mm),
    numbering: none,
    number-align: center,
  )

  {
    set image(width: 164pt)
    if logo == none {
      logo = image("./assets/logo.svg", width: 164pt)
    }     

    let haw_logo(image, href: "https://www.haw-kiel.de") = {
      link(href, image)
    }

    // Usage (path is local):
    place(
    top + right,
    dx: -13mm,
    dy: 10mm,
      haw_logo(logo),
    )
  }


  // Title etc.
  show title: set text(size: 31pt, weight: 500)
  pad(
    left: 40mm,
    top: 66mm,
    right: 30mm,
    stack(
      // Type
      {
      upper(text(translations.bachelor-thesis, size: 11pt, weight: "bold"))
      v(2mm)
      },
      // Author
      text(author, size: 11pt),
      v(13mm),
      // Title
      par(title, leading: 1em),
      // title,
      // std.title(),
      v(5mm),
      line(start: (0pt, 0pt), length: 30pt, stroke: 1mm),
      v(12mm),
      // Faculty
      text(translations.faculty-of + " " + faculty, size: 10pt, weight: "bold"),
    ),
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
          text("WISSENSCHAFTEN KIEL", size: 9pt, weight: "bold"),
          v(2mm),
          text("Kiel University of Applied Sciences", size: 9pt),
        ),
      ),
    ),
  )


  // Second cover page
  pagebreak()

  // Set the document's basic properties.
  set page(
    margin: margin,
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
      text(translations.bachelor-thesis-submitted),
      text(translations.study-course + " " + text(study-course, style: "italic")),
      text(translations.at-the-faculty-of + " " + faculty),
      text(translations.at-university-of-applied-science-hamburg),
    ),

    v(4mm),
    line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),
    v(4mm),

    // Supervision
    if supervisors.len() > 0 {
      if type(supervisors) != array {
        text(translations.supervising-examiner + ": " + text(supervisors, weight: "bold"))
      } else {
        text(translations.supervising-examiner + ": " + text(supervisors.first(), weight: "bold"))

        if supervisors.len() > 1 {
          linebreak()
          text(translations.second-examiner + ": " + text(supervisors.at(1), weight: "bold"), size: 10pt)
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
          translations.submitted-on + ": " + (translations.submission-date-format)(submission-date),
          size: 10pt,
        ),
      )
    },
  )
}
