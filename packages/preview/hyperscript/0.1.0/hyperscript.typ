#let parse-selector(s) = {
 
  let tag = "div"
  let classes = ()
  let id = ""
  let attrs = (:)
  let r = regex("(?:(^|#|\.)([^#.\[\]]+))|(\[(.+?)(?:\s*=\s*(['\"])(?:\\[\"'\]]|.)*?)?\])")
  for m in s.matches(r) {
    if m.captures.at(0) == "" {
      tag = m.captures.at(1)
    } 
    if m.captures.at(0) == "." {
      classes.push(m.captures.at(1))
    } 
    if m.captures.at(0) == "#" {
      id = m.captures.at(1)
    } 
    if m.captures.at(0) == none {
      let s = m.captures.at(2)   // key=val
      let mm = s.match(regex("\[?(\w*)='?([^']*)'?\]"))
      if mm != none {
        attrs.insert(mm.captures.at(0), mm.captures.at(1))
      }
    } 
  }
  let class = (..classes, attrs.at("class", default: "")).join(" ").trim()
  if class != "" {
    attrs = attrs + (class: class)
  }
  if id != "" {
    attrs = attrs + (id: id)
  }

  return (tag, attrs)
}

#let h(selector, ..args) = {
  let pargs = args.pos()
  let (tag, attrs) = parse-selector(selector)
  if pargs.len() > 0 {
    if type(pargs.at(0)) == dictionary {
      attrs = attrs + pargs.remove(0)
    }
  }
  html.elem(tag, pargs.join(), attrs: attrs)
}

#let hc(selector, ..args) = context {
  if target() == "html" {
    return h(selector, ..args)
  }
  let pargs = args.pos()
  if pargs.len() > 0 {
    if type(pargs.at(0)) == dictionary {
      let dum = pargs.remove(0)
    }
  }
  return pargs.join()
}
