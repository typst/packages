#import "/src/deps.typ": cetz
#import cetz.draw: bezier-through, catmull, circle, content, get-ctx, hobby, line, mark
#import cetz.styles: merge

#let resolve-directions(direction) = {
    let vertical = "north"
    let horizontal = "east"
    if "south" in direction {
        vertical = "south"
    }
    if "west" in direction {
        horizontal = "west"
    }
    return (x: horizontal, y: vertical)
}

#let resolve-decoration(ctx, deco, decor-type) = {
    if type(deco) == dictionary and deco.at("content", default: none) == none { panic("decoration dictionary needs at least the 'content' key") }

    let style = cetz.styles.resolve(ctx.style.zap.decoration, merge: if type(deco) == dictionary { deco } else { (content: deco) }, root: decor-type)
    style.size = cetz.util.measure(ctx, style.content)
    style.position = resolve-directions(style.anchor)
    style.side = if style.position.y == "north" { 1 } else { -1 }
    style.label-distance = style.at("label-distance", default: (0.1 + style.size.last()) * style.side)

    return style
}

/// Symbol current decoration
///
/// - label (content | dict): label content
/// -> content
#let current(label) = {
    get-ctx(ctx => {
        let style = resolve-decoration(ctx, label, "current")

        let mark-position = if style.position.x == "west" {
            (("in", style.distance, "symbol.west"), "in")
        } else {
            (("symbol.east", style.distance, "out"), "out")
        }

        mark(..mark-position, symbol: style.symbol, reverse: style.invert, anchor: "center", fill: cetz.util.resolve-stroke(style.stroke).paint, stroke: 0pt, scale: style.scale)
        content((rel: (0, style.label-distance), to: mark-position.at(0)), style.content)
    })
}

/// Symbol flow decoration
///
/// - label (content | dict): label content
/// -> content
#let flow(label) = {
    get-ctx(ctx => {
        let style = resolve-decoration(ctx, label, "flow")

        let west = style.position.x == "west"
        let a-start = (to: ("symbol." + style.position.x, style.distance, if west { "in" } else { "out" }), rel: (0, style.indent * style.side))
        let a-end = (to: a-start, rel: (style.length * if west { -1 } else { 1 }, 0))

        line(
            a-start,
            a-end,
            mark: (
                (if style.invert { "start" } else { "end" }): style.symbol,
                stroke: 0pt,
                fill: cetz.util.resolve-stroke(style.stroke).paint,
                scale: style.scale,
            ),
            stroke: style.stroke,
        )
        content((rel: (0, style.label-distance), to: (a-start, style.label-ratio, a-end)), style.content)
    })
}

/// Symbol voltage decoration
///
/// - label (content | dict): label content
/// -> content
#let voltage(label, p-rotate) = {
    get-ctx(ctx => {
        let style = resolve-decoration(ctx, label, "voltage")

        let r-distance = cetz.util.resolve-number(ctx, style.distance)
        let a-start = (rel: (style.start.at(0), (r-distance + style.start.at(1)) * style.side), to: "symbol." + style.position.y + "-west")
        let a-end = (rel: (style.end.at(0), (r-distance + style.end.at(1)) * style.side), to: "symbol." + style.position.y + "-east")
        let a-center = (rel: (style.center.at(0), (r-distance + style.center.at(1)) * style.side), to: "symbol." + style.position.y)

        let (a-start, a-end) = if style.position.x == "west" { (a-end, a-start) } else { (a-start, a-end) }
        content((rel: (0, style.label-distance), to: a-center), style.content)
        if (style.shape == "curved") {
            hobby(
                a-start,
                a-center,
                a-end,
                mark: (
                    (if style.invert { "start" } else { "end" }): style.symbol,
                    stroke: 0pt,
                    fill: cetz.util.resolve-stroke(style.stroke).paint,
                    scale: style.scale,
                ),
                stroke: style.stroke,
            )
        } else if (style.shape == "straight") {
            line(
                a-start,
                a-end,
                mark: (
                    (if style.invert { "start" } else { "end" }): style.symbol,
                    stroke: 0pt,
                    fill: cetz.util.resolve-stroke(style.stroke).paint,
                    scale: style.scale,
                ),
                stroke: style.stroke,
            )
        } else {
            panic("Only 'curved' and 'straight' variants are supported for voltage arrows")
        }
    })
}
