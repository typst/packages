#import "dependencies.typ": cetz
#import "styles.typ": default-style
#import "decorations.typ": current, flow, voltage

#let component(
    draw: none,
    label: none,
    i: none,
    f: none,
    u: none,
    position: 50%,
    scale: 1.0,
    rotate: 0deg,
    debug: false,
    style: none,
    ..params,
) = {
    let p-position = position
    let (uid, name, ..position) = params.pos()
    if position.at(1, default: none) == none {
        position = (position.first(),)
    }
    assert(position.len() in (1, 2), message: "accepts only 2 or 3 (for 2 nodes components only) positional arguments")
    assert(position.at(1, default: none) == none or rotate == 0deg, message: "cannot use rotate argument with 2 nodes")
    assert(type(name) == str, message: "component name must be a string")
    assert(type(scale) == float, message: "scale must be a float")
    assert(type(rotate) == angle, message: "rotate must an angle")
    assert(label == none or type(label) in (content, str), message: "label must content or string")
    assert(params.at("variant", default: default-style.variant) in ("ieee", "iec", "pretty"), message: "variant must be 'iec', 'ieee' or 'pretty'")

    let p-rotate = rotate
    let p-scale = scale
    let p-draw = draw
    let p-style = style
    import cetz.draw: *

    group(name: name, ctx => {
        let pre-style = cetz.styles.resolve(ctx.style, root: "zap", base: default-style)
        let p-rotate = p-rotate
        let (ctx, ..position) = cetz.coordinate.resolve(ctx, ..position)
        let p-origin = position.first()
        if position.len() == 2 {
            anchor("in", position.first())
            anchor("out", position.last())
            p-rotate = cetz.vector.angle2(..position)
            p-origin = (position.first(), p-position, position.last())
        }
        set-origin(p-origin)
        rotate(p-rotate)

        // Component
        on-layer(1, {
            group(name: "component", {
                let base-style = p-style + pre-style + pre-style.at(uid, default: (something: none))
                let style = cetz.styles.resolve(base-style, merge: params.named())
                scale(p-scale * style.at("scale", default: 1))
                draw(ctx, position, style)
                copy-anchors("bounds")
            })
        })

        copy-anchors("component")

        // Wires and label
        on-layer(0, {
            if (label != none) {
                let (width, height) = cetz.util.measure(ctx, label)
                let new-position = (width / 2 * calc.abs(calc.sin(p-rotate)) + height / 2 * calc.abs(calc.cos(p-rotate)))
                content((rel: (0, -20pt), to: (rel: (0, new-position), to: "component.south")), label)
            }
        })

        if position.len() == 2 {
            line("in", "component.west", ..pre-style.at("wires"))
            line("out", "component.east", ..pre-style.at("wires"))

            if i != none {
                current(ctx, i)
            }
            if f != none {
                flow(ctx, f)
            }
            if u != none {
                voltage(ctx, u, p-rotate)
            }
        }
    })

    if (debug) {
        on-layer(1, {
            for-each-anchor(name, exclude: ("start", "end", "mid", "component", "line", "bounds", "gl", "0", "1"), name => {
                circle((), radius: .7pt, stroke: red + .2pt)
                content((rel: (0, 3pt)), box(inset: 1pt, text(3pt, name, fill: red)), angle: -30deg)
            })
        })
    }
}

#let interface(node1, node2, ..params, io: false) = {
    import cetz.draw: *

    hide(rect(node1, node2, name: "bounds"))
    if io {
        let (node3, node4) = (0,0)
        if params.pos().len() == 2 {
            (node3, node4) = params.pos()
        } else {
            (node3, node4) = ("bounds.west", "bounds.east")
        }

        anchor("in", node3)
        anchor("out", node4)
    }
}
