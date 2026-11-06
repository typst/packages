#import "../utilities.typ": *


// Color to highlight function names in
#let fn-color = rgb("#1f2a63")

#let get-type-color(type) = rgb("#eff0f3")


#let show-outline(module-doc, style-args: (:)) = {
  let prefix = module-doc.label-prefix
  let gen-entry(name) = {
    if style-args.enable-cross-references {
      link(label(prefix + name), name)
    } else {
      name
    }
  }
  if module-doc.functions.len() > 0 {
    list(..module-doc.functions.map(fn => gen-entry(fn.name + "()")))
  }
    
  if module-doc.variables.len() > 0 {
    text([Variables:], weight: "bold")
    list(..module-doc.variables.map(var => gen-entry(var.name)))
  }
}

// Create beautiful, colored type box
#let show-type(type, style-args: (:)) = { 
  h(2pt)
  box(outset: 2pt, fill: get-type-color(type), radius: 2pt, raw(type, lang: none))
  h(2pt)
}



#let show-parameter-list(fn, style-args) = {
  block(fill: rgb("#d8dbed"), width: 100%, inset: (x: 0.5em, y: 0.7em), {
    set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
    text(fn.name, fill: fn-color)
    "("
    let inline-args = fn.args.len() < 5
    if not inline-args { "\n  " }
    let items = ()
    for (arg-name, info) in fn.args {
      if style-args.omit-private-parameters and arg-name.starts-with("_") { 
        continue
      }
      let types 
      if "types" in info {
        types = ": " + info.types.map(x => show-type(x)).join(" ")
      }
      items.push(box(arg-name + types))
    }
    items.join( if inline-args {", "} else { ",\n  "})
    if not inline-args { "\n" } + ")"
    if fn.return-types != none {
      box[~-> #fn.return-types.map(x => show-type(x)).join(" ")]
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
      #set text(fill: fn-color)
      #raw(name, lang: none) 
    ]
    (#h(-.2em)
    #types.map(x => (style-args.style.show-type)(x)).join([ #text("or",size:.6em) ])
    #if show-default [\= #raw(lang: "typc", default) ]
    #h(-.2em)) --
    #content
    
  ]
)


#let show-function(
  fn, style-args,
) = {
  set par(justify: false, hanging-indent: 1em, first-line-indent: 0em)

  block(breakable: style-args.break-param-descriptions, 
    if style-args.enable-cross-references [
      #(style-args.style.show-parameter-list)(fn, style-args)
      #label(style-args.label-prefix + fn.name + "()")
    ] else [
      #(style-args.style.show-parameter-list)(fn, style-args)
    ]
  )
  pad(x: 0em, eval-docstring(fn.description, style-args))

  let parameter-block

  for (name, info) in fn.args {
    if style-args.omit-private-parameters and name.starts-with("_") { 
      continue
    }
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
    [*#style-args.local-names.parameters:*]
    parameter-block
  }
  v(4em, weak: true)
}


#let show-variable(
  var, style-args,
) = {
  set par(justify: false, hanging-indent: 1em, first-line-indent: 0em)

  let type = if "type" not in var { none } 
      else { show-type(var.type, style-args: style-args) }
      
  block(breakable: style-args.break-param-descriptions, fill: rgb("#d8dbed"), width: 100%, inset: (x: 0.5em, y: 0.7em),
    stack(dir: ltr, spacing: 1.2em,
      if style-args.enable-cross-references [
        #set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
        #text(var.name, fill: fn-color)
        #label(style-args.label-prefix + var.name)
      ] else [
        #set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
        #text(var.name, fill: fn-color)
      ],
      type
    )
  )
  pad(x: 0em, eval-docstring(var.description, style-args))

  v(4em, weak: true)
}


#let show-reference(label, name, style-args: none) = {
  link(label, raw(name, lang: none))
}

#import "../show-example.typ": show-example as show-ex

#let show-example(
  ..args
) = {
  show-ex(
    ..args,
    code-block: block.with(stroke: .5pt +  fn-color),
    preview-block: block.with(stroke: .5pt +  fn-color),
    col-spacing: 0pt
  )
}