#import "../utilities.typ": *
#import "default.typ"


// Color to highlight function names in
#let fn-color = rgb("#1f2a63")
#let fn-color = blue.darken(30%)

#let default-type-color = rgb("#eff0f3")


#let show-outline(module-doc, style-args: (:)) = {
  let prefix = module-doc.label-prefix
  let items = ()
  for fn in module-doc.functions {
    items.push(fn.name + "()")
    // items.push(link(label(prefix + fn.name + "()"), fn.name + "()"))
  }
  list(..items)
}

#let show-type(type-name, style-args: (:)) = { 
  h(2pt)
  let clr = style-args.colors.at(type-name, default: style-args.colors.at("default", default: default-type-color))
  if type(clr) == color {
    let components = clr.components()
    clr = rgb(..components.slice(0, -1), 60%)
  }
  box(outset: 2pt, fill: clr, radius: 2pt, raw(type-name, lang: none))
  h(2pt)
}


#let show-parameter-list(fn, style-args) = {
  block(fill: rgb("#d8dbed44"), width: 100%, inset: (x: 0.5em, y: 0.7em), {
    set text(font: "DejaVu Sans Mono", size: 0.85em, weight: 340)
    text(fn.name)
    "("
    let inline-args = fn.args.len() < 5
    if not inline-args { "\n  " }
    let items = ()
    for (arg-name, info) in fn.args {
      let types 
      if "types" in info {
        types = ": " + info.types.map(x => show-type(x, style-args: style-args)).join(" ")
      }
      items.push(box(arg-name + types))
    }
    items.join( if inline-args {", "} else { ",\n  "})
    if not inline-args { "\n" } + ")"
    if fn.return-types != none {
      box[~-> #fn.return-types.map(x => show-type(x, style-args: style-args)).join(" ")]
    }
  })
}



// Create a parameter description block, containing name, type, description and optionally the default value. 
#let show-parameter-block(
  name, types, content, style-args,
  show-default: false, 
  default: none, 
) = block(
  inset: 0pt, width: 100%,
  breakable: style-args.break-param-descriptions,
  [ 
    #[
      #raw(name, lang: none) 
    ]
    #if types != () [
      (#h(-.2em)
      #types.map(x => (style-args.style.show-type)(x, style-args: style-args)).join([ #text("or",size:.6em) ])
      #if show-default [\= #raw(lang: "typc", default) ]
      #h(-.2em))
    ]
    --
    #content
    
  ]
)


#let show-function(
  fn, style-args,
) = {
  if style-args.colors == auto { style-args.colors = default.colors }
  set par(justify: false, hanging-indent: 1em, first-line-indent: 0em)

  block(breakable: style-args.break-param-descriptions, fill: rgb("#d8dbed44"), 
  if style-args.enable-cross-references [
    #(style-args.style.show-parameter-list)(fn, style-args)
    #label(style-args.label-prefix + fn.name + "()")
  ] else [
    #(style-args.style.show-parameter-list)(fn, style-args)
  ])
  pad(x: 0em, eval-docstring(fn.description, style-args))

  let parameter-block

  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    parameter-block += (style-args.style.show-parameter-block)(
      name, types, eval-docstring(description, style-args), 
      style-args,
      show-default: "default" in info, 
      default: info.at("default", default: none),
    )
  }
  
  if parameter-block != none {
    [*Parameters:*]
    parameter-block
  }
  v(2em, weak: true)
}


#let show-variable(
  var, style-args,
) = {
  if style-args.colors == auto { style-args.colors = default.colors }
  set par(justify: false, hanging-indent: 1em, first-line-indent: 0em)

  let type = if "type" not in var { none } 
      else { show-type(var.type, style-args: style-args) }
      
  block(breakable: style-args.break-param-descriptions, fill: rgb("#d8dbed44"), width: 100%, inset: (x: 0.5em, y: 0.7em),
    stack(dir: ltr, spacing: 1.2em,
      if style-args.enable-cross-references [
        #set text(font: "DejaVu Sans Mono", size: 0.85em, weight: 340)
        #text(var.name)
        #label(style-args.label-prefix + var.name)
      ] else [
        #set text(font: "DejaVu Sans Mono", size: 0.85em, weight: 340)
        #text(var.name)
      ],
      type
    )
  )
  pad(x: 0em, eval-docstring(var.description, style-args))

  v(2em, weak: true)
}


#let show-reference(label, name, style-args: none) = {
  link(label, raw(name, lang: none))
}

#import "../show-example.typ" as example

#let show-example(
  ..args
) = {
  
  example.show-example(
    ..args,
    layout: example.default-layout-example.with(
      code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
      preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
      col-spacing: 5pt
    ),
  )
}