#import "/src/component.typ": component, interface, wrap-ctx
#import "/src/anchor.typ": normalize-angle, rotation-around-z
#import "/src/dependencies.typ": cetz
#import cetz: vector
#import cetz.draw: *

/// laser beam
/// ```example
/// #beam.setup({
///     import beam: *
///     mirror("m1", (0, 1), (1, 0), (2, 1))
///     beam("", "m1.in", "m1", "m1.out")
/// })
/// ```
#let beam(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let points = points-style-decoration.pos()
    let style-decoration = points-style-decoration.named()
    assert(points.len() >= 2, message: "need at least 2 nodes")

    wrap-ctx(points, style-decoration, "beam", (ctx, points, style) => {
        on-layer(-1, line(..points, ..style, name: name))
    })
}

/// focusing laser beam
/// ```example
/// #beam.setup({
///     import beam: *
///     lens("l1", (1, 0))
///     lens("l2", (3, 0))
///     beam("", "l1", "l2")
///     focus("", (0, 0), "l1", flip: true)
///     focus("", "l2", (4, 0))
/// })
/// ```
#let focus(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
    /// flip the focus direction
    /// -> bool
    flip: false,
) = {
    let sketch(ctx, points, style) = {
        let ext = style.stroke.thickness
        let length = vector.dist(..points)
        interface(
            (-length / 2, -ext / 2),
            (length / 2, ext / 2),
        )

        let points = if flip {
            ("bounds.north-east", "bounds.west", "bounds.south-east")
        } else {
            ("bounds.north-west", "bounds.east", "bounds.south-west")
        }

        on-layer(-1, line(
            ..points,
            fill: style.stroke.paint,
            stroke: none,
            close: true,
        ))
    }
    component("beam", name, ..points-style-decoration, sketch: sketch, num-nodes: (2,), position: 50%)
}

/// fading laser beam
///
/// ```example
/// #beam.setup({
///     import beam: *
///     lens("l1", (0, 0), (2, 0))
///     focus("", "l1", "l1.in")
///     fade("", "l1", "l1.out")
/// })
/// ```
#let fade(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
    /// flip the fade direction
    /// -> bool
    flip: false,
) = {
    assert.eq(type(flip), bool, message: "flip must be bool")
    let points = points-style-decoration.pos()
    let style-decoration = points-style-decoration.named()
    if flip {
        points = points.rev()
    }

    get-ctx(ctx => {
        let initial-angle = rotation-around-z(ctx.transform)

        let sketch(ctx, points, style) = {
            let extent = style.stroke.thickness / ctx.length
            let color = style.stroke.paint

            // gradient fill is calculated with respect to the AABB.
            // Introduce an offset in the AABB corners to fit the gradient to the rendered shape
            let angle = initial-angle + vector.angle2(..points)
            let padding = (
                calc.abs(calc.sin(angle) * calc.cos(angle)) * extent
            )
            let length = cetz.vector.dist(..points)
            let ratios = (
                0,
                padding,
                length + padding,
                length + 2 * padding,
            )
            let colors = (
                color,
                color,
                color.transparentize(100%),
                color.transparentize(100%),
            )
            let fill = gradient.linear(
                ..colors.zip(ratios.map(it => 100% * (it / ratios.last()))),
                angle: -angle, //- angle
            )

            interface(
                (-length / 2, -extent / 2),
                (length / 2, extent / 2),
            )
            on-layer(-1, rect(
                "bounds.north-west",
                "bounds.south-east",
                fill: fill,
                stroke: none,
            ))
        }
        component("beam", name, ..points, ..style-decoration, sketch: sketch, num-nodes: (2,))
    })
}
