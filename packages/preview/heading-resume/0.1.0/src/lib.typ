#let _assert-array(value, name) = assert(
  type(value) == array,
  message: name + " must be an array.",
)

#let _assert-dictionary(value, name) = assert(
  type(value) == dictionary,
  message: name + " must be a dictionary.",
)

#let contact(value, url: none) = (
  value: value,
  url: url,
)

#let entry(
  title,
  organisation: none,
  dates: none,
  subtitle: none,
  body: none,
) = (
  title: title,
  organisation: organisation,
  dates: dates,
  subtitle: subtitle,
  body: body,
)

#let entry-section(
  title,
  entries,
  compact: false,
  inline-organisation: false,
) = {
  _assert-array(entries, "Section entries")
  assert(
    entries.len() > 0,
    message: "An entry section needs at least one entry.",
  )
  (
    kind: "entries",
    title: title,
    entries: entries,
    compact: compact,
    inline-organisation: inline-organisation,
  )
}

#let skill(label, value) = (
  label: label,
  value: value,
)

#let skill-section(title, rows) = {
  _assert-array(rows, "Skill rows")
  assert(rows.len() > 0, message: "A skill section needs at least one row.")
  (
    kind: "skills",
    title: title,
    rows: rows,
  )
}

#let default-style = (
  page: (
    paper: "a4",
    fill: rgb("fffdf9"),
    margin: (x: 11.5mm, top: 9.5mm, bottom: 6.5mm),
    footer-size: 0.62em,
    footer-fill: auto,
    footer-alignment: right,
  ),
  colors: (
    accent: rgb("cf3f2f"),
    ink: rgb("17191d"),
    muted: rgb("5f6268"),
    hairline: rgb("c9c4bd"),
    link: auto,
    emphasis: auto,
    marker: auto,
  ),
  typography: (
    base-size: 11pt,
    display-font: "Libertinus Serif",
    body-font: "Libertinus Serif",
    label-font: "Libertinus Serif",
    section-font: auto,
    emphasis-font: auto,
    emphasis-style: "italic",
    paragraph-justify: false,
    paragraph-leading: 0.42em,
  ),
  header: (
    name-size: 3.59em,
    name-weight: "regular",
    name-tracking: -0.7pt,
    name-after-gap: -2.6em,
    contact-size: 0.62em,
    contact-separator: [•],
    contact-separator-gap: 0.5em,
    rule-length: 100%,
    rule-stroke: color => 1.15pt + color,
    profile-size: 0.92em,
    profile-weight: "medium",
  ),
  columns: (
    widths: (1.62fr, 1fr),
    gutter: 4mm,
    divider-stroke: color => 0.55pt + color,
    aside-inset: 5mm,
    full-section-gap: 0.28em,
  ),
  sections: (
    before: 0.3em,
    title-columns: (auto, 1fr),
    title-rule-gap: 0.75em,
    title-size: 1.03em,
    title-weight: "semibold",
    title-tracking: 0.8pt,
    title-transform: upper,
    rule-length: 100%,
    rule-stroke: color => 0.55pt + color,
    rule-start: (0em, 0.42em),
    after: 0.38em,
  ),
  entries: (
    heading-columns: (1fr, auto),
    column-gutter: 0.65em,
    title-size: 0.96em,
    compact-title-size: 0.89em,
    title-weight: "bold",
    inline-organisation-size: 0.84em,
    dates-size: 0.79em,
    organisation-size: 0.88em,
    compact-organisation-size: 0.81em,
    organisation-style: "italic",
    subtitle-size: 0.77em,
    metadata-gap: 0.18em,
    metadata-separator: [·],
    body-size: 0.88em,
    compact-body-size: 0.82em,
    body-before: -0.12em,
    body-leading: 0.4em,
    compact-body-leading: 0.32em,
    after: 0.32em,
    compact-after: 0.22em,
    divider-before: -0.6em,
    divider-after: -0.2em,
    divider-length: 100%,
    divider-stroke: color => (
      paint: color,
      thickness: 0.6pt,
      dash: "dotted",
    ),
  ),
  skills: (
    size: 0.84em,
    label-weight: "bold",
    columns: (7.8em, 1fr),
    row-gutter: 0.62em,
  ),
  list: (
    indent: 0em,
    body-indent: 0.55em,
    spacing: 0.52em,
    marker: [•],
  ),
)

#let _style-group(overrides, name) = {
  let supplied = overrides.at(name, default: (:))
  _assert-dictionary(supplied, "Style group \"" + name + "\"")

  let defaults = default-style.at(name)
  for key in supplied.keys() {
    assert(
      key in defaults,
      message: "Unknown style key \"" + name + "." + key + "\".",
    )
  }
  defaults + supplied
}

#let _resolve-style(overrides) = {
  _assert-dictionary(overrides, "Resume style")
  for group in overrides.keys() {
    assert(
      group in default-style,
      message: "Unknown style group \"" + group + "\".",
    )
  }

  (
    page: _style-group(overrides, "page"),
    colors: _style-group(overrides, "colors"),
    typography: _style-group(overrides, "typography"),
    header: _style-group(overrides, "header"),
    columns: _style-group(overrides, "columns"),
    sections: _style-group(overrides, "sections"),
    entries: _style-group(overrides, "entries"),
    skills: _style-group(overrides, "skills"),
    list: _style-group(overrides, "list"),
  )
}

#let _fallback(value, fallback) = if value == auto { fallback } else { value }

#let _resolve-stroke(value, color) = if type(value) == function {
  value(color)
} else {
  value
}

#let _entry-body(body) = {
  if body == none {
    none
  } else if type(body) == array {
    list(..body)
  } else {
    body
  }
}

#let _section-heading(title, style) = {
  let colors = style.colors
  let typography = style.typography
  let sections = style.sections
  let section-font = _fallback(typography.section-font, typography.label-font)
  let rule-stroke = _resolve-stroke(sections.rule-stroke, colors.hairline)

  v(sections.before)
  grid(
    columns: sections.title-columns,
    column-gutter: sections.title-rule-gap,
    text(
      font: section-font,
      size: sections.title-size,
      weight: sections.title-weight,
      fill: colors.accent,
      tracking: sections.title-tracking,
      (sections.title-transform)(title),
    ),
    line(
      length: sections.rule-length,
      stroke: rule-stroke,
      start: sections.rule-start,
    ),
  )
  v(sections.after)
}

#let _divider(style) = {
  let colors = style.colors
  let entries = style.entries
  let stroke = _resolve-stroke(entries.divider-stroke, colors.hairline)

  v(entries.divider-before)
  line(length: entries.divider-length, stroke: stroke)
  v(entries.divider-after)
}

#let _render-entry(item, compact, inline-organisation, style) = {
  let colors = style.colors
  let typography = style.typography
  let entries = style.entries

  grid(
    columns: entries.heading-columns,
    column-gutter: entries.column-gutter,
    [
      #text(
        font: typography.body-font,
        size: if compact {
          entries.compact-title-size
        } else {
          entries.title-size
        },
        weight: entries.title-weight,
        item.title,
      )
      #if inline-organisation and item.organisation != none {
        h(entries.metadata-gap)
        text(
          font: typography.body-font,
          size: entries.inline-organisation-size,
          fill: colors.muted,
        )[
          #entries.metadata-separator #item.organisation
        ]
      }
    ],
    if item.dates == none {
      []
    } else {
      text(
        font: typography.body-font,
        size: entries.dates-size,
        fill: colors.muted,
        item.dates,
      )
    },
  )

  if not inline-organisation and item.organisation != none {
    text(
      font: typography.body-font,
      size: if compact {
        entries.compact-organisation-size
      } else {
        entries.organisation-size
      },
      style: entries.organisation-style,
      fill: colors.muted,
      item.organisation,
    )
    if item.subtitle != none {
      h(entries.metadata-gap)
      text(
        font: typography.label-font,
        size: entries.subtitle-size,
        fill: colors.muted,
      )[
        #entries.metadata-separator #item.subtitle
      ]
    }
  } else if item.subtitle != none {
    text(
      font: typography.label-font,
      size: entries.subtitle-size,
      fill: colors.muted,
      item.subtitle,
    )
  }

  if item.body != none {
    v(entries.body-before)
    set text(
      size: if compact {
        entries.compact-body-size
      } else {
        entries.body-size
      },
    )
    set par(
      leading: if compact {
        entries.compact-body-leading
      } else {
        entries.body-leading
      },
    )
    _entry-body(item.body)
  }
  v(if compact { entries.compact-after } else { entries.after })
}

#let _render-entries(section, style) = {
  for (index, item) in section.entries.enumerate() {
    _render-entry(
      item,
      section.compact,
      section.inline-organisation,
      style,
    )
    if index < section.entries.len() - 1 {
      _divider(style)
    }
  }
}

#let _render-skills(section, style) = {
  let typography = style.typography
  let skills = style.skills
  let cells = section
    .rows
    .map(row => (
      text(
        font: typography.body-font,
        size: skills.size,
        weight: skills.label-weight,
        row.label,
      ),
      row.value,
    ))
    .flatten()

  set text(size: skills.size)
  grid(
    columns: skills.columns,
    row-gutter: skills.row-gutter,
    ..cells,
  )
}

#let _render-section(section, style) = {
  _section-heading(section.title, style)
  if section.kind == "entries" {
    _render-entries(section, style)
  } else if section.kind == "skills" {
    _render-skills(section, style)
  } else {
    assert(false, message: "Unknown section kind \"" + section.kind + "\".")
  }
}

#let _render-sections(sections, style) = {
  for section in sections {
    _render-section(section, style)
  }
}

#let _render-contact(item) = if item.url == none {
  item.value
} else {
  link(item.url, item.value)
}

#let resume(
  body,
  name: none,
  contacts: (),
  profile: none,
  main-sections: (),
  aside-sections: (),
  full-sections: (),
  language: "en",
  document-title: "Resume",
  footer: none,
  style: (:),
) = {
  assert(name != none, message: "Resume name is required.")
  _assert-array(contacts, "Contacts")
  _assert-array(main-sections, "Main sections")
  _assert-array(aside-sections, "Aside sections")
  _assert-array(full-sections, "Full-width sections")

  let style = _resolve-style(style)
  let page-style = style.page
  let colors = style.colors
  let typography = style.typography
  let header = style.header
  let columns = style.columns
  let list-style = style.list
  let link-fill = _fallback(colors.link, colors.muted)
  let emphasis-fill = _fallback(colors.emphasis, colors.muted)
  let emphasis-font = _fallback(
    typography.emphasis-font,
    typography.body-font,
  )
  let marker-fill = _fallback(colors.marker, colors.accent)
  let footer-fill = _fallback(page-style.footer-fill, colors.muted)
  let header-rule-stroke = _resolve-stroke(
    header.rule-stroke,
    colors.accent,
  )
  let column-divider-stroke = _resolve-stroke(
    columns.divider-stroke,
    colors.hairline,
  )
  let rendered-contacts = contacts.map(_render-contact)

  set document(title: document-title)
  set text(
    font: typography.body-font,
    size: typography.base-size,
    fill: colors.ink,
    lang: language,
  )
  set page(
    paper: page-style.paper,
    fill: page-style.fill,
    margin: page-style.margin,
    footer: if footer == none {
      none
    } else {
      align(
        page-style.footer-alignment,
        text(
          font: typography.body-font,
          size: page-style.footer-size,
          fill: footer-fill,
          footer,
        ),
      )
    },
  )
  set par(
    justify: typography.paragraph-justify,
    leading: typography.paragraph-leading,
  )
  set list(
    indent: list-style.indent,
    body-indent: list-style.body-indent,
    spacing: list-style.spacing,
    marker: text(fill: marker-fill, list-style.marker),
  )
  show link: set text(fill: link-fill)
  show emph: set text(
    font: emphasis-font,
    style: typography.emphasis-style,
    fill: emphasis-fill,
  )

  text(
    font: typography.display-font,
    size: header.name-size,
    weight: header.name-weight,
    tracking: header.name-tracking,
    name,
  )
  v(header.name-after-gap)

  if rendered-contacts.len() > 0 {
    text(
      font: typography.label-font,
      size: header.contact-size,
      fill: colors.muted,
    )[
      #rendered-contacts.join([
        #h(header.contact-separator-gap)
        #text(fill: marker-fill, header.contact-separator)
        #h(header.contact-separator-gap)
      ])
    ]
  }

  line(length: header.rule-length, stroke: header-rule-stroke)
  if profile != none {
    text(
      font: typography.label-font,
      size: header.profile-size,
      weight: header.profile-weight,
      profile,
    )
  }

  if main-sections.len() > 0 and aside-sections.len() > 0 {
    grid(
      columns: columns.widths,
      column-gutter: columns.gutter,
      [#_render-sections(main-sections, style)],
      grid.cell(
        stroke: (left: column-divider-stroke),
        inset: (left: columns.aside-inset),
      )[
        #_render-sections(aside-sections, style)
      ],
    )
  } else if main-sections.len() > 0 or aside-sections.len() > 0 {
    let sections = if main-sections.len() > 0 {
      main-sections
    } else {
      aside-sections
    }
    _render-sections(sections, style)
  }

  if full-sections.len() > 0 {
    v(columns.full-section-gap)
    _render-sections(full-sections, style)
  }

  body

  context [
    #metadata(counter(page).final().first()) <resume-page-count>
  ]
}
