#import "/src/dependencies.typ": cetz
#import cetz.draw: bezier-through, catmull, circle, content, hobby, line, mark

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

#let resolve-decoration(ctx, dec) = {
    if type(dec) == dictionary and dec.at("content", default: none) == none { panic("Decoration dictionary needs at least the 'content' key") }
    return if type(dec) == dictionary {
        let p-size = cetz.util.measure(ctx, dec.at("content"))
        let directions = resolve-directions(dec.at("anchor", default: "north-east"))
        let p-side = if directions.y == "north" { 1 } else { -1 }
        (
            dec.at("content", default: none),
            dec.at("distance", default: 9pt),
            p-size,
            dec.at("invert", default: false),
            directions,
            dec.at("label-distance", default: (0.1 + p-size.last()) * p-side),
            p-side
        )
    } else {
        let p-size = cetz.util.measure(ctx, dec)
        (dec, 9pt, p-size, false, (x: "east", y: "north"), (0.1 + p-size.last()), 1)
    }
}

#let current(ctx, label) = {
    let (p-label, p-distance, p-size, p-invert, p-position, p-label-distance, p-side) = resolve-decoration(ctx, label)

    let mark-position = if p-position.x == "west" {
        (("in", p-distance, "component.west"), "in")
    } else {
        (("component.east", p-distance, "out"), "out")
    }

    mark(..mark-position, symbol: if p-invert { "<" } else { ">" }, anchor: "center", fill: black, scale: 0.8)
    content((rel: (0, p-label-distance), to: mark-position.at(0)), p-label)
}

#let flow(ctx, label) = {
    let (p-label, p-distance, p-size, p-invert, p-position, p-label-distance, p-side) = resolve-decoration(ctx, label)

    let (a-start, a-end) = if p-position.x == "west" {
        let first = ("component.west", p-distance, "in")
        (first, (rel: (-.7, 0), to: first))
    } else {
        let first = ("component.east", p-distance, "out")
        (first, (rel: (.7, 0), to: first))
    }
    let a-start = (rel: (0, if p-side { -.2 } else { .2 }), to: a-start)
    let a-end = (rel: (0, if p-side { -.2 } else { .2 }), to: a-end)
    let (a-start, a-end) = if p-invert { (a-end, a-start) } else { (a-start, a-end) }

    line(a-start, a-end, mark: (end: ">"), fill: black, stroke: 0.55pt, scale: 0.8)
    content((rel: (0, p-label-distance), to: (a-start, 50%, a-end)), p-label)
}

#let voltage(ctx, label, p-rotate) = {
    let (p-label, p-distance, p-size, p-invert, p-position, p-label-distance, p-side) = resolve-decoration(ctx, label)

    let a-start = (rel: (-.4, .1 * p-side), to: "component." + p-position.y + "-west")
    let a-end = (rel: (.4, .1 * p-side), to: "component." + p-position.y + "-east")
    let a-center = (rel: (0, .3 * p-side), to: "component." + p-position.y)

    content((rel: (0, p-label-distance), to: a-center), p-label)
    if p-position.x == "west" {
        hobby(a-end, a-center, a-start, mark: (end: ">", fill: black), scale: 0.8, stroke: 0.55pt)
    } else {
        hobby(a-start, a-center, a-end, mark: (end: ">", fill: black), scale: 0.8, stroke: 0.55pt)
    }
}
