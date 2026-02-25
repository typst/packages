#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": ac-sign
#import "/src/utils.typ": get-style
#import cetz.draw: anchor, circle, content, line, mark, polygon, rect, set-style

#let isource(name, node, dependent: false, current: "dc", ..params) = {
    assert(type(dependent) == bool, message: "dependent must be boolean")
    assert(current in ("dc", "ac"), message: "current must be ac or dc")

    // Drawing function
    let draw(ctx, position, style) = {
        let factor = if dependent { 1.1 } else { 1 }
        interface((-style.radius * factor, -style.radius * factor), (style.radius * factor, style.radius * factor), io: position.len() < 2)

        set-style(stroke: style.stroke)
        if dependent {
            polygon((0, 0), 4, fill: style.fill, radius: style.radius * factor)
        } else {
            circle((0, 0), fill: style.fill, radius: style.radius)
        }
        if style.variant == "iec" {
            line((0, -style.radius * factor), (rel: (0, 2 * style.radius * factor)))
        } else {
            line(
                (-style.radius + style.padding, 0),
                (rel: (2 * style.radius - 1.85 * style.padding, 0)),
                mark: (end: ">", scale: style.arrow-scale * params.at("scale", default: style.scale.at("x", default: 1.0))),
                fill: get-style(ctx).arrow.stroke.paint,
                stroke: get-style(ctx).arrow.stroke,
            )
        }
    }

    // Component call
    component("isource", name, node, draw: draw, ..params)
}

#let disource(name, node, ..params) = isource(name, node, dependent: true, ..params)
#let acisource(name, node, ..params) = isource(name, node, current: "ac", ..params)

#let vsource(name, node, dependent: false, current: "dc", ..params) = {
    assert(current in ("dc", "ac"), message: "current must be ac or dc")

    // Drawing function
    let draw(ctx, position, style) = {
        let factor = if dependent { 1.1 } else { 1 }
        interface((-style.radius * factor, -style.radius * factor), (style.radius * factor, style.radius * factor), io: position.len() < 2)

        set-style(stroke: style.stroke)
        if dependent {
            polygon((0, 0), 4, fill: style.fill, radius: style.radius * factor)
        } else {
            circle((0, 0), fill: style.fill, radius: style.radius)
        }
        if style.variant == "iec" {
            if current == "ac" {
                content((0, 0), [#cetz.canvas({ ac-sign(size: 2) })])
            } else {
                line((-style.radius * factor, 0), (rel: (2 * style.radius * factor, 0)))
            }
        } else {
            line((rel: (-style.radius + style.padding, -style.sign-size)), (rel: (0, 2 * style.sign-size)), stroke: style.sign-stroke)
            line(
                (
                    style.radius - style.padding - style.sign-delta,
                    -style.sign-size,
                ),
                (rel: (0, 2 * style.sign-size)),
                stroke: style.sign-stroke,
            )
            line((rel: (style.sign-size, -style.sign-size)), (rel: (-2 * style.sign-size, 0)), stroke: style.sign-stroke)
        }
    }

    // Component call
    component("vsource", name, node, draw: draw, ..params)
}

#let dvsource(name, node, ..params) = vsource(name, node, ..params, dependent: true)
#let acvsource(name, node, ..params) = vsource(name, node, ..params, current: "ac")
