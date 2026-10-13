#import "@preview/cetz:0.5.2": canvas, draw
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font
#import "vowels.typ": language-vowels, vowel-data

// Vowels supported by the 3D chart (Ladefoged & Maddieson 1996, p. 283)
#let vowels-3d-inventory = ("i", "e", "ɛ", "a", "u", "o", "ɔ", "ɒ", "ə")

// Distance between the unrounded (front) and rounded (back) faces; fixed by design
#let vowels-3d-depth = 4

// Accept an angle, or a plain number read as degrees (30 = 30deg)
#let to-angle(value, name) = {
  if type(value) == angle { value } else if type(value) in (int, float) { value * 1deg } else {
    panic("vowels-3d: " + name + " must be an angle (e.g. 30deg) or a number of degrees (e.g. 30)")
  }
}

// Roundedness score (depth): 0 = front face (least rounded), 1 = back face (most rounded)
// High vowels sit at the extremes (i least, u most rounded); low vowels meet at 0.5
#let get-roundedness-score(vowel-info) = {
  if vowel-info.rounded {
    0.5 + (vowel-info.height * 0.5) - ((1 - vowel-info.frontness) * vowel-info.height)
  } else {
    ((1 - vowel-info.height) * 0.5) + (vowel-info.frontness * vowel-info.height)
  }
}

// Orthographic projection: spin around the vertical axis by `rotation`,
// then tilt the view down by `tilt`. Returns (screen-x, screen-y, view-depth);
// larger view-depth = farther from the viewer.
#let project-3d(p, rotation, tilt) = {
  let (x, y, z) = p
  let x1 = x * calc.cos(rotation) + z * calc.sin(rotation)
  let z1 = -x * calc.sin(rotation) + z * calc.cos(rotation)
  let y2 = y * calc.cos(tilt) + z1 * calc.sin(tilt)
  let z2 = -y * calc.sin(tilt) + z1 * calc.cos(tilt)
  (x1, y2, z2)
}

#let vowels-3d(
  ..args, // Optional positional vowel string (tipa-style); default: all 9 vowels
  rotation: 30deg, // Spin around the vertical axis (0deg = straight-on; positive = depth recedes left); number = degrees
  tilt: 20deg, // Viewing angle from above (0deg = eye level); number = degrees
  width: 8,
  height: 6,
  rows: 3,
  cols: 2,
  scale: 0.7,
  depth-cue: true, // Draw farther vowels smaller; fades out automatically in flat front/back views
) = {
  assert(type(depth-cue) == bool, message: "vowels-3d: depth-cue must be true or false")
  assert(args.pos().len() <= 1,
    message: "vowels-3d: expected at most one positional argument (the vowel string)")
  assert(args.named().len() == 0,
    message: "vowels-3d: unexpected named argument(s): " + args.named().keys().join(", "))
  let vowel-string = args.pos().at(0, default: "ieEauoO6@")
  let rotation = to-angle(rotation, "rotation")
  let tilt = to-angle(tilt, "tilt")
  let supported = "i e ɛ a u o ɔ ɒ ə (tipa: i e E a u o O 6 @)"
  assert(
    type(vowel-string) != str or lower(vowel-string) not in language-vowels,
    message: "vowels-3d: language names are not accepted (got \"" + str(vowel-string)
      + "\"). Use the nine default vowels or a subset of " + supported,
  )
  let scale-factor = scale // `scale` is shadowed by the built-in inside canvas closures
  let vowels-to-plot = ipa-to-unicode(vowel-string).clusters().filter(v => v.trim() != "")
  for v in vowels-to-plot {
    assert(
      v in vowels-3d-inventory,
      message: "vowels-3d: unsupported symbol \"" + v + "\". Only the nine default vowels or a subset of them are accepted: " + supported,
    )
  }

  let scaled-width = width * scale
  let scaled-height = height * scale
  let scaled-depth = vowels-3d-depth * scale
  let scaled-font-size = 22 * scale
  let scaled-line-thickness = 0.85 * scale

  let top = scaled-height / 2
  let bottom = -scaled-height / 2
  // Same trapezoid as the 2D vowels() chart (x, y), extruded along z
  let tl = (-scaled-width / 2, top)
  let tr = (scaled-width / 2, top)
  let br = (scaled-width / 2, bottom)
  let bl = (-scaled-width / 10, bottom)

  // Left/right edge x at a given height
  let edge-x(corner-top, corner-bottom, y) = {
    let t = (top - y) / scaled-height
    corner-top.at(0) * (1 - t) + corner-bottom.at(0) * t
  }

  // Negated so positive rotation sends the depth up-left, as in Ladefoged & Maddieson
  let proj(p) = project-3d(p, -rotation, tilt)
  let to-screen(p) = proj(p).slice(0, 2)

  // A face is visible when its outward normal points toward the viewer
  let facing(normal) = proj(normal).at(2) < 0
  let slant-len = calc.sqrt(scaled-height * scaled-height + calc.pow(bl.at(0) - tl.at(0), 2))
  let visible = (
    front: facing((0, 0, -1)),
    back: facing((0, 0, 1)),
    top: facing((0, 1, 0)),
    bottom: facing((0, -1, 0)),
    right: facing((1, 0, 0)),
    left: facing((-scaled-height / slant-len, -(bl.at(0) - tl.at(0)) / slant-len, 0)),
  )

  let solid-stroke = (paint: black, thickness: scaled-line-thickness * 1pt)
  let grid-stroke = (paint: gray, thickness: scaled-line-thickness * 1pt)
  let hidden-stroke = (paint: gray, thickness: scaled-line-thickness * 0.8pt, dash: "dashed")

  // Segments: (start-3d, end-3d, faces it belongs to, is-outline)
  let segments = ()
  let z0 = 0
  let z1 = scaled-depth
  let corners = (tl, tr, br, bl)
  let corner-faces = (("top", "left"), ("top", "right"), ("bottom", "right"), ("bottom", "left"))
  let side-faces = ("top", "right", "bottom", "left")
  for i in range(4) {
    let a = corners.at(i)
    let b = corners.at(calc.rem(i + 1, 4))
    let side = side-faces.at(i)
    segments.push(((..a, z0), (..b, z0), ("front", side), true))
    segments.push(((..a, z1), (..b, z1), ("back", side), true))
    segments.push(((..a, z0), (..a, z1), corner-faces.at(i), true))
  }

  // Height levels wrap around the four vertical faces
  for i in range(1, rows) {
    let y = top - scaled-height * i / rows
    let lx = edge-x(tl, bl, y)
    let rx = edge-x(tr, br, y)
    segments.push(((lx, y, z0), (rx, y, z0), ("front",), false))
    segments.push(((rx, y, z0), (rx, y, z1), ("right",), false))
    segments.push(((rx, y, z1), (lx, y, z1), ("back",), false))
    segments.push(((lx, y, z1), (lx, y, z0), ("left",), false))
  }

  // Front/back divisions on the front face
  for i in range(1, cols) {
    let t = i / cols
    let x-top = tl.at(0) * (1 - t) + tr.at(0) * t
    let x-bottom = bl.at(0) * (1 - t) + br.at(0) * t
    segments.push(((x-top, top, z0), (x-bottom, bottom, z0), ("front",), false))
  }

  // Peripheral vowels sit on the left (front) or right (back) face; central vowels
  // float inside the prism. Depth is set by roundedness.
  let vowel-points = vowels-to-plot.dedup().map(v => {
    let info = vowel-data.at(v)
    let y = bottom + info.height * scaled-height
    let lx = edge-x(tl, bl, y)
    let rx = edge-x(tr, br, y)
    let interior = info.frontness >= 0.4 and info.frontness <= 0.6
    let x = if interior { lx + info.frontness * (rx - lx) } else if info.frontness < 0.5 { lx } else { rx }
    (vowel: v, pos: (x, y, get-roundedness-score(info) * scaled-depth), interior: interior)
  })

  canvas({
    import draw: *

    // Hidden edges first, so visible lines are drawn on top
    for (a, b, faces, outline) in segments {
      if not faces.any(f => visible.at(f)) {
        line(to-screen(a), to-screen(b), stroke: hidden-stroke)
      }
    }
    for (a, b, faces, outline) in segments {
      if faces.any(f => visible.at(f)) {
        line(to-screen(a), to-screen(b), stroke: if outline { solid-stroke } else { grid-stroke })
      }
    }

    // Depth cue: vowels farther from the viewer are drawn smaller (lines are unchanged).
    // Distance is normalized between the nearest and farthest prism corners.
    // Strength fades to 0 only as the line of sight approaches the rounding axis
    // (flat front or back view, which looks like the 2D trapezoid). Top, bottom and
    // side views keep the cue. m = 1 when looking straight along that axis.
    let max-shrink = 0.3 // Farthest vowel at 70% size
    let full-at = 0.15 // 1 - m at which the cue reaches full strength (default view: ~0.19)
    let m = calc.abs(proj((0, 0, 1)).at(2))
    let t = calc.min(1, (1 - m) / full-at)
    let strength = if depth-cue { max-shrink * t * t * (3 - 2 * t) } else { 0 } // smoothstep
    let corner-depths = corners.map(c => (proj((..c, z0)).at(2), proj((..c, z1)).at(2))).flatten()
    let near = calc.min(..corner-depths)
    let far = calc.max(..corner-depths)
    let size-at(p) = if far - near < 1e-9 { 1 } else {
      1 - strength * (proj(p).at(2) - near) / (far - near)
    }

    // Draw farthest first, so nearer vowels overlap farther ones
    for vp in vowel-points.sorted(key: vp => -proj(vp.pos).at(2)) {
      let (sx, sy) = to-screen(vp.pos)
      let k = size-at(vp.pos)
      circle((sx, sy), radius: scaled-line-thickness * 0.12 * k, fill: black, stroke: none)
      content(
        (sx + 0.15 * scale-factor * k, sy + 0.15 * scale-factor * k),
        anchor: "south-west",
        context text(
          size: scaled-font-size * k * 1pt,
          font: phonokit-font.get(),
          top-edge: "x-height",
          bottom-edge: "baseline",
          vp.vowel,
        ),
      )
    }
  })
}
