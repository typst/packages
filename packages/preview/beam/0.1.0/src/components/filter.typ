#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// filter
/// ```example
/// #beam.setup({
///     import beam: *
///     filter("", (0, 0))
///     flip-filter("", (2, 0))
/// })
/// ```
#let filter(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, position, style) = {
        interface(
            (-style.width / 2, -style.height / 2),
            (style.width / 2, style.height / 2),
            io: position.len() < 2,
        )

        rect("bounds.north-west", "bounds.south-east", ..style)
    }
    component("filter", name, ..points-style-decoration, sketch: sketch)
}

#let flip-filter = filter.with(stroke: (dash: "densely-dashed"))

/// rotational filter / filter wheel
/// ```example
/// #beam.setup({
///     import beam: *
///     filter-rot("", (0, 0))
/// })
/// ```
#let filter-rot(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, position, style) = {
        interface(
            (-style.width / 2, -style.height / 2),
            (style.width / 2, style.height / 2),
            io: true,
        )

        translate(y: style.height / 6)
        rect(
            (-style.width / 2, -style.width / 2),
            (style.width / 2, style.width / 2),
            ..style,
        )
        line((0, -style.height / 3), (0, style.height / 3))
    }
    component("filter-rot", name, ..points-style-decoration, sketch: sketch)
}
