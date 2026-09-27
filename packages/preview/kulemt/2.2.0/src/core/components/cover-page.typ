#import "../../assets/text-blobs.typ": master-strings, submission-text
#import "../utils/fonts.typ": front-font, leading-for

// Cover page and title page.
//
// kulemt-front.dtx: "The cover page and the title page have exactly the same
// layout." In v2 they are one routine (\@@_print_title_page:) called twice, so
// both list everyone and there is no coloured band. The cover/title split and
// the band were kulemt v1 features.
//
// Geometry from \@@_print_title_page::
//   * text starts 1 cm below the top edge, bottom margin 1 cm -> body 27.7 cm
//   * side margins 2 cm, always centred, even with two-sided printing -> 17 cm
//   * the logo line is 3 cm high and starts 1 cm from the left paper edge,
//     i.e. it reaches 1 cm into the left margin. The logo is placed at its
//     NATURAL size: logokuleng-en.pdf is 216 x 99.6 pt (76.2 x 35.1 mm) and
//     logokuleng-nl.pdf is 256.8 x 100.08 pt (90.6 x 35.3 mm), so both stand
//     slightly proud of the 3 cm line, exactly as in the LaTeX output.
//   * sizes/baselineskips: title 24.88/30, subtitle 17.28/22, authors 14.4/18,
//     body 12/14, people labels 12/14.5, academic year 14.4/18
//   * glue: 40pt plus 2fill, 40pt plus .3fill, 30pt plus 1fill, 20pt plus
//     2fill, then a fixed 15pt below the academic year

#let LOGO-EN = image("../../assets/logokuleng-en.png", width: 76.2mm)
#let LOGO-NL = image("../../assets/logokuleng-nl.png", width: 90.6mm)

/// The faculty logo for a programme language, as kulemt picks it from
/// faculty.logo.dutch / faculty.logo.english in kulemt.ini.
/// -> content
#let default-logo(english-master) = if english-master { LOGO-EN } else {
  LOGO-NL
}

#let generate-year(academic-year) = [
  #if type(academic-year) == array {
    [#academic-year.at(0) #sym.dash.en #academic-year.at(1)]
  } else {
    [#academic-year #sym.dash.en #(academic-year + 1)]
  }
]

/// One group of people: an italic designation, then the names one per line.
///
/// kulemt (\@@_print_people:n) uses \medskip, then 12/14.5 in \itdefault for
/// the designation, then 2pt, then the names. No colon, not bold -- 0.1.0
/// printed "*Promotor*:", which is the kulemt v1 style.
/// -> content
#let print-people(names, designations) = {
  if names != none and names.len() > 0 {
    let label = if names.len() > 1 { designations.at(1) } else {
      designations.at(0)
    }
    v(12pt)
    set par(leading: leading-for(12pt, 14.5pt), spacing: 0pt)
    text(size: 12pt, style: "italic", label)
    parbreak()
    v(2pt)
    names.join(linebreak())
    parbreak()
  }
}

/// Insert a cover page (`cover: true`) or a title page (`cover: false`).
/// -> content
#let insert-cover-page(
  title,
  subtitle,
  authors,
  promotors,
  assessors,
  supervisors,
  academic-year,
  degree,
  english-master,
  logo,
  cover: false,
  lang: "en",
) = {
  if promotors == none or promotors.len() == 0 {
    panic("A thesis needs at least one promotor/supervisor.")
  }
  let s = master-strings(english-master)
  let logo-content = if logo == auto { default-logo(english-master) } else {
    logo
  }

  page(
    paper: "a4",
    // 2 cm left and right, 1 cm top and bottom: 17 cm x 27.7 cm body.
    margin: (x: 20mm, top: 10mm, bottom: 10mm),
    header: none,
    footer: none,
    numbering: none,
  )[
    #{
      set text(font: front-font, size: 12pt, lang: lang)
      set par(justify: false, first-line-indent: 0pt, spacing: 0pt)

      // Logo line: 3 cm reserved, logo reaching 1 cm into the left margin.
      place(
        top + left,
        dx: -10mm,
        dy: 0pt,
        if logo-content == none { [] } else { logo-content },
      )
      v(30mm, weak: false)

      v(40pt)
      v(2fr)
      block(width: 100%, {
        set par(leading: leading-for(24.88pt, 30pt), spacing: 0pt)
        text(size: 24.88pt, title)
      })
      if subtitle != none {
        v(1em)
        block(width: 100%, {
          set par(leading: leading-for(17.28pt, 22pt), spacing: 0pt)
          text(size: 17.28pt, subtitle)
        })
      }

      v(40pt)
      v(0.3fr)
      block(width: 100%, {
        set par(leading: leading-for(14.4pt, 18pt), spacing: 0pt)
        text(size: 14.4pt, authors.join(linebreak()))
      })

      // Degree and people: ragged left, at most half the text width.
      v(30pt)
      v(1fr)
      align(right, block(width: 50%, {
        set align(right)
        set par(leading: leading-for(12pt, 14pt), spacing: 0pt)
        submission-text(
          degree.name,
          degree.options,
          english-master: english-master,
        )
        parbreak()
        print-people(promotors, s.promoter)
        print-people(assessors, s.assessor)
        print-people(supervisors, s.assistant)
      }))

      v(20pt)
      v(2fr)
      align(center, block({
        set par(leading: leading-for(14.4pt, 18pt), spacing: 0pt)
        text(size: 14.4pt)[#s.acyear-pre #generate-year(academic-year)]
      }))
      v(15pt)
    }
  ]
}
