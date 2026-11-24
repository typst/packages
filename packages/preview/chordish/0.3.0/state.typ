#let default-settings = (
  chords: "inline",
  instrument: "guitar",
  autochord: true,
  diagrams: true,
  simplify-slash: none,
)

#let chordish-state = state("chordish", (
  transpose: 0,
  custom: (:),
  book-settings: default-settings,
  ..default-settings,
))
