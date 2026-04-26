#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// sample
/// ```example
/// #beam.setup({
///     import beam: *
///     sample("", (0, 0))
/// })
/// ```
/// #doc-points[1-2]
/// #doc-style("sample")
#let sample(
    /// -> str
    name,
    /// -> points | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, points, style) = {
        interface(
            (-style.width / 2, -style.height / 2),
            (style.width / 2, style.height / 2),
            io: points.len() < 2,
        )

        rect("bounds.north-west", "bounds.south-east", ..style)
    }
    component("sample", name, ..points-style-decoration, sketch: sketch)
}
