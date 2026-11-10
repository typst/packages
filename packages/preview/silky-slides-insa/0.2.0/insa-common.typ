#let insa-heading-fonts = ("League Spartan", "Arial", "Liberation Sans")
#let insa-body-fonts = ("Source Serif", "Source Serif 4", "Georgia")
#let insa-colors = (
  primary: rgb("#e42618"),
  secondary: rgb("#f69f1d"),
  tertiary: rgb("#f5adaa"),
)

#let supported-insas = (
  "rennes": "Rennes",
  "hdf": "Hauts-de-France",
  "cvl": "Centre Val de Loire",
)

#let assert-insa-id(id) = {
  assert(
    supported-insas.keys().contains(id),
    message: "Only INSAs " + supported-insas.keys().join(", ") + " are supported for now.",
  )
}

/// Checks that the school ID is supported and returns its full name.
///
/// - id (str): the short name of the school (rennes, hdf or cvl)
/// -> str
#let insa-school-name(id) = {
  assert-insa-id(id)
  return supported-insas.at(id)
}

/// Returns the path to the INSA logo for the given school identifier.
///
/// - id (str): the short name of the school (rennes, hdf or cvl)
/// -> str
#let insa-logo-path(id, white: false) = {
  assert-insa-id(id)
  if white { return "assets/" + id + "/logo-white.png" }
  let extension = if id == "cvl" { "svg" } else { "png" }
  return "assets/" + id + "/logo." + extension
}

#let insa-front-cover-path(id, variant: 1) = {
  assert-insa-id(id)
  assert(
    variant >= 1 and variant <= 3,
    message: "Variant must be 1, 2, or 3.",
  )

  let base-path = "assets/" + id + "/front-cover"
  let extension = if (id == "cvl" and variant != 3) { ".svg" } else { ".png" }
  return base-path + str(variant) + extension
}

