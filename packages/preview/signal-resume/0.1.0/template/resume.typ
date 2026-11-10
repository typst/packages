// Signal Resume
// ATS-first, single-column Typst resume framework.

#let resume(
  body,
  name: "Your Name",
  headline: none,
  contact: (),
  summary: none,
  skills: (),
  experience: (),
  education: (),
  featured-sections: (),
  sections: (),
  body-font: "New Computer Modern",
  page-size: "us-letter",
  list-spacing: 0.34em,
) = {
  set document(title: name, author: name)
  set page(
    paper: page-size,
    margin: 18mm,
    header: none,
    footer: none,
  )
  set text(font: body-font, size: 11pt, fill: rgb("181818"))
  set par(leading: 0.55em, justify: false)
  set list(indent: 1.15em, body-indent: 0.42em, spacing: list-spacing, marker: [•])

  let section-heading(title) = {
    v(0.42em)
    grid(
      columns: (1fr,),
      row-gutter: 0.18em,
      text(size: 12pt, weight: "bold", upper(title)),
      line(length: 100%, stroke: 0.6pt + rgb("444444")),
    )
    v(0.16em)
  }

  let contact-line(items) = {
    align(center)[
      #items.filter(item => item != none and item != "").join([ #sym.dot.c ])
    ]
  }

  let dated-entry(entry) = {
    block(width: 100%)[
      #strong(entry.organization)
      #v(0.24em)
      #text(size: 10.8pt, entry.title)
      #if entry.location != none {
        [ — #text(size: 10.8pt, fill: rgb("555555"), entry.location)]
      }
      #text(size: 10.8pt, fill: rgb("333333"))[ | #entry.dates]
    ]
    if entry.description != none {
      v(0.12em)
      emph(entry.description)
    }
    if entry.bullets.len() > 0 {
      v(0.06em)
      list(..entry.bullets)
    }
    v(0.34em)
  }

  let education-entry(entry) = {
    block(width: 100%)[
      #strong(entry.institution)
      #v(0.24em)
      #text(size: 10.8pt, weight: "medium", entry.credential)
      | #entry.dates
    ]
    v(0.34em)
  }

  let render-custom(section) = {
    section-heading(section.title)
    if section.kind == "bullets" {
      list(..section.items)
    } else if section.kind == "labeled" {
      grid(
        columns: (1fr,),
        row-gutter: 0.48em,
        ..section.items.map(item => [#strong(item.label): #item.value]),
      )
      v(0.34em)
    } else if section.kind == "entries" {
      for item in section.items { dated-entry(item) }
    } else {
      section.content
    }
  }

  if headline != none {
    align(center, grid(
      columns: (auto,),
      row-gutter: 0.68em,
      align: center,
      [#text(size: 21pt, weight: "bold", name)],
      [#text(size: 11.2pt, weight: "medium", fill: rgb("333333"), headline)],
      [#text(size: 10pt, fill: rgb("444444"), contact-line(contact))],
    ))
  } else {
    align(center, grid(
      columns: (auto,),
      row-gutter: 0.68em,
      align: center,
      [#text(size: 21pt, weight: "bold", name)],
      [#text(size: 10pt, fill: rgb("444444"), contact-line(contact))],
    ))
  }

  if summary != none {
    v(0.20em)
    section-heading("Summary")
    text(size: 11pt, summary)
  }

  if skills.len() > 0 {
    section-heading("Technical Skills")
    for group in skills {
      text(size: 11pt)[#strong(group.label): #group.items.join(", ")]
      linebreak()
    }
  }

  if experience.len() > 0 {
    section-heading("Experience")
    for entry in experience {
      dated-entry((
        organization: entry.company,
        title: entry.role,
        location: entry.location,
        dates: entry.dates,
        description: entry.description,
        bullets: entry.bullets,
      ))
    }
  }

  for featured-section in featured-sections {
    render-custom(featured-section)
  }

  if education.len() > 0 {
    block(breakable: false)[
      #section-heading("Education")
      #education-entry(education.first())
    ]
    for entry in education.slice(1) {
      education-entry(entry)
    }
  }

  for custom-section in sections {
    render-custom(custom-section)
  }
}
