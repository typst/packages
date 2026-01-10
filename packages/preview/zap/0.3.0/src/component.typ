#import "dependencies.typ": cetz
#import "styles.typ": default-style
#import "decorations.typ": current, flow, voltage
#import "components/nodes.typ": node
#import "components/nodes.typ": node
#import "utils.typ": get-label-anchor

#let component(
    draw: none,
    label: none,
    i: none,
    f: none,
    u: none,
    n: none,
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
    assert(type(scale) == float or (type(scale) == array and scale.len() == 2), message: "scale must be a float or an array of two floats")
    assert(type(rotate) == angle, message: "rotate must an angle")
    assert(label == none or type(label) in (content, str, dictionary), message: "label must content, dictionary or string")
    assert(params.at("variant", default: default-style.variant) in ("ieee", "iec", "pretty"), message: "variant must be 'iec', 'ieee' or 'pretty'")
    assert(n in (none, "*-", "*-*", "-*", "o-*", "*-o", "o-", "-o", "o-o"))

    let p-rotate = rotate
    let p-scale = scale
    let p-draw = draw
    let p-style = style
    import cetz.draw: *

    group(name: name, ctx => {
        let pre-style = cetz.styles.resolve(ctx.style, root: "zap", base: default-style)
        let base-style = p-style + pre-style + pre-style.at(uid, default: (something: none))
        let style = cetz.styles.resolve(base-style, merge: params.named())
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
                if (type(p-scale) == float) {
                    scale(p-scale * style.at("scale", default: 1))
                } else {
                    scale(x: p-scale.at(0, default: 1) * style.at("scale", default: 1), y: p-scale.at(1, default: 1) * style.at("scale", default: 1))
                }
                draw(ctx, position, style)
                copy-anchors("bounds")
            })
        })

        copy-anchors("component")

        // Label
        on-layer(0, {
            if label != none {
                if type(label) == dictionary and label.at("content", default: none) == none { panic("Label dictionary needs at least content key") }
                let (label, distance, width, height, anchor) = if type(label) == dictionary {
                    (label.at("content", default: none), label.at("distance", default: 7pt), ..cetz.util.measure(ctx, label.at("content")), label.at("anchor", default: "north"))
                } else {
                    (label, 7pt, ..cetz.util.measure(ctx, label), "north")
                }
                let reverse = "south" in anchor
                let new-position = (0.5 * width * calc.abs(calc.sin(p-rotate)) + 0.5 * height * calc.abs(calc.cos(p-rotate)))
                content("component." + anchor, anchor: get-label-anchor(p-rotate).at(if reverse { 1 } else { 0 }), label, padding: distance)
            }
        })

        // Decorations
        if position.len() == 2 {
            line("in", "component.west", ..pre-style.at("wires"))
            line("component.east", "out", ..pre-style.at("wires"))

            if i != none {
                current(ctx, i)
            }
            if f != none {
                flow(ctx, f)
            }
            if u != none {
                voltage(ctx, u, p-rotate)
            }
            if n != none {
                if "*-" in n {
                    node("", "in")
                }
                if "-*" in n {
                    node("", "out")
                }
                if "o-" in n {
                    node("", "in", fill: false)
                }
                if "-o" in n {
                    node("", "out", fill: false)
                }
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
        let (node3, node4) = (0, 0)
        if params.pos().len() == 2 {
            (node3, node4) = params.pos()
        } else {
            (node3, node4) = ("bounds.west", "bounds.east")
        }

        anchor("in", node3)
        anchor("out", node4)
    }
}
