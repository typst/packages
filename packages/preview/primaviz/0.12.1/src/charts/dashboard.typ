// dashboard.typ - Dashboard layout primitives (card, compact-table, alert, badge, separator)
#import "../theme.typ": _resolve-ctx, _is-dark, _shade
#import "../primitives/polar-labels.typ": label-ink, legible
#import "../primitives/status.typ": status-colors

/// Renders a themed card container with optional title and description.
///
/// - title (none, content, str): Optional card title
/// - desc (none, content, str): Optional description shown beside the title
/// - width (length): Card width
/// - theme (none, dictionary): Theme overrides
/// - body (content): Card body content
/// -> content
#let card(title: none, desc: none, width: 100%, theme: none, body) = context {
  let t = _resolve-ctx(theme)
  let fill = if t.background != none { t.background } else { white }
  let stroke = if t.border != none { t.border } else { 0.75pt + t.text-color-light }
  let muted = t.text-color-light

  box(
    width: width,
    stroke: stroke,
    inset: 0pt,
    fill: fill,
    radius: t.border-radius,
  )[
    #let pad = t.axis-label-gap
    #if title != none {
      box(inset: (x: pad, top: pad, bottom: 0pt), width: 100%)[
        #text(size: t.axis-title-size, weight: "bold", fill: t.text-color, title)
        #if desc != none {
          h(pad)
          text(size: t.axis-label-size, fill: muted, desc)
        }
      ]
    }
    #box(inset: (x: pad, top: pad * 0.8, bottom: pad), width: 100%, body)
  ]
}

/// Renders a compact data table with themed header row and alternating fills.
///
/// Rows are separated by hairlines only (no column rules), the header text is
/// whichever of the theme's text colours reads on the header fill, and the
/// first column is as wide as its content unless `col-widths` says otherwise.
///
/// - headers (array): Column header strings
/// - rows (array): Array of row arrays (each row is an array of cell strings); columns of numbers are right-aligned, others left
/// - highlight-col (none, int): Column index to render in bold with primary color
/// - col-widths (none, array): Custom column widths; defaults to the first column fitting its content, the others sharing the rest
/// - theme (none, dictionary): Theme overrides
/// -> content
#let compact-table(headers, rows, highlight-col: none, col-widths: none, theme: none) = context {
  let t = _resolve-ctx(theme)
  let fill = if t.background != none { t.background } else { white }
  let alt-fill = if t.background != none { _shade(t, 5%) } else { t.text-color-light.transparentize(90%) }
  let header-fill = t.palette.at(1, default: t.palette.at(0))
  let rule = if t.border != none { t.border } else { 0.4pt + t.text-color-light }
  let highlight-color = legible(t.palette.at(0), fill)

  // Numbers line up on the right; words read from the left
  let number = regex("^[+−\\-$€£]?[0-9][0-9.,]*\\s?[%kKMB]?$")
  let numeric(col) = rows.all(r => {
    let cell = r.at(col, default: "")
    cell == "" or (type(cell) == str and cell.match(number) != none)
  })
  let cols = if col-widths != none { col-widths } else { (auto, ..range(headers.len() - 1).map(_ => 1fr)) }
  table(
    columns: cols,
    align: range(headers.len()).map(col => if col > 0 and numeric(col) { right } else { left }),
    stroke: (x, y) => (bottom: rule),
    inset: (x: t.axis-label-gap * 0.8, y: t.axis-label-gap * 0.6),
    fill: (_, row) => if row == 0 { header-fill } else if calc.rem(row, 2) == 0 { alt-fill } else { fill },
    ..headers.map(h => text(size: t.axis-label-size, weight: "bold", fill: label-ink(header-fill, t), upper(h))),
    ..rows.flatten().enumerate().map(((i, cell)) => {
      let col = calc.rem(i, headers.len())
      text(
        size: t.value-label-size,
        weight: if highlight-col != none and col == highlight-col { "bold" } else { "regular" },
        fill: if highlight-col != none and col == highlight-col { highlight-color } else { t.text-color },
        cell,
      )
    }),
  )
}

/// Renders a themed alert block with left border accent, icon, and optional title.
///
/// Colours carry the meaning in light and dark themes alike: info is the
/// theme's first palette colour, warning amber, error red, success green
/// (a theme can set `warning-color`, `negative-color`, `positive-color`).
///
/// - body (content): Alert body content
/// - variant (str): One of `"info"`, `"warning"`, `"error"`, `"success"`
/// - title (none, content, str): Optional alert title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let alert(body, variant: "info", title: none, theme: none) = context {
  let t = _resolve-ctx(theme)
  let sc = status-colors(t)
  let variants = (
    info:    (accent: sc.info, icon: "ℹ"),
    warning: (accent: sc.warning, icon: "!"),
    error:   (accent: sc.negative, icon: "✕"),
    success: (accent: sc.positive, icon: "✓"),
  )
  let vr = variants.at(variant, default: variants.info)
  let accent = vr.accent
  let bg = if _is-dark(t) { accent.darken(80%) } else { accent.lighten(90%) }

  box(
    width: 100%,
    fill: bg,
    stroke: (left: 2.5pt + accent),
    inset: (x: t.axis-label-gap, y: t.axis-label-gap),
  )[
    #if title != none {
      text(size: t.axis-title-size, weight: "bold", fill: legible(accent, bg, min-ratio: 4.5))[#vr.icon #h(3pt) #title]
      v(2pt)
    }
    #text(size: t.value-label-size, fill: t.text-color, body)
  ]
}

/// Renders an inline colored pill badge.
///
/// - label (str, content): Badge text
/// - variant (str): One of `"default"`, `"secondary"`, `"destructive"`, `"outline"`, `"success"`
/// - theme (none, dictionary): Theme overrides
/// -> content
#let badge(label, variant: "default", theme: none) = context {
  let t = _resolve-ctx(theme)
  let pal = t.palette
  let primary = pal.at(0, default: blue)
  let secondary = pal.at(1, default: gray)
  let destructive = pal.at(2, default: red)
  let success = if pal.len() > 3 { pal.at(3) } else { primary }
  let fill-bg = if t.background != none { t.background } else { white }

  // Text on a coloured badge is whichever colour reads on it
  let styles = (
    default: (bg: primary, fg: label-ink(primary, t)),
    secondary: (bg: secondary, fg: label-ink(secondary, t)),
    destructive: (bg: destructive, fg: label-ink(destructive, t)),
    outline: (bg: fill-bg, fg: t.text-color),
    success: (bg: success, fg: label-ink(success, t)),
  )
  let s = styles.at(variant, default: styles.default)
  box(
    fill: s.bg,
    stroke: if variant == "outline" { if t.border != none { t.border } else { 0.5pt + t.text-color-light } } else { none },
    inset: (x: t.axis-label-gap * 0.7, y: t.axis-label-gap * 0.25),
    radius: t.border-radius,
    // (the theme's smallest type: a badge reads as text, not as a mark)
    text(size: t.axis-label-size, weight: "bold", fill: s.fg, upper(label)),
  )
}

/// Renders a themed horizontal rule separator.
///
/// - thickness (length): Line thickness
/// - theme (none, dictionary): Theme overrides
/// -> content
#let separator(thickness: 0.75pt, theme: none) = context {
  let t = _resolve-ctx(theme)
  let color = if t.border != none {
    let b = t.border
    if type(b) == color { b }
    else if type(b) == stroke { b.paint }
    else { t.text-color-light }
  } else { t.text-color-light }
  v(4pt)
  line(length: 100%, stroke: thickness + color)
  v(4pt)
}

/// Lays out content blocks in a dashboard grid.
///
/// - cols (int, array): Number of equal columns, or array of column widths (e.g., `(2fr, 1fr)`)
/// - rows (array): Array of arrays, where each inner array contains the content blocks for that row.
///   Example: `((card1, card2), (card3,))` creates 2 rows.
/// - gap (length): Gap between cells
/// - row-gap (none, length): Vertical gap between rows; defaults to `gap` if none
/// -> content
#let dashboard-layout(rows, cols: 2, gap: 6pt, row-gap: none) = {
  let rg = if row-gap != none { row-gap } else { gap }
  let col-spec = if type(cols) == int {
    range(cols).map(_ => 1fr)
  } else {
    cols
  }

  for (i, row) in rows.enumerate() {
    if i > 0 { v(rg) }
    grid(
      columns: col-spec,
      column-gutter: gap,
      ..row
    )
  }
}
