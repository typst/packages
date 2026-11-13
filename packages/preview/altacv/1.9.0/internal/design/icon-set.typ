// The icon vocabulary: logical icon names and the FontAwesome glyphs
// they draw, the profile networks the contact bar recognises, the
// built-in publication icons, and every glyph name FontAwesome knows.
// Data, so validation can check names without importing the renderer
// (`icons.typ`).

#import "@preview/fontawesome:0.6.2": fa-icon-map-common, fa-icon-map-version

// Free Solid glyphs (https://fontawesome.com/search). Keys are part of
// the public `icon(...)` API: renaming one is a breaking change.
#let _utility-icons = (
  book: "book",
  calendar: "calendar",
  cubes: "cubes",
  email: "envelope",
  file: "file",
  flask: "flask",
  folder: "folder",
  laptop-code: "laptop-code",
  location: "location-dot",
  microphone: "microphone",
  newspaper: "newspaper",
  phone: "phone",
  terminal: "terminal",
)

// The `preferences.profile-icons` default: the networks the contact bar
// draws out of the box. Keys are lowercase to match `_profile-network`
// (`data/cv.typ`), which lowercases the network. Brand marks, except
// `link` and `website` (see `_solid-names`).
#let _network-icons = (
  bluesky: "bluesky",
  github: "github",
  gitlab: "gitlab",
  link: "link",
  linkedin: "linkedin",
  mastodon: "mastodon",
  medium: "medium",
  orcid: "orcid",
  stackoverflow: "stack-overflow",
  twitter: "twitter",
  website: "globe",
)

// `link` and `website` are profile networks but not brand marks.
#let _solid-names = _utility-icons.keys() + ("link", "website")

#let _icon-glyphs = _utility-icons + _network-icons

// `publications[].type` codes → the icon leading their subheading:
// the `preferences.publication-icons` default.
#let _publication-icons = (
  article: "newspaper",
  book: "book",
  thesis: "book",
  talk: "microphone",
)

// Renamed networks → the key their icon still ships under. Keys are
// lowercase, as `_profile-network` (`data/cv.typ`) lowercases the network.
#let _network-aliases = (
  x: "twitter",
)

// Every glyph name `fa-icon` resolves under FontAwesome 7, the
// version `@preview/fontawesome` defaults to and the pinned image
// installs (bump the key with the import and the image): what a
// `preferences.profile-icons` value is checked against, so a typo
// (`githb`) panics rather than rendering a missing
// glyph. It includes Pro-only names, which the Free fonts lack.
#let _fa-glyphs = fa-icon-map-common + fa-icon-map-version.at("7")
