#import "@preview/phonokit:0.5.4": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

#vowels(
  "english",
  arrows: (
    ("a", "U"),
    ("a", "I"),
    ("e", "I"),
    ("O", "I"),
    ("o", "U"),
  ),
  arrow-color: blue.lighten(60%),
  curved: true,
  highlight: ("a", "e", "o", "O"),
  highlight-color: blue.lighten(80%),
)
