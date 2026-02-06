//==============================================================================
// The Sierpiński carpet
//
// Public functions:
//     sierpinski-carpet
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate Sierpiński carpet
//
// iterations: [0, 5]
//
// Arguments:
//     n: the number of iterations
//     size: the width/height of the image (in pt), optional
//     padding: spacing around the content (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-carpet(
  n,
  size: 243,
  padding: 0,
  fill: none,
  stroke: black + 1pt
) = {
  assert(type(n) == int and n >= 0 and n <= 5, message: "`n` should be in range [0, 5]")
  assert((type(size) == int or type(size) == float) and size > 0, message: "`size` should be positive")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  // Generate Sierpiński carpet nodes recursively
  let carpet-node(level, x, y, sz) = {
    if level == 0 {return ()}
    let sz1 = sz / 3
    let node0 = (x, y, sz)
    let node1 = carpet-node(level - 1, x - 2*sz1, y - 2*sz1, sz1)
    let node2 = carpet-node(level - 1, x + sz1, y - 2*sz1, sz1)
    let node3 = carpet-node(level - 1, x + 4*sz1, y - 2*sz1, sz1)
    let node4 = carpet-node(level - 1, x - 2*sz1, y + sz1, sz1)
    let node5 = carpet-node(level - 1, x + 4*sz1, y + sz1, sz1)
    let node6 = carpet-node(level - 1, x - 2*sz1, y + 4*sz1, sz1)
    let node7 = carpet-node(level - 1, x + sz1, y + 4*sz1, sz1)
    let node8 = carpet-node(level - 1, x + 4*sz1, y + 4*sz1, sz1)
    return ((node0,), node1, node2, node3, node4, node5, node6, node7, node8).join()
  }

  let v = carpet-node(n, padding + size / 3, padding + size / 3, size / 3)

  let cmd = ()
  cmd.push(std.curve.move((padding * 1pt, padding * 1pt)))
  cmd.push(std.curve.line((size * 1pt, 0pt), relative: true))
  cmd.push(std.curve.line((0pt, size * 1pt), relative: true))
  cmd.push(std.curve.line((-size * 1pt, 0pt), relative: true))
  cmd.push(std.curve.close(mode: "straight"))
  for node in v {
    let x0 = node.at(0)
    let y0 = node.at(1)
    let sz0 = node.at(2)
    cmd.push(std.curve.move((x0 * 1pt, y0 * 1pt)))
    cmd.push(std.curve.line((0pt, sz0 * 1pt), relative: true))
    cmd.push(std.curve.line((sz0 * 1pt, 0pt), relative: true))
    cmd.push(std.curve.line((0pt, -sz0 * 1pt), relative: true))
    cmd.push(std.curve.close(mode: "straight"))
  }

  box(
    width: (size + 2*padding) * 1pt, height: (size + 2*padding) * 1pt,
    place(std.curve(fill: fill, stroke: stroke, ..cmd))
  )
}
