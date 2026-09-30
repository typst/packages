#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: anchor, line, merge-path
#import "/src/symbols/wire.typ": wire

#let antenna(name, node, closed: false, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        assert(style.number > 1, message: "number must be at least 2")

        wire((0, 0), (0, style.distance))
        let width = style.spacing * (style.number - 1)
        let left = -(style.number - 1) / 2

        merge-path(
            close: true,
            fill: if closed { style.fill } else { none },
            stroke: if closed { style.stroke } else { none },
            {
                line((0, style.distance), (rel: (style.spacing * left, style.length)))
                line((rel: (width, 0)), (0, style.distance))
            },
        )
        if not closed {
            for i in range(style.number) {
                line((0, style.distance), (rel: (style.spacing * (i + left), style.length)), stroke: style.stroke)
            }
        }
        interface((-width / 2, style.distance), (rel: (width, style.length)))
        anchor("default", (0, 0))
    }

    // Constructor call
    symbol("antenna", name, node, draw: draw, ..params)
}
