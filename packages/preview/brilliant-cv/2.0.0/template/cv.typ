// Imports
#import "@preview/brilliant-cv:2.0.0": cv
#let metadata = toml("./metadata.toml")
#let importModules(modules, lang: metadata.language) = {
  for module in modules {
    include {
      "modules_" + lang + "/" + module + ".typ"
    }
  }
}


#show: cv.with(metadata)
#importModules((
  "education",
  "professional",
  "projects",
  "certificates",
  "publications",
  "skills",
))
