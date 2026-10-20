#import "@preview/alchemist:0.2.0": cetz
#import "anchors.typ": _structure-name, _annotation-anchor

#let _normalized-annotations(annotations) = {
  if annotations == none {
    ()
  } else if type(annotations) == array {
    annotations
  } else {
    (annotations,)
  }
}

#let _annotation-label-body(annotation, label) = {
  let body = text(
    size: annotation.at("label-size", default: 0.85em),
    fill: annotation.at("label-text-fill", default: black),
  )[#label]

  if annotation.at("boxed", default: false) {
    box(
      inset: annotation.at("label-inset", default: 2pt),
      radius: annotation.at("label-radius", default: 2pt),
      fill: annotation.at("label-fill", default: white),
      stroke: annotation.at("label-stroke", default: 0.35pt + luma(72%)),
      body,
    )
  } else {
    body
  }
}

#let _sign(value) = {
  if value > 0 { 1 } else if value < 0 { -1 } else { 0 }
}

#let _callout-placement(side) = {
  if side == "east" {
    (offset: (1.65, 0), anchor: "west")
  } else if side == "west" {
    (offset: (-1.65, 0), anchor: "east")
  } else if side == "north" {
    (offset: (0, 1.35), anchor: "south")
  } else if side == "south" {
    (offset: (0, -1.35), anchor: "north")
  } else if side == "north-east" {
    (offset: (1.45, 1.15), anchor: "west")
  } else if side == "north-west" {
    (offset: (-1.45, 1.15), anchor: "east")
  } else if side == "south-east" {
    (offset: (1.45, -1.15), anchor: "west")
  } else if side == "south-west" {
    (offset: (-1.45, -1.15), anchor: "east")
  } else {
    panic("callout side must be east, west, north, south, north-east, north-west, south-east, or south-west")
  }
}

#let _callout-target-offset(label-offset, mark, gap: 0.2) = {
  if mark != none {
    (0, 0)
  } else {
    // Stop leader lines just short of atom labels/bonds so callouts read as
    // annotations rather than extra chemical bonds.
    (_sign(label-offset.at(0)) * gap, _sign(label-offset.at(1)) * gap)
  }
}

#let _callout-label-offset(label-offset, label-gap) = {
  // Keep leader lines visually separate from unboxed label text.
  (-_sign(label-offset.at(0)) * label-gap, -_sign(label-offset.at(1)) * label-gap)
}

#let _normalize-cetz-coordinate(coord) = {
  if type(coord) == dictionary or type(coord) == str {
    _annotation-anchor(coord)
  } else {
    coord
  }
}

#let _offset-coordinate(coord, offset) = {
  if offset == none or offset == (0, 0) {
    coord
  } else {
    (to: coord, rel: offset)
  }
}

#let _normalized-leader-points(points) = {
  if points == none {
    ()
  } else if type(points) == array {
    points
  } else {
    (points,)
  }
}

#let _callout-leader-points(start, via, end) = {
  let points = (_normalize-cetz-coordinate(start),)
  for point in _normalized-leader-points(via) {
    points.push(_normalize-cetz-coordinate(point))
  }
  points.push(_normalize-cetz-coordinate(end))
  points
}

#let _render-overlay-annotations(annotations) = {
  for (idx, annotation) in _normalized-annotations(annotations).enumerate() {
    let kind = annotation.at("type", default: "arrow")
    let name = annotation.at("name", default: none)
    if name == none {
      name = "molchemist-annotation-" + str(idx)
    }

    if kind == "arrow" {
      let from = _annotation-anchor(
        annotation.at("from"),
        anchor: annotation.at("from-anchor", default: "mid"),
      )
      let to = _annotation-anchor(
        annotation.at("to"),
        anchor: annotation.at("to-anchor", default: "mid"),
      )
      cetz.draw.line(
        from,
        to,
        name: name,
        stroke: annotation.at("stroke", default: black),
        mark: annotation.at("mark", default: (end: ">>", fill: black)),
      )
      let label = annotation.at("label", default: none)
      if label != none {
        cetz.draw.content(
          (
            rel: annotation.at("label-offset", default: (0, 0)),
            to: name + ".50%",
          ),
          _annotation-label-body(annotation, label),
          anchor: annotation.at("label-anchor", default: "south"),
        )
      }
    } else if kind == "label" {
      cetz.draw.content(
        (
          rel: annotation.at("offset", default: (0, 0)),
          to: _annotation-anchor(
            annotation.at("at"),
            anchor: annotation.at("anchor", default: "mid"),
          ),
        ),
        _annotation-label-body(annotation, annotation.at("label")),
        name: name,
        anchor: annotation.at("label-anchor", default: "south"),
      )
    } else if kind == "callout" {
      let target = _annotation-anchor(
        annotation.at("at"),
        anchor: annotation.at("anchor", default: "mid"),
      )
      let placement = _callout-placement(annotation.at("side", default: "north-east"))
      let label-offset = annotation.at("label-offset", default: auto)
      if label-offset == auto {
        label-offset = placement.offset
      }
      let label-anchor = annotation.at("label-anchor", default: auto)
      if label-anchor == auto {
        label-anchor = placement.anchor
      }
      let label-position = annotation.at("label-at", default: auto)
      if label-position == auto {
        label-position = (
          rel: label-offset,
          to: target,
        )
      } else {
        label-position = _normalize-cetz-coordinate(label-position)
      }
      let label-gap = annotation.at("label-gap", default: 0.14)
      let label-start = annotation.at("leader-start", default: auto)
      if label-start == auto {
        label-start = (
          rel: _callout-label-offset(label-offset, label-gap),
          to: label-position,
        )
      } else {
        label-start = _normalize-cetz-coordinate(label-start)
      }
      label-start = _offset-coordinate(
        label-start,
        annotation.at("leader-start-offset", default: (0, 0)),
      )
      let target-offset = annotation.at("target-offset", default: auto)
      if target-offset == auto {
        target-offset = _callout-target-offset(
          label-offset,
          annotation.at("mark", default: none),
          gap: annotation.at("target-gap", default: 0.2),
        )
      }
      let target-end = annotation.at("leader-end", default: auto)
      if target-end == auto {
        target-end = (
          rel: target-offset,
          to: target,
        )
      } else {
        target-end = _normalize-cetz-coordinate(target-end)
      }
      target-end = _offset-coordinate(
        target-end,
        annotation.at("leader-end-offset", default: (0, 0)),
      )
      let leader = annotation.at("leader", default: "curve")
      let leader-points = annotation.at("leader-points", default: ())
      let path-points = _callout-leader-points(label-start, leader-points, target-end)
      if leader == "curve" {
        cetz.draw.hobby(
          ..path-points,
          name: name + "-leader",
          stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
          mark: annotation.at("mark", default: none),
        )
      } else if leader == "straight" {
        cetz.draw.line(
          ..path-points,
          name: name + "-leader",
          stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
          mark: annotation.at("mark", default: none),
        )
      } else if leader == "elbow" {
        if _normalized-leader-points(leader-points).len() > 0 {
          cetz.draw.line(
            ..path-points,
            name: name + "-leader",
            stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
            mark: annotation.at("mark", default: none),
          )
        } else {
          let elbow = (
            rel: (0, label-offset.at(1)),
            to: target,
          )
          cetz.draw.line(
            label-start,
            elbow,
            target-end,
            name: name + "-leader",
            stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
            mark: annotation.at("mark", default: none),
          )
        }
      } else {
        panic("callout leader must be \"curve\", \"elbow\", or \"straight\"")
      }
      cetz.draw.content(
        label-position,
        _annotation-label-body(annotation, annotation.at("label")),
        name: name,
        anchor: label-anchor,
      )
    } else if kind == "cetz" {
      let body = annotation.at("body")
      body(_structure-name)
    } else {
      panic("Unknown molchemist annotation type: " + repr(kind))
    }
  }
}
