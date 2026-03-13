#import "page-setup.typ": compute-margins, compute-margin-bottom
#import "strings.typ": get-string

#let georgia = ("Georgia", "New Computer Modern")

// Compute the ISRN string:
// LIU-{department-short}/{area}-EX-{level-code}--{YY}/{number}--SE
#let compute-isrn(department-short, faculty, level, publication-year, thesis-number) = {
  let area = if faculty == "lith" { "LITH" } else { faculty }
  let level-code = if level == "msc" { "A" } else { "G" }

  // Last two digits of the year
  let year-str = str(publication-year)
  let yy = if year-str.len() >= 2 {
    year-str.slice(year-str.len() - 2)
  } else {
    year-str
  }

  "LIU-" + department-short + "/" + area + "-EX-" + level-code + "--" + yy + "/" + thesis-number + "--SE"
}

#let make-title-page(
  format: none,
  title: (swedish: none, english: none),
  subtitle: (swedish: none, english: none),
  author: none,
  examiner: none,
  supervisor: none,
  subject: none,
  department: (swedish: none, english: none),
  department-short: "IDA",
  publication-year: none,
  thesis-number: "001",
  language: "swedish",
  level: "msc",
  faculty: "lith",
  external-supervisor: none,
) = {
  let margins = compute-margins(format)
  let margin-x = margins.outside
  let margin-bottom = compute-margin-bottom(format)
  let other-language = if language == "swedish" { "english" } else { "swedish" }
  let university-name = get-string(language, "university")
  let department-name = department.at(language)
  let thesis-label = get-string(language, "thesis-label")(level)
  let isrn = compute-isrn(department-short, faculty, level, publication-year, thesis-number)

  // The primary title and subtitle in the document language
  let primary-title = title.at(language)
  let primary-subtitle = subtitle.at(language)
  // The translated title and subtitle in the other language
  let translated-title = title.at(other-language)
  let translated-subtitle = subtitle.at(other-language)

  let logo-path = if language == "swedish" {
    "../assets/figures/liu_primary_black_sv.pdf"
  } else {
    "../assets/figures/liu_primary_black_en.pdf"
  }

  let title-area-width = 119mm

  page(
    numbering: none,
    header: none,
    footer: none,
    margin: (
      left: margin-x - 1cm,
      right: margin-x - 1cm,
      top: format.margin-top,
      bottom: margin-bottom,
    ),
    {
      set par(first-line-indent: 0pt)
      {
        let sans-font = ("New Computer Modern Sans", "New Computer Modern")
        set text(font: sans-font, size: 11pt)
        set align(right)

        university-name
        [ | ]
        department-name
        linebreak()

        thesis-label
        [ | ]
        subject
        linebreak()

        str(publication-year)
        [ | ]
        isrn
      }

      v(50mm)

      pad(left: 44mm, {
        block(width: title-area-width, {
          {
            set text(font: georgia, size: 25pt)
            set par(leading: 5pt)
            primary-title
          }

          if primary-subtitle != none {
            linebreak()
            set text(size: 13pt)
            [-- #primary-subtitle]
          }

          v(2pt)
          line(length: 100%, stroke: 0.4pt)
          v(2pt)

          {
            set text(font: georgia, size: 13pt, style: "italic")
            translated-title

            if translated-subtitle != none {
              linebreak()
              [-- #translated-subtitle]
            }
          }

          v(10mm)
          {
            set text(font: georgia, size: 12pt, weight: "bold")
            author
          }

          v(10mm)
          {
            set text(font: georgia, size: 10pt)
            let supervisor-label = get-string(language, "supervisor")
            let examiner-label = get-string(language, "examiner")

            [#supervisor-label : #supervisor]
            linebreak()
            [#examiner-label : #examiner]

            if external-supervisor != none {
              linebreak()
              let ext-label = get-string(language, "external-supervisor")
              [#ext-label : #external-supervisor]
            }
          }
        })
      })

      let adjusted-margin-x = margin-x - 1cm
      let footer-dx = 20mm - adjusted-margin-x
      let footer-dy = (format.page-height - 40mm) - format.margin-top - 6.5mm

      place(
        top + left,
        dx: footer-dx,
        dy: footer-dy,
        {
          let footer-width = format.page-width - 20mm - 20mm
          box(width: footer-width, {
            grid(
              columns: (85mm, 1fr),
              align: (left + bottom, right + bottom),
              image(logo-path, width: 85mm),
              // Shift text up to align with logo's visual bottom edge.
              move(dy: -12pt, {
                set text(font: georgia, size: 10pt)
                university-name
                linebreak()
                [SE--581 83 Linköping]
                linebreak()
                [013-28 10 00 , www.liu.se]
              }),
            )
          })
        },
      )
    },
  )
}
