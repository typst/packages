// Imports
#import "@preview/brilliant-cv:3.1.1": cv
#let metadata = toml("./metadata.toml")
#let cv-language = sys.inputs.at("language", default: none)
#let metadata = if cv-language != none {
  metadata + (language: cv-language)
} else {
  metadata
}

#let import-modules(modules, lang: metadata.language) = {
  for module in modules {
    include {
      "modules_" + lang + "/" + module + ".typ"
    }
  }
}

#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
)

#import-modules((
  "education",
  "professional",
  "projects",
  "certificates",
  "publications",
  "skills",
))
