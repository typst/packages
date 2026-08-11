#import "locale.typ": *

#let titlepage(
  authors,
  date,
  title-font,
  language,
  logo,
  many-authors,
  supervisor,
  title,
  type-of-thesis,
  university,
  faculty,
  date-format,
  show-confidentiality-statement,
  confidentiality-marker,
  page-grid,
  startdate,
  enddate
) = {

  // ---------- Page Setup ---------------------------------------

  set page(     
    // identical to document
    margin: (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm),   
  )
  // The whole page in `title-font`, all elements centered
  set text(font: title-font, size: page-grid)
  set align(center)

  // ---------- Logo ------------------------------------------

  if logo != none {
    place(
      top + center,
      dy: -3 * page-grid,
      box(logo, height: 3 * page-grid) 
    )
    v(1 * page-grid)
  } else {
    v(0.25 * page-grid)
  }

  // university
  text(size: 1.3 * page-grid, university)
  linebreak()
  // v(0.25 * page-grid)

  // faculty
  if faculty != none {
    text(TITLEPAGE_FACULTY.at(language) + " " + faculty)
    v(0.25 * page-grid)
  }
  else {
    v(1.25 * page-grid)
  }

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


  // type of thesis (optional)
  if (type-of-thesis != none and type-of-thesis.len() > 0) {
    v(4 * page-grid)
    align(center, text(size: page-grid*1.2, weight: "bold", type-of-thesis))
    // v(0.25 * page-grid)
  }

  // course of studies
  text(TITLEPAGE_SECTION_B.at(language) + " " + authors.map(author => author.course-of-studies).dedup().join(" | "),)
  v(0.25 * page-grid)
  
  
  // ---------- Title ---------------------------------------

  v(0.25 * page-grid)
  text(weight: "bold", fill: luma(80), size: 1.5 * page-grid, title)
  v(page-grid)


  

  // ---------- Author(s) ---------------------------------------
  v(1.5 * page-grid)
  place(center, text(size: page-grid, TITLEPAGE_BY.at(language)))

  v(1.25 * page-grid)
  place(
    center,
    // dy: -16 * page-grid,
    grid(
      columns: 100%,
      gutter: if (many-authors) {
        14pt
      } else {
        1 * page-grid
      },
      ..authors.map(author => align(
        center,
        {
          text(author.name) + if author.degree != none {
            ", " + author.degree
          }
          linebreak()
          text(TITLEPAGE_STUDENT_ID.at(language) + " " + author.student-id)
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

      // time frame
      if startdate != none and enddate != none {
        text(weight: "bold", fill: luma(80), TITLEPAGE_TIME_FRAME.at(language))
      },
        text(if startdate != none and enddate != none {
          text(startdate.display(date-format))
          text([ -- ])
          text(enddate.display(date-format))
        }),

      // submission date
      text(weight: "bold", fill: luma(80), TITLEPAGE_DATE.at(language)),
      text(
        if (type(date) == datetime) {
          date.display(date-format)
        } else {
          date.at(0).display(date-format) + [ -- ] + date.at(1).display(date-format)
        },
      ),

      v(0.5 * page-grid), v(0.5 * page-grid),
      // first supervisor
      ..if ("first" in supervisor) {
        (
          text(weight: "bold", fill: luma(80), TITLEPAGE_SUPERVISOR_FIRST.at(language)),
          if (type(supervisor.first) == str) {text(supervisor.first)}
        )
      },

      // second supervisor
      ..if ("second" in supervisor) {
        (
          text(
            weight: "bold", fill: luma(80), 
            TITLEPAGE_SUPERVISOR_SECOND.at(language)
          ),
          if (type(supervisor.second) == str) {text(supervisor.second)}
        )
      },

    )
  )
}