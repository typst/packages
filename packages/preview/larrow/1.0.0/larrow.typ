#import "@preview/cetz:0.4.2"

#let arrow-label(lbl, dx: 0pt, dy: 0pt) = [#sym.zws#metadata((dx, dy))#lbl#sym.zws]

#let label-arrow(from, to, bend: 0, tip: "straight", from-tip: none,
                 both-tip: none, stroke: auto, from-offset: (0pt, 0pt),
                 to-offset: (0pt, 0pt), both-offset: (0pt, 0pt), debug: false
) = context {
    // Where the function call is in the layout. Necessary to place the canvas
    // in the top left corner of the page later.
    let here-loc = locate(here()).position()

    // Get the from position and offsets if available.
    let from-loc = locate(from).position()
    let from-deltas = query(from).first()
    let from-dx
    let from-dy
    if from-deltas.has("value") {
        from-dx = from-deltas.value.at(0).to-absolute().pt()
        from-dy = from-deltas.value.at(1).to-absolute().pt()
    } else { (from-dx, from-dy) = (0, 0) }

    // Get the to position and offsets if available.
    let to-loc = locate(to).position()
    let to-deltas = query(to).first()
    let to-dx
    let to-dy
    if to-deltas.has("value") {
        to-dx = to-deltas.value.at(0).to-absolute().pt()
        to-dy = to-deltas.value.at(1).to-absolute().pt()
    } else { (to-dx, to-dy) = (0, 0) }

    // Coordinates of the from and to positions without offsets so far.
    let fx = from-loc.x.to-absolute().pt()
    let fy = page.height.to-absolute().pt() - from-loc.y.to-absolute().pt()
    let tx = to-loc.x.to-absolute().pt()
    let ty = page.height.to-absolute().pt() - to-loc.y.to-absolute().pt()

    // Apply offsets
    fx = (fx + from-offset.at(0).to-absolute().pt() + 
          both-offset.at(0).to-absolute().pt() + from-dx)
    fy = (fy + from-offset.at(1).to-absolute().pt() +
          both-offset.at(1).to-absolute().pt() + from-dy)
    tx = (tx + to-offset.at(0).to-absolute().pt() +
          both-offset.at(0).to-absolute().pt() + to-dx)
    ty = (ty + to-offset.at(1).to-absolute().pt() +
          both-offset.at(1).to-absolute().pt() + to-dy)

    // Vector from "from" label to "to" label.
    let diff-x = tx - fx
    let diff-y = ty - fy
    // Position of the midpoint between two labels (used to position the
    // control point of the quadratic bezier curve).
    let midpoint-x = fx + diff-x / 2
    let midpoint-y = fy + diff-y / 2
    // Magnitude of the difference vector between from and to labels.
    let magnitude-diff = calc.sqrt(calc.pow(diff-x, 2) + calc.pow(diff-y, 2))
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
    let control-x
    let control-y
    // Whether bend is positive or negative automatically gives correct
    // handedness of the curve.
    control-x = midpoint-x + unit-diff-y * bend
    control-y = midpoint-y + -1 * unit-diff-x * bend

    // Actual drawing of curve.
    place(dx: -1 * here-loc.x, dy: -1 * here-loc.y, cetz.canvas(length: 1pt, {
        // Only import necessary components for example not to override
        // standard stroke definition.
        import cetz.draw: rect, bezier, circle
        // This rectangle is used to force the cetz canvas to take the size of
        // the entire page and thus properly locate coordinates from base typst
        // on the page.
        rect((0, 0), (page.width, page.height), stroke: none)
        // If tips aren't set together, draw individual marks.
        if both-tip == none {
            // This bezier curve is the actual arrow.
            bezier((fx, fy), (tx, ty), (control-x, control-y),
                   mark: (start: from-tip, end: tip), stroke: stroke
            )
        } else { // Otherwise, draw both-tip for both ends.
            bezier((fx, fy), (tx, ty), (control-x, control-y),
                   mark: (symbol: both-tip), stroke: stroke
            )
        }
        // If debugging was turned on for the arrow, the starting and end
        // points as well as the control point is marked.
        if debug {
            circle((fx, fy), stroke: green)
            circle((tx, ty), stroke: red)
            circle((control-x, control-y), stroke: blue)
        }
    }))
}

#let al = arrow-label
#let larw = label-arrow
