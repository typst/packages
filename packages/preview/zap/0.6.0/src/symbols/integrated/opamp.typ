#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: anchor, content, line, polygon, rect, scope, set-style, translate

#let opamp(name, node, invert: false, ..params) = {
    assert(params.pos().len() == 0, message: "opamp supports only one node")

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: true)

        let sgn = if invert { -1 } else { 1 }
        anchor("minus", (-style.width / 2, sgn * style.sign-delta))
        anchor("plus", (-style.width / 2, -sgn * style.sign-delta))

        if style.variant == "iec" {
            rect((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), fill: style.fill, stroke: style.stroke, name: "shape")
            anchor("v", "shape.north")
            anchor("g", "shape.south")
        } else {
            scope({
                if style.variant == "ieee" { translate((-style.width / 6, 0)) }
                polygon((0, 0), 3, radius: style.width * 2 / 3, fill: style.fill, stroke: style.stroke, name: "shape")
            })
            anchor("v", "shape.edge-0")
            anchor("g", "shape.edge-2")
        }

        set-style(stroke: style.sign-stroke)
        line((rel: (style.padding - style.sign-size, 0), to: "minus"), (rel: (2 * style.sign-size, 0)))
        line((rel: (style.padding - style.sign-size, 0), to: "plus"), (rel: (2 * style.sign-size, 0)))
        line((rel: (style.padding, -style.sign-size), to: "plus"), (rel: (0, 2 * style.sign-size)))

        anchor("label", (style.width / 2 - if style.variant == "ieee" { .45 } else { .15 }, 0))
    }

    // Constructor call
    symbol("opamp", name, node, draw: draw, ..params)
}

#let iopamp(name, node, ..params) = opamp(name, node, ..params, invert: true)
