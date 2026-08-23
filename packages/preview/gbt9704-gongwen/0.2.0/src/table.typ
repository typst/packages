// table.typ — 表格主题样式
// 提供两个接口：
//   apply(theme, align-h)  — 全局 show/set 规则
//   wrap(theme, body, align-h) — 单表包裹
//
// align-h: "center" (default) | "left" | "right"

// ── Theme data ──

#let _themes = (
  plain: (
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    rule-bottom: none,
    align: auto,
    fill: none,
  ),
  "full-grid": (
    stroke: 0.5pt,
    inset: (x: 5pt, y: 4pt),
    rule-bottom: none,
    align: auto,
    fill: none,
  ),
  "single-line": (
    stroke: (_, y) => if y == 0 {
      (bottom: 1pt, top: none, left: none, right: none)
    } else {
      none
    },
    inset: (x: 5pt, y: 4pt),
    rule-bottom: none,
    fill: (_, y) => if calc.odd(y) { gray.lighten(90%) },
    align: (x, y) =>
      if x == 0 { right } else { left }
      + if y == 0 { bottom } else { top },
  ),
  "three-line": (
    stroke: (x, y) => {
      if y == 0 {
        (top: 1.5pt, bottom: 0.5pt, left: none, right: none)
      } else {
        (top: none, bottom: none, left: none, right: none)
      }
    },
    inset: (x: 5pt, y: 4pt),
    rule-bottom: 1.5pt,
    align: auto,
    fill: none,
  ),
)

// ── Helpers ──

// Wrap body with horizontal alignment + optional bottom rule.
//   align-h: left | center | right
//   block(width: 100%) neutralizes paragraph first-line-indent.
#let _align-wrap(body, align-h, rule-bottom) = {
  let inner = if rule-bottom != none {
    block(width: auto, stroke: (bottom: rule-bottom), inset: 0pt, body)
  } else {
    block(width: auto, inset: 0pt, body)
  }

  if align-h == left {
    block(width: 100%, inset: 0pt, inner)
  } else if align-h == right {
    block(width: 100%, inset: 0pt,
      align(right, inner)
    )
  } else { // center (default)
    block(width: 100%, inset: 0pt,
      align(center, inner)
    )
  }
}

// ── Public API ──

/// Apply a table theme globally via show/set rules.
/// - `theme` (str): `"full-grid"` (default) | `"three-line"` | `"single-line"` | `"plain"`
/// - `align-h` (str): `"center"` (default) | `"left"` | `"right"`
#let apply(theme, align-h: center) = {
  let t = _themes.at(theme, default: _themes.at("full-grid"))

  show table: set par(first-line-indent: (amount: 0em, all: true))
  show table.cell.where(y: 0): set text(stroke: 0.6pt + black)

  show table: set table(
    stroke: t.stroke,
    inset: t.inset,
    fill: t.fill,
    align: t.align,
  )

  show table: it => _align-wrap(it, align-h, t.rule-bottom)
}

/// Wrap a single table with theme-specific styling.
/// - `theme` (str): `"full-grid"` | `"three-line"` | `"single-line"` | `"plain"`
/// - `body` (content): content block containing `#table(...)`
/// - `align-h` (str): `"center"` (default) | `"left"` | `"right"`
#let wrap(theme, body, align-h: center) = {
  let t = _themes.at(theme, default: _themes.at("full-grid"))

  {
    set par(first-line-indent: (amount: 0em, all: true))
    show table.cell.where(y: 0): set text(stroke: 0.6pt + black)

    set table(
      stroke: t.stroke,
      inset: t.inset,
      fill: t.fill,
      align: t.align,
    )

    _align-wrap(body, align-h, t.rule-bottom)
  }
}
