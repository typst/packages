#import "lib.typ": metrics

// Samples in README
#let samples = (
  (
    content: metrics(
      72pt,
      "EB Garamond",
      display: "Typewriter"
    ),
    caption: "The metrics of EB Garamond (Google Fonts)"
  ),
  (
    content: metrics(
      54pt,
      "一點明體",
      display: "電傳打字機",
      use: metrics => table(
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
      display: "テレタイプ端末"
    ),
    caption: "The metrics of Hiragino Mincho ProN"
  )
).map(it => figure(
  it.content,
  caption: it.caption
))

#set page(
  fill: white,
  width: 420pt,
  margin: 0pt
)

// Sample 1
// Fit the page with exact same size of metrics
#set page(height: 124.35pt)
#style(styles => {
  let content = pad(
    y: 8pt,
    samples.at(0)
  )

  [
    #content

    // #measure(content, styles).height
  ]
})

// Sample 2
#set page(height: 179.59pt)
#style(styles => {
  let content = pad(
    y: 8pt,
    samples.at(1)
  )

  [
    #content

    // #measure(content, styles).height
  ]
})

// Sample 3
#set page(height: 84.39pt)
#style(styles => {
  let content = pad(
    y: 8pt,
    samples.at(2)
  )

  [
    #content

    // #measure(content, styles).height
  ]
})
