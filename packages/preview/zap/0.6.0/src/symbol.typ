#import "deps.typ": cetz
#import "decorations.typ": current, flow, voltage
#import "symbols/node.typ": node
#import "symbols/wire.typ": wire
#import "styles.typ": default
#import "utils.typ": get-label-anchor, opposite-anchor
#import cetz.styles: merge
#import cetz.draw: anchor, circle, copy-anchors, for-each-anchor, get-ctx, group, hide, move-to, on-layer, rect, scope

#let typst-angle = angle

/// Low-level function for creating circuit symbols. Used internally for all built-in symbols and can also be used to create custom ones.
///
/// https://zap.grangelouis.ch/#custom
///
/// - draw (func): drawing function
/// - label (content | dict): label content
/// - i (content | dict): current decoration
/// - f (content | dict): flow decoration
/// - u (content | dict): voltage decoration
/// - n (str): ends nodes types
/// - position (ratio): position of the symbol
/// - scale (float): scaling factor
/// - angle (angle): rotation angle
/// - debug (bool): debug mode (displays anchors)
/// -> content
#let symbol(
    uid,
    name,
    draw: none,
    label: none,
    i: none,
    f: none,
    u: none,
    n: none,
    position: 50%,
    angle: 0deg,
    debug: none,
    ..params,
) = {
    assert(params.pos().len() in (1, 2), message: "only 1 or 2 nodes are accepted")
    assert(params.pos().len() == 1 or angle == 0deg, message: "cannot use rotate argument with 2 nodes")
    assert(type(name) == str, message: "identifier must be a string")
    assert(type(angle) == typst-angle, message: "rotation must an angle")
    assert(label == none or type(label) in (content, str, dictionary), message: "label must content, dictionary or string")
    assert("variant" not in params.named() or params.named().variant in ("ieee", "iec", "alt", auto), message: "variant must be 'iec', 'ieee', 'alt' or auto")
    assert(n in (none, "*-", "*-*", "-*", "o-*", "*-o", "o-", "-o", "o-o"), message: "nodes must be none, *-*, o-*, o-o, o-, etc.")

    group(name: name, ctx => {
        let keep-style = ctx.style
        let style = cetz.styles.resolve(ctx.style.zap, merge: params.named(), root: uid)
        let stroke = style.at("stroke", default: default.stroke)
        style.stroke = cetz.util.resolve-stroke(if stroke != none { stroke } else { 0pt })
        style.scale = style.at("scale", default: default.scale)
        if type(style.scale) in (float, int) { style.scale = (x: style.scale, y: style.scale) }
        let (ctx, ..nodes) = cetz.coordinate.resolve(ctx, ..params.pos())
        let origin = nodes.first()
        let params-angle = angle
        if nodes.len() == 2 {
            anchor("in", nodes.first())
            anchor("out", nodes.last())
            params-angle = cetz.vector.angle2(..nodes)
            origin = (nodes.first(), position, nodes.last())
        }
        cetz.draw.set-origin(origin)
        cetz.draw.rotate(params-angle)
        ctx.insert("rotation", params-angle)

        // Symbol
        on-layer(1, {
            group(name: "symbol", {
                // Scaling
                cetz.draw.scale(..style.scale)

                // Symbol's draw function
                draw(ctx, nodes, style)
                copy-anchors("bounds")
            })
        })

        copy-anchors("symbol")

        // Label
        on-layer(0, {
            if label != none {
                let label-style = cetz.styles.resolve(
                    ctx.style.zap.at(uid, default: (label: (:))),
                    base: ctx.style.zap.label,
                    merge: if type(label) == dictionary { label } else { (content: label) },
                    root: "label",
                )
                let anchor = get-label-anchor(params-angle)
                let resolved-anchor = if type(label-style.anchor) == str and "south" in label-style.anchor { opposite-anchor(anchor) } else { anchor }
                cetz.draw.content(
                    if type(label-style.anchor) == str { "symbol." + label-style.anchor } else { label-style.anchor },
                    anchor: label-style.at("align", default: resolved-anchor),
                    label-style.content,
                    padding: label-style.distance,
                )
            }
        })

        // Symbol decorations
        if nodes.len() == 2 {
            wire("in", "symbol.west")
            wire("symbol.east", "out")

            if i != none { current(i) }
            if f != none { flow(f) }
            if u != none { voltage(u, params-angle) }
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
    get-ctx(ctx => {
        let debug = if debug == none { ctx.style.zap.debug.enabled } else { debug }
        if (debug) {
            on-layer(1, ctx => {
                let style = ctx.style.zap.debug
                for-each-anchor(name, exclude: ("start", "end", "mid", "symbol", "line", "bounds", "gl", "0", "1"), name => {
                    circle((), radius: style.radius, stroke: style.stroke)
                    cetz.draw.content((rel: (0, style.shift)), box(inset: style.inset, text(style.font, name, fill: style.fill)), angle: style.angle)
                })
            })
        }
    })

    // Set previous coordinate
    move-to(params.pos().last())
}

// TODO: update this to more modern and resilient function (with "wirein" and "wireout" anchors)
/// Low-level symbol interface to automate wiring and positioning. Will be replaced in the future.
#let interface(node1, node2, ..params, io: false) = {
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
