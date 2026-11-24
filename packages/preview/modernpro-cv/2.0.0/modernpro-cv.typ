///////////////////////////////
// modernpro-cv.typ
// A clean, modern academic CV template
// Copyright (c) 2026
// Author:  Academic Template Collective
// License: MIT
// Version: 2.0.0
// Date:    2026-07-30
// Email:   maintainers@example.invalid
///////////////////////////////

// Shared design tokens for the academic suite: one serif family, two weights,
// a restrained size ladder, four colours, and one rhythm system. Keep this block in sync with
// modernpro-coverletter.typ so a CV and a letter read as one document set.
#let default-cv-style = (
  text: rgb("#1f2933"),
  muted: rgb("#667085"),
  heading: rgb("#1f2933"),
  subheading: rgb("#1f2933"),
  accent: rgb("#1e3a5f"),
  rule: rgb("#dde3ea"),

  heading-font: ("PT Serif", "Libertinus Serif"),
  name-size: 18pt,
  item-title-size: 10.5pt,
  role-size: 10.5pt,
  section-size: 9.8pt,
  body-size: 10pt,
  meta-size: 9.8pt,
  address-size: 9.8pt,
  reference-size: 9.8pt,
  small-size: 8.8pt,
  contact-size: 8.8pt,
  footer-size: 8.4pt,
  contact-icon-size: 7.6pt,
  contact-icon-width: 9pt,
  contact-icon-gap: 4pt,

  section-gap: 1.08em,
  section-content-gap: 0.7em,
  item-gap: 0.98em,
  entry-row-gap: 0.58em,
  description-gap: 0.66em,
  header-row-gap: 2.4pt,
  header-rule-gap: 6pt,
  header-content-gap: 10pt,
  body-leading: 0.66em,
  list-spacing: 0.3em,
  rule-stroke: 0.4pt,
  section-tracking: 0.08em,
)

// One setting controls the document's vertical rhythm. Individual layout keys
// can still override a preset when a document needs a local adjustment.
#let cv-rhythm(preset) = if preset == "compact" {
  (
    section-gap: 0.72em,
    section-content-gap: 0.38em,
    item-gap: 0.62em,
    entry-row-gap: 0.3em,
    description-gap: 0.36em,
    header-row-gap: 1.8pt,
    header-rule-gap: 4.8pt,
    header-content-gap: 7pt,
    body-leading: 0.58em,
    list-spacing: 0.2em,
  )
} else if preset == "relaxed" or preset == "spacious" {
  (
    section-gap: 1.3em,
    section-content-gap: 0.82em,
    item-gap: 1.2em,
    entry-row-gap: 0.68em,
    description-gap: 0.76em,
    header-row-gap: 3pt,
    header-rule-gap: 7pt,
    header-content-gap: 11pt,
    body-leading: 0.74em,
    list-spacing: 0.32em,
  )
} else {
  (
    section-gap: default-cv-style.section-gap,
    section-content-gap: default-cv-style.section-content-gap,
    item-gap: default-cv-style.item-gap,
    entry-row-gap: default-cv-style.entry-row-gap,
    description-gap: default-cv-style.description-gap,
    header-row-gap: default-cv-style.header-row-gap,
    header-rule-gap: default-cv-style.header-rule-gap,
    header-content-gap: default-cv-style.header-content-gap,
    body-leading: default-cv-style.body-leading,
    list-spacing: default-cv-style.list-spacing,
  )
}

#let cv-style = state("modernpro-cv-style", default-cv-style)

#let is-filled(value) = value != none and value != [] and value != ""

#let as-bool(value) = value == true or value == "true"

#let _option(source, key, default) = if source == none {
  default
} else {
  source.at(key, default: default)
}

#let _option-any(source, keys, default) = {
  let value = default
  if source != none {
    for key in keys {
      value = source.at(key, default: value)
    }
  }
  value
}

#let _first-filled(values, default: none) = {
  let value = default
  for candidate in values {
    if not is-filled(value) and is-filled(candidate) {
      value = candidate
    }
  }
  value
}

// A smaller date set beside a larger title aligns on cap-height by default,
// which leaves its baseline floating. Shifting by the cap-height difference
// restores a shared baseline and survives a title that wraps.
#let _cap-shift(style) = 0.7 * (style.item-title-size - style.small-size)

// Structural gaps are explicit, which drops the weak paragraph and block
// spacing next to them. Every vertical distance therefore comes from exactly
// one rhythm token rather than stacking on Typst's defaults.
#let sectionsep = context {
  let style = cv-style.get()
  v(style.section-gap)
}

#let subsectionsep = context {
  let style = cv-style.get()
  v(style.item-gap)
}

// Section headings (Education, Experience, etc). Case, weight, colour, and the
// trailing rule carry the hierarchy so the size ladder stays at four steps.
#let section(title) = {
  context {
    let style = cv-style.get()
    let label = {
      show heading: it => it.body
      heading(level: 1)[
        #text(
          style.section-size,
          fill: style.accent,
          weight: "bold",
          tracking: style.section-tracking,
        )[#upper[#title]]
      ]
    }
    block(sticky: true, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.7em,
        align: horizon,
        label,
        line(length: 100%, stroke: style.rule-stroke + style.rule),
      )
    ]
    v(style.section-content-gap)
  }
}

// Subsection headings (institution, company, etc).
#let subsection(content) = {
  context {
    let style = cv-style.get()
    text(style.item-title-size, fill: style.subheading, weight: "bold")[#content]
  }
}

// Entry header: a left block carrying the title and its qualifiers, and a right
// rail carrying nothing but the date. Location folds into the left meta line so
// the right edge stays a single clean column.
#let _entry-header(
  title: none,
  date: none,
  meta: none,
  location: none,
) = {
  context {
    let style = cv-style.get()
    // Keep the institution or degree in regular text and use colour, rather
    // than another italic layer, to quieten the dense middle of an academic CV.
    let qualifier = if is-filled(meta) and is-filled(location) {
      [
        #text(style.meta-size, fill: style.text)[#meta]
        #text(style.meta-size, fill: style.muted)[ · #location]
      ]
    } else if is-filled(meta) {
      text(style.meta-size, fill: style.text)[#meta]
    } else if is-filled(location) {
      text(style.meta-size, fill: style.muted)[#location]
    } else {
      none
    }

    if is-filled(title) or is-filled(date) or is-filled(qualifier) {
      // Implicit paragraph spacing would swamp the rhythm tokens, so every gap
      // inside an entry is an explicit v() and the blocks contribute none.
      block(breakable: false, sticky: true, above: 0pt, below: 0pt)[
        #block(above: 0pt, below: 0pt)[
          #grid(
            columns: (1fr, auto),
            column-gutter: 1em,
            [
              #if is-filled(title) {
                text(style.item-title-size, fill: style.subheading, weight: "bold")[#title]
              }
            ],
            [
              #if is-filled(date) {
                v(_cap-shift(style))
                align(right, text(style.small-size, fill: style.muted)[#date])
              }
            ],
          )
        ]
        #if is-filled(qualifier) {
          v(style.entry-row-gap)
          block(above: 0pt, below: 0pt)[
            #qualifier
          ]
        }
      ]
    }
  }
}

#let _entry-description(content) = {
  if is-filled(content) {
    context {
      let style = cv-style.get()
      // Neutralize implicit block margins so the shared rhythm tokens remain
      // the single source of truth for metadata, descriptions, and lists.
      show list: set block(above: 0pt, below: 0pt)
      show enum: set block(above: 0pt, below: 0pt)
      v(style.description-gap)
      block(above: 0pt, below: 0pt)[
        #text(style.body-size, fill: style.text)[#content]
      ]
    }
  }
}

#let _entry-finish() = context {
  let style = cv-style.get()
  v(style.item-gap)
}

// Education part
#let education(institution: none, major: none, date: none, location: none, description: none) = {
  _entry-header(title: institution, date: date, meta: major, location: location)
  _entry-description(description)
  _entry-finish()
}

// Projects
#let project(title, date, info) = {
  _entry-header(title: title, date: date)
  _entry-description(info)
  _entry-finish()
}

// Summary or short description.
#let summary(content) = {
  context {
    let style = cv-style.get()
    text(style.body-size, fill: style.text)[#content ]
  }
}

// Backward-compatible name.
#let descript = summary

// Job title
#let job(position: none, institution: none, location: none, date: none, description: none) = {
  _entry-header(title: position, date: date, meta: institution, location: location)
  _entry-description(description)
  _entry-finish()
}

// Recommended semantic name for job entries.
#let experience(
  title: none,
  position: none,
  institution: none,
  organization: none,
  location: none,
  date: none,
  details: none,
  description: none,
) = job(
  position: _first-filled((title, position)),
  institution: _first-filled((institution, organization)),
  location: location,
  date: date,
  description: _first-filled((details, description)),
)

// Details
#let info(content) = {
  context {
    let style = cv-style.get()
    text(style.body-size, fill: style.text)[#content\ ]
  }
}

#let oneline-title-item(title: none, content: none) = {
  context {
    let style = cv-style.get()
    if is-filled(title) {
      text(style.body-size, fill: style.subheading, weight: "bold")[#title: ]
    }
    if is-filled(content) {
      text(style.body-size, fill: style.text)[#content \ ]
    }
  }
}

#let detail-line = oneline-title-item
#let skill-line = detail-line

#let oneline-two(entry1: none, entry2: none) = {
  context {
    let style = cv-style.get()
    let left-content = if entry1 != none { entry1 } else { [] }
    let right-content = if entry2 != none { entry2 } else { [] }

    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      text(style.body-size, fill: style.text)[#left-content],
      align(right, text(style.small-size, fill: style.muted)[#right-content]),
    )
  }
}

#let twoline-item(entry1: none, entry2: none, entry3: none, entry4: none, description: none) = {
  _entry-header(title: entry1, date: entry2, meta: entry3, location: entry4)
  _entry-description(description)
  _entry-finish()
}

#let entry(
  title: none,
  left: none,
  right: none,
  meta: none,
  location: none,
  details: none,
  description: none,
) = twoline-item(
  entry1: _first-filled((title, left)),
  entry2: right,
  entry3: meta,
  entry4: location,
  description: _first-filled((details, description)),
)

#let award(award: none, institution: none, date: none) = {
  context {
    let style = cv-style.get()
    let label = if is-filled(award) and is-filled(institution) {
      [#award · #institution]
    } else {
      _first-filled((award, institution))
    }
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      text(style.body-size, fill: style.text)[#label],
      align(right, text(style.small-size, fill: style.muted)[#date]),
    )
    v(style.entry-row-gap)
  }
}

#let references(references: (), columns: (1fr, 1fr)) = {
  context {
    let style = cv-style.get()
    grid(
      columns: columns,
      column-gutter: 1.4em,
      row-gutter: style.item-gap,
      ..references.map(reference => block(breakable: false)[
        #align(left, {
          // Name and role occupy separate lines so every reference block has the
          // same line count and the columns stay aligned regardless of length.
          text(style.reference-size, fill: style.subheading, weight: "bold")[
            #reference.name\
          ]
          if ("position" in reference) {
            text(style.reference-size, fill: style.text, style: "italic")[#reference.position\ ]
          }

          if ("department" in reference) {
            text(style.reference-size, fill: style.text)[#reference.department\ ]
          }
          if ("institution" in reference) {
            text(style.reference-size, fill: style.text)[#reference.institution\ ]
          }
          if ("address" in reference) {
            text(style.small-size, fill: style.muted)[#reference.address\ ]
          }
          if ("email" in reference) {
            link("mailto:" + reference.email)[
              #text(style.small-size, fill: style.accent)[#reference.email]
            ]
          }
        })
      ]),
    )
  }
}

#let reference-list = references

// Publications
#let publication(path, styletype) = {
  context {
    let style = cv-style.get()
    set text(style.body-size, fill: style.text)
    bibliography(path, title: none, full: true, style: styletype)
  }
}

// Contact icons are optional content supplied by the document. The core
// template deliberately does not import or require an icon package.
#let _contact-has-icon(contact) = (
  type(contact) == dictionary
  and ("icon" in contact)
  and is-filled(contact.icon)
)

#let _contact-label(contact, style) = {
  let label = if type(contact) == dictionary {
    _option(contact, "text", [])
  } else {
    contact
  }
  let rendered = text(
    fill: if type(contact) == dictionary and ("link" in contact) and is-filled(contact.link) {
      style.accent
    } else {
      style.muted
    },
  )[#label]

  if type(contact) == dictionary and ("link" in contact) and is-filled(contact.link) {
    link(contact.link)[#rendered]
  } else {
    rendered
  }
}

#let _contact-icon(contact, style) = if _contact-has-icon(contact) {
  text(style.contact-icon-size, fill: style.accent)[#_option(contact, "icon", [])]
} else {
  []
}

// Inline contact details, used by the optional compact header mode.
#let contact-display(contacts) = {
  context {
    let style = cv-style.get()
    set text(style.contact-size, fill: style.muted)
    contacts
      .map(contact => {
        if _contact-has-icon(contact) {
          box([
            #_contact-icon(contact, style)
            #h(style.contact-icon-gap)
            #_contact-label(contact, style)
          ])
        } else {
          _contact-label(contact, style)
        }
      })
      .join(" · ")
  }
}

// Stacked contact details use a narrow, fixed icon column only when at least
// one contact supplies an icon. Text-only profiles keep the original layout.
#let contact-stack(contacts) = {
  context {
    let style = cv-style.get()
    set text(style.contact-size, fill: style.muted)

    let has-icons = false
    for contact in contacts {
      if _contact-has-icon(contact) {
        has-icons = true
      }
    }

    if has-icons {
      let cells = ()
      for contact in contacts {
        cells += (
          align(center + horizon, _contact-icon(contact, style)),
          align(left + horizon, _contact-label(contact, style)),
        )
      }
      grid(
        columns: (style.contact-icon-width, auto),
        column-gutter: style.contact-icon-gap,
        row-gutter: style.header-row-gap,
        ..cells,
      )
    } else {
      grid(
        columns: 1fr,
        row-gutter: style.header-row-gap,
        ..contacts.map(contact => align(right, _contact-label(contact, style))),
      )
    }
  }
}

#let section-gap = sectionsep
#let item-gap = subsectionsep

#let section-block(
  id,
  title: none,
  separator: true,
  body,
) = (
  id: id,
  content: {
    if title != none {
      section(title)
    }
      body
    if separator {
      sectionsep
    }
  },
)

#let render-sections(
  sections: (),
  order: none,
  include-remaining: true,
) = {
  if order == none {
    for entry in sections {
      entry.content
    }
  } else {
    for id in order {
      let entry = sections
        .filter(section => section.id == id)
        .at(0, default: none)
      if entry != none {
        entry.content
      }
    }
    if include-remaining {
      for entry in sections {
        if not order.contains(entry.id) {
          entry.content
        }
      }
    }
  }
}

#let resolve-cv-config(
  font-type,
  continue-header,
  margin,
  name,
  address,
  lastupdated,
  pagecount,
  date,
  contacts,
  profile: none,
  theme: none,
  layout: none,
  options: none,
  preset: none,
  accent: none,
  columns: none,
  default-bottom: 1.3cm,
) = {
  let resolved-preset = _first-filled(
    (preset, _option-any(layout, ("density", "preset"), none)),
    default: "default",
  )
  let rhythm = cv-rhythm(resolved-preset)
  let resolved-date = _option(options, "date", date)
  if resolved-date == none {
    resolved-date = datetime.today().display()
  }
  let resolved-continue-header = as-bool(_option-any(layout, ("continue-header", "continued-header"), continue-header))
  let resolved-margin = _option(layout, "margin", margin)
  if resolved-margin == none {
    // The first-page masthead must not move when continuation headers are
    // toggled. These dimensions are shared with modernpro-coverletter.
    resolved-margin = (
      left: 2.2cm,
      right: 2.2cm,
      top: 2cm,
      bottom: default-bottom,
    )
  }
  let resolved-accent = _first-filled(
    (accent, _option(theme, "accent", none)),
    default: default-cv-style.accent,
  )

  let style = (
    text: _option(theme, "text", default-cv-style.text),
    muted: _option(theme, "muted", default-cv-style.muted),
    heading: _option-any(theme, ("heading", "headings"), default-cv-style.heading),
    subheading: _option-any(theme, ("subheading", "subheadings"), default-cv-style.subheading),
    accent: resolved-accent,
    rule: _option(theme, "rule", default-cv-style.rule),
    heading-font: _option-any(theme, ("heading-font", "display-font"), default-cv-style.heading-font),
    body-size: _option(theme, "body-size", default-cv-style.body-size),
    item-title-size: _option(theme, "item-title-size", default-cv-style.item-title-size),
    meta-size: _option(theme, "meta-size", default-cv-style.meta-size),
    small-size: _option(theme, "small-size", default-cv-style.small-size),
    section-size: _option(theme, "section-size", default-cv-style.section-size),
    section-tracking: _option(theme, "section-tracking", default-cv-style.section-tracking),
    name-size: _option(theme, "name-size", default-cv-style.name-size),
    role-size: _option(theme, "role-size", default-cv-style.role-size),
    address-size: _option(theme, "address-size", default-cv-style.address-size),
    contact-size: _option(theme, "contact-size", default-cv-style.contact-size),
    contact-icon-size: _option(theme, "contact-icon-size", default-cv-style.contact-icon-size),
    contact-icon-width: _option(
      layout,
      "contact-icon-width",
      _option(theme, "contact-icon-width", default-cv-style.contact-icon-width),
    ),
    contact-icon-gap: _option(
      layout,
      "contact-icon-gap",
      _option(theme, "contact-icon-gap", default-cv-style.contact-icon-gap),
    ),
    footer-size: _option(theme, "footer-size", default-cv-style.footer-size),
    reference-size: _option(theme, "reference-size", default-cv-style.reference-size),
    section-gap: _option(layout, "section-gap", _option(theme, "section-gap", rhythm.section-gap)),
    section-content-gap: _option(layout, "section-content-gap", _option(theme, "section-content-gap", rhythm.section-content-gap)),
    item-gap: _option(layout, "item-gap", _option(theme, "item-gap", rhythm.item-gap)),
    entry-row-gap: _option(layout, "entry-row-gap", _option(theme, "entry-row-gap", rhythm.entry-row-gap)),
    description-gap: _option(layout, "description-gap", _option(theme, "description-gap", rhythm.description-gap)),
    header-row-gap: _option(layout, "header-row-gap", rhythm.header-row-gap),
    header-rule-gap: _option(layout, "header-rule-gap", rhythm.header-rule-gap),
    header-content-gap: _option(layout, "header-content-gap", rhythm.header-content-gap),
    body-leading: _option(layout, "body-leading", rhythm.body-leading),
    list-spacing: _option(layout, "list-spacing", rhythm.list-spacing),
    rule-stroke: _option(layout, "rule-stroke", _option(theme, "rule-stroke", default-cv-style.rule-stroke)),
  )

  (
    font-type: _first-filled(
      (_option-any(theme, ("font-type", "font"), none), font-type),
      default: default-cv-style.heading-font,
    ),
    style: style,
    continue-header: resolved-continue-header,
    margin: resolved-margin,
    name: _option(profile, "name", name),
    role: _option-any(profile, ("role", "headline", "position"), none),
    address: _option(profile, "address", address),
    contacts: _option(profile, "contacts", contacts),
    lastupdated: as-bool(_option-any(options, ("lastupdated", "last-updated"), lastupdated)),
    pagecount: as-bool(_option-any(options, ("pagecount", "page-count"), pagecount)),
    date: resolved-date,
    columns: _option(layout, "columns", (1fr, 2fr)),
    column-gutter: _option(layout, "column-gutter", 1.8em),
    contact-layout: _option(layout, "contact-layout", "stacked"),
    preset: resolved-preset,
    header-height: _option(layout, "header-height", 17mm),
    header-ascent: _option(layout, "header-ascent", 0.8em),
  )
}

#let cv-footer(cfg) = context {
  let style = cfg.style
  let current-page = counter(page).get().first()
  let show-page = cfg.pagecount and (not cfg.continue-header or current-page == 1)
  set text(style.footer-size, fill: style.muted)
  grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: horizon,
    [#if cfg.lastupdated and current-page == 1 [Last updated: #cfg.date]],
    align(right)[
      #if show-page [#counter(page).display("1 / 1", both: true)]
    ],
  )
}

#let cv-header(cfg) = {
  let style = cfg.style
  // Typst measures a line box down to the baseline, so descenders hang outside
  // it and a tight stack collides. Extending the bottom edge fixes the whole
  // header at once, for every document in the suite.
  set text(bottom-edge: "descender")
  set par(spacing: 0pt, first-line-indent: 0em)

  let identity = (
    if is-filled(cfg.name) {
      align(left, text(style.name-size, fill: style.heading, weight: "bold")[#cfg.name])
    },
    if is-filled(cfg.role) {
      align(left, text(style.role-size, fill: style.accent, weight: "bold")[#cfg.role])
    },
    if is-filled(cfg.address) {
      align(left, text(style.address-size, fill: style.muted)[#cfg.address])
    },
  ).filter(item => item != none)

  let contact-block = if cfg.contacts == none or cfg.contacts.len() == 0 {
    none
  } else if cfg.contact-layout == "inline" {
    contact-display(cfg.contacts)
  } else {
    contact-stack(cfg.contacts)
  }

  block(breakable: false)[
    #block(height: cfg.header-height, breakable: false)[
      #align(bottom, grid(
        columns: (1.08fr, 1fr),
        column-gutter: 1.4em,
        align: bottom,
        grid(
          columns: 1fr,
          row-gutter: style.header-row-gap,
          ..identity,
        ),
        align(right + bottom, [
          #if contact-block != none {
            contact-block
          }
        ]),
      ))
    ]
    #v(style.header-rule-gap)
    #line(length: 100%, stroke: style.rule-stroke + style.accent)
    #v(style.header-content-gap)
  ]
}

#let cv-continuation-header(cfg) = {
  let style = cfg.style
  let document-label = if cfg.pagecount {
    [Curriculum vitae · #counter(page).display("1 / 1", both: true)]
  } else {
    [Curriculum vitae]
  }
  block(breakable: false)[
    #grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      text(style.contact-size, fill: style.heading, weight: "bold")[#cfg.name],
      text(style.contact-size, fill: style.muted)[#document-label],
    )
    #v(0.3em)
    #line(length: 100%, stroke: style.rule-stroke + style.rule)
  ]
}

#let render-cv-page(cfg, body) = {
  set page(footer: cv-footer(cfg))
  if cfg.continue-header {
    set page(
      margin: cfg.margin,
      header: context {
        if counter(page).get().first() > 1 {
          cv-continuation-header(cfg)
        }
      },
      header-ascent: cfg.header-ascent,
    )
    cv-header(cfg)
    body
  } else {
    set page(margin: cfg.margin)
    cv-header(cfg)
    body
  }
}

// Single entry point. The document body arrives positionally through the show
// rule; `columns: 2` ignores it and renders the `left` and `right` bodies.
#let cv(
  profile: none,
  preset: none,
  accent: none,
  columns: 1,
  left: none,
  right: none,
  font-type: none,
  continue-header: "true",
  margin: none,
  name: none,
  address: none,
  lastupdated: "true",
  pagecount: "true",
  date: none,
  contacts: (),
  theme: none,
  layout: none,
  options: none,
  mainbody,
) = {
  let cfg = resolve-cv-config(
    font-type,
    continue-header,
    margin,
    name,
    address,
    lastupdated,
    pagecount,
    date,
    contacts,
    profile: profile,
    theme: theme,
    layout: layout,
    options: options,
    preset: preset,
    accent: accent,
    columns: columns,
    default-bottom: if columns == 2 { 1.5cm } else { 1.3cm },
  )

  cv-style.update(cfg.style)
  set text(font: cfg.font-type, size: cfg.style.body-size, fill: cfg.style.text)
  // Only consecutive paragraphs use this; explicit rhythm gaps drop the weak
  // paragraph spacing next to them, so it never doubles up on a token.
  set par(leading: cfg.style.body-leading, spacing: 0.9em)
  set list(indent: 1em, body-indent: 0.45em, spacing: cfg.style.list-spacing)
  show link: set text(fill: cfg.style.accent)
  set cite(form: "full")

  let body = if columns == 2 {
    grid(
      columns: cfg.columns,
      column-gutter: cfg.column-gutter,
      left, right,
    )
  } else {
    mainbody
  }

  render-cv-page(cfg, body)
}

#let cv-single(
  font-type: none,
  continue-header: "true",
  margin: none,
  name: none,
  address: none,
  lastupdated: "true",
  pagecount: "true",
  date: none,
  contacts: (),
  profile: none,
  preset: none,
  accent: none,
  theme: none,
  layout: none,
  options: none,
  mainbody,
) = cv(
  profile: profile,
  preset: preset,
  accent: accent,
  columns: 1,
  font-type: font-type,
  continue-header: continue-header,
  margin: margin,
  name: name,
  address: address,
  lastupdated: lastupdated,
  pagecount: pagecount,
  date: date,
  contacts: contacts,
  theme: theme,
  layout: layout,
  options: options,
  mainbody,
)

// Kept without a trailing positional so the historical `#show: cv-double(...)`
// call form keeps working alongside `#show: cv.with(columns: 2, ...)`.
#let cv-double(
  font-type: none,
  continue-header: "false",
  margin: none,
  name: none,
  address: none,
  lastupdated: "true",
  pagecount: "true",
  date: none,
  contacts: (),
  left: none,
  right: none,
  profile: none,
  preset: none,
  accent: none,
  theme: none,
  layout: none,
  options: none,
) = cv(
  profile: profile,
  preset: preset,
  accent: accent,
  columns: 2,
  left: left,
  right: right,
  font-type: font-type,
  continue-header: continue-header,
  margin: margin,
  name: name,
  address: address,
  lastupdated: lastupdated,
  pagecount: pagecount,
  date: date,
  contacts: contacts,
  theme: theme,
  layout: layout,
  options: options,
  [],
)
