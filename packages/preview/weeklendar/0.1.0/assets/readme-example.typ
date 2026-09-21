#import "@preview/weeklendar:0.1.0": *

#let events = (
  (
    start: "2026-09-21T08:15", end: "2026-09-21T12",
    summary: "Analysis I", description: [Lecture \ + exercise session],
    fill: green,
    repeat-until: "2026-12-20", repeat-frequency: duration(days: 7),
    repeat-edit: (
      "1": (
        description: [Online lecture \ + exercise session]
      )
    )
  ),
  (
    start: "2026-09-22T13:15", end: "2026-09-22T17",
    summary: "Probability", description: [Lecture \ + exercise session],
    fill: blue.lighten(30%),
    repeat-until: "2026-12-20", repeat-frequency: duration(days: 7),
  ),
  (
    start: "2026-09-23T08:15", end: "2026-09-23T12",
    summary: "Linear algebra", description: [Lecture \ + exercise session],
    fill: teal.lighten(50%),
    repeat-until: "2026-12-20", repeat-frequency: duration(days: 7),
    repeat-edit: ("2": (
      description: [
        Exercise session \
        #box(fill: rgb("#fffb10"), inset: 3pt)[
          #text(red)[Submit sheet]
        ]
      ]
    ))
  ),
  (
    start: "2026-09-24T08:15", end: "2026-09-24T10",
    summary: "Programming", description: "Lecture",
    fill: purple.lighten(30%),
    repeat-until: "2026-12-20", repeat-frequency: duration(days: 7),
    repeat-edit: (
      "1": (
        end: "2026-10-01T12",
        description: "Longer lecture"
      )
    )
  ),
  (
    start: "2026-09-21T13:15", end: "2026-09-21T15",
    summary: "Programming", description: "Project",
    fill: purple.lighten(60%),
    repeat-until: "2026-12-20", repeat-frequency: duration(days: 7),
  ),
  (
    start: "2026-09-25T13:15", end: "2026-09-25T17",
    summary: "Physics", description: [Lecture \ + exercise session],
    fill: rgb("#fffd96"),
    repeat-until: "2026-12-20", repeat-frequency: duration(days: 7),
  ),
  (
    start: "2026-09-21T16:30", end: "2026-09-21T17:15",
    summary: "Dentist",
    fill: red.lighten(30%),
  ),
  (
    start: "2026-10-04T12", end: "2026-10-04T22",
    summary: "Mom's birthday", description: "Bring a cake !",
    fill: rgb("#a3fc8f"),
  ),
  (
    start: "2026-10-10T08", end: "2026-10-11T16",
    summary: "Mountain trip",
    fill: rgb("#fcc48f"),
  ),
)

#weeklendar(
  starting-date: "2026-09-21",
  ending-date: "2026-10-11",
  ..events
)
