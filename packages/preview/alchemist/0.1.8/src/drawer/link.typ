#import "../utils/angles.typ"
#import "../utils/anchors.typ": *

#let create-link-decorations-anchors(link, ctx) = {
  let link-angle = 0deg
  let to-name = none
  if ctx.in-cycle {
    if ctx.faces-count == ctx.cycle-faces - 1 and ctx.first-fragment != none {
      to-name = ctx.first-fragment
    }
    if ctx.faces-count == 0 {
      link-angle = ctx.relative-angle
    } else {
      link-angle = ctx.relative-angle + ctx.cycle-step-angle
    }
  } else {
    link-angle = angles.angle-from-ctx(ctx, link, ctx.angle)
  }
  link-angle = angles.angle-correction(link-angle)
  ctx.relative-angle = link-angle
  let override = angles.angle-override(link-angle, ctx)

  let to-connection = link.at("to", default: none)
  let from-connection = none
  let from-name = none

  let from-pos = if ctx.last-anchor.type == "coord" {
    ctx.last-anchor.anchor
  } else if ctx.last-anchor.type == "fragment" {
    from-connection = link-fragment-index(
      link-angle,
      false,
      ctx.last-anchor.count - 1,
      ctx.last-anchor.vertical,
    )
    from-connection = link.at("from", default: from-connection)
    from-name = ctx.last-anchor.name
    fragment-link-anchor(
      ctx.last-anchor.name,
      from-connection,
      ctx.last-anchor.count,
    )
  } else if ctx.last-anchor.type == "link" {
    ctx.last-anchor.name + "-end-anchor"
  } else {
    panic("Unknown anchor type " + ctx.last-anchor.type)
  }
  let length = link.at("atom-sep", default: ctx.config.atom-sep)
  let link-name = link.at("name")
  if ctx.record-vertex {
    if ctx.faces-count == 0 {
      ctx.vertex-anchors.push(from-pos)
    }
    if ctx.faces-count < ctx.cycle-faces - 1 {
      ctx.vertex-anchors.push(link-name + "-end-anchor")
    }
  }
  ctx = context_.set-last-anchor(
    ctx,
    (
      type: "link",
      name: link-name,
      override: override,
      from-pos: from-pos,
      from-name: from-name,
      from: from-connection,
      to-name: to-name,
      to: to-connection,
      angle: link-angle,
      over: link.at("over", default: none),
      draw: link.draw,
    ),
  )
  (
    ctx,
    {
      hide({
        circle(name: link-name + "-start-anchor", from-pos, radius: .25em)
      })
      let end-anchor = (to: from-pos, rel: (angle: link-angle, radius: length))
      if ctx.config.debug {
        line(from-pos, end-anchor, stroke: blue + .1em)
      }
      hide(
        {
          circle(name: link-name + "-end-anchor", end-anchor, radius: .25em)
        },
        bounds: true,
      )
    },
  )
}

#let draw-link(link, ctx) = {
  ctx.first-branch = false
  let drawing
  (ctx, drawing) = create-link-decorations-anchors(link, ctx)
  ctx.faces-count += 1
  if link.links.len() != 0 {
    ctx.hooks-links.push((link.links, ctx.last-anchor.name, false))
  }
  (ctx, drawing)
}
