#import "metadata.typ": *
#import "@preview/fontawesome:0.2.1": *

#let text-font = "Hanken Grotesk"
#let text-size = 9pt
#let header-name = [#first-name #last-name]
#let title = [#sub-title]


#let text-colors = (
  light-gray: rgb("#ededef"),
  medium-gray: rgb("#78787e"),
  dark-gray: rgb("#3c3c42"),
)

#let accent-color = rgb("#d4d2cc")

#let import-section(file) = {
  include {
    "content/" + file + ".typ"
  }
}


#let layout(doc) = {
  set text(
    fill: text-colors.dark-gray,
    font: text-font,
    size: text-size,
  )
  set align(left)
  set page(
    fill: rgb("F4F1EB"),
    paper: "a4",
    margin: (
      left: 1.2cm,
      right: 1.2cm,
      top: 1.6cm,
      bottom: 1.2cm,
    ),
  )
  doc
}

#let section-title-style(str) = {
  text(
    size: 12pt,
    weight: "bold",
    fill: text-colors.dark-gray,
    str,
  )
}

#let name-block() = {
  text(
    fill: text-colors.dark-gray,
    size: 30pt,
    weight: "extrabold",
    header-name,
  )
}

#let title-block() = {
  text(
    size: 15pt,
    style: "italic",
    fill: text-colors.dark-gray,
    title,
  )
}

#let info-block-style(icon, txt) = {
  text(
    size: 10pt,
    fill: text-colors.medium-gray,
    weight: "medium",
    fa-icon(icon) + h(5pt) + txt,
  )
}

#let info-block() = {
  table(
    columns: 1fr,
    inset: -1pt,
    stroke: none,
    row-gutter: 3mm,
    [#info-block-style("location-dot", info.address) #h(2pt) #info-block-style(
        "phone",
        info.telephone,
      ) #h(2pt) #info-block-style("envelope", info.email) #h(2pt) #info-block-style(
        "linkedin",
        info.linkedin,
      ) #h(2pt) #info-block-style("github", info.github)],
  )
}

#let header-table() = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 4mm,
    [#name-block()],
    [#title-block()],
    [#info-block()],
  )
}

#let make-header-photo(profile-photo) = {
  if profile-photo != false {
    box(
      clip: true,
      radius: 50%,
      image(profile-image),
    )
  } else {
    box(
      clip: true,
      stroke: 5pt + yellow,
      radius: 50%,
      fill: yellow,
    )
  }
}

#let cv-header(left-comp, right-comp, cols, align) = {
  table(
    columns: cols,
    inset: 0pt,
    stroke: none,
    column-gutter: 10pt,
    align: horizon,
    {
      left-comp
    },
    {
      right-comp
    }
  )
}

#let create-header(
  use-photo: false,
) = {
  cv-header(
    header-table(),
    make-header-photo(use-photo),
    (74%, 20%),
    left,
  )
}

#let cv-section(title) = {
  section-title-style(title)
  h(4pt)
}

#let date-style(date) = (
  table.cell(
    align: right,
    text(
      size: 9pt,
      weight: "bold",
      style: "italic",
      date,
    ),
  )
)

#let degree-style(degree) = (
  text(
    size: 10pt,
    weight: "bold",
    degree,
  )
)

#let institution-style(institution) = (
  table.cell(
    text(
      size: 9pt,
      style: "italic",
      weight: "medium",
      institution,
    ),
  )
)

#let location-style(location) = (
  table.cell(
    text(
      style: "italic",
      weight: "medium",
      location,
    ),
  )
)

#let tag-style(str) = {
  align(
    right,
    text(
      weight: "regular",
      str,
    ),
  )
}

#let tag-list-style(tags) = {
  for tag in tags {
    box(
      inset: (x: 0.4em),
      outset: (y: 0.3em),
      fill: accent-color,
      radius: 3pt,
      tag-style(tag),
    )
    h(5pt)
  }
}

#let profile-entry(str) = {
  text(
    size: text-size,
    weight: "medium",
    str,
  )
}

#let reference-entry(
  name: "Name",
  title: "Title",
  company: "Company",
  telephone: "Telephone",
  email: "Email",
) = {
  table(
    columns: (3fr, 2fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    [#degree-style(name)],
    [#date-style(company)],
    table.cell(colspan: 2)[#institution-style(telephone), #location-style(email)],
  )
  v(2pt)
}

#let education-entry(
  degree: "Degree",
  date: "Date",
  institution: "Institution",
  location: "Location",
  description: "",
  highlights: (),
) = {
  table(
    columns: (3fr, 1fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    [#degree-style(degree)], [#date-style(date)],
    [#institution-style(institution), #location-style(location)],
  )
  v(2pt)
}

#let experience-entry(
  title: "Title",
  date: "Date",
  company: "Company",
  location: "Location",
) = {
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    [#degree-style(title)] ,
    [#date-style(date)],
    table.cell(colspan: 2)[#institution-style(company), #location-style(location)],
  )
  v(5pt)
}

#let skill-style(skill) = {
  text(
    weight: "bold",
    skill,
  )
}

#let skill-tag(skill) = {
  box(
    inset: (x: 0.3em),
    outset: (y: 0.2em),
    fill: accent-color,
    radius: 3pt,
    skill-style(skill),
  )
}

#let skill-entry(
  skills: (),
) = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 2mm,
    column-gutter: 3mm,
    align: center,
    for sk in skills {
      [#skill-tag(sk) #h(4pt)]
    },
  )
}


#let language-entry(
  language: "Language",
  proficiency: "Proficiency",
) = {
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    align: left,
    table.cell(
      text(
        weight: "bold",
        language,
      ),
    ),
    table.cell(
      align: right,
      text(
        weight: "medium",
        proficiency,
      ),
    )
  )
}

#let recipient-style(str) = {
  text(
    style: "italic",
    str,
  )
}

#let recipient-entry(
  name: "Name",
  title: "Title",
  company: "Company",
  address: "Address",
  city: "City",
) = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    align: left,
    recipient-style(name),
    recipient-style(title),
    recipient-style(company),
    recipient-style(address),
  )
}

#let get-header-by-language(english-string, spanish-string) = {
  if language == "en" {
    english-string
  } else if language == "es" {
    spanish-string
  }
}

#let is-spanish() = {
  if language == "es" {
    true
  } else {
    false
  }
}

#let is-english() = {
  if language == "en" {
    true
  } else {
    false
  }
}
