#let resume(
  author: "",
  location: "",
  email: "",
  github: "",
  linkedin: "",
  phone: "",
  personal_site: "",
  accent_color: "#000000",
  body,
) = {

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    // LaTeX style font
    font: "New Computer Modern",
    size: 10pt,
    lang: "en",
    // Disable ligatures so ATS systems do not get confused when parsing fonts.
    ligatures: false
  )

  // Reccomended to have 0.5in margin on all sides
  set page(
    margin: (0.5in),
    "us-letter",
  )


  // Link styles
  show link: underline


  // Small caps for section titles
  show heading.where(level: 2): it => [
    #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]

  // Accent Color Styling
  show heading: set text(
    fill: rgb(accent_color),
  )

  show link: set text(
    fill: rgb(accent_color),
  )

  // Name will be aligned left, bold and big
  show heading.where(level: 1): it => [
    #set align(left)
    #set text(
      weight: 700,
      size: 20pt,
    )
    #it.body
  ]

  // Level 1 Heading
  [= #(author)]

  // Personal Info
  pad(
    top: 0.25em,
    align(left)[
      #(
        // Phone Number
        phone,
        // Location
        location,
        // Email
        link("mailto:" + email)[#email],
        // Github
        link("https://" + github)[#github],
        // Linkedin
        link("https://" + linkedin)[#linkedin],
        // Personal Site
        link("https://" + personal_site)[#personal_site],
      ).join("  |  ")
    ],
  )

  // Main body.
  set par(justify: true)

  body
}

// Generic two by two component for resume
#let generic_two_by_two(
  top_left: "",
  top_right: "",
  bottom_left: "",
  bottom_right: "",
) = {
  pad[
    #top_left #h(1fr) #top_right \
    #bottom_left #h(1fr) #bottom_right
  ]
}

// Generic one by two component for resume
#let generic_one_by_two(
  left: "",
  right: "",
) = {
  pad[
    #left #h(1fr) #right
  ]
}

// Cannot just use normal --- ligature becuase ligatures are disabled for good reasons
#let dates_helper(
  start_date: "",
  end_date: "",
) = {
  start_date + " " + $dash.em$ + " " + end_date
}

// Section components below
#let edu(
  institution: "",
  dates: "",
  degree: "",
  gpa: "",
  location: "",
) = {
  generic_two_by_two(
    top_left: strong(institution),
    top_right: location,
    bottom_left: emph(degree),
    bottom_right: emph(dates),
  )
}

#let work(
  title: "",
  dates: "",
  company: "",
  location: "",
) = {
  generic_two_by_two(
    top_left: strong(title),
    top_right: dates,
    bottom_left: company,
    bottom_right: emph(location),
  )
}

#let project(
  role: "",
  name: "",
  url: "",
  dates: "",
) = {
  pad[
    *#role*, #name (#link("https://" + url)[#url]) #h(1fr) #dates
  ]
}

#let extracurriculars(
  activity: "",
  dates: "",
) = {
  generic_one_by_two(
    left: strong(activity),
    right: dates,
  )
}