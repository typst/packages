#let default-person = (
  name: "",
  pronouns: "",
  location: "",
  phone: "",
  email: "",
  email-text: "",
  github: "",
  github-text: "",
  linkedin: "",
  linkedin-text: "",
  personal-site: "",
  personal-site-text: "",
)

#let default-placement = (
  name: left,
  contact: left,
)

#let default-page = (
  font: "New Computer Modern",
  font-size: 10pt,
  name-size: 20pt,
  accent-color: "#000000",
  paper: "us-letter",
  margin: 0.5in,
  lang: "en",
)

#let default-spacing = (
  line-spacing: 0.5em,
  block-spacing: 0.85em,
  item-spacing: 0.75em,
  after-header: 0.25em,
  section-rule: 0.5pt,
)

#let spacing-state = state("exp-resume-spacing", default-spacing)
