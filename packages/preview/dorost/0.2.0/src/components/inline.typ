#import "../config.typ": default-fonts, default-colors

// Shared by the tone-bearing inline and block helpers.
#let tone-color(tone) = {
  if tone == "neutral" { default-colors.text }
  else if tone == "accent" { default-colors.accent }
  else if tone == "muted" { default-colors.muted }
  else { panic("dorost: tone must be \"neutral\", \"accent\", or \"muted\"") }
}

#let code-inline(value) = box({
  set text(dir: ltr, font: default-fonts.code)
  show raw: set text(dir: ltr, font: default-fonts.code)
  raw(value, block: false)
})

#let math-inline(body) = box({
  set text(dir: ltr)
  body
})

#let badge(body, tone: "accent") = {
  let color = tone-color(tone)
  box(inset: (x: 0.45em, y: 0.15em), radius: 0.25em, stroke: 0.5pt + color)[
    #text(fill: color, size: 0.85em, body)
  ]
}
