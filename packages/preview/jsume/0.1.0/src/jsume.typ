#import "@preview/zh-format:0.1.0": zh-format
#import "@preview/nerd-icons:0.2.0": change-nerd-font
#import "./components/sections.typ": *

#let jsume(
  paper: "a4",
  numbering: "(1/1)",
  top-margin: 0.3in,
  bottom-margin: 0.3in,
  left-margin: 0.3in,
  right-margin: 0.3in,
  font: "Libertinus Serif",
  nerd-font: "Symbols Nerd Font",
  font-size: 11pt,
  lang: "en-US",
  jsume-data: (),
  doc,
) = {
  let basics = jsume-data.at("basics", default: ())
  let work = jsume-data.at("work", default: ())
  let projects = jsume-data.at("projects", default: ())
  let publications = jsume-data.at("publications", default: ())
  let education = jsume-data.at("education", default: ())
  let certificates = jsume-data.at("certificates", default: ())
  let awards = jsume-data.at("awards", default: ())
  let skills = jsume-data.at("skills", default: ())
  let languages = jsume-data.at("languages", default: ())

  let title = basics.at("name", default: "Resume")
  let author = basics.at("name", default: "")
  let label = basics.at("label", default: "")

  show: zh-format

  change-nerd-font(nerd-font)

  set document(
    title: title,
    author: author,
    keywords: "cv",
    date: none,
  )

  set page(
    paper: paper,
    numbering: numbering,
    margin: (
      top: top-margin,
      bottom: bottom-margin,
      left: left-margin,
      right: right-margin,
    ),
  )

  set par(
    leading: 0.7em,
    spacing: 0.7em,
  )

  set text(
    font: font,
    size: font-size,
    lang: lang.split("-").at(0, default: "en"),
    ligatures: false,
  )

  show heading.where(
    level: 1,
  ): it => block(width: 100%)[
    #set text(font-size + 4pt, weight: "extrabold")
    #smallcaps(it.body)
    #v(-0.8em)
    #line(length: 100%, stroke: stroke(thickness: 0.15em))
  ]

  // header
  header-section(
    title: title,
    label: label,
    base-font-size: font-size,
  )

  // personal info
  let location = basics.at("location", default: "")
  let phone = basics.at("phone", default: "")
  let email = basics.at("email", default: "")
  let url = basics.at("url", default: "")
  personal-info-section(
    location: location-to-str(location),
    phone: phone,
    email: email,
    url: url,
  )

  // work
  if work.len() > 0 {
    work-section(data: work, lang: lang)
  }

  // education
  if education.len() > 0 {
    education-section(data: education, lang: lang)
  }

  // projects
  if projects.len() > 0 {
    projects-section(data: projects, lang: lang)
  }

  // publications
  if publications.len() > 0 {
    publications-section(data: publications, lang: lang)
  }

  // certificates
  if certificates.len() > 0 {
    certificates-section(data: certificates, lang: lang)
  }

  // awards
  if awards.len() > 0 {
    awards-section(data: awards, lang: lang)
  }

  // skills
  if skills.len() > 0 {
    skills-section(data: skills, lang: lang)
  }

  // Languages
  if languages.len() > 0 {
    languages-section(data: languages, lang: lang)
  }

  doc
}
