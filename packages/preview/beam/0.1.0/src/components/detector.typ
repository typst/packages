#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

/// detector / camera
/// ```example
/// #beam.setup({
///     import beam: *
///     detector("", (0, 0))
/// })
/// ```
#let detector(
    /// -> str
    name,
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    let sketch(ctx, position, style) = {
        interface((0, -style.radius), (style.radius, style.radius), io: true)

        arc((0, style.radius), start: 90deg, stop: -90deg, ..style)
    }
    component("detector", name, ..points-style-decoration, sketch: sketch, position: 100%)
}
