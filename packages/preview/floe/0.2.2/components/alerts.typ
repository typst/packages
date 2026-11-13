// ============================================================================
// FLOE DESIGN SYSTEM — SHADCN ALERTS & EXAM TRAPS (components/alerts.typ)
// Authentic Shadcn Callouts: Delicate Borders, Icon Circles, Bold Title Hierarchy
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": alert
#import "academic.typ": _parse-args

#let _render-comparison-chip(tag-txt, tag-color, border-color, content, h: auto) = block(
  width: 100%,
  height: h,
  fill: white,
  stroke: strokes.hairline + border-color,
  radius: radii.sm,
  inset: (x: 8pt, y: 6pt),
)[
  #text(font: fonts.sans, size: 7.5pt, weight: "bold", fill: tag-color)[#tag-txt]
  #v(2.5pt)
  #block(width: 100%)[
    #show math.equation.where(block: true): it => align(left, it)
    #set align(left)
    #set text(size: 8.5pt)
    #content
  ]
]

/// Closed-Book Exam Trap / Pitfall Callout (Shadcn Danger Alert with mistake vs correct chips)
#let pitfall(..args) = {
  let (title, body) = _parse-args(args)
  let mistake = if "mistake" in args.named() { args.named().mistake } else { none }
  let correct = if "correct" in args.named() { args.named().correct } else { none }

  let icon = box(
    width: 16pt,
    height: 16pt,
    fill: rgb("#FEE2E2"),
    radius: radii.full,
    align(center + horizon)[
      #text(font: fonts.sans, size: 9pt, weight: "bold", fill: rgb("#DC2626"))[⚠]
    ]
  )

  let display-title = if title != none {
    "CLOSED-BOOK EXAM TRAP: " + title
  } else {
    "CLOSED-BOOK EXAM TRAP"
  }

  alert(
    variant: "danger",
    title: display-title,
    icon: icon,
  )[
    #body
    #if mistake != none or correct != none [
      #v(6pt)
      #layout(size => {
        let col-w = (size.width - 8pt) / 2
        context {
          let m-m = if mistake != none {
            measure(block(width: col-w, _render-comparison-chip("✕ COMMON MISTAKE", rgb("#B91C1C"), rgb("#FECDD3"), mistake)))
          } else { (height: 0pt) }
          let m-c = if correct != none {
            measure(block(width: col-w, _render-comparison-chip("✓ CORRECT FORM", rgb("#15803D"), rgb("#BBF7D0"), correct)))
          } else { (height: 0pt) }
          let max-h = calc.max(m-m.height, m-c.height)

          grid(
            columns: (1fr, 1fr),
            gutter: 8pt,
            if mistake != none [
              #_render-comparison-chip("✕ COMMON MISTAKE", rgb("#B91C1C"), rgb("#FECDD3"), mistake, h: max-h)
            ],
            if correct != none [
              #_render-comparison-chip("✓ CORRECT FORM", rgb("#15803D"), rgb("#BBF7D0"), correct, h: max-h)
            ],
          )
        }
      })
    ]
  ]
}

/// Closed-Book Exam Alert / Key Formula Reminder (Amber Alert)
#let exam-alert(..args) = {
  let (title, body) = _parse-args(args)
  let icon = box(
    width: 16pt,
    height: 16pt,
    fill: rgb("#FEF3C7"),
    radius: radii.full,
    align(center + horizon)[
      #text(font: fonts.sans, size: 9pt, weight: "bold", fill: rgb("#D97706"))[⚡]
    ]
  )
  let display-title = if title != none {
    "EXAM ALERT (NO FORMULA SHEET): " + title
  } else {
    "EXAM ALERT (NO FORMULA SHEET)"
  }

  alert(
    variant: "warning",
    title: display-title,
    icon: icon,
    body,
  )
}

/// Informational Note (Sky Blue Alert)
#let note(..args) = {
  let (title, body) = _parse-args(args)
  let icon = box(
    width: 16pt,
    height: 16pt,
    fill: rgb("#E0F2FE"),
    radius: radii.full,
    align(center + horizon)[
      #text(font: fonts.sans, size: 9pt, weight: "bold", fill: rgb("#0284C7"))[ℹ]
    ]
  )
  let display-title = if title != none { "NOTE: " + title } else { "NOTE" }

  alert(
    variant: "info",
    title: display-title,
    icon: icon,
    body,
  )
}

/// Engineering Pro-Tip / Best Practice (Emerald Green Alert)
#let tip(..args) = {
  let (title, body) = _parse-args(args)
  let icon = box(
    width: 16pt,
    height: 16pt,
    fill: rgb("#DCFCE7"),
    radius: radii.full,
    align(center + horizon)[
      #text(font: fonts.sans, size: 9pt, weight: "bold", fill: rgb("#16A34A"))[💡]
    ]
  )
  let display-title = if title != none { "ENGINEERING TIP: " + title } else { "ENGINEERING TIP" }

  alert(
    variant: "success",
    title: display-title,
    icon: icon,
    body,
  )
}

/// Warning / Saturation Notice (Amber-Orange Alert)
#let warning(..args) = {
  let (title, body) = _parse-args(args)
  let icon = box(
    width: 16pt,
    height: 16pt,
    fill: rgb("#FFEDD5"),
    radius: radii.full,
    align(center + horizon)[
      #text(font: fonts.sans, size: 9pt, weight: "bold", fill: rgb("#EA580C"))[▲]
    ]
  )
  let display-title = if title != none { "WARNING: " + title } else { "WARNING" }

  alert(
    variant: "warning",
    title: display-title,
    icon: icon,
    body,
  )
}
