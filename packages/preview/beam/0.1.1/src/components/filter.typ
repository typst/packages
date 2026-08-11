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
/// #doc-points[1-2]
/// #doc-style("filter")
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
/// #doc-points[1-2]
/// #doc-style("filter-rot")
#let filter-rot(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
    /// flip the filter -> bool
    flip: false,
) = {
    let sketch(ctx, position, style) = {
        let h = style.diameter
        let w = style.stroke.thickness * 2
        if position.len() < 2 {
            anchor("in", (-w / 2, 0))
            anchor("out", (w / 2, 0))
        }
        translate(y: h / 4 * (1 - 2 * int(flip)))
        interface(
            (-w / 2, -h / 2),
            (w / 2, h / 2),
        )
        rect(
            (-w / 2, -w / 2),
            (w / 2, w / 2),
            fill: style.fill,
        )
        line((0, -h / 2), (0, h / 2), stroke: style.stroke)
    }
    component("filter-rot", name, ..points-style-decoration, sketch: sketch)
}
