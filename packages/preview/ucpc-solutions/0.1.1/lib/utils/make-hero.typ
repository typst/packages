#import "/lib/colors.typ": color

#let __ucpc_build_hero_subtitle(
  authors: (),
  datetime: none,
) = [
  #text(size: 2em)[
    #if type(authors) == array [
      #authors.map(each => each).join(", ")
    ] else if type(authors) == str [
      #authors
    ]
  ]

  \
  #if datetime != none [#datetime]
]

#let make-hero(
  title: none,
  subtitle: none,
  fgcolor: white,
  bgcolor: color.bluegray.at(2),
  height: 65%,
  authors: (),
  datetime: none,
) = {
  if (title == none) {
    panic("`title` field is required")
  }

  // Upper
  rect(
    width: 100%,
    height: height,
    fill: bgcolor,
    outset: 0%,
    inset: (left: 5em, y: 3em),
  )[
    #align(horizon)[
      #text(fill: fgcolor)[
        = #text(
          size: 40pt,
          weight: "bold",
        )[#title] \ 

        #text(size: 22pt, weight: "medium")[#subtitle]
      ]
    ]
  ]
  align(center + horizon)[
    #text(fill: bgcolor)[
      #__ucpc_build_hero_subtitle(authors: authors, datetime: datetime)
    ]
  ]
}
