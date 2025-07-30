#let configuration = yaml("configuration.yaml")
#import "@preview/swe-cv:1.0.0": *
// Page settings
#set page(margin: (left: 1.5cm, right: 1.5cm,top: 2cm, bottom: 2cm))
#set text(size: 9pt)

// Main header
#grid(
  columns: (1fr, 1fr, 1fr),
  align(left)[
    #link(configuration.header.email) \
    #configuration.header.phone \
  ],
  align(center)[
    #text(weight: "semibold",size: 2em)[#configuration.header.name] \
    #link(configuration.header.website)[#configuration.header.websiteDisplayName]
  ],
  align(right)[
    #configuration.header.github \
    #configuration.header.linkedin \
  ]
)


// Education
#section([Education])
#for ed in configuration.education [
  #exp-header((left: ed.location, center: ed.name, right: ed.date))
  - #ed.degree
]

// spacer
#block(below: 1em)

// Work experience
#section([Employment])
#for exp in configuration.employment [
  #exp-header((left: exp.location, center: exp.company, right: exp.date))
  #for responsibility in exp.responsibilities [
    - #responsibility
  ]
]

// spacer
#block(below: 1em)

// Projects
#section([Projects])
#for project in configuration.projects [
  #project-header((title: project.title, website: project.website))
  #for contribution in project.contributions [
    - #contribution
  ]
]

// spacer
#block(below: 1em)

// Technical skills
#section([Technical Skills])
- Languages: #for skill in configuration.skills.languages [
  #skill,
]
- Frameworks and libraries: #for skill in configuration.skills.frameworks [
  #skill,
]
- Tools: #for skill in configuration.skills.tools [
  #skill,
]

