// One cut-out tile: the dice rolls behind its look, the geometry of its ragged
// scissor cut, and the drawing of a few printed characters on it.

#import "rng.typ"

// ==========================================================================
// Look
//
// Everything about a tile that is left to chance. Keeping the dice rolls apart
// from the drawing code means a tile's look depends only on its state.

#let _scalars = 7
#let _coordinates = 16

/// Rolls the look of one tile.
///
/// `cfg` carries the user's options: `faces`, `palette`, `scale` (a pair of
/// floats), `tilt` (an angle), `sway` and `backing` (floats).
#let roll-look(state, cfg) = {
  let u = rng.draws(state, _scalars + _coordinates)
  (
    face: rng.pick(cfg.faces, u.at(0)),
    paper: rng.pick-weighted(cfg.palette, u.at(1)),
    shout: u.at(2) < 0.5,
    scale: rng.between(u.at(3), ..cfg.scale),
    angle: rng.between(u.at(4), -cfg.tilt, cfg.tilt),
    sway: rng.between(u.at(5), -1, 1) * cfg.sway,
    backing: u.at(6) < cfg.backing,
    jitter: u.slice(_scalars).map(x => 2 * x - 1),
  )
}

// ==========================================================================
// Geometry
//
// The outline of a scissor cut: a rectangle whose edges wobble a little.

#let _anchors = (
  (0, 0), (0.5, 0), (1, 0), (1, 0.5),
  (1, 1), (0.5, 1), (0, 1), (0, 0.5),
)

/// Returns the outline of a `w` × `h` cut as an array of `(x, y)` points.
///
/// `jitter` holds one number in -1…1 per coordinate (16 in total) and `reach`
/// is the largest distance a corner may stray from the perfect rectangle.
/// Edge midpoints stray half as far, which keeps the cut looking like one
/// confident snip of the scissors rather than noise.
#let _outline(w, h, jitter, reach) = _anchors.enumerate().map(((i, (fx, fy))) => {
  let amount = if calc.even(i) { reach } else { reach / 2 }
  (
    w * fx + jitter.at(2 * i) * amount,
    h * fy + jitter.at(2 * i + 1) * amount,
  )
})

/// Draws `points` as a filled shape, positioned so that the point (0, 0) sits
/// at the top-left of the enclosing box (shifted by `dx` / `dy`).
///
/// Typst places a polygon by its bounding box, so every point is moved by
/// `reach` to keep all coordinates non-negative, and the shape is moved back.
#let _paint(points, reach, fill, dx: 0pt, dy: 0pt) = place(
  top + left,
  dx: dx - reach,
  dy: dy - reach,
  polygon(
    fill: fill,
    stroke: none,
    ..points.map(((x, y)) => (x + reach, y + reach)),
  ),
)

// ==========================================================================
// Drawing

#let _backing = rgb("#faf8f1")
#let _shadow = rgb("#000000").transparentize(78%)

/// Selects ordinary document text, but never the printed labels of tiles.
///
/// A show rule that turns text into tiles would otherwise match the text
/// inside its own tiles forever. Tile labels are therefore set with
/// `overhang: false` (invisible on a single line of glyphs), which ordinary
/// text almost never is, and `ransom-note` only matches text where it is on.
#let document-text = text.where(overhang: true)

/// Draws `label` on a scrap of paper, following the look given by `spec`.
///
/// Must be called where `context` is available, because the scrap is sized to
/// fit the measured glyphs.
///
/// - label (str): the characters to print.
/// - spec (dictionary): the tile's look, as produced by `roll-look`.
/// - size (length): the base font size; the spec scales it per tile.
/// - ragged (float): cut roughness as a fraction of the font size.
/// - shadow (bool): whether the scrap casts a soft shadow.
#let cutout(label, spec, size: 12pt, ragged: 0.07, shadow: true) = {
  let font-size = size * spec.scale

  // `bounds` hugs the real ink of the glyphs, so a full stop gets a tiny scrap
  // and a capital Q a tall one – just like cutting letters out of a page.
  let print(bottom-edge) = text(
    font: spec.face.font,
    weight: spec.face.weight,
    style: spec.face.style,
    size: font-size,
    fill: spec.paper.ink,
    top-edge: "bounds",
    bottom-edge: bottom-edge,
    overhang: false, // marks this as a tile label, see `document-text`
    label,
  )
  let glyphs = print("bounds")
  let ink = measure(glyphs)
  let w = calc.max(ink.width + 0.26 * font-size, 0.6 * font-size)
  let h = calc.max(ink.height + 0.26 * font-size, 0.85 * font-size)

  // How far the ink reaches below the writing baseline. Negative for marks
  // that float above it, such as an apostrophe.
  let drop = ink.height - measure(print("baseline")).height

  let reach = font-size * ragged
  let margin = font-size * 0.09
  let points = _outline(w, h, spec.jitter, reach)

  let scrap = box(width: w, height: h, {
    if shadow {
      _paint(points, reach, _shadow, dx: font-size * 0.04, dy: font-size * 0.07)
    }
    if spec.backing {
      let wide = _outline(w + 2 * margin, h + 2 * margin, spec.jitter, reach)
      _paint(wide, reach, _backing, dx: -margin, dy: -margin)
    }
    _paint(points, reach, spec.paper.fill)
    place(center + horizon, glyphs)
  })

  // Rotating without reflow lets neighbouring scraps overlap a little, which
  // is what glued-down paper does. The box baseline then lowers the scrap until
  // the glyphs sit on the line, plus the scrap's own random sway.
  box(
    baseline: (h - ink.height) / 2 + drop + spec.sway * size,
    rotate(spec.angle, scrap, reflow: false),
  )
}
