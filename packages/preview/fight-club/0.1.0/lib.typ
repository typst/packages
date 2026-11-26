#let _directions = (
  f: 0deg,
  b: 180deg,
  u: -90deg,
  d: 90deg,
  uf: -45deg,
  ub: -135deg,
  df: 45deg,
  db: 135deg,
  "u/f": -45deg,
  "u/b": -135deg,
  "d/f": 45deg,
  "d/b": 135deg,
)

#let _held-directions = (
  "F": 0deg,
  "B": 180deg,
  "U": -90deg,
  "D": 90deg,
  "UF": -45deg,
  "UB": -135deg,
  "DF": 45deg,
  "DB": 135deg,
  "U/F": -45deg,
  "U/B": -135deg,
  "D/F": 45deg,
  "D/B": 135deg,
)

#let _buttons = ("1", "2", "3", "4")
#let _symbol-baseline = (at: horizon, shift: -0.25em)
#let _symbol-gap = 0.1em
#let _step-separator = box(
  width: 0.3em,
  height: 0.36em,
  baseline: _symbol-baseline,
  polygon(fill: black, (0em, 0em), (0.3em, 0.18em), (0em, 0.36em)),
)
#let _plus = box(
  baseline: _symbol-baseline,
  polygon(
    fill: black,
    (0.1em, 0em), (0.18em, 0em),
    (0.18em, 0.1em), (0.28em, 0.1em),
    (0.28em, 0.18em), (0.18em, 0.18em),
    (0.18em, 0.28em), (0.1em, 0.28em),
    (0.1em, 0.18em), (0em, 0.18em),
    (0em, 0.1em), (0.1em, 0.1em),
  ),
)

#let _button-diagram(pressed, numbers: false) = {
  let scale = if numbers { 1 } else { 0.8 }
  let diameter = scale * 0.4em
  let radius = diameter / 2
  let gap = scale * 0.02em
  let pitch = diameter + gap

  let key(label) = {
    let active = label in pressed
    let face = circle(
      radius: radius,
      fill: if active { black } else { none },
      stroke: 0.6pt + black,
      inset: 0pt,
    )

    if numbers {
      stack(
        dir: ttb,
        spacing: -diameter,
        face,
        grid(
          columns: (diameter,),
          rows: (diameter,),
          align: center + horizon,
          text(font: "DejaVu Sans Mono", size: 0.3em, fill: if active { white } else { black })[#label],
        ),
      )
    } else {
      face
    }
  }

  let at(label, x, y, base-x, base-y) = move(
    dx: scale * x * 1em - base-x,
    dy: scale * y * 1em - base-y,
    key(label),
  )

  box(
    width: scale * 0.88em,
    height: scale * 1em,
    baseline: _symbol-baseline,
    move(
      dx: -scale * 0.06em,
      grid(
        columns: (diameter, diameter),
        rows: (diameter, diameter),
        column-gutter: gap,
        row-gutter: gap,
        at("1", 0.26, 0.42, radius, radius),
        at("2", 0.60, 0.22, radius + pitch, radius),
        at("4", 0.74, 0.58, radius, radius + pitch),
        at("3", 0.40, 0.78, radius + pitch, radius + pitch),
      ),
    ),
  )
}

#let _arrow(direction, hollow: false) = {
  box(
    baseline: _symbol-baseline,
    rotate(
      direction,
      reflow: true,
      polygon(
        fill: if hollow { none } else { black },
        stroke: 1pt + black,
        (0em, 0.17em),
        (0.4em, 0.17em),
        (0.4em, 0em),
        (0.72em, 0.29em),
        (0.4em, 0.58em),
        (0.4em, 0.41em),
        (0em, 0.41em),
      ),
    ),
  )
}

#let _render-part(part, numbers) = {
  let direction = _directions.at(part, default: none)
  let held-direction = _held-directions.at(part, default: none)
  if held-direction != none {
    _arrow(held-direction, hollow: true)
  } else if direction != none {
    _arrow(direction)
  } else if part in ("n", "*") {
    box(
      width: 0.66em,
      height: 0.72em,
      baseline: _symbol-baseline,
      polygon(
        fill: black,
        (0.33em, 0.008em), (0.407em, 0.25em), (0.66em, 0.25em),
        (0.451em, 0.404em), (0.539em, 0.657em), (0.33em, 0.503em),
        (0.121em, 0.657em), (0.209em, 0.404em), (0em, 0.25em),
        (0.253em, 0.25em),
      ),
    )
  } else if part in _buttons {
    _button-diagram((part,), numbers: numbers)
  } else {
    [#part]
  }
}

// Draw a sequence step in one SVG with tightly computed horizontal bounds.
#let _svg-step(parts, numbers, prefix: false, plus: true) = {
  let items = ()
  let add(path, width) = (path: path, width: width)
  if prefix { items.push(add("<path d='M0 -1.8 L3 0 L0 1.8 Z'/>", 3)) }
  let opening = parts.first().starts-with("[")
  let closing = parts.last().ends-with("]")
  if opening { items.push(add("<path d='M0.4 -4 H3.4 Q0.4 0 3.4 4 H0.4 Z' fill='none' stroke='black' stroke-width='0.8' stroke-linejoin='round'/>", 3.8)) }
  parts = parts.map(part => part.trim("[").trim("]"))
  let grouped = ()
  for part in parts {
    if part in _buttons and grouped.len() > 0 and grouped.last().split("+").all(p => p in _buttons) {
      let previous = grouped.pop()
      grouped.push(previous + "+" + part)
    } else {
      grouped.push(part)
    }
  }
  parts = grouped
  for (index, part) in parts.enumerate() {
    if plus and index > 0 and part not in (":", "~") and parts.at(index - 1) not in (":", "~") { items.push(add("<path transform='translate(0,-1.4)' d='M1 0 H1.8 V1 H2.8 V1.8 H1.8 V2.8 H1 V1.8 H0 V1 H1 Z'/>", 2.8)) }
    let angle = _directions.at(part, default: _held-directions.at(part, default: none))
    if part.starts-with("\"") and part.ends-with("\"") and part.len() >= 2 {
      let label = part.slice(1, part.len() - 1)
      let safe = label.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")
      let width = calc.max(6, label.len() * 3.2 + 4)
      items.push(add("<rect x='0' y='-4' width='"+str(width)+"' height='8' rx='2' fill='black'/><text x='"+str(width / 2)+"' y='0' text-anchor='middle' dominant-baseline='central' font-family='DejaVu Sans Mono' font-size='5' fill='white' xml:space='preserve'>"+safe+"</text>", width))
    } else if part == ":" {
      items.push(add("<path d='M0.4 -2.8 H2.2 V-1 H0.4 Z M0.4 1 H2.2 V2.8 H0.4 Z' fill='none' stroke='black' stroke-width='0.6'/>", 2.6))
    } else if part == "~" {
      items.push(add("<path d='M0.35 0 C0.733333 -0.6 1.116667 -0.6 1.5 0 S2.266667 0.6 2.65 0' fill='none' stroke='black' stroke-width='0.7' stroke-linecap='round'/>", 3))
    } else if angle != none {
      let points = ((0,1.7),(4,1.7),(4,0),(7.2,2.9),(4,5.8),(4,4.1),(0,4.1))
      let rotated = points.map(p => (p.at(0)*calc.cos(angle)-p.at(1)*calc.sin(angle), p.at(0)*calc.sin(angle)+p.at(1)*calc.cos(angle)))
      let xs = rotated.map(p => p.at(0))
      let ys = rotated.map(p => p.at(1))
      let left = calc.min(..xs)
      let right = calc.max(..xs)
      let top = calc.min(..ys)
      let bottom = calc.max(..ys)
      let coords = rotated.map(p => str(p.at(0)-left+0.5)+","+str(p.at(1)-(top+bottom)/2)).join(" ")
      let fill = if _held-directions.at(part, default: none) != none { "none" } else { "black" }
      items.push(add("<polygon points='"+coords+"' fill='"+fill+"' stroke='black' stroke-width='1' stroke-linejoin='round'/>", right - left + 1))
    } else if part in ("n", "*") {
      items.push(add("<polygon points='3.3,-3.25 4.07,-0.83 6.6,-0.83 4.51,0.71 5.39,3.24 3.3,1.7 1.21,3.24 2.09,0.71 0,-0.83 2.53,-0.83'/>", 6.6))
    } else if part in _buttons or (part.contains("+") and part.split("+").all(x => x in _buttons)) {
      let pressed = part.split("+")
      let scale = if numbers { 1.0 } else { 0.8 }
      let circles = ""
      for (label, x, y) in (("1",2.6,4.2),("2",6.0,2.2),("4",7.4,5.8),("3",4.0,7.8)) {
        let active = label in pressed
        let color = if active { "black" } else { "white" }
        circles += "<circle cx='"+str(x)+"' cy='"+str(y)+"' r='2' fill='"+color+"' stroke='black' stroke-width='0.6'/>"
        if numbers { circles += "<text x='"+str(x)+"' y='"+str(y)+"' text-anchor='middle' dominant-baseline='central' font-family='DejaVu Sans Mono' font-size='3' fill='"+(if active { "white" } else { "black" })+"'>"+label+"</text>" }
      }
      items.push(add("<g transform='scale("+str(scale)+") translate(-0.3,-5)'>"+circles+"</g>", 9.4*scale))
    } else {
      let safe = part.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")
      items.push(add("<text x='0' y='0' dominant-baseline='central' font-size='10'>"+safe+"</text>", calc.max(3, part.len()*6)))
    }
  }
  if closing { items.push(add("<path d='M0.4 -4 H3.4 V4 H0.4 Q3.4 0 0.4 -4 Z' fill='none' stroke='black' stroke-width='0.8' stroke-linejoin='round'/>", 3.8)) }
  let x = 0.0
  let shapes = ""
  for item in items {
    if x > 0 { x += if prefix and x == 3 { if opening { 4 } else { 2 } } else { 1 } }
    shapes += "<g transform='translate("+str(x)+",0)'>"+item.path+"</g>"
    x += item.width
  }
  let svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 -5 "+str(x)+" 10' width='"+str(x)+"' height='10'>"+shapes+"</svg>"
  box(baseline: _symbol-baseline, image(bytes(svg.replace("−", "-")), format: "svg", height: 1em, alt: parts.join("+")))
}

#let tekken(input, numbers: false, display: false, plus: true, separator: true) = {
  let segments = input.split("\"")
  let source = ""
  for (index, segment) in segments.enumerate() {
    if index > 0 { source += "\"" }
    if calc.rem(index, 2) == 0 {
      let plain = segment.replace(",", " ").replace(regex("\\s*\\+\\s*"), "+")
      for mark in (":", "~") {
        plain = plain.replace(regex("\\s*" + mark + "\\s*"), "+" + mark + "+")
      }
      source += plain.replace(regex("\\[\\s+"), "[").replace(regex("\\s+\\]"), "]")
    } else {
      source += segment
    }
  }
  let tokens = source.matches(regex("(?:\"[^\"]*\"|[^\\s,\"])+")).map(m => m.text)
  let notation = {
    for (index, token) in tokens.enumerate() {
      if index > 0 {
        let previous = tokens.at(index - 1)
        h(if previous.ends-with("]") or (not separator and token.starts-with("[")) { 0.4em } else { 0.2em }, weak: true)
        sym.zws
      }
      let inner = token.trim("[").trim("]")
      let parts = if inner.starts-with("\"") or inner.split("+").all(x => x in _buttons) { (token,) } else { token.split("+").filter(part => part != "") }
      _svg-step(parts, numbers, prefix: index > 0 and separator, plus: plus)
    }
  }
  if display { block(width: 100%, above: 0.4em, below: 0.4em, align(center, notation)) } else { notation }
}
