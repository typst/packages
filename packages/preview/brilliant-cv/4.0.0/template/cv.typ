// Imports
#import "@preview/brilliant-cv:4.0.0": cv

// Each profile lives in its own folder with a self-contained metadata.toml.
// Switch profile at compile time:
//   typst compile cv.typ --input profile=fr
#let profile = sys.inputs.at("profile", default: "en")
#let metadata = toml("profile_" + profile + "/metadata.toml")

#let import-modules(modules) = {
  for module in modules {
    include {
      "profile_" + profile + "/" + module + ".typ"
    }
  }
}

#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
  // To use custom image icons in personal.info.custom-<name> entries,
  // pass them here (keys must match the custom-<name> keys in metadata.toml):
  // custom-icons: (
  //   "custom-cert": image("assets/my-icon.png"),
  // ),
)

// Add, remove, or reorder modules to customize your CV content
#import-modules((
  "education",
  "professional",
  "projects",
  "certificates",
  "publications",
  "skills",
))
