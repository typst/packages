/**
 * Font configuration for the TYPST template
 *
 * @author Tom Planche
 * @license MIT
 */

// Global font configuration state
#let _fonts = state("fonts", (
  default: "New Computer Modern Math",
  code: "Zed Plex Mono"
))

/**
 * Set global font configuration
 * @param default-font - Default font family
 * @param code-font - Code font family
 */
#let set-fonts(default-font: "New Computer Modern Math", code-font: "Zed Plex Mono") = {
  _fonts.update((
    default: default-font,
    code: code-font
  ))
}

/**
 * Get current font configuration
 */
#let get-fonts() = {
  _fonts.get()
}
