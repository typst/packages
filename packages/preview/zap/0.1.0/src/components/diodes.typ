#import "../component.typ": component
#import "../dependencies.typ": cetz
#import cetz.draw: anchor, polygon, line, rotate as cetzrotate, set-origin, floating, translate, merge-path
#import "../mini.typ": radiation-arrows
#import "../utils.typ": quick-wires

#let diode(uid, node, emitting: false, recieving: false, ..params) = {
    assert(type(emitting) == bool, message: "emitting must be of type bool")
    assert(type(recieving) == bool, message: "recieving must be of type bool")

    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    let sign-stroke = 0.6pt
    // IEC/ANSI/IEEE style constants
    let polygon-radius = 11pt
    let height = polygon-radius * calc.sin(calc.pi/4)
    let tangent = polygon-radius * calc.cos(calc.pi/4) * 0.7

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (position.len() == 2) {
                anchor("in", position.first())
                anchor("out", position.last())
            } else {
                anchor("in", (- polygon-radius/2, 0))
                anchor("out", (rel: (polygon-radius, 0)))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            translate((-0.08,0))
            polygon((0,0), 3, radius: .35, fill: white)
            line((0deg, .35), (180deg, .175), stroke: wires-stroke)
            line((polygon-radius - 1pt, -height), (polygon-radius - 1pt, height), stroke: component-stroke)
            let origin = (-tangent / 2, 20pt)
            if (emitting) {
                radiation-arrows(origin)
            } else if (recieving) {
                radiation-arrows(origin, reversed: true)
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            quick-wires(rotate, ..position)
        }
    )

    // Componant call
    component(uid, node, draw: draw, ..params)
}

#let led(uid, node, ..params) = diode(uid, node, emitting: true, ..params)
#let photodiode(uid, node, ..params) = diode(uid, node, recieving: true, ..params)