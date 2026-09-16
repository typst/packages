#import "@preview/cetz:0.4.2"
#import cetz.draw: *
#import "utils.typ": handle-auto, update-dict

/// Draw a cardinality box.
/// -> content
#let _draw-cardinality-box(
  /// Coordinates of the box.
  /// -> array
  coordinates,
  /// Its unique name to be referred as.
  /// -> str
  name: none,
  /// Its label (e.g. (0,1)).
  /// -> str
  label: none,
  /// Whether this box is actually an hierarchy.
  /// -> bool
  hierarchy: false,
  /// All arguments passed to ```typ #std.box()```.
  /// -> args
  ..args,
) = {
  get-ctx(ctx => {
    let handle-cardinality-fill = {
      if ctx.settings.fill.cardinality == auto {
        handle-auto(page.fill, white)
      } else {
        ctx.settings.fill.cardinality
      }
    }

    let final-handle(arg, override: none) = {
      let cardinality = ctx.settings.at(arg).cardinality
      if override != none {
        cardinality = override
      }
      if not hierarchy { cardinality } else {
        handle-auto(ctx.settings.at(arg).hierarchy, cardinality)
      }
    }

    let box-args = update-dict(
      (
        stroke: final-handle("stroke"),
        radius: final-handle("radius"),
        fill: final-handle("fill", override: handle-cardinality-fill),
      ),
      args.named(),
    )
    let label-content = align(
      center,
      (final-handle("text"))(label),
    )
    content(
      coordinates,
      box(
        ..box-args,
        label-content,
      ),
      name: name,
    )
  })
}
