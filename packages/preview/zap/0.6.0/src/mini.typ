#import "deps.typ": cetz
#import cetz.draw: anchor, circle, hobby, line, merge-path, rotate, scope, set-origin, set-style
#import cetz.styles: merge

/// Default symbol styling dictionary
#let center-mark(symbol: ">", ..end) = {
    (end: ((pos: 50%, symbol: symbol, fill: black, anchor: "center", ..end.named()), (pos: 0%, symbol: ">", scale: 0)))
}

/// Mini lamp symbol
#let lamp(pos, radius: .5, ..params) = {
    circle(pos, radius: radius, ..params)
    line((rel: (radius: radius, angle: 45deg), to: pos), (rel: (radius: -radius, angle: 45deg), to: pos), ..params)
    line((rel: (radius: radius, angle: -45deg), to: pos), (rel: (radius: -radius, angle: -45deg), to: pos), ..params)
}

/// Mini arrow displayed on top of resistors/...
#let adjust-arrow(type, ..params) = {
    scope(ctx => {
        let style = cetz.styles.resolve(ctx.style.zap.arrow, merge: params.named(), root: type)

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
                fill: cetz.util.resolve-stroke(style.stroke).paint,
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

/// Default symbol styling dictionary
#let radiation-arrows(origin, ..params) = {
    scope(ctx => {
        let style = cetz.styles.resolve(ctx.style.zap.arrow, merge: params.named(), root: "radiation")

        set-origin(origin)
        rotate(style.angle)
        set-style(
            stroke: style.stroke,
            mark: (
                stroke: (thickness: 0pt),
                scale: style.scale,
                fill: cetz.util.resolve-stroke(style.stroke).paint,
            ),
        )

        let pos = if style.reversed { "start" } else { "end" }
        line((style.length, -style.distance), (0, -style.distance), mark: ((pos): style.symbol))
        line((style.length, +style.distance), (0, +style.distance), mark: ((pos): style.symbol))
    })
}

/// Default symbol styling dictionary
#let adjustable-arrow(node, ..params) = {
    scope(ctx => {
        let style = cetz.styles.resolve(ctx.style.zap.arrow, merge: params.named(), root: "adjustable")

        anchor("adjust", (to: node, rel: (0, style.length)))
        anchor("tip", node)

        line("adjust", "tip", stroke: style.stroke, mark: (
            stroke: (thickness: 0pt),
            end: style.symbol,
            scale: style.scale,
            fill: cetz.util.resolve-stroke(style.stroke).paint,
        ))
    })
    anchor("adjust", "adjust")
    anchor("a", "adjust")
    anchor("tip", "tip")
}

/// DC sign
#let dc-sign(ctx) = {
    let width = ctx.style.zap.sign.width
    let spacing = 1.5pt
    let vspace = 3pt
    let tick-width = (width - 2 * spacing) / 3

    set-style(stroke: ctx.style.zap.sign.stroke)

    line((-width / 2, 0), (width / 2, 0))
    line((-width / 2, -vspace), (-width / 2 + tick-width, -vspace))
    line((-tick-width / 2, -vspace), (tick-width / 2, -vspace))
    line((width / 2, -vspace), (width / 2 - tick-width, -vspace))
}

/// AC sign with different waveforms
#let ac-sign(ctx, waveform: "default") = {
    let width = ctx.style.zap.sign.width
    let height = ctx.style.zap.sign.height

    set-style(stroke: ctx.style.zap.sign.stroke)

    if waveform == "rect" {
        height *= 1.3
        width *= 0.8
        line(
            (-width / 2, 0),
            (rel: (0, height / 2)),
            (rel: (width / 2, 0)),
            (rel: (0, -height)),
            (rel: (width / 2, 0)),
            (rel: (0, height / 2)),
        )
    } else if waveform == "tri" {
        line(
            (-width / 2, -height / 2),
            (rel: (width / 3, height)),
            (rel: (width / 3, -height)),
            (rel: (width / 3, height)),
        )
    } else if waveform == "saw" {
        line(
            (-width / 2, -height / 2),
            (rel: (width / 2, height)),
            (rel: (0, -height)),
            (rel: (width / 2, height)),
        )
    } else {
        hobby(
            (-width / 2, 0),
            (-width / 4, height / 2),
            (width / 4, -height / 2),
            (width / 2, 0),
        )
    }
}

/// Default symbol styling dictionary
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
