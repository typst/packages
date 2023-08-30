#let $id = (
  base    : rgb("$base"),
  surface : rgb("$surface"),
  overlay : rgb("$overlay"),
  muted   : rgb("$muted"),
  subtle  : rgb("$subtle"),
  text    : rgb("$text"),
  love    : rgb("$love"),
  gold    : rgb("$gold"),
  rose    : rgb("$rose"),
  pine    : rgb("$pine"),
  foam    : rgb("$foam"),
  iris    : rgb("$iris"),
  highlight : (
    low     : rgb("$highlightLow"),
    med     : rgb("$highlightMed"),
    high    : rgb("$highlightHigh"),
  )
)

#let theme(content) = [
  #set page(fill: $id.base,)
  #set text(fill: $id.text,)
  #set table(fill: $id.surface, stroke: $id.highlight.high)
  #set circle(stroke: $id.subtle, fill: $id.overlay)
  #set ellipse(stroke: $id.subtle, fill: $id.overlay)
  #set line(stroke: $id.subtle)
  #set path(stroke: $id.subtle, fill: $id.overlay)
  #set polygon(stroke: $id.subtle, fill: $id.overlay)
  #set rect(stroke: $id.subtle, fill: $id.overlay)
  #set square(stroke: $id.subtle, fill: $id.overlay)
  #show link: it => [
    #set text(fill: $id.iris)
    #it
  ]
  #show ref: it => [
    #set text(fill: $id.foam)
    #it
  ]
  #show footnote: it => [
    #set text(fill: $id.pine)
    #it
  ]
  #content
]
