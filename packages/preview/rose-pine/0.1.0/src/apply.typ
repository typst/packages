#let apply-theme(content, theme-data) = [
  #set page(fill: theme-data.base,)
  #set text(fill: theme-data.text,)
  #set table(fill: theme-data.surface, stroke: theme-data.highlight.high)
  #set circle(stroke: theme-data.subtle, fill: theme-data.overlay)
  #set ellipse(stroke: theme-data.subtle, fill: theme-data.overlay)
  #set line(stroke: theme-data.subtle)
  #set path(stroke: theme-data.subtle, fill: theme-data.overlay)
  #set polygon(stroke: theme-data.subtle, fill: theme-data.overlay)
  #set rect(stroke: theme-data.subtle, fill: theme-data.overlay)
  #set square(stroke: theme-data.subtle, fill: theme-data.overlay)
  #show link: it => [
    #set text(fill: theme-data.iris)
    #it
  ]
  #show ref: it => [
    #set text(fill: theme-data.foam)
    #it
  ]
  #show footnote: it => [
    #set text(fill: theme-data.pine)
    #it
  ]
  #content
]


#let apply(
  variant: "rose-pine"
) = {
  return  (content) => [
    #import "themes/" + variant + ".typ": variant as theme-data
    #apply-theme(content, theme-data)
  ]
}
