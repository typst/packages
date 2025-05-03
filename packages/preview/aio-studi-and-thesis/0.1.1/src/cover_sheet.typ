#let get-cover-sheet(
  primary-color: none,        // required
  secondary-color: none,      // required
  text-color: none,           // required
  background-color: none,     // required
  
  visualise-content-boxes: (  // required
    flag: false,              // required
    fill: none,               // required
    stroke: none              // required
  ),
  
  university: (
    name: none,               // required
    street: none,             // required
    city: none,               // required
    logo: none
  ),
  employer: (
    name: none,               // required
    street: none,             // required
    city: none,               // required
    logo: none
  ),
  
  cover-image: none,
  
  date: none,
  version: none,
  
  title: none,
  subtitle: none,
  description: none,
  
  authors: (
    (
      name: "Unknown author", // required
      id: "",
      email: ""
    ),
  ),
  
  faculty: none,
  programme: none,
  semester: none,
  course: none,
  examiner: none,
  submission-date: none
) = {
  import "utils.typ": *
  import "dictionary.typ": *

  set text(size: 11pt)

  let default-logo(size: 80pt) = {
    box(
      height: size,
      width: size,
      stroke: text-color,
      fill: background-color
    )[
      #align(center)[Logo]
    ]
  }

  let bold-weight = 550
  
  let div(height: 1em, body) = {
    if body != none {
      box(
        fill: if visualise-content-boxes.flag { visualise-content-boxes.fill },
        stroke: if visualise-content-boxes.flag { visualise-content-boxes.stroke },
        width: 100%
      )[
        #body
      ]
    } else {
      box(
        fill: if visualise { visualise-color } else { none },
        stroke: none,
        width: 100%,
        height: height
      )
    }
  }

  // Facilities
  let get-content-for-facility(facility) = {
    set text(1.1em, weight: bold-weight)
    
    if is-not-none-or-empty(facility) {
      if is-not-none-or-empty(facility.name) and is-not-none-or-empty(facility.street) and is-not-none-or-empty(facility.city) {
        grid(
          columns: (75%, 25%),
          align: horizon,
          [ 
            #div[
              #facility.name
              #linebreak()
              #facility.street
              #linebreak()
              #facility.city
            ]
          ],
          [
            #div[
              #let facility-dict-contains-key(key) = {
                return dict-contains-key(dict: facility, key)
              }
              
              #if facility-dict-contains-key("logo") {
                if is-not-none-or-empty(facility.logo) { 
                  facility.logo
                } else {
                  default-logo()
                }
              } else {
                default-logo()
              }
            ]
          ]
        )
      }
    }
  }
  
  div[
    #get-content-for-facility(university)
  ]
  
  if is-not-none-or-empty(university) and is-not-none-or-empty(employer) {
    if is-not-none-or-empty(university.name) and is-not-none-or-empty(employer.name) {
      div[
        #h(20pt) #text(1.1em, weight: bold-weight, style: "italic")[ #txt-cooperation ]
      ]
    }
  }

  div[
    #get-content-for-facility(employer)
  ]

  // Cover image
  if is-not-none-or-empty(cover-image) {
    div[
      #div(height: 0em)[]
      #align(center, block(height: 10em)[
        #div[
          #cover-image
        ]
      ])
      #div(height: 0em)[]
    ]
  }
  else {
    v(2fr)
  }

  v(1fr)
  
  // Date, version
  div[
    #text(1.1em)[ #date ]
    #if is-not-none-or-empty(version) {
      text(size: 15pt, weight: "regular")[ | ]
      text(1.1em)[ Version: #version ]
    }
  ]
  
  v(2pt)

  // Title
  div[
    #text(2.5em, weight: "bold", fill: primary-color, title)
  ]
  
  // Subtitle
  if is-not-none-or-empty(subtitle) {
    linebreak()
    div[
      #text(1.4em, weight: 400, fill: secondary-color, subtitle)
    ]
  }
  
  // Description
  if is-not-none-or-empty(description) {
    v(1fr)
    div[
      #text(style: "italic", weight: bold-weight, description)
    ]
  }
  
  v(1fr)

  // Authors
  div[
    #grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(start)[
          #text(fill: primary-color, weight: "bold", size: 12pt)[ #author.name ]
          #let author-dict-contains-key(key) = {
            return dict-contains-key(dict: author, key)
          }
          #if author-dict-contains-key("id") {
            if is-not-none-or-empty(author.id) {
              linebreak()
              author.id
            }
          }
          #if author-dict-contains-key("email") {
            if is-not-none-or-empty(author.email) {
              linebreak()
              link("mailto:" + author.email)[ #author.email ]
            }
          }
        ]
      )
    )
  ]
  
  v(1fr)

  // Information
  div[
    #let get-content(parameter, body) = if is-not-none-or-empty(parameter) { v(6pt) + body }
    #let get-info-description(it) = { text(weight: "bold")[ #it: ] }
  
    #grid(
      columns: (8em, auto),
      [ #get-content(faculty)[ #get-info-description(txt-faculty) ] ],
      [ #get-content(faculty)[ #faculty ] ],
      
      [ #get-content(programme)[ #get-info-description(txt-programme) ] ],
      [ #get-content(programme)[ #programme ] ],
      
      [ #get-content(semester)[ #get-info-description(txt-semester) ] ],
      [ #get-content(semester)[ #semester ] ],
      
      [ #get-content(course)[ #get-info-description(txt-course) ] ],
      [ #get-content(course)[ #course ] ],
      
      [ #get-content(examiner)[ #get-info-description(txt-examiner) ] ],
      [ #get-content(examiner)[ #examiner ] ],
      
      [ #get-content(submission-date)[ #get-info-description(txt-submission-date) ] ],
      [ #get-content(submission-date)[ #submission-date ] ],
    )
  ]
}