#let upb-colors = (
  ultra-blue: rgb(26,34,164),
  arctic-blue: rgb(118,206,208),
  ocean-blue: rgb(81,165,197),
  sky-blue: rgb(52,115,190),
  sapphire-blue: rgb(24,28,98),
  iris-violet: rgb(126,63,168),
  fuchsia-red: rgb(193,56,160),
)

#let code = (..arguments) => {
  highlight(
    fill: luma(240),
    top-edge: 1em,
    bottom-edge: -0.3em,
    extent: 0.05em,
    raw(..arguments),
  )
}

#let notebox = (content) => {
  set grid(row-gutter: 0.7em, column-gutter: 1.2em)
  box(
    fill: luma(250),
    width: 100%,
    inset: (left: 1.5em, right:1.5em, top: 1.1em, bottom:1.1em),
    stroke: .4pt,
    outset: 0em,
    content,
  )
}

#let heading-font = "Linux Biolinum" // https://www.dafont.com/linux-biolinum.font

// https://forum.typst.app/t/1677/5
#let overlay(color, body) = layout(bounds => {
  let size = measure(body, ..bounds)
  body
  place(top + left, block(..size, fill: color))
})
