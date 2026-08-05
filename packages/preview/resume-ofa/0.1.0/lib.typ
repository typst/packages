#import "@preview/scienceicons:0.1.0": orcid-icon

#let resume(
  author: "",
  author-position: left,
  personal-info-position: left,
  pronouns: "",
  location: "",
  email: "",
  github: "",
  linkedin: "",
  phone: "",
  personal-site: "",
  orcid: "",
  accent-color: "#000000",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 9pt,
  lang: "en",
  marginxy: (x: 0.3in, y: 0.25in),
  body,
) = {

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    font: font,
    size: font-size,
    lang: lang,
    // Disable ligatures so ATS systems do not get confused when parsing fonts.
    ligatures: false
  )

  set page(
    margin: marginxy,
    paper: paper,
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
    fill: rgb(accent-color),
  )

  show link: set text(
    fill: rgb(accent-color),
  )

  // Name will be aligned left, bold and big
  show heading.where(level: 1): it => [
    #set align(author-position)
    #set text(
      weight: 700,
      size: author-font-size,
    )
    #pad(it.body)
  ]

  // Level 1 Heading
  [= #(author)]

  // Personal Info Helper
  let contact-item(value, prefix: "", link-type: "") = {
    if value != "" {
      if link-type != "" {
        link(link-type + value)[#(prefix + value)]
      } else {
        value
      }
    }
  }

  // Personal Info
  pad(
    top: 0.25em,
    align(personal-info-position)[
      #{
        let items = (
          contact-item(pronouns),
          contact-item(phone),
          contact-item(location),
          contact-item(email, link-type: "mailto:"),
          contact-item(github, link-type: "https://"),
          contact-item(linkedin, link-type: "https://"),
          contact-item(personal-site, link-type: "https://"),
          contact-item(orcid, prefix: [#orcid-icon(color: rgb("#AECD54"))orcid.org/], link-type: "https://orcid.org/"),
        )
        items.filter(x => x != none).join("  |  ")
      }
    ],
  )

  // Main body.
  set par(justify: true, leading: 0.6em, spacing: 1em)
  body
}

// Generic two by two component for resume
#let generic-two-by-two(
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

// Generic one by two component for resume
#let generic-one-by-two(
  left: "",
  right: "",
) = {
  [
    #left #h(1fr) #right
  ]
}

// Cannot just use normal --- ligature becuase ligatures are disabled for good reasons
#let dates-helper(
  start-date: "",
  end-date: "",
) = {
  start-date + " " + $dash.em$ + " " + end-date
}

// Section components below
#let edu(
  institution: "",
  dates: "",
  degree: "",
  gpa: "",
  location: "",
  // Makes dates on upper right like rest of components
  consistent: false,
) = {
  if consistent {
    // edu-constant style (dates top-right, location bottom-right)
    generic-two-by-two(
      top-left: strong(degree),
      top-right: dates,
      bottom-left: emph(institution),
      bottom-right: emph(gpa),
    )
  } else {
    // original edu style (location top-right, dates bottom-right)
    generic-two-by-two(
      top-left: strong(degree),
      top-right: gpa,
      bottom-left: emph(institution),
      bottom-right: emph(dates),
    )
  }
}

#let work(
  title: "",
  dates: "",
  company: "",
  location: "",
  one-liner: false,
) = {
  if one-liner {
    generic-one-by-two(
      left: strong(title) + ", " + emph(company),
      right: dates,
    )
  } else {
    generic-two-by-two(
      top-left: strong(title),
      top-right: dates,
      bottom-left: emph(company),
      bottom-right: emph(location),
    )
  }
}

#let project(
  role: "", // The role you had in the project (e.g. "Lead Developer", "Research Assistant", "Team Member", etc.) if applicable
  name: "", // The name of the project or research work
  org: "", // The corresponding organization for the project, if applicable (e.g. conference, company, school, etc.)
  url: "", // A URL to the project, paper, or any relevant link. Can be left empty if not applicable
  dates: "", // The dates you worked on the project or research (e.g. "Jan 2023 - May 2023", "2022", etc.)
  one-liner: true,
) = {
  if one-liner {
    generic-one-by-two(
      left: {
        if org != "" and role == "" {
          strong(name) + ", " + emph(org)
        } else if role != "" and org == "" {
          strong(role) + ", " + emph(name)
        } else {
          strong(name)
        }
      },
      right: dates,
    )
  } else {
    generic-two-by-two(
      top-left: {
        if org != "" and role == "" {
          strong(name)
        } else if role != "" and org == "" {
          strong(role)
        } else {
          strong(name)
        }
      },
      top-right: dates,
      bottom-left: {
        if org != "" and role == "" {
          emph(org)
        } else if role != "" and org == "" {
          emph(name)
        } else {
          emph(name)
        }
      },
      bottom-right: "",
    )
  }

}

#let certificates(
  name: "",
  issuer: "",
  url: "",
  date: "",
  id: "",
) = {
  set par(spacing: 0.5em)
  [
    *#name*, #issuer #h(1fr)
    #if url != "" {
      [ (#link("https://" + url)[#url])]
    }
    #if id != "" {
      "Credential ID: " + id
    }
    #date
  ]
}

#let extracurriculars(
  activity: "",
  dates: "",
) = {
  generic-one-by-two(
    left: strong(activity),
    right: dates,
  )
}

#let skills(
  category: "",
  items: "",
) = {
  set par(spacing: 0.5em)
  [
    #strong(category):
    #items
  ]
}

#let language(
  language: "",
  proficiency: "",
  url: "",
  date: "",
  cert: "",
  score: "",
  level: "",
) = {
  set par(spacing: 0.5em)
  [
    *#language*, #proficiency #h(1fr)
    #if url != "" {
      [ (#link("https://" + url)[#url])]
    }
    #if cert != "" {
      cert + ": " + score + " (" + level + ")"
    }
    #date
  ]
}
