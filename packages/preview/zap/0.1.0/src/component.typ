#import "dependencies.typ": cetz
#import "utils.typ": *

#let component(draw: none, label: none, variant: "iec", scale: 1.0, wires: true, rotate: 0deg, label-angle: 0deg, label-anchor: "center", label-distance: 20pt, debug: false, ..params) = {
    let (name, ..position) = params.pos()
    assert(position.len() in (1, 2), message: "accepts only 2 or 3 (for 2 nodes components only) positional arguments")
    assert(position.at(1, default: none) == none or rotate == 0deg, message: "cannot use rotate argument with 2 nodes")
    assert(type(name) == str, message: "component ID must be a string")
    assert(type(scale) == float, message: "scale must be a float")
    assert(type(rotate) == angle, message: "rotate must an angle")
    assert(label == none or type(label) in (content, str), message: "label must content or string")
    assert(variant in ("ieee", "iec", "pretty"), message: "variant must be 'iec', 'ieee' or 'pretty'")
    assert(type(wires) == bool, message: "wires must be a bool")

    let p-rotate = rotate
    let p-scale = scale
    let p-draw = draw
    import cetz.draw: *

    group(name: name, ctx => {
        let p-rotate = p-rotate
        let (ctx, ..position) = cetz.coordinate.resolve(ctx, ..position)
        let p-origin = position.first()
        if position.len() == 2 {
            p-rotate = cetz.vector.angle2(..position)
            p-origin = (position.first(), 50%, position.last())
        }
        // Component
        on-layer(1, {
            (p-draw.anchors)(ctx, position, variant, p-scale, p-rotate, wires, ..params.named())
            group(name: name+"-component", {
                set-origin(p-origin)
                rotate(p-rotate)
                scale(p-scale)
                (p-draw.component)(ctx, position, variant, p-scale, p-rotate, wires, ..params.named())
            })
        })
        // Wires and label
        on-layer(0, {
            if (wires) {
                (p-draw.wires)(ctx, position, variant, p-scale, p-rotate, wires, ..params.named())
            }
            if (label != none) {
                let display = if type(label) == str { $label$ } else { label }
                p-rotate = p-rotate + label-angle
                let angle = if (p-rotate >= 90deg) { -90deg + p-rotate } else { 90deg + p-rotate }
                content((rel: (angle, label-distance), to: name+"-component.center"), display, anchor: label-anchor, padding: 6pt)
            }
        })
    })

    if (debug) {
        on-layer(1, {
            for-each-anchor(name, exclude: ("north", "south", "south-east", "north-east", "east", "west", "north-west", "south-west", "center", "start", "end", "mid", name+"-component"), (name) => {
               content((), box(inset: 1pt, fill: black, text(4pt, [#name], fill: white)))
            })
        })
    }
}