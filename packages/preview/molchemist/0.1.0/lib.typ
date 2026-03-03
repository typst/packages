#import "@preview/alchemist:0.1.8": *

#let mol-plugin = plugin("molchemist_plugin.wasm")

#let get-b-func(b-type) = {
  if b-type == "double" { double }
  else if b-type == "triple" { triple }
  else if b-type == "cram-filled-right" { cram-filled-right }
  else if b-type == "cram-filled-left" { cram-filled-left }
  else if b-type == "cram-dashed-right" { cram-dashed-right }
  else if b-type == "cram-dashed-left" { cram-dashed-left }
  else { single }
}

#let _render-ast(cmds, base-sep, config: (:)) = {
  for cmd in cmds {
    if cmd.type == "fragment" {
      
      if cmd.element != "" {
        branch({
          single(absolute: 0deg, atom-sep: 0.1pt, stroke: none, name: cmd.name + "_pos")
        })
      }

      hook(cmd.name)

      if cmd.links.len() > 0 {
        let l-dict = (:)
        for l in cmd.links {
          let b-func = get-b-func(l.bondType)
          let l-args = (
            absolute: l.angle * 1deg,
            atom-sep: base-sep * l.lengthScale
          )
          if "offset" in l and l.offset != none {
            l-args.insert("offset", l.offset)
          }
          l-dict.insert(l.target, b-func(..l-args))
        }
        branch({ single(absolute: 0deg, atom-sep: 0pt, stroke: none, links: l-dict) })
      }

      if cmd.element != "" {
        import cetz.draw
        
        let label-parts = cmd.element.split("_")
        let label-content = if label-parts.len() == 1 {
          [#label-parts.at(0)]
        } else {
          [#label-parts.at(0)#sub(label-parts.at(1))]
        }

        let text-args = (:)
        if "fragment-color" in config and config.at("fragment-color") != none {
          text-args.insert("fill", config.at("fragment-color"))
        }
        if "fragment-font" in config and config.at("fragment-font") != none {
          text-args.insert("font", config.at("fragment-font"))
        }
        
        let styled-label = text(..text-args, label-content)

        draw.content(
          cmd.name + "_pos.start",
          box(fill: rgb("FFFFFF"), inset: 1.5pt, styled-label) 
        )
      }

    } else if cmd.type == "bond" {
      let b-func = get-b-func(cmd.bondType)
      let args = (
        absolute: cmd.angle * 1deg,
        atom-sep: base-sep * cmd.lengthScale
      )
      if "offset" in cmd and cmd.offset != none {
        args.insert("offset", cmd.offset)
      }
      b-func(..args)
    } else if cmd.type == "branch" {
      branch(_render-ast(cmd.body, base-sep, config: config))
    }
  }
}

#let render-mol(data, abbreviate: false, skeletal: false, config: (:)) = {
  let mode = "full"
  if skeletal {
    mode = "skeletal"
  } else if abbreviate {
    mode = "abbreviate"
  }

  let base-sep = config.at("atom-sep", default: 3em)
  
  let cbor-bytes = mol-plugin.sdf_to_ast(bytes(data), bytes(mode))
  let ast = cbor(cbor-bytes)
  
  skeletize(config: config, _render-ast(ast, base-sep, config: config))
}