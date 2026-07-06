#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": ac-sign
#import cetz.draw: anchor, circle, content, line, mark, polygon, rect, set-style

/// Current source symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - dependent (bool): whether this source depends on some value
/// -> content
#let isource(name, node, dependent: false, ..params) = {
    assert(type(dependent) == bool, message: "dependent must be boolean")

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
                mark: (end: ">", scale: style.arrow-scale * style.scale.at("x", default: 1.0)),
                fill: cetz.util.resolve-stroke(ctx.style.zap.arrow.stroke).paint,
                stroke: ctx.style.zap.arrow.stroke,
            )
        }
    }

    // Constructor call
    symbol("isource", name, node, draw: draw, ..params)
}

#let disource(name, node, ..params) = isource(name, node, dependent: true, ..params)
#let acisource(name, node, ..params) = isource(name, node, current: "ac", ..params)

/// Voltage source symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - dependent (bool): whether this source depends on some value
/// - current ('dc' | 'ac' | 'tri' | 'rect' | 'saw' | 'sin'): type of current flowing through
/// -> content
#let vsource(name, node, dependent: false, current: "dc", ..params) = {
    assert(current in ("dc", "ac", "tri", "rect", "saw", "sin"), message: "current must be 'dc', 'ac', 'tri', 'rect', 'saw' or 'sin'")

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
            if current != "dc" {
                cetz.draw.scope({
                    cetz.draw.rotate(-ctx.rotation)
                    ac-sign(ctx, waveform: current)
                })
            } else {
                line((-style.radius * factor, 0), (rel: (2 * style.radius * factor, 0)))
            }
        } else {
            set-style(stroke: ctx.style.zap.sign.stroke)
            line((rel: (-style.radius + style.padding, -style.sign.size)), (rel: (0, 2 * style.sign.size)))
            line((style.radius - style.padding - style.sign.delta, -style.sign.size), (rel: (0, 2 * style.sign.size)))
            line((rel: (style.sign.size, -style.sign.size)), (rel: (-2 * style.sign.size, 0)))
        }
    }

    // Constructor call
    symbol("vsource", name, node, draw: draw, ..params)
}

#let dvsource(name, node, ..params) = vsource(name, node, ..params, dependent: true)
#let acvsource(name, node, ..params) = vsource(name, node, ..params, current: "ac")
