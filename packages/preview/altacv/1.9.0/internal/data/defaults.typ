// The defaults the caller's labels and preferences merge over: the
// labels, kept in `labels-en.toml` and its translations so translators
// edit a plain resource file rather than Typst source, and the
// preferences, with the `maps-providers` presets for `maps-provider`.

#import "../design/icon-set.typ": _network-icons, _publication-icons
#import "sections.typ": _keys-for-column

#let _default-labels = toml("labels-en.toml")
// The bundled translations, by ISO 639 code: each sets only the labels
// it changes, over `_default-labels` (`_resolve-labels`).
#let _translations = (ga: toml("labels-ga.toml"))

/// Map deep-link URL templates for `preferences.maps-provider`; `{q}`
/// becomes the URL-encoded `basics.location`.
/// -> dictionary
#let maps-providers = (
  google: "https://www.google.com/maps?q={q}",
  apple: "https://maps.apple.com/?q={q}",
  bing: "https://www.bing.com/maps?q={q}",
  duckduckgo: "https://duckduckgo.com/?q={q}&iaxm=maps",
  osm: "https://www.openstreetmap.org/search?query={q}",
)

// Documented in docs/reference.md's preferences tables and grouped as
// there, which is also the order the "Supported:" list of an
// unknown-key panic follows. Comments here note only constraints the
// reference doesn't need.
#let _default-preferences = (
  // Look.
  // `auto`: the theme's.
  font: auto,
  body-size: 10pt,
  // Internal: the deprecated `accent`'s roles over the default theme
  // (`_fold-accent`). A caller's `colours` panics (`_merge-options`).
  colours: (:),
  publication-icons: _publication-icons,
  project-icons: (:),
  profile-icons: _network-icons,
  // Header.
  // Visual only: PDF title / author metadata keep the name as given.
  uppercase-name: true,
  header-text-align: left,
  photo-size: 6em,
  photo-shape: "circle",
  photo-position: right,
  // Deprecated (#239): read into `photo-position` (`canonical.typ`).
  image-stack-order: "above",
  qr-code: none,
  // Page and layout.
  paper: "a4",
  margin: (x: 0.9cm, y: 1.5cm),
  column-ratio: 0.65,
  left-column-sections: _keys-for-column("left"),
  right-column-sections: _keys-for-column("right"),
  // Footer.
  page-footer: none,
  last-modified-footer: false,
  // Rides the `last-modified-footer` line; no-op without it.
  footer-version: false,
  // Formatting and links.
  date-format: "long",
  link-contact-info: true,
  print-full-urls: false,
  maps-provider: maps-providers.google,
  max-rating: 5,
  skill-level-display: auto,
  owner-names: (),
  // Deprecated, removed in the next major (#239). `accent` has no
  // default, as `_canonical-preferences` folds it into `colours`.
  // `group-certificates` and `show-pronouns` are ignored (JSON Resume
  // dropped `basics.pronouns` as added by accident,
  // https://github.com/jsonresume/jsonresume.org/pull/629),
  // and `_canonical-cv` turns `references-available-on-request` into a
  // `references[].availableOnRequest` entry.
  group-certificates: true,
  show-pronouns: false,
  references-available-on-request: false,
)
