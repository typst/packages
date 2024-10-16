#import "@preview/grotesk-cv:1.0.1": cv

#let metadata = toml("info.toml")
#let photo = image("./img/" + metadata.personal.profile_image)

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
  photo: photo,
  use-photo: true,
  left-pane: import-sections(left-pane),
  right-pane: import-sections(right-pane),
  left-pane-proportion: eval(metadata.layout.left_pane_width),
)

