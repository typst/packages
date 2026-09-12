// Polarity adaptations derived from the palette.
//
// A deck flips a theme to dark by swapping colors through `setup(colors: ..)`,
// not by picking a twin theme. Almost every rule in a theme's `apply` paints
// from `colors.*` and follows the swap on its own. The exceptions live here:
// values that cannot be expressed as a palette entry, chiefly the syntax
// highlighting theme, which is an asset rather than a color. A theme reads the
// canvas it was handed and branches, so any palette a deck passes gets the
// right treatment without declaring its polarity anywhere.

// Whether a palette's canvas reads as dark, by relative luminance of its
// canvas color. The threshold is coarse on purpose: palettes cluster near
// white or near black, and a mid-gray canvas is legible under either branch.
#let is-dark-canvas(colors) = {
  let parts = rgb(colors.canvas).components()
  0.2126 * parts.at(0) + 0.7152 * parts.at(1) + 0.0722 * parts.at(2) < 50%
}

// The syntax highlighting theme for dark canvases. Typst's built-in raw
// colors are tuned for light grounds; a dark canvas swaps this in instead.
#let dark-code-theme = read("code-dark.tmTheme", encoding: none)
