#let _is-emoji(str) = (
  if str.contains(regex("[\\p{Emoji}]+")) {
    true
  } else {
    false
  }
)

#let _parse-length(s) = {
  let s = s.trim()
  let value = float(s.replace(regex("[a-z%]+"), ""))
  if s.ends-with("em") { value * 1em }
  else if s.ends-with("pt") { value * 1pt }
  else if s.ends-with("mm") { value * 1mm }
  else if s.ends-with("cm") { value * 1cm }
  else if s.ends-with("%") { value * 1% }
  else { value * 1pt }
}

#let _clean-str(s) = s.trim("\"").trim("'")

#let _parse-line(text) = {
  let parts = text.split("|")
  if parts.len() < 2 {
    return (icon: none, params: (:), content: text.trim())
  }
  
  let meta-part = parts.first().trim()
  let content-str = parts.slice(1).join("|").trim()

  if meta-part == "" {
    return (icon: none, params: (:), content: content-str)
  }

  let meta-items = meta-part.split(",")
  let first-item = meta-items.first().trim()
  
  let icon-code = none
  let params-start = 0

  if first-item.contains("=") {
    icon-code = none
    params-start = 0
  } else {
    icon-code = first-item
    params-start = 1
  }

  let params = (:)
  for item in meta-items.slice(params-start) {
    let kv = item.split("=")
    if kv.len() == 2 {
       let k = kv.at(0).trim()
       let v = kv.at(1).trim()
       if k == "size" { params.size = _parse-length(v) }
       else if k == "dy" { params.dy = _parse-length(v) }
       else if k == "dx" { params.dx = _parse-length(v) }
       else if k == "fill" or k == "color" { params.fill = eval(v) }
       else if k == "font" { params.font = _clean-str(v) }
    }
  }
  return (icon: icon-code, params: params, content: content-str)
}

#let dtree(
  body,
  indent-width: 1.5em,
  row-height: 1.5em,
  spacing: 0.5em,
  indent-marker: " ",
  stroke: none,
  font: none,
  size: 10pt,
  fill: black,
  icons: (:),
  icon-rules: (:),
  default-icon: none,
  icon-size: 1em,
  icon-dx: -1pt,
  icon-dy: 0pt,
) = {
  let default-stroke = 0.7pt + black
  let final-stroke = if stroke == none { default-stroke }
                     else if type(stroke) == length { stroke + default-stroke.paint }
                     else if type(stroke) == color { default-stroke.thickness + stroke }
                     else { stroke }

  let raw-text = if type(body) == content and body.has("text") { body.text } else { body }
  let lines = raw-text.split("\n").filter(l => l.trim().len() > 0)
  
  let nodes = ()
  for (i, line) in lines.enumerate() {
    let trimmed = line.trim(at: start)
    let raw-indent = line.len() - trimmed.len()
    let parsed = _parse-line(trimmed)
    nodes.push((
      id: i,
      raw-indent: raw-indent,
      content: parsed.content,
      icon-code: parsed.icon,
      inline-params: parsed.params,
      level: 0 
    ))
  }

  let marker-len = indent-marker.len()
  if marker-len == 0 { marker-len = 1 }
  nodes = nodes.map(n => {
    n.level = int(n.raw-indent / marker-len)
    n
  })

  let has-next-sibling-at-level(current-idx, lvl) = {
    let remaining = nodes.slice(current-idx + 1)
    for node in remaining {
      if node.level < lvl { return false }
      if node.level == lvl { return true }
    }
    return false
  }

  let v-line = place(line(start: (50%, 0%), end: (50%, 100%), stroke: final-stroke))
  let h-line = place(line(start: (50%, 50%), end: (100%, 50%), stroke: final-stroke))
  let half-v = place(line(start: (50%, 0%), end: (50%, 50%), stroke: final-stroke))

  let draw-conn(type) = {
    box(width: indent-width, height: row-height, {
      if type == "pass" { v-line }
      else if type == "fork" { v-line; h-line }
      else if type == "end"  { half-v; h-line }
    })
  }

  let text-args = (size: size, fill: fill, weight: "regular")
  if font != none { text-args.insert("font", font) }
  set text(..text-args)

  stack(dir: ttb, ..nodes.enumerate().map(((i, node)) => {
    let parts = ()
    if node.level > 0 {
      for l in range(1, node.level + 1) {
         if l == node.level {
            parts.push(draw-conn(if has-next-sibling-at-level(i, l) { "fork" } else { "end" }))
         } else {
            parts.push(if has-next-sibling-at-level(i, l) { draw-conn("pass") } 
                       else { box(width: indent-width, height: row-height, "") })
         }
      }
    }

    let rule-icon = none
    let rule-params = (:)
    
    if node.icon-code == none and icon-rules.len() > 0 {
      for (pattern, val) in icon-rules {
        let matched = false
        if type(pattern) == str {
          if pattern.starts-with("*") { matched = node.content.ends-with(pattern.slice(1)) }
          else { matched = node.content == pattern or node.content.ends-with(pattern) }
        } else if type(pattern) == regex {
          matched = (node.content.match(pattern) != none)
        }
        
        if matched {
          if type(val) == dictionary {
            rule-icon = val.at("icon", default: none)
            if "color" in val { val.insert("fill", val.color) }
            rule-params = val
          } else {
            rule-icon = val
          }
          break
        }
      }
    }

    let get-param(key, default-val) = {
      if key in node.inline-params { node.inline-params.at(key) }
      else if key in rule-params { rule-params.at(key) }
      else { default-val }
    }

    let p-size = get-param("size", icon-size)
    let p-dx   = get-param("dx", icon-dx)
    let p-dy   = get-param("dy", icon-dy)
    let p-fill = get-param("fill", fill)
    let p-font = get-param("font", font)

    let target-icon = if node.icon-code != none { node.icon-code } else { rule-icon }
    let icon-display = none

    if target-icon != none {
      let content-cand = none
      
      if target-icon in icons {
        let raw-val = icons.at(target-icon)
        if type(raw-val) == bytes {
          content-cand = image(raw-val, fit: "contain", height: p-size)
        } else if type(raw-val) == content {
          content-cand = box(height: p-size, raw-val)
        } else {
          let str-val = str(raw-val)
          if _is-emoji(str-val) {
            content-cand = move(dy: -0.15em, text(size: p-size, fill: p-fill, top-edge: "bounds", bottom-edge: "bounds", str-val))
          } else {
            content-cand = text(size: p-size, fill: p-fill, top-edge: "bounds", bottom-edge: "bounds", str-val)
          }
        }
      } 
      else {
        if type(target-icon) == bytes {
           content-cand = image(target-icon, fit: "contain", height: p-size)
        } else if type(target-icon) == content {
           content-cand = box(height: p-size, target-icon)
        } else if type(target-icon) == str {
          if target-icon.ends-with(".png") or target-icon.ends-with(".jpg") or target-icon.ends-with(".svg") {
             content-cand = image(target-icon, fit: "contain", height: p-size)
          } else {
             if _is-emoji(target-icon) {
               content-cand = move(dy: -0.15em, text(size: p-size, fill: p-fill, top-edge: "bounds", bottom-edge: "bounds", target-icon))
             } else {
               content-cand = text(size: p-size, fill: p-fill, top-edge: "bounds", bottom-edge: "bounds", target-icon)
             }
          }
        }
      }
      if content-cand != none {
        icon-display = move(dx: p-dx, dy: p-dy, content-cand)
      }
    } else if default-icon != none {
      icon-display = move(dx: icon-dx, dy: icon-dy, default-icon)
    }

    box(height: row-height, stack(dir: ltr, spacing: 0pt,
      ..parts,
      h(spacing),
      if icon-display != none {
        box(
          width: p-size * 1.2, 
          height: row-height, 
          align(center + horizon, icon-display)
        )
      },
      box(
        height: row-height,
        align(horizon, {
          if p-font == none {
            text(fill: p-fill, raw(node.content))
          } else {
            text(fill: p-fill, font: p-font, node.content)
          }
        })
      )
    ))
  }))
}
