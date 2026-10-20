#import "theme.typ": accent-color

/// Chapter overview. Accepts paragraphs, lists, math and links.
#let introduction(title: auto, body) = context {
  let accent = accent-color.get()
  let actual-title = if title == auto {
    if text.lang.starts-with("zh") { [本章提要] } else { [In this chapter] }
  } else { title }
  block(
    width: 100%, breakable: true,
    fill: accent.lighten(96%),
    stroke: (left: 2.5pt + accent),
    inset: (x: 14pt, y: 11pt),
    radius: (right: 3pt),
    above: 10pt, below: 18pt,
    {
      set par(first-line-indent: 0pt)
      block(sticky: true, above: 0pt, below: 6pt, text(fill: accent, weight: "bold", actual-title))
      body
    },
  )
}
