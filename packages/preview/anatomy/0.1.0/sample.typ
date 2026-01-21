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
      "一點明體",
      "電傳打字機",
      typeset: metrics => table(
        columns: 2,
        ..metrics.pairs().flatten().map(x => [ #x ])
      )
    ),
    caption: "The metrics of I.Ming (table attached)"
  ),
  (
    content: metrics(
      54pt,
      "Hiragino Mincho ProN",
      "テレタイプ端末"
    ),
    caption: "The metrics of Hiragino Mincho ProN"
  )
).map(it => figure(
  it.content,
  caption: it.caption
))

`metrics(72pt, "EB Garamond", "Typewriter")` will be rendered as follows:

#samples.at(0)

Additionally, a closure using `metrics` dictionary as parameter can be
specified for further typesetting:

```typ
metrics(54pt, "一點明體", "電傳打字機",
  typeset: metrics => table(
    columns: 2,
    ..metrics.pairs().flatten().map(x => [ #x ])
  )
)
```

It will generate:

#samples.at(1)

#rect(inset: 1em)[
  *Remark*: To typeset CJK text, adopting font's ascender/descender as
  `top-edge`/`bottom-edge` makes more sense in some cases. As for most
  CJK fonts, the difference between ascender and descender heights will
  be exact 1em.

  Tested with `metrics(54pt, "Hiragino Mincho ProN", "テレタイプ端末")`:

  #samples.at(2)
]
