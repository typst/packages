#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": ac-sign
#import cetz.draw: anchor, arc, circle, rotate

#let circulator(name, node, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.radius, -style.radius), (style.radius, style.radius), io: false)

        circle((0, 0), radius: style.radius, fill: white, ..style, name: "circle")
        anchor("port1", "circle.west")
        anchor("port2", "circle.east")
        anchor("port3", "circle.north")

        let mark = (end: ">", fill: black, stroke: 0pt, anchor: "tip", inset: -.04)
        arc((0, 0), radius: style.arrow-radius, start: -45deg, delta: 280deg, anchor: "origin", stroke: ctx.style.zap.arrow.stroke, mark: mark)
    }

    // Constructor call
    symbol("circulator", name, node, draw: draw, ..params)
}
