#import "locale.typ": *

#let titlepage(
  authors,
  date,
  title-font,
  language,
  logo-left,
  logo-right,
  many-authors,
  supervisor,
  title,
  type-of-thesis,
  university,
  university-location,
  at-university,
  date-format,
  show-confidentiality-statement,
  confidentiality-marker,
  university-short,
  page-grid,
) = {

  // ---------- Page Setup ---------------------------------------

  set page(     
    // identical to document
    margin: (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm),   
  )
  // The whole page in `title-font`, all elements centered
  set text(font: title-font, size: page-grid)
  set align(center)

  // ---------- Logo(s) ---------------------------------------

  if logo-left != none and logo-right == none {           // one logo: centered
    place(                                
      top + center,
      dy: -3 * page-grid,
      box(logo-left, height: 3 * page-grid) 
    )
  } else if logo-left != none and logo-right != none {    // two logos: left & right
    place(
      top + left,
      dy: -4 * page-grid,
      box(logo-left, height: 3 * page-grid) 
    )
    place(
      top + right,
      dy: -4 * page-grid,
      box(logo-right, height: 3 * page-grid) 
    )
  }

  // ---------- Title ---------------------------------------

  v(7 * page-grid)     
  text(weight: "bold", fill: luma(80), size: 1.5 * page-grid, title)
  v(page-grid)
  
  // ---------- Confidentiality Marker (optional) ---------------------------------------

  if (confidentiality-marker.display) {
    let size = 7em
    let display = false
    let title-spacing = 2em
    let x-offset = 0pt

    let y-offset = if (many-authors) {
      7pt
    } else {
      0pt
    }

    if (type-of-degree == none and type-of-thesis == none) {
      title-spacing = 0em
    }

    if ("display" in confidentiality-marker) {
      display = confidentiality-marker.display
    }
    if ("offset-x" in confidentiality-marker) {
      x-offset = confidentiality-marker.offset-x
    }
    if ("offset-y" in confidentiality-marker) {
      y-offset = confidentiality-marker.offset-y
    }
    if ("size" in confidentiality-marker) {
      size = confidentiality-marker.size
    }
    if ("title-spacing" in confidentiality-marker) {
      confidentiality-marker.title-spacing
    }

    v(title-spacing)

    let color = if (show-confidentiality-statement) {
      red
    } else {
      green.darken(5%)
    }

    place(
      right,
      dx: 35pt + x-offset,
      dy: -70pt + y-offset,
      circle(radius: size / 2, fill: color),
    )
  }

  // ---------- Sub-Title-Infos ---------------------------------------
  // 
  // type of thesis (optional)
  if (type-of-thesis != none and type-of-thesis.len() > 0) {
    align(center, text(size: page-grid, type-of-thesis))
    v(0.25 * page-grid)
  }

  // course of studies
  text(TITLEPAGE_SECTION_B.at(language) + authors.map(author => author.course-of-studies).dedup().join(" | "),)
  v(0.25 * page-grid)

  // university
  text(university + [ ] + university-location)


  // ---------- Author(s) ---------------------------------------

  place(
    bottom + center,
    dy: -10 * page-grid,
    grid(
      columns: 100%,
      gutter: if (many-authors) {
        14pt
      } else {
        1.25 * page-grid
      },
      ..authors.map(author => align(
        center,
        {
          text(author.name)
        },
      ))
    )
  )

  // ---------- Info-Block ---------------------------------------

  set text(size: 11pt)
  place(
    bottom + center,
    grid(
      columns: (auto, auto),
      row-gutter: 1em,
      column-gutter: 1em,
      align: (right, left),

      // submission date
      text(weight: "bold", fill: luma(80), TITLEPAGE_DATE.at(language)),
      text(
        if (type(date) == datetime) {
          date.display(date-format)
        } else {
          date.at(0).display(date-format) + [ -- ] + date.at(1).display(date-format)
        },
      ),

      // students
      align(text(weight: "bold", fill: luma(80), TITLEPAGE_STUDENT_ID.at(language)), top),
      stack(
        dir: ttb,
        for author in authors {
          text([#author.student-id, #author.course])
          linebreak()
        }
      ),

      // company
      ..if (not at-university) { 
        (align(text(weight: "bold", fill: luma(80), TITLEPAGE_COMPANY.at(language)), top),
         stack(
          dir: ttb,
          for author in authors {
            let company-address = ""

            // company name
            if (
              "name" in author.company and
              author.company.name != none and
              author.company.name != ""
              ) {
              company-address+= author.company.name
            } else {
              panic("Author '" + author.name + "' is missing a company name. Add the 'name' attribute to the company object.")
            }

            // company address (optional)
            if (
              "post-code" in author.company and
              author.company.post-code != none and
              author.company.post-code != ""
              ) {
              company-address+= text([, #author.company.post-code])
            }

            // company city
            if (
              "city" in author.company and
              author.company.city != none and
              author.company.city != ""
              ) {
              company-address+= text([, #author.company.city])
            } else {
              panic("Author '" + author.name + "' is missing the city of the company. Add the 'city' attribute to the company object.")
            }

            // company country (optional)
            if (
              "country" in author.company and
              author.company.country != none and
              author.company.country != ""
            ) {
              company-address+= text([, #author.company.country])
            }

            company-address
            linebreak()
          }
        )
       )
      },

      // company supervisor
      ..if ("company" in supervisor) {
        (
          text(weight: "bold", fill: luma(80), TITLEPAGE_COMPANY_SUPERVISOR.at(language)),
          if (type(supervisor.company) == str) {text(supervisor.company)}
        )
      },

      // university supervisor
      ..if ("university" in supervisor) {
        (
          text(
            weight: "bold", fill: luma(80), 
            TITLEPAGE_SUPERVISOR.at(language) + university-short + [:]
          ),
          if (type(supervisor.university) == str) {text(supervisor.university)}
        )
      },

    )
  )
}