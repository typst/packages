#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, arc, line
#import "/src/mini.typ": variable-arrow

#let capacitor(name, node, variable: false, polarized: false, ..params) = {
    assert(type(variable) == bool, message: "variable must be of type bool")

    // Capacitor style
    let style = (
        width: .8,
        distance: .25,
        radius: 0.6,
        angle: 40deg,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.distance / 2, -style.width / 2), (style.distance / 2, style.width / 2), io: position.len() < 2)

        if polarized {
            arc(
                (-style.distance / 2 - style.radius + style.radius * calc.cos(style.angle), style.radius * calc.sin(style.angle)),
                radius: style.radius,
                start: style.angle,
                stop: -style.angle,
                ..style,
            )
        } else {
            line((-style.distance / 2, -style.width / 2), (-style.distance / 2, style.width / 2), ..style)
        }
        line((style.distance / 2, -style.width / 2), (style.distance / 2, style.width / 2), ..style)
        if (variable) {
            variable-arrow()
        }
    }

    // Component call
    component("capacitor", name, node, draw: draw, style: style, ..params)
}

#let pcapacitor(name, node, ..params) = capacitor(name, node, polarized: true, ..params)
