// altacv — a two-column CV template for Typst. Visually descended from
// LianTze Lim's AltaCV LaTeX class (https://github.com/liantze/AltaCV,
// LPPL); forked from George Honeywood's alta-typst
// (https://github.com/GeorgeHoneywood/alta-typst, MIT, © 2023 George
// Honeywood) and rewritten around a JSON Resume-style data dict.
//
// Spacing tokens are em-multipliers of `body-size`, so changing one
// knob scales the document proportionally. The few absolute values
// (page margins, column gutter, rule thicknesses) are visual choices
// independent of text size.

// State set by alta() at render time and read by helpers below.
#let _body_size_state = state("alta-body-size", 10pt)
#let _accent_state = state("alta-accent", rgb("#00796B"))

// Accent is configurable via alta(); the rest are opinionated.
#let _body_colour = rgb("#666666")
#let _emphasis_colour = rgb("#2E2E2E")
#let _empty_dot_colour = rgb("#c0c0c0")
#let _divider_colour = rgb("#D1D1D1")

// Label keys mirror JSON Resume's section keys (`work`, `certificates`,
// …) so callers think in a single vocabulary. The values are editorial:
// "Experience" reads better than "Work" as a CV heading,
// "Certifications" than "Certificates".
#let _default_labels = (
  work: "Experience",
  focusAreas: "Areas of Focus",
  skills: "Skills",
  languages: "Languages",
  education: "Education",
  certificates: "Certifications",
  publications: "Publications",
  awards: "Awards",
  projects: "Projects",
  articles: "Articles",
  present: "Present",
)

// Exported so callers can write `mapsProvider: maps-providers.google`
// rather than the literal URL. `{q}` is substituted with the URL-
// encoded location at render time.
#let maps-providers = (
  google: "https://www.google.com/maps?q={q}",
  apple: "https://maps.apple.com/?q={q}",
  bing: "https://www.bing.com/maps?q={q}",
  duckduckgo: "https://duckduckgo.com/?q={q}&iaxm=maps",
  osm: "https://www.openstreetmap.org/search?query={q}",
)

// Merge user overrides over defaults, panicking on unknown keys so
// typos in `labels` / `preferences` surface as errors instead of being
// silently absorbed.
#let _strict_merge(defaults, overrides, name) = {
  let unknown = overrides.keys().filter(k => k not in defaults)
  if unknown.len() > 0 {
    panic(
      "Unknown " + name + " key(s): " + unknown.join(", ")
        + ". Valid keys: " + defaults.keys().join(", "),
    )
  }
  defaults + overrides
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

// Every SVG ships with fill="#666666" baked in so icon() can colour-
// swap by string replace at call time. Any new icon vendored into
// `icons/` must follow that convention.
#let _utility_icon_sources = (
  calendar: read("icons/calendar.svg"),
  email: read("icons/email.svg"),
  file: read("icons/file.svg"),
  location: read("icons/location.svg"),
  phone: read("icons/phone.svg"),
)
#let _network_icon_sources = (
  bluesky: read("icons/bluesky.svg"),
  github: read("icons/github.svg"),
  gitlab: read("icons/gitlab.svg"),
  link: read("icons/link.svg"),
  linkedin: read("icons/linkedin.svg"),
  mastodon: read("icons/mastodon.svg"),
  medium: read("icons/medium.svg"),
  stackoverflow: read("icons/stackoverflow.svg"),
  twitter: read("icons/twitter.svg"),
  website: read("icons/website.svg"),
)
#let _icon_sources = _utility_icon_sources + _network_icon_sources
#let _profile_networks = _network_icon_sources.keys()

// Maps renamed networks onto the icon we still ship under the old
// name. The lookup happens after `lower(profile.network)`.
#let _network_aliases = (
  x: "twitter",
)

// ─── Public helpers ──────────────────────────────────────────────────

// Measurements default to body-size-relative values so icons scale
// with the surrounding text.
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

// Bold accent-coloured line — designed for the company / institution
// row beneath a role or education entry.
#let name(body) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  block(
    above: 0pt,
    below: 0.6 * body-size,
    text(weight: "bold", fill: accent, body),
  )
}

// Either side may be `none` — the box is skipped, so undated /
// unlocated entries don't emit a stray icon.
#let term(period, location: none) = context {
  if period == none and location == none { return }
  let body-size = _body_size_state.get()
  block(
    above: 0pt,
    below: 0.8 * body-size,
    inset: (left: 0.3 * body-size),
    text(0.9 * body-size, {
      if period != none {
        box(width: 50%, {
          icon("calendar")
          period
        })
      }
      if location != none {
        box(width: 50%, {
          icon("location")
          location
        })
      }
    }),
  )
}

// Half-fill (1.5 → 1 full + 1 half + 3 empty) uses a 50%/50% linear
// gradient — Typst has no native half-circle fill, and a gradient
// produces a sharp boundary where a transparent overlay wouldn't.
//
// LinkedIn-style fluency strings. Numeric `rating` wins over `fluency`
// when an entry supplies both, so callers can opt into fractional
// precision without rewriting their data.
#let _max_rating = 5
#let _fluency_rating = (
  "Native":               5,
  "Bilingual":            5,
  "Full Professional":    4,
  "Professional Working": 3,
  "Limited Working":      2,
  "Elementary":           1,
)
#let _check_rating(rating) = {
  if type(rating) not in (int, float) {
    panic("Rating must be numeric, got: " + repr(rating))
  }
  if rating < 0 or rating > _max_rating {
    panic("Rating out of range: " + repr(rating) + ". Expected 0–" + str(_max_rating) + ".")
  }
  rating
}
#let _resolve_rating(entry) = {
  // Bound to `value` rather than `rating` so the module-scope public
  // `rating()` helper isn't shadowed inside this function.
  let value = entry.at("rating", default: none)
  if value != none { return _check_rating(value) }
  let fluency = entry.at("fluency", default: none)
  if fluency != none {
    if type(fluency) == str and fluency in _fluency_rating { return _fluency_rating.at(fluency) }
    panic("Unknown fluency level: " + repr(fluency) + ". Provide a numeric `rating` instead, or use one of: " + _fluency_rating.keys().join(", "))
  }
  panic("Language entry needs either a `rating` (0–" + str(_max_rating) + ") or a `fluency` string.")
}
#let _half_fill(accent) = gradient.linear(
  (accent, 0%),
  (accent, 50%),
  (_empty_dot_colour, 50%),
  (_empty_dot_colour, 100%),
)
#let rating(label, value) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  let dot-radius = 0.45 * body-size
  let dot-baseline = -0.25 * body-size
  let dot-spacing = 0.4 * body-size

  text(label)
  h(1fr)
  for i in range(1, _max_rating + 1) {
    let fill = if value >= i {
      accent
    } else if value > i - 1 {
      _half_fill(accent)
    } else {
      _empty_dot_colour
    }
    box(baseline: dot-baseline, circle(radius: dot-radius, fill: fill))
    if i != _max_rating { h(dot-spacing) }
  }
  [\ ]
}

// `label: true` is the category-heading variant (darker fill, bold
// text) — used to distinguish a group's leading pill from the item
// pills that follow it on the same row.
#let tag(body, label: false) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  let fill-colour = if label { accent.lighten(70%) } else { accent.lighten(85%) }
  let text-weight = if label { "bold" } else { "regular" }
  box(
    fill: fill-colour,
    stroke: 0.5pt + accent,
    radius: 2.5pt,
    inset: (x: 0.4 * body-size, y: 0.15 * body-size),
    outset: (y: 0.15 * body-size),
    text(0.85 * body-size, fill: accent.darken(15%), weight: text-weight, body),
  )
  h(0.25 * body-size)
}

#let divider() = context {
  let body-size = _body_size_state.get()
  v(0.3 * body-size)
  line(
    length: 100%,
    stroke: (paint: _divider_colour, thickness: 0.6pt, dash: "dashed"),
  )
  v(0.3 * body-size)
}

// Interleaves `divider()` between items; the trailing one is suppressed
// so sections don't end on a stray rule.
#let _join_with_dividers(items, render) = {
  for (i, item) in items.enumerate() {
    render(item)
    if i < items.len() - 1 { divider() }
  }
}

// Accent-coloured italic link — used for publication and project titles.
#let styled-link(dest, content) = context {
  let accent = _accent_state.get()
  emph(text(fill: accent, link(dest, content)))
}

// ─── Section renderers (internal) ────────────────────────────────────

// Returns `none` when neither date is supplied so callers can skip
// emitting the term row, rather than falsely rendering "Present" for
// a fully undated entry.
#let _format_date_range(entry, labels) = {
  let is-empty(v) = v == none or v == ""
  let start = entry.at("startDate", default: none)
  let end = entry.at("endDate", default: none)
  if is-empty(start) and is-empty(end) { return none }
  let end-text = if is-empty(end) { labels.present } else { end }
  if is-empty(start) { [#end-text] } else { [#start – #end-text] }
}

// String-path sources resolve relative to lib.typ (not the user's
// document), so callers should prefer a leading "/" for a root-
// relative path or pass bytes via `read("path", encoding: none)`.
// `fit: "cover"` is what keeps non-square sources from distorting.
#let _portrait(source, size) = box(
  width: size,
  height: size,
  clip: true,
  radius: 50%,
  image(source, fit: "cover", width: 100%, height: 100%),
)

#let _contact_channels = ("email", "phone", "location", "profiles")

// Returns a fully-populated per-channel dict so downstream code can
// always `link-config.at(channel)` without missing-key guards.
#let _resolve_link_config(value) = {
  // Sourcing the channel set from `_contact_channels` keeps adding a
  // fifth channel a one-line change there, not here.
  let all-channels(v) = _contact_channels.fold((:), (acc, c) => acc + ((c): v))
  if type(value) == bool {
    all-channels(value)
  } else if type(value) == dictionary {
    let unknown = value.keys().filter(k => k not in _contact_channels)
    if unknown.len() > 0 {
      let quote(k) = "\"" + k + "\""
      panic(
        "Unknown linkContactInfo channel(s): " + unknown.map(quote).join(", ")
          + ". Supported: " + _contact_channels.map(quote).join(", "),
      )
    }
    // Per-channel values must be bools. Validating up front gives a
    // precise error message anchored to the user's input rather than
    // letting non-bools propagate to the render-time `if` check
    // (which would panic with a generic "expected boolean" message).
    for (k, v) in value.pairs() {
      if type(v) != bool {
        panic(
          "linkContactInfo." + k + " must be a bool, got: " + repr(v),
        )
      }
    }
    all-channels(true) + value
  } else {
    panic(
      "linkContactInfo must be a bool or a dict, got: " + repr(value),
    )
  }
}

#let _header(
  basics,
  image-size: 6em,
  image-position: "right",
  header-text-align: "left",
  link-contact-info: true,
  maps-provider: maps-providers.google,
  uppercase-name: true,
) = {
  if image-position not in ("left", "right") {
    panic("imagePosition must be \"left\" or \"right\", got: " + repr(image-position))
  }
  let text-align = (
    if header-text-align == "left" { left }
    else if header-text-align == "right" { right }
    else if header-text-align == "center" { center }
    else {
      panic(
        "headerTextAlign must be \"left\", \"right\", or \"center\", got: "
          + repr(header-text-align),
      )
    }
  )
  let link-config = _resolve_link_config(link-contact-info)
  context {
    let body-size = _body_size_state.get()
    let accent = _accent_state.get()

    let header-text = align(text-align, {
      block(
        spacing: 0pt,
        below: 1.2 * body-size,
        text(
          2.5 * body-size,
          fill: accent,
          weight: "bold",
          if uppercase-name { upper(basics.name) } else { basics.name },
        ),
      )

      if "label" in basics and basics.label != none {
        block(
          spacing: 0pt,
          below: 0.8 * body-size,
          text(1.2 * body-size, fill: _emphasis_colour, weight: "bold", basics.label),
        )
      }

      set text(0.8 * body-size, weight: "bold")
      let bar-icon = icon.with(size: 0.9 * body-size, shift: 0.2 * body-size, fill: accent)

      let entries = ()
      let email = basics.at("email", default: none)
      if email != none {
        entries.push((
          channel: "email",
          icon: "email",
          value: email,
          url: "mailto:" + email,
        ))
      }
      let phone = basics.at("phone", default: none)
      if phone != none {
        // Strip RFC 3966 visual separators (spaces, parens, hyphens, dots)
        // from the dialable URI; the displayed value keeps them intact.
        let dialable = phone.replace(regex("[\s()\-.]"), "")
        entries.push((
          channel: "phone",
          icon: "phone",
          value: phone,
          url: "tel:" + dialable,
        ))
      }
      let location = basics.at("location", default: none)
      if location != none {
        let url = if maps-provider == none { none } else {
          maps-provider.replace("{q}", _url_encode(location))
        }
        entries.push((
          channel: "location",
          icon: "location",
          value: location,
          url: url,
        ))
      }
      for profile in basics.at("profiles", default: ()) {
        let raw = lower(profile.network)
        let network = _network_aliases.at(raw, default: raw)
        if network not in _profile_networks {
          panic(
            "Unknown profile network: " + repr(profile.network)
              + ". Supported: " + _profile_networks.join(", ")
              + ". To add another, vendor its SVG into icons/ and register it in _network_icon_sources.",
          )
        }
        entries.push((
          channel: "profiles",
          icon: network,
          value: profile.at("username", default: profile.at("url", default: "")),
          url: profile.url,
        ))
      }

      // Each entry is wrapped in `box(...)` so the icon and its
      // display text stay together when the contact bar wraps —
      // line breaks fall on the inter-entry `h(...)` joins, never
      // between an icon and the text it labels.
      entries
        .map(entry => box({
          bar-icon(entry.icon)
          let value = [#entry.value]
          if link-config.at(entry.channel) and entry.url != none {
            link(entry.url, value)
          } else { value }
        }))
        .join(h(1.2 * body-size))
      // Inherits par.spacing, so the gap stays in sync with the rest
      // of the document even when bodySize is tweaked.
      parbreak()
    })

    let image-src = basics.at("image", default: none)
    // Contract is `str` (path) or `bytes`. Both carry `len()`, so an
    // empty path ("") or empty bytes report 0 and skip the frame.
    // Anything else panics with a clear message instead of falling
    // through to a cryptic `image()` failure or — worse — silently
    // dropping the photo (which is what an empty array would do under
    // a bare `.len()` check).
    let has-image = if image-src == none {
      false
    } else if type(image-src) in (str, bytes) {
      image-src.len() > 0
    } else {
      panic(
        "basics.image must be a string path or bytes, got: " + repr(image-src),
      )
    }
    if has-image {
      // Swapping the column order moves the photo to the opposite
      // side without changing the alignment of the text within its
      // column — both branches keep `1fr` on the text side.
      let photo = _portrait(image-src, image-size)
      if image-position == "left" {
        grid(
          columns: (auto, 1fr),
          align: top,
          column-gutter: 1em,
          photo,
          header-text,
        )
      } else {
        grid(
          columns: (1fr, auto),
          align: top,
          column-gutter: 1em,
          header-text,
          photo,
        )
      }
    } else {
      header-text
    }
  }
}

#let _summary(basics) = context {
  let summary = basics.at("summary", default: none)
  if summary == none or summary == [] { return }
  let body-size = _body_size_state.get()
  v(0.8 * body-size)
  par(summary)
  v(0.4 * body-size)
}

#let _experience(work, labels) = if work.len() > 0 [
  == #labels.work

  #_join_with_dividers(work, job => [
    #block(breakable: false)[
      === #job.position
      #name[#job.name]
      #term(_format_date_range(job, labels), location: job.at("location", default: none))

      #for bullet in job.at("highlights", default: ()) [- #bullet]
    ]
  ])
]

#let _focus_areas(items, labels) = if items.len() > 0 [
  == #labels.focusAreas

  #for item in items [- #item]
]

// `text("-")` (not `[-]`) — markup-bracketed `-` parses as a list-item
// bullet. The trailing `h(...)` after the dash mirrors the gap that
// `tag()` already emits to its left, keeping the label pill visually
// centred between its two whitespace gutters.
#let _skills(groups, labels) = if groups.len() > 0 {
  context {
    let body-size = _body_size_state.get()
    let row-gap = 0.7 * body-size
    [== #labels.skills]
    for group in groups {
      let keywords = group.at("keywords", default: ())
      if keywords.len() == 0 { continue }
      block(above: 0pt, below: row-gap, par(hanging-indent: 1em, leading: row-gap, {
        tag(group.name, label: true)
        text("-")
        h(0.25 * body-size)
        for item in keywords { tag(item) }
      }))
    }
  }
}

#let _languages(items, labels) = if items.len() > 0 [
  == #labels.languages

  #_join_with_dividers(items, lang => block(
    breakable: false,
    rating(lang.language, _resolve_rating(lang)),
  ))
]

#let _education(entries, labels) = if entries.len() > 0 [
  == #labels.education

  #_join_with_dividers(entries, edu => [
    #block(breakable: false)[
      #let title = edu.at("studyType", default: edu.at("area", default: ""))
      #if title != "" [=== #title]
      #name[#edu.at("institution", default: "")]
      #term(_format_date_range(edu, labels))

      #if "score" in edu and edu.score != none [#edu.score]
    ]
  ])
]

// Buckets by issuer in insertion order; multi-issuer clusters survive
// as their own group, singletons pool into a trailing "other" group.
// The issuer key is never rendered — it exists purely for grouping.
#let _build_cert_groups(certs) = {
  let by-issuer = (:)
  for cert in certs {
    let issuer = cert.at("issuer", default: "")
    let name = cert.at("name", default: "")
    if name == "" { continue }
    by-issuer.insert(issuer, by-issuer.at(issuer, default: ()) + (name,))
  }
  let groups = ()
  let singletons = ()
  for (_, names) in by-issuer.pairs() {
    if names.len() > 1 { groups.push(names) } else { singletons.push(names.first()) }
  }
  if singletons.len() > 0 { groups.push(singletons) }
  groups
}

#let _certificates(certs, labels, group: true) = {
  if certs.len() == 0 { return }
  // Decide whether to emit the heading *after* filtering — otherwise
  // a list of certs whose `name` is empty would still render a bare
  // "Certifications" heading with nothing under it.
  let groups = if group {
    _build_cert_groups(certs)
  } else {
    let names = certs.map(c => c.at("name", default: "")).filter(n => n != "")
    if names.len() > 0 { (names,) } else { () }
  }
  if groups.len() == 0 { return }
  [== #labels.certificates]
  _join_with_dividers(groups, names => block(
    breakable: false,
    { for n in names [#tag(n)] },
  ))
}

// Rejects `none`, the empty string, and the empty content block —
// the three ways a section field can be effectively absent.
#let _present(v) = v != none and v != "" and v != []

// Follows JSON Resume's `awards[]` shape. Entries without a `title`
// are skipped so a stray entry can't emit an orphan heading.
#let _awards(entries, labels) = {
  let valid = entries.filter(a => _present(a.at("title", default: none)))
  if valid.len() == 0 { return }
  [== #labels.awards]
  _join_with_dividers(valid, award => block(breakable: false, {
    [=== #award.title]
    let awarder = award.at("awarder", default: none)
    if _present(awarder) { name[#awarder] }
    let date = award.at("date", default: none)
    if _present(date) { term(date) }
    let summary = award.at("summary", default: none)
    if _present(summary) { par(summary) }
  }))
}

// Practical subset of JSON Resume's `projects[]`: name, description,
// url, dates, highlights, keywords. `entity`, `type`, `roles` are
// accepted but unrendered (open an issue if you need them). Entries
// without a `name` are skipped to avoid an orphan heading.
#let _projects(entries, labels) = {
  let valid = entries.filter(p => _present(p.at("name", default: none)))
  if valid.len() == 0 { return }
  [== #labels.projects]
  _join_with_dividers(valid, project => block(breakable: false, {
    let title = project.name
    let url = project.at("url", default: none)
    [=== #if url != none { styled-link(url, title) } else { title }]
    let description = project.at("description", default: none)
    if _present(description) {
      // Softer than `name()` (which is bold + accent) so the
      // description doesn't compete visually with a linked title.
      emph(description)
      linebreak()
    }
    term(_format_date_range(project, labels))
    for bullet in project.at("highlights", default: ()) [- #bullet]
    let keywords = project.at("keywords", default: ())
    if keywords.len() > 0 {
      for kw in keywords { tag(kw) }
    }
  }))
}

// `pub.type` is a local extension. The grouping key is rendered
// verbatim as the subheading, so localisers either override
// `labels.articles` (the default for untyped entries) or pre-translate
// the `type` strings. Groups render in first-occurrence order — Typst
// dicts preserve insertion order.
#let _publications(pubs, labels) = if pubs.len() > 0 {
  context {
    let body-size = _body_size_state.get()
    let groups = (:)
    for pub in pubs {
      let key = pub.at("type", default: labels.articles)
      groups.insert(key, groups.at(key, default: ()) + (pub,))
    }
    [== #labels.publications]
    for (group, items) in groups.pairs() [
      ==== #icon("file", size: 1.2 * body-size, shift: 0pt) #group

      #for pub in items [
        #block(breakable: false)[
          #let date = pub.at("releaseDate", default: none)
          #let url = pub.at("url", default: none)
          #let title = pub.at("name", default: "")
          - #if date != none [#text(0.8 * body-size, fill: _body_colour.lighten(35%), date) \ ]
            #if url != none { styled-link(url, title) } else { emph(title) }.
        ]
      ]
    ]
  }
}

// ─── Section catalogue + default preferences ────────────────────────
//
// Single source of truth for the dispatch lookup, default render order,
// and default column membership. Adding a section here is enough to
// place it in the default layout — no parallel order array to keep in
// sync. (Still need to write the renderer and add a label key.)
//
// Defined *after* the section renderers because Typst closures bind
// identifiers eagerly at creation time; insertion order doubles as
// the default render order within each column.
#let _sections = (
  work: (
    column: "left",
    render: (cv, labels, prefs) => _experience(cv.at("work", default: ()), labels),
  ),
  focusAreas: (
    column: "right",
    render: (cv, labels, prefs) => _focus_areas(cv.at("focusAreas", default: ()), labels),
  ),
  skills: (
    column: "right",
    render: (cv, labels, prefs) => _skills(cv.at("skills", default: ()), labels),
  ),
  languages: (
    column: "right",
    render: (cv, labels, prefs) => _languages(cv.at("languages", default: ()), labels),
  ),
  education: (
    column: "right",
    render: (cv, labels, prefs) => _education(cv.at("education", default: ()), labels),
  ),
  certificates: (
    column: "right",
    render: (cv, labels, prefs) => _certificates(
      cv.at("certificates", default: ()),
      labels,
      group: prefs.groupCertificates,
    ),
  ),
  awards: (
    column: "right",
    render: (cv, labels, prefs) => _awards(cv.at("awards", default: ()), labels),
  ),
  projects: (
    column: "right",
    render: (cv, labels, prefs) => _projects(cv.at("projects", default: ()), labels),
  ),
  publications: (
    column: "right",
    render: (cv, labels, prefs) => _publications(cv.at("publications", default: ()), labels),
  ),
)

// Defaults derived from `_sections` so adding a section there
// automatically places it in the default layout for its declared
// column. Insertion order in `_sections` controls render order.
#let _keys_for_column(col) = _sections.keys().filter(k => _sections.at(k).column == col)
#let _default_left_column_sections = _keys_for_column("left")
#let _default_right_column_sections = _keys_for_column("right")

// User-facing reference for these prefs lives in the README. Comments
// below capture only what isn't recoverable from the key name + default
// — non-obvious constraints, footguns, and design rationale.
#let _default_preferences = (
  // Must be installed on the build host (CI installs Lato).
  font: "Lato",
  // Every spacing token is an em-multiplier of this, so changing one
  // knob scales the whole document proportionally.
  bodySize: 10pt,
  paper: "a4",
  margin: (x: 0.9cm, y: 1.5cm),
  accent: rgb("#00796B"),
  groupCertificates: true,
  imageSize: 6em,
  linkContactInfo: true,
  // `{q}` is substituted with the URL-encoded location. A string
  // missing that placeholder panics so a typo is caught up front
  // rather than producing a dead link.
  mapsProvider: maps-providers.google,
  imagePosition: "right",
  headerTextAlign: "left",
  // PDF metadata (title / author) stays as-supplied regardless of
  // this flag — see the comment above `set document(...)`.
  uppercaseName: true,
  // Fraction strictly between 0 and 1 (validated in alta()). Halving
  // it and swapping the column-section arrays gives an inverted layout.
  columnRatio: 0.64,
  // Sections omitted from BOTH arrays don't render even if their data
  // is present; sections listed in both render twice. Defaults derive
  // from `_sections` so adding a section there places it automatically.
  leftColumnSections: _default_left_column_sections,
  rightColumnSections: _default_right_column_sections,
)

// ─── Main template ───────────────────────────────────────────────────
//
// Parameters:
//   cv          — data dict following JSON Resume; see
//                 examples/example.typ for a worked schema.
//   labels      — partial dict; merged over `_default_labels`.
//   preferences — partial dict; merged over `_default_preferences`.
#let alta(
  cv,
  labels: (:),
  preferences: (:),
) = {
  let labels = _strict_merge(_default_labels, labels, "labels")
  let preferences = _strict_merge(_default_preferences, preferences, "preferences")
  let column-ratio = preferences.columnRatio
  if type(column-ratio) not in (int, float) or column-ratio <= 0 or column-ratio >= 1 {
    panic("columnRatio must be a number strictly between 0 and 1, got: " + repr(column-ratio))
  }
  let mp = preferences.mapsProvider
  if mp != none {
    if type(mp) != str {
      panic(
        "mapsProvider must be a URL template string (containing `{q}`) or `none`, got: "
          + repr(mp),
      )
    }
    if "{q}" not in mp {
      panic(
        "mapsProvider URL template must contain the `{q}` placeholder, got: "
          + repr(mp),
      )
    }
  }
  if type(preferences.uppercaseName) != bool {
    panic(
      "uppercaseName must be a bool, got: " + repr(preferences.uppercaseName),
    )
  }
  let accent = preferences.accent
  let body-size = preferences.bodySize
  _accent_state.update(accent)
  _body_size_state.update(body-size)

  // `uppercaseName` is purely visual — PDF metadata stays canonical.
  set document(title: cv.basics.name + " --- CV", author: cv.basics.name)
  set text(body-size, font: preferences.font, fill: _body_colour)
  set page(paper: preferences.paper, margin: preferences.margin)
  set par(leading: 0.55em, spacing: 0.7em)
  set list(
    marker: text(0.85em, "•"),
    indent: 0pt,
    body-indent: 0.4 * body-size,
    spacing: 0.55em,
  )

  // Heading levels map to semantic CV roles:
  //   ==   section title (e.g. Experience)
  //   ===  role / qualification line
  //   ==== sub-grouping (publication type)
  show heading.where(level: 2): it => block(sticky: true)[
    #v(0.6 * body-size)
    #text(1.7 * body-size, fill: accent, weight: "bold", upper(it.body))
    #v(-0.7 * body-size)
    #line(length: 100%, stroke: 2pt + accent)
    #v(0.2 * body-size)
  ]
  show heading.where(level: 3): it => block(
    above: 1.0 * body-size,
    below: 0.8 * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: "regular", it.body),
  )
  show heading.where(level: 4): it => block(
    above: 0.6 * body-size,
    below: 0.6 * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: "bold", it.body),
  )

  _header(
    cv.basics,
    image-size: preferences.imageSize,
    image-position: preferences.imagePosition,
    header-text-align: preferences.headerTextAlign,
    link-contact-info: preferences.linkContactInfo,
    maps-provider: preferences.mapsProvider,
    uppercase-name: preferences.uppercaseName,
  )
  _summary(cv.basics)

  // The same `_sections` dict that derives the column defaults also
  // gates the overrides, so adding a section stays a single-touch
  // change.
  let validate-column(arr, pref-name) = {
    let unknown = arr.filter(k => k not in _sections)
    if unknown.len() > 0 {
      let quote(k) = "\"" + k + "\""
      panic(
        "Unknown " + pref-name + " key(s): " + unknown.map(quote).join(", ")
          + ". Supported: " + _sections.keys().map(quote).join(", "),
      )
    }
  }
  validate-column(preferences.leftColumnSections, "leftColumnSections")
  validate-column(preferences.rightColumnSections, "rightColumnSections")

  // Section renderers are width-agnostic — they fill their container,
  // so the same renderer works whether dropped into the wide or the
  // narrow column.
  let render-column(keys) = {
    for key in keys {
      let entry = _sections.at(key)
      (entry.render)(cv, labels, preferences)
    }
  }

  // Swapping the column-section arrays and inverting `columnRatio`
  // together gives a mirrored layout.
  let gutter = 12pt
  let left-width = column-ratio * 100%
  let right-width = (1 - column-ratio) * 100% - gutter
  grid(
    columns: (left-width, right-width),
    column-gutter: gutter,
    render-column(preferences.leftColumnSections),
    render-column(preferences.rightColumnSections),
  )
}
