#import "@preview/grotesk-cv:0.1.4": cv

#let metadata = toml("info.toml")


#let left-pane = (
  "profile",
  "experience",
  "education",
)

#let right-pane = (
  "skills",
  "languages",
  "other_experience",
  "references",
)

#show: cv.with(
  metadata,
  use-photo: true,
  left-pane: left-pane,
  right-pane: right-pane,
  left-pane-proportion: 71%,
)

