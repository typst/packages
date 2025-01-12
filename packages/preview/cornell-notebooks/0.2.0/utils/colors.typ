// Colors from the official palette of the University of Strasbourg
// https://langagevisuel.unistra.fr/index.php?id=396

#let white = rgb("#ffffff")
#let black = rgb("#000000")

#let link-color = rgb(118, 50, 55)

#let grey = (
  "A": rgb("#333332"),
  "B": rgb("#929292"),
  "C": rgb("#CACACA"),
  "D": rgb("#F6F6F6"),
  "E": rgb("#696260"),
)

#let maroon = (
  "A": rgb("#522122"),
  "B": rgb("#96716A"),
  "C": rgb("#CDB6B3"),
  "D": rgb("#F3F0EF"),
  "E": rgb("#B0685F"),
)

#let brown = (
  "A": rgb("#512414"),
  "B": rgb("#AF745B"),
  "C": rgb("#D6BAAB"),
  "D": rgb("#F4EAE7"),
  "E": rgb("#BD6244"),
)

#let orange = (
  "A": rgb("#7D340D"),
  "B": rgb("#E94E1B"),
  "C": rgb("#FAC294"),
  "D": rgb("#FEF0E7"),
  "E": rgb("#FF4600"),
)

#let red = (
  "A": rgb("#8A200D"),
  "B": rgb("#E42313"),
  "C": rgb("#F6AF8F"),
  "D": rgb("#FDEDE8"),
  "E": rgb("#FF2015"),
)

#let pink = (
  "A": rgb("#921428"),
  "B": rgb("#E40136"),
  "C": rgb("#F4A5AA"),
  "D": rgb("#FDEDED"),
  "E": rgb("#FF1D44"),
)

#let purple = (
  "A": rgb("#7E0F44"),
  "B": rgb("#BF1C66"),
  "C": rgb("#F3A3C1"),
  "D": rgb("#FCEAF4"),
  "E": rgb("#FA186E"),
)

#let violet = (
  "A": rgb("#3B2983"),
  "B": rgb("#584495"),
  "C": rgb("#AAA5D2"),
  "D": rgb("#EDE7F4"),
  "E": rgb("#4C2ED6"),
)

#let nblue = (
  "A": rgb("#22398E"),
  "B": rgb("#4458A3"),
  "C": rgb("#95B5E0"),
  "D": rgb("#E7EDF9"),
  "E": rgb("#315CDD"),
)

#let blue = (
  "A": rgb("#003F75"),
  "B": rgb("#0070B9"),
  "C": rgb("#8CD3F6"),
  "D": rgb("#E2F3FC"),
  "E": rgb("#0095FF"),
)

#let cyan = (
  "A": rgb("#004C4C"),
  "B": rgb("#009194"),
  "C": rgb("#85CCD3"),
  "D": rgb("#DCEFF4"),
  "E": rgb("#00C1C1"),
)

#let ngreen = (
  "A": rgb("#00462E"),
  "B": rgb("#008A57"),
  "C": rgb("#73C09B"),
  "D": rgb("#E7F3EC"),
  "E": rgb("#29D49D"),
)

#let green = (
  "A": rgb("#004818"),
  "B": rgb("#009A3A"),
  "C": rgb("#A6D2A7"),
  "D": rgb("#EBF4E9"),
  "E": rgb("#61F275"),
)

#let camo = (
  "A": rgb("#3B471A"),
  "B": rgb("#89A12A"),
  "C": rgb("#D8E08E"),
  "D": rgb("#F0F5E2"),
  "E": rgb("#96D400"),
)

#let yellow = (
  "A": rgb("#E28E00"),
  "B": rgb("#FFCD00"),
  "C": rgb("#FFF594"),
  "D": rgb("#FFFDE8"),
  "E": rgb("#FFF028"),
)

// ----

#let colorthemes = (
  lblue: (blue.E, cyan.E),
  blue: (nblue.E, cyan.E),
  dblue: (nblue.E, blue.E),
  yellow: (yellow.B, yellow.C, black),
  pink: (pink.E, pink.B),
  neon: (violet.E, pink.E),
  mandarine: (orange.E, brown.E),
  hazy: (maroon.E, grey.E),
  smoke: (grey.E, black),
  forest: (green.A, camo.E),
  berry: (pink.A, purple.A),
  ocean: (cyan.A, blue.B, blue.D),
  lavender: (purple.C, violet.C, black),
  moss: (ngreen.C, grey.B, black),
  clay: (brown.B, maroon.C),
  mint: (ngreen.E, cyan.C, black),
  lemon: (yellow.A, camo.E, black),
  wine: (maroon.A, brown.A, maroon.D),
)
