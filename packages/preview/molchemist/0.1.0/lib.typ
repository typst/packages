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

#let _ast-to-alchemist-code(cmds, indent: 1) = {
  let ind = "  " * indent
  let res = ""
  for cmd in cmds {
    if cmd.type == "fragment" {
      let f-args-str = ""
      
      if cmd.name != "" {
        f-args-str += "name: \"" + cmd.name + "\""
      }

      let links-str = ""
      if cmd.links.len() > 0 {
        links-str += "links: (\n"
        for l in cmd.links {
           let offset-str = if "offset" in l and l.offset != none { ", offset: \"" + l.offset + "\"" } else { "" }
           links-str += ind + "  \"" + l.target + "\": " + l.bondType + "(absolute: " + str(l.angle) + "deg, atom-sep: base-sep * " + str(l.lengthScale) + offset-str + "),\n"
        }
        links-str += ind + ")"
      }

      if cmd.element != "" {
        if links-str != "" {
          if f-args-str != "" { f-args-str += ", " }
          f-args-str += links-str
        }
        let elem-str = "\"" + cmd.element + "\""
        if f-args-str != "" {
          res += ind + "fragment(" + elem-str + ", " + f-args-str + ")\n"
        } else {
          res += ind + "fragment(" + elem-str + ")\n"
        }
      } else {
        if cmd.name != "" {
          res += ind + "hook(\"" + cmd.name + "\")\n"
        }
        if links-str != "" {
          res += ind + "branch({\n"
          res += ind + "  single(absolute: 0deg, atom-sep: 0pt, stroke: none, " + links-str + ")\n"
          res += ind + "})\n"
        }
      }
      
    } else if cmd.type == "bond" {
      let offset-str = if "offset" in cmd and cmd.offset != none { ", offset: \"" + cmd.offset + "\"" } else { "" }
      res += ind + cmd.bondType + "(absolute: " + str(cmd.angle) + "deg, atom-sep: base-sep * " + str(cmd.lengthScale) + offset-str + ")\n"
    } else if cmd.type == "branch" {
      res += ind + "branch({\n"
      res += _ast-to-alchemist-code(cmd.body, indent: indent + 1)
      res += ind + "})\n"
    }
  }
  return res
}

#let _render-ast(cmds, base-sep, config: (:)) = {
  for cmd in cmds {
    if cmd.type == "fragment" {
      let f-args = (:)

      if cmd.name != "" {
        f-args.insert("name", cmd.name)
      }

      let l-dict = (:)
      if cmd.links.len() > 0 {
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
      }

      if cmd.element != "" {
        if l-dict.len() > 0 {
          f-args.insert("links", l-dict)
        }
        fragment(cmd.element, ..f-args)
      } else {
        if cmd.name != "" {
          hook(cmd.name)
        }
        if l-dict.len() > 0 {
          branch({
            single(absolute: 0deg, atom-sep: 0pt, stroke: none, links: l-dict)
          })
        }
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

#let render-mol(data, abbreviate: false, skeletal: false, dump: false, config: (:)) = {
  let mode = "full"
  if skeletal {
    mode = "skeletal"
  } else if abbreviate {
    mode = "abbreviate"
  }

  let base-sep = config.at("atom-sep", default: 3em)
  
  let cbor-bytes = mol-plugin.sdf_to_ast(bytes(data), bytes(mode))
  let ast = cbor(cbor-bytes)
  
  if dump {
    let code = "#let base-sep = " + repr(base-sep) + "\n#skeletize({\n" + _ast-to-alchemist-code(ast, indent: 1) + "})"
    return raw(code, block: true, lang: "typst")
  } else {
    skeletize(config: config, _render-ast(ast, base-sep, config: config))
  }
}