///! Global theme state.
///!
///! Plots that do not specify an explicit `theme:` argument inherit the
///! global theme.

#let _theme-state = state("gribouille-theme", none)

/// Set the global default theme for all subsequent plots.
///
/// \@category Themes
/// \@subcategory Modify a theme
/// \@stability stable
/// \@since 0.1.0
///
/// \@param theme Theme dictionary from \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-void, or \@theme.
///
/// \@returns None.
///
/// \@examples-static Set the project default once so every plot inherits it.
/// ```
/// #theme-set(theme-minimal())
/// // All plots below use theme-minimal() by default.
/// ```
///
/// \@examples-static Pin a custom theme as the project default.
/// ```
/// #theme-set(theme(
///   panel-background: element-rect(fill: rgb("#fff7e6")),
///   panel-grid: element-line(colour: rgb("#d9cfbf")),
/// ))
/// ```
///
/// \@see \@theme-get, \@theme
#let theme-set(theme) = _theme-state.update(theme)

/// Get the current global default theme.
///
/// Returns `none` if no global theme has been set.
///
/// \@category Themes
/// \@subcategory Modify a theme
/// \@stability stable
/// \@since 0.1.0
///
/// \@returns The current global theme dictionary, or `none`.
///
/// \@examples-static Read back the theme that subsequent plots will inherit.
/// ```
/// #theme-set(theme-minimal())
/// #let active = theme-get()
/// ```
///
/// \@see \@theme-set
#let theme-get() = context _theme-state.get()
