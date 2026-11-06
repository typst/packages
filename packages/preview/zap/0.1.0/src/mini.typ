#import "dependencies.typ": cetz
#import cetz.draw: anchor, set-origin, rotate, line, set-style, hobby

#let adjustable-arrow() = {
    let arrow-length = 40pt
    let arrow-angle = 55deg
    let arrow-origin = (-0.5*calc.cos(arrow-angle)*arrow-length, -0.5*calc.sin(arrow-angle)*arrow-length)
    anchor("adjust", arrow-origin)

    set-origin(arrow-origin)
    rotate(arrow-angle)
    line((0,0), (arrow-length,0), mark: (end: ">", fill: black))
}

#let radiation-arrows(origin, reversed: false) = {
    let arrows-distance = 3.5pt
    let arrows-length = 14pt
    let arrows-scale = 0.8

    set-origin(origin)
    set-style(stroke: 0.6pt)
    rotate(-27deg)
    if (reversed) {
        line((arrows-length,-arrows-distance), (0,-arrows-distance), mark: (start: ">", scale: arrows-scale, fill: black))
        line((arrows-length,arrows-distance), (0,arrows-distance), mark: (start: ">", scale: arrows-scale, fill: black))
    } else {
        line((arrows-length,-arrows-distance), (0,-arrows-distance), mark: (end: ">", scale: arrows-scale, fill: black))
        line((arrows-length,arrows-distance), (0,arrows-distance), mark: (end: ">", scale: arrows-scale, fill: black))
    }
}

#let dc-sign() = {
    let width = 12pt
    let spacing = 1.5pt
    let vspace = 3.5pt
    let symbol-stroke = 0.6pt
    let tick-width = (width - 2 * spacing ) / 3

    set-style(stroke: symbol-stroke)

    line((-width/2, 0), (width/2, 0))
    line((-width/2, -vspace), (-width/2 + tick-width, -vspace))
    line((-tick-width/2, -vspace), (tick-width/2, -vspace))
    line((width/2, -vspace), (width/2 - tick-width, -vspace))
}

#let ac-sign() = {
    let width = 12pt
    let height = 12
    let symbol-stroke = 0.6pt

    set-style(stroke: symbol-stroke)

    hobby((-1.5, 0), (-.5, 1), (.5, -1), (1.5, 0), omega: 0)
}