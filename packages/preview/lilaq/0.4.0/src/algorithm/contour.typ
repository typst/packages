#import "../math.typ": vec

/// Computes the orientation of a polygon, returns `left` if the polygon is 
/// lefthanded (counter-clockwise) and `right` if it is righthanded (clockwise). 
#let compute-polygon-orientation(..arr) = {
  arr = arr.pos()
  let r = arr.zip(arr.slice(1))
    .map(((A, B)) => (A.at(0) - B.at(0)) * (A.at(1) + B.at(1)))
  let s = r.sum(default: 0)
  if s < -0.0000000000001 { return right } 
  else if s > 0.000000000001 { return left }
}
// #assert.eq(compute-polygon-orientation( (5, −5),
//         (−5, −5),
//         (−1.6666666666666665, −5),
//         (1.666666666666667, −5),
//         (5, −5),), none)
#assert.eq(compute-polygon-orientation((0,0), (0,1), (1,1), (1,0)), right)
#assert.eq(compute-polygon-orientation((0,0), (1,0), (1,1), (0,1)), left)
#assert.eq(compute-polygon-orientation((0,0), (1,0)), none)
#assert.eq(compute-polygon-orientation((0,0), (0,1)), none)


      
/// Retrieves the center coordinate of a hyperbolic paraboloid (HP) surface
/// given by the parameter values u=v=0.5. 
/// p1 ·-----· p2
///    |  · ←|
/// p4 ·-----· p3
#let get-hp-center-z(z1, z2, z3, z4) = {
  return 0.25 * (z1 + z2 + z3 + z4)
}


/// Given two points $p_1$, $p_2$ in 3D space, find whether the line between
/// theses points intersects a plane $z=z_0$ and at which coordinates $(x,y)$. 
/// Returns `none` if the segment does not intersect the plane between $p_1$
/// and $p_2$.
#let intersect-z-plane(p1, p2, z0) = {
  let (dx, dy, dz) = vec.subtract(p2, p1)
  if dz == 0 /*and z0 != p1.at(2)*/ { return none }
  let ratio = (z0 - p1.at(2)) / dz
  if ratio < 0 or ratio > 1 { return none }
  return (p1.at(0) + ratio*dx, p1.at(1) + ratio*dy)
}

#assert.eq(intersect-z-plane((0,0,0), (2,0,1), .2), (.4, 0))
#assert.eq(intersect-z-plane((0,0,0), (2,0,1), 1), (2, 0))
#assert.eq(intersect-z-plane((0,0,0), (2,0,1), 1.1), none)
#assert.eq(intersect-z-plane((0,0,0), (2,0,1), -.01), none)


/// Given a list of (oriented) segments as pairs of points, returns
/// a list of polygons constructed from connected components in the set of 
/// segments. The orientation plays a role. 
#let group-segments(segments) = {
  let cycles = ()
  while segments.len() > 0 {
    let segment = segments.pop()
    let k = segments
    let (p1, p2) = segment
    let cycle = (p1, p2)
    let start = segment
    while true {
      let pos = segments.position(x => x.first() == p2)
      if pos != none {
        start = segments.remove(pos)
        p2 = start.last()
        cycle.push(p2)
      } else {
        break
      }
    }
    cycle = cycle.rev()
    p1 = cycle.last()
    while true {
      let pos = segments.position(x => x.last() == p1)
      if pos != none {
        p1 = segments.remove(pos).first()
        cycle.push(p1)
      } else {
        break
      }
    }
    cycles.push(cycle)
  }
  return cycles
}


#let close-path-at-boundaries(path, boundaries: (xmin: 0, xmax: 1, ymin: 0, ymax: 1)) = {
  let corners = (
    (boundaries.xmax, boundaries.ymax), 
    (boundaries.xmax, boundaries.ymin), 
    (boundaries.xmin, boundaries.ymin), 
    (boundaries.xmin, boundaries.ymax)
  )
  if path.first() == path.last() { return path.rev() }
  let get-case(point) = {
    let case = 0
    
  }
  let get-edge(point) = {
    if point.at(1) == boundaries.ymax { return 0 } // top
    if point.at(1) == boundaries.ymin { return 2 } // bottom
    if point.at(0) == boundaries.xmax { return 1 } // right
    if point.at(0) == boundaries.xmin { return 3 } // left
    let k = point
    return none
  }
  let edge1 = get-edge(path.last())
  let edge2 = get-edge(path.first())
  if none in (edge1, edge2) { return none }

  
  let edges = (edge1, edge2)

  let rrange(a, b) = {
    if a < b { a+= 4}
    let r = calc.rem(1 - 3, 4)
    
    if a <= b { range(a, b) }
    else { 
      return range(b, a).rev() 
    } 
  }
  let f = rrange(edge1, edge2)
  if calc.rem-euclid(edge1 - edge2, 4) > 2 {
    f = rrange(edge2, edge1).rev()
  } else {
    f = rrange(edge1, edge2)
  }
  for i in f {
    path.push(corners.at(calc.rem(i, 4)))
  }
  path.push(path.first())
  return path.rev()
}


#let mod-distance(a, b, div) = {
  let diff =  b - a
  calc.abs(calc.rem(diff, div))
}
#assert.eq(mod-distance(0, 1, 4), 1)
#assert.eq(mod-distance(1, 0, 4), 1)
#assert.eq(mod-distance(1, 2, 4), 1)
#assert.eq(mod-distance(0, 2, 4), 2)
// #assert.eq(mod-distance(3, 0, 4), 1)
#assert.eq(mod-distance(2, 2, 4), 0)
#assert.eq(mod-distance(0, 2, 4), 2)
#assert.eq(mod-distance(2, 0, 4), 2)

#assert.eq(mod-distance(0, 5, 4), 1)

#let close-path-at-boundaries(path, boundaries: (xmin: 0, xmax: 1, ymin: 0, ymax: 1)) = {
  let corners = (
    (boundaries.xmax, boundaries.ymax), 
    (boundaries.xmax, boundaries.ymin), 
    (boundaries.xmin, boundaries.ymin), 
    (boundaries.xmin, boundaries.ymax)
  )
  if path.len() == 0 or path.first() == path.last() { return path.rev() }
  let get-edge(point) = {
    if point.at(1) == boundaries.ymax { return 0 } // top
    if point.at(1) == boundaries.ymin { return 2 } // bottom
    if point.at(0) == boundaries.xmax { return 1 } // right
    if point.at(0) == boundaries.xmin { return 3 } // left
    return none
  }
  
  let edge1 = get-edge(path.last())
  let edge2 = get-edge(path.first())
  if none in (edge1, edge2) { return none }

  
  if edge1 == edge2 {
    path.push(path.first())
    return path.rev()
  } else if calc.rem(edge1 + 2, 4) == edge2 { // opposite edges
    if edge1 in (0,2) { // top/bottom
      let mid-x = 0.5 * (boundaries.xmax - boundaries.xmin)
      // if path.last().at(0) < mid-x
      let vertices = (corners.at(0), corners.at(1))
      if edge1 == 2 { vertices = vertices.rev() }
      path += vertices
    } else { // left/right
      let vertices = (corners.at(3), corners.at(0))
      // let vertices = (corners.at(2), corners.at(1))
      if edge1 == 1 { vertices = vertices.rev() }
      path += vertices
      if path.last().last() < -3 {
        let k = path
      }
    }
  } else {
    if calc.rem(edge1 + 1, 4) == edge2 {
      path.push(corners.at(edge1))
    } else if calc.rem(edge2 + 1, 4) == edge1 {
      path.push(corners.at(edge2))
    } else { assert(false) }
  }
  path.push(path.first())
  return path.rev()
  
  let edges = (edge1, edge2)

  let rrange(a, b) = {
    if a < b { a+= 4}
    let r = calc.rem(1 - 3, 4)
    
    if a <= b { range(a, b) }
    else { 
      return range(b, a).rev() 
    } 
  }
  let f = rrange(edge1, edge2)
  if calc.rem-euclid(edge1 - edge2, 4) > 2 {
    f = rrange(edge2, edge1).rev()
  } else {
    f = rrange(edge1, edge2)
  }
  for i in f {
    path.push(corners.at(calc.rem(i, 4)))
  }
  path.push(path.first())
  return path.rev()
}


#let test-close-boundaries(curve, result) = {
  let test-boundaries = (xmin: 0, xmax: 1, ymin: 0, ymax: 1)
  let closed-curve = close-path-at-boundaries(curve, boundaries: test-boundaries)
  if result != none {
    assert.eq(closed-curve, result.rev())
  }
  box(width: 1cm, height: 1cm, fill: luma(90%), {
    let transform(p) = (p.at(0)*1cm, 1cm - p.at(1)*1cm)
    let vertices = closed-curve.map(transform)
    place(std.curve(
      std.curve.move(vertices.first()),
      ..vertices.slice(1).map(std.curve.line),
    )) 
  })
}
// #test-close-boundaries((), ())
#test-close-boundaries(((.5,0), (1,.5)),
  ((.5, 0), (1, .5), (1, 0), (.5, 0))
)
#test-close-boundaries(((1,.5), (.5,0)),
  ((1, .5), (.5, 0), (1, 0), (1, .5))
)
#test-close-boundaries(((1,.5), (.5,1)),
  ((1, .5), (.5, 1), (1, 1), (1, .5))
)
#test-close-boundaries(((.5,1), (1,.5)),
  ((.5, 1), (1, .5), (1, 1), (.5, 1))
)
#test-close-boundaries(((0,.5), (.5,1)),
  ((0, .5), (.5, 1), (0, 1), (0, .5))
)
#test-close-boundaries(((.5,1), (0,.5)),
  ((.5, 1), (0, .5), (0, 1), (.5, 1))
)
#test-close-boundaries(((0,.5), (.5,0)),
  ((0, .5), (.5, 0), (0, 0), (0, .5))
)
#test-close-boundaries(((.5,0), (0,.5)),
  ((.5, 0), (0, .5), (0, 0), (.5, 0))
)

#test-close-boundaries(((.2,0), (.5, .5), (.8, 0)),
  ((.2,0), (.5, .5), (.8, 0), (.2, 0))
)
#test-close-boundaries(((.2, 1), (.5, .5), (.8, 1)),
  ((.2, 1), (.5, .5), (.8, 1), (.2, 1))
)
#test-close-boundaries(((0, .2), (.5, .5), (0, .8)),
  ((0, .2), (.5, .5), (0, .8), (0, .2))
)
#test-close-boundaries(((1, .2), (.5, .5), (1, .8)),
  ((1, .2), (.5, .5), (1, .8), (1, .2))
)

#test-close-boundaries(((1, 0), (0, 1)),
  none
)
#test-close-boundaries(((0, 1), (1, 0)),
  none
)
#test-close-boundaries(((1, 1), (0, 0)),
  none
)
#test-close-boundaries(((0, 0), (1, 1)),
  none
)


#test-close-boundaries(((1, 0), (0, .5)),
  none
)
#test-close-boundaries(((1, 0), (.5, 1)),
  none
)
#test-close-boundaries(((0, .2), (1, .3)),
  none
)
#test-close-boundaries(((0, .7), (1, .8)),
  none
)

#test-close-boundaries(((1, 0), (1, 1)),  none)
#test-close-boundaries(((1, 1), (1, 0)),  none)



#let generate-contour(x, y, z, level, z-range: 1) = {
  let get-z(i, j) = { z.at(i).at(j) }
  let get-p(i, j) = { (x.at(i), y.at(j), z.at(i).at(j)) }

  let blocks = ()
  for i in range(x.len() - 1) {
    for j in range(y.len() - 1) {
      let zs = (get-z(i, j), get-z(i+1, j), get-z(i, j+1), get-z(i+1,j+1))
      if calc.min(..zs) <= level and calc.max(..zs) >= level {
        blocks.push((i, j))
      }
    }
  } 

  let segments = ()
  while blocks.len() > 0 {
    let (i, j) = blocks.pop()
    /*
    0: → (0,0) -> (1,0)
    1: ↓ (1,0) -> (1,1)
    2: ← (1,1) -> (0,1)
    3: ↑ (0,1) -> (0,0)
    */
    let qqqs = ((0,0), (1,0), (1,1), (0,1), (0,0))
    let intersections = ()
    for edge in range(4) {
      let (Ax, Ay) = qqqs.at(edge)
      let (Bx, By) = qqqs.at(edge + 1)
      let p1 = get-p(Ax + i, Ay + j)
      let p2 = get-p(Bx + i, By + j)
      if edge < 2 { (p1, p2) = (p2, p1) }
      let interpolation = intersect-z-plane(p1, p2, level)
      if interpolation == p2.slice(0,2) and edge > 2 {
        // edge += 1
      }
      if interpolation != none {
        intersections.push((edge, interpolation))
      }
    }
    intersections = intersections.dedup(key: x => x.at(1))
    let sort-intersection-tuple(i1, i2) = {
      let corner = qqqs.at(i2.at(0))
      if corner == i2.at(1) {
        // (i1, i2) = (i2, i1)
      }
      if get-z(..vec-add(corner, (i,j))) < level {
        (i1, i2) = (i2, i1)
      }
      return (i1.at(1), i2.at(1))
    }
    
    // assert(intersections.len() in (2,4))
    if intersections.len() == 2 {
      segments.push(sort-intersection-tuple(..intersections))
    } else if intersections.len() == 4 {
      let z0 = get-hp-center-z(get-z(i, j), get-z(i+1, j), get-z(i, j+1), get-z(i+1,j+1))
      let (a,b,c,d) = intersections
      if calc.abs(z0 - level) < 1e-6* z-range {
        let center = (0.5*(x.at(i) + x.at(i+1)), 0.5*(y.at(j) + y.at(j+1)))
        let (c1, c2) = (center, center)
        c1.at(0) += 1e-30
        c2.at(0) -= 1e-30
        c1.at(0) += .2
        c2.at(0) -= .2
        if get-z(i, j) > level{ (c1, c2) = (c2, c1)}
        let seg1 = sort-intersection-tuple(a, d)
        let seg2 = sort-intersection-tuple(b, c)
        segments.push((seg1.at(0), c1))
        segments.push((seg2.at(0), c2))
        
        if get-z(i, j) > level {
          (c1, c2) = (c2, c1)
        }
        segments.push((c2, seg1.at(1)))
        segments.push((c1, seg2.at(1)))
        // segments.push((a,b,c,d))
      } else if z0 > level {
        if get-z(i, j) > level {
          (b, d) = (d, b)
        }
        segments.push(sort-intersection-tuple(a,d))
        segments.push(sort-intersection-tuple(c,b))
        // segments.push((a,d,b,c))
      } else if level > z0 {
        if get-z(i, j) > level {
          (d, b) = (b, d)
        }
        segments.push(sort-intersection-tuple(a,b))
        segments.push(sort-intersection-tuple(c,d))
        // segments.push((a,c,b,d))
      } 
    } else {
      // segments.push(sort-intersection-tuple(..intersections.slice(0,2)))
      // let o = (i,j)
      // assert(false)
    }
  }
  let paths = group-segments(segments)
  return paths
}

#let lshift(a) = 2*a

#let bw-or(a,b) = {
    let c = 0;
    let n = 1;
    while ((a > 0) or (b > 0)) {
      if ((calc.rem(a, 2) == 1) or (calc.rem(b, 2) == 1)) {
          c += n;    
      }
      a = calc.quo(a, 2);
      b = calc.quo(b, 2);
      n = n * 2;
    }
    return c;
}

#assert.eq(bw-or(0b00, 0b11), 0b11)
#assert.eq(bw-or(0b010001, 0b110100), 0b110101)

#let compute-case(corners-z, level) = {
  let case = 0
  for z in corners-z {
    case = bw-or(lshift(case), if z > level {1} else {0})
  }
  if case == 0 {
    if corners-z.filter(x => x == level).len() == 2 {
      for z in corners-z {
        case = bw-or(lshift(case), if z >= level {1} else {0})
      }
    }
  }
  return case
}

#assert.eq(compute-case((-1,-1,-1,-1), 0), 0)
#assert.eq(compute-case((1,1,1,1), 0), 15)
#assert.eq(compute-case((-1,-1,-1,1), 0), 1)
#assert.eq(compute-case((-1,-1,1,-1), 0), 2)
#assert.eq(compute-case((-1,-1,1,1), 0), 3)
#assert.eq(compute-case((-1,1,-1,-1), 0), 4)

#assert.eq(compute-case((-1,-1,-1,1), 0), 1)
#assert.eq(compute-case((0,0,-1,-1), 0), 12)



#let generate-contour(x, y, z, level, z-range: 1) = {
  let z-eps = 1e-6 * z-range
  let x-eps = 1e-17 * (x.last() - x.first())
  
  let get-z(i, j) = { z.at(j).at(i) }
  let get-p(i, j) = { (x.at(i), y.at(j), z.at(j).at(i)) }

  let blocks = ()
  for i in range(x.len() - 1) {
    for j in range(y.len() - 1) {
      let zs = (get-z(i, j), get-z(i+1, j), get-z(i, j+1), get-z(i+1,j+1))
      if calc.min(..zs) <= level and calc.max(..zs) >= level {
        blocks.push((i, j))
      }
    }
  } 

  let segments = ()
  while blocks.len() > 0 {
    let (i, j) = blocks.pop()
    let corners = ((0,0), (1,0), (1,1), (0,1))
    let case = compute-case(corners.map(corner => get-p(..vec.add((i, j), corner)).at(2)), level)
    let qqqs = ((0,0), (1,0), (1,1), (0,1), (0,0))

    let get-edge-intersection(edge) = {
      let (Ax, Ay) = qqqs.at(edge)
      let (Bx, By) = qqqs.at(edge + 1)
      let p1 = get-p(Ax + i, Ay + j)
      let p2 = get-p(Bx + i, By + j)
      if edge < 2 { (p1, p2) = (p2, p1) }
      
      let interpolation = intersect-z-plane(p1, p2, level)
      interpolation
    }
    let get-line-segment(edge1, edge2) = ((edge2, edge1).map(get-edge-intersection),)
    
    let z0 = get-hp-center-z(get-z(i, j), get-z(i+1, j), get-z(i, j+1), get-z(i+1,j+1))

    let cases = (
      () => (),
      () => get-line-segment(3,2),
      () => get-line-segment(2,1),
      () => get-line-segment(3,1),
      () => get-line-segment(1,0),
      () => {
        if calc.abs(z0 - level) < z-eps {
          let (i0,i1,i2,i3) = (0,1,2,3).map(get-edge-intersection)
          let center = (i0.at(0), i1.at(1))
          let (c1, c2) = (center, center)
          c1.at(0) += x-eps
          c2.at(0) -= x-eps
          
          ((i0, c2), (c2, i3), (i2, c1), (c1, i1))
        } else if z0 > level {
          get-line-segment(3,0) + get-line-segment(1,2)
        } else if z0 < level {
          get-line-segment(1,0) + get-line-segment(3,2)
        }
      },
      () => get-line-segment(2,0),
      () => get-line-segment(3,0),
      () => get-line-segment(0,3),
      () => get-line-segment(0,2),
      () => {
        if calc.abs(z0 - level) < z-eps {
          let (i0,i1,i2,i3) = (0,1,2,3).map(get-edge-intersection)
          let center = (i0.at(0), i1.at(1))
          let (c1, c2) = (center, center)
          c1.at(0) -= x-eps
          c2.at(0) += x-eps
          
          ((i1, c2), (c2, i0), (i3, c1), (c1, i2))
        } else if z0 > level {
          get-line-segment(0,1) + get-line-segment(2,3)
        } else if z0 < level {
          get-line-segment(0,3) + get-line-segment(2,1)
        }
      },
      () => get-line-segment(0,1),
      () => get-line-segment(1,3),
      () => get-line-segment(1,2),
      () => get-line-segment(2,3),
      () => (),
    )
    let k = (i,j,case, (get-z(i, j), get-z(i+1, j), get-z(i, j+1), get-z(i+1,j+1)))
    segments += cases.at(case)()
  }
  let paths = group-segments(segments.dedup())
  return paths
}

#let generate-contours(x, y, z, levels, z-range: 1) = {
  return levels.map(level => generate-contour(x, y, z, level, z-range: z-range))
}
        
#let gen-contour-1rect = generate-contour.with((0,1), (0,1))


#let test-contour-case(x: (0,1), y: (0,1), z, level, answer) = {
  let z-flat = z.flatten()
  let (min, max) = (calc.min(..z-flat), calc.max(..z-flat))
  if min == max {min -=1 }
  let contour = generate-contour(x, y, z, level)
  assert.eq(contour, answer)
  box(width: 2cm, height: 2cm, stroke: .5pt,
    {
      let sq = box.with(width: 1cm, height: 1cm)
      let cmap = color.map.icefire
      let cmap = (blue, yellow, red)
      let grad = gradient.linear(..cmap)
      let get-clr(z) = grad.sample((z - min)/(max - min)*100%)
      for i in range(x.len()) {
        for j in range(y.len()) {
          place(
            dx: i * 1cm, dy: 1cm - j*1cm,
            sq(fill: get-clr(z.at(j).at(i)))
          ) 
        }
      }
      let transform(p) = (p.at(0)*2cm, 2cm - p.at(1)*2cm)
      contour.map(contour-path => {
        contour-path = contour-path.map(transform)
        place(curve(
          curve.move(contour-path.first()),
          ..contour-path.slice(1).map(curve.line),
          stroke: get-clr(level).lighten(20%) + 2pt,
        )) + place(
        dx: (contour-path.first()).at(0), 
        dy: (contour-path.first()).at(1),
        place(center + horizon, circle(fill: black, radius: 1pt))
      )}).join()
    }
  )
}

#test-contour-case(
  x: (-1,0,1), 
  y: (-5,5), 
  // ((-1,-1),(0,0),(1,1)), 
  ((-1,0,1),(-1,0,1)), 
  0, 
  ((((0, 5), (0, -5)), ))
),

#set page(height: auto, width: auto, margin: 1cm)

The dot indicates the start of a curve. A curve is to be oriented such that the _higher_ profile lies _left_ of it. 


== No intersection

#set table(align: center)

#table(columns: 3,
  [Right on], [all below], [all above],
  test-contour-case(((0,0),(0,0)), 0, ()),
  test-contour-case(((20,-20),(-20,10)), 50, ()),
  test-contour-case(((20,-20),(-20,10)), -50, ()),
)


== Saddles

// HP saddle directly through center
#table(columns: 6, 
  [Right on], [slightly above], [slightly below],
  [Right on], [slightly above], [slightly below],
  test-contour-case(((-1,1),(1,-1)), 0, 
    (((1, .5), (.5,.5), (.5,0)), ((0,.5), (.5,.5), (.5, 1)))
  ),
  test-contour-case(((-1,1),(1,-1)), 0.5, 
    ((((0,.75), (.25, 1)), ((1,.25), (.75,0))))
  ),
  test-contour-case(((-1,1),(1,-1)), -0.5,
    ((((1,.75), (.75,1)), ((0,.25), (.25, 0))))
  ),
  test-contour-case(((1,-1),(-1,1)), 0, 
    (((.5,1), (.5,.5), (1, .5)), ((.5, 0),(.5,.5), (0,.5)))
  ),
  test-contour-case(((1,-1),(-1,1)), 0.5, 
    ((((.75,1), (1,.75)), ((.25,0), (0,.25))))
  ),
  test-contour-case(((1,-1),(-1,1)), -0.5,
    ((((.25,1), (0,.75)), ((.75,0), (1,.25))))
  ),
  [Offset y], [Offset x], [skew below], [], [], [],
  
  test-contour-case(
    ((-3,3),(1,-1)), 
    0,
    (((1, .75), (.5,.75), (.5,0)), 
    ((0,.75), (.5,.75), (.5, 1)))
  ),
  test-contour-case(
    ((-3,1),(3,-1)), 0, 
    (((1, .5), (.75,.5), (.75,0)), ((0,.5), (.75,.5), (.75, 1)))
  ),
  test-contour-case(((-3,3),(3,-1)), 0, 
    (((1, .75), (.75,1)), ((0,.5), (.5, 0)))
  ),
)


== Cross to opposite side

#table(columns: 4, 
  [Left to right], [Right to left], [Top to bottom], [Bottom to top],
  // o  o
  // ---→
  // x  x
  test-contour-case(((1,0),(2, 6)), 1.5, 
    ((((0,.5), (1, .25)), ))
  ),
  // x  x
  // ←---
  // o  o
  test-contour-case(((2,6),(1, 0)), 1.5, 
    ((((1,.75), (0, .5)), ))
  ),
  // x | o
  //   |
  // x ↓ o
  test-contour-case(((1,2),(0, 6)), 1.5, 
    ((((.25,1), (.5, 0)), ))
  ),
  // o ↑ x
  //   |
  // o | x
  test-contour-case(((2,0),(6,1)), 1.5, 
    ((((.25,0), (.9,1)), ))
  ),
)

// let mesh_ = create-mesh(linspace(-5, 5, num: 3), linspace(-5, 5, num: 2), func)

== Corners

#table(columns: 4,
  [Bottom to left], [Left to bottom],[Right to bottom],[Bottom to right],
  // x   x
  // ←-|
  // o | x  (o above level)
  test-contour-case(((6,2),(0,0)), 3, 
    ((((.75,0), (0,.5)), ))
  ),
  // o   o
  // --|
  // x ↓ o  (x below level)
  test-contour-case(((-4,2),(0,0)), -1, 
    ((((0,.75), (.5,0)), ))
  ),
  // x   x
  //   |--
  // x ↓ o
  test-contour-case(((-4,4),(-1,-1)), 0, 
    ((((1,.8), (.5,0)), ))
  ),
  // o   o
  //   |-→
  // o | x
  test-contour-case(((4,-4),(1,1)), 0, 
    ((((.5,0), (1,.8)), ))
  ),
  [Top to right], [Right to top],[Left to top],[Top to left],
  
  // x | o
  //   |-→
  // x   x
  test-contour-case(((-4,-4),(-4,4)), 0, 
    ((((.5,1), (1,.5)), ))
  ),
  // o ↑ x
  //   |--
  // o   o
  test-contour-case(((4,4),(4,-4)), 0, 
    ((((1,.5), (.5,1)), ))
  ),
  // o ↑ x
  // --|
  // x   x
  test-contour-case(((-4,-4),(4,-4)), 0, 
    ((((0,.5), (.5,1)), ))
  ),
  // x | o
  // ←-|
  // o   o
  test-contour-case(((4,4),(-4,4)), 0, 
    ((((.5,1), (0,.5)), ))
  ),

)


== Edge cases

#table(columns: 4,
  [Top below], [Top above], [Bottom below], [Bottom above],
  // ·←--·
  // 
  // o   o
  test-contour-case(((3,4),(0,0)), 0, 
    ((((1,1), (0,1)), ))
  ),
  
  // ·--→·
  // 
  // x   x
  test-contour-case(((-3,-4),(0,0)), 0, 
    ((((0,1), (1,1)), ))
  ),
  
  // o   o
  // 
  // ·--→·
  test-contour-case(((0,0),(3,4)), 0, 
    ((((0,0), (1,0)), ))
  ),
  
  // x   x
  // 
  // ·←--·
  test-contour-case(((0,0),(-3,-4)), 0, 
    ((((1,0), (0,0)), ))
  ),
  
  [Left below], [Left above], [Top below], [Top above],
  // ·   o
  // ↓
  // ·   o
  test-contour-case(((0,3),(0,4)), 0, 
    ((((0,1), (0,0)), ))
  ),
  
  // ·   x
  // ↑
  // ·   x
  test-contour-case(((0,-3),(0,-4)), 0, 
    ((((0,0), (0,1)), ))
  ),
  
  // o   ·
  //     ↑
  // o   ·
  test-contour-case(((3,0),(4,0)), 0, 
    ((((1,0), (1,1)), ))
  ),
  
  // x   ·
  //     ↓
  // x   ·
  test-contour-case(((-3,0),(-4,0)), 0, 
    ((((1,1), (1,0)), ))
  ),
)

