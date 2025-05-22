#import "/src/dependencies.typ": cetz
#import cetz.draw: bezier-through, catmull, circle, content, hobby, line, mark

#let get-label(label) = {
    let p-label = if type(label) == dictionary and "label" in label {
        label.label
    } else {
        label
    }
    let p-invert = label.at("invert", default: false)
    let p-position = if type(label) == dictionary and "position" in label and type(label.position) == alignment {
        label.position
    } else {
        end + top
    }
    (p-label, p-position, p-invert, label.at("distance", default: 50%))
}

#let current(ctx, label) = {
    let (p-label, p-position, p-invert, p-distance) = get-label(label)

    let (width, height) = cetz.util.measure(ctx, p-label)
    let side = if p-position.y == top { (1, ">", "<") } else { (-1, ">", "<") }

    if p-position.x == start {
        mark(("in", p-distance, "component.west"), "in", symbol: if p-invert { "<" } else { ">" }, anchor: "center", fill: black, scale: 0.8)
        content((rel: (0, (.2 + height) * side.first()), to: ("in", p-distance, "component.west")), p-label)
    } else {
        mark(("component.east", p-distance, "out"), "out", symbol: if p-invert { "<" } else { ">" }, anchor: "center", fill: black, scale: 0.8)
        content((rel: (0, (.2 + height) * side.first()), to: ("component.east", p-distance, "out")), p-label)
    }
}

#let flow(ctx, label) = {
    let (p-label, p-position, p-invert, p-distance) = get-label(label)

    let (width, height) = cetz.util.measure(ctx, p-label)

    let bottom = p-position.y == bottom

    let (a-start, a-end) = if p-position.x == start {
        let first = ("component.west", p-distance, "in")
        (first, (rel: (-.7, 0), to: first))
    } else {
        let first = ("component.east", p-distance, "out")
        (first, (rel: (.7, 0), to: first))
    }

    line(
        (rel: (0, if bottom { - .2 } else { .2 }), to: if p-invert { a-end } else { a-start }),
        (rel: (0, if bottom { -.2 } else { .2 }), to: if p-invert { a-start } else { a-end }),
        mark: (end: ">"),
        fill: black,
        stroke: 0.55pt,
        scale: 0.8,
    )
    content((rel: (0, height * if bottom { -2 } else { 2 }), to: (a-start, 50%, a-end)), p-label)
}

#let voltage(ctx, label, p-rotate) = {
    let (p-label, p-position, ..params) = get-label(label)

    let (width, height) = cetz.util.measure(ctx, p-label)
    let side = if p-position.y == top { (1, "north") } else { (-1, "south") }

    let a-start = (rel: (-.4, .1 * side.first()), to: "component." + side.last() + "-west")
    let a-end = (rel: (.4, .1 * side.first()), to: "component." + side.last() + "-east")
    let a-center = (rel: (0, .3 * side.first()), to: "component." + side.last())
    let a-label = (width / 2 * calc.abs(calc.sin(p-rotate)) + height / 2 * calc.abs(calc.cos(p-rotate)))

    content((rel: (0, 11pt * side.first()), to: a-center), p-label)
    if p-position.x == start {
        hobby(a-end, a-center, a-start, mark: (end: ">", fill: black), scale: 0.8, stroke: 0.55pt)
    } else {
        hobby(a-start, a-center, a-end, mark: (end: ">", fill: black), scale: 0.8, stroke: 0.55pt)
    }
}
