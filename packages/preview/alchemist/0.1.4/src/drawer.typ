#import "default.typ": default
#import "@preview/cetz:0.3.1"
#import "utils/utils.typ": *
#import "utils/anchors.typ": *
#import "drawer/molecule.typ" as molecule
#import "drawer/link.typ" as link
#import "drawer/branch.typ" as branch
#import "drawer/cycle.typ" as cycle
#import "drawer/parenthesis.typ" as parenthesis
#import "drawer/hook.typ" as hook

#import cetz.draw: *

#let default-anchor = (type: "coord", anchor: (0, 0))

#let default-ctx = (
  // general
  last-anchor: default-anchor, // keep trace of the place to draw
  group-id: 0, // id of the current group
  link-id: 0, // id of the current link
  links: (), // list of links to draw
  hooks: (:), // list of hooks
  hooks-links: (), // list of links to hooks
  relative-angle: 0deg, // current global relative angle
  angle: 0deg, // current global angle
  // branch
  first-branch: false, // true if the next element is the first in a branch
  // cycle
  first-molecule: none, // name of the first molecule in the cycle
  in-cycle: false, // true if we are in a cycle
  cycle-faces: 0, // number of faces in the current cycle
  faces-count: 0, // number of faces already drawn
  cycle-step-angle: 0deg, // angle between two faces in the cycle
  record-vertex: false, // true if the cycle should keep track of its vertices
  vertex-anchors: (), // list of the cycle vertices
)

#let draw-hooks-links(links, name, ctx, from-mol) = {
  for (to-name, (link,)) in links {
    if to-name not in ctx.hooks {
      panic("Molecule " + to-name + " does not exist")
    }
    let to-hook = ctx.hooks.at(to-name)
    if to-hook.type == "molecule" {
      ctx.links.push((
        type: "link",
        name: link.at("name", default: "link" + str(ctx.link-id)),
        from-pos: if from-mol {
          (name: name, anchor: "mid")
        } else {
          name + "-end-anchor"
        },
        from-name: if from-mol {
          name
        },
        to-name: to-name,
        from: none,
        to: none,
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
        name: link.at("name", default: "link" + str(ctx.link-id)),
        from-pos: if from-mol {
          (name: name, anchor: "mid")
        } else {
          name + "-end-anchor"
        },
        from-name: if from-mol {
          name
        },
        to-name: to-name,
        to-hook: to-hook.hook,
        override: angles.angle-override(ctx.angle, ctx),
        draw: link.draw,
      ))
    } else {
      panic("Unknown hook type " + ctx.hook.at(to-name).type)
    }
    ctx.link-id += 1
  }
  ctx
}

#let draw-molecules-and-link(ctx, body) = {
	let molecule-drawing = ()
	let parenthesis-drawing = ()
  let cetz-drawing = ()
	for element in body {
		if ctx.in-cycle and ctx.faces-count >= ctx.cycle-faces {
			continue
		}
		let drawing = ()
		let parenthesis-drawing-rec = ()
		let cetz-rec = ()
		if type(element) == function {
			cetz-drawing.push(element)
		} else if "type" not in element {
			panic("Element " + str(element) + " has no type")
		} else if element.type == "molecule" {
			(ctx, drawing) = molecule.draw-molecule(element, ctx)
		} else if element.type == "link" {
			(ctx, drawing) = link.draw-link(element, ctx)
		} else if element.type == "branch" {
			(ctx, drawing, parenthesis-drawing-rec, cetz-rec) = branch.draw-branch(element, ctx, draw-molecules-and-link)
		} else if element.type == "cycle" {
			(ctx, drawing, parenthesis-drawing-rec, cetz-rec) = cycle.draw-cycle(element, ctx, draw-molecules-and-link)
		} else if element.type == "hook" {
			ctx = hook.draw-hook(element, ctx)
		} else if element.type == "parenthesis" {
			(ctx, drawing, parenthesis-drawing-rec, cetz-rec) = parenthesis.draw-parenthesis(element, ctx, draw-molecules-and-link)
		} else {
			panic("Unknown element type " + element.type)
		}
		molecule-drawing += drawing
		cetz-drawing += cetz-rec
		parenthesis-drawing += parenthesis-drawing-rec
	}
	if ctx.last-anchor.type == "link" and not ctx.last-anchor.at("drew", default: false) {
		ctx.links.push(ctx.last-anchor)
		ctx.last-anchor.drew = true
	}
  (
    ctx,
    molecule-drawing,
		parenthesis-drawing,
    cetz-drawing,
  )
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
        scope({
          set-origin(from)
          rotate(angle)
          (link.draw)(length, ctx, cetz-ctx, override: link.override)
        })
      }
    }),
  )
}

#let draw-skeleton(config: default, name: none, mol-anchor: none, body) = {
  let config = merge-dictionaries(config, default)
  let ctx = default-ctx
  ctx.angle = config.base-angle
  ctx.config = config
  let (ctx, atoms, parenthesis, cetz-drawing) = draw-molecules-and-link(ctx, body)
  for (links, name, from-mol) in ctx.hooks-links {
    ctx = draw-hooks-links(links, name, ctx, from-mol)
  }
  let links = draw-link-decoration(ctx).at(1)

  if name == none {
		atoms
		links
		parenthesis
		cetz-drawing
  } else {
    group(
      name: name,
      anchor: mol-anchor,
      {
        anchor("default", (0, 0))
        atoms
        links
				parenthesis
        cetz-drawing
      },
    )
  }
}

/// setup a molecule skeleton drawer
#let skeletize(debug: false, background: none, config: (:), body) = {
  if "debug" not in config {
    config.insert("debug", debug)
  }
  cetz.canvas(
    debug: debug,
    background: background,
    draw-skeleton(config: config, body),
  )
}
