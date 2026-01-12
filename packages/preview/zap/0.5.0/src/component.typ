#import "dependencies.typ": cetz
#import "decorations.typ": current, flow, voltage
#import "components/node.typ": node
#import "components/wire.typ": wire
#import "utils.typ": get-label-anchor, get-style, opposite-anchor, resolve-style
#import cetz.styles: merge
#import cetz.util: merge-dictionary

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
    debug: none,
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
    assert(type(scale) == float or (type(scale) == dictionary), message: "scale must be a dictionary or a float")
    assert(type(rotate) == angle, message: "rotate must an angle")
    assert(label == none or type(label) in (content, str, dictionary), message: "label must content, dictionary or string")
    assert("variant" not in params.named() or params.named().variant in ("ieee", "iec", auto), message: "variant must be 'iec', 'ieee' or auto")
    assert(n in (none, "*-", "*-*", "-*", "o-*", "*-o", "o-", "-o", "o-o"), message: "nodes are none, *-*, o-*, o-o, o-, etc.")

    let p-rotate = rotate
    let p-scale = scale
    let p-draw = draw
    import cetz.draw: *

    group(name: name, ctx => {
        // Save the current style
        let keep-style = ctx.style
        cetz.draw.set-style(..cetz.styles.default)

        let zap-style = ctx.zap.style
        let user-style = params.named()
        let user-stroke = user-style.remove("stroke", default: (:))
        let label-defaults = user-style.remove("label-defaults", default: (:))

        // Override style by user style
        zap-style.at(uid) = merge(zap-style.at(uid), user-style)

        // Resolve style
        let style = resolve-style(zap-style).at(uid)

        // Override stroke by user stroke
        style = merge(style, (stroke: user-stroke))

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
                // Scaling
                if (type(p-scale) == float) {
                    scale(x: p-scale * style.scale.x, y: p-scale * style.scale.y)
                } else {
                    scale(x: p-scale.at("x", default: 1.0) * style.scale.x, y: p-scale.at("y", default: 1.0) * style.scale.y)
                }
                draw(ctx, position, style)
                copy-anchors("bounds")
            })
        })

        copy-anchors("component")

        // Label
        on-layer(0, {
            if label != none {
                let label-style = zap-style.label
                label-style = merge(label-style, style.at("label", default: (:)))
                label-style = merge(label-style, label-defaults)
                label-style = merge(label-style, if type(label) == dictionary { label } else { (content: label) })

                let anchor = get-label-anchor(p-rotate)
                let resolved-anchor = if type(label-style.anchor) == str and "south" in label-style.anchor { opposite-anchor(anchor) } else { anchor }
                content(
                    if type(label-style.anchor) == str { "component." + label-style.anchor } else { label-style.anchor },
                    anchor: label-style.at("align", default: resolved-anchor),
                    label-style.content,
                    padding: label-style.distance,
                )
            }
        })

        // Symbol decorations
        if position.len() == 2 {
            wire("in", "component.west")
            wire("component.east", "out")

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
                } else if "o-" in n {
                    node("", "in", fill: false)
                }
                if "-*" in n {
                    node("", "out")
                } else if "-o" in n {
                    node("", "out", fill: false)
                }
            }
        }

        // Bringing back the current style
        cetz.draw.set-style(..keep-style)
    })

    // Show symbol anchors in debug mode
    cetz.draw.get-ctx(ctx => {
        let debug = if debug == none { get-style(ctx).debug.enabled } else { debug }
        if (debug) {
            on-layer(1, ctx => {
                let style = ctx.zap.style.debug
                for-each-anchor(name, exclude: ("start", "end", "mid", "component", "line", "bounds", "gl", "0", "1"), name => {
                    circle((), radius: style.radius, stroke: style.stroke)
                    content((rel: (0, style.shift)), box(inset: style.inset, text(style.font, name, fill: style.fill)), angle: style.angle)
                })
            })
        }
    })
}

// TODO: update this to more modern and resilient function (with "wirein" and "wireout" anchors)
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
