#import "theme.typ": active-theme
#import "helpers.typ": format-date, get-meta-pairs, render-cover-divider, render-cover-logo

#let _unpack-info(title-or-info, logo-or-subtitle, args) = {
  if type(title-or-info) == dictionary {
    (title-or-info, logo-or-subtitle)
  } else {
    let pos = args.pos()
    let named = args.named()
    let info = (
      title: title-or-info,
      subtitle: logo-or-subtitle,
      course: pos.at(0, default: none),
      assignment: pos.at(1, default: none),
      stu-name: pos.at(2, default: none),
      stu-id: pos.at(3, default: none),
      instructor: pos.at(4, default: none),
      department: pos.at(5, default: none),
      university: pos.at(6, default: none),
      semester: pos.at(7, default: none),
      section: pos.at(8, default: none),
      date-str: pos.at(9, default: none),
      scale: named.at("scale", default: none),
      doc-ref: named.at("doc-ref", default: none),
      rev: named.at("rev", default: none),
    )
    (info, pos.at(10, default: none))
  }
}

#let _get-meta(info, include-inst: false) = {
  get-meta-pairs(
    info.at("stu-name", default: none),
    info.at("stu-id", default: none),
    info.at("instructor", default: none),
    info.at("date-str", default: none),
    info.at("university", default: none),
    info.at("department", default: none),
    info.at("semester", default: none),
    info.at("section", default: none),
    include-inst: include-inst,
  )
}

#let _render-header-row(th, info, logo, max-height: 1.8cm, tracking: 0.12em) = {
  grid(
    columns: (1fr, auto),
    align: (left + top, right + top),
    [
      #if info.at("university", default: none) != none [
        #text(size: 10pt, weight: "bold", tracking: tracking, fill: th.primary)[#upper(info.university)]
      ]
      #if info.at("department", default: none) != none [
        #v(0.15cm)
        #text(size: 9pt, weight: "medium", fill: th.text-muted)[#info.department]
      ]
    ],
    render-cover-logo(logo, max-height: max-height),
  )
}

#let _render-meta-cell(th, label, val, label-size: 7.5pt, val-size: 9.5pt, font: none) = [
  #text(
    size: label-size,
    weight: "bold",
    tracking: 0.12em,
    fill: th.text-muted,
    ..if font != none { (font: font) } else { (:) },
  )[#label] \
  #v(3pt)
  #text(size: val-size, weight: "bold", fill: th.text)[#val]
]

#let _render-meta-grid(
  th,
  pairs,
  cols: auto,
  column-gutter: 1.5cm,
  row-gutter: 0.8cm,
  grid-align: left + horizon,
  label-size: 7.5pt,
  val-size: 9.5pt,
  font: none,
) = {
  let effective-cols = if cols != auto { cols } else { (1fr,) * calc.min(pairs.len(), 4) }
  grid(
    columns: effective-cols,
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    align: grid-align,
    ..pairs.map(((l, v)) => _render-meta-cell(th, l, v, label-size: label-size, val-size: val-size, font: font))
  )
}

#let _render-cover-title(
  th,
  info,
  title-size: 28pt,
  sub-size: 12pt,
  sub-style: "normal",
  sub-weight: "regular",
  v-space: 0.6cm,
) = [
  #set par(justify: false)
  #set text(hyphenate: false)
  #text(size: title-size, weight: "bold", fill: th.primary)[#info.at("title", default: "")]
  #if info.at("subtitle", default: none) != none [
    #v(v-space)
    #text(size: sub-size, fill: th.text-muted, style: sub-style, weight: sub-weight)[#info.subtitle]
  ]
]

#let _get-tag-str(info, keys: ("course", "assignment"), sep: "  ·  ") = {
  let vals = keys.map(k => info.at(k, default: none)).filter(it => it != none and it != "")
  if vals.len() > 0 { vals.join(sep) } else { none }
}

#let render-cover-modern(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, height: 100%)[
    #rect(width: 100%, height: 4pt, fill: th.primary, radius: 2pt)
    #v(0.6cm)
    #_render-header-row(th, info, logo)
    #v(1.4fr)

    #let badges = ()
    #if info.at("course", default: none) != none {
      badges.push(box(
        fill: th.primary.lighten(92%),
        inset: (x: 10pt, y: 5pt),
        radius: 4pt,
        stroke: 0.5pt + th.primary.lighten(40%),
      )[
        #text(size: 9.5pt, weight: "bold", tracking: 0.08em, fill: th.primary)[#upper(info.course)]
      ])
    }
    #if info.at("assignment", default: none) != none {
      badges.push(box(
        fill: th.accent.lighten(88%),
        inset: (x: 10pt, y: 5pt),
        radius: 4pt,
        stroke: 0.5pt + th.accent.darken(10%),
      )[
        #text(size: 9.5pt, weight: "bold", fill: th.accent.darken(30%))[#info.assignment]
      ])
    }
    #if badges.len() > 0 [
      #stack(dir: ltr, spacing: 0.8em, ..badges)
      #v(0.8cm)
    ]

    #_render-cover-title(th, info)

    #v(0.8cm)
    #line(length: 100%, stroke: 0.6pt + th.border)
    #v(1.6fr)

    #let pairs = _get-meta(info)
    #if pairs.len() > 0 [
      #rect(width: 100%, fill: th.surface, inset: (x: 16pt, y: 14pt), radius: 8pt, stroke: 0.5pt + th.border)[
        #_render-meta-grid(th, pairs, row-gutter: 1cm)
      ]
    ]
    #v(0.4cm)
  ]
}

#let render-cover-swiss(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, height: 100%)[
    #grid(
      columns: (8pt, 1fr),
      column-gutter: 1.4cm,
      stack(
        dir: ttb,
        spacing: 0pt,
        rect(width: 100%, height: 35%, fill: th.primary, radius: (top: 4pt)),
        v(4pt),
        rect(width: 100%, height: 1fr, fill: th.accent, radius: (bottom: 4pt)),
      ),
      [
        #_render-header-row(th, info, logo, max-height: 1.6cm, tracking: 0.15em)
        #v(1.4fr)

        #let tag-str = _get-tag-str(info)
        #if tag-str != none [
          #box(
            fill: th.primary.lighten(92%),
            stroke: 0.8pt + th.primary,
            inset: (x: 10pt, y: 5pt),
            radius: 2pt,
          )[
            #text(size: 9pt, weight: "bold", tracking: 0.22em, fill: th.primary)[#upper(tag-str)]
          ]
          #v(0.6cm)
        ]

        #_render-cover-title(th, info, title-size: 32pt, sub-size: 12pt, v-space: 0.7cm)

        #v(1.6fr)
        #let pairs = _get-meta(info)
        #if pairs.len() > 0 [
          #line(length: 100%, stroke: 0.6pt + th.accent)
          #v(0.8cm)
          #let num-cols = if pairs.len() == 3 { 3 } else { calc.min(pairs.len(), 2) }
          #grid(
            columns: (1fr,) * num-cols,
            column-gutter: 1.2cm,
            row-gutter: 0.9cm,
            ..pairs.map(((lbl, val)) => [
              #box(
                width: 100%,
                fill: th.surface,
                inset: (x: 12pt, y: 10pt),
                radius: 2pt,
                stroke: (left: 3.5pt + th.primary, rest: 0.5pt + th.border),
              )[
                #text(size: 7.5pt, weight: "bold", tracking: 0.15em, fill: th.text-muted)[#lbl] \
                #v(4pt)
                #text(size: 9.5pt, weight: "bold", fill: th.text)[#val]
              ]
            ])
          )
        ]
        #v(0.4cm)
      ],
    )
  ]
}

#let render-cover-geometric(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, height: 100%, clip: true)[
    #place(top + right, dx: 2.2cm, dy: -1.8cm)[
      #circle(radius: 115pt, fill: th.accent.lighten(92%))
    ]
    #place(top + right, dx: -0.2cm, dy: 1cm)[
      #circle(radius: 65pt, stroke: 1.5pt + th.primary.lighten(80%))
    ]
    #place(top + right, dx: 0.8cm, dy: 3.5cm)[
      #rotate(45deg)[#rect(
        width: 55pt,
        height: 55pt,
        fill: th.primary.lighten(94%),
        radius: 10pt,
        stroke: 0.8pt + th.accent.lighten(70%),
      )]
    ]
    #place(top + right, dx: -1.8cm, dy: 6cm)[
      #rotate(45deg)[#square(size: 14pt, fill: th.accent.lighten(85%))]
    ]
    #place(bottom + left, dx: -1.8cm, dy: 1.8cm)[
      #circle(radius: 75pt, fill: th.primary.lighten(96%))
    ]

    #_render-header-row(th, info, logo, max-height: 1.6cm, tracking: 0.12em)
    #v(1.4fr)

    #let tag-str = _get-tag-str(info, sep: "  •  ")
    #if tag-str != none [
      #box(
        fill: th.surface,
        stroke: 0.6pt + th.border,
        inset: (x: 10pt, y: 5pt),
        radius: 6pt,
      )[
        #grid(
          columns: (auto, auto),
          column-gutter: 0.5cm,
          align: horizon,
          rotate(45deg)[#square(size: 6pt, fill: th.accent)],
          text(size: 9.5pt, weight: "bold", tracking: 0.15em, fill: th.accent)[#upper(tag-str)],
        )
      ]
      #v(0.6cm)
    ]

    #_render-cover-title(th, info, title-size: 30pt, sub-size: 11.5pt, v-space: 0.6cm)

    #v(0.8cm)
    #grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0.4cm,
      align: horizon,
      rotate(45deg)[#square(size: 7pt, fill: th.primary)],
      line(length: 100%, stroke: 1pt + th.primary.lighten(60%)),
      rotate(45deg)[#square(size: 7pt, fill: th.accent)],
    )

    #v(1.6fr)
    #let pairs = _get-meta(info)
    #if pairs.len() > 0 [
      #let num-cols = if pairs.len() == 3 { 3 } else { calc.min(pairs.len(), 2) }
      #grid(
        columns: (1fr,) * num-cols, gutter: 12pt,
        ..pairs.map(((lbl, val)) => box(
          width: 100%,
          fill: th.surface,
          inset: (x: 12pt, y: 10pt),
          radius: 8pt,
          stroke: (top: 3pt + th.accent, rest: 0.6pt + th.border),
        )[
          #grid(
            columns: (auto, 1fr),
            column-gutter: 6pt,
            align: horizon,
            rotate(45deg)[#square(size: 4.5pt, fill: th.primary)],
            text(size: 7.5pt, weight: "bold", tracking: 0.12em, fill: th.text-muted)[#lbl],
          )
          #v(4pt)
          #text(size: 9.5pt, weight: "bold", fill: th.text)[#val]
        ])
      )
    ]
    #v(0.4cm)
  ]
}

#let render-cover-architecture(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  let mono-font = ("JetBrains Mono", "DejaVu Sans Mono", "Liberation Mono")
  rect(width: 100%, height: 100%, stroke: 0.8pt + th.primary.lighten(40%), inset: 1.4cm)[
    #block(width: 100%, height: 100%)[
      #place(top + left, dx: -1cm, dy: -1cm)[#text(size: 11pt, font: mono-font, fill: th.primary.lighten(30%))[+]]
      #place(top + right, dx: 1cm, dy: -1cm)[#text(size: 11pt, font: mono-font, fill: th.primary.lighten(30%))[+]]
      #place(bottom + left, dx: -1cm, dy: 1cm)[#text(size: 11pt, font: mono-font, fill: th.primary.lighten(30%))[+]]
      #place(bottom + right, dx: 1cm, dy: 1cm)[#text(size: 11pt, font: mono-font, fill: th.primary.lighten(30%))[+]]

      #_render-header-row(th, info, logo, max-height: 1.5cm, tracking: 0.1em)
      #v(1fr)

      #align(center)[
        #let tag-str = _get-tag-str(info)
        #if tag-str != none [
          #text(size: 9pt, weight: "bold", tracking: 0.2em, fill: th.accent)[#upper(tag-str)]
          #v(0.5cm)
        ]
        #_render-cover-title(th, info, title-size: 26pt, sub-size: 11pt, sub-style: "italic", v-space: 0.5cm)
      ]

      #v(1fr)
      #let tech-items = ()
      #if info.at("scale", default: none) != none { tech-items.push("SCALE: " + str(info.scale)) }
      #if info.at("doc-ref", default: none) != none { tech-items.push("DOC REF: " + str(info.doc-ref)) }
      #if info.at("rev", default: none) != none { tech-items.push("REV: " + str(info.rev)) }
      #if tech-items.len() > 0 [
        #align(center)[
          #text(size: 7.5pt, font: mono-font, fill: th.text-muted, tracking: 0.15em)[
            #tech-items.join("   ·   ")
          ]
        ]
        #v(0.4cm)
      ]

      #let pairs = _get-meta(info)
      #if pairs.len() > 0 [
        #table(
          columns: (1fr,) * pairs.len(),
          stroke: 0.6pt + th.border-dark,
          fill: (x, y) => th.surface,
          inset: 10pt,
          ..pairs.map(((l, v)) => _render-meta-cell(th, l, v, label-size: 7pt, font: mono-font))
        )
      ]
    ]
  ]
}

#let render-cover-minimal(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, height: 100%)[
    #align(center + horizon)[
      #let header-str = _get-tag-str(info, keys: ("university", "department"))
      #if header-str != none [
        #text(size: 9pt, weight: "bold", tracking: 0.15em, fill: th.text-muted)[#upper(header-str)]
        #v(1.2cm)
      ]
      #let tag-str = _get-tag-str(info)
      #if tag-str != none [
        #text(size: 9.5pt, weight: "bold", tracking: 0.2em, fill: th.accent)[#upper(tag-str)]
        #v(0.6cm)
      ]
      #_render-cover-title(th, info, sub-size: 11.5pt, sub-style: "italic")
      #v(1.2cm)
      #line(length: 20%, stroke: 0.5pt + th.border)
      #v(1.2cm)

      #let pairs = _get-meta(info)
      #if pairs.len() > 0 [
        #_render-meta-grid(th, pairs, grid-align: center + horizon)
      ]
    ]
  ]
}

#let render-cover-classic(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, height: 100%)[
    #align(center)[
      #if info.at("university", default: none) != none [
        #v(0.5cm)
        #text(size: 12pt, weight: "bold", tracking: 0.1em, fill: th.primary)[#upper(info.university)]
      ]
      #if info.at("department", default: none) != none [
        #v(0.2cm)
        #text(size: 10pt, fill: th.text-muted)[#info.department]
      ]

      #v(1.8fr)
      #line(length: 100%, stroke: 1.5pt + th.primary)
      #v(0.2cm)
      #line(length: 100%, stroke: 0.5pt + th.primary)
      #v(0.8cm)

      #_render-cover-title(th, info, title-size: 26pt, sub-style: "italic")

      #v(0.8cm)
      #line(length: 100%, stroke: 0.5pt + th.primary)
      #v(0.2cm)
      #line(length: 100%, stroke: 1.5pt + th.primary)
      #v(2fr)

      #let tag-str = _get-tag-str(info, sep: "  —  ")
      #if tag-str != none [
        #text(size: 10.5pt, weight: "bold", fill: th.accent)[#tag-str]
        #v(1cm)
      ]

      #let pairs = _get-meta(info)
      #if pairs.len() > 0 [
        #_render-meta-grid(th, pairs, grid-align: center + horizon, label-size: 8pt, val-size: 10pt)
      ]
      #v(0.5cm)
    ]
  ]
}

#let render-cover-editorial(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, height: 100%)[
    #_render-header-row(th, info, logo)
    #v(1fr)

    #if info.at("course", default: none) != none [
      #text(size: 10pt, weight: "bold", tracking: 0.2em, fill: th.accent)[#upper(info.course)]
      #v(0.5cm)
    ]

    #_render-cover-title(th, info, title-size: 32pt, v-space: 0.8cm)

    #v(1.5fr)
    #let pairs = _get-meta(info)
    #if pairs.len() > 0 [
      #rect(width: 100%, fill: th.surface, inset: 16pt, radius: 4pt, stroke: (left: 4pt + th.primary))[
        #_render-meta-grid(th, pairs, cols: (1fr, 1fr), column-gutter: 2cm)
      ]
    ]
    #v(0.4cm)
  ]
}

#let render-header-banner(th, title-or-info, logo-or-subtitle: none, ..args) = {
  let (info, logo) = _unpack-info(title-or-info, logo-or-subtitle, args)
  block(width: 100%, below: 2em)[
    #grid(
      columns: (1fr, auto),
      align: horizon,
      [
        #let tag-str = _get-tag-str(info, keys: ("course", "assignment", "semester", "section"))
        #if tag-str != none [
          #text(size: 9pt, weight: "bold", tracking: 0.1em, fill: th.primary)[#upper(tag-str)]
        ]
      ],
      render-cover-logo(logo, max-height: 2em),
    )

    #if info.at("course", default: none) != none or info.at("assignment", default: none) != none or logo != none [ #v(
      0.6em,
    ) ]

    #_render-cover-title(th, info, title-size: 20pt, sub-size: 10.5pt, v-space: 0.4em)

    #let pairs = _get-meta(info, include-inst: true)
    #if pairs.len() > 0 [
      #v(0.8em)
      #render-cover-divider(0.6pt + th.border)
      #v(0.6em)
      #_render-meta-grid(th, pairs, column-gutter: 1.5em, val-size: 9pt)
    ]
  ]
}

#let assignment-cover(
  title: none,
  subtitle: none,
  course: none,
  assignment: none,
  student: none,
  author: none,
  student-id: none,
  id: none,
  instructor: none,
  department: none,
  university: none,
  semester: none,
  section: none,
  date: none,
  logo: none,
  cover-page: false,
  cover-style: "modern",
  scale: none,
  doc-ref: none,
  rev: none,
  revision: none,
  height: "auto",
) = context {
  let th = active-theme.get()
  let info = (
    title: title,
    subtitle: subtitle,
    course: course,
    assignment: assignment,
    stu-name: if student != none { student } else { author },
    stu-id: if student-id != none { student-id } else { id },
    instructor: instructor,
    department: department,
    university: university,
    semester: semester,
    section: section,
    date-str: format-date(date),
    scale: scale,
    doc-ref: doc-ref,
    rev: if revision != none { revision } else { rev },
  )

  let is-cover = cover-page != false
  let selected-style = if type(cover-page) == str { cover-page } else { cover-style }
  let norm-style = lower(str(selected-style))

  if is-cover [
    #let cover-renderers = (
      "swiss": render-cover-swiss,
      "swiss-editorial": render-cover-swiss,
      "geometric": render-cover-geometric,
      "architecture": render-cover-architecture,
      "minimal": render-cover-minimal,
      "clean": render-cover-minimal,
      "classic": render-cover-classic,
      "formal": render-cover-classic,
      "editorial": render-cover-editorial,
    )
    #let render-fn = cover-renderers.at(norm-style, default: render-cover-modern)
    #render-fn(th, info, logo)
    #if height != "dynamic" [ #pagebreak() ]
  ] else [
    #render-header-banner(th, info, logo)
  ]
}

#let title-page(title: "", subtitle: none, author: "", id: "", ..args) = assignment-cover(
  title: title,
  subtitle: subtitle,
  student: author,
  student-id: id,
  ..args,
)
