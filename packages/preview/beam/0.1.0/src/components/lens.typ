#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: *

#let kinds = ("()", "((", "))", ")(", "(|", ")|", "|)", "|(", "||")

/// lens
/// ```example
/// #beam.setup({
///     import beam: *
///     lens("", (0, 0))
///     lens("", (1.5, 0), kind: ")(")
///     lens("", (3, 0), kind: "(|")
/// })
/// ```
#let lens(
    /// -> str
    name,
    /// what kind of lens to draw. Supported lenses are
    /// #("()", "((", "))", ")(", "(|", ")|", "|)", "|(", "||").map(repr).map(raw.with(lang: "typc")).join([, ], last: [ and ])
    /// -> str
    kind: "()",
    /// -> coordinate | style | decoration
    ..points-style-decoration,
) = {
    assert(kind in kinds, message: "kind must be " + kinds.map(repr).join(", ", last: " or "))

    let sketch(ctx, points, style) = {
        interface(
            (-style.width / 2 - style.extent, -style.height / 2),
            (style.width / 2 + style.extent, style.height / 2),
            io: points.len() < 2,
        )

        merge-path(close: true, ..style, {
            let (offset-out, offset-in) = if kind.first() == "(" {
                (style.extent, 0)
            } else if kind.first() == "|" {
                (0, 0)
            } else {
                (0, style.extent)
            }
            arc-through(
                (to: "bounds.north-west", rel: (offset-out, 0)),
                (to: "bounds.west", rel: (offset-in, 0)),
                (to: "bounds.south-west", rel: (offset-out, 0)),
            )

            let (offset-out, offset-in) = if kind.last() == ")" {
                (-style.extent, 0)
            } else if kind.last() == "|" {
                (0, 0)
            } else {
                (0, -style.extent)
            }
            arc-through(
                (to: "bounds.south-east", rel: (offset-out, 0)),
                (to: "bounds.east", rel: (offset-in, 0)),
                (to: "bounds.north-east", rel: (offset-out, 0)),
            )
        })
    }
    component("lens", name, ..points-style-decoration, sketch: sketch)
}
