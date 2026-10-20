// logos.typ
//
// Default for university-logo: auto. The logo ships with the package, see
// the Logos section of README.md for its terms. Users replace it by
// passing their own image(...) of the official PDF.

// Official University of Stuttgart logo, as on the corporate design
// page, with the editing data stripped. Cropped by university-block.typ.
#let default-university-logo(language) = {
  if language == "german" {
    image("../assets/unistuttgart_logo_deutsch.pdf")
  } else {
    image("../assets/unistuttgart_logo_englisch.pdf")
  }
}
