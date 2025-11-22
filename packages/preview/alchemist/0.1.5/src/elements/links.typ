#import "@preview/cetz:0.3.4"
#import "../drawer/cram.typ": *
#import "../utils/utils.typ"


/// Create a link function that is then used to draw a link between two points
///
/// - draw-function (function): The function that will be used to draw the link. It should takes four arguments: the length of the link, the alchemist context, the cetz context, and a dictionary of named arguments that can be used to configure the links
/// -> function
#let build-link(draw-function) = {
  (..args) => {
    if args.pos().len() != 0 {
      panic("Links takes no positional arguments")
    }
    let args = args.named()
    (
      (
        type: "link",
        draw: (length, ctx, cetz-ctx, override: (:)) => {
          let args = args
          for (key, val) in override {
            args.insert(key, val)
          }
          draw-function(length, ctx, cetz-ctx, args)
        },
        links: (:),
        ..args,
      ),
    )
  }
}

/// Draw a single line between two molecules
/// #example(```
/// #skeletize({
///   molecule("A")
///   single()
///   molecule("B")
/// })
///```)
/// It is possible to change the color and width of the line
/// with the `stroke` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   single(stroke: red + 5pt)
///   molecule("B")
/// })
///```)
#let single = build-link((length, ctx, _, args) => {
  import cetz.draw: *
  line((0, 0), (length, 0), stroke: args.at("stroke", default: ctx.config.single.stroke))
})

/// Draw a double line between two molecules
/// #example(```
/// #skeletize({
///   molecule("A")
///   double()
///   molecule("B")
/// })
///```)
/// It is possible to change the color and width of the line
/// with the `stroke` argument and the gap between the two lines
/// with the `gap` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   double(
///     stroke: orange + 2pt,
///     gap: .8em
///   )
///   molecule("B")
/// })
///```)
/// This link also supports an `offset` argument that can be set to `left`, `right` or `center`.
///It allows to make either the let side, right side or the center of the double line to be aligned with the link point.
/// #example(```
/// #skeletize({
///   molecule("A")
///   double(offset: "right")
///   molecule("B")
///   double(offset: "left")
///   molecule("C")
///   double(offset: "center")
///   molecule("D")
/// })
///```)
#let double = build-link((length, ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let gap = utils.convert-length(cetz-ctx, args.at("gap", default: ctx.config.double.gap)) / 2
  let offset = args.at("offset", default: ctx.config.double.offset)
  let coeff = args.at("offset-coeff", default: ctx.config.double.offset-coeff)
  if coeff < 0 or coeff > 1 {
    panic("Invalid offset-coeff value: must be between 0 and 1")
  }
  if offset == "right" {
    translate((0, -gap))
  } else if offset == "left" {
    translate((0, gap))
  } else if offset == "center" { } else {
    panic("Invalid offset value: must be \"left\", \"right\" or \"center\"")
  }

  translate((0, -gap))
  line(
    ..if offset == "right" {
      let x = length * (1 - coeff) / 2
      ((x, 0), (x + length * coeff, 0))
    } else {
      ((0, 0), (length, 0))
    },
    stroke: args.at("stroke", default: ctx.config.double.stroke),
  )
  translate((0, 2 * gap))
  line(
    ..if offset == "left" {
      let x = length * (1 - coeff) / 2
      ((x, 0), (x + length * coeff, 0))
    } else {
      ((0, 0), (length, 0))
    },
    stroke: args.at("stroke", default: ctx.config.double.stroke),
  )
})

/// Draw a triple line between two molecules
/// #example(```
/// #skeletize({
///   molecule("A")
///   triple()
///   molecule("B")
/// })
///```)
/// It is possible to change the color and width of the line
/// with the `stroke` argument and the gap between the three lines
/// with the `gap` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   triple(
///     stroke: blue + .5pt,
///     gap: .15em
///   )
///   molecule("B")
/// })
///```)
#let triple = build-link((length, ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let gap = utils.convert-length(cetz-ctx, args.at("gap", default: ctx.config.triple.gap))
  line((0, 0), (length, 0), stroke: args.at("stroke", default: ctx.config.triple.stroke))
  translate((0, -gap))
  line((0, 0), (length, 0), stroke: args.at("stroke", default: ctx.config.triple.stroke))
  translate((0, 2 * gap))
  line((0, 0), (length, 0), stroke: args.at("stroke", default: ctx.config.triple.stroke))
})

/// Draw a filled cram between two molecules with the arrow pointing to the right
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-filled-right()
///   molecule("B")
/// })
///```)
/// It is possible to change the stroke and fill color of the arrow
/// with the `stroke` and `fill` arguments. You can also change the base length of the arrow with the `base-length` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-filled-right(
///     stroke: red + 2pt,
///     fill: green,
///     base-length: 2em
///   )
///   molecule("B")
/// })
///```)
#let cram-filled-right = build-link((length, ctx, cetz-ctx, args) => cram(
  (0, 0),
  (length, 0),
  ctx,
  cetz-ctx,
  args,
))

/// Draw a filled cram between two molecules with the arrow pointing to the left
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-filled-left()
///   molecule("B")
/// })
///```)
/// It is possible to change the stroke and fill color of the arrow
/// with the `stroke` and `fill` arguments. You can also change the base length of the arrow with the `base-length` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-filled-left(
///     stroke: red + 2pt,
///     fill: green,
///     base-length: 2em
///   )
///   molecule("B")
/// })
///```)
#let cram-filled-left = build-link((length, ctx, cetz-ctx, args) => cram(
  (length, 0),
  (0, 0),
  ctx,
  cetz-ctx,
  args,
))

/// Draw a hollow cram between two molecules with the arrow pointing to the right
/// It is a shorthand for `cram-filled-right(fill: none)`
#let cram-hollow-right = build-link((length, ctx, cetz-ctx, args) => {
  args.fill = none
  args.stroke = args.at("stroke", default: black)
  cram((0, 0), (length, 0), ctx, cetz-ctx, args)
})

/// Draw a hollow cram between two molecules with the arrow pointing to the left
/// It is a shorthand for `cram-filled-left(fill: none)`
#let cram-hollow-left = build-link((length, ctx, cetz-ctx, args) => {
  args.fill = none
  args.stroke = args.at("stroke", default: black)
  cram((length, 0), (0, 0), ctx, cetz-ctx, args)
})

/// Draw a dashed cram between two molecules with the arrow pointing to the right
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-dashed-right()
///   molecule("B")
/// })
///```)
/// It is possible to change the stroke of the lines in the arrow
/// with the `stroke` argument. You can also change the arrow base length with the `base-length` argument and the tip length with the `tip-length` argument.
// You can also change distance between the dashes with the `dash-gap` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-dashed-right(
///     stroke: red + 2pt,
///     base-length: 2em,
///     tip-length: 1em,
///     dash-gap: .5em
///   )
///   molecule("B")
/// })
///```)
#let cram-dashed-right = build-link((length, ctx, cetz-ctx, args) => dashed-cram(
  (0, 0),
  (length, 0),
  length,
  ctx,
  cetz-ctx,
  args,
))

/// Draw a dashed cram between two molecules with the arrow pointing to the left
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-dashed-left()
///   molecule("B")
/// })
///```)
/// It is possible to change the stroke of the lines in the arrow
/// with the `stroke` argument. You can also change the base length of the arrow with the `base-length` argument and distance between the dashes with the `dash-gap` argument
/// #example(```
/// #skeletize({
///   molecule("A")
///   cram-dashed-left(
///     stroke: red + 2pt,
///     base-length: 2em,
///     dash-gap: .5em
///   )
///   molecule("B")
/// })
///```)
#let cram-dashed-left = build-link((length, ctx, cetz-ctx, args) => dashed-cram(
  (length, 0),
  (0, 0),
  length,
  ctx,
  cetz-ctx,
  args,
))