#import "@preview/cetz:0.3.4" as cetz: draw

#import cetz.util: measure, resolve-number

#import "elements.typ": TYPES, empty

#let if-auto(value, default, f: v => v) = if value == auto {
  f(default)
} else {
  f(value)
}

#let rebalance-heights(elements, height-growth, y: auto) = {
  // Count elements that can have a dynamic height
  let dynamic = 0
  for e in elements {
    if e.type in (TYPES.PROCESS, TYPES.CALL, TYPES.EMPTY) {
      dynamic += 1
    }
  }

  // Adjust height and position of elements
  if y == auto {
    y = elements.first().pos.at(1)
  }

  if dynamic > 0 {
    let growth = height-growth / dynamic
    for (i, e) in elements.enumerate() {
      e.pos.at(1) = y

      if e.type in (TYPES.PROCESS, TYPES.CALL, TYPES.EMPTY) {
        e.height += growth
        //e.grow += growth

        elements.at(i) = e
      }

      y -= e.height + e.grow
    }
  } else {
    let growth = height-growth / elements.len()
    for (i, e) in elements.enumerate() {
      e.grow += growth
      e.pos.at(1) = y

      if e.type in (TYPES.LOOP, TYPES.FUNCTION) {
        e.elements = rebalance-heights(e.elements, growth, y: e.pos.at(1) - e.height)
      } else if e.type == TYPES.BRANCH {
        e.left = rebalance-heights(e.left, growth, y: e.pos.at(1) - e.height)
        e.right = rebalance-heights(e.right, growth, y: e.pos.at(1) - e.height)
      }

      elements.at(i) = e
      y -= e.height + e.grow
    }
  }
  return elements
}

#let layout-elements(ctx, (x, y), width, inset, elements, i: 0) = {
  let elems = ()

  for element in elements {
    i += 1
    element.name = if-auto(element.name, "e" + str(i))
    element.pos = (x, y)
    element.width = width
    element.inset = if-auto(
      element.inset,
      inset,
      f: resolve-number.with(ctx),
    )
    element.height = if element.height == auto {
      measure(ctx, block(width: width * ctx.length, element.text)).at(1) + 2 * element.inset
    } else {
      element.height
    }

    if element.type in (TYPES.LOOP, TYPES.FUNCTION) {
      if element.elements == none or element.elements == () {
        element.elements = empty()
      }

      if element.at("test-last", default: false) {
        (element.elements, i) = layout-elements(
          ctx,
          (x + 2 * element.inset, y),
          width - 2 * element.inset,
          inset,
          () + element.elements,
          i: i,
        )
      } else {
        (element.elements, i) = layout-elements(
          ctx,
          (x + 2 * element.inset, y - element.height),
          width - 2 * element.inset,
          inset,
          () + element.elements,
          i: i,
        )
      }
      element.grow = element.elements.fold(0, (h, e) => h + e.height + e.grow)

      if element.type == TYPES.FUNCTION {
        element.grow += 2 * element.inset
      }
    } else if element.type == TYPES.BRANCH {
      if element.left == none or element.left == () {
        element.left = empty()
      }
      (element.left, i) = layout-elements(
        ctx,
        (x, y - element.height),
        width * element.column-split,
        inset,
        () + element.left,
        i: i,
      )

      if element.right == none or element.right == () {
        element.right = empty()
      }
      (element.right, i) = layout-elements(
        ctx,
        (x + width * element.column-split, y - element.height),
        width * (1 - element.column-split),
        inset,
        () + element.right,
        i: i,
      )

      let (height-left, height-right) = (
        element.left.fold(0, (h, e) => h + e.height + e.grow),
        element.right.fold(0, (h, e) => h + e.height + e.grow),
      )

      if height-left < height-right {
        element.left = rebalance-heights(element.left, (height-right - height-left))
      } else if height-right < height-left {
        element.right = rebalance-heights(element.right, (height-left - height-right))
      }

      element.grow = calc.max(height-left, height-right)
    } else if element.type == TYPES.SWITCH {
      for (index, key) in element.branches.keys().enumerate() {
        if element.branches.at(key) == none or element.branches.at(key) == () {
          element.branches.at(key) = empty()
        }
        (element.branches.at(key), i) = layout-elements(
          ctx,
          (x + width * index / element.branches.len(), y - element.height),
          width / element.branches.len(),
          inset,
          () + element.branches.at(key),
          i: i,
        )
      }

      let heights = element.branches.values().map(branch => branch.fold(0, (h, e) => h + e.height + e.grow))

      element.grow = calc.max(..heights)

      for (index, key) in element.branches.keys().enumerate() {
        element.branches.at(key) = rebalance-heights(element.branches.at(key), element.grow - heights.at(index))
      }
    }

    elems.push(element)

    y -= element.height + element.grow
  }

  return (elems, i)
}

#let draw-elements(ctx, layout, stroke: 1pt + black, theme: (:), labels: ()) = {
  for element in layout {
    let (x, y) = element.pos

    let stroke = if-auto(element.stroke, stroke)

    if element.type == TYPES.EMPTY {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        stroke: stroke,
        fill: if-auto(
          element.fill,
          theme.at("empty", default: rgb("#fffff3")),
        ),
        name: element.name,
      )
      draw.content(
        (x + element.width * .5, y - element.height * .5),
        element.text,
        anchor: "center",
        name: element.name + "-text",
      )
    } else if element.type == TYPES.PROCESS {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        stroke: stroke,
        fill: if-auto(
          element.fill,
          theme.at("process", default: rgb("#fceece")),
        ),
        name: element.name,
      )
      draw.content(
        (x + element.inset, y - element.height * .5),
        element.text,
        anchor: "west",
        name: element.name + "-text",
      )
    } else if element.type == TYPES.CALL {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        stroke: stroke,
        fill: if-auto(
          element.fill,
          theme.at("call", default: rgb("#fceece")).darken(5%),
        ),
        name: element.name,
      )
      draw.rect(
        (x + element.inset * .5, y),
        (
          x + element.width - element.inset * .5,
          y - element.height - element.grow,
        ),
        stroke: stroke,
        fill: if-auto(
          element.fill,
          theme.at("call", default: rgb("#fceece")),
        ),
      )
      draw.content(
        (x + element.inset, y - element.height * .5),
        element.text,
        anchor: "west",
        name: element.name + "-text",
      )
    } else if element.type == TYPES.LOOP {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        stroke: stroke,
        fill: if-auto(
          element.fill,
          theme.at("loop", default: rgb("#dcefe7")),
        ),
        name: element.name,
      )

      if not element.at("test-last", default: false) {
        draw.content(
          (x + element.inset, y - element.height * .5),
          element.text,
          anchor: "west",
          name: element.name + "-text",
        )
      } else {
        draw.content(
          (x + element.inset, y - element.grow - element.height * .5),
          element.text,
          anchor: "west",
          name: element.name + "-text",
        )
      }
      draw-elements(ctx, element.elements, stroke: stroke, theme: theme, labels: labels)
    } else if element.type == TYPES.FUNCTION {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        stroke: stroke,
        fill: if-auto(
          element.fill,
          theme.at("function", default: rgb("#ffffff")),
        ),
        name: element.name,
      )
      draw.content(
        (x + element.inset, y - element.height * .5),
        strong(element.text),
        anchor: "west",
        name: element.name + "-text",
      )

      draw-elements(ctx, element.elements, stroke: stroke, theme: theme, labels: labels)
    } else if element.type == TYPES.BRANCH {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        fill: if-auto(
          element.fill,
          theme.at("branch", default: rgb("#fadad0")),
        ),
        stroke: stroke,
        name: element.name,
      )

      let content-width = measure(ctx, element.text).at(0) + 2 * element.inset
      draw.content(
        (
          x + element.column-split * element.width + (.5 - element.column-split) * content-width,
          y - element.inset,
        ),
        element.text,
        anchor: "north",
        name: element.name + "-text",
      )

      draw.line(
        (x, y),
        (x + element.width * element.column-split, y - element.height),
        (x + element.width, y),
        stroke: stroke,
      )

      draw.content(
        (x + element.inset * .5, y - element.height + element.inset * .5),
        text(.66em, element.labels.at(0, default: labels.at(0, default: "true"))),
        anchor: "south-west",
      )
      draw.content(
        (
          x + element.width - element.inset * .5,
          y - element.height + element.inset * .5,
        ),
        text(.66em, element.labels.at(1, default: labels.at(1, default: "false"))),
        anchor: "south-east",
      )

      draw-elements(ctx, element.left, stroke: stroke, theme: theme, labels: labels)
      draw-elements(ctx, element.right, stroke: stroke, theme: theme, labels: labels)
    } else if element.type == TYPES.SWITCH {
      draw.rect(
        (x, y),
        (x + element.width, y - element.height - element.grow),
        fill: if-auto(
          element.fill,
          theme.at("branch", default: rgb("#fadad0")),
        ),
        stroke: stroke,
        name: element.name,
      )

      let content-width = measure(ctx, element.text).at(0) + 2 * element.inset
      draw.content(
        (
          x + element.column-split * element.width + (.5 - element.column-split) * content-width,
          y - element.inset,
        ),
        element.text,
        anchor: "north",
        name: element.name + "-text",
      )

      draw.line(
        (x, y),
        (x + element.width * element.column-split, y - element.height),
        (x + element.width, y),
        stroke: stroke,
      )

      for i in range(element.branches.len() - 1) {
        let key = element.branches.keys().at(i)
        draw.line(
          (
            x + element.width * i / element.branches.len(),
            y - element.height * i / (element.branches.len() - 1),
          ),
          (x + element.width * i / element.branches.len(), y - element.height),
        )
        draw.content(
          (
            x + element.width * i / element.branches.len() + element.inset * .5,
            y - element.height + element.inset * .5,
          ),
          text(.66em, element.labels.at(i, default: key)),
          anchor: "south-west",
        )
      }

      draw.content(
        (
          x + element.width - element.inset * .5,
          y - element.height + element.inset * .5,
        ),
        text(.66em, element.branches.keys().at(-1, default: labels.at(1, default: "default"))),
        anchor: "south-east",
      )

      for branch in element.branches.values() {
        draw-elements(ctx, branch, stroke: stroke, theme: theme, labels: labels)
      }
    }
  }
}

#let diagram(
  pos,
  anchor: "center",
  name: "nassi",
  width: 12,
  inset: .194,
  theme: (:),
  stroke: 1pt + black,
  labels: (),
  elements,
) = {
  draw.get-ctx(ctx => {
    let (layout, _) = layout-elements(
      ctx,
      pos,
      resolve-number(ctx, width),
      resolve-number(ctx, inset),
      elements,
    )
    draw.group(
      anchor: anchor,
      name: name,
      draw-elements(ctx, layout, stroke: stroke, theme: theme, labels: labels),
    )
  })
}
