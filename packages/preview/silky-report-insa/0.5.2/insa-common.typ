#let insa-heading-fonts = ("League Spartan", "Arial", "Liberation Sans")
#let insa-body-fonts = ("Source Serif", "Source Serif 4", "Georgia")
#let insa-colors = (
  primary: rgb("#e42618"),
  secondary: rgb("#f69f1d"),
  tertiary: rgb("#f5adaa"),
)

/// Checks that the school ID is supported and returns its full name.
///
/// - id (str): the short name of the school (rennes, hdf or cvl)
/// -> str
#let insa-school-name(id) = {
  let supported-insas = (
    "rennes": "Rennes",
    "hdf": "Hauts-de-France",
    "cvl": "Centre Val de Loire"
  )
  assert(supported-insas.keys().contains(id), message: "Only INSAs " + supported-insas.keys().join(", ") + " are supported for now.")
  return supported-insas.at(id)
}
