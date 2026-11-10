#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": ac-sign, dc-sign
#import cetz.draw: anchor, arc, circle, content, rect

/// Motor symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - current ("dc" | "ac"): type of current
/// -> content
#let motor(uid, name, node, current: "dc", ..params) = {
    assert(current in ("dc", "ac"), message: "current must be ac or dc")

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

        circle((0, 0), radius: style.radius, fill: style.fill, stroke: style.stroke)
        content((0, 0), anchor: "south", "M", padding: .03)
        let symbol = if current == "dc" { dc-sign } else { ac-sign }
        cetz.draw.scope({
            cetz.draw.rotate(-ctx.rotation)
            cetz.draw.translate(y: -0.2)
            cetz.draw.scale(0.7)
            symbol(ctx)
        })
    }

    // Constructor call
    symbol(uid, name, node, draw: draw, ..params)
}

#let dcmotor(name, node, ..params) = motor("dcmotor", name, node, ..params, current: "dc")
#let acmotor(name, node, ..params) = motor("acmotor", name, node, ..params, current: "ac")
