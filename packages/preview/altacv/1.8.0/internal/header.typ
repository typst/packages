// Header — every above-the-grid surface: name, pronouns, label,
// contact bar and optional portrait and QR from `basics`, then the
// `_intro` lines (`objective`, `basics.summary`). Preference shapes
// are validated up front in `validation.typ`; cv fields are checked
// here, where they're consumed.

#import "state.typ": (
  _accent_state, _body_colour, _body_size_state, _emphasis_colour,
)
#import "icons.typ": _network_aliases, _profile_networks, icon
#import "qr.typ": _qr_render, _resolve_qr_url
#import "text.typ": _field, _join_present, _present
#import "primitives.typ": _preamble
#import "validation.typ": _check_type, _contact_channels
#import "location.typ": _format_location

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

// `image()` resolves bare string paths at THIS file, which lives in
// the @preview cache for installed users; `path` and `bytes` sources
// let callers anchor resolution at their own .typ. `alt` becomes the
// image's `/Alt` in tagged PDF output.
#let _portrait(source, size, alt) = box(
  width: size,
  height: size,
  clip: true,
  radius: 50%,
  image(source, fit: "cover", width: 100%, height: 100%, alt: alt),
)

// Fully populated per channel, so callers can `link-config.at(channel)`
// without missing-key guards.
#let _resolve_link_config(value) = {
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
    // The value is usually a bare username, so the icon is the only
    // thing naming the network. The user's own string, not the
    // lowercased key, keeps their capitalisation ("GitHub").
    alt: profile.network,
    // A profile without `url` renders unlinked rather than failing.
    value: profile.at("username", default: profile.at("url", default: "")),
    url: profile.at("url", default: none),
  )
}

// The contact bar's entries in display order, one
// `(channel, icon, value, url)` dict per present field; `channel` keys
// into the resolved `linkContactInfo` config. Pure data, no `context`.
// An empty string counts as absent, so it never renders a bare icon
// behind a dead `mailto:` / `tel:` link.
#let _contact_entries(basics, maps-provider) = {
  let email = _field(basics, "email")
  let phone = _field(basics, "phone")
  // One collapsed value feeds both display and maps link, so they
  // cannot drift.
  let location = _format_location(
    basics.at("location", default: none),
    "basics.location",
  )
  let url = _field(basics, "url")
  let fields = (
    if email != none {
      (channel: "email", icon: "email", value: email, url: "mailto:" + email)
    },
    if phone != none {
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
    if url != none { (channel: "url", icon: "link", value: url, url: url) },
  ).filter(e => e != none)
  fields + basics.at("profiles", default: ()).map(_profile_entry)
}

// Takes the resolved `body-size` / `accent` so `_header` owns the
// single `context` read.
#let _header_text(basics, preferences, body-size, accent) = {
  let link-config = _resolve_link_config(preferences.linkContactInfo)
  let headline = _field(basics, "label")
  let pronouns = _field(basics, "pronouns")
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
      {
        text(
          2.5 * body-size,
          fill: accent,
          weight: "bold",
          if preferences.uppercaseName { upper(basics.name) } else {
            basics.name
          },
        )
        // Outside `upper(...)`: pronouns aren't part of the name. The
        // `box` keeps "(they/them)" whole when a long name wraps.
        if preferences.showPronouns and pronouns != none {
          h(0.5 * body-size)
          box(text(body-size, fill: _body_colour, [(#pronouns)]))
        }
      },
    )

    if headline != none {
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
    // `box` per entry so the bar wraps between entries, never between
    // an icon and its text.
    _contact_entries(basics, preferences.mapsProvider)
      .map(entry => box({
        bar-icon(entry.icon, alt: entry.at("alt", default: none))
        let value = [#entry.value]
        if link-config.at(entry.channel) and entry.url != none {
          link(entry.url, value)
        } else { value }
      }))
      .join(h(1.2 * body-size))
    // Inherits `par.spacing`, so the gap tracks the rest of the document.
    parbreak()
  })
}

// A `path` can't be empty; an empty `str` / `bytes` skips the frame.
// Other types panic here rather than as a cryptic `image()` failure.
// `alt` is the person's name: language-neutral, so no label key.
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

// `photo` and `qr` are `none` when absent.
#let _header_layout(header-text, photo, qr, qr-size, body-size, preferences) = {
  // Full-width `block` centres the photo against the page (a bare
  // `align(center, box)` centres against the inline position). The
  // `qr-size` spacer balances the QR so the content stays centred
  // page-wise. Only the top row gets the QR grid, so the QR stays at
  // the header's top corner whichever way the stack runs. The row gap
  // is an explicit `v(...)` because block spacing inside a grid cell
  // is consumed by the cell.
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
    // QR goes opposite `imagePosition` even with no photo, so adding
    // one later doesn't move it. Absent ornaments are dropped rather
    // than left as empty cells, which would add a stray gutter.
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

// `preferences` is the merged, validated dict from `alta()`.
#let _header(basics, preferences) = {
  let qr-url = _resolve_qr_url(preferences.qrCode, basics)
  context {
    let body-size = _body_size_state.get()
    let accent = _accent_state.get()
    // Small enough to stay clear of the contact bar, large enough to
    // scan in print. Filled with `accent` to match the other ornaments.
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

// The CV's root `objective` (JSON Resume 1.4.0, a forward-looking
// goal), then `basics.summary` (background), between the header and
// the first section; either alone keeps the summary's spacing. The
// objective is set off like a pull quote — italic, behind a thin
// accent rule — so it reads apart from the summary without being
// louder than it, in colour or in a black-and-white print.
// Lives here, not in `sections/`: it isn't dispatched via `_sections`.
#let _intro(cv) = {
  let objective = cv.at("objective", default: none)
  _check_type(
    "objective",
    objective,
    (str, content, type(none)),
    "a string or content",
  )
  let summary = _field(cv.basics, "summary")
  if _present(objective) or summary != none {
    context {
      let body-size = _body_size_state.get()
      let goal = _preamble(objective)
      v(0.8 * body-size)
      _join_present(
        (
          if goal != none {
            block(
              stroke: (left: 1.5pt + _accent_state.get()),
              inset: (left: 0.7 * body-size, y: 0.15 * body-size),
              goal,
            )
          },
          if summary != none { par(summary) },
        ),
        v(0.3 * body-size),
      )
      v(0.4 * body-size)
    }
  }
}
