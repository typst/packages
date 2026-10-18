#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: anchor, content, line, merge-path, on-layer, polygon, rect, scale, scope, translate

/// Analog-digital converter symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - input ('a' | 'd'): analog/digital input
/// -> content
#let adc(name, node, input: "a", ..params) = {
    assert(input in ("a", "d"), message: "input can only be d or a")

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        let inverse = if input == "d" { -1 } else { 1 }
        on-layer(0, {
            scope({
                scale(x: inverse)
                merge-path(
                    close: true,
                    {
                        line(
                            (-style.width / 2, style.height / 2),
                            (style.width / 2 - style.arrow-width, style.height / 2),
                            (style.width / 2, 0),
                            (style.width / 2 - style.arrow-width, -style.height / 2),
                            (-style.width / 2, -style.height / 2),
                            (-style.width / 2, style.height / 2),
                        )
                    },
                    stroke: style.stroke,
                    fill: style.fill,
                )
            })
        })

        anchor("vcc", (0, style.height / 2))
        anchor("gnd", (0, -style.height / 2))
        anchor("label", (-0.15 * if input == "d" { -1 } else { 1 }, 0))
    }

    // Constructor call
    symbol("converter", name, node, draw: draw, ..params)
}

#let dac(name, node, ..params) = adc(name, node, input: "d", ..params)
