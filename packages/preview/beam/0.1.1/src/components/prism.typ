#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// dispersive prism
///
/// ```example
/// #beam.setup({
///     import beam: *
///     prism("", (0, 0))
/// })
/// ```
/// #doc-points[1 or 3]
/// #doc-style("prism")
#let prism(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, points, style) = {
        translate(x: 0.45 * style.radius)
        let x = style.radius * calc.sin(30deg)
        let y = style.radius * calc.cos(30deg)
        interface((x, y), (-style.radius, -y))

        polygon((0, 0), 3, angle: 180deg, ..style)
        translate(x: -0.45 * style.radius) // translate back to draw axis properly
    }
    component("prism", name, ..points-style-decoration, sketch: sketch, num-points: (1, 3))
}
