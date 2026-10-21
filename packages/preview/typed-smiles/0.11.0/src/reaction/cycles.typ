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
#import "../chemistry.typ": _compute-layout
#import "../styles.typ": _resolve-foreground-theme
#import "../molecule/rendering.typ": _mirror-layout, _draw-molecule
#import "../molecule/api.typ": smiles, _typst-rotate
#import "schemes.typ": mol, reaction

// ── Catalytic cycle ───────────────────────────────────────────────────────────

/// A transformation between two species on a catalytic cycle, consumed by
/// #cycle(). Steps alternate with the species (mol()/content) items: the k-th
/// step is the arc from the k-th species to the next one around the ring.
///
/// - label (content): Name of the transformation, placed outside the arc.
/// - into (str / content): A reagent entering at this arc (drawn outside the
///   ring with a small merging arrow pointing inward), e.g. ce("H2") or a
///   mol()/smiles(). Default: none.
/// - out (str / content): A product leaving at this arc (drawn outside the ring
///   with an arrow pointing outward). Any content works, including a nested
///   reaction() to continue a branch from the released molecule. Default: none.
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
/// -> dictionary  (consumed by #cycle)
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

#let _cycle-label-rotation(rotation, midpoint-angle) = {
  if rotation == "straight" {
    0deg
  } else if rotation == "auto" {
    _upright-angle(midpoint-angle)
  } else if type(rotation) == _angle-type {
    rotation
  } else {
    panic("step rotation must be \"straight\", \"auto\", or an angle")
  }
}

/// Lays out a catalytic cycle: species arranged on a circle with arc arrows
/// between them. Items alternate species and step()s, like #reaction()
/// alternates molecules and rxn-arrow()s, but the sequence closes into a ring
/// (the last step returns to the first species). Species are mol() items or any
/// content (SMILES strings are rendered by #smiles); a mol(label:) is drawn
/// under its species.
///
/// step(label:) names the transformation on an arc; step(into:) adds a reagent
/// merging into the arc from outside the ring, and step(out:) a product leaving
/// it. Because step(out:) accepts any content, passing a reaction() there grows
/// a full linear branch out of a released molecule.
///
/// - radius (auto / float): Ring radius in bond-length units. `auto` fits the
///   species without overlap. Default: auto.
/// - start (angle): Angle of the first species (0deg is east, 90deg north).
///   Default: 90deg.
/// - clockwise (bool): Travel direction around the ring. Default: true.
/// - scale (float): Uniform scale; sets the canvas bond length. Default: 1.0.
/// - reagent-scale (float): Scale of into/out reagents relative to `scale`.
///   Default: 0.8.
/// - reagent-bend (float): Default curvature of into/out side arrows. `0`
///   is nearly radial. Default: 0.12.
/// - arc-gap (float): Clearance between a molecule and the arc-arrow ends, in
///   bond-length units beyond the molecule's radius. Smaller (even negative)
///   brings arrows closer to the species. Default: 0.15.
/// - arrow-color (color): Arc and merge arrow color. Default: black.
/// - label-color (auto / color): Step label color. Default: the maroon accent.
/// - breakable (bool): Whether the block may split across pages. Default: false.
/// - ..items: Species (mol()/content) and step()s in ring order.
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
  let cycle-items = items.pos()
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

  let canvas-scale = scale * 30pt
  let molecule-scale = scale
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
      let (width, height, kind, payload) = if type(molecule-item.spec) == str {
        let molecule-layout = _mirror-layout(
          _compute-layout(molecule-item.spec),
          molecule-item.opts.at("mirror", default: none),
          rotation: molecule-item.opts.at("rotation", default: 0deg),
        )
        (molecule-layout.bbox_width, molecule-layout.bbox_height, "mol", molecule-layout)
      } else {
        let measured-content = measure(molecule-item.spec)
        (
          measured-content.width / canvas-scale,
          measured-content.height / canvas-scale,
          "content",
          molecule-item.spec,
        )
      }
      maximum-diagonal = calc.max(
        maximum-diagonal,
        calc.sqrt(width * width + height * height),
      )
      placed.push((
        m: molecule-item,
        w: width,
        h: height,
        kind: kind,
        payload: payload,
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
    // Per-species angular clearance: an arc retreats from each molecule by that
    // molecule's own reach in the tangential (arc-approach) direction, plus
    // arc-gap. This keeps the visible gap uniform whether a wide molecule sits
    // at the top (approached across its width) or the side (across its height).
    let angular-clearance(index) = if cycle-radius > 0.01 {
      let placed-item = placed.at(index)
      let angle = species-angle(index)
      let tangential-reach = (
        placed-item.w / 2 * calc.abs(calc.sin(angle))
          + placed-item.h / 2 * calc.abs(calc.cos(angle))
      )
      calc.min(
        step-angle * 0.45,
        calc.max(
          0deg,
          1.0rad * (tangential-reach + arc-gap) / cycle-radius,
        ),
      )
    } else { 0deg }

    let canvas = cetz.canvas(length: canvas-scale, {
      import cetz.draw: *

      // Arc arrows between consecutive species, with labels and reagents.
      for step-index in range(species-count) {
        let from-species-angle = species-angle(step-index)
        let to-species-angle = species-angle(step-index + 1)
        let cycle-step = arc-steps.at(step-index)
        let from-angle = (
          from-species-angle + direction * angular-clearance(step-index)
        )
        let to-angle = (
          to-species-angle
            - direction * angular-clearance(
              calc.rem(step-index + 1, species-count),
            )
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
        let reagent-metrics(specification, extra-offset) = {
          let body = _render-cycle-reagent(
            specification,
            molecule-scale * reagent-scale,
          )
          if body == none {
            none
          } else {
            let measured-body = measure(body)
            let width = measured-body.width / canvas-scale
            let height = measured-body.height / canvas-scale
            let radial-half-extent = 0.5 * (
              calc.abs(width * calc.cos(midpoint-angle))
                + calc.abs(height * calc.sin(midpoint-angle))
            )
            // Floor keeps small reagents at a fixed clearance; large content
            // (e.g. a nested reaction) is pushed out by its own extent.
            let distance = (
              cycle-radius + calc.max(2.05, 1.0 + radial-half-extent)
            )
            (
              body: body,
              center: offset-point(
                point-on-circle(midpoint-angle, distance),
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
        )
        if incoming-reagent != none {
          let incoming-anchor = reagent-anchor-for(midpoint-angle)
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
            let tip = point-on-circle(midpoint-angle, cycle-radius)
            bezier(
              incoming-attachment,
              tip,
              (
                tip.at(0) - travel-direction.at(0) * 0.5,
                tip.at(1) - travel-direction.at(1) * 0.5,
              ),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            bezier(
              incoming-attachment,
              point-on-circle(midpoint-angle, cycle-radius + 0.28),
              point-on-circle(
                midpoint-angle + direction * step-angle * bend,
                cycle-radius + 1.05,
              ),
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
        )
        if outgoing-reagent != none {
          let outgoing-anchor = reagent-anchor-for(midpoint-angle)
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
            let arc-point = point-on-circle(midpoint-angle, cycle-radius)
            bezier(
              arc-point,
              outgoing-attachment,
              (
                arc-point.at(0) + travel-direction.at(0) * 0.5,
                arc-point.at(1) + travel-direction.at(1) * 0.5,
              ),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            bezier(
              point-on-circle(midpoint-angle, cycle-radius + 0.28),
              outgoing-attachment,
              point-on-circle(
                midpoint-angle - direction * step-angle * bend,
                cycle-radius + 1.05,
              ),
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
            let (molecule-foreground, molecule-theme) = _resolve-foreground-theme(
              placed-item.m.opts.at("fg", default: auto),
              placed-item.m.opts.at("theme", default: auto),
            )
            _draw-molecule(
              placed-item.payload,
              scale: molecule-scale,
              font-size: placed-item.m.opts.at("font-size", default: none),
              font: placed-item.m.opts.at(
                "font",
                default: "New Computer Modern",
              ),
              bond-stroke: placed-item.m.opts.at("bond-stroke", default: none),
              color: placed-item.m.opts.at("color", default: true),
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
              atom-annotations: placed-item.m.opts.at(
                "atom-annotations",
                default: (),
              ),
              opacity: placed-item.m.opts.at("opacity", default: 100%),
              bond-customizations: placed-item.m.opts.at(
                "bond-customizations",
                default: (),
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
              center.at(1) - placed-item.h / 2 - 0.34,
            ),
            placed-item.m.label,
            anchor: "north",
          )
        }
      }
    })

    block(breakable: breakable, canvas)
  }
}
