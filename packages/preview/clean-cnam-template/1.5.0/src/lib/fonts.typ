/**
 * Font configuration for the TYPST template
 *
 * @author Tom Planche
 * @license MIT
 */

// Global font configuration state
#let _fonts = state("fonts", (
  default: (name: "New Computer Modern Math", weight: 400),
  code: (name: "Zed Plex Mono", weight: 400)
))

/**
 * Set global font configuration
 * @param default-font - Default font object (name, weight)
 * @param code-font - Code font object (name, weight)
 */
#let set-fonts(
  default-font: (name: "New Computer Modern Math", weight: 400),
  code-font: (name: "Zed Plex Mono", weight: 400)
) = {
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
