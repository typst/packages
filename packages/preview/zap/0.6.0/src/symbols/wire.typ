#import "/src/deps.typ": cetz
#import "/src/utils.typ": zigzag
#import "/src/decorations.typ": current
#import cetz.draw: anchor, circle, content, group, hide, line, mark, set-style
#import cetz.styles: merge

// Save native function
#let typst-ratio = ratio

/// Electrical wire symbol to use inside a circuit
///
/// - bits (int): number of bit marks
/// - shape (str): wire routing style
/// - ratio (ratio): position of wire segments
/// - axis (str): axis of the shape
/// - i (str | dict): current decoration
/// - name (str): symbol identifier
/// -> content
#let wire(bits: 0, shape: "direct", ratio: 50%, axis: "x", i: none, name: none, ..params) = {
    assert(type(bits) == int, message: "bits must be an int")
    assert(params.pos().len() >= 2, message: "wires need at least two nodes")
    assert(type(ratio) in (typst-ratio, int, float, length), message: "ratio must be a ratio, a number or a length")
    assert(shape in ("direct", "zigzag", "dodge"), message: "shape must be 'direct', 'zigzag' or 'dodge'")

    group(name: name, ctx => {
        let style = cetz.styles.resolve(ctx.style.zap, merge: params.named(), root: "wire")
        let (ctx, ..nodes) = cetz.coordinate.resolve(ctx, ..params.pos())
        cetz.draw.stroke(style.stroke)

        // Drawing the wire using the shape parameter
        anchor("in", nodes.first())
        anchor("out", nodes.last())
        for (index, node) in nodes.enumerate() { anchor("p" + str(index), node) }
        if shape == "direct" {
            line(..nodes, name: "line")
        } else if shape == "zigzag" {
            if nodes.len() < 2 { return }
            let generated = zigzag(ctx, nodes, axis, ratio)
            cetz.draw.line(..generated, nodes.last(), name: "line")
        }

        // Multi-bits wiring by displaying a slash with a number
        for i in range(bits) {
            let delta = i * 0.4
            line((rel: (0, -0.2), to: "line.50%"), (rel: (0, 0.2), to: "line.50%"))
        }

        // Current decoration
        cetz.draw.set-style(zap: (decoration: (current: (distance: 0pt))))
        cetz.draw.hide(cetz.draw.rect("line.50%", "line.51%", name: "symbol"))
        if i != none { current(i) }
    })
}


#let zwire(..params) = wire(shape: "zigzag", ..params)
#let swire(..params) = wire(shape: "zigzag", ratio: 100%, ..params)
