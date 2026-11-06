#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// pinhole / aperture
/// ```example
/// #beam.setup({
///     import beam: *
///     pinhole("", (0, 0))
/// })
/// ```
/// #doc-points[1-2]
/// #doc-style("pinhole")
#let pinhole(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, points, style) = {
        interface(
            (-style.width / 2, -style.height / 2),
            (style.width / 2, style.height / 2),
            io: points.len() < 2,
        )
        let inlet = style.height / 7

        for sign in (+1, -1) {
            rect(
                (-style.width / 2, sign * style.height / 2),
                (style.width / 2, sign * inlet),
                ..style,
            )
            rect(
                (-style.width / 6, sign * style.gap / 2),
                (style.width / 6, sign * inlet),
                ..style,
            )
        }
    }
    component("pinhole", name, ..points-style-decoration, sketch: sketch)
}
