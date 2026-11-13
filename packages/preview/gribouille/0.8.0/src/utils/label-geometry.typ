///! Rotated-label geometry: where a label is pinned, and how far it reaches
///! from that pin.
///!
///! Shared by the chrome stage, which reserves the band a label lands in, and
///! by the guide primitives, which draw it. Both sides read the same anchor
///! table and the same reach arithmetic, so the side a label is reserved on
///! and the side it is drawn on cannot drift apart.

// The anchor `_draw-x-label` pins an x tick label at. Kept here, beside the
// reach arithmetic that reserves room for it, so the side a label is reserved
// on and the side it is drawn on cannot drift apart.
#let _x-label-anchor(angle) = {
  if angle == 0 { "north" } else if angle > 0 { "north-east" } else {
    "north-west"
  }
}

// Where each anchor sits on the unrotated label box, in half-extent units from
// its centre. Only the anchors the axis draws are listed: `north` and the two
// corner anchors for x labels, `mid-east` / `mid-west` for y labels, `south`
// for a secondary x, and `center` for a radial theta label.
#let _ANCHOR-OFFSET = (
  center: (0, 0),
  north: (0, 1),
  south: (0, -1),
  "north-east": (1, 1),
  "north-west": (-1, 1),
  "mid-east": (1, 0),
  "mid-west": (-1, 0),
)

// How far (cm) a label of `w-cm` by `h-cm` drawn at `angle` with `anchor`
// reaches from the point it is pinned at, per canvas side.
//
// cetz names a `content` anchor on the turned rectangle's own corners rather
// than on the bounding box of the rotation, so a rotated corner-pinned label
// swings about its pin: a `north-east` label at 45 degrees reaches left by its
// length and right by its thickness, not to one side alone. Both box axes
// therefore project onto both canvas axes, and the two extremes are
// independent along each, so a side takes the larger projection of each axis.
#let _label-reach(w-cm, h-cm, angle, anchor) = {
  let (ox, oy) = _ANCHOR-OFFSET.at(anchor)
  let a = angle * 1deg
  let (cos-a, sin-a) = (calc.cos(a), calc.sin(a))
  // Distance from the pin to each edge of the box, along the box's own axes.
  let (bx-hi, bx-lo) = ((1 - ox) * w-cm / 2, (1 + ox) * w-cm / 2)
  let (by-hi, by-lo) = ((1 - oy) * h-cm / 2, (1 + oy) * h-cm / 2)
  let _end = (d-hi, d-lo, proj) => calc.max(d-hi * proj, -d-lo * proj)
  (
    right: _end(bx-hi, bx-lo, cos-a) + _end(by-hi, by-lo, -sin-a),
    left: _end(bx-hi, bx-lo, -cos-a) + _end(by-hi, by-lo, sin-a),
    up: _end(bx-hi, bx-lo, sin-a) + _end(by-hi, by-lo, cos-a),
    down: _end(bx-hi, bx-lo, -sin-a) + _end(by-hi, by-lo, -cos-a),
  )
}

// Bounding box (cm) of an ink box of `w-cm` by `h-cm` turned by `angle`
// degrees: how far it reaches either way from its own centre, which is
// `_label-reach` at the `center` anchor. Both trigonometric terms come out
// absolute there, so a box turned past a quarter turn is as big as its mirror
// in the first quadrant rather than folding back towards nothing.
#let _rotated-extent(w-cm, h-cm, angle) = {
  let r = _label-reach(w-cm, h-cm, angle, "center")
  (width: r.left + r.right, height: r.up + r.down)
}
