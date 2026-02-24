#import "../../component.typ": component
#import "../../dependencies.typ": cetz
#import cetz.draw: anchor, line, mark, circle, translate, scale as cetzscale, floating
#import "../../mini.typ": adjustable-arrow

#let bjt(uid, node, polarisation: "npn", envelope: false, ..params) = {
    assert(polarisation in ("npn", "pnp"), message: "polarisation must `npn` or `pnp`")
    assert(type(envelope) == bool, message: "envelope must be of type bool")

    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt

    // Style constants
    let radius = 20pt
    let angle = 50deg
    let width = 24pt
    let distance = 13pt
    let base = (-6pt, 0)
    let emitter = (calc.cos(angle) * radius, calc.sin(angle) * radius)
    let collector = (calc.cos(angle) * radius, -calc.sin(angle) * radius)
    if (polarisation == "npn") {
        let temp = emitter
        emitter = collector
        collector = temp
    }
    let wires-direction = - ((int(polarisation == "npn") + 1) * 2 - 3)

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            translate((-emitter.at(0), 0))
            if (envelope) {
                anchor("base", (-radius - wires-length, 0))
                anchor("emitter", (emitter.at(0), emitter.at(1) + wires-direction * wires-length))
                anchor("collector", (collector.at(0), collector.at(1) - wires-direction * wires-length))
            } else if (not envelope) {
                anchor("base", (base.at(0) - wires-length, 0))
                anchor("emitter", (emitter.at(0), emitter.at(1) + wires-direction * wires-length))
                anchor("collector", (collector.at(0), collector.at(1) - wires-direction * wires-length))
            } else {
                anchor("base", base)
                anchor("emitter", emitter)
                anchor("collector", collector)
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if (envelope) {
                line(base, (x: -radius), stroke: wires-stroke)
            }
            line((base.at(0), wires-direction * distance/2), emitter, name:"line", stroke: wires-stroke)
            line((base.at(0), -distance/2 * wires-direction), collector, name: "line2", stroke: wires-stroke)
            mark("line.centroid", emitter, symbol: if (polarisation == "npn") { ">" } else { "<" }, fill: black, scale: 0.9, anchor: "center")
            if (envelope) {
                circle((0,0), radius: radius, stroke: component-stroke)
            }
            line((base.at(0), -width/2), (base.at(0), width/2), stroke: component-stroke)
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            floating(line("base", (rel: (wires-length,0)), stroke: wires-stroke))
            floating(line("emitter", (rel: (0, -wires-length * wires-direction)), stroke: wires-stroke))
            floating(line("collector", (rel: (0, wires-length * wires-direction)), stroke: wires-stroke))
            translate((-emitter.at(0), 0))
        }
    )

    // Componant call
    component(uid, node, draw: draw, ..params)
}

#let pnp(uid, node, ..params) = bjt(uid, node, polarisation: "pnp", ..params)
#let npn(uid, node, ..params) = bjt(uid, node, polarisation: "npn", ..params)