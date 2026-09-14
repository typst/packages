#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": adjust-arrow
#import cetz.draw: anchor, arc, line, merge-path, rect, set-style

#let inductor(name, node, variable: false, preset: false, sensor: false, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        set-style(stroke: style.stroke)
        if (style.variant == "iec") {
            rect((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), fill: style.fill)
        } else {
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
        }

        if variable {
            adjust-arrow("variable")
        } else if preset {
            adjust-arrow("preset")
        } else if sensor {
            adjust-arrow("sensor")
        }
    }

    // Component call
    component("inductor", name, node, draw: draw, ..params)
}
