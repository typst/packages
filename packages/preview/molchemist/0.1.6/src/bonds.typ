// Bond glyphs extend Alchemist links with CTfile query and coordination styles.
#import "@preview/alchemist:0.2.0": *

#let _molchemist-dashed-stroke(stroke, dash) = {
  if stroke == none or stroke == auto {
    stroke
  } else if type(stroke) == dictionary {
    stroke + (dash: dash)
  } else if type(stroke) == color {
    (paint: stroke, dash: dash)
  } else if type(stroke) == length {
    (thickness: stroke, dash: dash)
  } else {
    (paint: stroke.paint, thickness: stroke.thickness, dash: dash)
  }
}

#let _molchemist-partial-double(dash) = build-link((length, ctx, cetz-ctx, args) => {
  let args = args
  let offset = args.at("offset", default: ctx.config.double.offset)
  let key = if offset == "left" { "stroke-left" } else { "stroke-right" }
  let stroke = args.at(key, default: args.at("stroke", default: ctx.config.double.stroke))
  args.insert(key, _molchemist-dashed-stroke(stroke, dash))
  (double(..args).first().draw)(length, ctx, cetz-ctx)
})

#let _molchemist-dashed-single(dash) = build-link((length, ctx, cetz-ctx, args) => {
  let args = args
  let stroke = args.at("stroke", default: ctx.config.single.stroke)
  args.insert("stroke", _molchemist-dashed-stroke(stroke, dash))
  (single(..args).first().draw)(length, ctx, cetz-ctx)
})

#let _molchemist-dashed-double = build-link((length, ctx, cetz-ctx, args) => {
  let args = args
  let stroke = args.at("stroke", default: ctx.config.double.stroke)
  args.insert("stroke-left", _molchemist-dashed-stroke(args.at("stroke-left", default: stroke), "dashed"))
  args.insert("stroke-right", _molchemist-dashed-stroke(args.at("stroke-right", default: stroke), "dashed"))
  (double(..args).first().draw)(length, ctx, cetz-ctx)
})

#let _molchemist-wavy = build-link((length, ctx, _, args) => {
  import cetz.draw: *
  cetz.decorations.wave(
    line((0, 0), (length, 0), stroke: none),
    segments: 8,
    amplitude: .12,
    stroke: args.at("stroke", default: ctx.config.single.stroke),
  )
})

#let _molchemist-crossed-double = build-link((length, ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let gap = utils.convert-length(
    cetz-ctx,
    args.at("gap", default: ctx.config.double.gap),
  ) / 2
  let stroke = args.at("stroke", default: ctx.config.double.stroke)
  line(
    (0, -gap),
    (length, gap),
    stroke: args.at("stroke-right", default: stroke),
  )
  line(
    (0, gap),
    (length, -gap),
    stroke: args.at("stroke-left", default: stroke),
  )
})

#let _molchemist-quadruple = build-link((length, ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let gap = utils.convert-length(
    cetz-ctx,
    args.at("gap", default: ctx.config.double.gap),
  )
  let stroke = args.at("stroke", default: ctx.config.double.stroke)
  for offset in (-1.5, -0.5, 0.5, 1.5) {
    line(
      (0, offset * gap),
      (length, offset * gap),
      stroke: stroke,
    )
  }
})

#let _molchemist-coordination-right = build-link((length, ctx, _, args) => {
  import cetz.draw: *
  line(
    (0, 0),
    (length, 0),
    stroke: args.at("stroke", default: ctx.config.single.stroke),
    mark: (end: ">", fill: black),
  )
})

#let _molchemist-coordination-left = build-link((length, ctx, _, args) => {
  import cetz.draw: *
  line(
    (0, 0),
    (length, 0),
    stroke: args.at("stroke", default: ctx.config.single.stroke),
    mark: (start: ">", fill: black),
  )
})

#let _molchemist-aromatic = _molchemist-partial-double("dashed")
#let _molchemist-single-or-double = _molchemist-partial-double("dotted")
#let _molchemist-single-or-aromatic = _molchemist-dashed-single("dashed")
#let _molchemist-double-or-aromatic = _molchemist-dashed-double
#let _molchemist-hydrogen = _molchemist-dashed-single("dotted")

#let get-b-func(b-type) = {
  if b-type == "double" { double }
  else if b-type == "triple" { triple }
  else if b-type == "quadruple" { _molchemist-quadruple }
  else if b-type == "aromatic" { _molchemist-aromatic }
  else if b-type == "single-or-double" { _molchemist-single-or-double }
  else if b-type == "single-or-aromatic" { _molchemist-single-or-aromatic }
  else if b-type == "double-or-aromatic" { _molchemist-double-or-aromatic }
  else if b-type == "any" or b-type == "either" { _molchemist-wavy }
  else if b-type == "crossed-double" { _molchemist-crossed-double }
  else if b-type == "coordination-right" { _molchemist-coordination-right }
  else if b-type == "coordination-left" { _molchemist-coordination-left }
  else if b-type == "hydrogen" { _molchemist-hydrogen }
  else if b-type == "cram-filled-right" { cram-filled-right }
  else if b-type == "cram-filled-left" { cram-filled-left }
  else if b-type == "cram-dashed-right" { cram-dashed-right }
  else if b-type == "cram-dashed-left" { cram-dashed-left }
  else { single }
}
