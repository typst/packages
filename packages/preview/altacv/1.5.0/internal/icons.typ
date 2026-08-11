// FontAwesome icon renderer. Delegates the actual glyph lookup +
// font selection to `@preview/fontawesome` (`fa-icon(name, solid:
// ...)`), so this file owns only:
//
//   * the logical-name → FA-glyph-name table (utility + network)
//   * the contact-bar sizing / colour / baseline-shift wrapper
//
// `fa-icon` resolves the glyph against the desktop FA fonts at
// compile time. They are not vendored — users must have FontAwesome
// installed locally (brew/apt/manual) or be compiling on typst.app,
// which ships the FA fonts in its preinstalled set.

#import "@preview/fontawesome:0.6.1": fa-icon
#import "state.typ": _body_size_state, _body_colour

// Utility icons. All resolve to the FA Free Solid font (passed via
// `solid: true`). Values are FA glyph names from the canonical
// FontAwesome catalogue — see https://fontawesome.com/search.
// Keys are the logical names the rest of the template uses; renaming
// a key here is a breaking change for any caller of the public
// `icon(...)` function.
#let _utility_icons = (
  book: "book",
  calendar: "calendar",
  email: "envelope",
  file: "file",
  // FA renamed `map-marker-alt` → `location-dot` in 6.x.
  location: "location-dot",
  microphone: "microphone",
  newspaper: "newspaper",
  phone: "phone",
)

// Profile-network icons. Keys are lowercase to match
// `lower(profile.network)` in `internal/header.typ`. Values are
// canonical FA glyph names; the FA Brands font resolves them
// automatically via the fallback list `fa-icon` consults. `link`
// and `website` resolve to Free Solid glyphs (they aren't brand
// marks) — encoded by the `is-brand` flag below.
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
  // Generic "this is a website" mark — FA Free Solid `globe`.
  website: "globe",
)

// Track which logical names are utility (solid) vs brand glyphs so
// `icon(name)` can flip `solid:` correctly. `link` and `website`
// live in `_network_icons` (they're profile-bar fallbacks) but
// render from Free Solid; everything else in `_network_icons` is a
// brand mark.
#let _solid_names = _utility_icons.keys() + ("link", "website")

#let _icon_glyphs = _utility_icons + _network_icons
#let _profile_networks = _network_icons.keys()

// Maps renamed networks onto the icon we still ship under the old
// name. The lookup happens after `lower(profile.network)`.
#let _network_aliases = (
  x: "twitter",
)

// Renders the FA glyph sized to the surrounding text. Emits a small
// trailing `h(...)` so callers don't need to add inter-icon spacing
// themselves; suppress it by wrapping in `box(...)` if undesired.
//
// The glyph is wrapped in a fixed-size box so its advance width is
// uniform across icons (FA glyphs have varied native widths, which
// would otherwise jitter the columns of icon-led rows).
#let icon(name, size: auto, shift: auto, fill: auto) = context {
  let body-size = _body_size_state.get()
  let resolved-size = if size == auto { body-size } else { size }
  let resolved-shift = if shift == auto { 0.15 * body-size } else { shift }
  let resolved-fill = if fill == auto { _body_colour } else { fill }

  let glyph = _icon_glyphs.at(name)
  let solid = name in _solid_names
  box(
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
  h(0.3 * body-size)
}
