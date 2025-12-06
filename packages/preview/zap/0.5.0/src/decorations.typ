#import "/src/dependencies.typ": cetz
#import "/src/utils.typ": get-style, resolve-style
#import cetz.draw: bezier-through, catmull, circle, content, hobby, line, mark
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

#let resolve-decoration(ctx, dec, decor-type) = {
    if type(dec) == dictionary and dec.at("content", default: none) == none { panic("Decoration dictionary needs at least the 'content' key") }

    let zap-style = ctx.zap.style
    zap-style.decoration.at(decor-type) = merge(zap-style.decoration.at(decor-type), if type(dec) == dictionary { dec } else { (content: dec) })

    let dec = resolve-style(zap-style).decoration.at(decor-type)
    dec.size = cetz.util.measure(ctx, dec.content)
    dec.position = resolve-directions(dec.anchor)
    dec.side = if dec.position.y == "north" { 1 } else { -1 }
    dec.label-distance = dec.at("label-distance", default: (0.1 + dec.size.last()) * dec.side)

    return dec
}

#let current(ctx, label) = {
    let style = resolve-decoration(ctx, label, "current")
    style.scale *= get-style(ctx).decoration.scale

    let mark-position = if style.position.x == "west" {
        (("in", style.distance, "component.west"), "in")
    } else {
        (("component.east", style.distance, "out"), "out")
    }

    mark(..mark-position, symbol: style.symbol, reverse: style.invert, anchor: "center", fill: style.stroke.paint, stroke: 0pt, scale: style.scale)
    content((rel: (0, style.label-distance), to: mark-position.at(0)), style.content)
}

#let flow(ctx, label) = {
    let style = resolve-decoration(ctx, label, "flow")
    style.scale *= get-style(ctx).decoration.scale

    let west = style.position.x == "west"
    let a-start = (to: ("component." + style.position.x, style.distance, if west { "in" } else { "out" }), rel: (0, style.indent * style.side))
    let a-end = (to: a-start, rel: (style.length * if west { -1 } else { 1 }, 0))

    line(
        a-start,
        a-end,
        mark: (
            (if style.invert { "start" } else { "end" }): style.symbol,
            stroke: 0pt,
            fill: style.stroke.paint,
            scale: style.scale,
        ),
        stroke: style.stroke,
    )
    content((rel: (0, style.label-distance), to: (a-start, style.label-ratio, a-end)), style.content)
}

#let voltage(ctx, label, p-rotate) = {
    let style = resolve-decoration(ctx, label, "voltage")
    style.scale *= get-style(ctx).decoration.scale

    let r-distance = cetz.util.resolve-number(ctx, style.distance)
    let a-start = (rel: (style.start.at(0), (r-distance + style.start.at(1)) * style.side), to: "component." + style.position.y + "-west")
    let a-end = (rel: (style.end.at(0), (r-distance + style.end.at(1)) * style.side), to: "component." + style.position.y + "-east")
    let a-center = (rel: (style.center.at(0), (r-distance + style.center.at(1)) * style.side), to: "component." + style.position.y)

    let (a-start, a-end) = if style.position.x == "west" { (a-end, a-start) } else { (a-start, a-end) }
    content((rel: (0, style.label-distance), to: a-center), style.content)
    hobby(
        a-start,
        a-center,
        a-end,
        mark: (
            (if style.invert { "start" } else { "end" }): style.symbol,
            stroke: 0pt,
            fill: style.stroke.paint,
            scale: style.scale,
        ),
        stroke: style.stroke,
    )
}
