#let cvline() = {v(-3pt); line(length: 100%); v(-2pt)}

#let conf(body) = {
  set par(justify: true,  leading: 0.6em, linebreaks: "optimized")
  set block(below: 0.8em)
  set list(tight: true, spacing: auto)
  set list(marker: [•])
  show heading.where(level: 1): set text(fill: blue,font: "Noto Sans",weight: "bold")
  show heading.where(level: 2): set text(fill: blue,font: "Noto Sans",weight: "bold")
  show heading.where(level: 3): set text(fill: blue,font: "Noto Sans",weight: "bold" )

  body
}

// --- Component Functions ---

#let personal-info(data) = [
  #align(center)[
    = #data.name
    #data.email |
    #link("https://linkedin.com/in/" + data.linkedinUsername)[linkedin.com/in/#data.linkedinUsername] |
    #data.phone | #data.location
  ]
]

#let profile-summary(data) = [
  == PROFILE SUMMARY
  #cvline()
  *#data.mainDescription*
  #{
    for achievement in data.achievements {
      [- #achievement]
    }
  }
]

#let areas-of-expertise(data) = [
  == AREAS OF EXPERTISE
  #cvline()
  #columns(3)[
    #align(center)[
      #{
        for (i, skill) in data.column1.enumerate() {
          [#skill]
          if i < data.column1.len() - 1 {
            linebreak()
          }
        }
      }
    ]
    #colbreak()
    #align(center)[
      #{
        for (i, skill) in data.column2.enumerate() {
          [#skill]
          if i < data.column2.len() - 1 {
            linebreak()
          }
        }
      }
    ]
    #colbreak()
    #align(center)[
      #{
        for (i, skill) in data.column3.enumerate() {
          [#skill]
          if i < data.column3.len() - 1 {
            linebreak()
          }
        }
      }
    ]
  ]
]

#let work-experience(data) = [
  == WORK EXPERIENCE
  #cvline()
  #{
    for job in data {
      [*#job.company*#h(1fr) #job.dateRange \ ]
      
      for position in job.positions {
        [*#position.title*]
      if "dates" in position and position.dates != "" {
          [_ (#position.dates) _]
        }
        [\ ]
        
        for responsibility in position.responsibilities {
          [- #responsibility \ ]
        }
      }
    }
  }
]

#let education(data) = [
  == EDUCATION
  #cvline()
  #{
    for edu in data {
      [*#edu.institution* #h(1fr) #edu.dateRange \
       #edu.degree \ ]

    }
  }
]