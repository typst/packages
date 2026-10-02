

// #start default-stroke
/// Typst's default `stroke`
#let default-stroke = (
  paint: black,
  thickness: 1pt,
  cap: "butt",
  join: "miter",
  dash: none,
  miter-limit: 4.0,
)
// #end default-stroke

// #start default-base-stroke
/// A default `stroke` for this package
#let default-base-stroke = (
  paint: blue,
  thickness: 0.5pt,
  cap: "round",
  join: "round",
)
// #end default-base-stroke

#let Stroke-config(stroke-mode: "merge", base-stroke: default-base-stroke) = {
  assert(stroke-mode == "merge" or stroke-mode == "cover", message: "Unknown stroke mode: " + str(stroke-mode) + ".")
  return (stroke-mode: stroke-mode, base-stroke: base-stroke)
}

// #start default-stroke-config
#let default-stroke-config = Stroke-config(
  stroke-mode: "merge",
  base-stroke: default-base-stroke,
)
// #end default-stroke-config

/// Convert a stroke object to a dictionary
#let stroke-to-dict(s) = {
  let t = type(s)
  if s == auto {
    return (paint: black, thickness: 1pt)
  }
  if t == dictionary {
    // 这个递归的作用是检查有无非法字段
    return stroke-to-dict(stroke(s))
  }
  if t in (color, gradient, tiling) {
    return (paint: s)
  }
  if t == length {
    return (thickness: s)
  }
  if t == stroke {
    return (
      paint: s.paint,
      thickness: s.thickness,
      join: s.join,
      cap: s.cap,
      miter-limit: s.miter-limit,
      dash: s.dash,
    )
  }
  return (thickness: 0pt)
}

/// Merge two stroke with `top` overriding `bottom`.
/// Attributes missing or set to `auto` in `top` inherit values from `bottom`.
///
/// - top (stroke): High-priority stroke style.
/// - bottom (stroke): Base stroke style.
/// -> dictionary
#let merge-stroke(top, bottom) = {
  let expand-auto(top-dict, bottom-dict) = {
    let res = top-dict
    for (k, v) in bottom-dict {
      if res.at(k, default: auto) == auto {
        // For keys with the same name: override when not `auto`; inherit when `auto`.
        res.insert(k, v)
      }
    }
    return res
  }
  let b-stroke = expand-auto(stroke-to-dict(bottom), default-stroke)
  let t-stroke = stroke-to-dict(top)
  expand-auto(t-stroke, b-stroke)
}


///
///
/// - stroke ():
/// - stroke-config ("merge" | "cover"): `base-stroke` is the underlying stroke used for merging when `stroke-mode` is "merge". When stroke-mode is "cover", base-stroke has no effect.
/// -> stroke in dictionary
#let resolve-stroke(
  stroke,
  stroke-config: default-stroke-config,
) = {
  let stroke-mode = stroke-config.stroke-mode
  let final-stroke = if stroke-mode == "merge" {
    let base-stroke = stroke-config.base-stroke
    merge-stroke(stroke, base-stroke)
  } else if stroke-mode == "cover" {
    merge-stroke(stroke, default-stroke)
  } else {
    panic-fmt("Unknown stroke mode: {}.", str(stroke-mode))
  }
  return final-stroke
}




// Handle the `inset` parameter of `block` and `box`.
#let resolve-sides(sides) = {
  let ret = (
    left: none,
    right: none,
    top: none,
    bottom: none,
  )
  let set-val(..keys, val: none, sides: none) = {
    assert.eq(keys.named().len(), 0)
    let arr-keys = keys.pos()
    for key in arr-keys {
      sides.at(key) = val
    }
    return sides
  }
  if type(sides) != dictionary {
    assert.eq(type(sides), std.length, message: "Ratio and relative length are not supported. Please use length only.")
    return set-val("left", "right", "top", "bottom", val: sides, sides: ret)
  }
  let _ = sides.map(
    it => assert.eq(
      type(it),
      std.length,
      message: "Ratio and relative length are not supported. Please use length only.",
    ),
  )
  if "y" in sides { ret = set-val("top", "bottom", val: sides.at("y"), sides: ret) }
  if "x" in sides { ret = set-val("left", "right", val: sides.at("x"), sides: ret) }
  if "left" in sides { ret = set-val("left", val: sides.at("left"), sides: ret) }
  if "bottom" in sides { ret = set-val("bottom", val: sides.at("bottom"), sides: ret) }
  if "right" in sides { ret = set-val("right", val: sides.at("right"), sides: ret) }
  if "top" in sides { ret = set-val("top", val: sides.at("top"), sides: ret) }
  if "rest" in sides {
    ret = ret.map(
      it => if it == none {
        sides.at("rest")
      } else {
        it
      },
    )
  }
  return ret.map(it => if it == none { 0pt } else { it })
}
