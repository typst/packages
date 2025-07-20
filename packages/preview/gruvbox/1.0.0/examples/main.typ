#import "@local/gruvbox:1.0.0": gruvbox, theme-colors

#set page(paper: "a7", height: auto)
#let content = [
  = #lorem(4)
  #lorem(15)#footnote[#lorem(5)]
  #highlight(lorem(3))@smith2023quantum
  #line()
  #table(
    columns: 3,
    ..for i in range(6) {
      ([cell \##(i + 1)],)
    },
  )
  #link("https://github.com/arsmoriendy/typst-gruvbox")
]

/// - clrs (array)
/// -> (array)
#let color-grid-cells(clrs) = {
  for c in clrs.values() {
    (grid.cell(rect(fill: c, height: 5mm)),)
  }
}

#let color-grid(cells) = grid(
  columns: cells.len(),
  ..cells,
  ..color-grid-cells(theme-colors.muted)
)

#let dark-color-grid = color-grid(color-grid-cells(theme-colors.dark.strong))
#let light-color-grid = color-grid(color-grid-cells(theme-colors.light.strong))

#show: gruvbox.with(theme: "dark", contrast: "hard")
#content
#dark-color-grid
#show: gruvbox.with(theme: "dark", contrast: "medium")
#content
#dark-color-grid
#show: gruvbox.with(theme: "dark", contrast: "soft")
#content
#dark-color-grid
#show: gruvbox.with(theme: "light", contrast: "hard")
#content
#light-color-grid
#show: gruvbox.with(theme: "light", contrast: "medium")
#content
#light-color-grid
#show: gruvbox.with(theme: "light", contrast: "soft")
#content
#light-color-grid
#show: gruvbox.with(print: true)
#content
#light-color-grid

#pagebreak()
#bibliography("refs.bib")
