#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// beam splitter cube
/// ```example
/// #beam.setup({
///     import beam: *
///     beam-splitter("", (0, 0))
/// })
/// ```
#let beam-splitter(
    /// -> name
    name,
    /// -> points | style | decoration
    ..points-style-decoration,
    /// flip along local y-axis -> bool
    flip: false,
) = {
    assert.eq(type(flip), bool, message: "flip must be bool")

    let sketch(ctx, points, style) = {
        if points.len() == 3 {
            rotate(-45deg)
        }

        interface(
            (-style.width / 2, -style.height / 2),
            (style.width / 2, style.height / 2),
            io: points.len() < 2,
        )

        let (p1, p2) = if flip {
            ("bounds.north-east", "bounds.south-west")
        } else {
            ("bounds.north-west", "bounds.south-east")
        }
        rect(p1, p2, ..style)
        line(p1, p2, ..style)
        rotate(45deg - 90deg * int(flip)) // fix axis rotation
    }
    component("beam-splitter", name, ..points-style-decoration, sketch: sketch, num-points: (1, 2, 3))
}

/// beam splitter plate
/// ```example
/// #beam.setup({
///     import beam: *
///     beam-splitter-plate("", (0, 0))
/// })
/// ```
#let beam-splitter-plate(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, points, style) = {
        if points.len() == 2 { rotate(135deg) }

        interface(
            (0, -style.height / 2),
            (-style.width / 2, style.height / 2),
        )

        rect("bounds.north-west", "bounds.south-east", ..style)
    }
    component("beam-splitter-plate", name, ..points-style-decoration, sketch: sketch, num-points: (1, 2, 3))
}
