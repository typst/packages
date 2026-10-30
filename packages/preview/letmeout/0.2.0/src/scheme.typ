// Color-scheme-specific content and scoped theme settings. Paged output is unchanged.
#import "css.typ": color-css, dark-properties

// Content for one color scheme: a logo for dark backgrounds, a note, a figure.
#let by-color-scheme(light: none, dark: none) = context {
  if target() != "html" { return light }
  html.elem("letmeout-light", attrs: (style: "display: contents"), light)
  html.elem("letmeout-dark", attrs: (style: "display: none"), dark)
}

// Content visible in just one color scheme. Paged output uses the light side.
#let light-only(body) = by-color-scheme(light: body)
#let dark-only(body) = by-color-scheme(dark: body)

// Existing names retained for compatibility.
#let for-scheme = by-color-scheme
#let on-scheme = by-color-scheme

// The same dark-color mappings and frame policy as `letmeout`, for one scope.
// Unspecified mappings inherit; nested scopes replace only the colors they name.
// `auto` inherits the frame policy; `none` keeps original SVG colors.
#let theme(dark-colors: (), dark-frames: auto, body) = context {
  assert(dark-frames in (auto, none, "invert"), message: "letmeout: dark-frames is auto, \"invert\" or none")
  let styles = ("display: contents",) + dark-properties(dark-colors)
  if target() != "html" { return body }
  // Recompute inherited text color here so local custom properties take effect.
  if type(text.fill) == color { styles.push("color: " + color-css(text.fill, role: "ink")) }
  if dark-frames != auto {
    styles.push("--letmeout-dark-frame-filter: " + if dark-frames == none { "none" } else { "invert(1) hue-rotate(180deg)" })
  }
  html.elem("letmeout-theme", attrs: (style: styles.join("; ")), body)
}
