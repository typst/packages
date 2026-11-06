#import "../component.typ": component
#import "../dependencies.typ": cetz
#import cetz.vector: dist
#import cetz.draw: anchor, rect, line, circle, set-origin, scale as cetzscale, rotate as cetzrotate, floating, set-style, translate, scope
#import "../mini.typ": adjustable-arrow
#import "../utils.typ": quick-wires

#let resistor(uid, node, adjustable: false, movable: false, ..params) = {
    assert(type(adjustable) == bool, message: "adjustable must be of type bool")
    assert(type(movable) == bool, message: "movable must be of type bool")

    // TODO: move to package defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    let sign-stroke = 0.6pt

    // Style constants
    let width = 40pt
    let height = width / 3
    let zigs = 3

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (position.len() == 2) {
                anchor("in", position.first())
                anchor("out", position.last())
            } else {
                anchor("in", (rel: (-width/2, 0)))
                anchor("out", (rel: (width, 0)))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (variant == "iec") {
                rect((-width / 2, -height / 2), (width / 2, height / 2), fill: white, ..styling)
            } else {
                let step = width / (zigs * 2)
                let height = height
                let sign = -1
                let x = width / 2
                line((-x, 0), (rel: (step/2, height/2)),
                    ..for _ in range(zigs * 2 - 1) {
                    ((rel: (step, height * sign)),)
                    sign *= -1 },
                    (x, 0), fill: none
                )
            }

            if (adjustable) {
                adjustable-arrow()
            } else if (movable) {
                let arrow-length = 40pt
                let arrow-distance = 20pt
                let arrow-origin = (1.3*width/2, arrow-distance)
                anchor("adjust", arrow-origin)
                line(arrow-origin, (0, arrow-distance), (0,height/2), mark: (end: ">", fill: black))
            }
        },
        wires: (ctx, position, variant, scale, rotate, ..styling) => {
            if (position.len() == 2 and position.at(1, default: none) != none) {
                let distance = dist(position.first(), position.last()) - cetz.util.resolve-number(ctx, width * scale)
                line(position.first(), (rel: (angle: rotate, radius: distance / 2)), stroke: wires-stroke)
                line(position.last(), (rel: (angle: rotate + 180deg, radius: distance / 2)), stroke: wires-stroke)
            } else {
                line((to: position.first(), rel: (-wires-length, 0)), (to: position.first(), rel: (wires-length, 0)), stroke: wires-stroke)
            }
        }
    )

    // Componant call
    component(uid, node, draw: draw, ..params)
}

#let potentiometer(uid, node, ..params) = resistor(uid, node, adjustable: true, ..params)