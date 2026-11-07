// The contact bar's entries from `basics`: one record per present
// contact detail and profile, linked per `link-contact-info`. In
// `data/`, not the header section, so the public `adapter` builds the
// same records `alta()` does without importing a section.

#import "../util/fields.typ": _field
#import "../util/values.typ": _display-url, _group-by, _url-encode
#import "../design/icon-set.typ": _icon-glyphs, _network-icons
#import "cv.typ": _location-parts, _profile-glyph, _profile-network
#import "validation.typ": _contact-channels

// Fully populated per channel, so callers can `link-config.at(channel)`
// without missing-key guards.
#let _resolve-link-config(value) = {
  let all-channels(v) = _contact-channels.fold((:), (acc, c) => acc + ((c): v))
  if type(value) == bool { all-channels(value) } else {
    all-channels(true) + value
  }
}

// `profile-icons` is the merged, lowercase-keyed
// `preferences.profile-icons`, which `_read-cv` has checked maps the
// network.
#let _profile-entry(profile, profile-icons: _network-icons) = (
  channel: "profiles",
  icon: _profile-network(profile),
  glyph: _profile-glyph(profile, profile-icons),
  // The value is usually a bare username, so the icon is the only
  // thing naming the network. The user's own string, not the
  // lowercased key, keeps their capitalisation ("GitHub").
  alt: profile.network,
  // No `url`: unlinked. No `username`: its URL, scheme dropped.
  value: profile.at(
    "username",
    default: _display-url(profile.at("url", default: "")),
  ),
  url: profile.at("url", default: none),
)

// The contact bar's entries in display order, one
// `(channel, icon, glyph, value, url)` dict per present field, `icon`
// a key of the icon set and `glyph` a FontAwesome name; `channel` keys
// into the resolved `link-contact-info` config. Pure data, no
// `context`: the location's `value` is `join-location` of its parts,
// the caller passing `_fact-line` (the theme's separator, which `data/`
// can't import); the default leaves `value` the parts array. An empty string counts as
// absent, so it never renders a bare icon behind a dead `mailto:` /
// `tel:` link.
#let _contact-entries(
  basics,
  maps-provider,
  location-alt: none,
  profile-icons: _network-icons,
  join-location: parts => parts,
) = {
  let email = _field(basics, "email")
  let phone = _field(basics, "phone")
  // The display and the maps link's query join the same parts, so
  // they can't drift; only the display takes the theme's separator.
  let location = _location-parts(basics.at("location", default: none))
  let url = _field(basics, "url")
  let fields = (
    if email != none {
      (
        channel: "email",
        icon: "email",
        glyph: _icon-glyphs.email,
        value: email,
        url: "mailto:" + email,
      )
    },
    if phone != none {
      // Strip RFC 3966 visual separators (spaces, parens, hyphens,
      // dots) from the dialable URI; the displayed value keeps them.
      (
        channel: "phone",
        icon: "phone",
        glyph: _icon-glyphs.phone,
        value: phone,
        url: "tel:" + phone.replace(regex("[\s()\-.]"), ""),
      )
    },
    if location != () {
      (
        channel: "location",
        icon: "location",
        glyph: _icon-glyphs.location,
        alt: location-alt,
        value: join-location(location),
        url: if maps-provider != none {
          // A plain replace, not `_fill-template`: a provider's other
          // `{…}` text isn't a placeholder.
          maps-provider.replace("{q}", _url-encode(location.join(", ")))
        },
      )
    },
    if url != none {
      (
        channel: "url",
        icon: "link",
        glyph: _icon-glyphs.link,
        value: _display-url(url),
        url: url,
      )
    },
  ).filter(e => e != none)
  let profiles = basics.at("profiles", default: ())
  fields + profiles.map(p => _profile-entry(p, profile-icons: profile-icons))
}

// The contact bar's entries (plus `alt` for profiles and the location),
// each with a `url` only where `link-contact-info` links its channel.
// `prefs` needs only `link-contact-info`, `maps-provider`,
// `profile-icons` and `print-full-urls`. With `print-full-urls`, an
// unlinked homepage or profile shows its `url`, scheme dropped, so a
// username on paper still says where to find it; other channels'
// `url`s (`mailto:`, `tel:`, a maps link) only point at the contact.
#let _linked-contacts(
  basics,
  prefs,
  location-alt: none,
  join-location: parts => parts,
) = {
  let link-config = _resolve-link-config(prefs.link-contact-info)
  _contact-entries(
    basics,
    prefs.maps-provider,
    location-alt: location-alt,
    profile-icons: prefs.profile-icons,
    join-location: join-location,
  ).map(e => {
    let linked = link-config.at(e.channel)
    let print = (
      not linked
        and prefs.print-full-urls
        and e.channel in ("url", "profiles")
        and e.url != none
    )
    let value = if print { _display-url(e.url) } else { e.value }
    e + (url: if linked { e.url }, value: value)
  })
}

// The contact bar's rows: contact details on one line, profiles on
// the next, so a busy bar scans in two groups. An empty row drops out.
#let _contact-rows(contacts) = _group-by(
  contacts,
  c => if c.channel == "profiles" { "profiles" } else { "details" },
).values()
