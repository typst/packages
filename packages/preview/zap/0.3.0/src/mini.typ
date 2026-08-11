#import "dependencies.typ": cetz
#import cetz.draw: anchor, hobby, line, rotate, scope, set-origin, set-style

#let center-mark(symbol: ">") = {
    (end: ((pos: 50%, symbol: symbol, fill: black, anchor: "center"), (pos: 0%, symbol: ">", scale: 0)))
}

#let variable-arrow() = {
    scope({
        let arrow-length = 40pt
        let arrow-angle = 55deg
        let arrow-origin = (
            -0.5 * calc.cos(arrow-angle) * arrow-length,
            -0.5 * calc.sin(arrow-angle) * arrow-length,
        )
        anchor("adjust", arrow-origin)

        set-origin(arrow-origin)
        rotate(arrow-angle)
        line((0, 0), (arrow-length, 0), mark: (end: ">", fill: black))
    })
}

#let radiation-arrows(origin, angle: -120deg, reversed: false, length: 12pt) = {
    scope({
        let arrows-distance = 3pt
        let arrows-length = length
        let arrows-scale = 0.8

        set-origin(origin)
        set-style(stroke: 0.55pt)
        rotate(angle)
        if (reversed) {
            line((arrows-length, -arrows-distance), (0, -arrows-distance), mark: (
                start: ">",
                scale: arrows-scale,
                fill: black,
            ))
            line((arrows-length, arrows-distance), (0, arrows-distance), mark: (
                start: ">",
                scale: arrows-scale,
                fill: black,
            ))
        } else {
            line((arrows-length, -arrows-distance), (0, -arrows-distance), mark: (
                end: ">",
                scale: arrows-scale,
                fill: black,
            ))
            line((arrows-length, arrows-distance), (0, arrows-distance), mark: (
                end: ">",
                scale: arrows-scale,
                fill: black,
            ))
        }
    })
}

#let dc-sign() = {
    let width = 10pt
    let spacing = 1.5pt
    let vspace = 3pt
    let symbol-stroke = 0.55pt
    let tick-width = (width - 2 * spacing) / 3

    set-style(stroke: symbol-stroke)

    line((-width / 2, 0), (width / 2, 0))
    line((-width / 2, -vspace), (-width / 2 + tick-width, -vspace))
    line((-tick-width / 2, -vspace), (tick-width / 2, -vspace))
    line((width / 2, -vspace), (width / 2 - tick-width, -vspace))
}

#let ac-sign(size: 1) = {
    let width = 10pt * size
    let height = 4pt * size
    let symbol-stroke = 0.55pt

    set-style(stroke: symbol-stroke)

    hobby((-width / 2, 0), (-width / 4, height / 2), (width / 4, -height / 2), (width / 2, 0))
}
