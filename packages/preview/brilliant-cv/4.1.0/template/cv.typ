// Required fonts: Roboto, Source Sans 3 (or Source Sans Pro), and the
// Font Awesome 7 Free desktop OTFs (Regular, Solid, Brands) — get them from
// https://fonts.google.com/specimen/Roboto,
// https://fonts.google.com/specimen/Source+Sans+3, and
// https://fontawesome.com/download. Install locally for desktop Typst.
// On typst.app, the web app does not bundle Font Awesome — upload the three
// .otf files to your project instead, or contact icons render as boxes.
// See https://yunanwg.github.io/brilliant-CV/ (Troubleshooting) for details.

// Imports
#import "@preview/brilliant-cv:4.1.0": cv, h-bar

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
  // Profile photos are personal and sensitive — avoid committing real ones to public git repos.
  profile-photo: image("assets/avatar.png"),
  // Replace the generated contact row with arbitrary Typst content:
  // header-info: [
  //   #metadata.personal.info.email
  //   #h-bar()
  //   #text(fill: black)[Berlin, Germany]
  // ],
  // Use `header-info: none` to remove the contact row entirely.
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
