#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// laser source
/// ```example
/// #beam.setup({
///     import beam: *
///     laser("", (0, 0))
/// })
/// ```
#let laser(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, points, style) = {
        interface((-style.length, -style.height / 2), (0, style.height / 2), io: points.len() < 2)

        rect(
            (-style.length, -style.height / 2),
            (-0.1 * style.length, style.height / 2),
            ..style,
        )
        rect(
            (-0.1 * style.length, -style.height / 3),
            (0, style.height / 3),
            ..style,
        )
    }
    component("laser", name, ..points-style-decoration, sketch: sketch, position: 0%)
}
