#import "../utilities.typ": *

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
  "none": rgb("#ffcbc4"),
  "auto": rgb("#ffcbc4"),
  "boolean": rgb("#ffedc1"),
  "integer": rgb("#e7d9ff"),
  "float": rgb("#e7d9ff"),
  "ratio": rgb("#e7d9ff"),
  "length": rgb("#e7d9ff"),
  "angle": rgb("#e7d9ff"),
  "relative-length": rgb("#e7d9ff"),
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
#let show-type(type, style-args: (:)) = { 
  h(2pt)
  let clr = style-args.colors.at(type, default: style-args.colors.at("default", default: default-type-color))
  box(outset: 2pt, fill: clr, radius: 2pt, raw(type))
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
  
  eval-docstring(fn.description, style-args)

  block(breakable: style-args.break-param-descriptions, {
    heading("Parameters", level: style-args.first-heading-level + 2)
    (style-args.style.show-parameter-list)(fn, style-args: style-args)
  })

  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name, types, eval-docstring(description, style-args), 
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
  
  eval-docstring(var.description, style-args)
  v(4.8em, weak: true)
}


#let show-reference(label, name, style-args: none) = {
  link(label, raw(name))
}


#import "../show-example.typ": show-example as show-ex

#let show-example(
  ..args
) = {
  
  show-ex(
    ..args,
    code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
    preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
    col-spacing: 5pt
  )
}