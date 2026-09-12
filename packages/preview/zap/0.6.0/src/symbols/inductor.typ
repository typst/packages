#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": adjust-arrow
#import cetz.draw: anchor, arc, line, merge-path, rect, set-style

/// Inductor symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - variable (bool): displays a diagonal arrow
/// - preset (bool): displays a diagonal arrow with flat end
/// - sensor (bool): displays a diagonal arrow with flat line
/// -> content
#let inductor(name, node, variable: false, preset: false, sensor: false, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        set-style(stroke: style.stroke)

        let bump-radius = style.width / style.bumps / 2
        merge-path({
            let sgn = if position.last().at(0) < position.first().at(0) { -1 } else { 1 }
            let start = (-style.width / 2 - bump-radius, 0)
            for i in range(style.bumps) {
                let arc-center-x = (
                    start.at(0) + bump-radius + i * 2 * bump-radius
                )
                let arc-center = (arc-center-x, 0)
                arc(arc-center, radius: bump-radius, start: sgn * 180deg, stop: 0deg)
            }
        })

        if variable {
            adjust-arrow("variable")
        } else if preset {
            adjust-arrow("preset")
        } else if sensor {
            adjust-arrow("sensor")
        }
    }

    // Constructor call
    symbol("inductor", name, node, draw: draw, ..params)
}
