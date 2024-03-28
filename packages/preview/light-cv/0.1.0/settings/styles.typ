// General Settings
#let pageStyle = (
  paper: "a4",
  margin: (
    left: 1cm,
    right: 1cm,
    top: 0.8cm,
    bottom: 0.4cm,
  )
)
#let colors = (
  accent: rgb("#007fad")
)
#let bodyStyle = (
  fonts: ("Source Sans Pro", "Font Awesome 6 Brands", "Font Awesome 6 Free"),
  size: 10pt,
  weight: "regular"
)
#let listStyle = (
  indent: 1em
)


// Header
#let headerStyle = (
  fonts: ("New Computer Modern Sans"),
  table: (
    columns: (5fr, 1fr),
    columnGutter: 30pt
  ),
  fullName: (
    size: 36pt,
    weight: "bold"
  ),
  jobTitle: (
    size: 18pt,
    weight: "bold"
  ),
  profilePhoto: (
    width: 100pt, 
    height: 100pt, 
    stroke: none, 
    radius: 9999pt,
    imageHeight: 10.0cm
  ),
  margins: (
    BetweenInfoAndSocials: 2.5mm,
    bottom: 3pt
  ),
  socials: (
    columnGutter: 10pt
  )
)

// Section
#let sectionStyle = (
  title: (
    size: 16pt,
    weight: "bold",
    fontColor: black 
  ),
  margins: (
    top: 3pt,
    RightToHLine: 2pt,
  )
)

// Entry
#let entryStyle = (
  table: (
    columns: (5%, 1fr)
  ),
  title: (
    size: 10pt,
    weight: "bold",
    color: black
  ),
  companyOrUniversity: (
    size: 10pt,
    weight: "bold",
    color: colors.accent
  ),
  timeAndLocation: (
    size: 10pt,
    weight: "regular",
    color: black
  ),
  margins: (
    top: 3pt,
    betweenLogoAndTitle: 8pt,
    betweenTitleAndSubtitle: 3pt,
    betweenTimeAndLocation: 10pt,
    betweenIconAndText: 5pt
  )
)

// Skills
#let skillsStyle = (
  columns: (18%, 1fr),
  stroke: 1pt + colors.accent,
  radius: 20%,
  margins: (
    betweenSkillTags: 6pt,
    betweenCategories: -6pt
  )
)