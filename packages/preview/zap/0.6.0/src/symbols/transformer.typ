#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: anchor, circle, hide, line, mark, merge-path, rect, set-style

/// Transformer symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// -> content
#let transformer(name, node, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.distance / 2 - style.radius, -style.radius), (style.distance / 2 + style.radius, style.radius), io: position.len() < 2)

        set-style(circle: (radius: style.radius))
        merge-path(
            join: false,
            stroke: none,
            fill: style.fill,
            {
                circle((-style.distance / 2, 0))
                circle((style.distance / 2, 0))
            },
        )

        set-style(stroke: style.stroke)
        circle((-style.distance / 2, 0))
        circle((style.distance / 2, 0))
    }

    // Constructor call
    symbol("transformer", name, node, draw: draw, ..params)
}
