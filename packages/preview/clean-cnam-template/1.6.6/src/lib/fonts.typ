/**
 * Font configuration for the TYPST template
 *
 * @author Tom Planche
 * @license MIT
 */

// Global font configuration state
#let _fonts = state("fonts", (
  default: (name: "New Computer Modern Math", weight: 400),
  body: (name: "New Computer Modern Math", weight: 400),
  title: (name: "New Computer Modern Math", weight: 400),
  code: (name: "Zed Plex Mono", weight: 400),
))

/**
 * Set global font configuration
 * @param fonts - Font configuration dictionary with keys: default, body, title, code
 */
#let set-fonts(fonts: (:)) = {
  _fonts.update(fonts)
}

/**
 * Get current font configuration
 */
#let get-fonts() = {
  _fonts.get()
}
