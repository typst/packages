#import "../src/element.typ": cv, item, label, progress-bar, section
#import "../src/theme.typ": set-theme

#let theme = (
  color: (
    accent: rgb("#E16B8C"),
    header: (
      accent: rgb("#64363C"),
      body: black,
    ),
  ),
)

#set-theme(theme)

#let main = section("Educational Background")[
  #label("2012, 6 mths")[
    #item("B.S. in Computer Science", caption: "University of Hong Kong")[#lorem(32)]]
]

#let aside = {
  section(
    "Contact",
  )[
    #label("Home")[Hong Kong, China]
    #label("Email")[contact\@me.com]
  ]

  section(
    "Technology Stack",
  )[
    #label("Web")[
      #stack(spacing: 7pt, item(".NET", caption: "Blazor")[#progress-bar(100%)], item("Express + React")[#progress-bar(
          50%,
        )])
    ]
    #label("Desktop")[
      #item("WPF")[#progress-bar(75%)]
    ]
    #label("Other")[
      #item("Gaming")[Unity, Godot]
      #item("Graphics")[Illustrator, Photoshop]
    ]
  ]
}

#cv(
  "Nanami Nakano",
  "developer",
  main,
  aside,
)
