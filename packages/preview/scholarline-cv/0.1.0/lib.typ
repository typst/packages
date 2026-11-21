// Scholarline CV — a minimal, customizable academic CV template for Typst. MIT licensed.
//
// Everything is a plugin: the core `cv()` only sets up the page and stores the theme.
// The header, sections, section headings, entry links, and icon table are replaceable
// plugins, and every
// built-in component is written with the same public primitives you can use yourself.
//
// Sections of this file: Theme · Icons · Primitives · Layout · Components.

// ── Theme ──────────────────────────────────────────────────────────────────────

#let default-theme = (
  ink: rgb("#151515"),
  muted: rgb("#666666"),
  rule: rgb("#E6E6E6"),
  // Typst warns once for every listed family that is not installed, so the defaults stay short:
  // Inter for Latin, Noto Sans CJK SC for Chinese (its Latin glyphs also cover a missing Inter).
  font: ("Inter",),
  cjk-font: ("Noto Sans CJK SC",),
  // Inter Display is Inter's large-size cut; the name falls back to `font` without it.
  display-font: ("Inter Display",),
  size: 9.6pt,
  spacing: 1.0,
  paper: "us-letter",
  margin: auto,
  header-align: center,
)

#let resolve-theme(user) = {
  for key in user.keys() {
    if key not in default-theme {
      panic("scholarline-cv: unknown theme key `" + key + "`; valid keys: " + default-theme.keys().join(", "))
    }
  }
  let t = default-theme + user
  if t.margin == auto {
    t.margin = if t.paper == "a4" { (x: 18mm, y: 15mm) } else { (x: 0.7in, y: 0.6in) }
  }
  t
}

// ── Icons ──────────────────────────────────────────────────────────────────────

// SVG sources use stroke="currentColor"; it is replaced by the theme's `muted` colour.
#let builtin-icons = (
  scholar: read("icons/scholar.svg"),
  github: read("icons/github.svg"),
  web: read("icons/web.svg"),
  email: read("icons/email.svg"),
  linkedin: read("icons/linkedin.svg"),
  orcid: read("icons/orcid.svg"),
  phone: read("icons/phone.svg"),
  location: read("icons/location.svg"),
  link: read("icons/link.svg"),
)

// Icons are 0.95em tall and shifted down by (0.95em − 0.72em) / 2, which puts their
// centre on the midline of Inter's cap height so they sit centred on the text line.
#let icon-height = 0.95em
#let icon-shift = 0.115em

// ── Primitives ─────────────────────────────────────────────────────────────────

// Plugin slots hold `auto` (use the built-in default) or a function; see `cv()`.
#let cv-state = state("scholarline-cv", (
  theme: resolve-theme((:)),
  icons: builtin-icons,
  section: auto,
  links: auto,
))

/// The resolved theme dictionary. Call inside `context`.
#let cv-theme() = cv-state.get().theme

/// A built-in or plugin icon by name, tinted and centred; other content is returned as-is.
#let cv-icon(spec) = {
  if spec == none or type(spec) != str { return spec }
  context {
    let icons = cv-state.get().icons
    if spec not in icons {
      panic("scholarline-cv: unknown icon `" + spec + "`; available icons: " + icons.keys().join(", "))
    }
    let svg = icons.at(spec).replace("currentColor", cv-theme().muted.to-hex())
    box(baseline: icon-shift, image(bytes(svg), format: "svg", height: icon-height))
  }
}

/// Semibold entry title.
#let entry-title(body) = context text(size: cv-theme().size * 1.04, weight: "semibold", body)

/// Muted metadata text (dates, roles, authors). `none` stays `none`.
#let entry-meta(body) = if body != none {
  context text(size: cv-theme().size * 0.94, fill: cv-theme().muted, body)
}

/// Joins the non-`none` parts with " · "; returns `none` when nothing is left.
#let dot-join(parts) = parts.filter(p => p != none).join[ · ]

/// Small uppercase, letter-spaced label used for section titles.
/// Chinese has no capitals, so `lang: "zh"` gets a slightly larger, tighter label instead.
#let section-label(title) = context {
  let zh = text.lang == "zh"
  text(
    size: cv-theme().size * if zh { 0.96 } else { 0.86 },
    weight: "semibold",
    tracking: if zh { 0.04em } else { 0.09em },
    upper(title),
  )
}

/// Soft underline used for clickable text; its colour follows the theme's `muted`.
#let soft-underline(body) = context underline(stroke: 0.6pt + cv-theme().muted.lighten(55%), offset: 3pt, body)

/// Default links plugin: muted `label ↗` links (L3).
#let default-links(links) = for item in links {
  h(0.6em)
  link(item.url, entry-meta[#item.label#h(0.12em)↗])
}

/// Alternative links plugin: muted labels with a soft underline (L2).
#let underline-links(links) = for item in links {
  h(0.6em)
  link(item.url, soft-underline(entry-meta(item.label)))
}

/// Entry links from an array of `(label:, url:)` dictionaries, styled by the `links` plugin.
#let entry-links(links) = if links.len() > 0 {
  context {
    let plugin = cv-state.get().links
    if plugin == auto { default-links(links) } else { plugin(links) }
  }
}

/// The shared two-column entry: `lines` on the left, muted `aside` rows on the right,
/// then an optional `body`. `none` rows are dropped without
/// leaving a gap, and single-line entries (awards, short items) use a tighter rhythm.
#let entry(lines, aside: (), body: none) = context {
  let t = cv-theme()
  let s = t.spacing
  let lines = lines.filter(x => x != none)
  // Tabular figures line up dates in the right column. They stay out of other muted text:
  // in Inter they also widen hyphens, which would split names such as "Wen-Jie".
  let aside = aside.filter(x => x != none).map(x => entry-meta(text(number-width: "tabular", x)))
  let single = lines.len() <= 1 and aside.len() <= 1 and body == none
  let gap = if single { 6pt * s } else { 10pt * s }
  let cells = ()
  for i in range(calc.max(lines.len(), aside.len())) {
    cells.push(lines.at(i, default: []))
    cells.push(aside.at(i, default: []))
  }
  block(above: gap, below: gap, width: 100%, {
    grid(
      columns: (1fr, auto),
      column-gutter: 12pt,
      row-gutter: 5pt * s,
      align: (start + horizon, end + horizon),
      ..cells,
    )
    // A little extra air separates the who/when block from the description.
    if body != none { block(above: 8pt * s, body) }
  })
}

// ── Layout ─────────────────────────────────────────────────────────────────────

#let contact(label, url, icon: none) = (label: label, url: url, icon: icon)

#let contact-item(item) = context box({
  let icon = item.at("icon", default: none)
  if icon != none {
    cv-icon(icon)
    h(0.35em)
  }
  link(item.url, soft-underline(item.label))
})

/// Default header plugin: centred name, muted subtitle, and an icon-led contact row.
#let default-header(name, subtitle, contacts) = context {
  let t = cv-theme()
  let s = t.spacing
  let rows = (text(font: t.display-font + t.font + t.cjk-font, size: t.size * 2.4, weight: "bold", tracking: -0.02em, name),)
  if subtitle != none {
    rows += (6pt * s, text(fill: t.muted, subtitle))
  }
  if contacts.len() > 0 {
    // Icons already lead each item, so plain space separates them instead of `·`.
    rows += (10pt * s, contacts.map(contact-item).join(h(1.3em)))
  }
  block(width: 100%, above: 0pt, below: 0pt, {
    set align(t.header-align)
    stack(dir: ttb, ..rows, 16pt * s, line(length: 100%, stroke: 0.5pt + t.rule))
  })
}

/// Default heading plugin: a small uppercase label over a full-width hairline.
#let default-heading(title) = context {
  let t = cv-theme()
  let s = t.spacing
  block(sticky: true, above: 22pt * s, below: 10pt * s, width: 100%, stack(
    dir: ttb,
    spacing: 6pt * s,
    section-label(title),
    line(length: 100%, stroke: 0.5pt + t.rule),
  ))
}

/// Default section plugin: a level-2 heading (styled by the `heading` plugin) followed by the body.
#let default-section(title, body) = {
  heading(level: 2, outlined: false, title)
  body
}

#let section-counter = counter("scholarline-cv-section")

/// Alternative section plugin: label in a left margin column, content on the right,
/// and a hairline between sections. The heading stays a real heading for PDF bookmarks.
#let margin-section(title, body) = {
  section-counter.step()
  context {
    let t = cv-theme()
    let s = t.spacing
    // The header's own rule already separates it from the first section.
    if section-counter.get().first() > 1 {
      block(above: 16pt * s, below: 0pt, line(length: 100%, stroke: 0.5pt + t.rule))
    }
    block(above: 0pt, below: 0pt, grid(
      columns: (20%, 1fr),
      column-gutter: 14pt,
      pad(top: 11.5pt * s, {
        show heading: it => section-label(it.body)
        heading(level: 2, outlined: false, title)
      }),
      pad(top: 10pt * s, body),
    ))
  }
}

#let default-plugins = (header: auto, heading: auto, section: auto, links: auto, icons: (:))

#let cv(
  name: "Your Name",
  subtitle: none,
  contacts: (),
  lang: "en",
  theme: (:),
  plugins: (:),
  body,
) = {
  if lang not in ("en", "zh") {
    panic("scholarline-cv: lang must be `en` or `zh`, got `" + str(lang) + "`")
  }
  for key in plugins.keys() {
    if key not in default-plugins {
      panic("scholarline-cv: unknown plugin `" + key + "`; valid plugins: " + default-plugins.keys().join(", "))
    }
  }
  let t = resolve-theme(theme)
  let p = default-plugins + plugins
  let header = if p.header == auto { default-header } else { p.header }
  let heading-fn = if p.heading == auto { default-heading } else { p.heading }
  let s = t.spacing

  set page(paper: t.paper, margin: t.margin)
  set text(
    font: t.font + t.cjk-font,
    size: t.size,
    fill: t.ink,
    lang: lang,
    region: if lang == "zh" { "cn" } else { none },
    cjk-latin-spacing: auto,
  )
  let leading = if lang == "zh" { 0.85em } else { 0.75em }
  set par(leading: leading, spacing: 4pt * s)
  set block(spacing: 4pt * s)
  // Items sit slightly further apart than wrapped lines, so a long bullet never blends into the next.
  set list(marker: text(fill: t.muted)[•], indent: 0pt, body-indent: 0.5em, spacing: leading + 2pt * s)
  show heading.where(level: 2): it => heading-fn(it.body)

  cv-state.update((theme: t, icons: builtin-icons + p.icons, section: p.section, links: p.links))
  header(name, subtitle, contacts)
  body
}

/// A CV section, laid out by the `section` plugin.
#let section(title, body) = context {
  let plugin = cv-state.get().section
  if plugin == auto { default-section(title, body) } else { plugin(title, body) }
}

// ── Components ─────────────────────────────────────────────────────────────────
// Built-in components use only the public primitives above; write your own the same way.

#let education(institution: "", degree: none, dates: none, location: none, details: none, body: none) = entry(
  (entry-title(institution), degree, entry-meta(details)),
  aside: (dates, location),
  body: body,
)

#let experience(institution: "", role: none, advisor: none, dates: none, location: none, body: none) = entry(
  (entry-title(institution), entry-meta(dot-join((role, advisor)))),
  aside: (dates, location),
  body: body,
)

#let publication(title: "", authors: none, venue: none, links: (), note: none) = entry((
  [#entry-title(title)#entry-links(links)],
  entry-meta(dot-join((authors, venue))),
  entry-meta(note),
))

#let project(name: "", role: none, tech: none, dates: none, links: (), body: none) = entry(
  ([#entry-title(name)#entry-links(links)], entry-meta(dot-join((role, tech)))),
  aside: (dates,),
  body: body,
)

#let award(name: "", date: none) = entry((name,), aside: (date,))

#let skill-line(label: "", items: []) = context {
  let s = cv-theme().spacing
  block(above: 6pt * s, below: 6pt * s, grid(
    columns: (10.5em, 1fr),
    column-gutter: 12pt,
    text(fill: cv-theme().muted, label),
    items,
  ))
}
