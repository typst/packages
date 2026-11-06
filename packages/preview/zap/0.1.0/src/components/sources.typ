#import "../component.typ": component
#import "../dependencies.typ": cetz
#import cetz.draw: anchor, rect, line, circle, mark, rotate as cetzrotate, floating
#import "../utils.typ": quick-wires

#let isource(uid, node, current: "dc", ..params) = {
    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    // Style constants
    let radius = 15pt
    let padding = 7pt
    let arrow-scale = 1.4

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (position.len() == 2) {
                anchor("minus", position.first())
                anchor("plus", position.last())
            } else {
                anchor("minus", (rel: (-radius, 0), to: position.first()))
                anchor("plus", (rel: (2*radius, 0)))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            circle((0, 0), radius: radius, fill: white, ..styling)
            if (variant == "iec") {
                line((0, -radius), (rel: (0, 2*radius)), stroke: component-stroke)
            } else {
                line((-radius + padding, 0), (rel: (2*radius - 1.85*padding, 0)), mark: (end: ">"), fill: black, stroke: component-stroke)
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            quick-wires(rotate, ..position)
        }
    )

    // Componant call
    component(uid, node, draw: draw, label-distance: 27pt, ..params)
}

#let acisource(uid, node, ..params) = isource(uid, node, current: "ac", ..params)

#let vsource(uid, node, current: "dc", ..params) = {
    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    let sign-stroke = 0.6pt
    // Style constants
    let radius = 15pt
    let padding = 7pt
    let sign-size = 4pt
    let sign-delta = 2pt

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (position.len() == 2) {
                anchor("minus", position.first())
                anchor("plus", position.last())
            } else {
                anchor("minus", (-radius, 0))
                anchor("plus", (rel: (2*radius, 0)))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            circle((0, 0), radius: (radius, radius), fill: white, ..styling)
            if (variant == "iec") {
                line((-radius, 0), (rel: (2*radius, 0)))
            } else {
                line((rel: (- radius + padding, -sign-size)), (rel:  (0, 2*sign-size)), stroke: sign-stroke)
                line((radius - padding - sign-delta, -sign-size),(rel: (0, 2*sign-size)), stroke: sign-stroke)
                line((rel: (sign-size, -sign-size)),(rel: (-2*sign-size, 0)), stroke: sign-stroke)
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            quick-wires(rotate, ..position)
        }
    )

    // Componant call
    component(uid, node, draw: draw, label-distance: 27pt, ..params)
}

#let acvsource(uid, node, ..params) = vsource(uid, node, current: "ac", ..params)