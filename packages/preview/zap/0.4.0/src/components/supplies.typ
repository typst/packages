#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, line, polygon, scale, scope

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
        anchor("default", (0, 0))
    }

    // Component call
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
        anchor("default", (0, 0))
    }

    // Component call
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
        anchor("default", (0, 0))
    }

    // Component call
    component("earth", name, node, draw: draw, style: style, ..params)
}

#let vcc(name, node, invert: false, ..params) = {
    // VCC style
    let style = (
        angle: 35deg,
        radius: .4,
        distance: .6,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        let direction = if invert { -1 } else { 1 }
        let cos = calc.cos(style.angle) * style.radius
        let sin = calc.sin(style.angle) * style.radius
        scope({
            scale(y: direction)
            line((0, 0), (0, style.distance), ..style.at("wires"))
            line((rel: (-sin, -cos), to: (0, style.distance)), (0, style.distance), (rel: (sin, -cos)), ..style)
        })
        interface((-sin, (style.distance - cos) * direction), (sin, style.distance * direction), (0, 0), (0, 0), io: false)
        anchor("default", (0, 0))
    }

    // Component call
    component(
        "vcc",
        name,
        node,
        draw: draw,
        style: style,
        label-defaults: if invert { (anchor: "south", align: "north") } else { (a: 1) },
        ..params,
    )
}

#let vee(name, node, ..params) = vcc(name, node, invert: true, ..params)
