#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": adjust-arrow
#import cetz.draw: anchor, arc, circle, line, merge-path, rect, set-style

/// Lamp symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// -> content
#let lamp(name, node, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

        set-style(stroke: style.stroke)
        circle((0, 0), radius: style.radius)
        line((45deg, style.radius), (-135deg, style.radius))
        line((135deg, style.radius), (-45deg, style.radius))
    }

    // Constructor call
    symbol("lamp", name, node, draw: draw, ..params)
}
