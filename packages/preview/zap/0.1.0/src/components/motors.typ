#import "../component.typ": component
#import "../dependencies.typ": cetz
#import cetz.draw: anchor, rect, arc, line, circle, content, set-origin, group, rotate as cetzrotate, floating
#import "../mini.typ": dc-sign
#import "../utils.typ": quick-wires

#let dcmotor(uid, node, ..params) = {
    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    let sign-stroke = 0.6pt

    // IEC style constants
    let circle-radius = 15pt
    let width = 35pt
    let height = width / 4

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (position.len() == 2) {
                anchor("in", position.first())
                anchor("out", position.last())
            } else {
                anchor("in", (-circle-radius, 0))
                anchor("out", (circle-radius, 0))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (variant == "pretty") {
                rect((-width / 2, -height / 2), (width / 2, height / 2), fill: black, ..styling)
                circle((0,0), radius: circle-radius, fill: white)
            } else {
                circle((0,0), radius: width / 2, fill: white)
                content(
                  (0,0),
                  padding: .1,
                  rotate: -rotate,
                  anchor: "south",
                  $"M"$
                )
                cetzrotate(-rotate)
                set-origin((0,-5pt))
                dc-sign()
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            quick-wires(rotate, ..position)
        }
    )

    // Componant call
    component(uid, node, draw: draw, label-distance: 30pt, ..params)
}