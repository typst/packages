#import "core/theming.typ" as core
#import "components/button.typ" as buttons
#import "components/sidebar.typ" as sidebar
#import "components/sweeps.typ" as sweeps
#import "layout/single-page-layout.typ": *
#import "layout/multi-page-layout.typ": *

#let theme-state = state("theme-state")

#let tiefcars(
  theme: "tng",
  body,
) = {
  core.apply-theme(theme)

  context {
    let theme = theme-state.get()
    set text(font: "Antonio", size: 10.5pt, fill: theme.fg)
    set page(margin: 20pt, fill: theme.bg)

    body
  }
}

