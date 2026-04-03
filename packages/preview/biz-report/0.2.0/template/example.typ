#import "@preview/biz-report:0.2.0": authorwrap, dropcappara, infobox, report  

#show: report.with(
  title: "Business Report",
  publishdate: "November 2025",
  mylogo: image("logo.png", width: 20%),
  myfeatureimage: image("techimage.png", height: 6cm),
  myvalues: "VALUE1 | VALUE2 | VALUE3 | VALUE4",
  mycolor: rgb(166, 0, 120),
  myfont: "IBM Plex Sans"
)

= Welcome

#dropcappara(firstline: "Welcome to this report.")[#lorem(50)]

#authorwrap(
  authorimage: image("author.png", height: 3cm), 
  authorcaption: "The Author, CXO")[#lorem(75)] 

#lorem(100)

=== Document Control

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    table.header(
      [Version], [Date], [Authors], [Changes]
    ),
    "0.2",
    "November 2025",
    "Reviewers",
    "Formal review",
    "0.1",
    "October 2025",
    "Authors",
    "Initial draft",
  )
]

= First main chapter 

#lorem(100)

#infobox(icon: "warning")[Swimming when there is a thunderstorm is dangerous.]

#lorem(100)

#align(center)[
  #table(
    columns: (auto, auto),
    table.header(
      [Name], [Purpose],
    ),
    "Cirrus",
    "Thin, wispy high-altitude clouds made of ice crystals. Indicate fair weather but can signal an approaching warm front or storm system.",
    "Stratus",
    "Low, uniform gray clouds resembling fog that doesn't reach the ground. Often produce mist, drizzle, or light rain.",
    "Cumulus",
    "Puffy, cotton-like clouds with flat bases. Typically bring fair weather but can develop into larger storm clouds.",
    "Cumulonimbus",
    "Towering, anvil-shaped clouds producing thunderstorms, heavy rain, hail, and sometimes tornadoes. Formed by powerful vertical air currents."
  )
]

== Sub-heading with an image

#figure(
  image("techimage.png", width:50%),
  caption: ["Technology Image"],
)

== Sub-heading

#lorem(50)

#lorem(50)

== Sub-heading

#lorem(50)

#lorem(50)

= Chapter of infoboxes

== Subhead

#lorem(50)

== Subhead

#infobox(icon: "laptop")[
    *List of problems:*

    - Problem 1.
    - Problem 2.
    - Problem 3.
]

#infobox(icon: "app-store")[
    *Heading Text*

    #lorem(30)
]

#infobox(icon: "shield-virus")[
    *Heading Text*

    #lorem(30)
]


#infobox(icon: "database")[
    *Heading Text*

    #lorem(30)
]
