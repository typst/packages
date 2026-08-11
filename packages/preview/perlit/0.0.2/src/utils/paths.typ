#let beautify_paths(start, target, ctrl_points, edge) = {
  let ctrl = {
    if edge.fromSide == "top" and edge.toSide == "top" {
      if start.at(1) > target.at(1) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
        )
      } else {
        (
          start: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "bottom" and edge.toSide == "bottom" {
      if start.at(1) < target.at(1) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
        )
      } else {
        (
          start: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "right" and edge.toSide == "right" {
      if start.at(0) > target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
        )
      } else {
        (
          start: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "left" and edge.toSide == "left" {
      if start.at(0) < target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
        )
      } else {
        (
          start: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "right" and edge.toSide == "left" {
      if start.at(0) == target.at(0) {
        (
          start: (start.at(0) - 0.000001, start.at(1)),
          target: target,
        )
      } else if start.at(0) > target.at(0) {
        let midY = (ctrl_points.start.at(1) + ctrl_points.target.at(1)) / 2
        (
          start: ctrl_points.start,
          mid0: (ctrl_points.start.at(0), midY),
          mid1: (ctrl_points.target.at(0), midY),
          target: ctrl_points.target,
        )
      } else {
        let mid = (ctrl_points.start.at(0) + ctrl_points.target.at(0)) / 2
        (
          start: (mid, ctrl_points.start.at(1)),
          target: (mid, ctrl_points.target.at(1)),
        )
      }
    }

    if edge.fromSide == "left" and edge.toSide == "right" {
      if start.at(0) == target.at(0) {
        (
          start: (start.at(0) - 0.000001, start.at(1)),
          target: target,
        )
      } else if start.at(0) < target.at(0) {
        let midY = (ctrl_points.start.at(1) + ctrl_points.target.at(1)) / 2
        (
          start: ctrl_points.start,
          mid0: (ctrl_points.start.at(0), midY),
          mid1: (ctrl_points.target.at(0), midY),
          target: ctrl_points.target,
        )
      } else {
        let midX = (ctrl_points.start.at(0) + ctrl_points.target.at(0)) / 2
        (
          start: (midX, ctrl_points.start.at(1)),
          target: (midX, ctrl_points.target.at(1)),
        )
      }
    }

    if edge.fromSide == "top" and edge.toSide == "bottom" {
      if start.at(1) == target.at(1) {
        (
          start: (start.at(0), start.at(1) - 0.000001),
          target: target,
        )
      } else if start.at(1) > target.at(1) {
        let midX = (ctrl_points.start.at(0) + ctrl_points.target.at(0)) / 2
        (
          start: ctrl_points.start,
          mid0: (midX, ctrl_points.start.at(1)),
          mid1: (midX, ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      } else {
        let midY = (ctrl_points.start.at(1) + ctrl_points.target.at(1)) / 2
        (
          start: (ctrl_points.start.at(0), midY),
          target: (ctrl_points.target.at(0), midY),
        )
      }
    }

    if edge.fromSide == "bottom" and edge.toSide == "top" {
      if start.at(1) == target.at(1) {
        (
          start: (start.at(0), start.at(1) - 0.000001),
          target: target,
        )
      } else if start.at(1) < target.at(1) {
        let midX = (ctrl_points.start.at(0) + ctrl_points.target.at(0)) / 2
        (
          start: ctrl_points.start,
          mid0: (midX, ctrl_points.start.at(1)),
          mid1: (midX, ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      } else {
        let midY = (ctrl_points.start.at(1) + ctrl_points.target.at(1)) / 2
        (
          start: (ctrl_points.start.at(0), midY),
          target: (ctrl_points.target.at(0), midY),
        )
      }
    }


    if edge.fromSide == "right" and edge.toSide == "top" {
      if ctrl_points.start.at(1) > ctrl_points.target.at(1) and ctrl_points.start.at(0) < target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "top" and edge.toSide == "right" {
      if ctrl_points.start.at(1) < ctrl_points.target.at(1) and ctrl_points.start.at(0) > target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "left" and edge.toSide == "top" {
      if ctrl_points.start.at(1) > ctrl_points.target.at(1) and ctrl_points.start.at(0) > target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "top" and edge.toSide == "left" {
      if ctrl_points.start.at(1) < ctrl_points.target.at(1) and ctrl_points.start.at(0) < target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if (edge.fromSide == "right" and edge.toSide == "bottom") {
      if ctrl_points.start.at(1) < ctrl_points.target.at(1) and ctrl_points.start.at(0) < target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if (edge.fromSide == "bottom" and edge.toSide == "right") {
      if ctrl_points.start.at(1) > ctrl_points.target.at(1) and ctrl_points.start.at(0) > target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if edge.fromSide == "left" and edge.toSide == "bottom" {
      if ctrl_points.start.at(1) < ctrl_points.target.at(1) and ctrl_points.start.at(0) > target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
          target: ctrl_points.target,
        )
      }
    }

    if (edge.fromSide == "bottom" and edge.toSide == "left") {
      if ctrl_points.start.at(1) > ctrl_points.target.at(1) and ctrl_points.start.at(0) < target.at(0) {
        (
          start: ctrl_points.start,
          target: (ctrl_points.start.at(0), ctrl_points.target.at(1)),
        )
      } else {
        (
          start: ctrl_points.start,
          mid: (ctrl_points.target.at(0), ctrl_points.start.at(1)),
          target: ctrl_points.target,
        )
      }
    }
  }

  (
    start: start,
    target: target,
    ctrl_points: if ctrl == none { ctrl_points } else { ctrl },
  )
}

#let bezier_at(p0, p1, p2, p3, t) = {
  let lerp(p, q, t) = {
    (
      (1 - t) * p.at(0) + t * q.at(0),
      (1 - t) * p.at(1) + t * q.at(1),
    )
  }

  let a = lerp(p0, p1, t)
  let b = lerp(p1, p2, t)
  let c = lerp(p2, p3, t)

  let d = lerp(a, b, t)
  let e = lerp(b, c, t)

  lerp(d, e, t)
}

#let line_at(points, t) = {
  if points.len() == 0 {
    none
  } else if points.len() == 1 {
    points.at(0)
  } else {
    let seg-lengths = ()
    let total = 0.0

    for i in range(0, points.len() - 1) {
      let p0 = points.at(i)
      let p1 = points.at(i + 1)

      let dx = p1.at(0) - p0.at(0)
      let dy = p1.at(1) - p0.at(1)
      let len = calc.sqrt(dx * dx + dy * dy)

      seg-lengths.push(len)
      total += len
    }

    let target = t * total

    let acc = 0.0

    for i in range(0, seg-lengths.len()) {
      let seg = seg-lengths.at(i)

      if acc + seg >= target {
        let p0 = points.at(i)
        let p1 = points.at(i + 1)

        let t = (target - acc) / seg

        let x = p0.at(0) + t * (p1.at(0) - p0.at(0))
        let y = p0.at(1) + t * (p1.at(1) - p0.at(1))

        return (x, y)
      }

      acc += seg
    }

    points.at(points.len() - 1)
  }
}
