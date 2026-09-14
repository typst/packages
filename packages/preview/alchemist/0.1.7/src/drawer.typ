#import "default.typ": default
#import "@preview/cetz:0.4.1"
#import "cetz/process.typ" as custom-process
#import "utils/utils.typ": *
#import "utils/anchors.typ": *
#import "utils/utils.typ" as utils
#import "drawer/fragment.typ" as fragment
#import "drawer/link.typ" as link
#import "drawer/branch.typ" as branch
#import "drawer/cycle.typ" as cycle
#import "drawer/parenthesis.typ" as parenthesis
#import "drawer/hook.typ" as hook
#import "drawer/operator.typ" as operator

#import cetz.draw: *

#let default-anchor = (type: "coord", anchor: (0, 0))

#let default-ctx = (
  // general
  last-anchor: default-anchor, // keep trace of the place to draw
  last-name: "", // last name used to draw
  links: (), // list of links to draw
  hooks: (:), // list of hooks
  hooks-links: (), // list of links to hooks
  relative-angle: 0deg, // current global relative angle
  angle: 0deg, // current global angle
  id: 0, // an id used to name things with an unique name
  // branch
  first-branch: false, // true if the next element is the first in a branch
  // cycle
  first-fragment: none, // name of the first fragment in the cycle
  in-cycle: false, // true if we are in a cycle
  cycle-faces: 0, // number of faces in the current cycle
  faces-count: 0, // number of faces already drawn
  cycle-step-angle: 0deg, // angle between two faces in the cycle
  record-vertex: false, // true if the cycle should keep track of its vertices
  vertex-anchors: (), // list of the cycle vertices
)

#let draw-hooks-links(links, mol-name, ctx, from-mol) = {
  let hook-id = 0
  for (to-name, (link,)) in links {
    if link.at(mol-name, default: none) == none {
      link.name = mol-name + "-hook-" + str(hook-id)
      hook-id += 1
    }
    if to-name not in ctx.hooks {
      panic("Molecule " + to-name + " does not exist")
    }
    let to-hook = ctx.hooks.at(to-name)
    if to-hook.type == "fragment" {
      ctx.links.push((
        type: "link",
        name: link.at("name"),
        from-pos: if from-mol {
          (name: mol-name, anchor: "mid")
        } else {
          mol-name + "-end-anchor"
        },
        from-name: if from-mol {
          mol-name
        },
        to-name: to-name,
        from: none,
        to: none,
        over: link.at("over", default: none),
        override: angles.angle-override(ctx.angle, ctx),
        draw: link.draw,
      ))
    } else if to-hook.type == "hook" {
      ctx.links.push((
        type: if from-mol {
          "mol-hook-link"
        } else {
          "link-hook-link"
        },
        name: link.at("name"),
        from-pos: if from-mol {
          (name: mol-name, anchor: "mid")
        } else {
          mol-name + "-end-anchor"
        },
        from-name: if from-mol {
          mol-name
        },
        to-name: to-name,
        to-hook: to-hook.hook,
        override: angles.angle-override(ctx.angle, ctx),
        draw: link.draw,
        over: link.at("over", default: none),
      ))
    } else {
      panic("Unknown hook type " + ctx.hook.at(to-name).type)
    }
  }
  ctx
}

#let draw-fragments-and-link(ctx, body) = {
  let fragment-drawing = ()
  let cetz-drawing = ()
  for element in body {
    if ctx.in-cycle and ctx.faces-count >= ctx.cycle-faces {
      continue
    }
    let drawing = ()
    let cetz-rec = ()
    if type(element) == function {
      cetz-drawing.push(element)
    } else if "type" not in element {
      panic("Element " + repr(element) + " has no type")
    } else if element.type == "fragment" {
      (ctx, drawing) = fragment.draw-fragment(element, ctx)
    } else if element.type == "link" {
      (ctx, drawing) = link.draw-link(element, ctx)
    } else if element.type == "branch" {
      (ctx, drawing, cetz-rec) = branch.draw-branch(element, ctx, draw-fragments-and-link)
    } else if element.type == "cycle" {
      (ctx, drawing, cetz-rec) = cycle.draw-cycle(element, ctx, draw-fragments-and-link)
    } else if element.type == "hook" {
      ctx = hook.draw-hook(element, ctx)
    } else if element.type == "parenthesis" {
      (ctx, drawing, cetz-rec) = parenthesis.draw-parenthesis(
        element,
        ctx,
        draw-fragments-and-link,
      )
    } else if element.type == "operator" {
      (ctx, drawing) = operator.draw-operator(element, fragment-drawing, ctx)
    } else {
      panic("Unknown element type " + element.type)
    }
    fragment-drawing += drawing
    cetz-drawing += cetz-rec
  }
  if ctx.last-anchor.type == "link" and not ctx.last-anchor.at("drew", default: false) {
    ctx.links.push(ctx.last-anchor)
    ctx.last-anchor.drew = true
  }
  (
    ctx,
    fragment-drawing,
    cetz-drawing,
  )
}

#let draw-link-over(ctx, link, over, angle) = {
  let name = link.name + "-over"
  let (over, length, radius) = if type(over) == str {
    (over, link-over-radius, link-over-radius)
  } else if type(over) == dictionary {
    let name = over.at("name", default: none)
    if name == none {
      panic("Over argument must have a name")
    }
    (
      name, 
      over.at("length", default: link-over-radius),
      over.at("radius", default: link-over-radius)
    )
  } else {
    panic("Over must be a string or a dictionary, got " + type(link.at("over")))
  }
  intersections(name, over, link.name)
  let color = if ctx.config.debug {
    red
  } else {
    white
  }
  scope({
    rotate(angle)
    rect(
      anchor: "center",
      (to: name + ".0", rel: (-length/2,-radius/2)),
      (rel: (length, radius)),
      fill: color,
      stroke: color
    )
  })
}

#let draw-link-decoration(ctx) = {
  (
    ctx,
    get-ctx(cetz-ctx => {
      for link in ctx.links {
        let ((from, to), angle) = calculate-link-anchors(ctx, cetz-ctx, link)
        if ctx.config.debug {
          circle(from, radius: .1em, fill: red, stroke: red)
          circle(to, radius: .1em, fill: red, stroke: red)
        }
        let length = distance-between(cetz-ctx, from, to)
        hide(line(from, to, name: link.name))
        if link.at("over") != none {
          if type(link.at("over")) == array {
            for over in link.at("over") {
              draw-link-over(ctx, link, over, angle)
            }
          } else {
            draw-link-over(ctx, link, link.at("over"), angle)
          }
        }

        scope({
          set-origin(from)
          rotate(angle)
          (link.draw)(length, ctx, cetz-ctx, override: link.override)
        })
      }
    }),
  )
}

/// set elements names and split the molecule into sub-groups
#let preprocessing(body, group-id: 0, link-id: 0, operator-id: 0) = {
  let result = ((),)
  for element in body {
    if type(element) == dictionary {
      if element.at("name", default: none) == none {
        if element.type == "fragment" {
          element.name = "fragment-" + str(group-id)
          group-id += 1
        } else if element.type == "link" {
          element.name = "link-" + str(link-id)
          link-id += 1
        } else if element.type == "operator" {
          element.name = "operator-" + str(operator-id)
          operator-id += 1
        }
      }
      if element.at("body", default: none) != none {
        let child-body
        (child-body, group-id, link-id, operator-id) = preprocessing(
          element.body,
          group-id: group-id,
          link-id: link-id,
          operator-id: operator-id,
        )
        if element.type == "parenthesis" and element.resonance {
          element.body = child-body
        } else {
          element.body = child-body.at(0)
        }
      }
      if element.type == "operator" or (element.type == "parenthesis" and element.resonance) {
        result.push(element)
        result.push(())
      } else {
        result.at(-1).push(element)
      }
    } else {
      result.at(-1).push(element)
    }
  }
  (result, group-id, link-id, operator-id)
}

#let operator-group-name = id => {
  "operator-group-" + str(id)
}

#let draw-groups(ctx, bodies, after-operator: false) = {
  ctx.last-name = ""

  let drawables = for (i, body) in bodies.enumerate() {
    if type(body) == array {
      if body.len() > 0 {
        ctx.last-name = operator-group-name(i)
        get-ctx(cetz-ctx => {
          let ctx = ctx
          if ctx.last-anchor.type == "coord" {
            (cetz-ctx, ctx.last-anchor.anchor) = cetz.coordinate.resolve(cetz-ctx, ctx.last-anchor.anchor)
          }
          let last-anchor = ctx.last-anchor
          let (ctx, atoms, cetz-drawing) = draw-fragments-and-link(ctx, body)
          for (links, name, from-mol) in ctx.hooks-links {
            ctx = draw-hooks-links(links, name, ctx, from-mol)
          }

          let molecule = {
            atoms
          }

          let (ctx: cetz-ctx, drawables, bounds: molecule-bounds, anchors) = custom-process.many(cetz-ctx, molecule)
          molecule-bounds = cetz.util.revert-transform(cetz-ctx.transform, molecule-bounds)

          let (translate-x, translate-y) = if after-operator {
            let (_, origin-anchor) = cetz.coordinate.resolve(cetz-ctx, last-anchor.anchor)
            (
              origin-anchor.at(0) - molecule-bounds.low.at(0),
              -origin-anchor.at(1)
                + (
                  molecule-bounds.low.at(1) + molecule-bounds.high.at(1)
                )
                  / 2,
            )
          } else {
            (0, 0)
          }
          let transform-matrix = cetz.matrix.transform-translate(
            translate-x,
            translate-y,
            0,
          )
          // panic(anchors)
          for name in anchors {
            let hold-anchors = cetz-ctx.nodes.at(name).anchors
            cetz-ctx.nodes.at(name).anchors = (name) => {
              if name != () {
                cetz.matrix.mul4x4-vec3(transform-matrix, hold-anchors(name))
              } else {
                hold-anchors(name)
              }
            }
          }
          (
            _ => (
              ctx: cetz-ctx,
              drawables: cetz.drawable.apply-transform(
                cetz.matrix.transform-translate(
                  translate-x,
                  translate-y,
                  0,
                ),
                drawables,
              ),
            ),
          )
          scope({
            translate(x: translate-x, y: -translate-y)
            draw-link-decoration(ctx).at(1)
            on-layer(2, cetz-drawing)
            let bound-rect = cetz.draw.rect(
              molecule-bounds.low,
              molecule-bounds.high,
              name: ctx.last-name,
              stroke: purple,
            )
            if ctx.config.debug {
              bound-rect
            } else {
              cetz.draw.hide(bound-rect)
            }
          })
        })
      }
    } else if body.type == "operator" {
      let (op-ctx, drawable) = operator.draw-operator(body, ctx)
      after-operator = true
      ctx = op-ctx
      drawable
    } else if body.type == "parenthesis" {
      let (parenthesis-ctx, drawable) = parenthesis.draw-resonance-parenthesis(body, draw-groups, ctx)
      ctx = parenthesis-ctx
      drawable
    } else {
      panic("Unexpected element type: " + body.type)
    }
  }
  (drawables, ctx)
}

#let draw-skeleton(config: default, name: none, mol-anchor: none, body) = {
  let config = merge-dictionaries(config, default)
  let ctx = default-ctx
  ctx.angle = config.base-angle
  ctx.config = config

  let bodies = preprocessing(body).at(0)
  let (final-drawing, ctx) = draw-groups(ctx, bodies)

  if name == none {
    final-drawing
  } else {
    group(name: name, anchor: mol-anchor, {
      anchor("default", (0, 0))
      final-drawing
    })
  }
}

/// setup a molecule skeleton drawer
#let skeletize(debug: false, background: none, config: (:), body) = {
  if "debug" not in config {
    config.insert("debug", debug)
  }
  cetz.canvas(debug: debug, background: background, draw-skeleton(config: config, body))
}

#let skeletize-config(default-config) = {
  let config-function(debug: false, background: none, config: (:), body) = {
    skeletize(debug: debug, background: background, config: merge-dictionaries(config, default-config), body)
  }
  config-function
}

#let draw-skeleton-config(default-config) = {
  let config-function(config: (:), name: none, mol-anchor: none, body) = {
    draw-skeleton(config: merge-dictionaries(config, default-config), body)
  }
  config-function
}
