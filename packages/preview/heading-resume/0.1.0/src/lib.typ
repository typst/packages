#let _assert-array(value, name) = assert(
  type(value) == array,
  message: name + " must be an array.",
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

#let _entry-body(body) = {
  if body == none {
    none
  } else if type(body) == array {
    list(..body)
  } else {
    body
  }
}

#let _section-heading(title, accent, hairline, label-font, size) = {
  v(0.3em)
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.75em,
    text(
      font: label-font,
      size: size,
      weight: "semibold",
      fill: accent,
      tracking: 0.8pt,
      upper(title),
    ),
    line(length: 100%, stroke: 0.55pt + hairline, start: (0em, 0.42em)),
  )
  v(0.38em)
}

#let _divider(hairline) = {
  v(-0.6em)
  line(
    length: 100%,
    stroke: (paint: hairline, thickness: 0.6pt, dash: "dotted"),
  )
  v(-0.2em)
}

#let _render-entry(
  item,
  compact,
  inline-organisation,
  body-font,
  label-font,
  muted,
  scaled,
) = {
  grid(
    columns: (1fr, auto),
    column-gutter: 0.65em,
    [
      #text(
        font: body-font,
        size: if compact { scaled(8.2) } else { scaled(8.8) },
        weight: "bold",
        item.title,
      )
      #if inline-organisation and item.organisation != none {
        h(0.18em)
        text(
          font: body-font,
          size: scaled(7.75),
          fill: muted,
        )[· #item.organisation]
      }
    ],
    if item.dates == none {
      []
    } else {
      text(font: body-font, size: scaled(7.3), fill: muted, item.dates)
    },
  )

  if not inline-organisation and item.organisation != none {
    text(
      font: body-font,
      size: if compact { scaled(7.45) } else { scaled(8.05) },
      style: "italic",
      fill: muted,
      item.organisation,
    )
    if item.subtitle != none {
      h(0.18em)
      text(font: label-font, size: scaled(7.05), fill: muted)[· #item.subtitle]
    }
  } else if item.subtitle != none {
    text(font: label-font, size: scaled(7.05), fill: muted, item.subtitle)
  }

  if item.body != none {
    v(-0.12em)
    set text(size: if compact { scaled(7.5) } else { scaled(8.05) })
    set par(leading: if compact { 0.32em } else { 0.4em })
    _entry-body(item.body)
  }
  v(if compact { 0.22em } else { 0.32em })
}

#let _render-entries(
  section,
  body-font,
  label-font,
  muted,
  hairline,
  scaled,
) = {
  for (index, item) in section.entries.enumerate() {
    _render-entry(
      item,
      section.compact,
      section.inline-organisation,
      body-font,
      label-font,
      muted,
      scaled,
    )
    if index < section.entries.len() - 1 {
      _divider(hairline)
    }
  }
}

#let _render-skills(section, body-font, scaled) = {
  let cells = section
    .rows
    .map(row => (
      text(font: body-font, size: scaled(7.7), weight: "bold", row.label),
      row.value,
    ))
    .flatten()

  set text(size: scaled(7.7))
  grid(
    columns: (7.8em, 1fr),
    row-gutter: 0.62em,
    ..cells,
  )
}

#let _render-section(
  section,
  accent,
  muted,
  hairline,
  body-font,
  label-font,
  section-font,
  scaled,
) = {
  _section-heading(section.title, accent, hairline, section-font, scaled(9.5))
  if section.kind == "entries" {
    _render-entries(section, body-font, label-font, muted, hairline, scaled)
  } else if section.kind == "skills" {
    _render-skills(section, body-font, scaled)
  } else {
    assert(false, message: "Unknown section kind \"" + section.kind + "\".")
  }
}

#let _render-sections(
  sections,
  accent,
  muted,
  hairline,
  body-font,
  label-font,
  section-font,
  scaled,
) = {
  for section in sections {
    _render-section(
      section,
      accent,
      muted,
      hairline,
      body-font,
      label-font,
      section-font,
      scaled,
    )
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
  accent: rgb("cf3f2f"),
  paper-fill: rgb("fffdf9"),
  ink: rgb("17191d"),
  muted: rgb("5f6268"),
  page-paper: "a4",
  page-margin: (x: 11.5mm, top: 9.5mm, bottom: 6.5mm),
  language: "en",
  document-title: "Resume",
  display-font: "Libertinus Serif",
  body-font: "Libertinus Serif",
  label-font: "Libertinus Serif",
  section-font: none,
  text-size: 11pt,
  footer: none,
) = {
  assert(name != none, message: "Resume name is required.")
  _assert-array(contacts, "Contacts")
  _assert-array(main-sections, "Main sections")
  _assert-array(aside-sections, "Aside sections")
  _assert-array(full-sections, "Full-width sections")
  let hairline = rgb("c9c4bd")
  let scaled(points) = text-size * points / 9.2
  let rendered-contacts = contacts.map(_render-contact)
  let resolved-section-font = if section-font == none {
    label-font
  } else {
    section-font
  }

  set document(title: document-title)
  set page(
    paper: page-paper,
    fill: paper-fill,
    margin: page-margin,
    footer: if footer == none {
      none
    } else {
      align(right, text(font: body-font, size: 6.8pt, fill: muted, footer))
    },
  )
  set text(font: body-font, size: text-size, fill: ink, lang: language)
  set par(justify: false, leading: 0.42em)
  set list(
    indent: 0em,
    body-indent: 0.55em,
    spacing: 0.52em,
    marker: text(fill: accent)[•],
  )
  show link: set text(fill: muted)
  show emph: set text(font: body-font, style: "italic", fill: muted)

  text(
    font: display-font,
    size: scaled(38),
    weight: "regular",
    tracking: -0.7pt,
    name,
  )
  v(-2.6em)

  if rendered-contacts.len() > 0 {
    text(font: label-font, size: scaled(5.3), fill: muted)[
      #rendered-contacts.join([
        #h(0.5em)#text(fill: accent)[•]#h(0.5em)
      ])
    ]
  }

  line(length: 100%, stroke: 1.15pt + accent)
  if profile != none {
    text(
      font: label-font,
      size: scaled(8.45),
      weight: "medium",
      profile,
    )
  }

  if main-sections.len() > 0 and aside-sections.len() > 0 {
    grid(
      columns: (1.62fr, 1fr),
      column-gutter: 4mm,
      [
        #_render-sections(
          main-sections,
          accent,
          muted,
          hairline,
          body-font,
          label-font,
          resolved-section-font,
          scaled,
        )
      ],
      grid.cell(
        stroke: (left: 0.55pt + hairline),
        inset: (left: 5mm),
      )[
        #_render-sections(
          aside-sections,
          accent,
          muted,
          hairline,
          body-font,
          label-font,
          resolved-section-font,
          scaled,
        )
      ],
    )
  } else if main-sections.len() > 0 or aside-sections.len() > 0 {
    let sections = if main-sections.len() > 0 {
      main-sections
    } else {
      aside-sections
    }
    _render-sections(
      sections,
      accent,
      muted,
      hairline,
      body-font,
      label-font,
      resolved-section-font,
      scaled,
    )
  }

  if full-sections.len() > 0 {
    v(0.28em)
    _render-sections(
      full-sections,
      accent,
      muted,
      hairline,
      body-font,
      label-font,
      resolved-section-font,
      scaled,
    )
  }

  body

  context [
    #metadata(counter(page).final().first()) <resume-page-count>
  ]
}
