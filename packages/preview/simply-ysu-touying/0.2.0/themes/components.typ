// Components of the YSU defense theme. Letters in the comments are the
// component codes of the defense deck (ysu-defense-modern.sty).
//
// Rules of the deck: at most three groups of semantic red and at most three
// frame groups per page; the conclusion bar (C) and the red-framed sentence
// (H) exclude each other.

#import "tokens.typ": *

#let _two(n) = if n < 10 { "0" + str(n) } else { str(n) }

// Page margin that full-width bars bleed into.
#let _bleed = 1cm

/// Two blocks side by side with the same height: `left(h)` gets the height
/// of the taller one. Used by label rows, side cards and the paper box.
#let _equal-row(left-width, gap, left, right-body, min-height: 0pt) = layout(size => {
  let rw = size.width - left-width - gap
  let h = calc.max(measure(block(width: rw, right-body)).height, min-height)
  grid(
    columns: (left-width, rw),
    column-gutter: gap,
    left(h), block(width: rw, height: h, right-body),
  )
})

// ---------------------------------------------------------------------------
// Emphasis and tags
// ---------------------------------------------------------------------------

/// Highlighted term: navy bold, kept on one line (原稿 \ysuHL). On navy
/// grounds it turns white.
#let hl(body) = box(strong(body))

/// Key conclusion: red bold, at most one per page (原稿 \ysuKey).
#let key(body) = box(strong(text(fill: ysu-red, body)))

/// F: tag. `kind`: "red" (limit or problem), "navy" or "line" (white outline
/// on navy).
#let tag(kind: "navy", size: 8pt, body) = {
  let (fill, stroke, fg) = if kind == "red" {
    (mix(ysu-red, 10%), none, ysu-red)
  } else if kind == "line" { (none, 0.6pt + white, white) } else {
    (mix(ysu-navy, 12%), none, ysu-navy)
  }
  box(fill: fill, stroke: stroke, radius: 2pt, inset: (x: 4pt, y: 1.5pt), text(
    size: size,
    weight: "bold",
    fill: fg,
    body,
  ))
}

/// White outline capsule on navy grounds.
#let pill(body) = box(stroke: 0.6pt + white, radius: 0.2cm, inset: (x: 6pt, y: 2pt), text(
  size: 8pt,
  weight: "bold",
  fill: white,
  body,
))

/// Navy capsule with white bold text (cover speaker, tab titles).
#let tab-pill(body) = box(fill: ysu-navy, radius: 0.18cm, inset: (x: 16pt, y: 4.5pt), text(
  weight: "bold",
  fill: white,
  body,
))

/// Navy label with white text, for box edges and row heads.
#let edge-label(red: false, body) = box(
  fill: if red { ysu-red } else { ysu-navy },
  radius: 2pt,
  inset: (x: 5pt, y: 2pt),
  text(size: 9pt, weight: "bold", fill: white, body),
)

/// Navy disc with a white icon. `icon` is any content (an icon font glyph,
/// a symbol, or text).
#let icon-disc(size: 0.42cm, fill: ysu-navy, icon) = box(
  circle(radius: size / 2, fill: fill, inset: 0pt, std.align(center + horizon, text(
    size: 7.5pt * (size / 0.42cm),
    fill: white,
    icon,
  ))),
)

// ---------------------------------------------------------------------------
// Bars
// ---------------------------------------------------------------------------

/// C: conclusion bar at the page bottom, navy gradient ground, white text.
/// A full-width bar bleeds to both page edges.
#let conclude(label: none, red-label: none, pill: none, bleed: true, body) = block(
  width: 100%,
  fill: grad-bar,
  outset: if bleed { (x: _bleed) } else { 0pt },
  radius: if bleed { 0pt } else { 2pt },
  inset: (x: if bleed { 0pt } else { 6pt }, y: 5pt),
  {
    set text(size: 10pt, fill: white)
    show strong: set text(fill: white)
    let head = if red-label != none { tag(kind: "red", size: 10pt, red-label) } else if label != none {
      tag(kind: "line", size: 10pt, label)
    }
    let tail = if pill != none {
      box(stroke: 0.6pt + white, radius: 0.2cm, inset: (x: 6pt, y: 2pt), text(size: 8pt, weight: "bold", pill))
    }
    grid(columns: (auto, 1fr, auto), column-gutter: 0.5em, align: horizon, head, body, tail)
  },
)

/// J: base bar. Full width, tint ground, navy rules on its top and bottom
/// edges, 11 pt bold navy text in the centre.
#let base-bar(bleed: true, body) = block(
  width: 100%,
  height: auto,
  fill: ysu-tint,
  stroke: (top: 1pt + ysu-navy, bottom: 1pt + ysu-navy, x: if bleed { none } else { 1pt + ysu-navy }),
  outset: if bleed { (x: _bleed) } else { 0pt },
  inset: (y: 0.12cm),
  std.align(center, text(size: 11pt, weight: "bold", fill: ysu-navy, body)),
)

/// N: section bar. Navy disc with a white icon, the name, then a hairline.
#let section-bar(icon: none, body) = grid(
  columns: if icon != none { (auto, auto, 1fr) } else { (auto, 1fr) },
  column-gutter: 5pt,
  align: horizon,
  ..if icon != none { (icon-disc(icon),) },
  text(size: 11pt, weight: "bold", fill: ysu-navy, body),
  line(length: 100%, stroke: 0.6pt + ysu-line),
)

// ---------------------------------------------------------------------------
// Boxes
// ---------------------------------------------------------------------------

/// T: title box. Gradient header with a white title (optional icon and a
/// right-hand `aside`, such as "第 3 章"), tint body, navy!35 border.
#let title-box(
  icon: none,
  title: none,
  aside: none,
  width: 100%,
  height: auto,
  body-size: 10pt,
  body,
) = {
  let head-h = 0.6cm
  block(
    width: width,
    height: height,
    radius: 3pt,
    clip: true,
    stroke: 0.6pt + mix(ysu-navy, 35%),
    fill: ysu-tint,
    {
      block(width: 100%, height: head-h, fill: grad-head, inset: (x: 6pt), spacing: 0pt, std.align(
        horizon,
        grid(
          columns: (1fr, auto),
          text(size: 10pt, weight: "bold", fill: white, {
            if icon != none { icon; h(0.5em) }
            title
          }),
          if aside != none { text(size: 9pt, fill: white, aside) },
        ),
      ))
      block(
        width: 100%,
        height: if type(height) == length { height - head-h } else { auto },
        inset: (x: 7pt, top: 0.3cm, bottom: 0.28cm),
        spacing: 0pt,
        text(size: body-size, body),
      )
    },
  )
}

/// Classic name of the title box.
#let tblock(title: none, body) = title-box(title: title, body)

/// P: group box. Navy!6 ground, navy!45 border; the label sits on the top
/// border (`red: true` sets it in red). Holds 2 to 4 sub-boxes.
#let group-box(label: none, red: false, body) = {
  let pad-top = if label == none { 6pt } else { 12pt }
  block(
    width: 100%,
    fill: mix(ysu-navy, 6%),
    stroke: 0.8pt + mix(ysu-navy, 45%),
    radius: 6pt,
    inset: (x: 7pt, top: pad-top, bottom: 6pt),
    {
      if label != none {
        let l = edge-label(red: red, label)
        context {
          let h = measure(l).height
          place(top + left, dx: 1pt, dy: -pad-top - h / 2, l)
        }
      }
      body
    },
  )
}

/// White sub-box inside a group box.
#let sub-box(body) = block(
  width: 100%,
  fill: white,
  stroke: 0.5pt + ysu-line,
  radius: 3pt,
  inset: (x: 5.5pt, y: 4pt),
  body,
)

/// Q: dashed sub-box.
#let dash-box(body) = block(
  width: 100%,
  fill: white,
  stroke: (paint: mix(ysu-navy, 55%), thickness: 0.6pt, dash: (2pt, 1.5pt)),
  radius: 3pt,
  inset: (x: 5.5pt, y: 4pt),
  body,
)

/// K: label row. A navy label block (2 to 4 characters) beside a sub-box of
/// the same height.
#let label-row(label: none, dashed: false, label-width: 1.3cm, body) = _equal-row(
  label-width,
  0.2cm,
  h => block(width: label-width, height: h, fill: ysu-navy, radius: 3pt, std.align(center + horizon, text(
    weight: "bold",
    fill: white,
    label,
  ))),
  (if dashed { dash-box } else { sub-box })(std.align(horizon, body)),
  min-height: 0.8cm,
)

/// W: hollow block arrow with 2 to 4 characters on the shaft. `dir`:
/// "right", "left", "up" or "down".
#let block-arrow(dir: "right", body) = context {
  let t = text(size: 9pt, weight: "bold", fill: ysu-navy, body)
  let s = measure(t)
  let shaft = s.height + 0.18cm
  let head-w = shaft + 0.28cm
  let head-l = head-w / 2 / calc.tan(50deg)
  let len = calc.max(1.1cm, s.width + 6pt + head-l)
  let body-l = len - head-l
  let y0 = (head-w - shaft) / 2
  let shape = polygon(
    fill: ysu-tint,
    stroke: 0.8pt + ysu-navy,
    (0pt, y0),
    (body-l, y0),
    (body-l, 0pt),
    (len, head-w / 2),
    (body-l, head-w),
    (body-l, y0 + shaft),
    (0pt, y0 + shaft),
  )
  let arrow = box(width: len, height: head-w, {
    place(shape)
    if dir in ("right", "left") {
      place(left + horizon, dx: (body-l - s.width) / 2, t)
    }
  })
  let angle = (right: 0deg, down: 90deg, left: 180deg, up: -90deg).at(dir)
  if dir in ("right", "left") and angle == 0deg { arrow } else if dir == "left" {
    box(width: len, height: head-w, {
      place(scale(x: -100%, reflow: true, box(width: len, height: head-w, place(shape))))
      place(left + horizon, dx: head-l + (body-l - s.width) / 2, t)
    })
  } else {
    stack(dir: ltr, spacing: 2pt, std.align(horizon, t), rotate(angle, reflow: true, box(
      width: len,
      height: head-w,
      place(shape),
    )))
  }
}

/// H: red-framed sentence. White ground, red border, a red label at the
/// left, navy text. At most one per page, never with a conclusion bar.
#let red-frame(label: none, center: false, body) = block(
  width: 100%,
  fill: white,
  stroke: 0.8pt + ysu-red,
  radius: 3pt,
  inset: (x: 6pt, y: 5pt),
  {
    set text(fill: ysu-navy)
    if center {
      std.align(std.center, { if label != none { edge-label(red: true, label); h(0.5em) }; body })
    } else {
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        align: horizon,
        if label != none { edge-label(red: true, label) }, body,
      )
    }
  },
)

/// A: card with a coloured bar on its top edge.
#let card(accent: ysu-navy, fill: white, inset: (x: 6pt, top: 6.5pt, bottom: 5pt), body) = block(
  width: 100%,
  fill: fill,
  stroke: 0.6pt + ysu-line,
  radius: 2pt,
  clip: true,
  inset: inset,
  {
    place(top + left, dx: -inset.x, dy: -inset.top, rect(width: 100% + 2 * inset.x, height: 2.5pt, fill: accent))
    body
  },
)

/// Card with a navy label on the left and a tint body with a navy edge
/// (原稿 \DefenseCard).
#let side-card(label: none, label-width: 2.35cm, body) = _equal-row(
  label-width,
  0.2cm,
  h => block(width: label-width, height: h, fill: ysu-navy, radius: 3pt, std.align(center + horizon, text(
    weight: "bold",
    fill: white,
    label,
  ))),
  block(width: 100%, fill: ysu-tint, stroke: (left: 2pt + ysu-navy), inset: (x: 8pt, y: 6pt), body),
)

/// Publication box: a navy "论文" label and the bibliographic text. A string
/// is cut before "DOI:".
#let paper-box(label: [论文], body) = {
  let text-body = if type(body) == str {
    let i = body.position("DOI:")
    if i == none { body } else { body.slice(0, i).trim() }
  } else { body }
  _equal-row(
    1.3cm,
    0.15cm,
    h => block(width: 1.3cm, height: h, fill: ysu-navy, radius: 3pt, std.align(center + horizon, text(
      weight: "bold",
      fill: white,
      label,
    ))),
    block(width: 100%, fill: ysu-tint, inset: (x: 8pt, y: 6pt), text(size: 8pt, text-body)),
  )
}

// ---------------------------------------------------------------------------
// Points and numbers
// ---------------------------------------------------------------------------

/// D: numbered points 01, 02, ... in navy tabular figures; continuation
/// lines start under the text. `rule` draws an ysuLine rule above each.
#let points(start: 1, rule: false, spacing: 0.5em, ..items) = {
  let rows = items.pos().enumerate().map(((i, it)) => {
    let row = grid(
      columns: (1.6em, 1fr),
      text(weight: "bold", fill: ysu-navy, number-width: "tabular", _two(start + i)), it,
    )
    if rule { block(width: 100%, stroke: (top: 0.6pt + ysu-line), inset: (top: 5pt), row) } else { row }
  })
  stack(dir: ttb, spacing: spacing, ..rows)
}

/// E: key number. A 3 pt navy rule on the top edge, no frame; muted label,
/// large navy value (red with `key: true`), optional basis line.
#let kpi(label: none, value: none, basis: none, key: false, size: 18pt) = block(
  width: 100%,
  stroke: (top: 3pt + ysu-navy),
  inset: (top: 5pt),
  {
    if label != none { text(size: 8pt, weight: "bold", fill: ysu-muted, label); linebreak() }
    text(size: size, weight: "bold", fill: if key { ysu-red } else { ysu-navy }, number-width: "tabular", value)
    if basis != none { linebreak(); text(size: 8pt, fill: ysu-muted, basis) }
  },
)

// ---------------------------------------------------------------------------
// Figures, equations, tables
// ---------------------------------------------------------------------------

/// Caption line under a figure: muted, footnote size.
#let fig-caption(body) = block(above: 2pt, width: 100%, std.align(center, text(size: 8pt, fill: ysu-muted, body)))

/// Centered figure with its caption (原稿 \DefenseFigure).
#let figure-box(caption: none, body) = {
  std.align(center, body)
  if caption != none { fig-caption(caption) }
}

/// Equation number in the thesis style: muted and small.
#let eq-number(body) = text(size: 8pt, fill: ysu-muted, body)

/// B: equation block. The formula sits on a tint block; `number` is the
/// thesis number such as "(3-5)"; `note` is the reading under it.
#let eq-block(number: none, note: none, body) = block(
  width: 100%,
  fill: ysu-tint,
  inset: (x: 8pt, y: 6pt),
  {
    set text(size: 9pt)
    grid(
      columns: (1fr, auto),
      align: (center + horizon, right + horizon),
      body, if number != none { eq-number(number) },
    )
    if note != none {
      v(4pt)
      text(size: 9pt, note)
    }
  },
)

/// Reading card: tint ground, navy bold title, 9 pt text.
#let reading-card(title: none, body) = block(
  width: 100%,
  fill: ysu-tint,
  inset: (x: 8pt, y: 5pt),
  {
    if title != none { text(weight: "bold", fill: ysu-navy, title); v(4pt, weak: true) }
    text(size: 9pt, body)
  },
)

/// Field screenshot in a night-blue window with three dots and a title.
#let screen-frame(title: none, body) = block(
  fill: ysu-night,
  radius: 4pt,
  inset: (x: 5pt, top: 0pt, bottom: 5pt),
  {
    block(height: 0.42cm, width: 100%, spacing: 0pt, std.align(left + horizon, {
      for _ in range(3) { box(circle(radius: 2.2pt, fill: ysu-night-dot)); h(3pt) }
      if title != none { h(6pt); text(size: 6.5pt, fill: ysu-kicker, title) }
    }))
    body
  },
)

/// Results table: navy header band with white text, a closing navy rule and
/// tinted rows for `mark` (0-based data-row indices, e.g. this work).
#let result-table(columns: auto, header: (), rows: (), mark: (), align: auto, size: 9pt) = {
  let n = header.len()
  let cols = if columns == auto { (auto,) + (1fr,) * (n - 1) } else { columns }
  set text(size: size)
  table(
    columns: cols,
    stroke: none,
    inset: (x: 5pt, y: 3.5pt),
    align: if align == auto { (x, y) => if x == 0 { left + horizon } else { center + horizon } } else { align },
    fill: (x, y) => if y == 0 { ysu-navy } else if (y - 1) in mark { mix(ysu-navy, 8%) },
    table.header(..header.map(h => text(weight: "bold", fill: white, h))),
    ..rows
      .enumerate()
      .map(((i, r)) => if i in mark { r.map(c => strong(c)) } else { r })
      .flatten(),
    table.hline(stroke: 0.8pt + ysu-navy),
  )
}
