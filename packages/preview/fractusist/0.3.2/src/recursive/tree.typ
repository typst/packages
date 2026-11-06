//==============================================================================
// The fractal tree
//
// Public functions:
//     fractal-tree, random-fractal-tree
//     pythagorean-tree
//==============================================================================


#import "@preview/suiji:0.3.0": *


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate fractal tree
//
// iterations: [1, 14]
//
// Arguments:
//     n: the number of iterations
//     root-color: root branch color, optional
//     leaf-color: leaf color, optional
//     trunk-len: initial length of the trunk (in pt), optional
//     trunk-rad: initial radius of the trunk (in pt), optional
//     theta: initial angle of the branch (in $pi$ radius), optional
//     angle: angle between branches in the same level (in $pi$ radius), optional
//     ratio: contraction factor between successive trunks, optional
//     padding: spacing around the content (in pt), optional
//
// Returns:
//     content: generated vector graphic
#let fractal-tree(
  n,
  root-color: rgb("#46230A"),
  leaf-color: rgb("#228B22"),
  trunk-len: 100,
  trunk-rad: 3.0,
  theta: 1/2,
  angle: 1/4,
  ratio: 0.8,
  padding: 0
) = {
  assert(type(n) == int and n >= 1 and n <= 14, message: "`n` should be in range [1, 14]")
  assert(type(root-color) == color, message: "`root-color` should be an color")
  assert(type(leaf-color) == color, message: "`leaf-color` should be an color")
  assert((type(trunk-len) == int or type(trunk-len) == float) and trunk-len > 0, message: "`trunk-len` should be positive")
  assert((type(trunk-rad) == int or type(trunk-rad) == float) and trunk-rad > 0, message: "`trunk-rad` should be positive")
  assert((type(theta) == int or type(theta) == float) and theta >= 0 and theta <= 1, message: "`theta` should be in range [0, 1]")
  assert((type(angle) == int or type(angle) == float) and angle >= 0 and angle <= 1/2, message: "`angle` should be in range [0, 1/2]")
  assert(type(ratio) == float and ratio > 0 and ratio < 1, message: "`ratio` should be in range (0, 1)")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  let a = angle * calc.pi

  // Generate fractal tree nodes recursively
  let fractal-tree-node(level, x, y, t, r, theta) = {
    if level == 0 {return ()}
    let x1 = x + t * calc.cos(theta)
    let y1 = y - t * calc.sin(theta)
    let node0 = (level, x, y, x1, y1)
    let theta1 = theta + a
    let theta2 = theta - a
    let node1 = fractal-tree-node(level - 1, x1, y1, t * r, r, theta1)
    let node2 = fractal-tree-node(level - 1, x1, y1, t * r, r, theta2)
    return ((node0,), node1, node2).join()
  }

  let v = fractal-tree-node(n, 0, 0, trunk-len, ratio, theta * calc.pi)
  v = v.sorted(key: it => -it.at(0))

  let (x-min, x-max, y-min, y-max) = (0, 0, 0, 0)
  for node in v {
    x-min = calc.min(x-min, node.at(1), node.at(3))
    x-max = calc.max(x-max, node.at(1), node.at(3))
    y-min = calc.min(y-min, node.at(2), node.at(4))
    y-max = calc.max(y-max, node.at(2), node.at(4))
  }
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding

  box(width: (x-max - x-min) * 1pt, height: (y-max - y-min) * 1pt,
    for node in v {
      let level-ratio = node.at(0) / n
      let paint-color = color.mix((root-color, level-ratio), (leaf-color, 1 - level-ratio))
      let line-width = calc.max(0.25, trunk-rad * level-ratio) * 1pt
      place(
        line(
          start: ((node.at(1) - x-min) * 1pt, (node.at(2) - y-min) * 1pt),
          end: ((node.at(3) - x-min) * 1pt, (node.at(4) - y-min) * 1pt),
          stroke: (paint: paint-color, thickness: line-width, cap: "round")
        )
      )
    }
  )
}


// Generate random fractal tree
//
// iterations: [1, 14]
//
// Arguments:
//     n: the number of iterations
//     seed: value of seed, effective value is an integer from [0, 2^32-1], optional
//     root-color: root branch color, optional
//     leaf-color: leaf color, optional
//     trunk-len: initial length of the trunk (in pt), optional
//     trunk-rad: initial radius of the trunk (in pt), optional
//     theta: initial angle of the branch (in $pi$ radius), optional
//     angle: angle between branches in the same level (in $pi$ radius), optional
//     ratio: contraction factor between successive trunks, optional
//     padding: spacing around the content (in pt), optional
//
// Returns:
//     content: generated vector graphic
#let random-fractal-tree(
  n,
  seed: 42,
  root-color: rgb("#46230A"),
  leaf-color: rgb("#228B22"),
  trunk-len: 100,
  trunk-rad: 3.0,
  theta: 1/2,
  angle: 1/4,
  ratio: 0.8,
  padding: 0
) = {
  assert(type(n) == int and n >= 1 and n <= 14, message: "`n` should be in range [1, 14]")
  assert(type(seed) == int, message: "`seed` should be an integer")
  assert(type(root-color) == color, message: "`root-color` should be an color")
  assert(type(leaf-color) == color, message: "`leaf-color` should be an color")
  assert((type(trunk-len) == int or type(trunk-len) == float) and trunk-len > 0, message: "`trunk-len` should be positive")
  assert((type(trunk-rad) == int or type(trunk-rad) == float) and trunk-rad > 0, message: "`trunk-rad` should be positive")
  assert((type(theta) == int or type(theta) == float) and theta >= 0 and theta <= 1, message: "`theta` should be in range [0, 1]")
  assert((type(angle) == int or type(angle) == float) and angle >= 0 and angle <= 1/2, message: "`angle` should be in range [0, 1/2]")
  assert(type(ratio) == float and ratio > 0 and ratio < 1, message: "`ratio` should be in range (0, 1)")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  let rng-ini = gen-rng-f(seed)
  let a = angle * calc.pi

  // Generate random fractal tree nodes recursively
  let random-fractal-tree-node(rng, level, x, y, t, r, th) = {
    if level == 0 {return (rng, ())}
    let rnd = 0
    let node1 = ()
    let node2 = ()
    (rng, rnd) = random-f(rng)
    let randt = (rnd + level / (2*n)) * t
    let x1 = x + randt * calc.cos(th)
    let y1 = y - randt * calc.sin(th)
    let node0 = (level, x, y, x1, y1)
    (rng, rnd) = random-f(rng)
    let th1 = th + rnd * a
    (rng, rnd) = random-f(rng)
    let th2 = th - rnd * a
    (rng, node1) = random-fractal-tree-node(rng, level - 1, x1, y1, t * r, r, th1)
    (rng, node2) = random-fractal-tree-node(rng, level - 1, x1, y1, t * r, r, th2)
    return (rng, ((node0,), node1, node2).join())
  }

  let (_, v) = random-fractal-tree-node(rng-ini, n, 0, 0, trunk-len, ratio, theta * calc.pi)
  v = v.sorted(key: it => -it.at(0))

  let (x-min, x-max, y-min, y-max) = (0, 0, 0, 0)
  for node in v {
    x-min = calc.min(x-min, node.at(1), node.at(3))
    x-max = calc.max(x-max, node.at(1), node.at(3))
    y-min = calc.min(y-min, node.at(2), node.at(4))
    y-max = calc.max(y-max, node.at(2), node.at(4))
  }
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding

  box(width: (x-max - x-min) * 1pt, height: (y-max - y-min) * 1pt,
    for node in v {
      let level-ratio = node.at(0) / n
      let paint-color = color.mix((root-color, level-ratio), (leaf-color, 1 - level-ratio))
      let line-width = calc.max(0.25, trunk-rad * level-ratio) * 1pt
      place(
        line(
          start: ((node.at(1) - x-min) * 1pt, (node.at(2) - y-min) * 1pt),
          end: ((node.at(3) - x-min) * 1pt, (node.at(4) - y-min) * 1pt),
          stroke: (paint: paint-color, thickness: line-width, cap: "round")
        )
      )
    }
  )
}


// Generate Pythagorean tree
//
// iterations: [1, 14]
//
// Arguments:
//     n: the number of iterations
//     root-color: root branch color, optional
//     leaf-color: leaf color, optional
//     trunk-len: initial length of the trunk (in pt), optional
//     theta: initial angle of the branch (in $pi$ radius), optional
//     start-angle: starting angle of base square bottom edge direction (in $pi$ radius), optional
//     padding: spacing around the content (in pt), optional
//     filling: whether the drawing is filling, optional; default is true, false is wireframe
//
// Returns:
//     content: generated vector graphic
#let pythagorean-tree(
  n,
  root-color: rgb("#46230A"),
  leaf-color: rgb("#228B22"),
  trunk-len: 50,
  theta: 1/5,
  start-angle: 0,
  padding: 0,
  filling: true
) = {
  assert(type(n) == int and n >= 1 and n <= 14, message: "`n` should be in range [1, 14]")
  assert(type(root-color) == color, message: "`root-color` should be an color")
  assert(type(leaf-color) == color, message: "`leaf-color` should be an color")
  assert((type(trunk-len) == int or type(trunk-len) == float) and trunk-len > 0, message: "`trunk-len` should be positive")
  assert(type(theta) == float and theta > 0 and theta < 1/2, message: "`theta` should be in range (0, 1/2)")
  assert((type(start-angle) == int or type(start-angle) == float) and start-angle >= 0 and start-angle < 2, message: "`start-angle` should be in range [0, 2)")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")
  assert(type(filling) == bool, message: "`filling` should be boolean")

  let c1 = calc.cos(theta * calc.pi) * calc.cos(theta * calc.pi)
  let c2 = calc.cos(theta * calc.pi) * calc.sin(theta * calc.pi)

  // Generate Pythagorean tree nodes recursively
  let pythagorean-tree-node(level, x, y, dx, dy) = {
    if level == 0 {return ()}
    let x1 = x + dy
    let y1 = y - dx
    let dx1 = c1 * dx + c2 * dy
    let dy1 = -c2 * dx + c1 * dy
    let x2 = x1 + dx1
    let y2 = y1 + dy1
    let dx2 = dx - dx1
    let dy2 = dy - dy1
    let node0 = (level, x, y, dx, dy)
    let node1 = pythagorean-tree-node(level - 1, x1, y1, dx1, dy1)
    let node2 = pythagorean-tree-node(level - 1, x2, y2, dx2, dy2)
    return ((node0,), node1, node2).join()
  }

  let a = start-angle * calc.pi
  let v = pythagorean-tree-node(n, 0, 0, calc.cos(a) * trunk-len, -calc.sin(a) * trunk-len)
  v = v.sorted(key: it => -it.at(0))

  let (x-min, x-max, y-min, y-max) = (0, 0, 0, 0)
  for node in v {
    let x1 = node.at(1)
    let y1 = node.at(2)
    let x2 = x1 + node.at(3)
    let y2 = y1 + node.at(4)
    let x3 = x2 + node.at(4)
    let y3 = y2 - node.at(3)
    let x4 = x1 + node.at(4)
    let y4 = y1 - node.at(3)
    x-min = calc.min(x-min, x1, x2, x3, x4)
    x-max = calc.max(x-max, x1, x2, x3, x4)
    y-min = calc.min(y-min, y1, y2, y3, y4)
    y-max = calc.max(y-max, y1, y2, y3, y4)
  }
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding

  let square-cmd(xc, yc, dx, dy) = (
    std.curve.move((xc * 1pt, yc * 1pt)),
    std.curve.line((dx * 1pt, dy * 1pt), relative: true),
    std.curve.line((dy * 1pt, -dx * 1pt), relative: true),
    std.curve.line((-dx * 1pt, -dy * 1pt), relative: true),
    std.curve.close(mode: "straight")
  )

  box(width: (x-max - x-min) * 1pt, height: (y-max - y-min) * 1pt,
    for node in v {
      let x1 = node.at(1)
      let y1 = node.at(2)
      let dx = node.at(3)
      let dy = node.at(4)
      let level-ratio = node.at(0) / n
      let paint-color = color.mix((root-color, level-ratio), (leaf-color, 1 - level-ratio))
      place(
        if filling {
          std.curve(stroke: none, fill: paint-color, ..square-cmd(x1 - x-min, y1 - y-min, dx, dy))
        } else {
          std.curve(stroke: paint-color, fill: none, ..square-cmd(x1 - x-min, y1 - y-min, dx, dy))
        }
      )
    }
  )
}
