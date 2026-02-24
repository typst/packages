#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, line
#import "/src/mini.typ": variable-arrow

#let capacitor(name, node, variable: false, ..params) = {
    assert(type(variable) == bool, message: "variable must be of type bool")

    // Capacitor style
    let style = (
        width: .8,
        distance: .25,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.distance / 2, -style.width / 2), (style.distance / 2, style.width / 2), io: position.len() < 2)

        line((-style.distance / 2, -style.width / 2), (-style.distance / 2, style.width / 2), ..style)
        line((style.distance / 2, -style.width / 2), (style.distance / 2, style.width / 2), ..style)
        if (variable) {
            variable-arrow()
        }
    }

    // Componant call
    component("capacitor", name, node, draw: draw, style: style, ..params)
}
