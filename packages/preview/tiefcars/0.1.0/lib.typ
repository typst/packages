#import "core/theming.typ" as core
#import "components/button.typ" as buttons
#import "components/sidebar.typ" as sidebar

#let theme-state = state("theme-state")

#let tiefcars(
  theme: "tng",
  body,
) = {
  core.apply-theme(theme)

  context {
    let theme = theme-state.final()
    set text(font: "Antonio", size: 10.5pt, fill: theme.fg)
    set page(margin: 10pt, fill: theme.bg)

    body
  }
}

#let default-layout(title: none, subtitle-text: none, body) = {
  sidebar.sidebar()

  context {
    let theme = theme-state.final()
    set text(fill: theme.heading, size: 40pt)
    place(top + right, title)
  }

  place(top+left, dx: 120pt,  dy: 60pt, box(width: 100% - 120pt, align(left, subtitle-text)))

  place(top + left, dx: 120pt, dy: 45pt * 3 + 180pt, box(
    clip: true,
    width: 100% - 120pt,
    height: 100% - 45pt * 3 + 180pt,
    body,
  ))
}
