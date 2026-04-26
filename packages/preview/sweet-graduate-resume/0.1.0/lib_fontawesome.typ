//! typst-fontawesome
//!
//! https://github.com/duskmoon314/typst-fontawesome

// Implementation of `fa-icon`
#import "lib_impl.typ": *

// Generated icons
#import "lib_gen.typ": *

// Re-export the `fa-icon` function
// The following doc comment is needed for lsp to show the documentation

/// Render a Font Awesome icon by its name or unicode
///
/// Parameters:
/// - `name`: The name of the icon
///   - This can be name in string or unicode of the icon
/// - `solid`: Whether to use the solid version of the icon
/// - `fa-icon-map`: The map of icon names to unicode
///   - Default is a map generated from FontAwesome metadata
///   - *Not recommended* You can provide your own map to override it
/// - `..args`: Additional arguments to pass to the `text` function
///
/// Returns: The rendered icon as a `text` element
#let fa-icon = fa-icon.with(fa-icon-map: fa-icon-map)
