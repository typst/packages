// Projected node anchors and optional CeTZ leader composition.

#import "protocol.typ": _required

#let _projected-anchor(node, width, height, canvas-width, canvas-height) = (
  node: node.at("node_id"),
  x: width * node.at("x") / canvas-width,
  y: height * node.at("y") / canvas-height,
  x-ratio: node.at("x") / canvas-width,
  y-ratio: node.at("y") / canvas-height,
  screen-x: node.at("x"),
  screen-y: node.at("y"),
  depth: node.at("depth"),
)

/// Return one projected node from a render result. Coordinates `x` and `y`
/// are Typst lengths measured from the render block's top-left corner.
///
/// - render-result (dictionary): Result of `render` with `return-report: true`.
/// - node (int): Requested node ID included in `anchor-nodes` or an annotation.
/// -> dictionary
#let node-anchor(render-result, node: none) = {
  let node = _required("node", node)
  if type(render-result) != dictionary or not "node-anchors" in render-result {
    panic("Axodendron: `node-anchor` requires `render(..., return-report: true)`")
  }
  let found = render-result.at("node-anchors").find(anchor => anchor.at("node") == node)
  if found == none {
    panic("Axodendron: node " + str(node) + " is not present in this render result; request it with `anchor-nodes`")
  }
  found
}

#let _cetz-point(render-result, anchor, length) = (
  anchor.at("x") / length,
  (render-result.at("height") - anchor.at("y")) / length,
)

#let _cetz-relative(point, offset, length) = (
  point.at(0) + offset.at("x") / length,
  point.at(1) - offset.at("y") / length,
)

#let _cetz-auto-anchor(offset) = {
  let x = offset.at("x")
  let y = offset.at("y")
  if x > 0pt and y > 0pt {
    "north-west"
  } else if x > 0pt and y < 0pt {
    "south-west"
  } else if x < 0pt and y > 0pt {
    "north-east"
  } else if x < 0pt and y < 0pt {
    "south-east"
  } else if x > 0pt {
    "west"
  } else if x < 0pt {
    "east"
  } else if y > 0pt {
    "north"
  } else if y < 0pt {
    "south"
  } else {
    "center"
  }
}

#let _cetz-leader-start(label-name, offset) = {
  let x = offset.at("x")
  let y = offset.at("y")
  label-name + "." + if x > 0pt {
    "mid-west"
  } else if x < 0pt {
    "mid-east"
  } else if y > 0pt {
    "north"
  } else {
    "south"
  }
}

#let _shorten-cetz-target(previous, target, gap, length) = {
  if gap == 0pt {
    target
  } else {
    let dx = target.at(0) - previous.at(0)
    let dy = target.at(1) - previous.at(1)
    let distance = calc.sqrt(dx * dx + dy * dy)
    if distance == 0 {
      panic("Axodendron: the last CeTZ leader segment has zero length")
    }
    let amount = gap / length
    if amount >= distance {
      panic("Axodendron: `cetz-label.target-gap` must be shorter than the last leader segment")
    }
    (
      target.at(0) - dx * amount / distance,
      target.at(1) - dy * amount / distance,
    )
  }
}

/// Overlay CeTZ leader labels on a completed render result. The CeTZ module is
/// injected by the caller so Axodendron remains usable without that package.
///
/// - render-result (dictionary): Result of `render` with `return-report: true`.
/// - cetz (module): Imported CeTZ module.
/// - labels (array): Annotations returned by `cetz-label`.
/// - length (length): Positive CeTZ canvas coordinate unit.
/// - strict (bool): Whether a missing target node should stop evaluation.
/// -> content
#let cetz-annotate(
  render-result,
  cetz: none,
  labels: (),
  length: 1pt,
  strict: true,
) = {
  let cetz = _required("cetz", cetz)
  if type(render-result) != dictionary or not "body" in render-result or not "node-anchors" in render-result {
    panic("Axodendron: `cetz-annotate` requires `render(..., return-report: true)`")
  }
  if type(labels) != array {
    panic("Axodendron: `cetz-annotate.labels` must be an array")
  }
  if type(length) != std.length or length <= 0pt {
    panic("Axodendron: `cetz-annotate.length` must be a positive length")
  }
  let commands = ()
  let width = render-result.at("width") / length
  let height = render-result.at("height") / length
  commands += cetz.draw.on-layer(-2, cetz.draw.content(
    (0, 0),
    (width, height),
    render-result.at("body"),
    padding: 0,
  ))

  for anchor in render-result.at("node-anchors") {
    commands += cetz.draw.anchor(
      "axodendron-node-" + str(anchor.at("node")),
      _cetz-point(render-result, anchor, length),
    )
  }

  for ((index, annotation)) in labels.enumerate() {
    if type(annotation) != dictionary or annotation.at("kind", default: none) != "cetz-label" {
      panic("Axodendron: `cetz-annotate.labels` accepts only values returned by `cetz-label`")
    }
    let anchor = render-result.at("node-anchors").find(item => item.at("node") == annotation.at("node"))
    if anchor == none {
      if strict {
        panic("Axodendron: CeTZ label node " + str(annotation.at("node")) + " is not present in this render result")
      }
    } else {
      let target = _cetz-point(render-result, anchor, length)
      let label-point = _cetz-relative(target, annotation.at("offset"), length)
      let label-name = "axodendron-label-" + str(index)
      let label-anchor = if annotation.at("anchor") == auto {
        _cetz-auto-anchor(annotation.at("offset"))
      } else {
        annotation.at("anchor")
      }
      commands += cetz.draw.on-layer(1, cetz.draw.content(
        label-point,
        annotation.at("body"),
        name: label-name,
        anchor: label-anchor,
        padding: annotation.at("padding"),
        frame: "rect",
        fill: annotation.at("fill"),
        stroke: annotation.at("label-stroke"),
      ))
      let via = annotation.at("via").map(point => _cetz-relative(target, point, length))
      let controls = annotation.at("controls").map(point => _cetz-relative(target, point, length))
      let previous = if controls != () {
        controls.last()
      } else if via == () {
        label-point
      } else {
        via.last()
      }
      let endpoint = _shorten-cetz-target(
        previous,
        target,
        annotation.at("target-gap"),
        length,
      )
      let leader-start = _cetz-leader-start(label-name, annotation.at("offset"))
      let leader-end = if endpoint == target {
        "axodendron-node-" + str(annotation.at("node"))
      } else {
        endpoint
      }
      let mark = if annotation.at("mark") == none {
        none
      } else {
        (
          end: annotation.at("mark"),
          scale: annotation.at("mark-scale"),
          fill: annotation.at("arrow-fill"),
          transform-shape: false,
        )
      }
      let leader = if controls == () {
        cetz.draw.line(
          ..((leader-start,) + via + (leader-end,)),
          stroke: annotation.at("arrow-stroke"),
          mark: mark,
        )
      } else {
        cetz.draw.bezier(
          leader-start,
          leader-end,
          ..controls,
          stroke: annotation.at("arrow-stroke"),
          mark: mark,
        )
      }
      commands += cetz.draw.on-layer(0, leader)
    }
  }
  cetz.canvas(commands, length: length)
}
