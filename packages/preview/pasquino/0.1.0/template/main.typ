#import "@preview/pasquino:0.1.0": poster, section

#show: poster.with(
  title: [Rule-based system and forward chaining for\ investigating incidents on Linux servers],
  authors: ("Kevin T. Oloughlin", "Paula R. Hoff"),
  info: (
    [Course: Expert Systems 2026],
    [Prof. Leo T. Garcia],
  ),
  theme: "blue",
)

// Left column content
#section(title: "Introduction")[
  #lorem(50)

  #lorem(90)
]

#section(title: "Objectives")[
  + #lorem(30)
  + #lorem(30)
  + #lorem(30)
]

#section(title: "Methodology")[
  #figure(
    image("images/method.png", width: 90%),
    caption: [Forward chaining visualization],
  )
  #lorem(80)
]

#section(title: "References")[
  #set text(size: 26pt)
  - Giarratano, J. C., & Riley, G. D. (2005). Expert Systems: Principles and Programming.
  - Nemeth, E., et al. (2017). UNIX and Linux System Administration Handbook.
  - Russell, S. J., & Norvig, P. (2021). Artificial Intelligence: A Modern Approach.
  - Buchanan, B. G., & Shortliffe, E. H. (1984). Rule-Based Expert Systems.
]

#colbreak()

// Right Column Content
#section(title: "Design")[
  #figure(
    image("images/architecture.png", width: 100%),
    caption: [Architecture of the forward chaining system],
  )
]

#section(title: "Results")[
  #figure(
    image("images/result.png"),
    caption: [WebApp for the inference system],
  )
]

#section(title: "Conclusions")[
  - #lorem(25)
  - #lorem(25)
  - #lorem(25)
  - #lorem(25)
]
