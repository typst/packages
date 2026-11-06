// Logical icon names → FontAwesome glyphs, plus the sizing wrapper.
// `@preview/fontawesome` resolves glyphs against the desktop FA fonts,
// which are not vendored: users need them installed locally, or must
// compile on typst.app, which preinstalls them.

#import "@preview/fontawesome:0.6.2": fa-icon
#import "state.typ": _body_colour, _body_size_state

// Free Solid glyphs (https://fontawesome.com/search). Keys are part of
// the public `icon(...)` API: renaming one is a breaking change.
#let _utility_icons = (
  book: "book",
  calendar: "calendar",
  email: "envelope",
  file: "file",
  location: "location-dot",
  microphone: "microphone",
  newspaper: "newspaper",
  phone: "phone",
)

// Keys are lowercase to match `lower(profile.network)` in
// `header.typ`. Brand marks, except `link` and `website` (see
// `_solid_names`).
#let _network_icons = (
  bluesky: "bluesky",
  github: "github",
  gitlab: "gitlab",
  link: "link",
  linkedin: "linkedin",
  mastodon: "mastodon",
  medium: "medium",
  stackoverflow: "stack-overflow",
  twitter: "twitter",
  website: "globe",
)

// `link` and `website` are profile networks but not brand marks.
#let _solid_names = _utility_icons.keys() + ("link", "website")

#let _icon_glyphs = _utility_icons + _network_icons
#let _profile_networks = _network_icons.keys()

// Renamed networks → the key their icon still ships under. Keys are
// lowercase, as the lookup follows `lower(profile.network)`.
#let _network_aliases = (
  x: "twitter",
)

// Emits a trailing `h(...)` so callers needn't space icons themselves.
// The fixed-size box evens out FA's varied glyph widths, which would
// otherwise jitter icon-led rows.
//
// By default the glyph is a `pdf.artifact`, so screen readers skip it
// rather than read a private-use codepoint aloud. When the icon alone
// carries meaning (a network beside a bare username), `alt` wraps it
// in `figure(alt: ...)` instead, as `box` and `link` take no alt text;
// the outer `box` keeps the figure inline.
#let icon(name, size: auto, shift: auto, fill: auto, alt: none) = context {
  let body-size = _body_size_state.get()
  let resolved-size = if size == auto { body-size } else { size }
  let resolved-shift = if shift == auto { 0.15 * body-size } else { shift }
  let resolved-fill = if fill == auto { _body_colour } else { fill }

  let glyph = _icon_glyphs.at(name)
  let solid = name in _solid_names
  let mark = box(
    baseline: resolved-shift,
    width: resolved-size,
    height: resolved-size,
    align(
      center + horizon,
      fa-icon(
        glyph,
        solid: solid,
        size: 0.9 * resolved-size,
        fill: resolved-fill,
      ),
    ),
  )
  if alt == none { pdf.artifact(mark) } else {
    box(figure(
      mark,
      alt: alt,
      numbering: none,
      outlined: false,
      gap: 0pt,
    ))
  }
  h(0.3 * body-size)
}
