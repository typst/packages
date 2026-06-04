#import "../../component.typ": component
#import "../../dependencies.typ": cetz
#import cetz.draw: anchor, line, mark, translate, circle, set-origin, floating
#import "../../mini.typ": adjustable-arrow

#let mosfet(uid, node, channel: "n", envelope: false, mode: "enhancement", bulk: "internal", ..params) = {
    assert(type(envelope) == bool, message: "envelope must be of type bool")
    assert(mode in ("enhancement", "depletion"), message: "mode must be `enhancement` or `depletion`")
    assert(channel in ("p", "n"), message: "channel must be `p` or `n`")
    assert(bulk in ("internal", "external", none), message: "substrate must be `internal`, `external` or none")

    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt

    // Style constants
    let width = 20pt
    let base-spacing = 3pt
    let base-width = width + 8pt
    let bar-length = (base-width - 2*base-spacing)/3
    let height = 15pt
    let base-delta = 0pt

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            anchor("gate", (-height, 0))
            anchor("drain", (0, width / 2 + wires-length))
            anchor("source", (0, -width / 2 - wires-length))
            if bulk == "external"  {
                anchor("bulk", (0, 0))
            }
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if mode == "enhancement" {
                let bar-length = (base-width - 2*base-spacing)/3
                for i in range(3) {
                    line(((-height, -base-width/2 + i * (bar-length + base-spacing))), (rel: (0, bar-length)))
                }
            } else {
                line((-height, -base-width/2), (rel: (0, base-width)))
            }
            if bulk == "internal" {
                line((0,0), (0,-width/2), stroke: wires-stroke)
            }
            line("drain", (rel: (0, -wires-length)), (rel: (-height, 0)), stroke: wires-stroke)
            line("source", (rel: (0, wires-length)), (rel: (-height, 0)), stroke: wires-stroke)
            if bulk != none {
                line((-height, 0), (rel: (height, 0)), name: "line", stroke: wires-stroke)
                mark("line.centroid", "gate", symbol: if (channel == "n") { ">" } else { "<" }, fill: black, scale: 0.8, anchor: "center")
            } else {
                mark((-height/2,  if (channel == "n") { -width/2 } else { width/2 }), (rel: (height, 0)), symbol: if (channel == "n") { ">" } else { "<" }, fill: black, scale: 0.8, anchor: "center")
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {}
    )

    // Componant call
    component(uid, node, draw: draw, ..params)
}

#let pmos(uid, node, ..params) = mosfet(uid, node, channel: "p", ..params)
#let nmos(uid, node, ..params) = mosfet(uid, node, channel: "n", ..params)
#let pmosd(uid, node, ..params) = mosfet(uid, node, channel: "p", mode: "depletion", ..params)
#let nmosd(uid, node, ..params) = mosfet(uid, node, channel: "n", mode: "depletion", ..params)