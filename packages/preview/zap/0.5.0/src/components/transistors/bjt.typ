#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": center-mark
#import "/src/components/wire.typ": wire
#import "/src/utils.typ": get-style
#import cetz.draw: anchor, circle, content, hide, line, mark, set-style, translate

#let bjt(name, node, polarisation: "npn", envelope: false, ..params) = {
    assert(polarisation in ("npn", "pnp"), message: "polarisation must `npn` or `pnp`")
    assert(type(envelope) == bool, message: "envelope must be of type bool")
    assert(params.pos().len() == 0, message: "ground supports only one node")

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius))

        translate((-calc.cos(style.aperture) * style.radius, 0))

        let sgn = if polarisation == "npn" { 1 } else { -1 }
        anchor("base", ((-style.radius, 0), 30%, (style.radius, 0)))
        anchor("e", (-style.aperture * sgn, style.radius))
        anchor("c", (style.aperture * sgn, style.radius))
        anchor("b", if envelope { (-style.radius, 0) } else { "base" })

        set-style(stroke: style.stroke)
        if envelope {
            circle((0, 0), radius: style.radius, fill: style.fill, name: "circle")
            wire("base", (-style.radius, 0))
        } else {
            hide(circle((0, 0), radius: style.radius, name: "circle"))
        }

        line((to: "base", rel: (0, -style.base-height / 2)), (to: "base", rel: (0, style.base-height / 2)))
        line((to: "base", rel: (0, -style.base-distance * sgn)), "e", stroke: get-style(ctx).wire.stroke, mark: center-mark(symbol: if sgn == -1 { "<" } else { ">" }))
        wire((to: "base", rel: (0, style.base-distance * sgn)), "c")

        if params.named().at("label", default: none) != none {
            content((style.radius, 0), params.named().at("label"), anchor: "west", padding: if envelope { 0.2 } else { -0.1 })
        }
    }

    // Component call
    component("bjt", name, node, draw: draw, ..params, label: none)
}

#let pnp(name, node, ..params) = bjt(name, node, polarisation: "pnp", ..params)
#let npn(name, node, ..params) = bjt(name, node, polarisation: "npn", ..params)
