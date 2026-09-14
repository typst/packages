#import "dependencies.typ": cetz
#import "utils.typ": get-style
#import cetz.draw: anchor, circle, hobby, line, merge-path, rotate, scope, set-origin, set-style
#import cetz.styles: merge

#let center-mark(symbol: ">") = {
    (end: ((pos: 50%, symbol: symbol, fill: black, anchor: "center"), (pos: 0%, symbol: ">", scale: 0)))
}

#let lamp(pos, radius: .5, ..params) = {
    circle(pos, radius: radius, ..params)
    line((rel: (radius: radius, angle: 45deg), to: pos), (rel: (radius: -radius, angle: 45deg), to: pos), ..params)
    line((rel: (radius: radius, angle: -45deg), to: pos), (rel: (radius: -radius, angle: -45deg), to: pos), ..params)
}

#let adjust-arrow(type, ..params) = {
    scope(ctx => {
        let arrow-style = get-style(ctx).arrow
        let style = merge(arrow-style.at(type), params.named())
        style.scale *= arrow-style.scale

        let origin = (
            -style.ratio.at(0) * calc.cos(style.angle) * style.length,
            -style.ratio.at(1) * calc.sin(style.angle) * style.length,
        )

        if type == "sensor" {
            anchor("label", origin)
            anchor("wiper", (to: origin, rel: (-style.sensor-length, 0)))
        } else {
            anchor("wiper", origin)
        }

        set-origin(origin)
        rotate(style.angle)

        anchor("tip", (style.length, 0))

        set-style(
            stroke: style.stroke,
            mark: (
                end: style.symbol,
                scale: style.scale,
            ),
        )
        if type == "variable" {
            line("wiper", "tip", mark: (
                stroke: (thickness: 0pt),
                fill: style.stroke.paint,
            ))
        } else if type == "preset" {
            line("wiper", "tip", mark: (
                stroke: style.stroke,
                width: style.width,
            ))
        } else if type == "sensor" {
            line("wiper", "label", "tip", mark: (
                stroke: style.stroke,
            ))
        }
    })
    if type == "sensor" {
        anchor("label", "label")
    }
    anchor("wiper", "wiper")
    anchor("tip", "tip")
}

#let radiation-arrows(origin, ..params) = {
    scope(ctx => {
        let arrow-style = get-style(ctx).arrow
        let style = merge(arrow-style.radiation, params.named())
        style.scale *= arrow-style.scale

        set-origin(origin)
        rotate(style.angle)
        set-style(
            stroke: style.stroke,
            mark: (
                stroke: (thickness: 0pt),
                scale: style.scale,
                fill: style.stroke.paint,
            ),
        )

        let pos = if style.reversed { "start" } else { "end" }
        line((style.length, -style.distance), (0, -style.distance), mark: ((pos): style.symbol))
        line((style.length, +style.distance), (0, +style.distance), mark: ((pos): style.symbol))
    })
}

#let adjustable-arrow(node, ..params) = {
    scope(ctx => {
        let arrow-style = get-style(ctx).arrow
        let style = merge(arrow-style.adjustable, params.named())
        style.scale *= arrow-style.scale

        anchor("adjust", (to: node, rel: (0, style.length)))
        anchor("tip", node)

        line("adjust", "tip", stroke: style.stroke, mark: (
            stroke: (thickness: 0pt),
            end: style.symbol,
            scale: style.scale,
            fill: style.stroke.paint,
        ))
    })
    anchor("adjust", "adjust")
    anchor("a", "adjust")
    anchor("tip", "tip")
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

#let clock-wedge(size: 1) = {
    let width = 5pt * size
    let height = 10pt * size
    let symbol-stroke = 0.55pt

    set-style(stroke: symbol-stroke)

    merge-path({
        line((0, height / 2), (width, 0))
        line((0, -height / 2), (width, 0))
    })
}
