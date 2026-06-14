// Vendored Font Awesome SVGs + the `icon()` renderer. The SVG sources
// are loaded once at module-evaluation time; `icon()` colour-swaps the
// baked `#666666` fill at call time so the same source serves both
// the default body colour and any caller-supplied tint.

#import "state.typ": _body_size_state, _body_colour

// Every SVG ships with fill="#666666" baked in so icon() can colour-
// swap by string replace at call time. Any new icon vendored into
// `icons/` must follow that convention.
#let _utility_icon_sources = (
  book: read("../icons/book.svg"),
  calendar: read("../icons/calendar.svg"),
  email: read("../icons/email.svg"),
  file: read("../icons/file.svg"),
  location: read("../icons/location.svg"),
  microphone: read("../icons/microphone.svg"),
  newspaper: read("../icons/newspaper.svg"),
  phone: read("../icons/phone.svg"),
)
#let _network_icon_sources = (
  bluesky: read("../icons/bluesky.svg"),
  github: read("../icons/github.svg"),
  gitlab: read("../icons/gitlab.svg"),
  link: read("../icons/link.svg"),
  linkedin: read("../icons/linkedin.svg"),
  mastodon: read("../icons/mastodon.svg"),
  medium: read("../icons/medium.svg"),
  stackoverflow: read("../icons/stackoverflow.svg"),
  twitter: read("../icons/twitter.svg"),
  website: read("../icons/website.svg"),
)
#let _icon_sources = _utility_icon_sources + _network_icon_sources
#let _profile_networks = _network_icon_sources.keys()

// Maps renamed networks onto the icon we still ship under the old
// name. The lookup happens after `lower(profile.network)`.
#let _network_aliases = (
  x: "twitter",
)

// Renders a vendored SVG sized to the surrounding text. Emits a small
// trailing `h(...)` so callers don't need to add inter-icon spacing
// themselves; suppress it by wrapping in `box(...)` if undesired.
#let icon(name, size: auto, shift: auto, fill: auto) = context {
  let body-size = _body_size_state.get()
  let resolved-size = if size == auto { body-size } else { size }
  let resolved-shift = if shift == auto { 0.15 * body-size } else { shift }
  let resolved-fill = if fill == auto { _body_colour } else { fill }

  let coloured = _icon_sources.at(name).replace(
    _body_colour.to-hex(),
    resolved-fill.to-hex(),
  )
  box(
    baseline: resolved-shift,
    width: resolved-size,
    height: resolved-size,
    align(
      center + horizon,
      image(bytes(coloured), format: "svg", height: 0.9 * resolved-size),
    ),
  )
  h(0.3 * body-size)
}
