///! Global theme state.
///!
///! Plots that do not specify an explicit `theme:` argument inherit the
///! global theme.

#let _theme-state = state("gribouille-theme", none)

/// Set the global default theme for all subsequent plots.
///
/// - theme: Theme dictionary from `theme-grey`, `theme-minimal`, `theme-classic`, `theme-void`, or `theme`.
///
/// Returns: None.
///
/// See also: `theme-get`, `theme`.
///
/// Set the project default once so every plot inherits it.
///
/// ```typst
/// #theme-set(theme-minimal())
/// // All plots below use theme-minimal() by default.
/// ```
///
/// Pin a custom theme as the project default.
///
/// ```typst
/// #theme-set(theme(
///   panel-background: element-rect(fill: rgb("#fff7e6")),
///   panel-grid: element-line(colour: rgb("#d9cfbf")),
/// ))
/// ```
#let theme-set(theme) = _theme-state.update(theme)

/// Get the current global default theme.
///
/// Returns `none` if no global theme has been set.
///
/// Returns: The current global theme dictionary, or `none`.
///
/// See also: `theme-set`.
///
/// Read back the theme that subsequent plots will inherit.
///
/// ```typst
/// #theme-set(theme-minimal())
/// #let active = theme-get()
/// ```
#let theme-get() = context _theme-state.get()
