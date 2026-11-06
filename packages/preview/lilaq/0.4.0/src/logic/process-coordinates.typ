
/// Takes an array of points as input and filters all points where at least one
/// coordinate is `calc.nan` to produce
/// + a filtered copy of the input array
/// + an array of consecutive "runs", i.e., all connected sequences from the input
///   separated by points where one or more coordinates take the value `calc.nan`. 
/// 
/// -> array
#let filter-nan-points(
  
  /// Input points. The points themselves may have any dimension.
  /// -> array
  points, 
  
  /// Whether to to split the data into separate runs whenever a coordinate 
  /// containing a `nan` value is encountered.  
  /// -> bool
  generate-runs: false
  
) = {
  if generate-runs {
    let filtered-points = ()
    let runs = ((),)
    for coord in points {
      if coord.find(float.is-nan) != none { 
        if runs.last().len() != 0 {
          runs.push(())
        }
        continue 
      }
      filtered-points.push(coord)
      runs.last().push(coord)
    }
    return (filtered-points, runs)
  } else {
    return points.filter(p => p.find(float.is-nan) == none)
  }
}


/// Converts an array of points to a step sequence. 
/// Given $n$ points, the output will have $2n-1$ points and zero points 
/// if the input has zero points. 
///
/// -> array
#let stepify(

  /// Input points of the form `(x, y)` with `nan` values removed. 
  /// -> array
  points, 

  /// Step mode
  /// - `start`: The interval $(x_{i-1}, x_i]$ takes the value of $x_i$. 
  /// - `end`: The interval $[x_i, x_{i+1})$ takes the value of $x_i$. 
  /// - `center`: The value switches half-way between consecutive $x$ positions. 
  /// -> start | center | end
  step: start

) = {
  if points.len() == 0 { return () }
  let result = ()
  if step == start {
    for i in range(points.len() - 1) {
      result.push(points.at(i))
      result.push((points.at(i).at(0), points.at(i + 1).at(1)))
    }
  } else if step == end {
    for i in range(points.len() - 1) {
      result.push(points.at(i))
      result.push((points.at(i + 1).at(0), points.at(i).at(1)))
    }
  } else if step == center {
    for i in range(points.len() - 1) {
      result.push(points.at(i))
      let mid = 0.5 * (points.at(i).at(0) + points.at(i + 1).at(0))
      result.push((mid, points.at(i).at(1)))
      result.push((mid, points.at(i + 1).at(1)))
    }
  }
  result.push(points.last())
  return result
}

#assert.eq(stepify((), step: start), ())
#assert.eq(stepify(((0,0),), step: start), ((0,0),))
#assert.eq(stepify(((0,0), (1,.7)), step: start), ((0,0), (0,.7), (1,.7)))
#assert.eq(stepify(((0,0), (1,.7), (3,-.1)), step: start), ((0,0), (0,.7), (1,.7), (1,-.1), (3,-.1)))

#assert.eq(stepify((), step: end), ())
#assert.eq(stepify(((0,0),), step: end), ((0,0),))
#assert.eq(stepify(((0,0), (1,.7)), step: end), ((0,0), (1,0), (1,.7)))
#assert.eq(stepify(((0,0), (1,.7), (3,-.1)), step: end), ((0,0), (1,0), (1,.7), (3, .7), (3,-.1)))

#assert.eq(stepify((), step: center), ())
#assert.eq(stepify(((0,0),), step: center), ((0,0),))
#assert.eq(stepify(((0,0), (1,.7)), step: center), ((0,0), (0.5,0), (0.5, .7), (1,.7)))
#assert.eq(stepify(((0,0), (1,.7), (3,-.1)), step: center), ((0,0), (.5,0), (.5, .7), (1,.7), (2, .7), (2, -.1), (3,-.1)))



/// Transforms a generalized point
#let transform-point(x, y, transform) = {
  if type(x) in (int, float) {
    x = transform(x, 1).at(0)
  }
  if type(y) in (int, float) {
    y = transform(1, y).at(1)
  }
  return (x, y)
}
#let convert-bezier-curve(points, transform) = {
  let v = points.at(0)
  let p = transform-point(..v, transform)
  let result = (p,)
  
  for (x, y) in points.slice(1) {
    if type(x) in (int, float) {
      x = transform(x + v.at(0), 1).at(0) - p.at(0)
    }
    if type(y) in (int, float) {
      y = transform(1, y + v.at(1)).at(1) - p.at(1)
    }
    result.push((x, y))
  }
  return result
}

// point and size pt -> makes sense
// point and size data coords -> makes sense
// point data coords and size pt -> makes sense
// point data pt and size data coords -> makes no sense


#let convert-rect(
  x, 
  y, 
  width, 
  height, 
  transform,
  align: top + left
) = {

  // at the end we only want (relative) lengths

  let (x1, y1)  = transform-point(x, y, transform)
  if type(width) in (int, float) {
    assert(type(x) in (int, float), message: "Setting the width in terms of data coordinates is only allowed if the origin x coordinate is given in data coordinates")
    width = transform(x + width, 1).at(0) - transform(x, 1).at(0)
  }

  if type(height) in (int, float) {
    assert(type(y) in (int, float), message: "Setting the height in terms of data coordinates is only allowed if the origin y coordinate is given in data coordinates")
    height = transform(1, y + height).at(1) - transform(1, y).at(1) 
  }

  if align.x == right { x1 -= width }
  else if align.x == center { x1 -= width / 2 }
  
  if align.y == bottom { y1 -= height }
  else if align.y == horizon { y1 -= height / 2 }


  return (x1, width, y1, height)
}

#let is-data-coordinates(coord) = type(coord) in (int, float)
#let all-data-coordinates(coords) = {
  return coords.map(is-data-coordinates).fold(true, (a, b) => a and b)
}


// Convert a vertex for `path`. A vertex may either be a single vertex
// or a pair/triple of vertices describing a point with handles on a
// bezier curve. 
#let convert-vertex(v, transform: it => it) = {
  if type(v.at(0)) == array {
    return v.map(p => transform-point(..p, transform))
  } else {
    transform-point(..v, transform)
  }
}

