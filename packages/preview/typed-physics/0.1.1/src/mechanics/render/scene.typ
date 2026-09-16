// Full-scene annotation settings and assembly from focused renderers.

#import "../../shared/vector.typ"
#import "../../shared/expression.typ"
#import "../forces.typ" as force-enumeration
#import "geometry.typ" as geometry
#import "surfaces.typ" as surfaces
#import "bodies.typ" as bodies
#import "structures.typ" as structures
#import "connectors.typ" as connectors
#import "loads.typ" as loads
#import "dimensions.typ" as dimensions
#import "../style.typ": resolve-surface-style

#let render-label = geometry.render-label
#let render-angle-marker = geometry.render-angle-marker
#let render-surface = surfaces.render-surface
#let render-unified-surface-hatching = surfaces.render-unified-surface-hatching
#let unified-surface-hatch-spans = surfaces.unified-surface-hatch-spans
#let render-curved-surface-hatching = surfaces.render-curved-surface-hatching
#let render-surface-length = surfaces.render-surface-length
#let render-body = bodies.render-body
#let friction-label = bodies.friction-label
#let render-rod = structures.render-rod
#let render-pivot = structures.render-pivot
#let render-support = structures.render-support
#let render-pendulum = structures.render-pendulum
#let render-pulley = connectors.render-pulley
#let render-connector = connectors.render-connector
#let bodies-named-by = loads.bodies-named-by
#let render-forces-on-body = loads.render-forces-on-body
#let render-applied-load = loads.render-applied-load
#let render-applied-load-on-rod = loads.render-applied-load-on-rod
#let render-torque = loads.render-torque
#let render-velocity = loads.render-velocity
#let render-angular-velocity = loads.render-angular-velocity
#let render-dimensions = dimensions.render-dimensions

#let annotation-settings(
  selection,
  argument-name,
  default-mode,
  allowed-modes,
  element-names,
) = {
  let selection-is-mode = type(selection) == str
  assert(
    selection-is-mode or type(selection) == dictionary,
    message: "typed-physics: " + argument-name + ": must be a mode or a dictionary with mode: and overrides:",
  )
  let mode = if selection-is-mode {
    selection
  } else {
    selection.at("mode", default: default-mode)
  }
  assert(
    mode in allowed-modes,
    message: "typed-physics: " + argument-name + ": mode must be " + allowed-modes.join(", "),
  )

  let declared-overrides = if selection-is-mode {
    ()
  } else {
    for key in selection.keys() {
      assert(
        key in ("mode", "overrides"),
        message: "typed-physics: unknown " + argument-name + ": key \"" + key + "\"; it takes mode and overrides",
      )
    }
    selection.at("overrides", default: ())
  }
  assert(
    type(declared-overrides) == array,
    message: "typed-physics: " + argument-name + ": overrides must be an array",
  )

  let resolved-settings = (:)
  for element-name in element-names {
    resolved-settings.insert(
      element-name,
      (mode: mode, is-visible: true, offset: (0, 0), rotation: 0deg),
    )
  }

  let overridden-elements = ()
  for declared-override in declared-overrides {
    assert(
      type(declared-override) == dictionary,
      message: "typed-physics: every " + argument-name + ": override must be a dictionary",
    )
    for key in declared-override.keys() {
      assert(
        key in ("on", "mode", "visible", "offset", "rotation"),
        message: "typed-physics: unknown " + argument-name + ": override key \"" + key + "\"",
      )
    }
    assert(
      "on" in declared-override,
      message: "typed-physics: every " + argument-name + ": override needs `on:` an eligible element name",
    )
    let element-name = declared-override.at("on")
    assert(
      element-name in element-names,
      message: "typed-physics: " + argument-name + ": override names \"" + element-name + "\", which is not an eligible element in this situation",
    )
    assert(
      not overridden-elements.contains(element-name),
      message: "typed-physics: " + argument-name + ": has more than one override for \"" + element-name + "\"",
    )
    overridden-elements.push(element-name)

    let element-mode = declared-override.at("mode", default: mode)
    let should-show-label = declared-override.at("visible", default: true)
    let label-offset = declared-override.at("offset", default: (0, 0))
    let label-rotation = declared-override.at("rotation", default: 0deg)
    assert(
      element-mode in allowed-modes,
      message: "typed-physics: " + argument-name + ": override mode must be " + allowed-modes.join(", "),
    )
    assert(
      type(should-show-label) == bool,
      message: "typed-physics: " + argument-name + ": override visible must be true or false",
    )
    assert(
      type(label-offset) == array
        and label-offset.len() == 2
        and type(label-offset.at(0)) in (int, float)
        and type(label-offset.at(1)) in (int, float),
      message: "typed-physics: " + argument-name + ": override offset must be an (x, y) pair of numbers",
    )
    assert(
      type(label-rotation) == angle,
      message: "typed-physics: " + argument-name + ": override rotation must be an angle",
    )
    resolved-settings.insert(
      element-name,
      (
        mode: element-mode,
        is-visible: should-show-label,
        offset: label-offset,
        rotation: label-rotation,
      ),
    )
  }
  resolved-settings
}

#let angle-label(surface, mode) = {
  if mode == "none" { return none }
  let displayed-degrees = expression.format-angle(surface.inclination.deg())
  if mode == "value" { return $#displayed-degrees$ }
  if mode == "symbol" { return surface.inclination-quantity.symbol }
  $#surface.inclination-quantity.symbol = #displayed-degrees$
}

#let render-scene(
  scene,
  diagram-style,
  labels: "name",
  angles: "value",
  loads: true,
  frictions: false,
  lengths: false,
  dimensions: (),
  forces: none,
  force-arrow-lengths: (:),
  solutions: (:),
) = {
  let bodies-showing-forces = bodies-named-by(scene, forces)
  let body-label-settings = annotation-settings(
    labels,
    "labels",
    "name",
    ("name", "symbol", "mass", "both", "none"),
    scene.body-order
      + scene.structure-order.filter(
        structure-name => scene.structures.at(structure-name).kind
          in ("rod", "pendulum"),
      ),
  )
  for element-name in body-label-settings.keys() {
    let label-setting = body-label-settings.at(element-name)
    if (
      label-setting.is-visible
        and label-setting.mode in ("symbol", "mass", "both")
    ) {
      let labelled-element = if element-name in scene.bodies {
        scene.bodies.at(element-name)
      } else {
        scene.structures.at(element-name)
      }
      assert(
        labelled-element.mass != none,
        message: (
          "typed-physics: labels: mode \""
            + label-setting.mode
            + "\" requests a mass label for \""
            + element-name
            + "\", but it has no `mass:`; declare its mass, choose mode \"name\", or hide that override"
        ),
      )
    }
  }
  let ramp-names = scene.surface-order.filter(
    surface-name => scene.surfaces.at(surface-name).kind == "ramp",
  )
  let angle-label-settings = annotation-settings(
    angles,
    "angles",
    "value",
    ("value", "symbol", "both", "none"),
    ramp-names,
  )

  for surface-name in scene.surface-order {
    let surface = scene.surfaces.at(surface-name)
    render-surface(surface, diagram-style)
  }
  render-unified-surface-hatching(scene, diagram-style)
  let straight-hatch-spans = unified-surface-hatch-spans(
    scene,
    diagram-style,
  )
  for surface-name in scene.surface-order {
    let surface = scene.surfaces.at(surface-name)
    if surface.kind == "arc" {
      render-curved-surface-hatching(
        surface,
        resolve-surface-style(diagram-style, surface.style),
        straight-hatch-spans,
      )
    }
  }

  for surface-name in scene.surface-order {
    let surface = scene.surfaces.at(surface-name)
    if lengths { render-surface-length(surface, diagram-style) }
    if surface.kind == "ramp" {
      let angle-annotation = angle-label-settings.at(surface-name)
      let climbs-to-the-right = surface.facing == "right"
      if angle-annotation.is-visible and angle-annotation.mode != "none" {
        render-angle-marker(
          surface.foot,
          if climbs-to-the-right { (1, 0) } else { (-1, 0) },
          surface.direction,
          angle-label(surface, angle-annotation.mode),
          diagram-style,
          radius: calc.min(diagram-style.angle-radius, surface.length * 0.22),
          // The label starts at the edge nearest the corner, so naming the
          // angle as well as its value grows the text into the ramp, not over
          // the arc.
          label-side: if climbs-to-the-right { "west" } else { "east" },
          label-offset: angle-annotation.offset,
          label-rotation: angle-annotation.rotation,
        )
      }
    }
  }

  for structure-name in scene.structure-order {
    let placed-structure = scene.structures.at(structure-name)
    if placed-structure.kind == "pivot" {
      render-pivot(placed-structure, diagram-style)
    } else if placed-structure.kind == "support" {
      render-support(placed-structure, diagram-style)
    }
  }
  for structure-name in scene.structure-order {
    let placed-structure = scene.structures.at(structure-name)
    if placed-structure.kind == "rod" {
      if loads {
        let applied-load-count = placed-structure.loads.len()
        for (load-index, applied-load) in placed-structure.loads.enumerate() {
          render-applied-load-on-rod(
            placed-structure,
            applied-load,
            force-enumeration.applied-load-symbol(
              applied-load,
              load-index,
              applied-load-count,
            ),
            diagram-style,
          )
        }
      }
      render-rod(
        placed-structure,
        diagram-style,
        body-label-settings.at(structure-name),
      )
    } else if placed-structure.kind == "pendulum" {
      render-pendulum(
        placed-structure,
        diagram-style,
        body-label-settings.at(structure-name),
      )
    }
  }

  for placed-connector in scene.connectors {
    render-connector(placed-connector, scene, diagram-style)
  }
  for pulley-name in scene.pulleys.keys() {
    render-pulley(scene.pulleys.at(pulley-name), diagram-style)
  }

  for body-name in scene.body-order {
    let body = scene.bodies.at(body-name)
    if bodies-showing-forces.contains(body-name) {
      render-forces-on-body(
        scene,
        body,
        force-arrow-lengths.at(body-name),
        diagram-style,
        solution: solutions.at(body-name, default: none),
      )
    } else if loads {
      let applied-load-count = body.loads.len()
      for (load-index, applied-load) in body.loads.enumerate() {
        render-applied-load(
          body,
          applied-load,
          force-enumeration.applied-load-symbol(
            applied-load,
            load-index,
            applied-load-count,
          ),
          diagram-style,
        )
      }
    }
    for (velocity-index, body-velocity) in body.velocities.enumerate() {
      render-velocity(body, body-velocity, velocity-index, diagram-style)
    }
    render-body(
      body,
      diagram-style,
      label-annotation: body-label-settings.at(body-name),
    )
    // Friction belongs to a contact rather than to a surface, so it is named
    // beside the body that makes it. The label sits on its own downhill end,
    // so it grows over ground that falls away from it and a rising surface
    // never runs through the text.
    if frictions and body.support != none {
      let contact-friction = friction-label(body.friction)
      if contact-friction != none {
        render-label(
          vector.point-along(
            vector.point-along(
              body.contact,
              vector.reversed(body.direction),
              body.half-extent-along + 0.25,
            ),
            body.outward-normal,
            0.12,
          ),
          contact-friction,
          diagram-style.angle-text,
          side: "south-east",
        )
      }
    }
    for (
      angular-velocity-index,
      body-angular-velocity,
    ) in body.angular-velocities.enumerate() {
      render-angular-velocity(
        body,
        body-angular-velocity,
        angular-velocity-index,
        diagram-style,
      )
    }
  }
  if loads {
    for placed-torque in scene.torques {
      render-torque(placed-torque, diagram-style)
    }
  }
  render-dimensions(scene, dimensions, diagram-style)
}
