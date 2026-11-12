// Up-front checks for the CV: each section's entry array and every
// field a renderer reads, so a renderer only meets values it can draw.
// `_read-cv` runs them; the options' are in `validation.typ`.

#import "../util/checks.typ": (
  _check-rating, _check-rules, _check-type, _check-unknown-keys, _list-rule,
  _prose-list, _quote, _require, _type-rule, _unknown,
)
#import "../util/fields.typ": _field
#import "../util/values.typ": _present, _present-str
#import "cv.typ": (
  _altacv, _altacv-ns, _location-fields, _profile-glyph, _skill-levels,
  _term-rating,
)

// Field rules (`_section-specs`' `fields`, `basics`): the types the
// renderers can draw. Dates are text too: a non-ISO one renders as
// written.
#let _text-rule = _type-rule((str, content), "a string or content")
#let _string-rule = _type-rule((str,), "a string")
#let _texts-rule = _list-rule((str, content), "an array of strings or content")

// A dict where a list belongs fails here, not deep in a renderer.
// Returns `entries`.
#let _check-section-entries(key, entries, item-types) = {
  _check-type(key, entries, (array,), "an array")
  let bad = entries.find(e => type(e) not in item-types)
  _require(
    key + " entries",
    bad,
    bad == none,
    _prose-list(item-types.map(repr)),
  )
  entries
}

#let _location-expected = (
  "a string or a dict matching JSON Resume's {"
    + _location-fields.join(", ")
    + "}"
)

// JSON Resume's `location`: a string or the shared dict. `what` is the
// field's path, for the message. `rule`, when set, checks the values
// shown (`city`, `region`, `countryCode`); `address` and `postalCode`
// aren't shown, so, as in 1.8.0, they take any value.
#let _location-shown = ("city", "region", "countryCode")
#let _location-text-rule = _type-rule(
  (str, content, type(none)),
  "a string or content",
)
#let _check-location(value, what, rule: none) = if (
  type(value) == dictionary
) {
  _check-unknown-keys(value.keys(), _location-fields, what)
  if rule != none {
    _check-rules(
      value,
      _location-shown.map(k => (k, rule)).to-dict(),
      prefix: what + ".",
      optional: true,
    )
  }
} else if _present(value) {
  _check-type(what, value, (str,), _location-expected)
}

// `basics.location`: its maps link URL-encodes the values shown, which
// only strings can be. With no maps-provider they're unchecked, as
// 1.8.0 drew any value there.
#let _check-basics-location(basics, what, maps-provider) = _check-location(
  basics.at("location", default: none),
  what,
  rule: if maps-provider != none {
    _type-rule((str, type(none)), "a string when a maps-provider is set")
  },
)

// The section `check`s (`_section-specs`) take the section's key, for
// messages, the entry and the preferences.

#let _check-entry-location(key, entry, _) = _check-location(
  entry.at("location", default: none),
  key + "[].location",
  rule: _location-text-rule,
)

// An award's link, in its `custom.altacv` namespace, which `fields`
// can't reach.
#let _check-award(key, entry, _) = _check-rules(
  _altacv-ns(entry),
  (url: _string-rule),
  prefix: key + "[].custom.altacv.",
  optional: true,
)

// An entry's `custom.altacv.rating`, checked against `max-rating` when
// set; `none` when not.
#let _altacv-rating(key, entry, prefs) = {
  let rating = _altacv(entry, "rating")
  if rating != none {
    _check-rating(key + "[].custom.altacv.rating", rating, prefs.max-rating)
  }
  rating
}

// A `custom.altacv.rating` wins over `fluency`, so a `fluency` it
// leaves to show must be a string. JSON Resume requires neither: a
// language with neither shows its name alone.
#let _check-language(key, entry, prefs) = {
  if _altacv-rating(key, entry, prefs) == none {
    _check-type(
      key + "[].fluency",
      entry.at("fluency", default: none),
      (str, type(none)),
      "a string when there's no numeric `custom.altacv.rating`",
    )
  }
}

#let _skill-level-expected = (
  "one of "
    + _prose-list(_skill-levels.keys().map(_quote))
    + " with `skill-level-display: \"rating\"`, or overridden by `custom.altacv.rating`"
)

// With `skill-level-display: "rating"`, a `level` must map to dots.
#let _check-skill(key, entry, prefs) = {
  let level = _field(entry, "level")
  if (
    _altacv-rating(key, entry, prefs) == none
      and prefs.skill-level-display == "rating"
      and level != none
  ) {
    _require(
      key + "[].level",
      level,
      _term-rating(level, _skill-levels, prefs.max-rating) != none,
      _skill-level-expected,
    )
  }
}

// No `pronouns`: JSON Resume dropped it as added by accident, so
// it is ignored like any other extra field.
// https://github.com/jsonresume/jsonresume.org/pull/629
#let _basics-fields = (
  name: _text-rule,
  label: _text-rule,
  email: _string-rule,
  phone: _string-rule,
  url: _string-rule,
  summary: _text-rule,
  profiles: _list-rule((dictionary,), "an array of dictionaries"),
)
#let _profile-fields = (
  network: _string-rule,
  username: _text-rule,
  url: _string-rule,
)

// The root fields outside the sections: `basics` and `objective`.
#let _check-root(cv, prefs) = {
  let basics = cv.basics
  _check-rules(basics, _basics-fields, prefix: "basics.", optional: true)
  _check-type(
    "basics.image",
    basics.at("image", default: none),
    (path, str, bytes, type(none)),
    "a path, a string path, or bytes",
  )
  _check-basics-location(basics, "basics.location", prefs.maps-provider)
  for profile in basics.at("profiles", default: ()) {
    _check-rules(
      profile,
      _profile-fields,
      prefix: "basics.profiles[].",
      optional: true,
    )
    _require(
      "basics.profiles[].network",
      profile.at("network", default: none),
      "network" in profile,
      "set",
    )
    if _profile-glyph(profile, prefs.profile-icons) == none {
      _unknown(
        "profile network",
        repr(profile.network),
        prefs.profile-icons.keys().join(", "),
        hint: " To use another, map it to a FontAwesome glyph in preferences.profile-icons (e.g. (kaggle: \"kaggle\")).",
      )
    }
  }
  if prefs.qr-code == auto {
    let url = basics.at("url", default: none)
    _require(
      "basics.url",
      url,
      _present-str(url),
      "a non-empty URL string when preferences.qr-code is `auto`",
    )
  }
  _check-type("meta", cv.meta, (dictionary,), "a dictionary")
  // `version` and `canonical` are read leniently (`_string-at`).
  _check-rules(
    cv.meta,
    (lastModified: _text-rule),
    prefix: "meta.",
    optional: true,
  )
  _check-type(
    "objective",
    cv.at("objective", default: none),
    (str, content, type(none)),
    "a string or content",
  )
}
