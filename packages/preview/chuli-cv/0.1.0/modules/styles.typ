#let colors = (
  accent: rgb("#007fad"),
  inactive: luma(170),
  gradient-init: rgb("#001f3f"),
  gradient-end: rgb("#7fdbff")
)

#let global-text-setting = (
  weight: "regular",
  size: 10pt,
)


#let vline() = [
  #h(5pt)
]

#let hline() = [
  #box(width: 1fr, line(stroke: 0.9pt, length: 100%))
]

#let dashed-line() = [
  table.hline(
    stroke: (
      paint: colors.inactive, 
      thickness: 1pt, 
      dash: "dashed"
    )
  )
]

#let letter-signature-style = (
  position: right,
  dx: -65%,
  dy: -4%,
)

#let letter-footer-style = (
  position: bottom,
  table: (
    columns: (1fr, auto),
    inset: 0pt,
  )
)

#let page-style = (
  paper: "a4",
  margin: (
    left: 1cm,
    right: 1cm,
    top: 0.8cm,
    bottom: 0.4cm,
  ),
  text: (
    align: left,
    weight: "regular",
    size: global-text-setting.size,
  )
)

#let body-style = (
  fonts: ("Source Sans Pro", "Font Awesome 6 Brands", "Font Awesome 6 Free"),
  size: global-text-setting.size,
  weight: "regular",
  fill: black,
)

#let list-style = (
  indent: 1em
)

#let header-style = (
  fonts: ("Source Sans Pro"),
  table: (
    inset: 0pt,
    columns: (5fr, 1fr),
    column-gutter: 30pt
  ),
  full-name: (
    size: 36pt,
    weight: "bold"
  ),
  job-title: (
    size: 18pt,
    weight: "bold"
  ),
  profile-photo: (
    width: 100pt, 
    height: 100pt, 
    stroke: none, 
    radius: 9999pt,
    image-height: 10.0cm
  ),
  margins: (
    between-info-and-socials: 2.5mm,
    bottom: 3pt
  ),
  socials: (
    column-gutter: 10pt
  )
)

#let section-style = (
  title: (
    size: 16pt,
    weight: "bold",
    font-color: black 
  ),
  margins: (
    top: 3pt,
    right-to-hline: 2pt,
  )
)

#let entry-style = (
  table: (
    columns: (5%, 1fr),
    inset: 0pt,
    align: horizon,
  ),
  title: (
    size: global-text-setting.size,
    weight: "bold",
    color: black
  ),
  company-or-university: (
    size: global-text-setting.size,
    weight: "bold",
    color: colors.accent
  ),
  time-and-location: (
    size: global-text-setting.size,
    weight: "regular",
    color: black
  ),
  margins: (
    top: 3pt,
    between-logo-and-title: 8pt,
    between-title-and-subtitle: 3pt,
    between-time-and-location: 10pt,
    between-icon-and-text: 5pt
  )
)

// Skills
#let skills-style = (
  columns: (18%, 1fr),
  stroke: 1pt + colors.accent,
  radius: 20%,
  margins: (
    between-skill-tags: 6pt,
    between-categories: -4pt
  )
)

// language
#let language-style = (
  columns: (18%, 1fr),
  stroke: 1pt + colors.accent,
  radius: 5pt,
  row-gutter: 2pt,
  align: (horizon, right),
  margins: (
    top: 3pt,
    between-tags: 3pt,
    between-categories: -6pt,
    between-icon-and-text: 5pt
  )   
)

#let freetime-style = (
  columns: (18%, 1fr),
  align: (horizon, right),
  column-gutter: 1pt,
)

// Education with table style
#let education-entry-style = (
  row-gutter: 4pt,
  column-gutter: 4pt,
  margins: (
    top: 3pt,
    between-logo-and-text: 5pt,
  ),

)

//Styles

#let footer-style(str) = {
  text(
    size: 8pt,
    fill: colors.inactive,
    smallcaps(str)
  )
}

#let accent-subtopic-style(str) = {
  text(
    size: body-style.size, 
    weight: "bold", 
    fill: colors.accent,
    str, 
  )
}

#let regular-text-style(str) = {
  text(
    font: body-style.fonts,
    weight: body-style.weight,
    size: body-style.size,
    fill: body-style.fill,
    str,
  )
}

#let black-topic-style(str) = {
  text(
    size: body-style.size, 
    weight: "bold", 
    fill: black,
    str, 
  )
}

#let inactive-ligth-style(str) = {
  text(
    font: body-style.fonts,
    size: body-style.size, 
    fill: colors.inactive, 
    weight: "light",
    str, 
  )
}

#let italic-text-style(str) = {
  text(
    font: body-style.fonts,
    weight: body-style.weight,
    size: body-style.size,
    fill: body-style.fill,
    style: "italic",
    str
  )
}

#let underline-accent-style(str) = {
  text(
    font: body-style.fonts,
    size: body-style.size, 
    weight: "bold", 
    fill: colors.accent,
    underline(str)
  )
}