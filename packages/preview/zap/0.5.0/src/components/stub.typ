#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": ac-sign
#import "/src/utils.typ": get-style, opposite-anchor
#import "/src/components/wire.typ": wire
#import cetz.draw: anchor, circle, content, line, mark, polygon, rect, set-style

#let stub(node, dir: "north", ..params) = {
    assert(params.pos().len() == 0, message: "stub must have exactly one node")

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
                (0.001, style.length)
            } else if dir == "south" {
                (0.0001, -style.length)
            } else if dir == "east" {
                (style.length, 0.001)
            } else if dir == "west" {
                (-style.length, 0.001)
            }
        }

        interface((0, 0), diff, io: false)

        wire((0, 0), (rel: diff))
    }


    // Component call
    component("stub", "l", node, draw: draw, ..args)
}

#let nstub(node, ..params) = stub(node, ..params, dir: "north")
#let sstub(node, ..params) = stub(node, ..params, dir: "south")
#let estub(node, ..params) = stub(node, ..params, dir: "east")
#let wstub(node, ..params) = stub(node, ..params, dir: "west")
