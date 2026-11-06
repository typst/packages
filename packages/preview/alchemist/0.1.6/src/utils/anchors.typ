#import "angles.typ"
#import "context.typ" as context_
#import "utils.typ": *
#import "@preview/cetz:0.3.4"
#import cetz.draw: *

#let anchor-north-east(cetz-ctx, (x, y, _), delta, fragment, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "north")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "east")),
  )

  let a = (a - x) + delta
  let b = (b - y) + delta
  (a, b)
}

#let anchor-north-west(cetz-ctx, (x, y, _), delta, fragment, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "north")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "west")),
  )
  let a = (x - a) + delta
  let b = (b - y) + delta
  (a, b)
}

#let anchor-south-west(cetz-ctx, (x, y, _), delta, fragment, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "south")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "west")),
  )
  let a = (x - a) + delta
  let b = (y - b) + delta
  (a, b)
}

#let anchor-south-east(cetz-ctx, (x, y, _), delta, fragment, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "south")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "east")),
  )
  let a = (a - x) + delta
  let b = (y - b) + delta
  (a, b)
}

/// Calculate an anchor position around a fragment using an ellipse
/// at a given angle
///
/// - ctx (alchemist-ctx): the alchemist context
/// - cetz-ctx (cetz-ctx): the cetz context
/// - angle (float, int, angle): the angle of the anchor
/// - fragment (string): the fragment name
/// - id (string): the fragment subpart id
/// - margin (length, none): the margin around the fragment
/// -> anchor: the anchor position around the fragment
#let fragment-anchor(ctx, cetz-ctx, angle, fragment, id, margin: none) = {
	let angle = angles.angle-correction(angle)
	let fragment-margin = if margin == none {
		ctx.config.fragment-margin
	} else {
		margin
	}
	fragment-margin = convert-length(cetz-ctx, fragment-margin)
  let (cetz-ctx, center) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: fragment, anchor: (id, "mid")),
  )
  let (a, b) = if angles.angle-in-range(angle, 0deg, 90deg) {
    anchor-north-east(cetz-ctx, center, fragment-margin, fragment, id)
  } else if angles.angle-in-range(angle, 90deg, 180deg) {
    anchor-north-west(cetz-ctx, center, fragment-margin, fragment, id)
  } else if angles.angle-in-range(angle, 180deg, 270deg) {
    anchor-south-west(cetz-ctx, center, fragment-margin, fragment, id)
  } else {
    anchor-south-east(cetz-ctx, center, fragment-margin, fragment, id)
  }

  // https://www.petercollingridge.co.uk/tutorials/computational-geometry/finding-angle-around-ellipse/
  let angle = if angles.angle-in-range-inclusive(angle, 0deg, 90deg) or angles.angle-in-range-strict(
    angle,
    270deg,
    360deg,
  ) {
    calc.atan(calc.tan(angle) * a / b)
  } else {
    calc.atan(calc.tan(angle) * a / b) - 180deg
  }


  if a == 0 or b == 0 {
    panic("Ellipse " + ellipse + " has no width or height")
  }
  (center.at(0) + a * calc.cos(angle), center.at(1) + b * calc.sin(angle))
}

/// Return the index to choose if the link connection is not overridden
#let link-fragment-index(angle, end, count, vertical) = {
  if not end {
    if vertical and angles.angle-in-range-strict(angle, 0deg, 180deg) {
      0
    } else if angles.angle-in-range-strict(angle, 90deg, 270deg) {
      0
    } else {
      count
    }
  } else {
    if vertical and angles.angle-in-range-strict(angle, 0deg, 180deg) {
      count
    } else if angles.angle-in-range-strict(angle, 90deg, 270deg) {
      count
    } else {
      0
    }
  }
}

#let fragment-link-anchor(name, id, count) = {
  if count <= id {
    panic("The last fragment only has " + str(count) + " connections")
  }
  if id == -1 {
    id = count - 1
  }
  (name: name, anchor: (str(id), "mid"))
}

#let link-fragment-anchor(name: none, id, count) = {
  if id >= count {
    panic("This fragment only has " + str(count) + " anchors")
  }
  if id == -1 {
    panic("The index of the fragment to link to must be defined")
  }
  if name == none {
    (name: str(id), anchor: "mid")
  } else {
    (name: name, anchor: (str(id), "mid"))
  }
}


#let calculate-mol-mol-link-anchors(ctx, cetz-ctx, link) = {
  let to-pos = (name: link.to-name, anchor: "mid")
  if link.to == none or link.from == none {
    let angle = link.at(
      "angle",
      default: angles.angle-between(cetz-ctx, link.from-pos, to-pos),
    )
    link.angle = angle
    if link.from == none {
      link.from = link-fragment-index(
        angle,
        false,
        ctx.hooks.at(link.from-name).count - 1,
        ctx.hooks.at(link.from-name).vertical,
      )
    }
    if link.to == none {
      link.to = link-fragment-index(
        angle,
        true,
        ctx.hooks.at(link.to-name).count - 1,
        ctx.hooks.at(link.to-name).vertical,
      )
    }
  }
  if link.from == -1 {
    link.from = 0
  }
  if link.to == -1 {
    link.to = ctx.hooks.at(link.to-name).count - 1
  }
  let start = fragment-anchor(ctx, cetz-ctx, link.angle, link.from-name, str(link.from))
  let end = fragment-anchor(ctx, cetz-ctx, link.angle + 180deg, link.to-name, str(link.to))
  ((start, end), angles.angle-between(cetz-ctx, start, end))
}

#let calculate-link-mol-anchors(ctx, cetz-ctx, link) = {
  if link.to == none {
    let angle = angles.angle-correction(
      angles.angle-between(
        cetz-ctx,
        link.from-pos,
        (name: link.to-name, anchor: "mid"),
      ),
    )
    link.to = link-fragment-index(
      angle,
      true,
      ctx.hooks.at(link.to-name).count - 1,
      ctx.hooks.at(link.to-name).vertical,
    )
    link.angle = angle
  } else if "angle" not in link {
    link.angle = angles.angle-correction(
      angles.angle-between(
        cetz-ctx,
        link.from-pos,
        (name: link.to-name, anchor: (str(link.to), "mid")),
      ),
    )
  }
  let end-anchor = fragment-anchor(
    ctx,
    cetz-ctx,
    link.angle + 180deg,
    link.to-name,
    str(link.to),
  )
  (
    (
      link.from-pos,
      end-anchor,
    ),
    angles.angle-between(cetz-ctx, link.from-pos, end-anchor),
  )
}

#let calculate-mol-link-anchors(ctx, cetz-ctx, link) = {
  (
    (
      fragment-anchor(ctx, cetz-ctx, link.angle, link.from-name, str(link.from)),
      link.name + "-end-anchor",
    ),
    link.angle,
  )
}

#let calculate-mol-hook-link-anchors(ctx, cetz-ctx, link) = {
  let hook = ctx.hooks.at(link.to-name)
  let angle = angles.angle-correction(angles.angle-between(cetz-ctx, link.from-pos, hook.hook))
  let from = link-fragment-index(
    angle,
    false,
    ctx.hooks.at(link.from-name).count - 1,
    ctx.hooks.at(link.from-name).vertical,
  )
  let start-anchor = fragment-anchor(ctx, cetz-ctx, angle, link.from-name, str(from))
  (
    (
      start-anchor,
      hook.hook,
    ),
    angles.angle-between(cetz-ctx, start-anchor, hook.hook),
  )
}

#let calculate-link-hook-link-anchors(ctx, cetz-ctx, link) = {
  let hook = ctx.hooks.at(link.to-name)
  (
    (
      link.from-pos,
      hook.hook,
    ),
    angles.angle-between(cetz-ctx, link.from-pos, hook.hook),
  )
}

#let calculate-link-link-anchors(link) = {
  ((link.from-pos, link.name + "-end-anchor"), link.angle)
}

#let calculate-link-anchors(ctx, cetz-ctx, link) = {
  if link.type == "mol-hook-link" {
    calculate-mol-hook-link-anchors(ctx, cetz-ctx, link)
  } else if link.type == "link-hook-link" {
    calculate-link-hook-link-anchors(ctx, cetz-ctx, link)
  } else if link.to-name != none and link.from-name != none {
    calculate-mol-mol-link-anchors(ctx, cetz-ctx, link)
  } else if link.to-name != none {
    calculate-link-mol-anchors(ctx, cetz-ctx, link)
  } else if link.from-name != none {
    calculate-mol-link-anchors(ctx, cetz-ctx, link)
  } else {
    calculate-link-link-anchors(link)
  }
}

