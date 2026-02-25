// Permission page for graduate theses.
// Uses the document's default font (New Computer Modern), not Georgia.

#let make-permission-page(
  author: none,
  language: "swedish",
  level: "lic",
  faculty: "lith",
  division: none,
  department-english: none,
  publication-year: none,
  edition: none,
  isbn-print: none,
  isbn-pdf: none,
  doi: none,
  issn: none,
) = {
  let permission-footer = context {
    align(center, counter(page).display("i"))
  }
  page(
    numbering: "i",
    header: none,
    footer: permission-footer,
    footer-descent: 15pt,
    {
      set text(size: 10pt)
      set par(first-line-indent: 0pt, justify: true)

      // Top section: conditional on faculty and level

      // FilFak + PhD: introductory paragraph about the faculty.
      if faculty == "filfak" and level == "phd" {
        [At the Faculty of Arts and Sciences at Linköping University, research and doctoral studies are carried out within broad problem areas. Research is organized in interdisciplinary research environments and doctoral studies mainly in graduate schools. Jointly, they publish the series Linköping Studies in Arts and Sciences. This thesis comes from #division at the #department-english.]
      }

      // All licentiate: ECTS explanation (centered, small text).
      if level == "lic" {
        v(1fr)
        align(center, {
          set text(size: 8pt)
          [This is a Swedish Licentiate's Thesis]
          v(0.8em)
          [Swedish postgraduate education leads to a doctor's degree and/or a licentiate's degree.]
          linebreak()
          [A doctor's degree comprises 240 ECTS credits (4 years of full-time studies).]
          v(-0.3em)
          [A licentiate's degree comprises 120 ECTS credits.]
        })
        v(19pt)
      }

      v(1fr)

      // Bottom section: metadata block (all variants, left-aligned).
      {
        set align(left)

        v(3cm)

        [Typeset using Typst]
        v(1cm)

        [Printed by LiU-Tryck, Linköping #str(publication-year)]
        v(1cm)

        if edition != none {
          [Edition #edition]
          v(5mm)
        }

        let print-label = if language == "swedish" { "(tryckt)" } else { "(print)" }
        [© #author, #str(publication-year)]
        linebreak()
        [ISBN #isbn-print #print-label]
        linebreak()
        [ISBN #isbn-pdf (PDF)]

        if doi != none {
          linebreak()
          doi
        }

        linebreak()
        [ISSN #issn]
        linebreak()
        [Published articles have been reprinted with permission from the respective copyright holder.]
      }

      v(12pt)
    },
  )
}
