// Catalytic-cycle declarations, layout, and drawing.

#import "@preview/cetz:0.5.2"
#import "../validation.typ": (
  _color-type,
  _angle-type,
  _content-type,
  _invalid-input,
  _validate-number,
  _validate-positive-number,
  _validate-bool,
  _validate-offset,
)
#import "../molecule/abbreviations.typ": _abbreviated-layout, _orient-abbreviation-labels
#import "../styles.typ": (
  _resolve-foreground-theme,
  _resolve-molecule-appearance,
  _resolve-molecule-bond-length,
)
#import "../molecule/rendering.typ": _mirror-layout, _draw-molecule, _translate-layout, _molecule-bounds
#import "../molecule/api.typ": smiles, _typst-rotate, _typst-scale
#import "schemes.typ": mol, reaction
#import "../molecule/alignment.typ": _is-aligned-molecule

// ── Catalytic cycle ───────────────────────────────────────────────────────────

/// A transformation between two species on a catalytic cycle, consumed by
/// `cycle()`. Steps alternate with the species (`mol()`/content) items: the k-th
/// step is the arc from the k-th species to the next one around the ring.
///
/// - label (content): Name of the transformation, placed outside the arc.
/// - into (str / content): A reagent entering at this arc (drawn outside the
///   ring with a small merging arrow pointing inward), e.g. `ce("H2")` or a
///   `mol()`/`smiles()`. Default: none.
/// - out (str / content): A product leaving at this arc (drawn outside the ring
///   with an arrow pointing outward). Any content works, including a nested
///   `reaction()` to continue a branch from the released molecule. Default: none.
/// - bend (auto / float): Curvature of this step's into/out side arrow. `0`
///   is nearly radial; positive values bow with the cycle direction, negative
///   values flip the bow. Default: auto (uses cycle's reagent-bend).
/// - merge (bool): Draw the into/out arrow tangent to the arc, so it visually
///   fuses with the main cycle arrow instead of pointing at it. Default: false.
/// - rotation ("straight" / "auto" / angle): Cycle label rotation. "auto"
///   follows the step's circle angle while keeping text upright. Default: "straight".
/// - label-offset (array): (dx, dy) nudge for the label, in bond-length units.
/// - into-offset (array): (dx, dy) nudge for the into reagent and its arrow.
/// - out-offset (array): (dx, dy) nudge for the out reagent and its arrow.
/// -> dictionary  (consumed by `cycle()`)
#let step(
  label: none, into: none, out: none, bend: auto, merge: false, rotation: "straight",
  label-offset: (0, 0), into-offset: (0, 0), out-offset: (0, 0),
) = {
  if bend != auto {
    _validate-number(bend, "step bend")
  }
  _validate-bool(merge, "step merge")
  if (
    rotation not in ("straight", "auto")
      and type(rotation) != _angle-type
  ) {
    _invalid-input(
      "step rotation",
      "expected \"straight\", \"auto\", or an angle, got " + repr(rotation),
      "Choose a supported label rotation.",
    )
  }
  _validate-offset(label-offset, "step label-offset")
  _validate-offset(into-offset, "step into-offset")
  _validate-offset(out-offset, "step out-offset")
  for (argument-name, argument-value) in (("into", into), ("out", out)) {
    if (
      argument-value != none
        and type(argument-value) != str
        and type(argument-value) != _content-type
    ) {
      _invalid-input(
        "step " + argument-name,
        "expected none, a SMILES string, or content, got "
          + repr(argument-value),
        "Pass a SMILES string directly or render the reagent before passing it.",
      )
    }
  }
  (
    __cycle_step__: true,
    label: label,
    into: into,
    out: out,
    bend: bend,
    merge: merge,
    rotation: rotation,
    label-offset: label-offset,
    into-offset: into-offset,
    out-offset: out-offset,
  )
}

// Render a reagent spec (SMILES string or content) to content, for the small
// molecules that feed into or out of a cycle arc.
#let _render-cycle-reagent(spec, scale) = {
  if spec == none { none }
  else if type(spec) == str { smiles(spec, scale: scale) }
  else { spec }
}

#let _upright-angle(angle) = {
  if calc.cos(angle) < 0 { angle + 180deg } else { angle }
}

#let _cycle-label-rotation(rotation, midpoint-angle, direction) = {
  if rotation == "straight" {
    0deg
  } else if rotation == "auto" {
    _upright-angle(-(midpoint-angle + direction * 90deg))
  } else if type(rotation) == _angle-type {
    rotation
  } else {
    panic("step rotation must be \"straight\", \"auto\", or an angle")
  }
}

#let _cycle-reagent-angles(from-angle, to-angle, paired-reagents) = {
  let span-angle = to-angle - from-angle
  (
    incoming: if paired-reagents { from-angle + span-angle * 0.25 } else {
      from-angle + span-angle / 2
    },
    outgoing: if paired-reagents { from-angle + span-angle * 0.75 } else {
      from-angle + span-angle / 2
    },
  )
}

#let _cycle-reagent-control(start, end, tangent, bend, incoming) = {
  let bend-direction = if incoming { -1 } else { 1 }
  (
    (start.at(0) + end.at(0)) / 2
      + tangent.at(0) * bend * bend-direction * 2,
    (start.at(1) + end.at(1)) / 2
      + tangent.at(1) * bend * bend-direction * 2,
  )
}

/// Lays out a catalytic cycle: species arranged on a circle with arc arrows
/// between them. Items alternate species and `step()`s, like `reaction()`
/// alternates molecules and `rxn-arrow()`s, but the sequence closes into a ring
/// (the last step returns to the first species). Species are `mol()` items or any
/// content (SMILES strings and `align-molecules()` results are rendered by
/// `smiles()`); a `mol(label:)` is drawn under its species.
///
/// `step(label:)` names the transformation on an arc; `step(into:)` adds a reagent
/// merging into the arc from outside the ring, and `step(out:)` a product leaving
/// it. Because `step(out:)` accepts any content, passing a `reaction()` there grows
/// a full linear branch out of a released molecule.
///
/// - radius (auto / float): Ring radius in bond-length units. `auto` fits the
///   species without overlap. Default: auto.
/// - start (angle): Angle of the first species (0deg is east, 90deg north).
///   Default: 90deg.
/// - clockwise (bool): Travel direction around the ring. Default: true.
/// - scale (float): Uniform scale of species, arrows, and labels. Default: 1.0.
/// - reagent-scale (float): Scale of into/out reagents relative to the cycle species.
///   Default: 0.8.
/// - reagent-bend (float): Default curvature of into/out side arrows. `0`
///   is nearly radial. Default: 0.12.
/// - arc-gap (float): Clearance between a molecule and the arc-arrow ends, in
///   bond-length units beyond the molecule's radius. Smaller (even negative)
///   brings arrows closer to the species. Default: 0.15.
/// - arrow-color (color): Arc and merge arrow color. Default: black.
/// - label-color (auto / color): Step label color. Default: the maroon accent.
/// - breakable (bool): Whether the block may split across pages. Default: false.
/// - ..items: Species (`mol()`/content) and `step()`s in ring order.
/// -> content
#let cycle(
  radius: auto,
  start: 90deg,
  clockwise: true,
  scale: 1.0,
  reagent-scale: 0.8,
  reagent-bend: 0.12,
  arc-gap: 0.15,
  arrow-color: black,
  label-color: rgb("#8B2942"),
  breakable: false,
  ..items,
) = {
  let cycle-items = items.pos().map(item => if _is-aligned-molecule(item) { mol(item) } else { item })
  if radius != auto {
    _validate-positive-number(radius, "cycle radius")
  }
  if type(start) != _angle-type {
    _invalid-input(
      "cycle start",
      "expected an angle, got " + repr(start),
      "Pass an angle such as 90deg.",
    )
  }
  _validate-bool(clockwise, "cycle clockwise")
  _validate-positive-number(scale, "cycle scale")
  _validate-positive-number(reagent-scale, "cycle reagent-scale")
  _validate-number(reagent-bend, "cycle reagent-bend")
  _validate-number(arc-gap, "cycle arc-gap")
  if type(arrow-color) != _color-type {
    _invalid-input(
      "cycle arrow-color",
      "expected a color, got " + repr(arrow-color),
      "Pass a Typst color.",
    )
  }
  if label-color != auto and type(label-color) != _color-type {
    _invalid-input(
      "cycle label-color",
      "expected auto or a color, got " + repr(label-color),
      "Use label-color: auto or pass a Typst color.",
    )
  }
  _validate-bool(breakable, "cycle breakable")
  if cycle-items.len() == 0 {
    _invalid-input(
      "cycle items",
      "the cycle is empty",
      "Pass at least one molecular species or content item.",
    )
  }
  let is-step(item) = (
    type(item) == dictionary and item.at("__cycle_step__", default: false)
  )
  let is-molecule-item(item) = (
    type(item) == dictionary and item.at("__mol__", default: false)
  )

  // Split into species (in ring order) and the step that follows each species.
  let species = ()
  let arc-steps = ()
  for item in cycle-items {
    if is-step(item) {
      if species.len() == 0 {
        _invalid-input(
          "cycle step",
          "a step appears before the first species",
          "Place each step() after the species where its arc begins.",
        )
      }
      if arc-steps.len() >= species.len() {
        _invalid-input(
          "cycle step",
          "more than one step follows the same species",
          "Place at most one step() between consecutive species.",
        )
      }
      arc-steps.push(item)
    } else {
      if (
        type(item) != str
          and type(item) != _content-type
          and not is-molecule-item(item)
      ) {
        _invalid-input(
          "cycle species",
          "expected a SMILES string, content, or mol(), got " + repr(item),
          "Pass a renderable species item.",
        )
      }
      // Pad a missing step for the previous species before starting a new one.
      while arc-steps.len() < species.len() {
        arc-steps.push(step())
      }
      species.push(item)
    }
  }
  while arc-steps.len() < species.len() { arc-steps.push(step()) }

  let species-count = species.len()

  let canvas-scale = 30pt
  let step-angle = 360deg / species-count
  let direction = if clockwise { -1 } else { 1 }
  let species-angle(index) = start + direction * index * step-angle

  context {
    // Measure each species so the ring can be sized and molecules centered.
    let placed = ()
    let maximum-diagonal = 0.0
    for species-item in species {
      let molecule-item = if is-molecule-item(species-item) {
        species-item
      } else {
        (
          __mol__: true,
          spec: species-item,
          label: none,
          offset: (0, 0),
          opts: (:),
        )
      }
      let molecule-scale = molecule-item.opts.at("scale", default: 1.0)
      let (
        bounds,
        molecule-bounds,
        kind,
        payload,
        bond-scale,
        resolved-bond-length,
        stroke-units,
      ) = if type(molecule-item.spec) == str {
        let effective-bond-length = _resolve-molecule-bond-length(
          molecule-item.opts,
          molecule-scale,
        )
        let bond-scale = if effective-bond-length == none {
          molecule-scale
        } else {
          effective-bond-length
        }
        let molecule-rotation = molecule-item.opts.at("rotation", default: 0deg)
        let molecule-layout = _orient-abbreviation-labels(
          _translate-layout(
            _mirror-layout(
              _abbreviated-layout(
                molecule-item.spec,
                molecule-item.opts.at("abbreviate", default: none),
                "mol abbreviate",
              ),
              molecule-item.opts.at("mirror", default: none),
              rotation: molecule-rotation,
            ),
            molecule-item.at("alignment-offset", default: (0, 0)),
          ),
          molecule-rotation,
        )
        let molecule-appearance = _resolve-molecule-appearance(
          molecule-item.opts,
          molecule-scale,
        )
        let measurement-options = molecule-item.opts
        measurement-options.insert("scale", molecule-scale)
        measurement-options.insert("font-size", molecule-appearance.font-size)
        measurement-options.insert("font", molecule-appearance.font)
        measurement-options.insert("bond-stroke", molecule-appearance.bond-stroke)
        if effective-bond-length != none {
          measurement-options.insert("bond-length", effective-bond-length)
        }
        let measured-molecule = measure(
          smiles(molecule-item.spec, ..measurement-options),
        )
        let molecule-bounds = _molecule-bounds(
          molecule-layout,
          molecule-rotation,
          bond-scale,
          measured-molecule.width / canvas-scale,
          measured-molecule.height / canvas-scale,
          options: measurement-options,
          canvas-scale: canvas-scale,
        )
        let bounds = molecule-bounds
        if molecule-item.label != none {
          let caption-size = measure(molecule-item.label)
          bounds.left = calc.max(bounds.left, caption-size.width / (2 * canvas-scale))
          bounds.right = calc.max(bounds.right, caption-size.width / (2 * canvas-scale))
          bounds.bottom += caption-size.height / canvas-scale + 0.34
        }
        (
          bounds,
          molecule-bounds,
          "mol",
          molecule-layout,
          bond-scale,
          effective-bond-length,
          molecule-appearance.bond-stroke / canvas-scale,
        )
      } else {
        let measured-content = measure(molecule-item.spec)
        let molecule-bounds = (
          left: measured-content.width / (2 * canvas-scale),
          right: measured-content.width / (2 * canvas-scale),
          bottom: measured-content.height / (2 * canvas-scale),
          top: measured-content.height / (2 * canvas-scale),
        )
        let bounds = molecule-bounds
        if molecule-item.label != none {
          let caption-size = measure(molecule-item.label)
          bounds.left = calc.max(bounds.left, caption-size.width / (2 * canvas-scale))
          bounds.right = calc.max(bounds.right, caption-size.width / (2 * canvas-scale))
          bounds.bottom += caption-size.height / canvas-scale + 0.34
        }
        (
          bounds,
          molecule-bounds,
          "content",
          molecule-item.spec,
          1.0,
          none,
          0.0,
        )
      }
      let width = bounds.left + bounds.right
      let height = bounds.bottom + bounds.top
      maximum-diagonal = calc.max(
        maximum-diagonal,
        calc.sqrt(width * width + height * height),
      )
      placed.push((
        m: molecule-item,
        w: width,
        h: height,
        bounds: bounds,
        kind: kind,
        payload: payload,
        molecule-bounds: molecule-bounds,
        resolved-bond-length: resolved-bond-length,
        bond-scale: bond-scale,
        stroke-units: stroke-units,
      ))
    }

    // Fit the ring: adjacent species centers must clear their bounding boxes.
    let cycle-radius = if radius != auto {
      radius
    } else if species-count == 1 {
      0.0
    } else {
      calc.max(
        2.0,
        (maximum-diagonal + 1.1)
          / (2 * calc.sin(calc.pi / species-count)),
      )
    }

    let point-on-circle(angle, radial-distance) = (
      radial-distance * calc.cos(angle),
      radial-distance * calc.sin(angle),
    )
    let offset-point(point, offset) = (
      point.at(0) + offset.at(0),
      point.at(1) + offset.at(1),
    )
    // Angular clearance finds where the curved path leaves the rendered
    // molecule bounds on the outgoing or incoming side of each species.
    let angular-clearance(index, path-direction) = if cycle-radius > 0.01 {
      let placed-item = placed.at(index)
      let angle = species-angle(index)
      let stroke-clearance = calc.max(
        placed-item.stroke-units / 2,
        0.9pt / canvas-scale / 2,
      )
      let margin = arc-gap + stroke-clearance + 0.16
      let is-inside-visible-bounds(delta) = {
        let path-angle = angle + path-direction * delta
        let point = point-on-circle(path-angle, cycle-radius)
        let center = point-on-circle(angle, cycle-radius)
        let x = point.at(0) - center.at(0)
        let y = point.at(1) - center.at(1)
        (x >= -placed-item.bounds.left - margin
          and x <= placed-item.bounds.right + margin
          and y >= -placed-item.bounds.bottom - margin
          and y <= placed-item.bounds.top + margin)
      }
      if not is-inside-visible-bounds(0deg) {
        0deg
      } else {
        let maximum-angle = step-angle * 0.49
        let lower-angle = 0deg
        let upper-angle = none
        for sample-index in range(1, 65) {
          if upper-angle != none { continue }
          let sample-angle = maximum-angle * sample-index / 64
          if not is-inside-visible-bounds(sample-angle) {
            upper-angle = sample-angle
          } else {
            lower-angle = sample-angle
          }
        }
        if upper-angle == none {
          _invalid-input(
            "cycle radius",
            repr(radius) + " leaves no clear arc after species " + str(index),
            "Increase radius or reduce the species label size so an arc can clear the rendered bounds.",
          )
        }
        for _ in range(12) {
          let midpoint = (lower-angle + upper-angle) / 2
          if is-inside-visible-bounds(midpoint) {
            lower-angle = midpoint
          } else {
            upper-angle = midpoint
          }
        }
        upper-angle
      }
    } else { 0deg }
    let outgoing-clearances = range(species-count).map(index => (
      angular-clearance(index, direction)
    ))
    let incoming-clearances = range(species-count).map(index => (
      angular-clearance(index, -direction)
    ))
    let visible-arc-lengths = range(species-count).map(step-index => {
      let from-clearance = outgoing-clearances.at(step-index)
      let to-clearance = incoming-clearances.at(
        calc.rem(step-index + 1, species-count),
      )
      cycle-radius * (step-angle - from-clearance - to-clearance) / 1rad
    })
    for (step-index, visible-arc-length) in visible-arc-lengths.enumerate() {
      if cycle-radius > 0.01 and visible-arc-length <= 0.16 + 0.9pt / canvas-scale {
        _invalid-input(
          "cycle radius",
          repr(radius) + " leaves no visible arrow at step " + str(step-index),
          "Increase radius or reduce the species label size to leave room for the arc arrow.",
        )
      }
    }

    let canvas = cetz.canvas(length: canvas-scale, {
      import cetz.draw: *

      // Arc arrows between consecutive species, with labels and reagents.
      for step-index in range(species-count) {
        let from-species-angle = species-angle(step-index)
        let to-species-angle = species-angle(step-index + 1)
        let cycle-step = arc-steps.at(step-index)
        let from-clearance = outgoing-clearances.at(step-index)
        let to-clearance = incoming-clearances.at(
          calc.rem(step-index + 1, species-count),
        )
        let from-angle = (
          from-species-angle + direction * from-clearance
        )
        let to-angle = (
          to-species-angle - direction * to-clearance
        )
        let segment-count = 24
        let points = range(segment-count + 1).map(segment-index => {
          let angle = (
            from-angle
              + (to-angle - from-angle) * (segment-index / segment-count)
          )
          point-on-circle(angle, cycle-radius)
        })
        line(
          ..points,
          mark: (end: ">", fill: arrow-color, size: 0.16),
          stroke: 0.9pt + arrow-color,
        )

        let midpoint-angle = (
          from-species-angle + direction * step-angle / 2
        )
        let bend = if cycle-step.bend == auto {
          reagent-bend
        } else {
          cycle-step.bend
        }
        let paired-reagents = cycle-step.into != none and cycle-step.out != none
        let reagent-angles = _cycle-reagent-angles(
          from-angle,
          to-angle,
          paired-reagents,
        )
        let incoming-angle = reagent-angles.incoming
        let outgoing-angle = reagent-angles.outgoing
        // Unit tangent along the arc's travel direction at its midpoint.
        let travel-direction = (
          direction * -calc.sin(midpoint-angle),
          direction * calc.cos(midpoint-angle),
        )
        if cycle-step.label != none {
          let has-reagent = cycle-step.into != none or cycle-step.out != none
          let label-radius = if has-reagent and cycle-radius > 1.3 {
            calc.max(0.55, cycle-radius - 1.05)
          } else {
            cycle-radius + 0.95
          }
          let label-body = text(
            size: 9pt,
            fill: if label-color == auto { black } else { label-color },
            cycle-step.label,
          )
          let label-rotation = _cycle-label-rotation(
            cycle-step.rotation,
            midpoint-angle,
            direction,
          )
          if label-rotation != 0deg {
            label-body = _typst-rotate(label-rotation, reflow: false, label-body)
          }
          content(
            offset-point(
              point-on-circle(midpoint-angle, label-radius),
              cycle-step.label-offset,
            ),
            label-body,
            anchor: "center",
          )
        }

        // Metrics for an into/out reagent placed radially outward from the
        // arc, offset by its own measured extent so wide content (even a
        // nested reaction) clears the ring, then nudged by a per-step offset.
        // Pure: returns coords, draws nothing.
        let reagent-metrics(specification, extra-offset, attachment-angle) = {
          let body = _render-cycle-reagent(
            specification,
            reagent-scale,
          )
          if body == none {
            none
          } else {
            let measured-body = measure(body)
            let width = measured-body.width / canvas-scale
            let height = measured-body.height / canvas-scale
            let radial-half-extent = 0.5 * (
              calc.abs(width * calc.cos(attachment-angle))
                + calc.abs(height * calc.sin(attachment-angle))
            )
            // Floor keeps small reagents at a fixed clearance; large content
            // (e.g. a nested reaction) is pushed out by its own extent.
            let distance = (
              cycle-radius + calc.max(2.05, 1.0 + radial-half-extent)
            )
            (
              body: body,
              center: offset-point(
                point-on-circle(attachment-angle, distance),
                extra-offset,
              ),
              w: width,
              h: height,
            )
          }
        }

        let reagent-anchor-for(angle) = {
          let direction-x = calc.cos(angle)
          let direction-y = calc.sin(angle)
          let axis-threshold = 0.12
          let horizontal-anchor = if direction-x > axis-threshold {
            "west"
          } else if direction-x < -axis-threshold {
            "east"
          } else {
            ""
          }
          let vertical-anchor = if direction-y > axis-threshold {
            "south"
          } else if direction-y < -axis-threshold {
            "north"
          } else {
            ""
          }
          if horizontal-anchor != "" and vertical-anchor != "" {
            vertical-anchor + "-" + horizontal-anchor
          }
          else if horizontal-anchor != "" { horizontal-anchor }
          else if vertical-anchor != "" { vertical-anchor }
          else { "center" }
        }

        let anchor-point(center, width, height, anchor) = {
          let center-x = center.at(0)
          let center-y = center.at(1)
          if anchor == "west" { (center-x - width / 2, center-y) }
          else if anchor == "east" { (center-x + width / 2, center-y) }
          else if anchor == "north" { (center-x, center-y + height / 2) }
          else if anchor == "south" { (center-x, center-y - height / 2) }
          else if anchor == "north-west" {
            (center-x - width / 2, center-y + height / 2)
          }
          else if anchor == "north-east" {
            (center-x + width / 2, center-y + height / 2)
          }
          else if anchor == "south-west" {
            (center-x - width / 2, center-y - height / 2)
          }
          else if anchor == "south-east" {
            (center-x + width / 2, center-y - height / 2)
          }
          else { center }
        }

        // Reagent merging in: arrow from the reagent toward the arc. In merge
        // mode the arrow ends on the arc pointing along the travel direction,
        // so it fuses with the main cycle arrow; otherwise it points radially.
        let incoming-reagent = reagent-metrics(
          cycle-step.into,
          cycle-step.into-offset,
          incoming-angle,
        )
        if incoming-reagent != none {
          let incoming-anchor = reagent-anchor-for(incoming-angle)
          let incoming-attachment = anchor-point(
            incoming-reagent.center,
            incoming-reagent.w,
            incoming-reagent.h,
            incoming-anchor,
          )
          content(
            incoming-attachment,
            incoming-reagent.body,
            anchor: incoming-anchor,
          )
          if cycle-step.merge {
            // Fuse smoothly into the main arc: the curve arrives tangent to the
            // arc with no arrowhead, so it reads as one continuous stroke.
            let tip = point-on-circle(incoming-angle, cycle-radius)
            let tangent = (
              direction * -calc.sin(incoming-angle),
              direction * calc.cos(incoming-angle),
            )
            bezier(
              incoming-attachment,
              tip,
              (
                tip.at(0) - tangent.at(0) * 0.5,
                tip.at(1) - tangent.at(1) * 0.5,
              ),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            let tip = point-on-circle(incoming-angle, cycle-radius)
            let tangent = (
              direction * -calc.sin(incoming-angle),
              direction * calc.cos(incoming-angle),
            )
            let incoming-control = _cycle-reagent-control(
              incoming-attachment,
              tip,
              tangent,
              bend,
              true,
            )
            bezier(
              incoming-attachment,
              tip,
              incoming-control,
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          }
        }

        // Product leaving: arrow from the arc outward to the reagent. In merge
        // mode it peels off the arc tangentially.
        let outgoing-reagent = reagent-metrics(
          cycle-step.out,
          cycle-step.out-offset,
          outgoing-angle,
        )
        if outgoing-reagent != none {
          let outgoing-anchor = reagent-anchor-for(outgoing-angle)
          let outgoing-attachment = anchor-point(
            outgoing-reagent.center,
            outgoing-reagent.w,
            outgoing-reagent.h,
            outgoing-anchor,
          )
          content(
            outgoing-attachment,
            outgoing-reagent.body,
            anchor: outgoing-anchor,
          )
          if cycle-step.merge {
            // Peel off the arc tangentially, keeping the arrowhead on the
            // departing product.
            let arc-point = point-on-circle(outgoing-angle, cycle-radius)
            let tangent = (
              direction * -calc.sin(outgoing-angle),
              direction * calc.cos(outgoing-angle),
            )
            bezier(
              arc-point,
              outgoing-attachment,
              (
                arc-point.at(0) + tangent.at(0) * 0.5,
                arc-point.at(1) + tangent.at(1) * 0.5,
              ),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            let arc-point = point-on-circle(outgoing-angle, cycle-radius)
            let tangent = (
              direction * -calc.sin(outgoing-angle),
              direction * calc.cos(outgoing-angle),
            )
            let outgoing-control = _cycle-reagent-control(
              arc-point,
              outgoing-attachment,
              tangent,
              bend,
              false,
            )
            bezier(
              arc-point,
              outgoing-attachment,
              outgoing-control,
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          }
        }
      }

      // Species on the ring, drawn on top of the arcs.
      for species-index in range(species-count) {
        let placed-item = placed.at(species-index)
        let center = point-on-circle(
          species-angle(species-index),
          cycle-radius,
        )
        if placed-item.kind == "mol" {
          group({
            translate(center)
            if placed-item.bond-scale != 1.0 { scale(placed-item.bond-scale) }
            let molecule-scale = placed-item.m.opts.at("scale", default: 1.0)
            let molecule-appearance = _resolve-molecule-appearance(
              placed-item.m.opts,
              molecule-scale,
            )
            let (molecule-foreground, molecule-theme) = _resolve-foreground-theme(
              placed-item.m.opts.at("fg", default: auto),
              placed-item.m.opts.at("theme", default: auto),
            )
            _draw-molecule(
              placed-item.payload,
              scale: molecule-scale,
              bond-length: placed-item.resolved-bond-length,
              font-size: molecule-appearance.font-size,
              font: molecule-appearance.font,
              bond-stroke: molecule-appearance.bond-stroke,
              color: molecule-appearance.color,
              rotation: placed-item.m.opts.at("rotation", default: 0deg),
              show-h: placed-item.m.opts.at("show-h", default: ()),
              lone-pairs: placed-item.m.opts.at("lone-pairs", default: none),
              atom-colors: placed-item.m.opts.at("atom-colors", default: (:)),
              show-indices: placed-item.m.opts.at(
                "show-indices",
                default: false,
              ),
              fg: molecule-foreground,
              theme: molecule-theme,
              aromatic: placed-item.m.opts.at("aromatic", default: "kekule"),
              charge-style: placed-item.m.opts.at("charge-style", default: "plain"),
              atom-annotations: placed-item.m.opts.at(
                "atom-annotations",
                default: (),
              ),
              opacity: placed-item.m.opts.at("opacity", default: 100%),
              bond-customizations: placed-item.m.opts.at(
                "bond-customizations",
                default: (),
              ),
              show-maps: placed-item.m.opts.at("show-maps", default: false),
              undepicted-stereo: placed-item.m.opts.at(
                "undepicted-stereo",
                default: "error",
              ),
            )
          })
        } else {
          content(center, placed-item.payload, anchor: "center")
        }
        if placed-item.m.label != none {
          content(
            (
              center.at(0),
              center.at(1) - placed-item.molecule-bounds.bottom - 0.34,
            ),
            placed-item.m.label,
            anchor: "north",
          )
        }
      }
    })

    let scaled-canvas = if scale == 1.0 {
      canvas
    } else {
      _typst-scale(
        x: scale * 100%,
        y: scale * 100%,
        reflow: true,
        canvas,
      )
    }
    block(breakable: breakable, scaled-canvas)
  }
}
