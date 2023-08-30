#let rose-pine-moon = (
  base    : rgb("#232136"),
  surface : rgb("#2a273f"),
  overlay : rgb("#393552"),
  muted   : rgb("#6e6a86"),
  subtle  : rgb("#908caa"),
  text    : rgb("#e0def4"),
  love    : rgb("#eb6f92"),
  gold    : rgb("#f6c177"),
  rose    : rgb("#ea9a97"),
  pine    : rgb("#3e8fb0"),
  foam    : rgb("#9ccfd8"),
  iris    : rgb("#c4a7e7"),
  highlight : (
    low     : rgb("#2a283e"),
    med     : rgb("#44415a"),
    high    : rgb("#56526e"),
  )
)

#let theme(content) = [
  #set page(fill: rose-pine-moon.base,)
  #set text(fill: rose-pine-moon.text,)
  #set table(fill: rose-pine-moon.surface, stroke: rose-pine-moon.highlight.high)
  #set circle(stroke: rose-pine-moon.subtle, fill: rose-pine-moon.overlay)
  #set ellipse(stroke: rose-pine-moon.subtle, fill: rose-pine-moon.overlay)
  #set line(stroke: rose-pine-moon.subtle)
  #set path(stroke: rose-pine-moon.subtle, fill: rose-pine-moon.overlay)
  #set polygon(stroke: rose-pine-moon.subtle, fill: rose-pine-moon.overlay)
  #set rect(stroke: rose-pine-moon.subtle, fill: rose-pine-moon.overlay)
  #set square(stroke: rose-pine-moon.subtle, fill: rose-pine-moon.overlay)
  #show link: it => [
    #set text(fill: rose-pine-moon.iris)
    #it
  ]
  #show ref: it => [
    #set text(fill: rose-pine-moon.foam)
    #it
  ]
  #show footnote: it => [
    #set text(fill: rose-pine-moon.pine)
    #it
  ]
  #content
]
