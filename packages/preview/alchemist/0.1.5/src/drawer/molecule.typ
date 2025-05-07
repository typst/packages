#import "../utils/context.typ": *
#import "../utils/anchors.typ": *
#import "@preview/cetz:0.3.4"

#let draw-molecule-text(mol) = {
	import cetz.draw: *
  for (id, eq) in mol.atoms.enumerate() {
    let name = str(id)
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
        eq
      },
    )
    id += 1
  }
}

#let draw-molecule-lewis(ctx, group-name, count, lewis) = {
	if lewis.len() == 0 {
		return ()
	}
	import cetz.draw: *
  get-ctx(cetz-ctx => {
    for (id, (angle: lewis-angle, molecule-margin, draw)) in lewis.enumerate() {
      let lewis-angle = angles.angle-correction(lewis-angle)
      let mol-id = if angles.angle-in-range-inclusive(lewis-angle, 90deg, 270deg) {
        0
      } else {
        count - 1
      }
      let anchor = molecule-anchor(
        ctx,
        cetz-ctx,
        lewis-angle,
        group-name,
        str(mol-id),
        margin: molecule-margin,
      )
      scope({
        set-origin(anchor)
        rotate(lewis-angle)
        draw(ctx, cetz-ctx)
      })
    }
  })
}

#let draw-molecule-elements(mol, ctx) = {
  let name = mol.name
  if name != none {
    if name in ctx.hooks {
      panic("Molecule with name " + name + " already exists")
    }
    ctx.hooks.insert(name, mol)
  } else {
    name = "molecule" + str(ctx.group-id)
  }
  let (group-anchor, side, coord) = if ctx.last-anchor.type == "coord" {
    ("west", true, ctx.last-anchor.anchor)
  } else if ctx.last-anchor.type == "link" {
    if ctx.last-anchor.to == none {
      ctx.last-anchor.to = link-molecule-index(
        ctx.last-anchor.angle,
        true,
        mol.count - 1,
        mol.vertical,
      )
    }
    let group-anchor = link-molecule-anchor(ctx.last-anchor.to, mol.count)
    ctx.last-anchor.to-name = name
    (group-anchor, false, ctx.last-anchor.name + "-end-anchor")
  } else {
    panic("A molecule must be linked to a coord or a link")
  }
  ctx = context_.set-last-anchor(
    ctx,
    (type: "molecule", name: name, count: mol.at("count"), vertical: mol.vertical),
  )
  ctx.group-id += 1
  (
    ctx,
    {
			import cetz.draw: *
      group(
        anchor: if side {
          group-anchor
        } else {
          "from" + str(ctx.group-id)
        },
        name: name,
        {
          set-origin(coord)
          anchor("default", (0, 0))
          draw-molecule-text(mol)
          if not side {
            anchor("from" + str(ctx.group-id), group-anchor)
          }
        },
      )
      draw-molecule-lewis(ctx, name, mol.count, mol.at("lewis"))
    },
  )
}

#let draw-molecule(element, ctx) = {
	if ctx.first-branch {
		panic("A molecule can not be the first element in a cycle")
	}
	let (ctx, drawing) = draw-molecule-elements(element, ctx)
	if element.links.len() != 0 {
		ctx.hooks.insert(ctx.last-anchor.name, element)
		ctx.hooks-links.push((element.links, ctx.last-anchor.name, true))
	}
	(ctx, drawing)
}