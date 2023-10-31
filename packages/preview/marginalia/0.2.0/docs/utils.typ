////
// Inspiration: https://github.com/typst/packages/blob/main/packages/preview/cetz/0.1.0/manual.typ
////

#import "../marginalia.typ"
#import "@preview/tidy:0.1.0"

#let example-box = box.with(fill: white.darken(3%), inset: 0.5em, radius: 0.5em, width: 100%)
// This is a wrapper around typs-doc show-module that
// strips all but one function from the module first.
// As soon as typst-doc supports examples, this is no longer
// needed.
#let show-module-fn(module, fn, ..args) = {
  module.functions = module.functions.filter(f => f.name == fn)
  tidy.show-module(module, ..args.pos(), ..args.named(),
                   show-module-name: false, style: tidy.styles.default)
}


#let dummy-page(content, width, height: auto, margin-left, margin-right) = {
  let total-width = width + margin-left + margin-right
  style(styles => {
    let content-box = box(
      height: height,
      width: width,
      fill: white,
      stroke: (left: black + 0.5pt, right: black + 0.5pt),
      inset: 3pt,
      content,
    )
    let box-height = measure(content-box, styles).height
    let height = if height == auto {box-height}
    example-box(height: height, width: total-width)
    place(
      dx: margin-left,
      dy: -height,
      content-box
    )
  })
}


#let _build-preamble(scope) = {
  let preamble = ""
  for module in scope.keys() {
    preamble = preamble + "import " + module + ": *; "
  }
  preamble
}

#let eval-example(source, ..scope) = {
  let preamble = _build-preamble(scope.named())
  eval(
    (preamble + "[" + source + "]"), scope: scope.named()
  )
}

#let _bidir-grid(direction, ..args) = {
  let grid-kwargs = (:)
  if direction == ltr {
    grid-kwargs = (columns: 2, column-gutter: 1em)
  } else {
    grid-kwargs = (rows: 2, row-gutter: 1em, columns: (100%,))
  }
  grid(..grid-kwargs, ..args)
}

#let example-with-source(source, inline: false, direction: ttb, ..scope) = {
    let picture = eval-example(source, ..scope)
    let source-box = if inline {box} else {block}
    
    _bidir-grid(direction)[
      #example-box(raw(lang: "typ", source))
    ][
    #example-box(picture)
    ]

}


#let _make-page(source, offset, w, l, r, scope) = {
  let props = (
      "margin-right:" + repr(r)
      + ", margin-left:" + repr(l)
      + ", page-width:" + repr(w)
      + ", page-offset-x: " + repr(offset)
    )
    let preamble = "#let margin-note = margin-note.with(" + props + ")\n"
    let content = eval-example(preamble + source.text, ..scope)
    dummy-page(content, w, l, r)
}

#let standalone-margin-note-example(
  source,
  width: 2in,
  margin-left: 0.8in,
  margin-right: 1in,
  scope: (marginalia:marginalia),
  direction: ltr,
) = {
  let (l, r) = (margin-left, margin-right)
  let number-args = (width, l, r)
  let content = _make-page(source, 0pt, ..number-args, scope)
  _bidir-grid(direction)[
    #example-box(width: 100%, source)
  ][
    #locate(loc => {
      let offset = loc.position().x
      set text(font: "linux libertine")
      layout(layout-size => {
        style(styles => {
          let minipage = content
          let minipage-size = measure(minipage, styles)
          let (width, height) = (minipage-size.width, minipage-size.height)
          let ratio = (layout-size.width / width) * 100%
          let w = width
          let number-args = number-args.map(n => n * ratio)
          minipage = _make-page(source, offset, ..number-args, scope)
          minipage
        })
      })
    })
  ]
}
