// mrbogo-cv - CV Template
// Unified entry point with language parameterization
// Usage: typst compile --input lang=en main.typ output.pdf

#let lang = sys.inputs.at("lang", default: "en")

#import "@preview/mrbogo-cv:1.0.5": *

// Dynamic imports based on language
// Sidebar labels (title-about, title-contact, title-skills) and skill block labels
#import "content/" + lang + "/labels.typ": *
// Profile with introduction section title
#import "content/" + lang + "/profile.typ": author, about-me, title-intro, intro-text
#import "content/" + lang + "/skills.typ": *
// Content files with co-located section titles (aliased to title-*)
#import "content/" + lang + "/experience.typ": title as title-experience, content as experiences
#import "content/" + lang + "/projects.typ": title as title-projects, content as projects
#import "content/" + lang + "/education.typ": title as title-education, content as education
#import "content/" + lang + "/certifications.typ": title as title-certifications, content as certifications
#import "content/" + lang + "/publications.typ": title as title-publications, content as publications

#set text(lang: lang)
#show: heading-style

#show: cv.with(
  author: author,
  accent-color: color-primary,
  profile-picture: image("assets/profile.png"),
  header-color: color-dark,
)

#side[
  = #title-about

  #about-me

  = #title-contact
  #contact-info()

  = #title-skills

  #skills-technical
  #skills-soft
  #skills-languages-spoken

  #v(1fr)
  #social-links()
]

= #title-intro

#introduction[#intro-text]

= #title-experience

#experiences

= #title-projects

#projects

= #title-education

#education

= #title-certifications

#certifications

= #title-publications

#publications
