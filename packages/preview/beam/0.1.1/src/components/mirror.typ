#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

#let sketch(ctx, points, style, kind: ")") = {
    set-style(..style)
    if kind == "|" {
        interface((-style.width, -style.height / 2), (0, style.height / 2))
        rect("bounds.north-east", "bounds.south-west")
    } else {
        let (pad-out, pad-in) = if kind == ")" {
            (-style.extent, 0)
        } else if kind == "(" {
            (0, -style.extent)
        }
        translate(x: -pad-in)
        merge-path(close: true, {
            arc-through(
                (pad-out, style.height / 2),
                (pad-in, 0),
                (pad-out, -style.height / 2),
            )
            line(
                (-style.width, -style.height / 2),
                (-style.width, style.height / 2),
            )
            // translate(x: -pad-in)
            interface(
                (-style.width, -style.height / 2),
                (0, style.height / 2),
            )
        })
    }

    rect(
        "bounds.north-west",
        (to: "bounds.south-west", rel: (style.width * .33, 0)),
        ..style,
        fill: black,
        stroke: (dash: "solid"),
    )
}

/// mirror
/// ```example
/// #beam.setup({
///     import beam: *
///     mirror("", (0, 0))
///     flip-mirror("", (2, 0))
/// })
/// ```
/// #doc-points[1 or 3]
/// #doc-style("mirror")
#let mirror(
    /// -> str
    name,
    /// what kind of mirror to draw. Supported mirrors are
    /// #("(", ")", "|").map(repr).map(raw.with(lang: "typc")).join([, ], last: [ and ])
    /// -> str
    kind: "|",
    /// -> points | style | decoration
    ..points-style-decoration,
) = {
    component("mirror", name, ..points-style-decoration, sketch: sketch.with(kind: kind), num-points: (1, 3))
}

#let flip-mirror = mirror.with(stroke: (dash: "densely-dashed"))

/// refraction grating
/// ```example
/// #beam.setup({
///     import beam: *
///     grating("", (0, 0))
/// })
/// ```
/// #doc-points[1 or 3]
/// #doc-style("grating")
#let grating(
    /// -> str
    name,
    /// -> points | style | decoration
    ..points-style-decoration,
) = {
    component("grating", name, ..points-style-decoration, sketch: sketch.with(kind: "|"), num-points: (1, 3))
}
