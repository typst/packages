#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": ac-sign, dc-sign
#import cetz.draw: anchor, arc, circle, content, line, rect, stroke

/// Piezoelectric crystal unit symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - current ("dc" | "ac"): type of current
/// -> content
#let piezo(name, node, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2 - style.spacing, -style.height / 2), (style.width / 2 + style.spacing, style.height / 2), io: position.len() < 2)

        stroke(style.stroke)
        rect((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2))
        line((-style.width / 2 - style.spacing, -style.height * 0.8 / 2), (rel: (0, style.height * 0.8)))
        line((style.width / 2 + style.spacing, -style.height * 0.8 / 2), (rel: (0, style.height * 0.8)))
    }

    // Constructor call
    symbol("piezo", name, node, draw: draw, ..params)
}
