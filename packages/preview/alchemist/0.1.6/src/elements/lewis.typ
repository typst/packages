#import "@preview/cetz:0.3.4"

/// Create a lewis function that is then used to draw a lewis
/// formulae element around the fragment
///
/// - draw-function (function): The function that will be used to draw the lewis element. It should takes three arguments: the alchemist context, the cetz context, and a dictionary of named arguments that can be used to configure the links
/// -> function
#let build-lewis(draw-function) = {
  (..args) => {
    if args.pos().len() != 0 {
      panic("Lewis function takes no positional arguments")
    }
    let args = args.named()
    let angle = args.at("angle", default: none)
		let radius = args.at("radius", default: none)
    (
      angle: angle,
			radius: radius,
      draw: (ctx, cetz-ctx) => draw-function(ctx, cetz-ctx, args)
    )
  }
}

/// draw a sigle electron around the fragment
/// 
/// It is possible to change the distance from the center of
/// the electron with the `gap` argument. 
/// 
/// The position of the electron is set by the `offset` argument. Available values are:
/// - "top": the electron is placed above the fragment center line
/// - "bottom": the electron is placed below the fragment center line
/// - "center": the electron is placed at the fragment center line
/// 
/// It is also possible to change the `radius`, `stroke` and `fill` arguments
/// #example(```
/// #skeletize({
/// 	fragment("A", lewis:(
/// 		lewis-single(offset: "top"),
/// 	))
/// 	single(angle:-2)
///   fragment("B", lewis:(
/// 		lewis-single(offset: "bottom"),
/// 	))
/// 	single(angle:-2)
///   fragment("C", lewis:(
/// 		lewis-single(offset: "center"),
/// 	))
/// })
/// ```)
#let lewis-single = build-lewis((ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let radius = args.at("radius", default: ctx.config.lewis-single.radius)
  let gap = args.at("gap", default: ctx.config.lewis-single.gap)
  let offset = args.at("offset", default: ctx.config.lewis-single.offset)
  if offset == "top" {
    translate((0, gap))
  } else if offset == "bottom" {
    translate((0, -gap))
  } else if offset != "center" {
    panic("Invalid position, expected 'top', 'bottom' or 'center'")
  }
  let fill = args.at("fill", default: ctx.config.lewis-single.fill)
  let stroke = args.at("stroke", default: ctx.config.lewis-single.stroke)
  circle((0, 0), radius: radius, fill: fill, stroke: stroke)
})

/// Draw a pair of electron around the fragment
/// 
/// It is possible to change the distance from the center of
/// the electron with the `gap` argument.
/// It is also possible to change the `radius`, `stroke` and `fill` arguments
/// #example(```
/// #skeletize({
/// 	fragment("A", lewis:(
/// 		lewis-double(),
/// 		lewis-double(angle: 90deg),
/// 		lewis-double(angle: 180deg),
/// 		lewis-double(angle: -90deg)
/// 	))
/// })
/// ```)
#let lewis-double = build-lewis((ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let radius = args.at("radius", default: ctx.config.lewis-double.radius)
  let gap = args.at("gap", default: ctx.config.lewis-double.gap)
  let fill = args.at("fill", default: ctx.config.lewis-double.fill)
  let stroke = args.at("stroke", default: ctx.config.lewis-double.stroke)
  circle((0, -gap), radius: radius, fill: fill, stroke: stroke)
  circle((0, gap), radius: radius, fill: fill, stroke: stroke)
})

/// Draw a pair of electron liked by a single line
/// 
/// It is possible to change the length of the line with the `lenght` argument.
/// It is also possible to change the `stroke` agument
/// #example(```
/// #skeletize({
/// 	fragment("B", lewis:(
/// 		lewis-line(angle: 45deg),
/// 		lewis-line(angle: 135deg),
/// 		lewis-line(angle: -45deg),
/// 		lewis-line(angle: -135deg)
/// 	))
/// })
/// ```)
#let lewis-line = build-lewis((ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let length = args.at("length", default: ctx.config.lewis-line.length)
  let stroke = args.at("stroke", default: ctx.config.lewis-line.stroke)
  line((0, -length / 2), (0, length / 2), stroke: stroke)
})


/// Draw a rectangle to denote a lone pair of electrons
/// 
/// It is possible to change the height and width of the rectangle with the `height` and `width` arguments.
/// It is also possible to change the `fill` and `stroke` arguments
/// #example(```
/// #skeletize({
/// 	fragment("C", lewis:(
/// 		lewis-rectangle(),
/// 		lewis-rectangle(angle: 180deg)
/// 	))
/// })
/// ```)
#let lewis-rectangle = build-lewis((ctx, cetz-ctx, args) => {
  import cetz.draw: *
  let height = args.at("height", default: ctx.config.lewis-rectangle.height)
  let width = args.at("width", default: ctx.config.lewis-rectangle.width)
  let fill = args.at("fill", default: ctx.config.lewis-rectangle.fill)
  let stroke = args.at("stroke", default: ctx.config.lewis-rectangle.stroke)
  rect((-width / 2, -height / 2), (width / 2, height / 2), fill: fill, stroke: stroke)
})
