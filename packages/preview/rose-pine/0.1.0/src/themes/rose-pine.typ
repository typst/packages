#let rose-pine = (
  base    : rgb("#191724"),
  surface : rgb("#1f1d2e"),
  overlay : rgb("#26233a"),
  muted   : rgb("#6e6a86"),
  subtle  : rgb("#908caa"),
  text    : rgb("#e0def4"),
  love    : rgb("#eb6f92"),
  gold    : rgb("#f6c177"),
  rose    : rgb("#ebbcba"),
  pine    : rgb("#31748f"),
  foam    : rgb("#9ccfd8"),
  iris    : rgb("#c4a7e7"),
  highlight : (
    low     : rgb("#21202e"),
    med     : rgb("#403d52"),
    high    : rgb("#524f67"),
  )
)

#let theme(content) = [
  #set page(fill: rose-pine.base,)
  #set text(fill: rose-pine.text,)
  #set table(fill: rose-pine.surface, stroke: rose-pine.highlight.high)
  #set circle(stroke: rose-pine.subtle, fill: rose-pine.overlay)
  #set ellipse(stroke: rose-pine.subtle, fill: rose-pine.overlay)
  #set line(stroke: rose-pine.subtle)
  #set path(stroke: rose-pine.subtle, fill: rose-pine.overlay)
  #set polygon(stroke: rose-pine.subtle, fill: rose-pine.overlay)
  #set rect(stroke: rose-pine.subtle, fill: rose-pine.overlay)
  #set square(stroke: rose-pine.subtle, fill: rose-pine.overlay)
  #show link: it => [
    #set text(fill: rose-pine.iris)
    #it
  ]
  #show ref: it => [
    #set text(fill: rose-pine.foam)
    #it
  ]
  #show footnote: it => [
    #set text(fill: rose-pine.pine)
    #it
  ]
  #content
]
