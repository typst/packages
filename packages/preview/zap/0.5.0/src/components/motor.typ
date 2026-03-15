#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": ac-sign, dc-sign
#import cetz.draw: anchor, arc, circle, content, rect

#let motor(uid, name, node, current: "dc", magnet: false, ..params) = {
    assert(current in ("dc", "ac"), message: "current must be ac or dc")
    assert(type(magnet) == bool, message: "magnet must be bool")
    assert(not (magnet and current == "ac"), message: "magnet only with dcmotor")

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

        if (magnet) {
            rect((-style.magnet-width / 2, -style.magnet-height / 2), (style.magnet-width / 2, style.magnet-height / 2), fill: style.stroke.paint)
        }
        circle((0, 0), radius: style.radius, fill: style.fill, stroke: style.stroke)
        content((0, 0), anchor: "south", "M", padding: .03)
        let symbol = if current == "dc" { dc-sign } else { ac-sign }
        content((0, 0), [#cetz.canvas({ symbol() })], anchor: "north", padding: .13)
    }

    // Component call
    component(uid, name, node, draw: draw, ..params)
}

#let dcmotor(name, node, ..params) = motor("dcmotor", name, node, ..params, current: "dc")
#let acmotor(name, node, ..params) = motor("acmotor", name, node, ..params, current: "ac")
