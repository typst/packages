#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, line, polygon

#let ground(name, node, ..params) = {
    assert(params.pos().len() == 0, message: "ground supports only one node")

    // Ground style
    let style = (
        radius: 0.22,
        distance: 0.28,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        line((0, 0), (0, -style.distance), ..style.at("wires"))
        polygon((0, -style.distance), 3, anchor: "north", radius: style.radius, angle: -90deg, name: "polygon", ..style)

        let (width, height) = cetz.util.measure(ctx, "polygon")
        interface((-width / 2, -height / 2), (width / 2, height / 2))
    }

    // Componant call
    component("ground", name, node, draw: draw, style: style, ..params)
}

#let frame(name, node, ..params) = {
    assert(params.pos().len() == 0, message: "earth supports only one node")

    // Earth style
    let style = (
        width: 0.46,
        angle: 20deg,
        depth: 0.25,
        distance: 0.28,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        line((0, 0), (0, -style.distance), ..style.at("wires"))
        let delta = style.width / 2
        line((-style.width / 2, -style.distance), (style.width / 2, -style.distance), ..style)
        for i in (0, 1, 2) {
            line((-style.width / 2 + (1 - i) * .01 + i * delta, -style.distance), (rel: (angle: -style.angle - 90deg, radius: style.depth)), ..style)
        }
        interface((-style.width / 2, style.distance), (style.width / 2, -style.distance))
    }

    // Componant call
    component("frame", name, node, draw: draw, style: style, ..params)
}

#let earth(name, node, ..params) = {
    assert(params.pos().len() == 0, message: "earth supports only one node")

    // Earth style
    let style = (
        width: .53,
        delta: .09,
        spacing: .11,
        distance: .28,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        line((0, 0), (0, -style.distance), ..style.at("wires"))
        for i in (0, 1, 2) {
            line((-style.width / 2 + i * style.delta, -style.distance - i * style.spacing), (style.width / 2 - i * style.delta, -style.distance - i * style.spacing), ..style)
        }
        interface((-style.width / 2, -style.distance - style.spacing * 2), (style.width / 2, -style.distance))
    }

    // Componant call
    component("earth", name, node, draw: draw, style: style, ..params)
}

#let vcc(name, node, ..params) = {
    // VCC style
    let style = (
        angle: 35deg,
        radius: .4,
        distance: .6,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        line((0, 0), (0, style.distance), ..style.at("wires"))
        line((rel: (radius: style.radius, angle: -90deg - style.angle), to: (0, style.distance)), (0, style.distance), (
            rel: (radius: style.radius, angle: -90deg + style.angle),
        ))

        let (width, height) = (calc.sin(style.angle) * style.radius, calc.cos(style.angle) * style.radius)
        interface((-width / 2, 0), (width / 2, style.distance))
    }

    // Componant call
    component("vcc", name, node, draw: draw, style: style, ..params)
}

#let vee(name, node, label: none, ..params) = {
    // VEE style
    let style = (
        angle: 35deg,
        radius: .4,
        distance: .6,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        line((0, 0), (0, -style.distance), ..style.at("wires"))
        line((rel: (radius: style.radius, angle: 90deg + style.angle), to: (0, -style.distance)), (0, -style.distance), (
            rel: (radius: style.radius, angle: 90deg - style.angle),
        ))

        let (width, height) = (calc.sin(style.angle) * style.radius, calc.cos(style.angle) * style.radius)
        interface((-width / 2, -style.distance), (width / 2, 0))
    }

    let p-label = label
    // Label position
    if p-label != none {
        p-label = if type(label) == dictionary {
            (content: label.at("content", default: none), anchor: label.at("anchor", default: "south"), distance: label.at("distance", default: 7pt))
        } else {
            (content: label, anchor: "south")
        }
    }

    // Componant call
    component("vee", name, node, draw: draw, style: style, label: p-label, ..params)
}
