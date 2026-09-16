// Molecular-orbital diagrams rendered as ordinary scenery 2D scenes.

#import "@preview/scenery:0.1.0" as scenery
#import "model.typ": bond-order

#let _role-color(role) = if role == "bonding" {
  rgb("#275d9a")
} else if role == "antibonding" {
  rgb("#b33a3a")
} else {
  luma(70)
}

/// Build a composable scenery scene from a validated `mo-model`.
#let mo-scene(
  model,
  column-gap: 3.4,
  level-width: 1.35,
  orbital-gap: 0.12,
  energy-height: 7.2,
  electron-height: 0.38,
  energy-axis: true,
  show-bond-order: true,
  spin-up-color: rgb("#1d4f91"),
  spin-down-color: rgb("#b1262d"),
) = {
  assert(type(model) == dictionary and model.at("kind", default: none) == "mo-model",
    message: "materia: mo-scene expects an mo-model")
  assert(column-gap > level-width,
    message: "materia: column-gap must be larger than level-width")

  let levels = ()
  for column in model.columns { levels += column.levels }
  let emin = calc.min(..levels.map(level => level.energy))
  let emax = calc.max(..levels.map(level => level.energy))
  let span = calc.max(emax - emin, 1e-9)
  let y-of(energy) = 0.7 + (energy - emin) / span * energy-height

  // Record each level's centre and full line extent before emitting anything,
  // so correlations can be drawn behind the levels and electron arrows.
  let positions = (:)
  for (column-index, column) in model.columns.enumerate() {
    let x = column-index * column-gap
    for level in column.levels {
      positions.insert(level.id, (
        x: x,
        y: y-of(level.energy),
        left: x - level-width / 2,
        right: x + level-width / 2,
      ))
    }
  }

  let prims = ()
  for correlation in model.correlations {
    let a = positions.at(correlation.at("from"))
    let b = positions.at(correlation.at("to"))
    let (xa, xb) = if a.x < b.x { (a.right, b.left) } else { (a.left, b.right) }
    let line-color = if correlation.color == auto { luma(155) } else { correlation.color }
    prims.push(scenery.edge(
      (xa, a.y),
      (xb, b.y),
      color: line-color,
      width: 0.65pt,
      dash: "dashed",
    ))
  }

  for (column-index, column) in model.columns.enumerate() {
    let x = column-index * column-gap
    prims.push(scenery.label((x, 0), column.label, size: 8pt))
    for level in column.levels {
      let y = y-of(level.energy)
      let level-color = if level.color != auto { level.color }
        else if column.color != auto { column.color }
        else { _role-color(level.role) }
      let orbit-width = (
        level-width - (level.degeneracy - 1) * orbital-gap
      ) / level.degeneracy
      let left = x - level-width / 2

      for orbital-index in range(level.degeneracy) {
        let lane-left = left + orbital-index * (orbit-width + orbital-gap)
        let lane-right = lane-left + orbit-width
        let lane-x = (lane-left + lane-right) / 2
        prims.push(scenery.edge(
          (lane-left, y),
          (lane-right, y),
          color: level-color,
          width: 1.15pt,
        ))

        let has-up = orbital-index < calc.min(level.occupation, level.degeneracy)
        let has-down = orbital-index < calc.max(level.occupation - level.degeneracy, 0)
        if has-up {
          let up-x = lane-x - if has-down { 0.055 } else { 0 }
          prims.push(scenery.arrow(
            (up-x, y + 0.035),
            (up-x, y + electron-height),
            color: spin-up-color,
            w: 0.018,
            head-scale: 28,
          ))
        }
        if has-down {
          prims.push(scenery.arrow(
            (lane-x + 0.055, y + electron-height),
            (lane-x + 0.055, y + 0.035),
            color: spin-down-color,
            w: 0.018,
            head-scale: 28,
          ))
        }
      }

      prims.push(scenery.label(
        (x, y - 0.28),
        level.label,
        color: level-color,
        size: 6.5pt,
        weight: "regular",
      ))
    }
  }

  if energy-axis {
    let axis-x = -1.35
    let top = 0.7 + energy-height + 0.45
    prims.push(scenery.arrow(
      (axis-x, 0.55),
      (axis-x, top),
      color: luma(60),
      w: 0.022,
      head-scale: 28,
    ))
    prims.push(scenery.label((axis-x - 0.45, (0.55 + top) / 2),
      rotate(-90deg, reflow: true, model.energy-label),
      size: 7pt, weight: "regular"))
  }

  if show-bond-order {
    let right = (model.columns.len() - 1) * column-gap + level-width / 2
    prims.push(scenery.label(
      (right, -0.62),
      [bond order = #bond-order(model)],
      size: 7pt,
      weight: "regular",
    ))
  }

  scenery.build-scene(..prims)
}

/// Render a molecular-orbital model as a standalone figure.
#let mo-diagram(
  model,
  width: 11cm,
  theme: scenery.default-theme,
  ..options,
) = scenery.render-scene(
  mo-scene(model, ..options),
  scenery.camera-2d(),
  width: width,
  theme: theme,
)
