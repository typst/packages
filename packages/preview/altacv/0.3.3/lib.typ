// altacv — a two-column CV template for Typst, inspired by LianTze
// Lim's AltaCV LaTeX class (https://github.com/liantze/AltaCV, LPPL).
// Forked from George Honeywood's alta-typst
// (https://github.com/GeorgeHoneywood/alta-typst, MIT, © 2023 George
// Honeywood) and rewritten around a JSON Resume-style data dict, with
// a `preferences` extension point for theme + behaviour toggles and a
// `labels` extension point for i18n / localisation.
//
// Public API:
//   alta(cv, ...config)  — render the document from a cv data dict
//                          (schema follows JSON Resume — see the
//                          example in examples/example.typ).
//   Helpers (icon, name, term, skill, tag, divider, styled-link) are
//   also exported for callers who want to compose custom layouts.
//
// Design tokens (spacing, dot sizes, etc.) are derived from `body-size`
// via em-multipliers, so changing body size scales the document
// proportionally. The few absolute values (page margins, column
// gutter, rule thicknesses) are physical / visual choices independent
// of text size.

// ─── State (set by alta() at render time) ─────────────────────────────
#let _body_size_state = state("alta-body-size", 10pt)
#let _accent_state = state("alta-accent", rgb("#00796B"))

// ─── Internal palette ────────────────────────────────────────────────
// Accent is configurable via alta(); body/emphasis are opinionated.
#let _body_colour = rgb("#666666")
#let _emphasis_colour = rgb("#2E2E2E")
#let _empty_dot_colour = rgb("#c0c0c0")
#let _divider_colour = rgb("#D1D1D1")

// ─── Default labels (English) ────────────────────────────────────────
// All display strings the template emits. Callers can override any
// subset via the `labels` parameter on alta() — supplied keys win, the
// rest fall back to these defaults. Allows translation (Spanish,
// French, German, ...) or local renaming (e.g. "Experience" →
// "Work History") without forking the template.
#let _default_labels = (
  experience: "Experience",
  focusAreas: "Areas of Focus",
  skills: "Skills",
  languages: "Languages",
  education: "Education",
  certifications: "Certifications",
  publications: "Publications",
  articles: "Articles",
  present: "Present",
)

// ─── Default preferences ─────────────────────────────────────────────
// Theme + behaviour configuration for the template. Callers override
// any subset via the `preferences` parameter on alta(); supplied keys
// win, the rest fall back to these defaults. Page geometry (font,
// body-size, paper, margin, column-ratio) remains as top-level alta()
// arguments since those are layout primitives rather than soft
// preferences.
#let _default_preferences = (
  // Theme colour applied to headings, accent rules, tag borders and
  // skill-dot fills.
  accent: rgb("#00796B"),
  // When true, certificates are grouped by issuer (issuers with 2+
  // certs become their own group; singletons pool into a final "other"
  // group). When false, certificates render as a single flat row.
  groupCertificates: true,
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

// Percent-encode a string for use in URL query / path components, per
// RFC 3986. Bytes outside the unreserved set (ALPHA / DIGIT / -._~)
// are emitted as %HH; multi-byte UTF-8 codepoints encode each byte
// separately so accented or non-Latin locations (e.g. "Zürich") round-
// trip correctly.
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

// std.target() is absent in paged-only builds; fall back to "paged".
#let target() = {
  if "target" in dictionary(std) { std.target() } else { "paged" }
}

// Vendored icons. SVGs ship with fill="#666666" baked in; icon() swaps
// it at call time. Utility icons drive the contact bar / term row /
// publication list; the rest are network icons available to profiles.
#let _utility_icons = ("calendar", "email", "file", "location", "phone")
#let _icon_sources = (
  calendar: read("icons/calendar.svg"),
  email: read("icons/email.svg"),
  file: read("icons/file.svg"),
  location: read("icons/location.svg"),
  phone: read("icons/phone.svg"),
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
#let _profile_networks = _icon_sources.keys().filter(k => k not in _utility_icons)

// ─── Public helpers ──────────────────────────────────────────────────

// Icon helper. Renders a vendored SVG in a fixed-size box.
//
// All measurements default to body-size-relative values so icons scale
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
  let body = box(
    baseline: resolved-shift,
    width: resolved-size,
    height: resolved-size,
    align(
      center + horizon,
      image(bytes(coloured), format: "svg", height: 0.9 * resolved-size),
    ),
  )
  if target() == "paged" {
    body
    h(0.3 * body-size)
  } else {
    html.frame(body)
  }
}

// Company / institution line under a role/education entry.
// Bold in the accent colour.
#let name(body) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  if target() == "paged" {
    block(
      above: 0pt,
      below: 0.6 * body-size,
      text(weight: "bold", fill: accent, body),
    )
  } else {
    html.div(class: "name", text(weight: "bold", fill: accent, body))
  }
}

// Date + optional location row, rendered as two left-aligned half-width
// boxes — period on the left, location on the right. Either side may
// be omitted (`none`); the box is skipped so undated/unlocated entries
// don't emit a stray icon.
#let term(period, location: none) = context {
  if period == none and location == none { return }
  let body-size = _body_size_state.get()
  if target() == "paged" {
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
  } else {
    html.div(
      style: "display: flex; align-items: center; gap: 10px;",
      {
        if period != none {
          icon("calendar")
          html.div(period)
        }
        if location != none {
          icon("location")
          html.div(location)
        }
      },
    )
  }
}

// Language / skill row — name on the left, N filled dots on the right.
// Supports fractional ratings (e.g. 1.5 → 1 full + 1 half + 3 empty);
// the half-fill uses a 50%/50% linear gradient for a sharp boundary.
//
// _fluency_rating maps LinkedIn-style fluency labels to dot counts.
// Callers can pass `rating` directly for fractional precision, or
// `fluency` for a named level (rating wins if both are present).
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
  let rating = entry.at("rating", default: none)
  if rating != none { return _check_rating(rating) }
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
#let skill(name, rating) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  let dot-radius = 0.45 * body-size
  let dot-baseline = -0.25 * body-size
  let dot-spacing = 0.4 * body-size

  let dots = {
    for i in range(1, _max_rating + 1) {
      let fill = if rating >= i {
        accent
      } else if rating > i - 1 {
        _half_fill(accent)
      } else {
        _empty_dot_colour
      }
      let dot = box(baseline: dot-baseline, circle(radius: dot-radius, fill: fill))
      if target() == "paged" {
        dot
        if i != _max_rating { h(dot-spacing) }
      } else {
        html.frame(dot)
      }
    }
  }

  if target() == "paged" {
    text(name)
    h(1fr)
    dots
    [\ ]
  } else {
    html.div(
      style: "display: flex; align-items: center; gap: 5px; max-width: 200px; justify-content: space-between;",
      {
        text(name)
        html.span(
          style: "display: flex; gap: 5px; align-items: center;",
          dots,
        )
      },
    )
  }
}

// Pill tag for skills / certifications.
//
// `label: true` gives a subtly emphasised variant for category labels
// (darker fill, bold text). Useful for distinguishing a group heading
// pill from the items that follow it on the same row.
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

// Dashed grey divider between entries within a section.
#let divider() = context {
  let body-size = _body_size_state.get()
  v(0.3 * body-size)
  line(
    length: 100%,
    stroke: (paint: _divider_colour, thickness: 0.6pt, dash: "dashed"),
  )
  v(0.3 * body-size)
}

// Render each item via `render`, interleaving divider() between
// consecutive items. Trailing divider is suppressed.
#let _join_with_dividers(items, render) = {
  for (i, item) in items.enumerate() {
    render(item)
    if i < items.len() - 1 { divider() }
  }
}

// Accented underlined italic link — used for publication titles.
#let styled-link(dest, content) = context {
  let accent = _accent_state.get()
  emph(text(fill: accent, link(dest, content)))
}

// ─── Section renderers (internal) ────────────────────────────────────
//
// Each takes the relevant slice of the cv dict and emits the
// corresponding rendered section. Kept private to the module so the
// public API surface stays small.

// Returns content for the date range, or `none` when neither date is
// supplied (so callers can skip emitting the term row entirely instead
// of falsely rendering "Present" for a fully undated entry).
#let _format_date_range(entry, labels) = {
  let is-empty(v) = v == none or v == ""
  let start = entry.at("startDate", default: none)
  let end = entry.at("endDate", default: none)
  if is-empty(start) and is-empty(end) { return none }
  let end-text = if is-empty(end) { labels.present } else { end }
  if is-empty(start) { [#end-text] } else { [#start – #end-text] }
}

#let _header(basics) = {
  context {
    let body-size = _body_size_state.get()
    let accent = _accent_state.get()

    block(
      spacing: 0pt,
      below: 1.2 * body-size,
      text(2.5 * body-size, fill: accent, weight: "bold", upper(basics.name)),
    )

    if "label" in basics and basics.label != none {
      block(
        spacing: 0pt,
        below: 0.8 * body-size,
        text(1.2 * body-size, fill: _emphasis_colour, weight: "bold", basics.label),
      )
    }

    if target() == "paged" {
      set text(0.8 * body-size, weight: "bold")
      let bar-icon = icon.with(size: 0.9 * body-size, shift: 0.2 * body-size, fill: accent)

      // Build the contact bar: email, phone, location (from basics
      // top-level), then any profiles (LinkedIn, Medium, etc.).
      let entries = ()
      let email = basics.at("email", default: none)
      if email != none {
        entries.push((icon: "email", value: email, url: "mailto:" + email))
      }
      let phone = basics.at("phone", default: none)
      if phone != none {
        entries.push((
          icon: "phone",
          value: phone,
          url: "tel:" + phone.replace(" ", ""),
        ))
      }
      let location = basics.at("location", default: none)
      if location != none {
        entries.push((
          icon: "location",
          value: location,
          url: "https://www.google.com/maps?q=" + _url_encode(location),
        ))
      }
      for profile in basics.at("profiles", default: ()) {
        let network = lower(profile.network)
        if network not in _profile_networks {
          panic(
            "Unknown profile network: " + repr(profile.network)
              + ". Supported: " + _profile_networks.join(", ")
              + ". To add another, vendor its SVG into icons/ and register it in _icon_sources.",
          )
        }
        entries.push((
          icon: network,
          value: profile.at("username", default: profile.at("url", default: "")),
          url: profile.url,
        ))
      }

      entries
        .map(entry => {
          bar-icon(entry.icon)
          link(entry.url)[#entry.value]
        })
        .join(h(1.2 * body-size))
      [

      ]
    }
  }
}

#let _summary(basics) = context {
  let body-size = _body_size_state.get()
  v(0.8 * body-size)
  par(basics.at("summary", default: []))
  v(0.4 * body-size)
}

#let _experience(work, labels) = if work.len() > 0 [
  == #labels.experience

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

// Group name renders as the leftmost pill, styled distinctly so it
// reads as a category, with a "-" separator between the label and the
// items. tag()'s trailing h(...) gives space before the dash; the
// h(...) below balances the gap on the right. text("-") rather than
// `[-]` so Typst doesn't parse the hyphen as a list-item bullet.
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
    skill(lang.language, _resolve_rating(lang)),
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

// Bucket certs by issuer (insertion order preserved), then split into
// multi-issuer groups + a trailing pool of singletons. Returns an
// array of arrays of cert names — the issuer key is only used for
// grouping and never rendered.
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

#let _certificates(certs, labels, group: true) = if certs.len() > 0 {
  let groups = if group {
    _build_cert_groups(certs)
  } else {
    (certs.map(c => c.at("name", default: "")).filter(n => n != ""),)
  }
  [== #labels.certifications]
  _join_with_dividers(groups, names => block(
    breakable: false,
    { for n in names [#tag(n)] },
  ))
}

// Group publications by `pub.type` (a local extension to JSON Resume).
// Entries without `type` fall under `labels.articles` so a CV of plain
// blog posts renders as before. The grouping key is used verbatim as
// the subheading, so users localising the section can either override
// `labels.articles` (for the default) or supply already-translated
// `type` strings directly. Typst dicts preserve insertion order, so
// groups render in first-occurrence order.
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

// ─── Main template ───────────────────────────────────────────────────
//
// alta(cv, ...config) renders the document from a cv data dict.
//
// Parameters:
//   cv            — data dict; see examples/example.typ for the schema
//                   (follows JSON Resume — https://jsonresume.org/).
//   font          — primary font family. Must be installed.
//   body-size     — base text size. Every spacing and sub-element size
//                   derives from this via em-multipliers, so changing
//                   it scales the document proportionally.
//   paper         — page format (a4, us-letter, …).
//   margin        — page margin dict.
//   column-ratio  — left/right column width split. The default (0.64)
//                   gives the experience column slightly more room
//                   than the side panel; tune to taste.
//   labels        — partial dict overriding the template's English
//                   display strings (section headings, "Present" date
//                   literal). Supply only the keys you want to change;
//                   the rest fall back to _default_labels.
//   preferences   — partial dict of theme + behaviour toggles. See
//                   _default_preferences for available keys (e.g.
//                   accent, groupCertificates). Supplied keys win, the
//                   rest fall back to defaults.
#let alta(
  cv,
  font: "Lato",
  body-size: 10pt,
  paper: "a4",
  margin: (x: 0.9cm, y: 1.5cm),
  column-ratio: 0.64,
  labels: (:),
  preferences: (:),
) = {
  let labels = _strict_merge(_default_labels, labels, "labels")
  let preferences = _strict_merge(_default_preferences, preferences, "preferences")
  let accent = preferences.accent
  _accent_state.update(accent)
  _body_size_state.update(body-size)

  set document(title: cv.basics.name + " --- CV", author: cv.basics.name)
  set text(body-size, font: font, fill: _body_colour)
  set page(paper: paper, margin: margin)
  set par(leading: 0.55em, spacing: 0.7em)
  set list(
    marker: text(0.85em, "•"),
    indent: 0pt,
    body-indent: 0.4 * body-size,
    spacing: 0.55em,
  )

  // Section heading (==): bold uppercase in accent + 2pt rule.
  show heading.where(level: 2): it => block(sticky: true)[
    #v(0.6 * body-size)
    #text(1.7 * body-size, fill: accent, weight: "bold", upper(it.body))
    #v(-0.7 * body-size)
    #line(length: 100%, stroke: 2pt + accent)
    #v(0.2 * body-size)
  ]
  // Role / qualification line (===): emphasis colour, regular weight.
  show heading.where(level: 3): it => block(
    above: 1.0 * body-size,
    below: 0.8 * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: "regular", it.body),
  )
  // Subsection (====): bold in emphasis colour.
  show heading.where(level: 4): it => block(
    above: 0.6 * body-size,
    below: 0.6 * body-size,
    sticky: true,
    text(1.2 * body-size, fill: _emphasis_colour, weight: "bold", it.body),
  )

  // Header (name / label / contact bar) + summary.
  _header(cv.basics)
  _summary(cv.basics)

  // Asymmetric two-column body via grid.
  let gutter = 12pt
  let left-width = column-ratio * 100%
  let right-width = (1 - column-ratio) * 100% - gutter
  grid(
    columns: (left-width, right-width),
    column-gutter: gutter,
    _experience(cv.at("work", default: ()), labels),
    {
      _focus_areas(cv.at("focusAreas", default: ()), labels)
      _skills(cv.at("skills", default: ()), labels)
      _languages(cv.at("languages", default: ()), labels)
      _education(cv.at("education", default: ()), labels)
      _certificates(cv.at("certificates", default: ()), labels, group: preferences.groupCertificates)
      _publications(cv.at("publications", default: ()), labels)
    },
  )
}
