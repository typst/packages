
/// The package version of Catppuccin.
///
/// ==== Example:
/// #example(
/// ```typ
/// This package's version is #version.
/// ```)
///
/// -> version
#let version = version(..toml("../typst.toml")
  .package
  .version
  .split(".")
  .map(x => int(x)))
