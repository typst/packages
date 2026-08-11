/// Used for adding attributes to nodes. See the Styling and Attributes section for more details.
#let a(..args) = metadata(("arborly-metadata", args.named()))

#let tree = {
  import "defaults.typ"
  import "@preview/cetz:0.3.4"
  import cetz.util: merge-dictionary

  let trim(list) = {
    while list.len() >= 1 and list.at(0) in (parbreak(), [ ]) {
      list = list.slice(1)
    }
    while list.len() >= 1 and list.at(list.len() - 1) == [ ] {
      list = list.slice(0, list.len() - 1)
    }
    list
  }

  let parse-recursive(list) = {
    // utility functions used only when parsing
    let is-opening(content) = {
      content == [[]].children.at(0)
    }
    let is-closing(content) = {
      content == [[]].children.at(1)
    }
    let is-metadata(content) = {
      (
        content.func() == metadata
          and type(content.value) == array
          and content.value.len() == 2
          and content.value.at(0) == "arborly-metadata"
      )
    }

    list = trim(list)

    let child-opener = list.position(is-opening)

    let (body-slice, children) = if child-opener == none {
      (trim(list), ())
    } else {
      let body-slice = trim(list.slice(0, child-opener))
      let children-slice = trim(list.slice(child-opener))
      let children = ()
      while children-slice.len() > 0 {
        let child-closer = 0
        let level = 1
        while level > 0 {
          child-closer += 1
          if is-opening(children-slice.at(child-closer)) {
            level += 1
          }
          if is-closing(children-slice.at(child-closer)) {
            level -= 1
          }
        }
        children.push(parse-recursive(children-slice.slice(1, child-closer)))

        children-slice = trim(children-slice.slice(child-closer + 1))
      }

      (body-slice, children)
    }

    let style-metadata = body-slice.find(is-metadata)
    let style = if style-metadata != none {
      style-metadata.value.at(1)
    } else {
      (:)
    }

    (body: body-slice.sum(default: none), children: children, style: style)
  }

  let parse(body) = {
    parse-recursive(body.at("children", default: (body,)))
  }

  let propagate-style((body, children, style, ..rest), parent-style) = {
    // update the parent-style for all children with inherited values
    if "inherit" in style.keys() {
      parent-style = merge-dictionary(parent-style, style.inherit)
      style.remove("inherit")
    }
    let new-children = ()
    for child in children {
      new-children.push(propagate-style(child, parent-style))
    }
    children = new-children
    // children = children.map(node => propagate-style(node, parent-style))

    let fallback-style = merge-dictionary(defaults.default-style, parent-style)

    style = merge-dictionary(fallback-style, style)

    let body = {
      set text(bottom-edge: "baseline")
      set text(..style.text)
      align(style.align-content, body)
    }

    (
      body: body,
      children: children,
      // Measurements cannot be taken before this point since styling can affect them
      body-height: measure(body).height,
      body-width: measure(body).width,
      style: style,
      // horizontal offset relative to the root. Gets updated but needs default.
      offset: 0pt,
      ..rest,
    )
  }

  let left-chunk((children, body-width)) = {
    if children.len() == 0 {
      body-width / 2
    } else {
      calc.max(body-width / 2, left-chunk(children.first()))
    }
  }

  let right-chunk((children, body-width)) = {
    if children.len() == 0 {
      body-width / 2
    } else {
      calc.max(body-width / 2, right-chunk(children.last()))
    }
  }

  let calc-child-width(children, horizontal-gap) = {
    let child-width = children.map(node => node.width).sum(default: 0pt)
    if children.len() > 1 {
      child-width += (children.len() - 1) * horizontal-gap
    }
    child-width
  }

  let propagate-width((children, body-width, style, ..rest), horizontal-gap) = {
    let children = children.map(node => propagate-width(node, horizontal-gap))
    let child-width = calc-child-width(children, horizontal-gap)
    let width = if style.align == right and children.len() >= 1 {
      let right-chunk = right-chunk((children, body-width))
      let left-chunk = calc.max(body-width / 2, child-width - right-chunk)
      left-chunk + right-chunk
    } else {
      calc.max(body-width, child-width)
    }
    (
      children: children,
      width: width,
      body-width: body-width,
      style: style,
      ..rest,
    )
  }

  // propagate a change to the offset of all children
  let propagate-offset((children, offset, ..rest), difference) = {
    let new-children = ()
    for child in children {
      new-children.push(propagate-offset(child, difference))
    }
    children = new-children
    (
      children: children,
      offset: offset + difference,
      ..rest,
    )
  }

  let calculate-offset-average((children, width), child-width) = {
    let first-offset = children.first().offset-from-left
    let last-offset = child-width - (children.last().width - children.last().offset-from-left)
    (first-offset + last-offset) / 2
  }

  // Uses the align: right style, but is still an offset from the left edge to the center
  let calculate-offset-right((children, width, body-width)) = {
    width - right-chunk((children, body-width))
  }

  let pair-offset(left, right, horizontal-gap: none) = {
    let left = (left,)
    let right = (right,)

    let max-sep = 0pt
    while left.len() > 0 and right.len() > 0 {
      let sep = (left.last().body-width + right.first().body-width) / 2 + (left.last().offset - right.first().offset)
      if sep.to-absolute() > max-sep.to-absolute() {
        max-sep = sep
      }
      let new-left = ()
      let new-right = ()
      for node in left {
        for child in node.children {
          new-left.push(child)
        }
      }
      for node in right {
        for child in node.children {
          new-right.push(child)
        }
      }
      left = new-left
      right = new-right
    }
    max-sep + horizontal-gap
  }

  let compute-horizontal-offset(
    (children, style, body-width, ..rest),
    horizontal-gap,
  ) = {
    // children = children.map(child => compute-horizontal-offset(child, horizontal-gap))
    let new-children = ()
    for child in children {
      new-children.push(compute-horizontal-offset(child, horizontal-gap))
    }
    children = new-children

    // unused in tight branch
    let width = 0pt
    let offset-from-left = 0pt


    if style.fit == "tight" {
      // START OF IF

      let seps = ()
      for (left, right) in children.windows(2) {
        seps.push(pair-offset(left, right, horizontal-gap: horizontal-gap))
      }
      // NOTE: this is probably the heaviest section of code, being at least 4 layers of looping.
      for n in range(3, children.len() + 1) {
        for (i, window) in children.windows(n).enumerate() {
          let current-sep = seps.slice(i, i + n - 1).sum()
          let calculated-sep = pair-offset(window.first(), window.last())
          if current-sep.to-absolute() < calculated-sep {
            let amortized-difference = (calculated-sep - current-sep) / (n - 1)
            for j in range(i, i + n - 1) {
              seps.at(j) += amortized-difference
            }
          }
        }
      }

      let sep-sum = seps.sum(default: 0pt)

      let difference = if style.align == left {
        0pt
      } else if style.align == right {
        -sep-sum
      } else {
        -sep-sum / 2
      }

      let new-children = ()
      for i in range(children.len()) {
        new-children.push(propagate-offset(children.at(i), difference))
        if i < seps.len() {
          difference += seps.at(i)
        }
      }
      children = new-children
    } else {
      // END OF IF, START OF ELSE

      let child-width = calc-child-width(children, horizontal-gap)
      width = if style.align == right and children.len() >= 1 {
        let right-chunk = right-chunk((children, body-width))
        let left-chunk = calc.max(body-width / 2, child-width - right-chunk)
        left-chunk + right-chunk
      } else {
        calc.max(body-width.to-absolute(), child-width.to-absolute())
      }

      if children.len() == 0 {
        return (
          children: children,
          width: width,
          body-width: body-width,
          offset-from-left: body-width / 2,
          style: style,
          ..rest,
        )
      }

      offset-from-left = if style.align == center {
        calculate-offset-average((children: children, width: width), child-width)
      } else if style.align == left {
        left-chunk((children: children, body-width: body-width))
      } else if style.align == right {
        calculate-offset-right((children: children, width: width, body-width: body-width))
      } else {
        panic("alignment not implemented: " + style.align)
      }

      let difference = if style.align == center {
        -offset-from-left
      } else if style.align == left {
        -calc.min(offset-from-left, left-chunk(children.first()))
      } else if style.align == right {
        -calc.min(offset-from-left, child-width - right-chunk(children.last()))
      } else {
        panic("alignment not implemented: " + style.align)
      }

      let new-children = ()
      for child in children {
        new-children.push(propagate-offset(child, difference + child.offset-from-left))
        difference += child.width + horizontal-gap
      }
      children = new-children
    } // END OF ELSE

    (
      children: children,
      body-width: body-width,
      width: width,
      style: style,
      offset-from-left: offset-from-left,
      ..rest,
    )
  }

  // This uses a non-recursive approach to get around the depth limit
  // for very deep trees, but as a consequence is harder to read.
  let draw(
    node,
    y: 0,
    name: "0",
    vertical-snapping-threshold: none,
    vertical-gap: none,
  ) = {
    let call-stack = ((node: node, y: y, name: name),)
    // Line elements are collected here and shown at the end, because they rely on element names that do not exist until later iterations of the call loop.
    let lines = ()

    while call-stack.len() > 0 {
      let (node: node, y: y, name: name) = call-stack.pop()
      let (
        body,
        children,
        offset,
        style,
        offset-from-left,
        body-height,
      ) = node

      // START OF ACTUAL IMPLEMENTATION
      let name = if style.name != none { style.name } else { name }
      cetz.draw.content(
        (offset.to-absolute().cm(), y),
        body,
        padding: style.padding,
        name: name,
      )

      for i in range(children.len()) {
        let child = children.at(i)

        // Calculate the offset
        let DEFAULT_HEIGHT = measure([dj]).height
        let average-height = (body-height + child.body-height) / 2
        let snapped-height = if calc.abs(DEFAULT_HEIGHT - average-height) <= vertical-snapping-threshold.to-absolute() {
          DEFAULT_HEIGHT
        } else {
          average-height
        }

        let line-style = merge-dictionary(style.child-lines, child.style.parent-line)

        let child-y = y - snapped-height.cm() - vertical-gap.to-absolute().cm()
        // let child-y = y - snapped-height.cm()
        let child-name = if child.style.name != none { child.style.name } else { name + "-" + str(i) }

        call-stack.push((
          node: child,
          y: child-y,
          name: child-name,
        ))
        if child.style.triangle {
          lines.push(
            cetz.draw.line(
              (name: name, anchor: "south"),
              (name: child-name, anchor: "north-west"),
              (name: child-name, anchor: "north-east"),
              close: true,
              ..line-style,
            ),
          )
        } else {
          lines.push(
            cetz.draw.line(
              if style.child-anchor != none {
                (name: name, anchor: style.child-anchor)
              } else {
                name
              },
              if child.style.parent-anchor != none {
                (name: child-name, anchor: child.style.parent-anchor)
              } else {
                child-name
              },
              ..line-style,
            ),
          )
        }
      }
      // END OF ACTUAL IMPLEMENTATION
    }

    lines.join()
  }

  /// Generate a syntax tree
  ///
  /// -> content
  let tree(
    /// A root style dictionary that is inherited by all nodes. Any more specific configuration within the tree takes precedence.
    ///
    /// -> dictionary
    style: (:),
    /// If the height of a node's content differs from regular text by less than this amount, it will be vertically spaced as though it had the same height.
    ///
    /// This is not useful if most nodes are significantly larger than simple text (eg. being surrounded by `rect`).
    ///
    /// -> length
    vertical-snapping-threshold: 0.5em,
    /// The vertical gap between nodes
    ///
    /// -> length
    vertical-gap: 2em,
    /// The horizontal gap between nodes
    ///
    /// -> length
    horizontal-gap: 1.75em,
    /// A code block to be inserted into the cetz canvas after the syntax tree. It can be used for drawing arrows between nodes. Remember to name nodes using ```typ #a``` in order to reference them. See Styling and Arguments for more.
    ///
    code: none,
    /// The tree's structure denoted using bracket-enclosed values, as described in Building a Syntax Tree
    ///
    /// -> content
    body,
  ) = context {
    let node = parse(body)
    let node = propagate-style(node, style)
    let node = compute-horizontal-offset(node, horizontal-gap)

    cetz.canvas({
      draw(
        node,
        vertical-snapping-threshold: vertical-snapping-threshold,
        vertical-gap: vertical-gap,
      )
      code
    })
  }

  tree
}
