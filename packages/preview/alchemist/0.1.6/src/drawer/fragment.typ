#import "../utils/context.typ": *
#import "../utils/anchors.typ": *
#import "@preview/cetz:0.3.4"

#let draw-fragment-text(mol) = {
	import cetz.draw: *
  for (id, eq) in mol.atoms.enumerate() {
    let name = str(id)
    let color = if mol.colors != none {
      if type(mol.colors) == color {
        mol.colors
      } else {
        mol.colors.at(calc.min(id, mol.colors.len() - 1))
      }
    } else {
      none
    }
    // draw atoms of the group one after the other from left to right
    content(
      name: name,
      anchor: if mol.vertical {
        "north"
      } else {
        "mid-west"
      },
      (
        if id == 0 {
          (0, 0)
        } else if mol.vertical {
          (to: str(id - 1) + ".south", rel: (0, -.2em))
        } else {
          str(id - 1) + ".mid-east"
        }
      ),
			auto-scale: false,
      {
        show math.equation: math.upright
        set text(fill: color) if color != none
        eq
      },
    )
    id += 1
  }
}

#let draw-fragment-lewis(ctx, group-name, count, lewis) = {
	if lewis.len() == 0 {
		return ()
	}
	import cetz.draw: *
  get-ctx(cetz-ctx => {
    for (id, (angle: lewis-angle, radius, draw)) in lewis.enumerate() {
      if (lewis-angle == none) {
        lewis-angle = ctx.config.lewis.angle
      }
      if (radius == none) {
        radius = ctx.config.lewis.radius
      }
      let lewis-angle = angles.angle-correction(lewis-angle)
      let mol-id = if angles.angle-in-range-inclusive(lewis-angle, 90deg, 270deg) {
        0
      } else {
        count - 1
      }
      let anchor = fragment-anchor(
        ctx,
        cetz-ctx,
        lewis-angle,
        group-name,
        str(mol-id),
        margin: radius,
      )
      scope({
        set-origin(anchor)
        rotate(lewis-angle)
        draw(ctx, cetz-ctx)
      })
    }
  })
}

#let draw-fragment-elements(mol, ctx) = {
  let name = mol.name
  if name in ctx.hooks {
    panic("Molecule fragment with name " + name + " already exists : " + ctx.hooks.keys().join(", "))
  }
  ctx.hooks.insert(name, mol)
  
  let (group-anchor, side, coord) = if ctx.last-anchor.type == "coord" {
    ("west", true, ctx.last-anchor.anchor)
  } else if ctx.last-anchor.type == "link" {
    if ctx.last-anchor.to == none {
      ctx.last-anchor.to = link-fragment-index(
        ctx.last-anchor.angle,
        true,
        mol.count - 1,
        mol.vertical,
      )
    }
    let group-anchor = link-fragment-anchor(ctx.last-anchor.to, mol.count)
    ctx.last-anchor.to-name = name
    (group-anchor, false, ctx.last-anchor.name + "-end-anchor")
  } else {
    panic("A molecule fragment must be linked to a coord or a link")
  }
  ctx = context_.set-last-anchor(
    ctx,
    (type: "fragment", name: name, count: mol.at("count"), vertical: mol.vertical),
  )
  if (side) {
    ctx.id += 1
  }
  (
    ctx,
    {
			import cetz.draw: *
      group(
        anchor: if side {
          group-anchor
        } else {
          "from" + str(ctx.id)
        },
        name: name,
        {
          set-origin(coord)
          anchor("default", (0, 0))
          draw-fragment-text(mol)
          if not side {
            anchor("from" + str(ctx.id), group-anchor)
          }
        },
      )
      draw-fragment-lewis(ctx, name, mol.count, mol.at("lewis"))
    },
  )
}

#let draw-fragment(element, ctx) = {
	if ctx.first-branch {
		panic("A molecule fragment can not be the first element in a cycle")
	}
	let (ctx, drawing) = draw-fragment-elements(element, ctx)
	if element.links.len() != 0 {
		ctx.hooks.insert(ctx.last-anchor.name, element)
		ctx.hooks-links.push((element.links, ctx.last-anchor.name, true))
	}
	(ctx, drawing)
}