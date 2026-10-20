// NASApunk: a Metropolis-derived theme for research mission briefings.
#import "@preview/touying:0.8.0": *
#import "@preview/touying:0.8.0": utils

#let default-fonts = (
  title: ("Rajdhani", "Sarasa Gothic SC"),
  body: ("IBM Plex Mono", "Sarasa Gothic SC"),
  code: ("Maple Mono NF",),
)

#let palette = (
  paper: white, ink: rgb("#222A2D"), orange: rgb("#CB4B22"),
  muted: rgb("#65716F"), rule: rgb("#C5C9BE"), panel: rgb("#E6E7DD"),
  blue: rgb("#286379"),
  emphasis: rgb("#B44020"), success: rgb("#35665B"),
  hint-emphasis: rgb("#326D65"),
  warning: rgb("#8A5B13"), danger: rgb("#A73434"),
)
#let bold-weight(weight) = if type(weight) == int { weight >= 700 } else { weight in ("bold", "extrabold", "black") }

#let typography(body, dark: false, title-font: default-fonts.title) = {
  show <nasapunk-columns>: it => {
    let fields = it.fields()
    let _ = fields.remove("label", default: none)
    let children = fields.remove("children")
    let count = if type(it.columns) == int { it.columns } else { it.columns.len() }
    let gaps = fields.column-gutter.map(g => if g == 5pt { 18pt } else { g })
    fields.column-gutter = 0pt
    fields.inset = (x, y) => (
      left: if x > 0 { gaps.at(calc.rem(x - 1, gaps.len())) / 2 } else { 0pt },
      right: if x < count - 1 { gaps.at(calc.rem(x, gaps.len())) / 2 } else { 0pt },
    )
    let divider = gradient.linear(
      (palette.orange, 0%), (palette.orange, 6%),
      (palette.rule, 6%), (palette.rule, 100%), angle: 90deg,
    )
    grid(..fields, ..children,
      ..range(1, count).map(x => grid.vline(x: x, stroke: 1.5pt + divider)),
    )
  }
  show heading: set text(font: title-font)
  // Instrument-panel section label: orange tick + tracked caps, no numbering.
  show heading.where(level: 3): it => block(above: 1em, below: .7em, sticky: true,
    grid(columns: (3pt, auto), column-gutter: 7pt, align: horizon,
      rect(width: 3pt, height: .95em, fill: palette.orange, stroke: none),
      text(size: 14pt, weight: "bold", tracking: 1.6pt, upper(it.body)),
    ))
  show strong: it => context text(
    weight: "bold",
    fill: if text.style == "italic" {
      if dark { rgb("#9FD4C8") } else { palette.hint-emphasis }
    } else {
      if dark { rgb("#FFB17C") } else { palette.emphasis }
    },
    it.body,
  )
  // Resolve the inner emphasis against the surrounding weight so both
  // *_text_* and _*text*_ use the same teal bold-italic styling.
  show emph: it => context text(
    style: "italic",
    fill: if bold-weight(text.weight) {
      if dark { rgb("#9FD4C8") } else { palette.hint-emphasis }
    } else {
      if dark { rgb("#9FD4DC") } else { palette.blue }
    },
    it.body,
  )
  // First row is the header; table.header also preserves PDF table semantics.
  // Explicit table/cell fills and strokes can still override these defaults.
  set table(
    inset: (x: 10pt, y: 7pt),
    align: left + horizon,
    fill: (x, y) => if y == 0 { palette.ink }
      else if x == 0 {
        if calc.odd(y) { rgb("#EDF1EF") } else { rgb("#E5EBE8") }
      } else if calc.odd(y) { white } else { rgb("#F5F7F6") },
    stroke: (_, y) => (
      top: if y == 0 { 2pt + palette.orange } else { none },
      bottom: if y == 0 { .8pt + palette.orange } else { .4pt + rgb("#D6DEDA") },
      left: none, right: none,
    ),
  )
  show table.cell: cell => {
    if cell.fill == palette.ink {
      set text(font: title-font, size: 1.08em, fill: white, weight: "bold")
      show strong: set text(fill: white)
      show emph: set text(fill: rgb("#9FD4DC"))
      cell
    } else {
      set text(fill: palette.ink)
      if cell.x == 0 {
        set text(weight: 500)
        cell
      } else {
        cell
      }
    }
  }
  body
}

// Multi-column grid; divider: true draws the theme's orange-capped rules.
#let cols(columns: (1fr, 1fr), gutter: 5pt, valign: top, divider: true, ..cells) = {
  let content = grid(columns: columns, gutter: gutter, align: valign, ..cells)
  if divider { [#content <nasapunk-columns>] } else { content }
}

// Expand with ..table-highlight([Label], [Value], ...) inside #table(...).
// A complete row is highlighted without changing its column alignment.
#let table-highlight(..cells) = cells.pos().enumerate().map(((index, body)) =>
  table.cell(
    fill: rgb("#FCF0E7"),
    stroke: (left: if index == 0 { 3pt + palette.orange } else { none },
      right: none, top: .5pt + rgb("#DEBBA6"), bottom: .5pt + rgb("#DEBBA6")),
    text(weight: 500, body),
  )
)

// Open engineering annotation: a registration target and leader, not a panel.
#let hint-rule(bottom: false) = {
  let hairline = rgb("#B7C5C5")
  if bottom {
    grid(columns: (30pt, 1fr, 60pt, 20pt, 8pt), gutter: 4pt, align: horizon,
      [],
      rect(width: 100%, height: .5pt, fill: hairline, stroke: none),
      rect(width: 100%, height: 2pt, fill: palette.blue, stroke: none),
      rect(width: 100%, height: 2pt, fill: rgb("#719C98"), stroke: none),
      rect(width: 100%, height: 2pt, fill: rgb("#E3B65A"), stroke: none),
    )
  } else {
    grid(columns: (60pt, 20pt, 8pt, 1fr, 8pt), gutter: 3pt, align: horizon,
      polygon(fill: palette.orange, stroke: none,
        (0pt, 0pt), (60pt, 0pt), (56pt, 4pt), (0pt, 4pt)),
      polygon(fill: rgb("#DE783C"), stroke: none,
        (4pt, 0pt), (20pt, 0pt), (16pt, 4pt), (0pt, 4pt)),
      polygon(fill: rgb("#E3B65A"), stroke: none,
        (4pt, 0pt), (8pt, 0pt), (4pt, 4pt), (0pt, 4pt)),
      rect(width: 100%, height: .5pt, fill: hairline, stroke: none),
      line(end: (0pt, 5pt), stroke: .7pt + palette.blue),
    )
  }
}
#let hint(body) = block(width: 100%, spacing: 12pt,
  stack(dir: ttb, spacing: 6pt,
  hint-rule(),
  grid(columns: (30pt, 1fr), gutter: 10pt, align: top,
    box(width: 30pt, height: 30pt)[
      #place(top + left, dx: 3pt, dy: 3pt,
        circle(width: 12pt, stroke: 1pt + palette.orange))
      #place(top + left, dy: 9pt,
        line(length: 23pt, stroke: 1pt + palette.orange))
      #place(top + left, dx: 9pt,
        line(end: (0pt, 22pt), stroke: 1pt + palette.orange))
      #place(top + left, dx: 9pt, dy: 23pt,
        line(end: (0pt, 7pt), stroke: (paint: palette.muted, thickness: .6pt, dash: "dashed")))
      #place(top + left, dx: 9pt, dy: 30pt,
        line(length: 15pt, stroke: .6pt + palette.muted))
    ],
    [
      #set text(weight: 500, style: "italic", fill: palette.ink)
      #show emph: it => context text(style: "italic",
        fill: if bold-weight(text.weight) { palette.hint-emphasis } else { palette.ink },
        it.body)
      #show strong: set text(style: "italic", weight: "bold", fill: palette.hint-emphasis)
      #body
    ],
  ),
  hint-rule(bottom: true),
  ),
)

// Instrument-panel callouts. Color is paired with a readable status label.
// kind: note | info | warning | success | danger; title: optional content.
#let callout(body, kind: "note", title: auto) = {
  let styles = (
    note: (color: palette.emphasis, tint: rgb("#FCF2EC"), code: "01", title: [NOTE]),
    info: (color: palette.blue, tint: rgb("#EDF4F7"), code: "02", title: [INFO]),
    warning: (color: palette.warning, tint: rgb("#FCF5E5"), code: "03", title: [CAUTION / CHECK]),
    success: (color: palette.success, tint: rgb("#EDF4EF"), code: "04", title: [VERIFIED / GO]),
    danger: (color: palette.danger, tint: rgb("#FAEEEE"), code: "05", title: [ALERT / NO-GO]),
  )
  assert(kind in styles, message: "Unknown callout kind: " + kind)
  let style = styles.at(kind)
  block(width: 100%, breakable: false, spacing: 10pt,
    fill: style.tint, stroke: .6pt + style.color, radius: 0pt,
    inset: 0pt,
    {
      block(width: 100%, fill: style.color, inset: (x: 11pt, y: 6pt), spacing: 0pt)[
        #set text(fill: white, size: 10pt, weight: "bold", tracking: .7pt)
        #show strong: set text(fill: white)
        #show emph: set text(fill: white)
        #grid(columns: (1fr, auto), gutter: 10pt,
          if title == auto { style.title } else { title }, [/#style.code])
      ]
      block(inset: 12pt, width: 100%, spacing: 0pt)[
        #set text(fill: palette.ink, weight: 500)
        #body
      ]
    },
  )
}
#let todo(body) = callout(body, kind: "warning", title: [PENDING / ACTION])

// Small tracked caption used for slide furniture (mission codes, counters).
#let tag(body, fill: palette.muted) = text(
  size: 8pt,
  weight: "medium", tracking: 1pt, fill: fill, body,
)
// Muted aerospace livery: continuous, stacked bands rather than a gradient.
#let rainbow = (
  rgb("#B84636"), rgb("#DE783C"), rgb("#E3B65A"),
  rgb("#719C98"), rgb("#355B70"),
)
#let rail(width: 100%, stripe-height: 2pt) = block(
  width: width, spacing: 0pt,
  stack(dir: ttb, spacing: 0pt,
    ..rainbow.map(color => rect(
      width: 100%, height: stripe-height, fill: color, stroke: none,
    )),
  ),
)
#let footer(self) = {
  show: pad.with(x: 34pt, bottom: 6pt)
  set align(bottom)
  line(length: 100%, stroke: .5pt + palette.rule)
  v(1pt)
  grid(columns: (1fr, auto), gutter: 12pt,
    tag(utils.fit-to-width(grow: false, 100%, self.info.title)),
    tag(context [#utils.slide-counter.display() / #utils.last-slide-number]),
  )
}
#let header(self, title) = {
  show: pad.with(x: 34pt)
  rail()
  v(8pt)
  grid(columns: (1fr, auto), gutter: 12pt, align: horizon,
    text(font: self.store.fonts.title, size: 23pt, weight: "bold", fill: palette.ink,
      if title == auto { utils.call-or-display(self, self.store.header) }
      else { utils.fit-to-width(grow: false, 100%, title) }),
    tag(self.store.mission-code, fill: palette.orange),
  )
}
#let slide(title: auto, config: (:), ..args) = touying-slide-wrapper(self => {
  let wrapper = themes.metropolis.slide(
    title: title,
    config: utils.merge-dicts(config-page(
      header: self => header(self, title), footer: footer,
    ), config),
    ..args,
  )
  (wrapper.body.value.fn)(self)
})

// Vector orbital mark: no external artwork or raster dependency.
#let orbital-mark() = box(width: 142pt, height: 142pt)[
  #place(center + horizon, circle(width: 125pt, stroke: .6pt + palette.rule))
  #place(center + horizon, circle(width: 86pt,
    stroke: (paint: palette.muted, thickness: .6pt, dash: "dashed")))
  #place(center + horizon, circle(width: 42pt, fill: palette.panel, stroke: 1pt + palette.ink))
  #place(center + horizon, line(length: 142pt, stroke: .5pt + palette.muted))
  #place(center + horizon, rotate(90deg, line(length: 142pt, stroke: .5pt + palette.rule)))
  #place(center + horizon, rotate(-35deg, line(length: 155pt, stroke: 3pt + palette.orange)))
  #place(top + right, dx: -19pt, dy: 22pt, circle(width: 9pt, fill: palette.ink, stroke: none))
  #place(bottom + center, dy: 17pt, tag[TRAJECTORY / 01])
]
// Print-registration crop mark for the cover corners.
#let crop-mark(size: 12pt) = box(width: size, height: size, {
  place(line(length: size, stroke: .7pt + palette.ink))
  place(line(end: (0pt, size), stroke: .7pt + palette.ink))
})
#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let corner(pos, angle) = place(pos, dx: if pos.x == left { -14pt } else { 14pt },
    dy: if pos.y == top { -14pt } else { 14pt }, rotate(angle, crop-mark()))
  touying-slide(self: self,
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      config-page(fill: rgb("#F4F3EE"), header: none, footer: none, margin: 32pt), config,
    ),
    [
      #set text(fill: palette.ink)
      #corner(top + left, 0deg)
      #corner(top + right, 90deg)
      #corner(bottom + right, 180deg)
      #corner(bottom + left, 270deg)
      #grid(columns: (1fr, auto), gutter: 12pt,
        tag(fill: palette.ink, if self.store.mission != none { self.store.mission }
          else { utils.fit-to-width(grow: false, 100%, info.title) }),
        tag(self.store.mission-code, fill: palette.orange))
      #v(12pt)
      #rail(stripe-height: 4pt)
      #v(1fr)
      #grid(columns: (1fr, 155pt), gutter: 28pt, align: horizon,
        [
          #block(below: 14pt, rect(width: 42pt, height: 4pt, fill: palette.orange, stroke: none))
          #block(text(font: self.store.fonts.title, 38pt, weight: "bold", info.title))
          #if info.subtitle != none { block(above: 22pt, text(17pt, fill: palette.muted, info.subtitle)) }
        ], orbital-mark())
      #v(1fr)
      #line(length: 100%, stroke: 1pt + palette.ink)
      #v(7pt)
      #grid(columns: (1fr, auto), gutter: 20pt,
        [#text(12pt, weight: "bold", info.author)
         #if info.institution != none { linebreak(); text(10pt, fill: palette.muted, info.institution) }],
        align(right)[
          #text(10pt, if info.date != none {
            if type(info.date) == datetime { info.date.display("[year]-[month]-[day]") } else { info.date }
          })
          #linebreak()
          #tag[COVER SHEET / 00]
        ])
      #if extra != none { v(6pt); text(10pt, extra) }
    ],
  )
})
#let two-digit(n) = if n < 10 { "0" + str(n) } else { str(n) }
#let sections() = query(heading.where(level: 1, outlined: true))

// Phase progress bar: completed phases in ink, the current one in orange.
#let phase-ticks(current, total) = grid(
  columns: (1fr,) * total, column-gutter: 4pt, row-gutter: 6pt,
  ..range(total).map(i => rect(width: 100%, height: 6pt, stroke: none,
    fill: if i + 1 == current { palette.orange } else if i + 1 < current { palette.ink } else { palette.rule })),
  ..range(total).map(i => tag(two-digit(i + 1),
    fill: if i + 1 == current { palette.orange } else { palette.muted })),
)
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  touying-slide(self: self,
    config: utils.merge-dicts(config-page(header: none, footer: footer, fill: palette.paper), config),
    context {
      let total = sections().len()
      let current = query(heading.where(level: 1, outlined: true).before(here())).len()
      grid(columns: (1fr, auto), gutter: 12pt,
        tag(fill: palette.orange)[SECTION #two-digit(current) / #two-digit(total)],
        tag(self.store.mission-code, fill: palette.orange))
      v(10pt)
      rail(stripe-height: 3pt)
      v(1fr)
      grid(columns: (auto, 1fr), column-gutter: 20pt, align: bottom,
        text(font: self.store.fonts.title, 88pt, weight: "bold", fill: palette.ink,
          top-edge: "cap-height", bottom-edge: "baseline", two-digit(current)),
        {
          text(font: self.store.fonts.title, 34pt, weight: "bold", fill: palette.ink, bottom-edge: "baseline",
            utils.display-current-heading(level: level, numbered: false, style: auto))
          if body != none and body != [] { v(8pt); text(fill: palette.muted, body) }
        })
      v(1fr)
      if total > 1 { phase-ticks(current, total) }
      v(14pt)
    },
  )
})
#let focus-slide(config: (:), align: horizon + center, body) = touying-slide-wrapper(self => {
  touying-slide(self: self,
    config: utils.merge-dicts(config-common(freeze-slide-counter: true),
      config-page(fill: palette.ink, header: none, footer: none, margin: 40pt), config),
    [#set text(fill: palette.paper)
     #show: typography.with(dark: true, title-font: self.store.fonts.title)
     #set std.align(align)
     #tag(self.store.mission-code, fill: palette.orange)
     #v(20pt)
     #text(font: self.store.fonts.title, 30pt, weight: "bold", body)
     #v(20pt)
     #rail(width: 96pt, stripe-height: 2pt)],
  )
})
// Flight-plan timeline of level-1 sections; depth: 2 lists each section's
// slides under its node.
#let sheet(h) = two-digit(utils.slide-counter.at(h.location()).first())
#let mission-timeline(depth: 1, title-font: default-fonts.title) = context {
  let entries = sections()
  let n = entries.len()
  if n == 0 { return }
  let subsections(i) = {
    let sel = heading.where(level: 2, outlined: true).after(entries.at(i).location())
    query(if i + 1 < n { sel.before(entries.at(i + 1).location()) } else { sel })
  }
  let checklist(i) = pad(right: 14pt, block(stroke: (left: .6pt + palette.rule), inset: (left: 10pt, y: 2pt),
    grid(columns: (auto, 1fr, auto), column-gutter: 8pt, row-gutter: 9pt,
      ..subsections(i).enumerate().map(((j, h)) => (
        tag(fill: palette.orange)[#(i + 1).#(j + 1)],
        text(13pt, fill: palette.ink, h.body),
        tag(sheet(h)),
      )).flatten(),
    )))
  let track(i) = box(width: 100%, height: 16pt, {
    place(horizon, line(length: 100%, stroke: 1pt + palette.ink))
    for x in (25%, 50%, 75%) {
      place(horizon, dx: x, line(start: (0pt, -3pt), end: (0pt, 3pt), stroke: .6pt + palette.muted))
    }
    place(horizon, circle(width: 14pt, stroke: 1.5pt + palette.ink,
      fill: if i == 0 { palette.orange } else { palette.paper }))
    if i == n - 1 {
      place(horizon + right, rect(width: 8pt, height: 8pt, fill: palette.ink, stroke: none))
    }
  })
  grid(columns: (1fr,) * n, column-gutter: 0pt, row-gutter: 12pt, align: left + top,
    ..range(n).map(i => tag(fill: palette.orange)[PHASE #two-digit(i + 1)]),
    ..range(n).map(track),
    ..entries.map(h => pad(right: 14pt,
      text(font: title-font, 20pt, weight: "bold", fill: palette.ink, h.body))),
    ..entries.map(h => tag[SHEET #sheet(h)]),
    ..if depth >= 2 { range(n).map(checklist) },
  )
}
#let outline-slide(title: [Mission overview], config: (:), depth: 1) = touying-slide-wrapper(self => {
  let wrapper = slide(title: title, config: config,
    mission-timeline(depth: depth, title-font: self.store.fonts.title))
  (wrapper.body.value.fn)(self)
})

// fonts: partial overrides merge into default-fonts, e.g. (body: ("Fira Mono",)).
#let nasapunk-theme(
  aspect-ratio: "16-9",
  mission: none,
  mission-code: [],
  fonts: (:),
  ..args,
  body,
) = {
  let fonts = default-fonts + fonts
  show: themes.metropolis.metropolis-theme.with(
    aspect-ratio: aspect-ratio,
    config-colors(primary: palette.orange, primary-light: palette.rule,
      secondary: palette.ink, neutral-lightest: palette.paper,
      neutral-dark: palette.ink, neutral-darkest: palette.ink),
    config-common(slide-fn: slide, new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false),
    config-page(margin: (top: 76pt, bottom: 30pt, x: 34pt), header-ascent: 0pt, footer-descent: 0pt),
    config-store(mission: mission, mission-code: mission-code, fonts: fonts),
    ..args,
  )
  set text(18pt, weight: 400, font: fonts.body)
  show raw: set text(font: fonts.code, weight: 400)
  show raw.where(block: true): set text(size: 12pt)
  show raw.where(block: false): box.with(
    fill: luma(240), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt,
  )
  show link: underline
  show link: set text(fill: palette.blue)
  show: typography.with(title-font: fonts.title)
  body
}
