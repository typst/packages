#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

#let sketch(ctx, points, style) = {
    interface((-style.height, -style.width / 2), (0, style.width / 2))

    // how to handle 2-part component styles?
    rect((-style.height * .67, -style.width / 2), (0, style.width / 2), ..style)
    rect(
        (-style.height, -style.width / 2),
        (-style.height * .67, style.width / 2),
        fill: black,
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
#let mirror(
    /// -> str
    name,
    /// -> points | style | decoration
    ..points-style-decoration,
) = {
    component("mirror", name, ..points-style-decoration, sketch: sketch, num-points: (1, 3))
}

#let flip-mirror = mirror.with(stroke: (dash: "densely-dashed"))

/// refraction grating
/// ```example
/// #beam.setup({
///     import beam: *
///     grating("", (0, 0))
/// })
/// ```
#let grating(
    /// -> str
    name,
    /// -> points | style | decoration
    ..points-style-decoration,
) = {
    component("grating", name, ..points-style-decoration, sketch: sketch, num-points: (1, 3))
}
