// logos.typ
//
// Defaults for university-logo: auto and chair-logo: auto. Both logos
// ship with the package, see the Logos section of README.md for their
// terms. Users replace them by passing their own image(...).

// Official University of Stuttgart logo, as on the corporate design
// page, with the editing data stripped. Cropped by university-block.typ.
#let default-university-logo(language) = {
  if language == "german" {
    image("../assets/unistuttgart_logo_deutsch.pdf")
  } else {
    image("../assets/unistuttgart_logo_englisch.pdf")
  }
}

#let default-chair-logo() = image("../assets/ls3_logo.png", width: 25mm)
