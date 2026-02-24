#let error(message) = {
  return block(
    stroke: 1.5pt + red,
    fill: luma(95%),
    inset: 8pt,
    radius: 6pt,
    text(red)[#strong([Error])] + "\n" + message,
  )
}

#let get-char(s, char, neg, step: 1) = {
  let pos-char = s.position(char)
  if pos-char + step < 0 or pos-char + step >= s.len() {
    return error(
      "String index out of bounds when getting character after "
        + str(step)
        + " step(s) of \""
        + char
        + "\" in \""
        + s
        + "\"",
    )
  }
  return if s.at(pos-char + step) == neg { -1 } else { 1 }
}

#let get-index(s, char, base, count) = {
  let pos-char = s.position(char)
  let res = int(s.slice(0, pos-char)) - base
  if res < 0 or res >= count {
    return error(
      "Rail index out of bounds when getting index "
        + str(res + base)
        + " by \""
        + s
        + "\"",
    )
  }
  return res
}

#let railynx(
  rail,
  nodes,
  base-index: 1,
  rail-space: 1cm,
  node-space: 1cm,
  breakable: true,
  fill: none,
  stroke: none,
  rail-stroke: 1.5pt + blue,
  switch-tension: 0,
  platform-fill: blue,
  arrow-dx: 0.2,
  arrow-fill: none,
  arrow-stroke: blue,
) = {
  let is-content(v) = type(v) == content
  let get-op-dir(s, char, neg: "l", step: 1) = get-char(
    s,
    char,
    neg,
    step: step,
  )
  let get-op-index(op, char) = get-index(op, char, base-index, rail)
  let rail-point(point) = (point.at(0) * rail-space, point.at(1) * node-space)
  let rail-point-xy(x, y) = (x * rail-space, y * node-space)
  let draw-railway(start, end) = {
    return place(
      line(
        start: rail-point(start),
        end: rail-point(end),
        stroke: rail-stroke,
      ),
    )
  }
  let draw-switch(start, end, ctrl1, ctrl2) = {
    return place(
      curve(
        curve.move(rail-point(start)),
        curve.cubic(
          rail-point-xy(
            start.at(0) + switch-tension * ctrl1.at(0),
            start.at(1) + switch-tension * ctrl1.at(1),
          ),
          rail-point-xy(
            end.at(0) + switch-tension * ctrl2.at(0),
            end.at(1) + switch-tension * ctrl2.at(1),
          ),
          rail-point(end),
        ),
        stroke: rail-stroke,
      ),
    )
  }
  let draw-platform((dxy, size)) = {
    return place(
      dx: rail-point(dxy).at(0),
      dy: rail-point(dxy).at(1),
      rect(
        width: rail-point(size).at(0),
        height: rail-point(size).at(1),
        fill: platform-fill,
        stroke: rail-stroke,
      ),
    )
  }
  let draw-arrow(dxy, yminor) = {
    return place(
      dx: rail-point(dxy).at(0),
      dy: rail-point(dxy).at(1),
      curve(
        fill: arrow-fill,
        stroke: arrow-stroke,
        curve.move(rail-point-xy(0.4, 0.5 + 2 * yminor)),
        curve.line(rail-point-xy(0.5, 0.5 + yminor)),
        curve.line(rail-point-xy(0.6, 0.5 + 2 * yminor)),
      ),
    )
  }
  if type(rail) != int {
    return error("Argument rail: expected int, found " + str(type(rail)))
  }
  if type(nodes) == str {
    nodes = nodes.split("\n")
  } else if type(nodes) != array {
    return error(
      "Argument nodes: expected array or str, found " + str(type(nodes)),
    )
  }
  for (i, node) in nodes.enumerate() {
    if type(node) == str {
      nodes.at(i) = node.split(regex("[\r ;]+"))
    } else if type(node) != array {
      return error(
        "Argument nodes: expected array or str, found "
          + str(type(node))
          + " at nodes["
          + str(i)
          + "]",
      )
    }
  }
  let exists = range(0, rail).map(_ => 0)
  let railynx-block = block(
    width: rail * rail-space,
    height: nodes.len() * node-space,
    breakable: breakable,
    fill: fill,
    stroke: stroke,
    {
      for (i, node) in nodes.enumerate() {
        for j in range(0, rail) {
          if exists.at(j) == 2 {
            exists.at(j) = 1
          } else if exists.at(j) == 3 {
            exists.at(j) = 0
          }
        }
        if node != () {
          for op in node {
            if op == () or op == "" { continue }
            if "e" in op {
              let op-index = get-op-index(op, "e")
              if is-content(op-index) { return op-index }
              if exists.at(op-index) == 0 or exists.at(op-index) == 1 {
                exists.at(op-index) = 1 - exists.at(op-index)
              }
            } else if "E" in op {
              let op-index = get-op-index(op, "E")
              if is-content(op-index) { return op-index }
              if exists.at(op-index) == 0 or exists.at(op-index) == 1 {
                exists.at(op-index) = exists.at(op-index) + 2
              }
              if exists.at(op-index) == 2 {
                draw-railway((op-index + 0.5, i + 0.5), (op-index + 0.5, i + 1))
              } else {
                draw-railway((op-index + 0.5, i), (op-index + 0.5, i + 0.5))
              }
              draw-railway(
                (op-index + 0.25, i + 0.5),
                (op-index + 0.75, i + 0.5),
              )
            } else if op.contains(regex("[sS]")) {
              let op-char = if op.find("s") != none { "s" } else { "S" }
              let (op-index, op-dir) = (
                get-op-index(op, op-char),
                get-op-dir(op, op-char),
              )
              if is-content(op-index) { return op-index }
              if is-content(op-dir) { return op-dir }
              if exists.at(op-index) != 2 {
                if op-char == "S" { exists.at(op-index) = 3 }
                if op-index + op-dir < 0 or op-index + op-dir >= rail {
                  return error(
                    "Rail index out of bounds when switching to "
                      + str(op-index + op-dir + base-index)
                      + " from "
                      + str(op-index + base-index)
                      + " by \""
                      + op
                      + "\"",
                  )
                }
                if exists.at(op-index + op-dir) == 0 {
                  exists.at(op-index + op-dir) = 2
                }
                draw-switch(
                  (op-index + 0.5, i),
                  (op-index + 0.5 + op-dir, i + 1),
                  (0, 1),
                  (0, -1),
                )
              }
            } else if op.contains(regex("[pP]")) {
              let op-char = if op.find("p") != none { "p" } else { "P" }
              let (op-index, op-dir) = (
                get-op-index(op, op-char),
                get-op-dir(op, op-char),
              )
              if is-content(op-index) { return op-index }
              if is-content(op-dir) { return op-dir }
              draw-platform(
                if op-char == "p"
                  or (
                    op-char == "P"
                      and (op-index + op-dir == -1 or op-index + op-dir == rail)
                  ) {
                  ((op-index + 0.35 + 0.25 * op-dir, i), (0.3, 1))
                } else {
                  ((op-index + 0.1 + 0.5 * op-dir, i), (0.8, 1))
                },
              )
            } else if "a" in op {
              let (op-index, op-dir1, op-dir2) = (
                get-op-index(op, "a"),
                0.15 * get-op-dir(op, "a", neg: "d"),
                get-op-dir(op, "a", step: 2),
              )
              if is-content(op-index) { return op-index }
              if is-content(op-dir1) { return op-dir1 }
              if is-content(op-dir2) { return op-dir2 }
              draw-arrow(
                (op-index + op-dir2 * calc.abs(arrow-dx), i),
                op-dir1,
              )
            }
          }
        }
        for j in range(0, rail) {
          if exists.at(j) == 1 {
            draw-railway((j + 0.5, i), (j + 0.5, i + 1))
          }
        }
      }
    },
  )
  return railynx-block
}
