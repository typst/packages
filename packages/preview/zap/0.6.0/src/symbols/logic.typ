#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: anchor, arc-through, bezier, circle, content, line, merge-path, rect, rotate, set-style

/// IEC (international)-inspired variant drawing function
#let logic-iec(ctx, position, style, text, invert, inputs, ..params) = {
    let height = calc.max(style.min-height, (inputs - 1) * style.spacing + 2 * style.padding)
    let inner-height = height - 2 * style.padding
    interface((-style.width / 2, -height / 2), (style.width / 2, height / 2), io: false)

    rect((-style.width / 2, -height / 2), (rel: (style.width, height)), fill: style.fill, stroke: style.stroke)
    content((0, 0), text, anchor: "center")

    for input in range(1, inputs + 1) {
        let y = if inputs == 1 {
            0
        } else {
            height / 2 - style.padding - (input - 1) * inner-height / (inputs - 1)
        }
        anchor("in" + str(input), (-style.width / 2, y))
    }

    if invert == true {
        let radius = ctx.style.zap.invert.radius
        circle((style.width / 2 + radius, 0), radius: radius, fill: style.fill, stroke: style.stroke, name: "bubble")
        anchor("out", "bubble.east")
    } else if invert == "wedge" {
        let invert = ctx.style.zap.invert
        line((style.width / 2, invert.wedge-height), (rel: (invert.wedge-width, -invert.wedge-height)))
        line((style.width / 2, 0), (rel: (invert.wedge-width, 0)))
        anchor("out", (style.width / 2 + invert.wedge-width, 0))
    } else {
        anchor("out", (style.width / 2, 0))
    }
}

/// IEEE/ANSI-inspired variant drawing function
#let logic-ieee(ctx, position, style, text, invert, inputs, ..params) = {
    let is-or = text in ($>=1$, $=1$)
    let is-xor = text in ($=1$,)
    let is-triangle = text in ($1$,)

    let inputs = if is-triangle { 1 } else { inputs }

    let spread = (inputs - 1) * style.spacing
    let h = calc.max(style.min-height, spread + 2 * style.padding) / 2
    let w = if is-triangle { style.width * 0.8 } else { style.width }

    interface((-w / 2, -h), (w / 2, h), io: false)
    set-style(stroke: style.stroke)

    merge-path(fill: style.fill, close: true, {
        if is-triangle {
            line((-w / 2, w / 2), (-w / 2, -w / 2), (w / 2, 0))
        } else if is-or {
            bezier((-w / 2, h), (w / 2, 0), (w / 8, h), (w / 2, h / 2))
            bezier((w / 2, 0), (-w / 2, -h), (w / 2, -h / 2), (w / 8, -h))
            bezier((-w / 2, -h), (-w / 2, h), (-w / 4, -h / 2), (-w / 4, h / 2))
        } else {
            line((-w / 2, h), (0, h))
            bezier((0, h), (0, -h), (w * 0.65, h), (w * 0.65, -h))
            line((0, -h), (-w / 2, -h), (-w / 2, h))
        }
    })

    if is-xor {
        bezier((-w / 2 - style.xor-spacing, h), (-w / 2 - style.xor-spacing, -h), (-w / 4 - style.xor-spacing, h / 2), (-w / 4 - style.xor-spacing, -h / 2))
    }

    if invert == true {
        let radius = ctx.style.zap.invert.radius
        circle((w / 2 + radius, 0), radius: radius, fill: style.fill, stroke: ctx.style.zap.invert.stroke, name: "bubble")
        anchor("out", "bubble.east")
    } else {
        anchor("out", (w / 2, 0))
    }

    for i in range(0, inputs) {
        let y-pos = (spread / 2) - (i * style.spacing)

        let x-indent = if is-or { (1 - calc.pow(y-pos / h, 2)) * 0.18 } else { 0 }

        let input-x = if is-xor {
            -w / 2 - 0.15 + x-indent
        } else if is-or {
            -w / 2 + x-indent
        } else {
            -w / 2
        }

        anchor("in" + str(i + 1), (input-x, y-pos))
    }
}

/// Logic symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - text (content): content displayed inside the rectangle
/// - invert (bool): display an inverted output
/// - inputs (int | array): number of inputs or list of input dictionaries
/// -> content
#let logic(name, node, text: $"&"$, invert: false, inputs: 2, ..params) = {
    assert(inputs >= 1, message: "logic supports minimum one input")
    assert(invert in (true, false, "wedge"), message: "invert should be boolean or 'wedge'")

    // Drawing function
    let draw(ctx, position, style) = {
        let func = if style.variant == "iec" { logic-iec } else { logic-ieee }
        func(ctx, position, style, text, invert, inputs, ..params)
    }

    // Constructor call
    symbol("logic", name, node, draw: draw, ..params)
}

#let lnot(name, node, ..params) = logic(name, node, inputs: 1, ..params, text: $1$, invert: true)
#let land(name, node, ..params) = logic(name, node, ..params, text: $"&"$)
#let lnand(name, node, ..params) = logic(name, node, ..params, text: $"&"$, invert: true)
#let lor(name, node, ..params) = logic(name, node, ..params, text: $>=1$)
#let lnor(name, node, ..params) = logic(name, node, ..params, text: $>=1$, invert: true)
#let lxor(name, node, ..params) = logic(name, node, ..params, text: $=1$)
#let lxnor(name, node, ..params) = logic(name, node, ..params, text: $=1$, invert: true)
