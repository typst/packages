#import "@preview/showybox:2.0.4": showybox
#import "@preview/heroic:0.1.2": *

#let custom-box(
  box-icon,
  box-color,
  box-title,
  ..box-content,
) = {
  showybox(
    frame: (
      border-color: box-color.darken(50%),
      title-color: box-color.lighten(30%),
      body-color: box-color.lighten(80%),
    ),
    title-style: (
      color: black,
    ),
    title: [
      #grid(
        columns: 2 * (auto,),
        gutter: 10pt,
        [
          #if box-icon != none {
            text(size: 25pt)[#box-icon]
          }
        ],
        align(horizon)[
          #text(size: 14pt, weight: "bold")[#box-title]
        ]
      )
    ],
    ..box-content,
  )
}


#let info-box(
  ..box-content,
) = {
  custom-box(
    icon("exclamation-circle", solid: false, color: blue.darken(30%)),
    blue,
    "Info",
    ..box-content,
  )
}


#let warning-box(
  ..box-content,
  lang: "de",
) = {
  custom-box(
    icon("exclamation-triangle", solid: false, color: orange.darken(30%)),
    orange,
    [
      #if lang == "de" [
        Achtung
      ] else [
       Warning
      ]
    ],
    ..box-content,
  )
}


#let note-box(
  ..box-content,
  lang: "de",
) = {
  custom-box(
    icon("clipboard", solid: false, color: yellow.darken(50%)),
    yellow.darken(10%),
    [
      #if lang == "de" [
        Hinweis
      ] else [
        Note
      ]
     ],
    ..box-content,
  )
}


#let tip-box(
  ..box-content,
    lang: "de",
) = {
  custom-box(
    icon("light-bulb", solid: false, color: green.darken(30%)),
    green,
    [
      #if lang == "de" [
        Tipp
      ] else [
        Tip
      ]
    ],
    ..box-content,
  )
}


#let important-box(
  ..box-content,
    lang: "de",
) = {
  custom-box(
    icon("megaphone", solid: false, color: red.darken(30%)),
    red,
    [
      #if lang == "de" [
        Wichtig
      ] else [
        Important
      ]
    ],
    ..box-content,
  )
}

