#let meta = toml("./info.toml")

// #import meta.import.path: cv
#import "@preview/grotesk-cv:1.0.4": cv
#let photo = image("./img/" + meta.personal.profile_image)

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
  meta,
  photo: photo,
  use-photo: true,
  left-pane: import-sections(left-pane),
  right-pane: import-sections(right-pane),
  left-pane-proportion: eval(meta.layout.left_pane_width),
)

