#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, hide, line, mark, translate
#import "/src/mini.typ": center-mark

#let bjt(name, node, polarisation: "npn", envelope: false, ..params) = {
    assert(polarisation in ("npn", "pnp"), message: "polarisation must `npn` or `pnp`")
    assert(type(envelope) == bool, message: "envelope must be of type bool")
    assert(params.pos().len() == 0, message: "ground supports only one node")

    // BJT style
    let style = (
        radius: .65,
        base-height: .6,
        base-distance: .12,
        aperture: 50deg,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius))

        let sgn = if polarisation == "npn" { -1 } else { 1 }
        anchor("base", ((-style.radius, 0), 30%, (style.radius, 0)))
        anchor("e", (-style.aperture * sgn, style.radius))
        anchor("c", (style.aperture * sgn, style.radius))
        anchor("b", if envelope { (-style.radius, 0) } else { "base" })

        if envelope {
            circle((0, 0), radius: style.radius, ..style, name: "circle")
            line("base", (-style.radius, 0), ..style.at("wires"))
        } else {
            hide(circle((0, 0), radius: style.radius, ..style, name: "circle"))
        }

        line((to: "base", rel: (0, -style.base-height / 2)), (to: "base", rel: (0, style.base-height / 2)), ..style)
        line((to: "base", rel: (0, -style.base-distance * sgn)), "e", ..style.at("wires"), mark: center-mark(symbol: if sgn == -1 { "<" } else { ">" }))
        line((to: "base", rel: (0, style.base-distance * sgn)), "c", ..style.at("wires"))
    }

    // Componant call
    component("bjt", name, node, draw: draw, style: style, ..params, label: none)
}

#let pnp(name, node, ..params) = bjt(name, node, polarisation: "pnp", ..params)
#let npn(name, node, ..params) = bjt(name, node, polarisation: "npn", ..params)
