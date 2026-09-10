#import "core.typ": severity-order, version
#import "collect.typ": paged

#let _plurals = (info: "info", warning: "warnings", error: "errors")

#let _count(n, severity) = {
  str(n) + " " + if n == 1 { severity } else { _plurals.at(severity) }
}

/// "1 error, 3 warnings", in decreasing severity skipping empty buckets
#let summary(findings) = {
  let parts = severity-order
    .rev()
    .map(sev => (sev, findings.filter(f => f.severity == sev).len()))
    .filter(((sev, n)) => n > 0)
    .map(((sev, n)) => _count(n, sev))
  if parts.len() == 0 { "no issues" } else { parts.join(", ") }
}

#let format-text(findings) = {
  if findings.len() == 0 { return "" }

  let lines = ()
  for f in findings {
    lines.push(f.severity + ": " + f.message + " [" + f.id + "]")
    if f.page-label != none { lines.push("  ┌─ page " + f.page-label) }
  }
  lines.push("")
  lines.push("sanity: " + summary(findings))
  lines.join("\n")
}

#let _colors = (
  info: rgb("#608FEA"),
  warning: rgb("#FFBB3E"),
  error: rgb("#F06262"),
)

/// a tint of a colour
#let wash(colour) = {
  let target = 97%
  let alpha = (100% - target) / (100% - luma(colour).components().first())
  colour.transparentize((1 - alpha) * 100%)
}

#let _pill(severity) = {
  let colour = _colors.at(severity)
  box(
    width: 38pt,
    fill: wash(colour),
    inset: (x: 0pt, y: 2pt),
    outset: (y: 3pt),
    radius: 2pt,
    align(center, text(size: 0.85em, fill: colour, severity)),
  )
}

/// the page a finding sits on
#let _where(f, locations) = {
  if f.page-label == none { return [] }
  let label = "page " + f.page-label
  let loc = if f.target == none { none } else {
    locations.at(f.target, default: none)
  }
  text(fill: _colors.info, if loc == none { label } else { link(loc, label) })
}

#let _body(findings, locations) = [
  #set text(
    font: ("DejaVu Sans Mono",),
    size: 8.5pt,
    fill: rgb("#1c1c1c"),
    lang: "en",
    dir: ltr,
  )
  #set par(justify: false, leading: 0.55em, spacing: 0.9em)
  #set align(left + top)

  #text(weight: "bold")[sanity]
  #h(0.35em)
  #text(fill: rgb("#8b9096"))[v#version]
  #h(0.6em)
  #text(fill: _colors.info, summary(findings))
  #line(length: 100%, stroke: 0.4pt + rgb("#c8ccd2"))
  #v(0.4em)

  #grid(
    columns: (auto, 1fr, auto),
    column-gutter: 0.9em,
    row-gutter: 0.7em,
    ..for f in findings {
      (
        _pill(f.severity),
        [
          #f.message \
          #text(fill: _colors.info, size: 0.85em, f.id)
        ],
        _where(f, locations),
      )
    }
  )

  #v(1.2em)
  #text(size: 0.85em, fill: rgb("#8b9096"))[
    sanity added this page; report: none, or \--input sanity=off, leaves it out.
  ]
]

/// the same findings appended to the document
#let appended-report(findings, locations: (:)) = {
  if findings.len() == 0 { return none }

  if paged() {
    page(
      columns: 1,
      header: none,
      footer: none,
      numbering: none,
      fill: white,
      background: none,
      foreground: none,
      _body(findings, locations),
    )
  } else {
    raw(format-text(findings), block: true)
  }
}
