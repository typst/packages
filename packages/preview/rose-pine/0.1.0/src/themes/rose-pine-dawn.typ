#let rose-pine-dawn = (
  base    : rgb("#faf4ed"),
  surface : rgb("#fffaf3"),
  overlay : rgb("#f2e9e1"),
  muted   : rgb("#9893a5"),
  subtle  : rgb("#797593"),
  text    : rgb("#575279"),
  love    : rgb("#b4637a"),
  gold    : rgb("#ea9d34"),
  rose    : rgb("#d7827e"),
  pine    : rgb("#286983"),
  foam    : rgb("#56949f"),
  iris    : rgb("#907aa9"),
  highlight : (
    low     : rgb("#f4ede8"),
    med     : rgb("#dfdad9"),
    high    : rgb("#cecacd"),
  )
)

#let theme(content) = [
  #set page(fill: rose-pine-dawn.base,)
  #set text(fill: rose-pine-dawn.text,)
  #set table(fill: rose-pine-dawn.surface, stroke: rose-pine-dawn.highlight.high)
  #set circle(stroke: rose-pine-dawn.subtle, fill: rose-pine-dawn.overlay)
  #set ellipse(stroke: rose-pine-dawn.subtle, fill: rose-pine-dawn.overlay)
  #set line(stroke: rose-pine-dawn.subtle)
  #set path(stroke: rose-pine-dawn.subtle, fill: rose-pine-dawn.overlay)
  #set polygon(stroke: rose-pine-dawn.subtle, fill: rose-pine-dawn.overlay)
  #set rect(stroke: rose-pine-dawn.subtle, fill: rose-pine-dawn.overlay)
  #set square(stroke: rose-pine-dawn.subtle, fill: rose-pine-dawn.overlay)
  #show link: it => [
    #set text(fill: rose-pine-dawn.iris)
    #it
  ]
  #show ref: it => [
    #set text(fill: rose-pine-dawn.foam)
    #it
  ]
  #show footnote: it => [
    #set text(fill: rose-pine-dawn.pine)
    #it
  ]
  #content
]
