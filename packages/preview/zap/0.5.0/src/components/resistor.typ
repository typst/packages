#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": adjust-arrow, adjustable-arrow
#import cetz.draw: anchor, line, rect, set-style

#let resistor(name, node, variable: false, heatable: false, adjustable: false, preset: false, sensor: false, ..params) = {
    assert(type(variable) == bool, message: "variable must be of type bool")
    assert(type(adjustable) == bool, message: "adjustable must be of type bool")

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        set-style(stroke: style.stroke)
        if style.variant == "iec" {
            rect(
                (-style.width / 2, -style.height / 2),
                (
                    style.width / 2,
                    style.height / 2,
                ),
                fill: style.fill,
            )
        } else {
            let step = style.width / (style.zigs * 2)
            let sign = -1
            let x = style.width / 2
            line(
                (-x, 0),
                (rel: (step / 2, style.height / 2)),
                ..for _ in range(style.zigs * 2 - 1) {
                    ((rel: (step, style.height * sign)),)
                    sign *= -1
                },
                (x, 0),
            )
        }
        if variable {
            adjust-arrow("variable")
        } else if preset {
            adjust-arrow("preset")
        } else if sensor {
            adjust-arrow("sensor")
        } else if adjustable {
            adjustable-arrow((0, style.height / 2))
        }
        if heatable {
            for i in range(3) {
                let x = style.width / 4 * (i + 1) - style.width / 2
                line((x, -style.height / 2), (x, style.height / 2))
            }
        }
    }

    // Component call
    component("resistor", name, node, draw: draw, ..params)
}

#let rheostat(name, node, ..params) = resistor(name, node, ..params, variable: true)
#let potentiometer(name, node, ..params) = resistor(name, node, ..params, adjustable: true)
#let heater(name, node, ..params) = resistor(name, node, ..params, heatable: true)
