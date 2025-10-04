
#let resume(
  // Name of the author (you)
  author: "",
  author-position: center,
  // Personal Information
  location: "",
  email: "",
  phone: "",
  linkedin: "",
  github: "",
  portfolio: "",
  personal-info-position: center,
  // Document values and format
  color-enabled: true,
  text-color: "#000080",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
  body,
) = {
  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    font: font,
    size: font-size,
    lang: lang,
    ligatures: false,
  )
  set page(
    margin: 0.5in,
    paper: paper,
  )

  // Accent Color Styling
  show heading: set text(
    fill: if color-enabled {
      rgb(text-color)
    },
  )

  show link: set text(
    fill: if color-enabled {
      rgb(text-color)
    },
  )

  // Link styles
  show link: underline
  show link: set text(
    fill: rgb(text-color),
  )

  // Name will be aligned to center, bold and big
  show heading.where(level: 1): it => [
    #set align(author-position)
    #set text(
      weight: "bold",
      size: author-font-size,
    )
    #pad(it.body)
  ]

  // Level 1 Heading
  [= #(author)]

  // Personal Information
  let contact-item(value, prefix: "", link-type: "") = {
    if value != "" {
      if link-type != "" {
        link(link-type + value)[#(prefix + value)]
      } else {
        value
      }
    }
  }
  pad(
    top: 0.25em,
    align(personal-info-position)[
      #{
        let items = (
          contact-item(phone),
          contact-item(location),
          contact-item(email, link-type: "mailto:"),
          contact-item(github, link-type: "https://"),
          contact-item(linkedin, link-type: "https://"),
          contact-item(portfolio, link-type: "https://"),
        )
        items.filter(x => x != none).join("  |  ")
      }
    ],
  )

  show heading.where(level: 2): it => [
    #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]

  // Main body.
  set par(justify: true)

  body
}

// Components layout template
#let one-by-one-layout(
  left: "",
  right: "",
) = {
  [
    #left #h(1fr) #right
  ]
}

#let two-by-two-layout(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = {
  [
    #top-left #h(1fr) #top-right \
    #bottom-left #h(1fr) #bottom-right
  ]
}

// Dates that can be use for components
//
// Example:
//
// Sep 2021 - Aug 2025 (end date is defined)
//
// Sep 2021 (if no end date defined)
#let dates-util(
  start-date: "",
  end-date: "",
) = {
  if end-date == "" {
    start-date
  } else {
    start-date + " " + $dash.em$ + " " + end-date
  }
}

// Resume components are listed below
// If you want to add some additional components, please make a PR

// Work Component
//
// Optional arguments: tech-used
#let work(
  company: "",
  role: "",
  dates: "",
  tech-used: "",
  location: "",
) = {
  if tech-used == "" {
    two-by-two-layout(
      top-left: strong(company),
      top-right: dates,
      bottom-left: role,
      bottom-right: emph(location),
    )
  } else {
    two-by-two-layout(
      top-left: strong(company) + " " + "|" + " " + strong(role),
      top-right: dates,
      bottom-left: tech-used,
      bottom-right: emph(location),
    )
  }
}

// Project Component
//
// Optional arguments: tech-used
#let project(
  name: "",
  dates: "",
  tech-used: "",
  url: "",
) = {
  if tech-used == "" {
    one-by-one-layout(
      left: [*#name* #if url != "" and dates != "" [(#link("https://" + url)[#url])]],
      right: dates,
    )
  } else {
    two-by-two-layout(
      top-left: strong(name),
      top-right: dates,
      bottom-left: tech-used,
      bottom-right: [(#link("https://" + url)[#url])],
    )
  }
}

// Education Component
#let edu(
  institution: "",
  location: "",
  degree: "",
  dates: "",
) = {
  two-by-two-layout(
    top-left: strong(institution),
    top-right: location,
    bottom-left: degree,
    bottom-right: dates,
  )
}
