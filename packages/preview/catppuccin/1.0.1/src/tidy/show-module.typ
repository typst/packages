#import "../flavors.typ": flavors, get-or-validate-flavor
#import "styles.typ"
#import "@preview/tidy:0.4.3"

/// A wrapper function around `tidy.show-module`.
/// -> content
#let show-module(
  /// Module documentation information as returned by `tidy.parse-module`.
  /// -> dictionary
  docs,
  /// The Catppuccin flavor to use for the style -> flavor
  flavor: flavors.mocha,
  /// Alternative style settings to use. See @ctp-tidy-style -> dictionary
  style-alt: (:),
  /// Additional arguments to pass to `tidy.show-module`
  ..args,
) = {
  let flavor = get-or-validate-flavor(flavor)
  let style = styles.ctp-tidy-style(flavor: flavor.identifier)

  for (key, value) in style-alt {
    style.insert(key, value)
  }

  tidy.show-module(docs, colors: style.colors, style: style, ..args)
}
