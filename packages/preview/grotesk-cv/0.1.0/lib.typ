#import "metadata.typ": *
#import "@preview/fontawesome:0.2.1": *

#let textFont = "Hanken Grotesk"
#let textSize = 9pt
#let headerName = [#firstName #lastName]
#let title = [#subTitle]


#let textColors = (
  lightGray: rgb("#ededef"),
  mediumGray: rgb("#78787e"),
  darkGray: rgb("#3c3c42"),
)

#let accentColor = rgb("#d4d2cc")

#let importSection(file) = {
  include {
    "content/sections/" + file + ".typ"
  }
}


#let layout(doc) = {
  set text(
    fill: textColors.darkGray,
    font: "Hanken Grotesk",
    size: textSize,
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

#let sectionTitleStyle(str) = {
  text(
    font: "Hanken Grotesk",
    size: 12pt,
    weight: "bold",
    fill: textColors.darkGray,
    str,
  )
}

#let nameBlock() = {
  text(
    font: "Hanken Grotesk",
    fill: textColors.darkGray,
    size: 30pt,
    weight: "extrabold",
    headerName,
  )
}

#let titleBlock() = {
  text(
    font: "Hanken Grotesk",
    size: 15pt,
    style: "italic",
    fill: textColors.darkGray,
    title,
  )
}

#let infoBlockStyle(icon, txt) = {
  text(
    font: "Hanken Grotesk",
    size: 10pt,
    fill: textColors.mediumGray,
    weight: "medium",
    fa-icon(icon) + h(5pt) + txt,
  )
}

#let infoBlock() = {
  table(
    columns: 1fr,
    inset: -1pt,
    stroke: none,
    row-gutter: 3mm,
    [#infoBlockStyle("location-dot", info.address) #h(2pt) #infoBlockStyle(
        "phone",
        info.telephone,
      ) #h(2pt) #infoBlockStyle("envelope", info.email) #h(2pt) #infoBlockStyle(
        "linkedin",
        info.linkedin,
      ) #h(2pt) #infoBlockStyle("github", info.github)],
  )
}

#let headerTable() = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 4mm,
    [#nameBlock()],
    [#titleBlock()],
    [#infoBlock()],
  )
}

#let makeHeaderPhoto(profilePhoto) = {
  if profilePhoto != false {
    box(
      clip: true,
      radius: 50%,
      image(profileImage),
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

#let cvHeader(leftComp, rightComp, cols, align) = {
  table(
    columns: cols,
    inset: 0pt,
    stroke: none,
    column-gutter: 10pt,
    align: horizon,
    {
      leftComp
    },
    {
      rightComp
    }
  )
}

#let createHeader(
  usePhoto: false,
) = {
  cvHeader(
    headerTable(),
    makeHeaderPhoto(usePhoto),
    (74%, 20%),
    left,
  )
}

#let cvSection(title) = {
  sectionTitleStyle(title)
  h(4pt)
}

#let dateStyle(date) = (
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

#let degreeStyle(degree) = (
  text(
    size: 10pt,
    weight: "bold",
    degree,
  )
)

#let institutionStyle(institution) = (
  table.cell(
    text(
      size: 9pt,
      style: "italic",
      weight: "medium",
      institution,
    ),
  )
)

#let locationStyle(location) = (
  table.cell(
    text(
      style: "italic",
      weight: "medium",
      location,
    ),
  )
)

#let tagStyle(str) = {
  align(
    right,
    text(
      weight: "regular",
      str,
    ),
  )
}

#let tagListStyle(tags) = {
  for tag in tags {
    box(
      inset: (x: 0.4em),
      outset: (y: 0.3em),
      fill: accentColor,
      radius: 3pt,
      tagStyle(tag),
    )
    h(5pt)
  }
}

#let profileEntry(str) = {
  text(
    font: "Hanken Grotesk",
    size: textSize,
    weight: "medium",
    fill: textColors.darkGray,
    str,
  )
}

#let referenceEntry(
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
    [#degreeStyle(name)],
    [#dateStyle(company)],
    table.cell(colspan: 2)[#institutionStyle(telephone), #locationStyle(email)],
  )
  v(2pt)
}

#let educationEntry(
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
    [#degreeStyle(degree)], [#dateStyle(date)],
    [#institutionStyle(institution), #locationStyle(location)],
  )
  v(2pt)
}

#let experienceEntry(
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
    [#degreeStyle(title)] ,
    [#dateStyle(date)],
    table.cell(colspan: 2)[#institutionStyle(company), #locationStyle(location)],
  )
  v(5pt)
}

#let skillStyle(skill) = {
  text(
    weight: "bold",
    skill,
  )
}

#let skillTag(skill) = {
  box(
    inset: (x: 0.3em),
    outset: (y: 0.2em),
    fill: accentColor,
    radius: 3pt,
    skillStyle(skill),
  )
}

#let skillEntry(
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
      [#skillTag(sk) #h(4pt)]
    },
  )
}


#let languageEntry(
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

#let recipientStyle(str) = {
  text(
    style: "italic",
    str,
  )
}

#let recipientEntry(
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
    recipientStyle(name),
    recipientStyle(title),
    recipientStyle(company),
    recipientStyle(address),
  )
}

#let getHeaderByLanguage(englishString, spanishString) = {
  if language == "en" {
    englishString
  } else if language == "es" {
    spanishString
  }
}

#let isSpanish() = {
  if language == "es" {
    true
  } else {
    false
  }
}

#let isEnglish() = {
  if language == "en" {
    true
  } else {
    false
  }
}
