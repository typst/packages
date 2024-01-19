#let tree(tag, ..children, child-spacing: 1em, layer-spacing: 2.3em, roof: false, stroke: 0.75pt) = {
  let tag_text = text(tag)
  style(sty => {
    let child_widths = children.pos().map(c => measure(c, sty).width)
    let child_xs = ()
    let acc = 0pt
    for width in child_widths {
      child_xs.push(acc)
      acc += width + child-spacing
    }

    let children_width = acc - child-spacing

    let child_nodes = children.pos().enumerate().map(t => {
      let (i, child) = t
      let child_width = measure(child, sty).width
      let x0 = child_xs.at(i) + child_width / 2
      let hi = -layer-spacing + 0.3em
      let lo = -0.3em
      if roof {
        place(polygon(stroke: stroke, (0pt + child_width/2, hi), (children_width - x0 + child_width/2, lo), (-x0+ child_width/2, lo)))
      } else {
        place(line(stroke: stroke, start: (0pt+ child_width/2, lo), end: (children_width / 2 - x0+ child_width/2, hi)))
      }
      child
    })

    let child_stack = stack(dir: ltr, spacing: child-spacing, ..child_nodes)
    let layer_stack = stack(dir: ttb, spacing: layer-spacing, tag_text, child_stack)
    block(align(center, layer_stack))
  })
}

#let syntree(code, terminal: (:), nonterminal: (:), child-spacing: 1em, layer-spacing: 2.3em) = {
  let stack = ((),)
  let roof_stack = (false,)
  for token in code.matches(regex(`(\\\[|\\\]|[^\[\]\s])+|\[|\]`.text)) {
    if token.text == "[" {
      stack.push(())
      roof_stack.push(false)
    } else if token.text == "]" {
      let (tag, ..children) = stack.pop()
      let roof = roof_stack.pop()
      if roof {
        children = (text(..terminal, children.join([ ])),)
      }
      stack.last().push(tree(tag, ..children, child-spacing: child-spacing, layer-spacing: layer-spacing, roof: roof))
    } else {
      let sty = if stack.last().len() == 0 { nonterminal } else { terminal }
      let t = token.text
      if t.starts-with("^") {
        t = t.slice(1)
        roof_stack.last() = true
      }
      stack.last().push(text(..sty, eval("[" + t + "]")))
    }
  }
  stack.last().last()
}
