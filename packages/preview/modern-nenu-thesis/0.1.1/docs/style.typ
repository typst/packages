#import "@preview/tidy:0.4.3"

#let function-name-color = rgb("#4c66c5")
#let rainbow-map = (
  (rgb("#4598c6"), 0%), // 深青色
  (rgb("#5dbd89"), 33%), // 深绿色
  (rgb("#c6b940"), 66%), // 深黄色
  (rgb("#c66c64"), 100%), // 深红色
)
#let gradient-for-color-types = gradient.linear(angle: 7deg, ..rainbow-map)
#let gradient-for-tiling = gradient.linear(angle: -45deg, rgb("#c698b3"), rgb("#82c6c6")).sharp(2).repeat(5)


#let rainbow-map = (
  (rgb("#4598c6").darken(30%), 0%), // 更深的青色
  (rgb("#5dbd89").darken(30%), 33%), // 更深的绿色
  (rgb("#c6b940").darken(30%), 66%), // 更深的黄色
  (rgb("#c66c64").darken(30%), 100%), // 更深的红色
)

#let default-type-color = rgb("#000")  // 稍深的灰色

#let colors = (
  "default": default-type-color.darken(20%),
  "content": rgb("#6cb2ac").darken(30%), // 更深的青色
  "string": rgb("#86c6a0").darken(30%), // 更深的绿色
  "str": rgb("#86c6a0").darken(30%),
  "none": rgb("#c6867c").darken(30%), // 更深的红色
  "auto": rgb("#c6867c").darken(30%),
  "bool": rgb("#c6b486").darken(30%), // 更深的黄色
  "boolean": rgb("#c6b486").darken(30%),
  "integer": rgb("#ab98c6").darken(30%), // 更深的紫色
  "int": rgb("#ab98c6").darken(30%),
  "float": rgb("#ab98c6").darken(30%),
  "ratio": rgb("#ab98c6").darken(30%),
  "length": rgb("#ab98c6").darken(30%),
  "angle": rgb("#ab98c6").darken(30%),
  "relative length": rgb("#ab98c6").darken(30%),
  "relative": rgb("#ab98c6").darken(30%),
  "fraction": rgb("#ab98c6").darken(30%),
  "symbol": rgb(165, 196, 172).darken(30%), // 更深的浅绿
  "array": rgb(196, 165, 204).darken(30%), // 更深的浅紫
  "dictionary": rgb(196, 165, 204).darken(30%),
  "arguments": rgb(196, 165, 204).darken(30%),
  "selector": rgb(150, 162, 178).darken(30%), // 更深的灰蓝
  "datetime": rgb(150, 162, 178).darken(30%),
  "module": rgb(158, 160, 192).darken(30%), // 更深的淡紫
  "stroke": default-type-color.darken(20%),
  "function": rgb("#c698c6").darken(30%), // 更深的粉色
  "color": gradient-for-color-types,
  "gradient": gradient-for-color-types,
  "tiling": gradient-for-tiling,
  "signature-func-name": rgb("#445db5"),
)

#let module(
  code,
  name: none,
  label-prefix: "",
  ..args,
) = {
  context {
    let module = tidy.parse-module(
      code,
      name: name,
      label-prefix: label-prefix,
    )
    tidy.show-module(
      module,
      first-heading-level: 1,
      colors: colors,
    )
    pagebreak(weak: true)
  }
}

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  font: "",
  color: blue,
  top-text: "",
  pic: "",
  title: "",
  title-align: left,
  subtitle: "",
  publisher: "",
  publisher-font: ("Latin Modern Roman Caps", "Apple Chancery"),
  signature: "",
  margin: (top: 0in),
  url: none,
  date: none,
  version: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: signature, title: title)
  set page(numbering: "1", number-align: center)
  set heading(numbering: (first, ..other) => {
    let len = other.pos().len()
    if len == 0 { return first }
  })
  show heading: it => {
    set block(below: 1.25em, above: 1.25em)
    it
  }
  show outline: it => {
    show heading: set align(center)
    it
  }
  show list: pad.with(x: 5%)

  // show link: set text(fill: purple.darken(30%))
  show link: it => {
    let dest = str(it.dest)
    if "." in dest and not "/" in dest { return underline(it, stroke: luma(60%), offset: 1pt) }
    set text(fill: rgb("#1e8f6f"))
    underline(it)
  }

  // Main body.
  set text(lang: "zh", font: ("Times New Roman", "Songti SC"))
  show raw: set text(font: ("Courier New", "Menlo", "Monaco Nerd Font"))
  show raw.where(block: true): set par(first-line-indent: 0pt)
  set par(justify: true)
  v(7em)

  pad(x: 10%, outline(depth: 2, indent: 2em))
  pagebreak()

  body
}

#let ref-fn(name) = link(label(name), raw(name))

