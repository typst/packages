#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": ac-sign
#import "/src/utils.typ": get-style
#import cetz.draw: anchor, arc-through, circle, rotate

#let circulator(name, node, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius), io: false)

        circle((0, 0), radius: style.radius, fill: white, ..style, name: "circle")
        anchor("port1", "circle.west")
        anchor("port2", "circle.east")
        anchor("port3", "circle.north")
        /*
         * Waiting on https://github.com/cetz-package/cetz/issues/981 to be fixed
        arc((0, 0), radius: style.arrow-radius, start: 45deg, delta: 90deg, anchor: "origin", ..style, stroke: red, fill: red)
         * in the meantime the arc-through is used below
         */

        rotate(53deg)
        arc-through((0, -style.arrow-radius), (0, style.arrow-radius), (-style.arrow-radius, 0), mark: (end: ">", fill: black, anchor: "tip", inset: -.04))
    }

    // Component call
    component("circulator", name, node, draw: draw, ..params)
}
