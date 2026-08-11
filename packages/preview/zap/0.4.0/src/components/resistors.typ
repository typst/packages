#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, line, rect
#import "/src/mini.typ": variable-arrow

#let resistor(name, node, variable: false, heatable: false, adjustable: false, ..params) = {
    assert(type(variable) == bool, message: "variable must be of type bool")
    assert(type(adjustable) == bool, message: "adjustable must be of type bool")

    // Resistor style
    let style = (
        width: 1.41,
        height: .47,
        zigs: 3,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        if style.variant == "iec" {
            rect(
                (-style.width / 2, -style.height / 2),
                (
                    style.width / 2,
                    style.height / 2,
                ),
                fill: white,
                ..style,
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
                ..style,
                fill: none,
            )
        }
        if variable {
            variable-arrow()
        } else if adjustable {
            let arrow-length = .8
            anchor("a", (0, style.height / 2 + arrow-length))
            line("a", (0, style.height / 2), mark: (end: ">", fill: black), fill: none)
        }
        if heatable {
            for i in range(3) {
                let x = style.width / 4 * (i + 1) - style.width / 2
                line((x, -style.height / 2), (x, style.height / 2), ..style)
            }
        }
    }

    // Component call
    component("resistor", name, node, draw: draw, style: style, ..params)
}

#let rheostat(name, node, ..params) = resistor(name, node, variable: true, ..params)
#let potentiometer(name, node, ..params) = resistor(name, node, adjustable: true, ..params)
#let heater(name, node, ..params) = resistor(name, node, heatable: true, ..params)
