#import "lib.typ": metrics


#let typography = {
  let multiplier = 1.5

  (
    size: 12pt,
    line-march: multiplier * 1em,
    line-across: (2 * multiplier - 1) * 1em,
    leading: (multiplier - 1) * 1em,
  )
}

#set text(
  typography.size,
  font: "American Typewriter",
)

#set par(
  first-line-indent: 1.5em,
  leading: typography.leading,
)
#show par: set block(spacing: typography.leading)

#show heading: set text(typography.size)

= Samples

#let samples = (
  (
    content: metrics(
      72pt,
      "EB Garamond",
      "Typewriter"
    ),
    caption: "The metrics of EB Garamond"
  ),
  (
    content: metrics(
      54pt,
      "Hiragino Mincho ProN",
      "電傳打字機"
    ),
    caption: "The metrics of Hiragino Mincho ProN"
  )
).map(it => figure(
  block(
    inset: (y: 1em),
    it.content
  ),
  caption: it.caption
))

`metrics(72pt, "EB Garamond", "Typewriter")` will be rendered as follows:

#samples.at(0)

#rect(inset: 1em)[
  *Remark*: To typeset CJK text, adopting font's ascender/descender as
  `top-edge`/`bottom-edge` makes more sense in some cases. As for most
  CJK fonts, the difference between ascender and descender height will
  be exact 1em.

  Tested with `metrics(54pt, "Hiragino Mincho ProN", "電傳打字機")`:

  #samples.at(1)
]
