#import "monash-colors.typ": *

/***********************/
/* TEMPLATE DEFINITION */
/***********************/

/* HANDLING DATE DISPLAY */

#let translate_month(month) = {
  // Construction mapping for months
  let t = (:)
  let fr-month-s = ("Janv.", "Févr.", "Mars", "Avr.", "Mai", "Juin",
    "Juill.", "Août", "Sept.", "Oct.", "Nov.", "Déc.")
  let fr-months-l = ("Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre")
  for i in range(12) {
    let idate = datetime(year: 0, month: i + 1, day: 1)
    let ml = idate.display("[month repr:long]")
    let ms = idate.display("[month repr:short]")
    t.insert(ml, fr-months-l.at(i))
    t.insert(ms, fr-month-s.at(i))
  }

  // Translating month
  let fr_month = t.at(month)
  fr_month
}

#let display-date(date, short-month) = {
  context {
    // Getting adapted month string
    let repr = if short-month { "short" } else { "long" }
    let month = date.display("[month repr:" + repr + "]")
    let day = date.display("[day]")

    // Translate if necessary
    if text.lang == "fr" {
      month = translate_month(month)
    }

  // Returns month and year
  [#day #month #str(date.year())]
  }
}


/* MAIN COVER DEFINITION */

#let cover(title, author, date-start, date-end, subtitle: none, logo: none, short-month: false, logo-horizontal: true, student-id: none, course-code: none, course-name: none, assignment-type: "Assignment", tutor-name: none, word-count: none, date: none, show-typst-attribution: true) = {
  // Modern gradient background
  set page(background: {
    // Subtle gradient background
    let gradient = gradient.linear(
      rgb(245, 250, 255),
      rgb(230, 242, 255),
      angle: 135deg
    )
    rect(width: 100%, height: 100%, fill: gradient)
    
    // Monash logo as subtle watermark
    place(
      center + horizon,
      dx: 0pt, dy: -35%,
      image("../../assets/Monash University-04.svg", width: 35%)
    )
    
    // Typst logo in bottom right corner (conditional)
    if show-typst-attribution {
      place(
        bottom + right,
        dx: -20pt, dy: -20pt,
        {
          set text(size: 8pt, fill: rgb(150, 150, 150))
          box(
            baseline: 0pt,
            link("https://typst.app", "Made with Typst")
          )
          h(3pt)
          box(
            baseline: 3pt,
            image("../../assets/typst.png", height: 10pt)
          )
        }
      )
    }
  })
  
  set text(hyphenate: false)
  set align(center)

  v(2fr)

  // Title with modern styling
  set text(size: 28pt, weight: "bold", fill: monash-blue)
  box(width: 85%)[
    #upper(title)
  ]
  
  // Decorative underline
  v(0.5em)
  box(width: 60%, height: 2pt, fill: monash-bright-blue)

  v(1fr)

  // Assignment type indicator
  set text(size: 16pt, fill: monash-blue, weight: "bold")
  box(width: 30%)[
    #assignment-type
  ]

  v(0.8fr)

  if subtitle != none {
    set text(size: 16pt, fill: monash-navy, style: "italic")
    box(width: 75%)[
      #subtitle
    ]
    v(0.8fr)
  }

  // Student information section
  box(width: 90%)[#{
    set text(size: 14pt, fill: monash-navy, weight: "bold")
    text("Student Information")
    linebreak()
    set text(weight: "regular")
    author
    if student-id != none {
      linebreak()
      text("Student ID: ") + student-id
    }
  }]

  v(0.5fr)

  // Course information section
  box(width: 90%)[#{
    set text(size: 14pt, fill: monash-navy, weight: "bold")
    text("Course Information")
    linebreak()
    set text(weight: "regular")
    if course-code != none {
      course-code
      linebreak()
    }
    if course-name != none {
      course-name
    }
  }]

  v(0.5fr)

  // Tutor and word count information
  box(width: 90%)[#{
    set text(size: 14pt, fill: monash-navy)
    if tutor-name != none {
      set text(weight: "bold")
      text("Tutor: ") + tutor-name
      linebreak()
    }
    if word-count != none {
      set text(weight: "bold")
      text("Word Count: ") + str(word-count)
    }
  }]

  v(0.5fr)

  // Date information
  if date != none {
    box(width: 60%)[#{
      set text(size: 14pt, fill: monash-blue, weight: "medium")
      text("Date: ") + display-date(date, short-month)
    }]
  }

  v(1fr)
}