#import "../components/sidebar.typ" as sidebar

#let single-page-layout(title: none, subtitle-text: none, top-height: 4, sidebar-button-texts: (), body) = {
  sidebar.sidebar(top-height: top-height, button-texts: sidebar-button-texts)

  context {
    let theme = state("theme-state").get()
    set text(fill: theme.heading, size: 40pt, weight: "bold")
    place(top + right, title)
  }

  place(top + left, dx: 120pt, dy: 60pt, box(width: 100% - 120pt, align(left, subtitle-text)))

  place(top + left, dx: 120pt, dy: top-height * 45pt + 160pt, box(
    width: 100% - 120pt,
    height: 100% - top-height * 45pt - 160pt,
    body,
  ))
}
