#let colors=(
  primary: rgb("#142439"),
  secondary: rgb("#4839cf"),
  tertiary: rgb("#2678E4"),
  quaternary: rgb("#9ED9CD"),
)

#let theme=(
  image-zoom: 1.0,

  body-color: colors.primary,
  border-color: colors.quaternary,
  h1-color: colors.secondary,
  body-alt-color: colors.tertiary,
  table-gutter-color: colors.secondary,
  icon-color: colors.tertiary,
  icon-caption-color: colors.secondary,

  tag-separator: 0.2em,
  section-separator: 0.7em,

)


#let cal(body) = {
  text(fill:theme.icon-color,"📅")+h(0.2em)+text(fill:theme.icon-caption-color, body)
}

#let loc(body) = {
  text(fill:theme.icon-color,"🏢")+h(0.2em)+text(fill:theme.icon-caption-color, body)
}

#let calloc(date,location) = {
  cal(date)+h(1fr)+loc(location)
  v(0.3em)
}

#let link(icon) = {
  highlight(stroke: 0.3em+theme.icon-color, fill: theme.icon-color, text(fill:white)[#icon])
  h(0.2em)
}

#let tag(body,
) = context {
  set box(stroke: text.fill)
  box(
    stroke: 0.1em,
    inset: 0.4em,
    radius: 0.6em,
    body
  )
}

#let taglist(..values) = {
  set par(leading: 0.3em)
  block(above:0.5em)[#values.pos().map(x => tag(x)).join(h(0.3em))]
}

#let tags(body) = {
  show list: it => {
    taglist(..it.children.map(l => l.body))
  }
  body
}