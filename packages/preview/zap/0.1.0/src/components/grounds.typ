#import "../component.typ": component
#import "../dependencies.typ": cetz
#import cetz.draw: anchor, polygon, line, rotate as cetzrotate, set-origin, merge-path
#import "../mini.typ": radiation-arrows

#let ground(uid, node, type: "signal", ..params) = {
    assert(type in ("signal", "earth", "frame"), message: "type must `signal`, `earth` or `frame`")

    // TODO: move to defaults
    let wires-length = 7pt
    let component-stroke = 1pt
    let wires-stroke = 0.6pt
    let sign-stroke = 0.6pt

    // IEC/ANSI/IEEE style constants
    let earth-l1 = wires-length * 2.4
    let earth-l2 = wires-length * 1.4
    let earth-l3 = wires-length * 0.7
    let earth-spacing = wires-length * 0.35

    let signal-width = 12pt
    let signal-height = 9pt

    let frame-width = 15pt
    let frame-diag-len = 8pt
    let frame-angle = 60deg
    let frame-spacing = frame-width / 4
    let symbol-distance = wires-length + 5pt

    // Drawing functions
    let draw = (
        anchors: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            anchor("in", (0, 0))
        },
        component: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            if type == "earth" {
                let y1 = -symbol-distance
                let y2 = y1 - earth-spacing
                let y3 = y2 - earth-spacing
                line((-earth-l1/2, y1), (earth-l1/2, y1))
                line((-earth-l2/2, y2), (earth-l2/2, y2))
                line((-earth-l3/2, y3), (earth-l3/2, y3))
            } else if type == "frame" or type == "chassis" {
                 let y = -symbol-distance
                 let x1 = -frame-width/2
                 let x2 = 0pt
                 let x3 = frame-width/2
                 let dy = frame-diag-len * calc.sin(frame-angle)
                 let dx = frame-diag-len * calc.cos(frame-angle)
                 line((x2, y), (x2 - dx, y - dy))
                 line((x1 - dx, y - dy), (-frame-width/2, y), (frame-width/2, y), (x3 - dx, y - dy))
            } else {
                line((0, -signal-height - symbol-distance), (-signal-width / 2, -symbol-distance), (signal-width / 2, -symbol-distance), close: true)
            }
        },
        wires: (ctx, position, variant, scale, rotate, wires, ..styling) => {
            set-origin(position.first())
            line((0,0), (rel: (0, -symbol-distance)), stroke: wires-stroke)
        }
    )

    // Componant call
    component(uid, node, draw: draw, ..params)
}

#let earth(uid, node, ..params) = ground(uid, node, type: "earth", ..params)
#let frame(uid, node, ..params) = ground(uid, node, type: "frame", ..params)