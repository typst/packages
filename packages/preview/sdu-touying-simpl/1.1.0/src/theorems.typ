// SDU Theorem Environments (pure Typst implementation)

// Default colors
#let _sdu-primary = rgb("#880000")
#let _sdu-fill = _sdu-primary.lighten(92%)
#let _sdu-def-fill = _sdu-primary.lighten(95%)
#let _sdu-accent = rgb("#e67e22")

// Shared theorem counter
#let _sdu-thm-counter = counter("sdu-theorem")

// Internal render function
#let _sdu-frame(
  supplement,
  body,
  title: none,
  fill: _sdu-fill,
  stroke-color: _sdu-primary,
  title-color: _sdu-primary,
  numbered: true,
) = {
  _sdu-thm-counter.step()
  block(
    fill: fill,
    stroke: (left: 3pt + stroke-color),
    inset: 10pt,
    radius: 2pt,
    width: 100%,
    {
      context {
        let num = _sdu-thm-counter.get().first()
        let num-str = if numbered { numbering("1", num) } else { none }
        let prefix = if num-str != none { supplement + " " + num-str } else { supplement }
        if title != none {
          block(
            fill: stroke-color,
            inset: (x: 8pt, y: 4pt),
            radius: (top-left: 0pt, rest: 4pt),
            text(fill: white, weight: "bold", prefix + ". " + title),
            below: 6pt,
          )
        } else {
          text(fill: title-color, weight: "bold", prefix)
          linebreak()
          v(4pt)
        }
      }
      body
    },
  )
}

// Public API
#let sdu-theorem(title: none, body) = _sdu-frame(
  "定理", body, title: title,
  fill: _sdu-fill, stroke-color: _sdu-primary, title-color: _sdu-primary,
)

#let sdu-definition(title: none, body) = _sdu-frame(
  "定义", body, title: title,
  fill: _sdu-def-fill, stroke-color: _sdu-primary.lighten(20%), title-color: _sdu-primary,
)

#let sdu-lemma(title: none, body) = _sdu-frame(
  "引理", body, title: title,
  fill: _sdu-fill, stroke-color: _sdu-primary, title-color: _sdu-primary,
)

#let sdu-corollary(title: none, body) = _sdu-frame(
  "推论", body, title: title,
  fill: _sdu-fill, stroke-color: _sdu-primary, title-color: _sdu-primary,
)

#let sdu-proof(body) = block(
  inset: 10pt,
  width: 100%,
  {
    text(fill: _sdu-primary, weight: "bold", "证明")
    linebreak()
    v(4pt)
    body
    h(1fr)
    $square$
  },
)

#let sdu-example(body) = {
  let _ex-counter = counter("sdu-example")
  _ex-counter.step()
  block(
    fill: _sdu-accent.lighten(90%),
    stroke: (left: 3pt + _sdu-accent),
    inset: 10pt,
    radius: 2pt,
    width: 100%,
    {
      text(fill: rgb("#d35400"), weight: "bold", "示例")
      linebreak()
      v(4pt)
      body
    },
  )
}

// No-op show rule (environments are self-contained)
#let show-sdu-theorems(body) = body
