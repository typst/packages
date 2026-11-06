#import "../utils/utils.typ"
#import "@preview/cetz:0.3.2"

#let bounding-box-height(bounds) = {
	calc.abs(bounds.high.at(1) - bounds.low.at(1))
}

#let bounding-box-width(bounds) = {
	calc.abs(bounds.high.at(0) - bounds.low.at(0))
}

#let left-parenthesis-anchor(parenthesis, ctx) = {
	let anchor = if parenthesis.body.at(0).type == "molecule" {
    let name = parenthesis.body.at(0).name
    if name == none {
      name = "molecule" + str(ctx.group-id)
    }
    ctx.group-id += 1
    parenthesis.body.at(0).name = name
    (name: name, anchor: "west")
  } else if parenthesis.body.at(0).type == "link" {
    let name = parenthesis.body.at(0).at("name", default: "link" + str(ctx.link-id))
    ctx.link-id += 1
    parenthesis.body.at(0).name = name
    (name: name, anchor: 50%)
  } else {
    panic("The first element of a parenthesis must be a molecule or a link")
  }
	(ctx, parenthesis, anchor)
}

#let right-parenthesis-anchor(parenthesis, ctx) = {
	let right-name = parenthesis.at("right")
	let right-type = ""
	if right-name != none {
		right-type = utils.get-element-type(parenthesis.body, right-name)
		if right-type == none {
			panic("The right element of the parenthesis does not exist")
		}
	} else {
		right-type = parenthesis.body.at(-1).type
		if right-type == "molecule" {
			right-name = "molecule" + str(ctx.group-id)
			ctx.group-id += 1
			parenthesis.body.at(-1).name = right-name
		} else if right-type == "link" {
			right-name = "link" + str(ctx.link-id)
			ctx.link-id += 1
			parenthesis.body.at(-1).name = right-name
		}
 	}

	let anchor = if right-type == "molecule" {
		(name: right-name, anchor: "east")
	} else if right-type == "link" {
		(name: right-name, anchor: 50%)
	} else {
		panic("The last element of a parenthesis must be a molecule or a link but got " + right-type)
	}
	(ctx, parenthesis, anchor)
}

#let draw-parenthesis(parenthesis, ctx, draw-molecules-and-link) = {
  let (ctx, parenthesis, left-anchor) = left-parenthesis-anchor(parenthesis, ctx)
	let (ctx, parenthesis, right-anchor) = right-parenthesis-anchor(parenthesis, ctx)

  let (parenthesis-ctx, drawing, parenthesis-rec, cetz-rec) = draw-molecules-and-link(
    ctx,
    parenthesis.body,
  )
  ctx = parenthesis-ctx
	parenthesis-rec += {
		import cetz.draw: *
		get-ctx(cetz-ctx => {
			let sub-bounds = cetz.process.many(cetz-ctx, {
				set-transform(none)
				drawing
			}).bounds
			
			let sub-height = bounding-box-height(sub-bounds)
			let sub-v-mid = sub-bounds.low.at(1) + sub-height / 2

			let sub-width = bounding-box-width(sub-bounds)

			let height = parenthesis.at("height")
			if height == none {
				if not parenthesis.align {
					panic("You must specify the height of the parenthesis if they are not aligned")
				}
				height = sub-height
			} else {
				height = utils.convert-length(cetz-ctx, height)
			}
			let block = block(height: height * cetz-ctx.length * 1.2, width: 0pt)
			let left-parenthesis = {
				set text(top-edge: "bounds", bottom-edge: "bounds")
				math.lr($parenthesis.l block$, size: 100%)
			}
			let right-parenthesis = {
				set text(top-edge: "bounds", bottom-edge: "bounds")
				math.lr($block parenthesis.r$, size: 100%)
			}

			let right-parenthesis-with-attach = {
				set text(top-edge: "bounds", bottom-edge: "bounds")
				math.attach(right-parenthesis, br: parenthesis.br, tr: parenthesis.tr)
			}

			let (_, (lx, ly, _)) = cetz.coordinate.resolve(cetz-ctx, update: false, left-anchor)
			let (_, (rx, ry, _)) = cetz.coordinate.resolve(cetz-ctx, update: false, right-anchor)

			if ctx.config.debug {
				circle((lx, ly), radius: 1pt, fill: orange, stroke: orange)
				circle((rx, ry), radius: 1pt, fill: orange, stroke: orange)
				rect(sub-bounds.low, sub-bounds.high, stroke: orange)
			}
			
			let hoffset = calc.abs(sub-width - calc.abs(rx - lx))

			if parenthesis.align {
				ly += calc.abs(ly - sub-v-mid)
				ry += calc.abs(ry - sub-v-mid)
				ry = ly
			} else if type(parenthesis.yoffset) == array {
				if parenthesis.yoffset.len() != 2 {
					panic("The parenthesis yoffset must be a list of length 2 or a number")
				}
				ly += utils.convert-length(cetz-ctx, parenthesis.yoffset.at(0))
				ry += utils.convert-length(cetz-ctx, parenthesis.yoffset.at(1))
			} else if parenthesis.yoffset != none {
				let offset = utils.convert-length(cetz-ctx, parenthesis.yoffset)
				ly += offset
				ry += offset
			}

			if type(parenthesis.xoffset) == array {
				if parenthesis.xoffset.len() != 2 {
					panic("The parenthesis xoffset must be a list of length 2 or a number")
				}
				lx += utils.convert-length(cetz-ctx, parenthesis.xoffset.at(0))
				rx += utils.convert-length(cetz-ctx, parenthesis.xoffset.at(1))
			} else if parenthesis.xoffset != none {
				let offset = utils.convert-length(cetz-ctx, parenthesis.xoffset)
				lx -= offset
				rx += offset
			}

			let right-bounds = cetz.process.many(cetz-ctx, content((0,0),right-parenthesis, auto-scale: false)).bounds
			let right-with-attach-bounds = cetz.process.many(cetz-ctx, content((0,0),right-parenthesis-with-attach, auto-scale: false)).bounds
			let right-voffset = calc.abs(right-bounds.low.at(1) - right-with-attach-bounds.low.at(1))
			if (parenthesis.tr != none and parenthesis.br != none) {
				right-voffset /= 2
			} else if (parenthesis.tr != none) {
				right-voffset *= -1
			}
			content((lx , ly), anchor: "mid-east", left-parenthesis, auto-scale: false)
			content((rx, ry - right-voffset), anchor: "mid-west", right-parenthesis-with-attach, auto-scale: false)
		})
	}
  (ctx, drawing, parenthesis-rec, cetz-rec)
}
