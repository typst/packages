//! typst-lucide
//!
//! https://github.com/Lieunoir/typst-lucide
//
// Inspired by https://github.com/duskmoon314/typst-fontawesome/blob/main/lib-impl.typ

#import "lib-map.typ": *

/// Render a lucide icon by its name
///
/// Parameters:
/// - `name`: Name of the icon
/// - `..args`: Additional arguments passed to the `text` function
/// - `fill`: Fill color, none by default. Officially not supported (see https://lucide.dev/guide/advanced/filled-icons)
///
/// Returns: lucide icon as text element
#let lucide-icon(name, ..args) = {
  text(
    font: "lucide",
    lucide-icon-map.at(name, default: name),
    ..args)
}
