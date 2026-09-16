//! typst-tabler-icons
//!
//! https://github.com/zyf722/typst-tabler-icons

// Implementation of `tabler-icon`
#import "lib-impl.typ": tabler-icon

// Generated icons
#import "lib-gen.typ": *

// Re-export the `tabler-icon` function
// The following doc comment is needed for lsp to show the documentation

/// Render a [Tabler icon](https://tabler.io/icons) by its name or unicode.
///
/// Parameters:
/// - `icon`: The name of the icon
///   - This can be name in string or unicode of the icon
/// - `tabler-icon-map`: The map of icon names to unicode
///   - Default is a map generated from Tabler metadata
///   - *Not recommended* You can provide your own map to override it
/// - `..args`: Additional arguments to pass to the `text` function
///
/// Returns: The rendered icon as a `text` element
#let tabler-icon = tabler-icon.with(tabler-icon-map: tabler-icon-map)
