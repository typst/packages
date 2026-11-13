// The `adapter` helpers (`adapter.typ` re-exports them): the readers
// `alta()` maps a CV with, for a mapping of your own written with the
// public blocks (#370). Thin wrappers over the internal helpers, with
// the preferences they read passed explicitly, so a mapping reads the
// data exactly as `alta()` does. They take JSON Resume's field names
// (`countryCode`), as the CV is written.

#import "util/checks.typ": _check, _enum-rule
#import "util/dates.typ": _format-date
#import "data/contacts.typ": _contact-rows, _linked-contacts
#import "data/cv.typ": (
  _altacv, _entry-rating, _entry-type, _fluency-terms, _location-parts,
  _type-groups,
)
#import "data/cv-checks.typ": (
  _check-basics-location, _check-location, _location-text-rule,
)
#import "data/defaults.typ": _default-labels, _default-preferences
#import "data/options.typ": _merge-options
#import "data/read.typ": _kebab-fields
#import "data/sections.typ": _section-entries, _section-specs
#import "data/validation.typ": _check-preference
#import "context.typ": _labels-state
#import "design/icon-set.typ": _network-icons
#import "primitives.typ": _fact-line

/// A JSON Resume date as `alta()` shows it: `"2024-06"` reads
/// `"Jun 2024"`. A value that isn't an ISO date (`"Jan 2022"`) comes
/// back as written.
///
/// - value (str, none): The date: `YYYY`, `YYYY-MM` or `YYYY-MM-DD`.
/// - format (str, function): As `preferences.date-format`: `"long"`,
///   `"short"`, `"iso"`, a template (`"[month]/[year]"`), or a function
///   of the parsed `(year, month, day)`.
/// - months (array, auto): The twelve month names. `auto` is the
///   English; for the document's language, pass its names.
/// -> str
#let format-date(
  value,
  format: _default-preferences.date-format,
  months: auto,
) = {
  _check-preference("date-format", format, name: "format-date() format")
  _format-date(
    value,
    format,
    if months == auto { _default-labels.months } else { months },
  )
}

/// A JSON Resume `location`'s parts as `alta()` shows them: the city,
/// region and country code that are set, in that order. `alta()` joins
/// them with the theme's separator; join them as you like for
/// `entry(location: ..)` (`.join(", ")`). It takes JSON Resume's
/// field names (`countryCode`), checked as `alta()` checks them.
///
/// - location (str, dictionary, none): A location string, or the
///   `(city, region, countryCode, ..)` dictionary.
/// -> array
#let location-parts(location) = {
  _check-location(
    location,
    "location-parts() location",
    rule: _location-text-rule,
  )
  _location-parts(_kebab-fields(location))
}

/// The contact bar `alta()` draws from `basics`, as `contact`-shaped
/// records for `cv-header(contacts: ..)`: the details (email, phone,
/// location, homepage), a `linebreak()`, then the profiles. The
/// linebreak drops out when either group is empty. A profile's glyph
/// comes from `icons`, so a record may draw a network `contact()`'s
/// icon names don't list. The records are for `cv-header`: a profile's
/// `alt` is its network as written, every other `alt` is `auto`, which
/// `cv-header` resolves (the location's in the document's language),
/// so read elsewhere, `alt` may be `auto`.
///
/// - basics (dictionary): The CV's `basics`.
/// - linked (bool, dictionary): As `preferences.link-contact-info`:
///   whether to link every channel, or a bool per channel (`email`,
///   `phone`, `location`, `url`, `profiles`).
/// - maps-provider (str, none): The map a location links to: a
///   `maps-providers` entry, or a URL template with `{q}`.
/// - full-urls (bool): As `preferences.print-full-urls`: an unlinked
///   homepage or profile shows its URL.
/// - icons (dictionary, auto): Profile networks' FontAwesome glyphs,
///   by lowercase network name, over the built-in ones.
/// -> array
#let basics-contacts(
  basics,
  linked: true,
  maps-provider: _default-preferences.maps-provider,
  full-urls: false,
  icons: auto,
) = {
  _check-preference(
    "link-contact-info",
    linked,
    name: "basics-contacts() linked",
  )
  _check-preference(
    "maps-provider",
    maps-provider,
    name: "basics-contacts() maps-provider",
  )
  _check-basics-location(basics, "basics-contacts() location", maps-provider)
  let profile-icons = (
    _network-icons
      + if icons == auto { (:) } else {
        icons.pairs().map(((k, v)) => (lower(k), v)).to-dict()
      }
  )
  // A record as `contact()` makes one, `alt` as the docstring says.
  let as-contact(c) = {
    if c.glyph == none {
      panic(
        "basics-contacts(): no icon for the profile network "
          + repr(c.alt)
          + "; map it in `icons:` (e.g. (kaggle: \"kaggle\"))",
      )
    }
    (
      icon: c.icon,
      glyph: c.glyph,
      value: c.value,
      url: c.url,
      alt: c.at("alt", default: auto),
    )
  }
  let rows = _contact-rows(_linked-contacts(
    _kebab-fields(basics),
    (
      link-contact-info: linked,
      maps-provider: maps-provider,
      print-full-urls: full-urls,
      profile-icons: profile-icons,
    ),
    location-alt: auto,
    join-location: _fact-line,
  ))
  rows.map(row => row.map(as-contact)).join((linebreak(),), default: ())
}

/// A language's fluency as `alta()` rates it: its
/// `custom.altacv.rating`, else its `fluency` term (`"Native"`,
/// `"Professional Working"`, …) on a scale of `max`, to the half;
/// `none` for any other term, which `alta()` shows as text.
///
/// - entry (dictionary): A `languages[]` entry.
/// - max (int): The scale's top.
/// -> int, float, none
#let fluency-rating(
  entry,
  max: _default-preferences.max-rating,
) = _entry-rating(
  entry,
  "fluency",
  _fluency-terms,
  max,
)

/// One of altacv's own fields, from its `custom.altacv` namespace on
/// the CV or an entry: `focusAreas`, a skill's or language's `rating`,
/// an award's `url`.
///
/// - obj (dictionary): The CV, or one of its entries.
/// - key (str): The field.
/// - default (any): Its value when it's unset.
/// -> any
#let custom(obj, key, default: none) = _altacv(obj, key, default: default)

/// An entry's `type` as `alta()` reads it: trimmed, or `none` when it's
/// untyped (no `type`, or a blank one).
///
/// - entry (dictionary): A `projects[]` or `publications[]` entry.
/// -> str, none
#let entry-type(entry) = _entry-type(entry)

/// Entries grouped by `type` (`entry-type`) as `alta()` groups them:
/// `(group, items)` pairs in the order each group first appears.
/// Pairs rather than a dictionary, as the untyped group may be `none`,
/// which can't be a dictionary key. `alta()` groups projects with
/// `untyped: labels.other-projects`, so a type named as the label
/// shares the untyped group, and publications by code, with
/// `key: lower, untyped: "article"`.
///
/// - items (array): Entries with an optional `type`.
/// - key (function): A typed entry's group, from its type: as written
///   by default, `lower` to match types ignoring case.
/// - untyped (any): The untyped entries' group, `none` by default.
/// -> array
#let group-by-type(items, ..args) = _type-groups(items, ..args)

/// The labels `alta()` renders with, in the document's language: its
/// bundled translation over the English, the template's
/// (`altacv.with(labels: ..)`) over that, `overrides` over all, merged
/// and checked as `alta(labels: ..)`'s are. Keys are `alta()`'s
/// kebab-case label names (`work`, `present`, `other-projects`);
/// `months` is the twelve month names, `publication-types` a heading
/// per publication `type` code, lowercase. Call it in `context`, where
/// the document's language is known.
///
/// - overrides (dictionary): Labels to override, as `alta()`'s
///   `labels:` takes them; a `publication-types` entry overrides that
///   one heading.
/// -> dictionary
#let labels(overrides: (:)) = (
  _merge-options(
    overrides,
    (:),
    lang: text.lang,
    template: _labels-state.get(),
  ).labels
)

/// The preferences `alta()` renders with inside the template:
/// `overrides` merged over its defaults and checked as
/// `alta(preferences: ..)`'s are, so a mapping reads every key, set or
/// not. Keys are `alta()`'s kebab-case preference names
/// (`column-ratio`, `date-format`); a camelCase one reads as its
/// kebab-case name. A document-level preference (`font`, `paper`, …)
/// panics, naming the set rule that replaces it.
///
/// - overrides (dictionary): Preferences to override, as `alta()`'s
///   `preferences:` takes them.
/// -> dictionary
#let preferences(overrides: (:)) = (
  _merge-options((:), overrides, inside: true).prefs
)

/// A section's entries as `alta()` renders them: the CV's own key's,
/// or for `focus-areas`, `custom.altacv.focusAreas`; without the
/// entries `alta()` skips, as having nothing to draw (a project,
/// publication or certificate without its `name`, an award without its
/// `title`, a language without its `language`, a skill or interest
/// group without keywords, a reference with neither a quote nor
/// `availableOnRequest`). `()` when the CV has none.
///
/// - cv (dictionary): The CV.
/// - key (str): A section key, as the column preferences name them
///   (`work`, `focus-areas`, …).
/// -> array
#let entries(cv, key) = {
  _check("entries() key", key, _enum-rule(_section-specs.keys()))
  _section-entries(cv, key)
}
