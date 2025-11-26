// Copyright 2024 Thomas Gingele https://github.com/B1TC0R3
// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "@preview/drafting:0.2.2": *

#let note_inset         = 1em
#let note_border_radius = 0.5em

#let note(
  content,
  width: auto,
  stroke: black,
  fill: gray.lighten(80%)
) = {
  inline-note(
    content,
    stroke: stroke,
    fill  : fill,
    rect  : rect.with(
      inset : note_inset,
      radius: note_border_radius,
      width : width
    )
  )
}

#let good-note(
  content,
  width: auto
) = {
  note(
    content,
    width: width,
    stroke: green,
    fill: green.lighten(80%)
  )
}

#let warning-note(
  content,
  width: auto
) = {
  note(
    content,
    width: width,
    stroke: orange,
    fill: orange.lighten(80%)
  )
}

#let error-note(
  content,
  width: auto
) = {
  note(
    content,
    width: width,
    stroke: red,
    fill: red.lighten(60%)
  )
}

#let color-note(
  content,
  border,
  inner,
  width: auto
) = {
  note(
    content,
    width: width,
    stroke: border,
    fill: inner, 
  )
}

#let todo() = {
  warning-note([*TODO*])
}
