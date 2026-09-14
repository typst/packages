#import "@preview/cetz:0.3.4"
#import "../utils/utils.typ"

/// Draw a triangle between two fragments
#let cram(from, to, ctx, cetz-ctx, args) = {
  let (cetz-ctx, (from-x, from-y, _)) = cetz.coordinate.resolve(cetz-ctx, from)
  let (cetz-ctx, (to-x, to-y, _)) = cetz.coordinate.resolve(cetz-ctx, to)
  let base-length = utils.convert-length(
    cetz-ctx,
    args.at("base-length", default: ctx.config.filled-cram.base-length),
  )
  cetz.draw.line(
    (from-x, from-y - base-length / 2),
    (from-x, from-y + base-length / 2),
    (to-x, to-y),
    close: true,
    stroke: args.at("stroke", default: ctx.config.filled-cram.stroke),
    fill: args.at("fill", default: ctx.config.filled-cram.fill),
  )
}

/// Draw a dashed triangle between two molecules fragments
#let dashed-cram(from, to, length, ctx, cetz-ctx, args) = {
	import cetz.draw: *
  let (cetz-ctx, (from-x, from-y, _)) = cetz.coordinate.resolve(cetz-ctx, from)
  let (cetz-ctx, (to-x, to-y, _)) = cetz.coordinate.resolve(cetz-ctx, to)
  let base-length = utils.convert-length(
    cetz-ctx,
    args.at("base-length", default: ctx.config.dashed-cram.base-length),
  )
  let tip-length = utils.convert-length(
    cetz-ctx,
    args.at("tip-length", default: ctx.config.dashed-cram.tip-length),
  )
  hide({
    line(name: "top", (from-x, from-y - base-length / 2), (to-x, to-y - tip-length / 2))
    line(
      name: "bottom",
      (from-x, from-y + base-length / 2),
      (to-x, to-y + tip-length / 2),
    )
  })
  let stroke = args.at("stroke", default: ctx.config.dashed-cram.stroke)
  let dash-gap = utils.convert-length(cetz-ctx, args.at("dash-gap", default: ctx.config.dashed-cram.dash-gap))
  let dash-width = stroke.thickness
  let converted-dash-width = utils.convert-length(cetz-ctx, dash-width)
  let length = utils.convert-length(cetz-ctx, length)

  let dash-count = int(calc.ceil(length / (dash-gap + converted-dash-width)))
  let incr = 100% / dash-count

  let percentage = 0%
  while percentage <= 100% {
    line(
      (name: "top", anchor: percentage),
      (name: "bottom", anchor: percentage),
      stroke: stroke,
    )
    percentage += incr
  }
}