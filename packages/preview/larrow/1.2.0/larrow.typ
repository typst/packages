#import "@preview/cetz:0.5.2"

#let arrow-label(lbl, dx: 0pt, dy: 0pt) = [#sym.zws#metadata((dx, dy))#lbl#sym.zws]

#let label-arrow(from, to, bend: 0, tip: "straight", from-tip: none,
                 both-tip: none, stroke: auto, from-offset: (0pt, 0pt),
                 to-offset: (0pt, 0pt), both-offset: (0pt, 0pt),
                 caption: none, caption-position: "mid", caption-options:
                    (frame: "rect", fill: auto, stroke: 0pt, padding: 1pt),
                 debug: false
) = context {
    // Append passed caption options to the default ones
    let caption-options = (
        frame: "rect", fill: auto, stroke: 0pt, padding: 1pt
    ) + caption-options

    let get-element(elem) = {
        if type(elem) == label {
            query(elem).first()            
        } else if type(elem) == content {
            elem
        } else {
            assert(false, message: "`from` and `to` should be labels
                or contents, but " + repr(elem) + " is "
                + repr(type(elem)))
        }
    }

    let position(elem, offset) = {
        let loc = elem.location().position()
        let (dx, dy) = if (
            elem.has("value") and elem.value.len() == 2
            and elem.value.all(val => type(val) == length) 
        ) {(
            elem.value.at(0).to-absolute().pt(),
            elem.value.at(1).to-absolute().pt()
        )} else { (0, 0) }

        // Coordinates without offsets so far.
        let x = loc.x.to-absolute().pt()
        let y = page.height.to-absolute().pt() - loc.y.to-absolute().pt()

        // Apply offsets
        x = (x + offset.at(0).to-absolute().pt() +
              both-offset.at(0).to-absolute().pt() + dx)
        y = (y + offset.at(1).to-absolute().pt() +
              both-offset.at(1).to-absolute().pt() + dy)

        (x, y)
    }

    let set-fill(opts) = {
        if opts.fill == auto {
            opts + (fill: {
                if page.fill == auto {white} else {page.fill}
            })
        } else {
            opts
        }
    }

    // Only import necessary components for example not to override
    // standard stroke definition.
    import cetz.draw: rect, bezier, circle, line, content

    // These functions return a tuple (line, debug-points)
    // Line from given points
    let chain-line(..args) = (
        line(..args, name: "arrow"),
        args.pos().slice(1, -1)
    )
    
    // Straight line or bezier curve
    let bezier-line((fx, fy), (tx, ty), bend, ..args) = {
        // Vector from "from" label to "to" label.
        let diff-x = tx - fx
        let diff-y = ty - fy
        // Position of the midpoint between two labels (used to position the
        // control point of the quadratic bezier curve).
        let midpoint-x = fx + diff-x / 2
        let midpoint-y = fy + diff-y / 2
        // Magnitude of the difference vector between from and to labels.
        let magnitude-diff = calc.sqrt(
            calc.pow(diff-x, 2) + calc.pow(diff-y, 2))
        let unit-diff-x
        let unit-diff-y
        if magnitude-diff != 0 {
            // Unit vector of the difference from -> to
            unit-diff-x = diff-x / magnitude-diff
            unit-diff-y = diff-y / magnitude-diff
        } else {
            unit-diff-x = 0
            unit-diff-y = 0
        }
        // Coordinates for the final control point.
        let control-x = midpoint-x + unit-diff-y * bend
        let control-y = midpoint-y + -1 * unit-diff-x * bend

        (
            bezier((fx, fy), (tx, ty), (control-x, control-y), ..args, name: "arrow"),
            ((control-x, control-y),)
        )
    }

    // Where the function call is in the layout. Necessary to place the canvas
    // in the top left corner of the page later.
    let here-loc = locate(here()).position()

    // Get the from position and offsets if available.
    let from-elem = get-element(from)
    let (fx, fy) = position(from-elem, from-offset)
    let to-elem = get-element(to)
    let (tx, ty) = position(to-elem, to-offset)

    // If tips aren't set together, draw individual marks.
    // Otherwise, draw both-tip for both ends.
    let mark = if (both-tip == none) {(start: from-tip, end: tip)} else {
        (symbol: both-tip)
    }
    // Actual drawing of line.
    place(dx: -1 * here-loc.x, dy: -1 * here-loc.y, cetz.canvas(length: 1pt, {
        // This rectangle is used to force the cetz canvas to take the size of
        // the entire page and thus properly locate coordinates from base typst
        // on the page.
        rect((0, 0), (page.width, page.height), stroke: none)
        let (line, debug-points) = (
            if bend == "-|" {
                chain-line((fx, fy), (tx, fy), (tx, ty),
                           mark: mark, stroke: stroke)
            } else if bend == "|-" {
                chain-line((fx, fy), (fx, ty), (tx, ty),
                           mark: mark, stroke: stroke)
            } else if type(bend) == function {
                chain-line((fx, fy), ..bend((fx, fy), (tx, ty)), (tx, ty),
                           mark: mark, stroke: stroke)
            } else if type(bend) in (int, float) {
                bezier-line((fx, fy), (tx, ty), bend,
                            mark: mark, stroke: stroke)
            }
        )
        line
        if caption != none {
            content((name: "arrow", anchor: caption-position),
                     caption, ..set-fill(caption-options))
        }
        // If debugging was turned on for the arrow, the starting and end
        // points as well as the control point is marked.
        if debug {
            circle((fx, fy), stroke: green)
            circle((tx, ty), stroke: red)
            debug-points.map(circle.with(stroke: blue)).join()
        }
    }))
}

#let al = arrow-label
#let larw = label-arrow
