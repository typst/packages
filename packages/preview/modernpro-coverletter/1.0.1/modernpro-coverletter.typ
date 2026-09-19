///////////////////////////////
// modernpro-coverletter.typ
// A clean, modern academic cover letter and statement template.
// Copyright (c) 2026
// Author:  Academic Template Collective
// License: MIT
// Version: 1.0.1
// Date:    2026-08-27
// Email:   maintainers@example.invalid
///////////////////////////////

// Shared design tokens for the academic suite: one serif family, two weights,
// a restrained size ladder, and four colours. Keep this block in sync with modernpro-cv.typ so a
// CV and a letter set beside each other read as one document set.
#let default-letter-style = (
  text: rgb("#1f2933"),
  muted: rgb("#667085"),
  heading: rgb("#1f2933"),
  accent: rgb("#1e3a5f"),
  rule: rgb("#dde3ea"),

  font: ("PT Serif", "Libertinus Serif"),
  name-size: 18pt,
  doc-title-size: 15pt,
  role-size: 10.5pt,
  subject-size: 10.8pt,
  heading-1-size: 11pt,
  heading-2-size: 10.8pt,
  body-size: 10.8pt,
  recipient-size: 9.8pt,
  address-size: 9.8pt,
  supplement-size: 9.8pt,
  small-size: 8.8pt,
  contact-size: 8.8pt,
  contact-icon-size: 7.6pt,
  contact-icon-width: 9pt,
  contact-icon-gap: 4pt,

  rule-stroke: 0.4pt,
)

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
  for candidate in values {
    if is-filled(candidate) {
      return candidate
    }
  }
  return default
}

// A small set of rhythm presets keeps the public API simple while preserving
// precise overrides for long or unusually dense documents.
#let letter-rhythm(preset) = if preset == "compact" {
  (
    line-spacing: 0.62em,
    paragraph-spacing: 1em,
    header-row-gap: 1.8pt,
    header-rule-gap: 4.8pt,
    header-content-gap: 7pt,
    recipient-top-gap: 0.3em,
    recipient-subject-gap: 0.8em,
    subject-after-gap: 0.65em,
    doc-title-top-gap: 0.3em,
    doc-title-rule-gap: 0.3em,
    doc-title-content-gap: 0.7em,
    heading-1-before: 0.85em,
    heading-1-after: 0.3em,
    heading-2-before: 0.7em,
    heading-2-after: 0.26em,
  )
} else if preset == "relaxed" or preset == "spacious" {
  (
    line-spacing: 0.8em,
    paragraph-spacing: 1.55em,
    header-row-gap: 3pt,
    header-rule-gap: 7pt,
    header-content-gap: 11pt,
    recipient-top-gap: 0.5em,
    recipient-subject-gap: 1.15em,
    subject-after-gap: 0.95em,
    doc-title-top-gap: 0.5em,
    doc-title-rule-gap: 0.45em,
    doc-title-content-gap: 1.1em,
    heading-1-before: 1.3em,
    heading-1-after: 0.5em,
    heading-2-before: 1.05em,
    heading-2-after: 0.42em,
  )
} else {
  (
    line-spacing: 0.72em,
    paragraph-spacing: 1.35em,
    header-row-gap: 2.4pt,
    header-rule-gap: 6pt,
    header-content-gap: 10pt,
    recipient-top-gap: 0.4em,
    recipient-subject-gap: 0.95em,
    subject-after-gap: 0.8em,
    doc-title-top-gap: 0.4em,
    doc-title-rule-gap: 0.36em,
    doc-title-content-gap: 0.9em,
    heading-1-before: 1.5em,
    heading-1-after: 0.5em,
    heading-2-before: 1.15em,
    heading-2-after: 0.42em,
  )
}

#let resolve-letter-config(
  font-type: none,
  margin: none,
  name: none,
  address: none,
  contacts: (),
  primary-colour: none,
  headings-colour: none,
  subheadings-colour: none,
  date-colour: none,
  link-colour: none,
  name-size: none,
  body-size: none,
  address-size: none,
  contact-size: none,
  recipient-size: none,
  cl-title-size: none,
  supplement-size: none,
  line-stroke: none,
  header-ascent: 1em,
  first-line-indent: 0em,
  line-spacing: none,
  paragraph-spacing: none,
  contact-separator: " · ",
  name-align: left,
  address-align: left,
  contact-align: right,
  name-weight: "bold",
  body-weight: "regular",
  date-format: "[day] [month repr:long] [year]",
  profile: none,
  theme: none,
  layout: none,
  preset: none,
  accent: none,
) = {
  let d = default-letter-style
  let resolved-preset = _first-filled(
    (preset, _option-any(layout, ("density", "preset"), none)),
    default: "default",
  )
  let rhythm = letter-rhythm(resolved-preset)
  let resolved-repeat-header = as-bool(_option(layout, "repeat-header", false))

  let resolved-margin = _option(layout, "margin", margin)
  if resolved-margin == none {
    // Match modernpro-cv exactly. Enabling a continuation header must never
    // move the first-page masthead.
    resolved-margin = (
      left: 2.2cm,
      right: 2.2cm,
      top: 2cm,
      bottom: 1.8cm,
    )
  }

  // Legacy colour parameters keep working; the modern path is theme + accent.
  let resolved-accent = _first-filled(
    (accent, _option(theme, "accent", none), link-colour),
    default: d.accent,
  )

  (
    font: _first-filled(
      (_option-any(theme, ("font", "font-type"), none), font-type),
      default: d.font,
    ),
    margin: resolved-margin,
    name: _option(profile, "name", name),
    role: _option-any(profile, ("role", "headline", "position"), none),
    address: _option(profile, "address", address),
    contacts: _option(profile, "contacts", contacts),

    text: _first-filled((_option-any(theme, ("text", "primary-colour"), none), primary-colour), default: d.text),
    muted: _first-filled((_option-any(theme, ("muted", "headings-colour"), none), headings-colour), default: d.muted),
    heading: _first-filled((_option-any(theme, ("heading", "subheadings-colour"), none), subheadings-colour), default: d.heading),
    date-colour: _first-filled((_option(theme, "date-colour", none), date-colour), default: d.muted),
    accent: resolved-accent,
    rule: _option(theme, "rule", d.rule),

    name-size: _first-filled((_option(theme, "name-size", none), name-size), default: d.name-size),
    doc-title-size: _option(theme, "doc-title-size", d.doc-title-size),
    role-size: _option(theme, "role-size", d.role-size),
    subject-size: _first-filled((_option(theme, "subject-size", none), cl-title-size), default: d.subject-size),
    heading-1-size: _option(theme, "heading-1-size", d.heading-1-size),
    heading-2-size: _option(theme, "heading-2-size", d.heading-2-size),
    body-size: _first-filled((_option-any(theme, ("body-size", "fontsize"), none), body-size), default: d.body-size),
    recipient-size: _first-filled((_option(theme, "recipient-size", none), recipient-size), default: d.recipient-size),
    address-size: _first-filled((_option(theme, "address-size", none), address-size), default: d.address-size),
    supplement-size: _first-filled((_option(theme, "supplement-size", none), supplement-size), default: d.supplement-size),
    small-size: _option(theme, "small-size", d.small-size),
    contact-size: _first-filled((_option(theme, "contact-size", none), contact-size), default: d.contact-size),
    contact-icon-size: _option(theme, "contact-icon-size", d.contact-icon-size),
    contact-icon-width: _option(layout, "contact-icon-width", _option(theme, "contact-icon-width", d.contact-icon-width)),
    contact-icon-gap: _option(layout, "contact-icon-gap", _option(theme, "contact-icon-gap", d.contact-icon-gap)),

    rule-stroke: _first-filled((_option(layout, "rule-stroke", none), line-stroke), default: d.rule-stroke),
    header-ascent: _option(layout, "header-ascent", header-ascent),
    first-line-indent: _option(layout, "first-line-indent", first-line-indent),
    line-spacing: _option(layout, "line-spacing", _first-filled((line-spacing,), default: rhythm.line-spacing)),
    paragraph-spacing: _option(layout, "paragraph-spacing", _first-filled((paragraph-spacing,), default: rhythm.paragraph-spacing)),
    contact-separator: _option(layout, "contact-separator", contact-separator),
    name-align: _option(layout, "name-align", name-align),
    address-align: _option(layout, "address-align", address-align),
    contact-align: _option(layout, "contact-align", contact-align),
    name-weight: _option(theme, "name-weight", name-weight),
    body-weight: _option(theme, "body-weight", body-weight),
    date-format: _option(layout, "date-format", date-format),
    justify: as-bool(_option(layout, "justify", false)),
    header-style: _option(layout, "header-style", "split"),
    contact-layout: _option(layout, "contact-layout", "stacked"),

    header-row-gap: _option(layout, "header-row-gap", rhythm.header-row-gap),
    header-rule-gap: _option(layout, "header-rule-gap", rhythm.header-rule-gap),
    header-content-gap: _option(layout, "header-content-gap", rhythm.header-content-gap),
    recipient-top-gap: _option(layout, "recipient-top-gap", rhythm.recipient-top-gap),
    recipient-subject-gap: _option(layout, "recipient-subject-gap", rhythm.recipient-subject-gap),
    subject-after-gap: _option(layout, "subject-after-gap", rhythm.subject-after-gap),
    doc-title-top-gap: _option-any(layout, ("doc-title-top-gap", "statement-title-top-gap"), rhythm.doc-title-top-gap),
    doc-title-rule-gap: _option-any(layout, ("doc-title-rule-gap", "statement-title-rule-gap"), rhythm.doc-title-rule-gap),
    doc-title-content-gap: _option-any(layout, ("doc-title-content-gap", "statement-title-content-gap"), rhythm.doc-title-content-gap),
    heading-1-before: _option(layout, "heading-1-before", rhythm.heading-1-before),
    heading-1-after: _option(layout, "heading-1-after", rhythm.heading-1-after),
    heading-2-before: _option(layout, "heading-2-before", rhythm.heading-2-before),
    heading-2-after: _option(layout, "heading-2-after", rhythm.heading-2-after),
    preset: resolved-preset,
    repeat-header: resolved-repeat-header,
    page-numbering: as-bool(_option(layout, "page-numbering", true)),
    header-height: _option(layout, "header-height", 17mm),
  )
}

// Contact rendering mirrors modernpro-cv so the same `profile` dictionary can
// be imported into a CV and a letter without editing either one.
#let _contact-has-icon(contact) = (
  type(contact) == dictionary
  and ("icon" in contact)
  and is-filled(contact.icon)
)

#let _contact-label(contact, cfg) = {
  let label = if type(contact) == dictionary {
    _option(contact, "text", [])
  } else {
    contact
  }
  let has-link = type(contact) == dictionary and ("link" in contact) and is-filled(contact.link)
  let rendered = text(fill: if has-link { cfg.accent } else { cfg.muted })[#label]
  if has-link { link(contact.link)[#rendered] } else { rendered }
}

#let _contact-icon(contact, cfg) = if _contact-has-icon(contact) {
  text(cfg.contact-icon-size, fill: cfg.accent)[#_option(contact, "icon", [])]
} else {
  []
}

#let letter-contact-display(contacts, cfg) = {
  context {
    set text(cfg.contact-size, fill: cfg.muted)
    contacts
      .map(contact => {
        if _contact-has-icon(contact) {
          box([
            #_contact-icon(contact, cfg)
            #h(cfg.contact-icon-gap)
            #_contact-label(contact, cfg)
          ])
        } else {
          _contact-label(contact, cfg)
        }
      })
      .join(cfg.contact-separator)
  }
}

#let letter-contact-stack(contacts, cfg) = {
  context {
    set text(cfg.contact-size, fill: cfg.muted)

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
          align(center + horizon, _contact-icon(contact, cfg)),
          align(left + horizon, _contact-label(contact, cfg)),
        )
      }
      grid(
        columns: (cfg.contact-icon-width, auto),
        column-gutter: cfg.contact-icon-gap,
        row-gutter: cfg.header-row-gap,
        ..cells,
      )
    } else {
      grid(
        columns: 1fr,
        row-gutter: cfg.header-row-gap,
        ..contacts.map(contact => align(cfg.contact-align, _contact-label(contact, cfg))),
      )
    }
  }
}

#let letter-header(cfg) = {
  // Typst measures a line box down to the baseline, so descenders hang outside
  // it and a tight identity stack collides. Extending the bottom edge fixes the
  // whole header at once, exactly as in modernpro-cv.
  set text(bottom-edge: "descender")
  set par(spacing: 0pt, first-line-indent: 0em)

  let identity = (
    if is-filled(cfg.name) {
      align(cfg.name-align, text(cfg.name-size, fill: cfg.heading, weight: cfg.name-weight)[#cfg.name])
    },
    if is-filled(cfg.role) {
      align(cfg.name-align, text(cfg.role-size, fill: cfg.accent, weight: "bold")[#cfg.role])
    },
    if is-filled(cfg.address) {
      align(cfg.address-align, text(cfg.address-size, fill: cfg.muted)[#cfg.address])
    },
  ).filter(item => item != none)

  let has-contacts = cfg.contacts != none and cfg.contacts.len() > 0
  let contact-block = if not has-contacts {
    none
  } else if cfg.contact-layout == "inline" {
    letter-contact-display(cfg.contacts, cfg)
  } else {
    letter-contact-stack(cfg.contacts, cfg)
  }
  if cfg.header-style == "centered" {
    block(breakable: false)[
      #block(height: cfg.header-height, breakable: false)[
        #align(bottom, [
          #align(center, grid(columns: 1fr, row-gutter: cfg.header-row-gap, ..identity))
          #if has-contacts {
            v(cfg.header-row-gap)
            align(center)[#letter-contact-display(cfg.contacts, cfg)]
          }
        ])
      ]
      #v(cfg.header-rule-gap)
      #line(length: 100%, stroke: cfg.rule-stroke + cfg.accent)
      #v(cfg.header-content-gap)
    ]
  } else {
    block(breakable: false)[
      #block(height: cfg.header-height, breakable: false)[
        #align(bottom, grid(
          columns: (1.08fr, 1fr),
          column-gutter: 1.4em,
          align: bottom,
          grid(columns: 1fr, row-gutter: cfg.header-row-gap, ..identity),
          align(cfg.contact-align + bottom, [
            #if contact-block != none { contact-block }
          ]),
        ))
      ]
      #v(cfg.header-rule-gap)
      #line(length: 100%, stroke: cfg.rule-stroke + cfg.accent)
      #v(cfg.header-content-gap)
    ]
  }
}

#let letter-continuation-header(cfg, label) = {
  let document-label = if cfg.page-numbering {
    [#label · #counter(page).display("1 / 1", both: true)]
  } else {
    label
  }
  block(breakable: false)[
    #grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      text(cfg.contact-size, fill: cfg.heading, weight: "bold")[#cfg.name],
      text(cfg.contact-size, fill: cfg.muted)[#document-label],
    )
    #v(0.3em)
    #line(length: 100%, stroke: cfg.rule-stroke + cfg.rule)
  ]
}

#let recipient-block(recipient, cfg) = {
  let greeting = _first-filled((
    _option(recipient, "greeting", none),
    _option(recipient, "start-title", none),
  ))
  let subject = _first-filled((
    _option(recipient, "subject", none),
    _option(recipient, "cl-title", none),
  ))
  let date = _option(recipient, "date", none)
  let name = _option(recipient, "name", none)
  let role = _first-filled((
    _option(recipient, "role", none),
    _option(recipient, "position", none),
  ))
  let department = _option(recipient, "department", none)
  let institution = _first-filled((
    _option(recipient, "organization", none),
    _option(recipient, "institution", none),
  ))
  let address = _option(recipient, "address", none)
  let postcode = _option(recipient, "postcode", none)
  let displayed-date = if is-filled(date) {
    date
  } else {
    datetime.today(offset: auto).display(cfg.date-format)
  }

  v(cfg.recipient-top-gap)
  block(breakable: false)[
    #set par(leading: cfg.line-spacing, spacing: 0pt)
    #grid(
      columns: (1fr, auto),
      column-gutter: 1.5em,
      [
        #if is-filled(name) {
          text(cfg.recipient-size, fill: cfg.heading, weight: "bold")[#name\ ]
        }
        #if is-filled(role) {
          text(cfg.recipient-size, fill: cfg.text)[#role\ ]
        }
        #if is-filled(department) {
          text(cfg.recipient-size, fill: cfg.text)[#department\ ]
        }
        #if is-filled(institution) {
          text(cfg.recipient-size, fill: cfg.text)[#institution\ ]
        }
        #if is-filled(address) {
          text(cfg.recipient-size, fill: cfg.muted)[#address\ ]
        }
        #if is-filled(postcode) {
          text(cfg.recipient-size, fill: cfg.muted)[#postcode]
        }
      ],
      align(right, text(cfg.recipient-size, fill: cfg.date-colour)[#displayed-date]),
    )
  ]

  v(cfg.recipient-subject-gap)
  block(sticky: true)[
    #if is-filled(subject) {
      text(cfg.subject-size, fill: cfg.heading, weight: "bold")[#subject]
      v(cfg.subject-after-gap)
    }
    #if is-filled(greeting) {
      text(cfg.body-size, fill: cfg.text, weight: cfg.body-weight)[#greeting]
    }
  ]
}

#let render-closing(cfg, closing-cfg) = {
  block(breakable: false)[
    #v(closing-cfg.closing-spacing)
    #set par(first-line-indent: 0em)

    #if closing-cfg.salutation != none {
      text(cfg.body-size, fill: cfg.text, weight: closing-cfg.salutation-weight)[#closing-cfg.salutation]
      v(closing-cfg.signature-spacing)
    }

    #if is-filled(cfg.name) {
      text(cfg.body-size, fill: cfg.heading, weight: closing-cfg.signature-weight)[#cfg.name]
    }

    #if closing-cfg.supplements != none {
      v(closing-cfg.supplement-spacing)
      let additions = if type(closing-cfg.supplements) == array {
        closing-cfg.supplements
      } else {
        (closing-cfg.supplements,)
      }
      for addition in additions {
        text(cfg.supplement-size, fill: cfg.muted)[#addition]
        linebreak()
      }
    }
  ]
}

#let coverletter(
  profile: none,
  preset: none,
  accent: none,
  recipient: (:),
  closing: none,
  font-type: none,
  margin: none,
  name: none,
  address: none,
  contacts: (),
  supplements: none,
  salutation: "Sincerely,",
  primary-colour: none,
  headings-colour: none,
  subheadings-colour: none,
  date-colour: none,
  link-colour: none,
  name-size: none,
  body-size: none,
  address-size: none,
  contact-size: none,
  recipient-size: none,
  cl-title-size: none,
  supplement-size: none,
  line-stroke: none,
  header-ascent: 1em,
  first-line-indent: 0em,
  line-spacing: none,
  paragraph-spacing: none,
  contact-separator: " · ",
  name-align: left,
  address-align: left,
  contact-align: right,
  name-weight: "bold",
  body-weight: "regular",
  salutation-weight: "regular",
  signature-weight: "bold",
  closing-spacing: 1.2em,
  signature-spacing: 0.5em,
  supplement-spacing: 1em,
  date-format: "[day] [month repr:long] [year]",
  theme: none,
  layout: none,
  mainbody,
) = {
  let cfg = resolve-letter-config(
    font-type: font-type,
    margin: margin,
    name: name,
    address: address,
    contacts: contacts,
    primary-colour: primary-colour,
    headings-colour: headings-colour,
    subheadings-colour: subheadings-colour,
    date-colour: date-colour,
    link-colour: link-colour,
    name-size: name-size,
    body-size: body-size,
    address-size: address-size,
    contact-size: contact-size,
    recipient-size: recipient-size,
    cl-title-size: cl-title-size,
    supplement-size: supplement-size,
    line-stroke: line-stroke,
    header-ascent: header-ascent,
    first-line-indent: first-line-indent,
    line-spacing: line-spacing,
    paragraph-spacing: paragraph-spacing,
    contact-separator: contact-separator,
    name-align: name-align,
    address-align: address-align,
    contact-align: contact-align,
    name-weight: name-weight,
    body-weight: body-weight,
    date-format: date-format,
    profile: profile,
    theme: theme,
    layout: layout,
    preset: preset,
    accent: accent,
  )
  let closing-cfg = (
    salutation: _option(closing, "salutation", salutation),
    supplements: _option(closing, "supplements", supplements),
    salutation-weight: _option(closing, "salutation-weight", salutation-weight),
    signature-weight: _option(closing, "signature-weight", signature-weight),
    closing-spacing: _option(closing, "closing-spacing", closing-spacing),
    signature-spacing: _option(closing, "signature-spacing", signature-spacing),
    supplement-spacing: _option(closing, "supplement-spacing", supplement-spacing),
  )

  set page(
    margin: cfg.margin,
    header: if cfg.repeat-header {
      context {
        if counter(page).get().first() > 1 {
          letter-continuation-header(cfg, [Cover letter])
        }
      }
    } else {
      none
    },
    header-ascent: cfg.header-ascent,
  )

  // These rules must live in the template body itself. Moving them into a
  // helper would scope them to that helper and silently leave the letter at
  // Typst's defaults instead of the configured size, leading, and spacing.
  set text(cfg.body-size, font: cfg.font, fill: cfg.text, weight: cfg.body-weight)
  set par(
    justify: cfg.justify,
    first-line-indent: cfg.first-line-indent,
    leading: cfg.line-spacing,
    spacing: cfg.paragraph-spacing,
  )
  show link: set text(fill: cfg.accent)

  letter-header(cfg)
  recipient-block(recipient, cfg)
  mainbody
  render-closing(cfg, closing-cfg)
}

#let statement(
  profile: none,
  preset: none,
  accent: none,
  title: none,
  supplement: none,
  font-type: none,
  margin: none,
  name: none,
  address: none,
  contacts: (),
  primary-colour: none,
  headings-colour: none,
  subheadings-colour: none,
  date-colour: none,
  link-colour: none,
  name-size: none,
  body-size: none,
  address-size: none,
  contact-size: none,
  line-stroke: none,
  header-ascent: 1em,
  first-line-indent: 0em,
  line-spacing: none,
  paragraph-spacing: none,
  contact-separator: " · ",
  name-align: left,
  address-align: left,
  contact-align: right,
  name-weight: "bold",
  body-weight: "regular",
  theme: none,
  layout: none,
  mainbody,
) = {
  // Statements are normally multi-page academic documents. They receive the
  // compact continuation header by default while preserving an explicit user
  // choice to turn it off.
  let statement-layout = if layout == none {
    (repeat-header: true,)
  } else if "repeat-header" in layout {
    layout
  } else {
    layout + (repeat-header: true,)
  }

  let cfg = resolve-letter-config(
    font-type: font-type,
    margin: margin,
    name: name,
    address: address,
    contacts: contacts,
    primary-colour: primary-colour,
    headings-colour: headings-colour,
    subheadings-colour: subheadings-colour,
    date-colour: date-colour,
    link-colour: link-colour,
    name-size: name-size,
    body-size: body-size,
    address-size: address-size,
    contact-size: contact-size,
    line-stroke: line-stroke,
    header-ascent: header-ascent,
    first-line-indent: first-line-indent,
    line-spacing: line-spacing,
    paragraph-spacing: paragraph-spacing,
    contact-separator: contact-separator,
    name-align: name-align,
    address-align: address-align,
    contact-align: contact-align,
    name-weight: name-weight,
    body-weight: body-weight,
    profile: profile,
    theme: theme,
    layout: statement-layout,
    preset: preset,
    accent: accent,
  )

  set page(
    margin: cfg.margin,
    header: if cfg.repeat-header {
      context {
        if counter(page).get().first() > 1 {
          letter-continuation-header(cfg, [#_first-filled((title,), default: [Statement])])
        }
      }
    } else {
      none
    },
    header-ascent: cfg.header-ascent,
  )

  set text(cfg.body-size, font: cfg.font, fill: cfg.text, weight: cfg.body-weight)
  set par(
    justify: cfg.justify,
    first-line-indent: cfg.first-line-indent,
    leading: cfg.line-spacing,
    spacing: cfg.paragraph-spacing,
  )
  show link: set text(fill: cfg.accent)

  show heading.where(level: 1): it => block(
    above: 0pt,
    below: 0pt,
    sticky: true,
  )[
    #v(cfg.heading-1-before)
    #text(cfg.heading-1-size, fill: cfg.heading, weight: "bold")[#it.body]
    #v(cfg.heading-1-after)
  ]

  show heading.where(level: 2): it => block(
    above: 0pt,
    below: 0pt,
    sticky: true,
  )[
    #v(cfg.heading-2-before)
    #text(cfg.heading-2-size, fill: cfg.heading, style: "italic")[#it.body]
    #v(cfg.heading-2-after)
  ]

  letter-header(cfg)

  // Deliberately not a `heading`: the level-1 show rule above would apply its
  // own block spacing here and override the title's own rhythm tokens.
  if is-filled(title) {
    v(cfg.doc-title-top-gap)
    block(sticky: true, above: 0pt, below: 0pt)[
      #block(above: 0pt, below: 0pt)[
        #text(
          cfg.doc-title-size,
          fill: cfg.heading,
          weight: "bold",
          bottom-edge: "descender",
        )[#title]
      ]
      #v(cfg.doc-title-rule-gap)
      #line(length: 100%, stroke: cfg.rule-stroke + cfg.rule)
    ]
    v(cfg.doc-title-content-gap)
  }

  mainbody

  if supplement != none {
    supplement
  }
}
