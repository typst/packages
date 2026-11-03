#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/symbols/wire.typ": wire
#import cetz.draw: anchor, circle, hide, line, mark, rect

/// Switch symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - closed (bool): switch state
/// -> content
#let switch(name, node, closed: false, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -0.2), (style.width / 2, 0.2), io: position.len() < 2)

        wire((-style.width / 2, 0), (radius: style.width / 2, angle: if closed { 0deg } else { style.angle }))
    }

    // Constructor call
    symbol("switch", name, node, draw: draw, ..params)
}
