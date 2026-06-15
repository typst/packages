// Ortic Solutions GmbH — Technical Specification Template
// Brand colors derived from ortic.com
#let ortic-blue = rgb("#008fff")
#let ortic-blue-dark = rgb("#0066b8")
#let ortic-gray = rgb("#959283")
#let ortic-ink = rgb("#1a1a1a")
#let ortic-muted = rgb("#5a5a5a")
#let ortic-soft = rgb("#f5f5f3")
#let ortic-rule = rgb("#e2e0db")

#let ortic-spec(
  title: "Technical Specification",
  subtitle: none,
  project: none,
  document-id: none,
  version: "1.0",
  status: "Draft",
  date: datetime.today(),
  authors: (),
  reviewers: (),
  client: none,
  classification: "Confidential",
  logo: "logo.png",
  abstract: none,
  revisions: (),
  // Set compact: true for short documents to avoid a page break before each
  // level-1 heading. Recommended when the body has only a few short sections.
  compact: false,
  // Set toc: false to omit the Table of Contents (useful for short documents).
  toc: true,
  body,
) = {
  set document(title: title, author: authors.map(a => a.name).join(", "))
  set page(
    paper: "a4",
    margin: (top: 3.2cm, bottom: 2.6cm, left: 2.4cm, right: 2.4cm),
    header: context {
      if counter(page).get().first() > 1 {
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          [
            #set text(size: 8pt, fill: ortic-muted)
            #text(weight: "semibold", fill: ortic-ink)[#title]
            #if document-id != none [
              #h(0.6em) #text(fill: ortic-rule)[|] #h(0.6em) #document-id
            ]
          ],
          [
            #set text(size: 8pt, fill: ortic-muted)
            v #version #h(0.6em) #text(fill: ortic-rule)[|] #h(0.6em) #status
          ],
        )
        v(-0.4em)
        line(length: 100%, stroke: 0.6pt + ortic-blue)
      }
    },
    footer: context {
      let n = counter(page).get().first()
      let total = counter(page).final().first()
      line(length: 100%, stroke: 0.4pt + ortic-rule)
      v(-0.2em)
      grid(
        columns: (1fr, 1fr, 1fr),
        align: (left + horizon, center + horizon, right + horizon),
        text(size: 8pt, fill: ortic-muted)[Ortic Solutions GmbH],
        text(size: 8pt, fill: ortic-muted)[#classification],
        text(size: 8pt, fill: ortic-muted)[Page #n of #total],
      )
    },
  )

  // "Open Sans" is bundled under ./fonts (matches ortic.com brand).
  // Compile with `typst compile --font-path fonts example.typ`.
  // Liberation Sans / DejaVu Sans are graceful fallbacks if --font-path is omitted.
  set text(
    font: ("Open Sans", "Liberation Sans", "DejaVu Sans"),
    size: 10.5pt,
    fill: ortic-ink,
    lang: "en",
  )
  set par(justify: true, leading: 0.72em, spacing: 1.1em, first-line-indent: 0pt)

  // Looser spacing for bullet and numbered lists
  set list(spacing: 0.9em, indent: 0.6em, body-indent: 0.6em)
  set enum(spacing: 0.9em, indent: 0.6em, body-indent: 0.6em)
  show list: set par(leading: 0.85em)
  show enum: set par(leading: 0.85em)

  // Headings
  show heading: set block(above: 1.8em, below: 1.0em)
  show heading.where(level: 1): it => {
    if not compact { pagebreak(weak: true) }
    block(width: 100%, above: if compact { 2.2em } else { 1.6em }, below: 1.2em)[
      #set text(size: 22pt, weight: "bold", fill: ortic-ink)
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.7em,
        align: (left + horizon, left + horizon),
        rect(width: 5pt, height: 1em, fill: ortic-blue, stroke: none),
        counter(heading).display() + h(0.5em) + it.body,
      )
      #v(-0.4em)
      #line(length: 100%, stroke: 0.6pt + ortic-rule)
    ]
  }
  show heading.where(level: 2): it => block(above: 1.8em, below: 1.0em)[
    #set text(size: 14pt, weight: "semibold", fill: ortic-blue-dark)
    #counter(heading).display() #h(0.5em) #it.body
  ]
  show heading.where(level: 3): it => block(above: 1.5em, below: 0.8em)[
    #set text(size: 11.5pt, weight: "semibold", fill: ortic-ink)
    #counter(heading).display() #h(0.4em) #it.body
  ]
  show heading.where(level: 4): it => block(above: 1.3em, below: 0.6em)[
    #set text(size: 10.5pt, weight: "semibold", fill: ortic-muted, style: "italic")
    #it.body
  ]
  set heading(numbering: "1.1.1.")

  // Links
  show link: it => text(fill: ortic-blue-dark, weight: "semibold")[#underline(stroke: 0.4pt + ortic-blue-dark, offset: 2pt, it)]

  // Code
  show raw.where(block: false): it => box(
    fill: ortic-soft,
    inset: (x: 4pt, y: 1pt),
    outset: (y: 2pt),
    radius: 2pt,
    text(font: "DejaVu Sans Mono", size: 0.92em, fill: ortic-blue-dark, it),
  )
  show raw.where(block: true): it => block(
    width: 100%,
    fill: ortic-soft,
    inset: 12pt,
    radius: 3pt,
    stroke: (left: 2pt + ortic-blue),
    text(font: "DejaVu Sans Mono", size: 9pt, it),
  )

  // Tables
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt + ortic-ink } else if y == 1 { 0.6pt + ortic-blue } else { 0.3pt + ortic-rule },
      bottom: 0.3pt + ortic-rule,
    ),
    inset: (x: 8pt, y: 6pt),
    fill: (_, y) => if y == 0 { ortic-soft },
  )
  show table.cell.where(y: 0): set text(weight: "semibold", fill: ortic-ink)

  // ---------- COVER PAGE ----------
  let meta-entries = ()
  if project != none { meta-entries.push(("Project", project)) }
  if client != none { meta-entries.push(("Client", client)) }
  if document-id != none { meta-entries.push(("Document ID", document-id)) }
  meta-entries.push(("Version", version))
  meta-entries.push(("Status", status))
  meta-entries.push(("Date", date.display("[year]-[month]-[day]")))
  meta-entries.push(("Classification", classification))

  // Build authors / reviewers block as a separate function for cover footer
  let cover-people = {
    grid(
      columns: (1fr, 1fr),
      column-gutter: 1cm,
      {
        text(size: 8.5pt, fill: ortic-muted, weight: "semibold", tracking: 1pt)[#upper[Authors]]
        v(0.3em)
        set text(size: 9.5pt, fill: ortic-ink)
        for a in authors {
          [#a.name]
          if "role" in a { text(fill: ortic-muted)[ — #a.role] }
          linebreak()
        }
      },
      if reviewers.len() > 0 {
        text(size: 8.5pt, fill: ortic-muted, weight: "semibold", tracking: 1pt)[#upper[Reviewers]]
        v(0.3em)
        set text(size: 9.5pt, fill: ortic-ink)
        for r in reviewers {
          [#r.name]
          if "role" in r { text(fill: ortic-muted)[ — #r.role] }
          linebreak()
        }
      } else [],
    )
  }

  page(
    margin: (top: 2.4cm, bottom: 2.0cm, left: 2.4cm, right: 2.4cm),
    header: none,
    footer: none,
    background: place(
      bottom + left,
      rect(
        width: 100%,
        height: 30%,
        fill: gradient.linear(
          rgb(255, 255, 255, 0),
          ortic-soft,
          angle: 90deg,
        ),
      ),
    ),
    {
      // ---- Header: logo + accent rule ----
      if logo != none {
        image(logo, width: 4.5cm)
      }
      v(0.4cm)
      line(length: 100%, stroke: 0.8pt + ortic-blue)

      v(2.2cm)

      // ---- Eyebrow + title block ----
      text(size: 9pt, weight: "semibold", fill: ortic-blue, tracking: 2pt)[TECHNICAL SPECIFICATION]
      v(0.4cm)
      block[
        #set text(size: 30pt, weight: "bold", fill: ortic-ink)
        #set par(leading: 0.4em)
        #title
      ]
      if subtitle != none {
        v(0.2cm)
        block[
          #set text(size: 15pt, weight: "regular", fill: ortic-muted)
          #set par(leading: 0.5em)
          #subtitle
        ]
      }

      v(2.0cm)

      // ---- Meta block: blue accent bar + key/value grid ----
      block(
        stroke: (left: 3pt + ortic-blue),
        inset: (left: 1em, top: 0pt, bottom: 0pt, right: 0pt),
        table(
          columns: (4.5cm, 1fr),
          stroke: none,
          inset: (x: 0pt, y: 5pt),
          fill: none,
          ..meta-entries.map(((l, v)) => (
            text(size: 8.5pt, weight: "semibold", fill: ortic-muted, tracking: 1pt)[#upper(l)],
            text(size: 10.5pt, weight: "semibold", fill: ortic-ink, v),
          )).flatten()
        ),
      )

      // ---- Authors/reviewers + imprint placed at the bottom of the cover ----
      place(
        bottom + left,
        dy: 0pt,
        block(width: 100%)[
          #if authors.len() > 0 or reviewers.len() > 0 [
            #line(length: 100%, stroke: 0.4pt + ortic-rule)
            #v(0.3cm)
            #cover-people
            #v(0.4cm)
          ]
          #line(length: 100%, stroke: 0.4pt + ortic-rule)
          #v(0.3cm)
          #align(center)[
            #set text(size: 8pt, fill: ortic-muted)
            Ortic Solutions GmbH #sym.dot.c Riedmattweg 9 #sym.dot.c CH-6052 Hergiswil #sym.dot.c www.ortic.com
          ]
        ],
      )
    },
  )

  // Reset page counter so body starts at page 1
  counter(page).update(1)

  // Helper: section heading used before the body (no numbering)
  let frontmatter-title(body) = block(below: 0.6em)[
    #set text(size: 18pt, weight: "bold", fill: ortic-ink)
    #body
    #v(-0.4em)
    #line(length: 6em, stroke: 1pt + ortic-blue)
  ]

  // ---------- REVISION HISTORY ----------
  if revisions.len() > 0 {
    frontmatter-title[Revision History]
    table(
      columns: (auto, auto, 1fr, auto),
      table.header[Version][Date][Description][Author],
      ..revisions.map(r => (
        r.version,
        r.date,
        r.description,
        r.author,
      )).flatten()
    )
    v(0.6cm)
  }

  // ---------- ABSTRACT ----------
  if abstract != none {
    block(
      width: 100%,
      fill: ortic-soft,
      inset: 16pt,
      radius: 3pt,
      stroke: (left: 3pt + ortic-blue),
      [
        #text(size: 9pt, weight: "semibold", fill: ortic-blue, tracking: 1.5pt)[#upper[Abstract]]
        #v(0.3em)
        #set text(size: 10.5pt, fill: ortic-ink, style: "italic")
        #abstract
      ],
    )
    v(0.6cm)
  }

  // ---------- TABLE OF CONTENTS ----------
  if toc {
    pagebreak(weak: true)
    frontmatter-title[Table of Contents]
    set text(size: 10.5pt)
    show outline.entry.where(level: 1): it => {
      v(0.5em, weak: true)
      strong(it)
    }
    outline(
      title: none,
      indent: auto,
      depth: 3,
    )
  }

  // ---------- BODY ----------
  body
}

// ---------- HELPER COMPONENTS ----------

#let callout(kind: "note", title: none, body) = {
  let palette = (
    note: (color: rgb("#008fff"), bg: rgb("#eef7ff"), label: "NOTE"),
    info: (color: rgb("#0066b8"), bg: rgb("#e7f1fb"), label: "INFO"),
    warning: (color: rgb("#d88a00"), bg: rgb("#fdf4e3"), label: "WARNING"),
    important: (color: rgb("#c0392b"), bg: rgb("#fbeae7"), label: "IMPORTANT"),
    success: (color: rgb("#2e8b57"), bg: rgb("#e8f4ed"), label: "SUCCESS"),
  )
  let p = palette.at(kind, default: palette.note)
  block(
    width: 100%,
    fill: p.bg,
    inset: 12pt,
    radius: 3pt,
    stroke: (left: 3pt + p.color),
    [
      #text(size: 8.5pt, weight: "bold", fill: p.color, tracking: 1.5pt)[#p.label]
      #if title != none [ #text(size: 10pt, weight: "semibold")[ — #title] ]
      #v(0.3em)
      #body
    ],
  )
}

#let req(id, priority: "MUST", body) = {
  let priority-colors = (
    "MUST": rgb("#c0392b"),
    "SHOULD": rgb("#d88a00"),
    "MAY": rgb("#5a5a5a"),
  )
  let c = priority-colors.at(priority, default: rgb("#5a5a5a"))
  block(
    width: 100%,
    inset: (x: 12pt, y: 8pt),
    stroke: (left: 2pt + ortic-blue, rest: 0.3pt + ortic-rule),
    radius: 2pt,
    [
      #grid(
        columns: (auto, auto, 1fr),
        column-gutter: 0.6em,
        align: (left + horizon, left + horizon, left + horizon),
        text(font: "DejaVu Sans Mono", size: 9pt, weight: "bold", fill: ortic-blue-dark)[#id],
        box(
          fill: c,
          inset: (x: 5pt, y: 1pt),
          radius: 2pt,
          text(size: 7.5pt, weight: "bold", fill: white, tracking: 1pt)[#priority],
        ),
        text(size: 10pt)[#body],
      )
    ],
  )
}

#let kv-list(..entries) = {
  table(
    columns: (auto, 1fr),
    column-gutter: 1.5em,
    stroke: (x, y) => (bottom: 0.3pt + ortic-rule),
    inset: (x: 0pt, y: 6pt),
    fill: none,
    ..entries.pos().map(((k, v)) => (
      text(weight: "semibold", fill: ortic-muted)[#k],
      [#v],
    )).flatten()
  )
}
