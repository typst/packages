// Common Imports & Definitions

#import "@preview/fontawesome:0.6.0": fa-icon
#import "@preview/datify:1.0.0": custom-date-format


#let icon-tel = box(fa-icon("phone"))
#let icon-email = box(fa-icon("envelope"))
#let icon-github = box(fa-icon("github"))
#let icon-linkedin = box(fa-icon("linkedin"))
#let icon-webpage = box(fa-icon("globe"))
#let icon-telegram = box(fa-icon("telegram"))


// Resume Template

#let make-title-section(
  firstname: str,
  lastname: str,
  headlines: array,
  phone-number: str,
  email: str,
  github: (:),
  linkedin: (:),
  homepage: (:),
  telegram: (:),
) = {
  set text(16pt)
  set align(center)
  [= #firstname  #lastname]
  set text(10pt)


  let headline-strings = array.map(headlines, h => {
    if h.linkto != "" {
      return link(label(h.linkto))[#h.name]
    } else {
      return h.name
    }
  })

  let contacts = ()

  if phone-number != none {
    contacts.push(link("tel:" + phone-number.replace(" ", ""))[#icon-tel #phone-number])
  }

  if email != none {
    contacts.push(link("mailto:" + email)[#icon-email #email])
  }

  if github != none {
    contacts.push(link("https://www.github.com/" + github.username)[#icon-github #github.username])
  }

  if linkedin != none {
    contacts.push(link("https://www.linkedin.com/in/" + linkedin.username)[#icon-linkedin #linkedin.username])
  }

  if telegram != none {
    contacts.push(link("https:t.me/" + telegram.username)[#icon-telegram #telegram.username])
  }

  if homepage != none {
    contacts.push(link(homepage.url)[#icon-webpage #homepage.display])
  }


  headline-strings.join("  /  ")
  linebreak()
  contacts.join("  |  ")
}

#let make-section-title(title: str) = {
  set text(weight: "bold")
  [== #title]
}

#let make-experience-item(
  startdate: str,
  enddate: str,
  title: str,
  label: str,
  organization: str,
  responsibilities: str,
) = {
  let timestamp = startdate + " - "

  if enddate != none {
    timestamp = timestamp + enddate
  } else {
    timestamp = timestamp + "Present"
  }

  text(weight: "bold")[#title #label]
  [ --- ]
  text(1em, weight: "light", style: "italic")[#organization]
  h(1fr)
  timestamp

  set text(0.9em)
  set par(justify: true, linebreaks: "optimized")
  for responsibility in responsibilities {
    let strings = eval(responsibility, mode: "markup")
    [- #strings]
  }
}

#let make-experiences-section(section-title: "Experience", items: array) = {
  set align(left)

  make-section-title(title: section-title)

  for item in items {
    make-experience-item(
      startdate: item.startdate,
      enddate: item.enddate,
      title: item.title,
      label: label(item.label),
      organization: item.organization,
      responsibilities: item.responsibilities,
    )
  }
}

#let make-keywords-section(
  title: str,
  skills: array,
) = {
  set align(left)
  set align(top)

  make-section-title(title: title)

  set par(spacing: 0.5em)

  for skill in skills {
    grid(
      columns: (1.5fr, 3fr),
      text(weight: "semibold")[#skill.title], skill.items.join(", ", last: ", and ") + ".",
    )
  }
}

#let make-line() = {
  line(length: 100%, stroke: 0.5pt)
}

#let make-resume(
  body,
  educations: array,
  email: str,
  experiences: array,
  firstname: str,
  font: "Source Sans 3",
  github: (:),
  headlines: array, // [{name: str, linkto: str}]
  homepage: (:),    // {url: str, display: str}
  lastname: str,
  linkedin: (:),    // {username: str}
  margin: 0.4in,
  phone-number: str,
  skills: array,
  telegram: (:),    // {username: str}
) = {
  set align(horizon)

  set page(
    margin: (top: margin, bottom: margin, left: margin, right: margin),
  )

  set text(font: font)

  let title-section = make-title-section(
    firstname: firstname,
    lastname: lastname,
    headlines: headlines,
    email: email,
    phone-number: phone-number,
    github: github,
    linkedin: linkedin,
    homepage: homepage,
    telegram: telegram,
  )

  let experience-section = make-experiences-section(
    items: experiences,
  )

  let education-section = make-experiences-section(
    section-title: "Education",
    items: educations,
  )

  let skills-section = make-keywords-section(
    title: "Skills & Technologies",
    skills: skills,
  )

  let line = make-line()

  title-section
  line
  experience-section
  line
  skills-section
  line
  education-section
}


// Cover Letter Template

#let show-email(email: str) = {
  set text(style: "italic")
  if email != "" and email != none {
    link("mailto:" + email)[#email]
  } else {
    ""
  }
}

#let make-header(
  date: datetime.today(),
  author-firstname: str,
  author-lastname: str,
  author-email: str,
  author-phone: str,
  author-headlines: array,
) = {
  [= #author-firstname #author-lastname]

  text(
    author-headlines.map(item => item.name).join(" / "),
    style: "italic",
  )

  grid(
    columns: (1em, 1fr),
    column-gutter: 0.5em,
    gutter: 0.5em,
    icon-tel, link("tel:" + author-phone)[#author-phone],
    icon-email, link("mailto:" + author-email)[#author-email],
  )

  line(length: 100%, stroke: 0.05em)
}

#let make-salutation(
  date: datetime,
  recipient-company: str,
  recipient-email: str,
  recipient-address: str,
  recipient-name: str,
) = {
  custom-date-format(date, pattern: "long")
  linebreak()

  recipient-name
  linebreak()

  recipient-company
  linebreak()

  recipient-address.join("\n")
  linebreak()

  show-email(email: recipient-email)
  linebreak()
  linebreak()

  [Dear #recipient-name]

  linebreak()
  linebreak()
}

#let make-closing(
  author-firstname: str,
  author-lastname: str,
) = {
  linebreak()
  linebreak()
  [Best Regards,]
  linebreak()
  [#author-firstname #author-lastname]
}

#let make-body(body) = {
  set par(justify: true, linebreaks: "optimized")
  body
}

#let make-cover-letter(
  author-email: str,
  author-firstname: str,
  author-headlines: array,
  author-lastname: str,
  author-phone: str,
  body,
  date: datetime.today(),
  font: "Source Sans 3",
  margin: auto,
  recipient-address: str,
  recipient-company: str,
  recipient-email: str,
  recipient-name: str,
) = {
  set page(
    margin: (top: margin, bottom: margin, left: margin, right: margin),
  )
  set text(font: font)
  set align(horizon)

  show heading: set text(size: 2em, weight: "light")

  let header = make-header(
    author-firstname: author-firstname,
    author-lastname: author-lastname,
    author-email: author-email,
    author-phone: author-phone,
    author-headlines: author-headlines,
  )

  let salutation = make-salutation(
    date: date,
    recipient-name: recipient-name,
    recipient-company: recipient-company,
    recipient-email: recipient-email,
    recipient-address: recipient-address,
  )

  let body = make-body(body)

  let closing = make-closing(
    author-firstname: author-firstname,
    author-lastname: author-lastname,
  )

  header

  set text(weight: "light")

  salutation

  body

  closing
}
