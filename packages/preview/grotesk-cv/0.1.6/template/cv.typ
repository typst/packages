#import "@preview/grotesk-cv:0.1.6": cv

#let metadata = toml("info.toml")

#let import-sections(
  sections,
) = {
  for section in sections {
    include {
      "content/" + section + ".typ"
    }
  }
}

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
  left-pane: import-sections(left-pane),
  right-pane: import-sections(right-pane),
  left-pane-proportion: 71%,
)

