#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// microscopy objective
/// ```example
/// #beam.setup({
///     import beam: *
///     objective("", (0, 0), rotate: 90deg)
/// })
/// ```
#let objective(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, points, style) = {
        let w = style.width
        let h = style.height

        interface(
            (-w / 2, -h / 2),
            (w / 2, h / 2),
            io: points.len() < 2,
        )

        line(
            (-h / 2, -w / 2),
            (h * .3, -w / 2),
            (h / 2, -w * .3),
            (h / 2, w * .3),
            (h * .3, w / 2),
            (-h / 2, w / 2),
            close: true,
            ..style,
        )
    }
    component("objective", name, ..points-style-decoration, sketch: sketch)
}
