// Graduate thesis title page layout.

#import "faculty.typ": get-degree-type-swedish

#let georgia = ("Georgia", "New Computer Modern")

#let make-graduate-title-page(
  title: (swedish: none, english: none),
  subtitle: (swedish: none, english: none),
  author: none,
  language: "swedish",
  level: "lic",
  faculty-data: none,
  department: (swedish: none, english: none),
  division: none,
  publication-year: none,
  thesis-number: none,
) = {
  page(
    numbering: none,
    header: none,
    footer: none,
    {
      set text(font: georgia)
      set par(first-line-indent: 0pt, justify: false)
      set align(center)

      v(5pt)

      // Publication series + degree word + thesis number
      {
        set text(size: 8pt)
        faculty-data.series
        linebreak()
        [#faculty-data.degree-word No. #thesis-number]
      }

      v(25mm)

      // Title
      {
        let primary-title = if language == "swedish" { title.swedish } else { title.english }
        set text(size: 14.4pt, weight: "bold")
        primary-title
      }

      // Subtitle
      {
        let primary-subtitle = if language == "swedish" { subtitle.swedish } else { subtitle.english }
        if primary-subtitle != none {
          linebreak()
          set text(size: 10pt)
          primary-subtitle
        }
      }

      v(20mm)

      // Author
      {
        set text(size: 12pt, weight: "bold")
        author
      }

      v(1fr)

      // LiU logo
      {
        let logo-path = if language == "swedish" {
          "../assets/figures/liu_primary_black_sv.pdf"
        } else {
          "../assets/figures/liu_primary_black_en.pdf"
        }
        image(logo-path, width: 60mm)
      }

      v(12mm)

      // Faculty-specific footer text
      {
        set text(size: 8pt)

        if language == "swedish" {
          if level == "lic" {
            let degree-type = get-degree-type-swedish(faculty-data.degree-prefix, level)
            [Framlagd vid #faculty-data.faculty-name vid Linköpings universitet som del av fordringarna för #degree-type]
            v(6mm)
          }
          department.swedish
          linebreak()
          [Linköping universitet]
          linebreak()
          [581 83 Linköping #h(1em) Linköping #str(publication-year)]
        } else {
          [Linköping University]
          linebreak()
          department.english
          linebreak()
          division
          linebreak()
          [SE-581 83 Linköping, Sweden]

          v(5mm)

          [Linköping #str(publication-year)]
        }
      }

      v(if language == "swedish" { 25pt } else { 11pt })
    },
  )
}
