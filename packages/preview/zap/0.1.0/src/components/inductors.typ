#import "../component.typ": component
#import "../dependencies.typ": cetz
#import cetz.vector: dist
#import cetz.draw: anchor, rect, arc, line, floating
#import "../utils.typ": quick-wires

#let inductor(uid, node, ..params) = {
    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    let sign-stroke = 0.6pt
    // IEC style constants
    let width = 40pt
    let height = width / 3

    // IEEE/ANSI style constants
    let bumps = 3
    let bump-radius = width / bumps / 2

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (position.len() == 2) {
                anchor("in", position.first())
                anchor("out", position.last())
            } else {
                anchor("in", (-width/2, 0))
                anchor("out", (rel: (width, 0)))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (variant == "iec") {
                rect((-width / 2, -height / 2), (width / 2, height / 2), fill: black, ..styling)
            } else {
                let start = (-width / 2 - bump-radius, 0pt)
                for i in range(bumps) {
                    let arc-center-x = start.at(0) + bump-radius + i * 2 * bump-radius
                    let arc-center = (arc-center-x, 0pt)
                    arc(arc-center, radius: bump-radius, start: 180deg, stop: 0deg)
                }
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
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