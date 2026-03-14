#import "deps.typ": *

#let ratios = (
  monitor: (1, 0.8),
  server: (0.5, 1),
)

#let draw-lbl = (
  label,
  label-pos,
  sx,
  sy,
  flat: true,
  is-circle: false,
) => if label != none {
  // FIXME: label absolute gap instead of relative
  let x = if label-pos.x == none {
    if flat or is-circle { 0 } else if label-pos.y == top {
      sx * 1 / 5
    } else {
      -sx * 1 / 5
    }
  } else if label-pos.x == left { -sx } else { sx }
  let y = if label-pos.y == none {
    0
  } else {
    (
      // FIXME: should be relative to label, not icon size
      (if flat { sy * 6 / 5 } else { sy * 4 / 5 })
        * (if label-pos.y == top { 1 } else { -1 })
    )
  }
  let pos = (x, y)
  let anchor-y = if label-pos.y == top {
    "south"
  } else if label-pos.y == bottom { "north" } else { none }
  let anchor-x = if label-pos.x == left {
    "east"
  } else if label-pos.x == right { "west" } else { none }
  // TODO: proper anchor
  cetz.draw.content(pos, label, anchor: if anchor-y != none {
    anchor-y
  } else { anchor-x })
}

// FIXME: fletcher doesn't provide x,y pos
// #let to-3d = (x, y, circle) => {
// let (yn, xn) = if circle { (0, 1) } else { (1 / 4, 3 / 4) }
// let mat = (
//   (xn, yn, 0, x),
//   (0, -3 / 8, 1 / 2, -y - 1 / 4),
//   (0, 0, 1, 0),
//   (0, 0, 0, 1),
// )
// cetz.draw.set-transform(mat)
// }

// FIXME: oh the ugliness
#let to-3d = (flat, shape, c) => {
  let off = if shape == "rect" { 1.08 } else { 1 }
  if flat { c } else if shape == "hex" or shape == "circle" {
    cetz.draw.translate(y: .25)
    cetz.draw.scale(y: 64%)
    cetz.draw.ortho(
      x: 60deg,
      y: 0deg,
      z: 0deg,
      sorted: false,
      c,
    )
  } else if shape == "bridge" or shape == "firewall" {
    cetz.draw.translate(x: -.15, y: -.1)
    cetz.draw.scale(x: 82%, y: 64%)
    cetz.draw.rotate(x: 0deg, y: 9deg)
    cetz.draw.ortho(
      x: -20deg,
      y: -20deg,
      z: 0deg,
      sorted: false,
      c,
    )
  } else {
    cetz.draw.translate(y: .25)
    cetz.draw.scale(x: 84% * off, y: 50%)
    cetz.draw.rotate(x: -17deg * off, y: -6deg * off)
    cetz.draw.ortho(
      x: 60deg,
      y: -11deg,
      z: -10deg,
      sorted: false,
      c,
    )
  }
}

#let stroke-to-paint = s => if type(s) == stroke { s.paint } else { s }
#let to-stroke = s => if type(s) == stroke { s } else { (paint: s) }
#let override-stroke = (s, ..o) => {
  let s-dict = if type(s) == stroke {
    (
      paint: s.paint,
      thickness: s.thickness,
      cap: s.cap,
      join: s.join,
      dash: s.dash,
      miter-limit: s.miter-limit,
    )
  } else { (paint: s) }
  (:..s-dict, ..o.named())
}

#let resolve-pos = (pos, (dsx, dsy)) => {
  let s = pos.at(1, default: (dsx, dsy))
  let size = if type(s) == array { s } else { (s * dsx, s * dsy) }
  let p = pos.first(default: (0, 0))
  let p = if type(p) == array { p } else { (p, p) }
  (
    p,
    size,
  )
}
#let resolve-style = (s, _, stroke-inner, fill-inner) => (
  if stroke-inner == auto { stroke-to-paint(s) } else { stroke-inner },
  if fill-inner == auto { stroke-to-paint(s) } else {
    fill-inner
  },
)

// TODO:
/// Default stroke
/// -> stroke
#let stroke-def = black + 2pt
/// Default fill
/// -> paint
#let fill-def = white
