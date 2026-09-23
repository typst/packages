#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": ac-sign
#import "/src/utils.typ": opposite-anchor
#import "/src/symbols/wire.typ": wire
#import cetz.draw: anchor, circle, content, line, mark, polygon, rect, set-style

/// Stub symbol to use inside a circuit
///
/// - node (coordinate): stub position coordinates
/// - dir ('north' | 'east' | 'south' | 'west'): direction of the stub
/// - invert (bool | 'wedge'): displays a bubble/wedge at the origin
/// -> content
#let stub(node, dir: "north", invert: false, ..params) = {
    assert(params.pos().len() == 0, message: "stub must have exactly one node")
    assert(invert in (true, false, "wedge"), message: "invert should be boolean or 'wedge'")

    let args = params.named()
    if "label" in args and args.label != none {
        if type(args.label) == dictionary {
            args = args + (label: args.label + (anchor: dir))
        } else {
            args = args + (label: (content: args.label, anchor: dir, align: opposite-anchor(dir)))
        }
    }

    // Drawing function
    let draw(ctx, position, style) = {
        let diff = {
            if dir == "north" {
                ((0, style.length), (0.0001, style.length))
            } else if dir == "south" {
                ((0, -style.length), (0.0001, -style.length))
            } else if dir == "east" {
                ((style.length, 0), (style.length, 0.0001))
            } else if dir == "west" {
                ((-style.length, 0), (-style.length, 0.0001))
            }
        }

        interface((0, 0), diff.at(1), io: false)

        wire((0, 0), diff.at(0))

        if invert == true {
            let r = ctx.style.zap.invert.radius
            let cx = if dir == "east" { r } else if dir == "west" { -r } else { 0 }
            let cy = if dir == "north" { r } else if dir == "south" { -r } else { 0 }
            circle((cx, cy), radius: r, fill: white, stroke: ctx.style.zap.invert.stroke)
        } else if invert == "wedge" {
            let invert = ctx.style.zap.invert
            let (a, b) = (-1, -1)
            if dir == "east" {
                (a, b) = (1, 1)
            } else if dir == "west" {
                (a, b) = (1, -1)
            } else if dir == "north" {
                (a, b) = (-1, 1)
            }
            line((invert.wedge-width * b, 0), (0, invert.wedge-height * a), stroke: ctx.style.zap.invert.stroke)
        }
    }

    // Constructor call
    symbol("stub", "l", node, draw: draw, ..args)
}

#let nstub(node, ..params) = stub(node, ..params, dir: "north")
#let sstub(node, ..params) = stub(node, ..params, dir: "south")
#let estub(node, ..params) = stub(node, ..params, dir: "east")
#let wstub(node, ..params) = stub(node, ..params, dir: "west")
