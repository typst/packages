// Header — name + label + summary + contact bar, optionally with a
// circular portrait. Owns every above-the-grid surface driven by
// `basics`: the header block itself, the `_summary` paragraph that
// sits between the contact bar and the first section heading, and the
// `_format_location` / `_url_encode` helpers that feed the maps deep
// link (single-caller helpers, kept adjacent to their consumer).
//
// `_header` composes three stages — `_contact_entries` (pure data),
// `_header_text` (name / label / contact bar) and `_header_layout`
// (photo + QR placement) — so each can change without re-reading the
// others. Preference shapes are validated up front in
// `validation.typ`; nothing here re-checks them.

#import "state.typ": _accent_state, _body_size_state, _emphasis_colour
#import "icons.typ": _network_aliases, _profile_networks, icon
#import "qr.typ": _qr_render, _resolve_qr_url
#import "text.typ": _present
#import "validation.typ": _check_unknown_keys, _contact_channels

// JSON Resume's structured `location` dict collapsed to a single
// header line. `address`/`postalCode` round-trip but aren't rendered
// — a CV header isn't a mailing label. Unknown keys panic to surface
// typos. The result drives both the displayed text and the maps
// deep link, so reader and link target stay in sync. Empty strings
// normalise to `none` so downstream `!= none` checks treat them as
// absent (no orphan location row, no blank-query maps URL).
#let _location_fields = (
  "address",
  "postalCode",
  "city",
  "countryCode",
  "region",
)
#let _location_display_order = ("city", "region", "countryCode")
#let _format_location(value) = {
  if value == none { return none }
  if type(value) == str {
    if value == "" { return none }
    return value
  }
  if type(value) != dictionary {
    panic(
      "basics.location must be a string or a dict matching JSON Resume's"
        + " {address, postalCode, city, countryCode, region}, got: "
        + repr(value),
    )
  }
  _check_unknown_keys(value.keys(), _location_fields, "basics.location")
  let parts = _location_display_order
    .map(k => value.at(k, default: none))
    .filter(v => v != none and v != "")
  if parts.len() == 0 { return none }
  parts.join(", ")
}

// Per RFC 3986. Iterates UTF-8 bytes (not codepoints), so non-Latin
// locations like "Zürich" or "京都" round-trip through the maps URL.
#let _url_encode(s) = {
  let unreserved = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
  let hex = "0123456789ABCDEF"
  let out = ""
  for b in array(bytes(s)) {
    if b < 128 and str.from-unicode(b) in unreserved {
      out += str.from-unicode(b)
    } else {
      out += "%" + hex.at(int(b / 16)) + hex.at(int(calc.rem(b, 16)))
    }
  }
  out
}

// `image()` resolves bare string paths at THIS file, which lives
// in the @preview cache for installed users. Accepting `path` and
// `bytes` lets callers anchor resolution at their own .typ; README
// documents the forms. `fit: "cover"` keeps non-square sources
// from distorting. `alt` becomes the image's `/Alt` in Typst's tagged
// PDF output, so screen readers announce the portrait instead of
// meeting an unlabelled figure.
#let _portrait(source, size, alt) = box(
  width: size,
  height: size,
  clip: true,
  radius: 50%,
  image(source, fit: "cover", width: 100%, height: 100%, alt: alt),
)

// Returns a fully-populated per-channel dict so downstream code can
// always `link-config.at(channel)` without missing-key guards. The
// shape (bool, or a dict of bools keyed by `_contact_channels`) is
// already enforced by `_validate_preferences`.
#let _resolve_link_config(value) = {
  // Sourcing the channel set from `_contact_channels` keeps adding a
  // channel a one-line change there, not here.
  let all-channels(v) = _contact_channels.fold((:), (acc, c) => acc + ((c): v))
  if type(value) == bool { all-channels(value) } else {
    all-channels(true) + value
  }
}

#let _profile_entry(profile) = {
  let raw = lower(profile.network)
  let network = _network_aliases.at(raw, default: raw)
  if network not in _profile_networks {
    panic(
      "Unknown profile network: "
        + repr(profile.network)
        + ". Supported: "
        + _profile_networks.join(", ")
        + ". To add another, register its FontAwesome glyph in _network_icons (internal/icons.typ).",
    )
  }
  (
    channel: "profiles",
    icon: network,
    // The display value is usually a bare username, so the icon is the
    // only thing naming the network; `alt` tags it with that name
    // instead of leaving it a decorative artifact. The user's own
    // `network` string, not the lowercased key, carries their
    // capitalisation ("GitHub", "LinkedIn").
    alt: profile.network,
    // Partial profiles (no `url`) keep working: the display value
    // falls back to `url` then "", and the link wrap is gated on
    // `entry.url != none` in `_header_text` — using
    // `.at("url", default: none)` instead of direct access means a
    // profile with only `network` + `username` renders the username
    // and skips the link.
    value: profile.at("username", default: profile.at("url", default: "")),
    url: profile.at("url", default: none),
  )
}

// The contact bar's entries in display order, one
// `(channel, icon, value, url)` dict per present field. `channel` keys
// into the resolved `linkContactInfo` config; `url: none` renders the
// value unlinked. Profile entries add an `alt` for their icon; the
// rest leave it out, since their value speaks for itself. Pure data —
// no `context` — so the bar's contents can be reasoned about apart
// from its styling. `_present` (not `!= none`) so an empty-string
// field is skipped rather than rendering a bare icon behind a dead
// `mailto:` / `tel:` link.
#let _contact_entries(basics, maps-provider) = {
  let email = basics.at("email", default: none)
  let phone = basics.at("phone", default: none)
  // `_format_location` collapses the JSON Resume dict form
  // `{address, postalCode, city, countryCode, region}` to a single
  // line, leaves an already-flat string untouched, and returns `none`
  // when every relevant field is empty. Both the display value and the
  // maps deep link are fed from the same result so they cannot drift.
  let location = _format_location(basics.at("location", default: none))
  let url = basics.at("url", default: none)
  let fields = (
    if _present(email) {
      (channel: "email", icon: "email", value: email, url: "mailto:" + email)
    },
    if _present(phone) {
      // Strip RFC 3966 visual separators (spaces, parens, hyphens,
      // dots) from the dialable URI; the displayed value keeps them.
      (
        channel: "phone",
        icon: "phone",
        value: phone,
        url: "tel:" + phone.replace(regex("[\s()\-.]"), ""),
      )
    },
    if location != none {
      (
        channel: "location",
        icon: "location",
        value: location,
        url: if maps-provider != none {
          maps-provider.replace("{q}", _url_encode(location))
        },
      )
    },
    if _present(url) { (channel: "url", icon: "link", value: url, url: url) },
  ).filter(e => e != none)
  fields + basics.at("profiles", default: ()).map(_profile_entry)
}

// Name, optional label, and contact bar, aligned per
// `headerTextAlign`. Takes the already-resolved `body-size` / `accent`
// so `_header` owns the single `context` read.
#let _header_text(basics, preferences, body-size, accent) = {
  let link-config = _resolve_link_config(preferences.linkContactInfo)
  let headline = basics.at("label", default: none)
  let bar-icon = icon.with(
    size: 0.9 * body-size,
    shift: 0.2 * body-size,
    fill: accent,
  )
  let text-align = (left: left, right: right, center: center).at(
    preferences.headerTextAlign,
  )
  align(text-align, {
    block(
      spacing: 0pt,
      below: 1.2 * body-size,
      text(
        2.5 * body-size,
        fill: accent,
        weight: "bold",
        if preferences.uppercaseName { upper(basics.name) } else {
          basics.name
        },
      ),
    )

    if _present(headline) {
      block(
        spacing: 0pt,
        below: 0.8 * body-size,
        text(
          1.2 * body-size,
          fill: _emphasis_colour,
          weight: "bold",
          headline,
        ),
      )
    }

    set text(0.8 * body-size, weight: "bold")
    // Each entry is wrapped in `box(...)` so the icon and its display
    // text stay together when the contact bar wraps — line breaks fall
    // on the inter-entry `h(...)` joins, never between an icon and the
    // text it labels.
    _contact_entries(basics, preferences.mapsProvider)
      .map(entry => box({
        bar-icon(entry.icon, alt: entry.at("alt", default: none))
        let value = [#entry.value]
        if link-config.at(entry.channel) and entry.url != none {
          link(entry.url, value)
        } else { value }
      }))
      .join(h(1.2 * body-size))
    // Inherits par.spacing, so the gap stays in sync with the rest of
    // the document even when bodySize is tweaked.
    parbreak()
  })
}

// `path` is always populated by construction (no public way to make an
// empty one); `str` and `bytes` can be empty and should silently skip
// the frame. Panicking on other types avoids a cryptic `image()`
// failure or a silent missing photo. `alt` is the portrait's
// accessible description — the person's name, which is
// language-neutral and so needs no label key.
#let _header_photo(image-src, size, alt) = {
  let has-image = if image-src == none {
    false
  } else if type(image-src) == path {
    true
  } else if type(image-src) in (str, bytes) {
    image-src.len() > 0
  } else {
    panic(
      "basics.image must be a path, a string path, or bytes, got: "
        + repr(image-src),
    )
  }
  if has-image { _portrait(image-src, size, alt) }
}

// Places the optional photo and QR around `header-text` per
// `imagePosition` / `imageStackOrder`. `photo` and `qr` are `none`
// when absent.
#let _header_layout(header-text, photo, qr, qr-size, body-size, preferences) = {
  // Centred portrait: photo stacks on its own row above or below the
  // text block. Full-width `block` centres the photo against the
  // document width (a bare `align(center, box)` would centre against
  // the default inline position). When a QR is present, the top row
  // is wrapped in a `(auto, 1fr, auto)` grid — QR on the left,
  // content centred page-wise in the 1fr column, `qr-size` spacer on
  // the right — so the QR stays anchored to the header's top corner
  // regardless of stack order. The inter-row gap is applied
  // externally via `v(...)` so it survives the grid wrap (block
  // spacing inside a grid cell is consumed by the cell, not the
  // surrounding flow).
  if preferences.imagePosition == "center" {
    let centred-photo = if photo != none {
      block(width: 100%, align(center, photo))
    }
    let with-qr(content) = if qr == none {
      content
    } else {
      grid(
        columns: (auto, 1fr, auto),
        align: top,
        column-gutter: 1em,
        qr, content, box(width: qr-size),
      )
    }
    let (top, bottom) = if centred-photo == none {
      (header-text, none)
    } else if preferences.imageStackOrder == "above" {
      (centred-photo, header-text)
    } else {
      (header-text, centred-photo)
    }
    with-qr(top)
    if bottom != none {
      v(0.8 * body-size)
      bottom
    }
  } else {
    // Horizontal layout: photo on the requested side, QR opposite.
    // With no portrait, "opposite of imagePosition" still applies —
    // a default (imagePosition: "right") CV with only a QR puts it
    // on the left, matching where it would land if a photo were
    // added later. Dropping absent ornaments (rather than rendering
    // empty cells) avoids an extra 1em column-gutter on the
    // surviving side.
    let (left-ornament, right-ornament) = if (
      preferences.imagePosition == "left"
    ) {
      (photo, qr)
    } else {
      (qr, photo)
    }
    let cells = (
      (left-ornament, auto),
      (header-text, 1fr),
      (right-ornament, auto),
    ).filter(((cell, _)) => cell != none)
    if cells.len() == 1 {
      header-text
    } else {
      grid(
        columns: cells.map(((_, col)) => col),
        align: top,
        column-gutter: 1em,
        ..cells.map(((cell, _)) => cell),
      )
    }
  }
}

// `preferences` is the merged dict from `alta()`, already validated by
// `_validate_preferences` — so the header reads it directly rather than
// re-declaring each pref's default as a kwarg.
#let _header(basics, preferences) = {
  let qr-url = _resolve_qr_url(preferences.qrCode, basics)
  context {
    let body-size = _body_size_state.get()
    let accent = _accent_state.get()
    // 3.5em ≈ small enough to stay out of the way of the contact bar,
    // large enough to remain scannable at typical print DPIs. The QR
    // inherits `accent` so it sits with the rest of the header's
    // coloured ornaments instead of fighting them with pure black.
    let qr-size = 3.5 * body-size
    _header_layout(
      _header_text(basics, preferences, body-size, accent),
      _header_photo(
        basics.at("image", default: none),
        preferences.imageSize,
        basics.name,
      ),
      if qr-url != none { _qr_render(qr-url, qr-size, accent) },
      qr-size,
      body-size,
      preferences,
    )
  }
}

// `basics.summary` rendered as a prose block between the header and
// the first section heading. Silently skipped when absent / empty.
// Lives next to `_header` (not in `sections/`) because it isn't
// dispatched via `_sections`; it's a header peer driven by the same
// `basics` block.
#let _summary(basics) = context {
  let summary = basics.at("summary", default: none)
  if summary == none or summary == "" or summary == [] { return }
  let body-size = _body_size_state.get()
  v(0.8 * body-size)
  par(summary)
  v(0.4 * body-size)
}
