#import "flavors/catppuccin-latte.typ": latte
#import "flavors/catppuccin-frappe.typ": frappe
#import "flavors/catppuccin-macchiato.typ": macchiato
#import "flavors/catppuccin-mocha.typ": mocha
#import "@preview/valkyrie:0.2.2" as z

/// The available color names for Catppuccin. Given simply by the dictionary
/// ```typ
/// #let color-names = (
///    rosewater: "Rosewater",
///    flamingo: "Flamingo",
///    pink: "Pink",
///    // ...
///  )
/// ```
///
/// -> dictionary
#let color-names = (
  rosewater: "Rosewater",
  flamingo: "Flamingo",
  pink: "Pink",
  mauve: "Mauve",
  red: "Red",
  maroon: "Maroon",
  peach: "Peach",
  yellow: "Yellow",
  green: "Green",
  teal: "Teal",
  sky: "Sky",
  sapphire: "Sapphire",
  blue: "Blue",
  lavender: "Lavender",
  text: "Text",
  subtext1: "Subtext 1",
  subtext0: "Subtext 0",
  overlay2: "Overlay 2",
  overlay1: "Overlay 1",
  overlay0: "Overlay 0",
  surface2: "Surface 2",
  surface1: "Surface 1",
  surface0: "Surface 0",
  base: "Base",
  mantle: "Mantle",
  crust: "Crust",
)

/// The available flavors for Catppuccin. Given simply by the dictionary
/// ```typ
///  #let flavors = (
///    latte: { ... },
///    frappe: { ... },
///    macchiato: { ... },
///    mocha: { ... },
///  )
///```
///
/// -> dictionary
#let flavors = (
  latte: latte,
  frappe: frappe,
  macchiato: macchiato,
  mocha: mocha,
)

#let color-schema(color-name) = z.dictionary((
  name: z.string(
    // Remove when `z.assert.eq` supports string.
    // See: https://github.com/typst-community/valkyrie/issues/49
    assertions: (
      (
        condition: (self, it) => it == color-name,
        message: (self, it) => "Must be exactly " + str(color-name),
      ),
    ),
  ),
  order: z.integer(min: 0),
  hex: z.string(),
  rgb: z.color(),
  accent: z.boolean(),
))

#let flavor-schema = z.dictionary((
  name: z.string(),
  identifier: z.string(assertions: (
    z.assert.one-of(flavors.values().map(x => x.identifier)),
  )),
  emoji: z.string(),
  order: z.integer(min: 0, max: 3),
  dark: z.boolean(),
  light: z.boolean(),
  colors: z.dictionary(color-names
    .keys()
    .fold((:), (acc, name) => (
      acc + ((name): color-schema(color-names.at(name)))
    ))),
))

/// Get the palette for the given flavor.
///
/// ==== Example
/// ```example
/// #let items = flavors.values().map(flavor => [
///   #let rainbow = (
///     "red", "yellow", "green",
///     "blue", "mauve",
///   ).map(c => flavor.colors.at(c).rgb)
///
///   #let fills = (
///     gradient.linear(..rainbow),
///     gradient.radial(..rainbow),
///     gradient.conic(..rainbow),
///   )
///
///   #stack(
///     dir: ttb,
///     spacing: 4pt,
///     text(flavor.name + ":"),
///     stack(
///       dir: ltr,
///       spacing: 3mm,
///       ..fills.map(fill => square(fill: fill))
///     )
///   )
/// ])
///
/// #grid(columns: 1, gutter: 1em, ..items)
/// ```
///
/// -> dictionary
#let get-flavor(
  /// The flavor name as a string to get the flavor for.
  /// This function is provided as a helper for anyone requiring
  /// dynamic resolution of a flavor. -> string
  flavor,
) = {
  assert.eq(
    type(flavor),
    str,
    message: "Invalid type. Argument should be a string. Got a "
      + repr(type(flavor))
      + ". ",
  )
  assert(
    flavor in flavors.keys(),
    message: "Invalid flavor name: "
      + repr(flavor)
      + ". Expected "
      + flavors.keys().join(", ", last: ", or ")
      + ".",
  )

  flavors.at(flavor)
}

/// Validate that the given dictionary is a valid flavor.
///
/// -> flavor
#let validate-flavor(
  /// The flavor to validate -> dictionary | flavor
  flavor,
) = {
  assert.eq(
    type(flavor),
    dictionary,
    message: "Invalid type. Argument should be a dictionary. Got a "
      + repr(type(flavor))
      + ". ",
  )

  z.parse(flavor, flavor-schema)
}

/// Get the flavor for the given flavor name or validate the given flavor.
/// This function is provided as a helper for anyone requiring dynamic resolution of a flavor.
///
/// -> flavor
#let get-or-validate-flavor(
  /// The flavor name as a string to get the flavor for -> string | dictionary | flavor
  flavor,
) = {
  if type(flavor) == str {
    get-flavor(flavor)
  } else {
    validate-flavor(flavor)
  }
}
