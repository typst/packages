#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, content, line, polygon, rect, scope, translate

#let opamp(name, node, invert: false, label: none, ..params) = {
    assert(params.pos().len() == 0, message: "opamp supports only one node")

    // Capacitor style
    let style = (
        width: 1.8,
        height: 1.75,
        padding: .28,
        sign-stroke: .55pt,
        sign-size: .14,
        sign-delta: .45,
    )


    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: true)

        let sgn = if invert { -1 } else { 1 }
        anchor("minus", (-style.width / 2, sgn * style.sign-delta))
        anchor("plus", (-style.width / 2, -sgn * style.sign-delta))

        if style.variant == "iec" {
            rect((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), fill: white, ..style)
        } else {
            scope({
                if style.variant == "ieee" { translate((-style.width / 6, 0)) }
                polygon((0, 0), 3, radius: style.width * 2 / 3, ..style)
            })
        }

        line((rel: (style.padding - style.sign-size, 0), to: "minus"), (rel: (2 * style.sign-size, 0)), stroke: style.sign-stroke)
        line((rel: (style.padding - style.sign-size, 0), to: "plus"), (rel: (2 * style.sign-size, 0)), stroke: style.sign-stroke)
        line((rel: (style.padding, -style.sign-size), to: "plus"), (rel: (0, 2 * style.sign-size)), stroke: style.sign-stroke)

        if label != none {
            content((style.width / 2, 0), label, anchor: "east", padding: if style.variant == "ieee" { .45 } else { .15 })
        }
    }

    // Componant call
    component("opamp", name, node, draw: draw, style: style, ..params, label: none)
}
