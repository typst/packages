#import "@preview/calligraphics:1.0.0": *
#import "@preview/metalogo:1.2.0": LaTeX
#resume(
  author: (
    firstname: "Jane",
    lastname: "Doe",
    email: "contact@example.org",
    phone: "+336 66 66 66 66",
    address: "City, Country",
    github: "Github",
    positions: ("Job researcher",),
  ),
)[
  = Skills

  #aside-skill-item(
    "Languages",
    (strong[English], "French", "German"),
  )

  #aside-skill-item( "Programming languages", ("C", "C++", "Rust"))
  #aside-skill-item( "Tools", ("Git", "JJ", LaTeX, "Typst", "RenderDoc", "Linux"))

  = Internship
  #resume-entry(
    title: "Old internship",
    location: "Been there",
    date: "2021",
    description: "Done that",
  )

  = Hobbies
  - Talking to the wind

  - Looking inside
][
  = Experiences
  #resume-entry(
    title: "Third work experience",
    location: "Other Place",
    date: "2023 - 2026",
    description: "Building more stuff", )
  #resume-item[
    - #lorem(7)
    - #lorem(9)
    - #lorem(13)
  ]


  #resume-entry(
    title: "Second work experience",
    location: "Other Place",
    date: "2022 - 2023",
    description: "Building stuff", )
  #resume-item[
    - #lorem(15)
    - #lorem(10)
  ]

  #resume-entry(
    title: "First work experience",
    location: "Place",
    date: "2020 - 2022",
    description: "Researching stuff", )
  #resume-item[
    #lorem(20)
  ]

  = Education
  #resume-entry(
    title: "Diploma",
    location: "Some university",
    date: "2017 - 2020",
    description: "Studying more advanced stuff", )
  #resume-item[
    - Math stuff
    - Computer stuff
    - Physics stuff
    - Humanities stuff
  ]

  #resume-entry(title: "Older diploma", location: "Location", date: "2016 - 2017", description: "Studying stuff")
  #resume-item[
    #lorem(10)
  ]

  = Projects

  #resume-entry(
    title: "Project",
    date: "",
    location: github-link("project-page"),
    description: "Maintainer of great project",
  )
  #resume-item[
    #lorem(30)
  ]

  #resume-entry(
    title: "Contribution to other great project",
    date: "",
    location: github-link("pull-request"),
    description: "Added stuff",
  )
  #resume-item[
    #lorem(20)
  ]

  #resume-entry(
    title: "Old Project",
    date: "",
    location: github-link("project-page"),
    description: "Maintainer of old project",
  )
  #resume-item[
    #lorem(20)
  ]
]
