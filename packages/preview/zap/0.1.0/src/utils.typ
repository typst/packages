#import "dependencies.typ": cetz

#let quick-wires(rotate, ..params) = {
    let position = params.pos()
    let wires-length = 20pt
    let wires-stroke = .6pt

    let p-rotate = rotate
    import cetz.draw: *

    if (position.len() == 2 and position.at(1, default: none) != none) {
        line(..position, stroke: wires-stroke)
    } else {
        line((to: position.first(), rel: (-wires-length, 0)), (to: position.first(), rel: (wires-length, 0)), stroke: wires-stroke)
    }
}