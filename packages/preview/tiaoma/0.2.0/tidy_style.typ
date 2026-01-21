// Based on default tidy style

// Modified to link to official documentation and allow linking to other
// document content.

#import "@preview/tidy:0.2.0": utilities, show-example as show-ex

// Color to highlight function names in
#let function-name-color = rgb("#4b69c6")
#let rainbow-map = ((rgb("#7cd5ff"), 0%), (rgb("#a6fbca"), 33%),(rgb("#fff37c"), 66%), (rgb("#ffa49d"), 100%))
#let gradient-for-color-types = gradient.linear(angle: 7deg, ..rainbow-map)

#let default-type-color = rgb("#eff0f3")

// Colors for Typst types
#let colors = (
  "default": default-type-color,
  "content": rgb("#a6ebe6"),
  "string": rgb("#d1ffe2"),
  "str": rgb("#d1ffe2"),
  "none": rgb("#ffcbc4"),
  "auto": rgb("#ffcbc4"),
  "boolean": rgb("#ffedc1"),
  "bool": rgb("#ffedc1"),
  "integer": rgb("#e7d9ff"),
  "int": rgb("#e7d9ff"),
  "float": rgb("#e7d9ff"),
  "ratio": rgb("#e7d9ff"),
  "length": rgb("#e7d9ff"),
  "angle": rgb("#e7d9ff"),
  "relative-length": rgb("#e7d9ff"),
  "relative length": rgb("#e7d9ff"),
  "relative": rgb("#e7d9ff"),
  "fraction": rgb("#e7d9ff"),
  "symbol": default-type-color,
  "array": default-type-color,
  "dictionary": default-type-color,
  "arguments": default-type-color,
  "selector": default-type-color,
  "module": default-type-color,
  "stroke": default-type-color,
  "function": rgb("#f9dfff"),
  "color": gradient-for-color-types,
  "gradient": gradient-for-color-types,
  "signature-func-name": rgb("#4b69c6"),
)

// Links to official type documentation
#let documentation = (
  "content": "https://typst.app/docs/reference/foundations/content/",
  "string": "https://typst.app/docs/reference/foundations/str/",
  "str": "https://typst.app/docs/reference/foundations/str/",
  "none": "https://typst.app/docs/reference/foundations/none/",
  "auto": "https://typst.app/docs/reference/foundations/auto/",
  "boolean": "https://typst.app/docs/reference/foundations/bool/",
  "bool": "https://typst.app/docs/reference/foundations/bool/",
  "integer": "https://typst.app/docs/reference/foundations/int/",
  "int": "https://typst.app/docs/reference/foundations/int/",
  "float": "https://typst.app/docs/reference/foundations/float/",
  "ratio": "https://typst.app/docs/reference/foundations/ratio/",
  "length": "https://typst.app/docs/reference/foundations/length/",
  "angle": "https://typst.app/docs/reference/foundations/angle/",
  "relative-length": "https://typst.app/docs/reference/foundations/array/",
  "relative length": "https://typst.app/docs/reference/foundations/array/",
  "relative": "https://typst.app/docs/reference/layout/relative/",
  "fraction": "https://typst.app/docs/reference/layout/fraction/",
  "symbol": "https://typst.app/docs/reference/symbols/symbol/",
  "array": "https://typst.app/docs/reference/foundations/array/",
  "dictionary": "https://typst.app/docs/reference/foundations/dictionary/",
  "arguments": "https://typst.app/docs/reference/foundations/arguments/",
  "selector": "https://typst.app/docs/reference/foundations/selector/",
  "module": "https://typst.app/docs/reference/foundations/module/",
  "stroke": "https://typst.app/docs/reference/visualize/stroke/",
  "function": "https://typst.app/docs/reference/foundations/function/",
  "color": "https://typst.app/docs/reference/visualize/color/",
  "gradient": "https://typst.app/docs/reference/visualize/gradient/",
)

#let colors-dark = {
  let k = (:)
  let darkify(clr) = clr.darken(30%).saturate(30%)
  for (key, value) in colors {
    if type(value) == color {
      value = darkify(value)
    } else if type(value) == gradient {
      let map = value.stops().map(((clr, stop)) => (darkify(clr), stop))
      value = value.kind()(..map)
    }
    k.insert(key, value)
  }
  k.signature-func-name = rgb("#4b69c6").lighten(40%)
  k
}

#let show-outline(module-doc, style-args: (:)) = {
  let prefix = module-doc.label-prefix
  if module-doc.functions.len() > 0 {
    list(..module-doc.functions.map(fn => link(label(prefix + fn.name + "()"), fn.name + "()")))
  }
    
  if module-doc.variables.len() > 0 {
    text([Variables:], weight: "bold")
    list(..module-doc.variables.map(var => link(label(prefix + var.name + ""), var.name + "()")))
  }
}

// Create beautiful, colored type box
#let show-type(type, style-args: (:), docs: (:)) = { 
  h(2pt)
  let clr = style-args.colors.at(type, default: style-args.colors.at("default", default: default-type-color))
  let dest = (documentation + docs).at(type, default: none)
  let c = box(outset: 2pt, fill: clr, radius: 2pt, raw(type))
  if dest != none {
    link(dest, c)
  } else {
    c
  }
  h(2pt)
}

#let show-parameter-list(fn, style-args: (:)) = {
  pad(x: 10pt, {
    set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
    text(fn.name, fill: style-args.colors.at("signature-func-name", default: rgb("#4b69c6")))
    "("
    let inline-args = fn.args.len() < 2
    if not inline-args { "\n  " }
    let items = ()
    for (arg-name, info) in fn.args {
      let types 
      if "types" in info {
        types = ": " + info.types.map(x => show-type(x, style-args: style-args)).join(" ")
      }
      items.push(arg-name + types)
    }
    items.join( if inline-args {", "} else { ",\n  "})
    if not inline-args { "\n" } + ")"
    if fn.return-types != none {
      " -> " 
      fn.return-types.map(x => show-type(x, style-args: style-args)).join(" ")
    }
  })
}

// Create a parameter description block, containing name, type, description and optionally the default value. 
#let show-parameter-block(
  name, types, content, style-args,
  show-default: false, 
  default: none, 
) = block(
  inset: 10pt, fill: rgb("ddd3"), width: 100%,
  breakable: style-args.break-param-descriptions,
  [
    #box(heading(level: style-args.first-heading-level + 3, name))
    #h(1.2em) 
    #types.map(x => (style-args.style.show-type)(x, style-args: style-args)).join([ #text("or",size:.6em) ])
  
    #content
    #if show-default [ #parbreak() Default: #raw(lang: "typc", default) ]
  ]
)

#let show-function(
  fn, style-args,
) = {

  if style-args.colors == auto { style-args.colors = colors }

  [
    #heading(fn.name, level: style-args.first-heading-level + 1)
    #label(style-args.label-prefix + fn.name + "()")
  ]
  
  utilities.eval-docstring(fn.description, style-args)

  block(breakable: style-args.break-param-descriptions, {
    heading("Parameters", level: style-args.first-heading-level + 2)
    (style-args.style.show-parameter-list)(fn, style-args: style-args)
  })

  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name, types, utilities.eval-docstring(description, style-args), 
      style-args,
      show-default: "default" in info, 
      default: info.at("default", default: none),
    )
  }
  v(4.8em, weak: true)
}

#let show-variable(
  var, style-args,
) = {
  if style-args.colors == auto { style-args.colors = colors }
  let type = if "type" not in var { none } 
      else { show-type(var.type, style-args: style-args) }

  stack(dir: ltr, spacing: 1.2em,
    [
      #heading(var.name, level: style-args.first-heading-level + 1)
      #label(style-args.label-prefix + var.name)
    ],
    type
  )
  
  utilities.eval-docstring(var.description, style-args)
  v(4.8em, weak: true)
}


#let show-reference(label, name, style-args: none) = {
  link(label, raw(name))
}

#let show-example(
  ..args
) = {
  
  show-ex.show-example(
    ..args,
    code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
    preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
    col-spacing: 5pt
  )
}
