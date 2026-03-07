//! typst-voronay
//!
//! https://github.com/Lieunoir/typst-voronay

#import "utils.typ"

/// R2 sequence from https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
/// Generates a point within $[0, 1]^2$
///
/// Parameters :
/// - `i` : Index of the element to generate
///
/// Returns : pseudorandom 2D point as array
#let r2-sequence(i) = {
  let g = 1.32471795724474602596
  let a1 = 1.0 / g
  let a2 = 1.0 / (g*g)
  let x = calc.fract(0.5+a1*i)
  let y = calc.fract(0.5+a2*i)
  (x, y)
}

#let halton(i, base) = {
  let x = 1.0 / base;
  let v = 0.0;
  while (i > 0) {
    v += x * calc.rem(i, base);
    i = calc.div-euclid(i,  base);
    x /= base;
  }
  v
}

/// Halton sequence
/// Generates a point within $[0, 1]^2$
///
/// Parameters :
/// - `i` : Index of the element to generate
///
/// Returns : pseudorandom 2D point as array
#let halton-2-3(i) = (halton(i, 2), halton(i, 3))

/// Sorts points along a hilbert curve.
/// Sorting points greatly improves performance of Delaunay.
///
/// Parameters :
/// - `points` : array of points (= arrays of len 2) to sort
///
/// Returns : sorted points
#let hilbert-point-sort(points) = {
  // Compute bounding box
  let (min_x, min_y, max_x, max_y) = points.fold(
    (float.inf, float.inf, -float.inf, -float.inf),
    (acc, val) => {
      let (min_x, min_y, max_x, max_y) = acc
      let (x, y) = val
      (
        calc.min(min_x, x),
        calc.min(min_y, y),
        calc.max(min_x, x),
        calc.max(min_y, y),
      )
    }
  )
  let width = max_x - min_x
  let height = max_y - min_y
  let n = calc.ceil(0.5 * calc.log(points.len(), base: 2.))
  points.map(((xi, yi)) => {
    let x = calc.floor((xi - min_x) / width * n)
    let y = calc.floor((yi - min_y) / height * n)
    let n = calc.pow(2, n)
    let s = n.bit-rshift(1)
    // Compute the index on the hilbert curve
    let d = 0
    while s > 0 {
      let rx = int(x.bit-and(s) > 0)
      let ry = int(y.bit-and(s) > 0)
      d += s * s * ((3 * rx).bit-xor(ry))
      s = s.bit-rshift(1)
      if ry == 0 {
        if rx == 1 {
          x = n - 1 - x;
          y = n - 1 - y;
        }
        //Swap x and y
        let t  = x;
        x = y;
        y = t;
      }
    }
    (xi, yi, d)
    // Sort the points
  }).sorted(key: ((_, _, d)) => d).map(((x, y, _)) => (x, y))
}

/// Computes the Delaunay triangulation of some points
///
/// Parameters :
/// - `points` : vertices of the triangulation, as an array of arrays of len 2
///
/// Returns : faces of the triangulation, as an array of arrays len 3 of indices
#let delaunay-triangulate(points) = {
  if points.len() == 0 {
    return ()
  }
  // This should be replaced by something more robust
  let vertices = (
    (-10e7, -10e7),
    (10e7, -10e7),
    (-10e7, 10e7),
  )
  let faces = (
    (0, 1, 2),
  ) + range(2 * points.len()).map(it => (-1, -1, -1))
  let edges = (
    (-1, -1, -1),
  ) + range(2 * points.len()).map(it => (-1, -1, -1))
  let edges_i = (
    (-1, -1, -1),
  ) + range(2 * points.len()).map(it => (-1, -1, -1))

  let explored = faces.map(it => 0)
  let n_v = vertices.len()
  let n = vertices.len()
  let n_f = 1
  let get-vertex(i) = {
    if i >= n_v {
      points.at(i - n_v)
    } else {
      vertices.at(i)
    }
  }

  for p in points {

    // Find first "bad" triangle
    //let i = n_f - 1 - faces.slice(0, n_f).rev().position(f => is_in_circle(p, get_vertex, f))
    let i = n_f - 1
    while not utils.is-in-circle(p, get-vertex, faces.at(i)) {
      i -= 1
    }
    explored.at(i) = n
    let to_explore_2 = (i,)
    let bad_f = (i,)

    // Find all other bad triangles (using connectivity)
    while to_explore_2.len() > 0 {
      let cur_f = to_explore_2.pop()
      let (f1, f2, f3) = edges.at(cur_f)
      if f1 != -1 and utils.is-in-circle(p, get-vertex, faces.at(f1)) and explored.at(f1) != n {
        bad_f.push(f1)
        to_explore_2.push(f1)
        explored.at(f1) = n
      }
      if f2 != -1 and utils.is-in-circle(p, get-vertex, faces.at(f2)) and explored.at(f2) != n {
        bad_f.push(f2)
        to_explore_2.push(f2)
        explored.at(f2) = n
      }
      if f3 != -1 and utils.is-in-circle(p, get-vertex, faces.at(f3)) and explored.at(f3) != n {
        bad_f.push(f3)
        to_explore_2.push(f3)
        explored.at(f3) = n
      }
    }
    let bad_f = bad_f.sorted()

    // Find which edge of the bad triangles stay
    let polygon = ()
    for f_i in bad_f {
      let (v1, v2, v3) = faces.at(f_i)
      let (f1, f2, f3) = edges.at(f_i)
      let (f1_i, f2_i, f3_i) = edges_i.at(f_i)
      if not bad_f.contains(f1) {
        polygon.push((v1, v2, f1, f1_i))
      }
      if not bad_f.contains(f2) {
        polygon.push((v2, v3, f2, f2_i))
      }
      if not bad_f.contains(f3) {
        polygon.push((v3, v1, f3, f3_i))
      }
    }

    // Sort the edges to form the loop in order
    let n_new = polygon.len()
    let i = 0
    while i < n_new {
      let (_, e2, _, _) = polygon.at(i)
      let j = i + 2
      while j < n_new {
        let p1 = polygon.at(j)
        let (e1, _, _, _) = p1
        if e1 == e2 {
          let p2 = polygon.at(i + 1)
          polygon.at(i + 1) = p1
          polygon.at(j) = p2
          break;
        }
        j += 1
      }
      i += 1
    }

    bad_f = bad_f + (n_f, n_f + 1, bad_f.first())
    let prev_f = n_f + 1

    // Triangulate the loop with the new point
    for (i, ((e1, e2, opp_f, opp_f_i), (f, next_f))) in polygon.zip(bad_f.windows(2)).enumerate() {
      faces.at(f) = (n, e1, e2)
      edges.at(f) = (prev_f, opp_f, next_f)
      edges_i.at(f) = (2, opp_f_i, 0)
      if opp_f >= 0 {
        edges.at(opp_f).at(opp_f_i) = f
        edges_i.at(opp_f).at(opp_f_i) = 1
      }
      prev_f = f
    }

    n_f += 2
    n += 1
  }

  // Remove the first points added for the external face
  let good_f = faces.filter(((f1, f2, f3)) =>
    f1 >= n_v and f2 >= n_v and f3 >= n_v
  ).map(((f1, f2, f3)) => (f1 - n_v, f2 - n_v, f3 - n_v))
  good_f
}

/// Computes the nodes of the dual of a triangulation
///
/// Parameters :
/// - `vertices` : vertices of the triangulation
/// - `faces` : faces of the triangulation
///
/// Returns : array of points (= arrays of len 2)
#let get-circumcenters(vertices, faces) = {
  faces.map(f => utils.get-circumcenter(i => vertices.at(i), f))
}

/// Computes the edges of the dual of a triangulation
///
/// Parameters :
/// - `faces` : faces of the triangulation
///
/// Returns : array of edges (= arrays of len 2)
#let get-dual-edges(faces) = {
  let d_edges = ()
  let edges = ()
  for (i, (f1, f2, f3)) in faces.enumerate() {
    edges.push((calc.min(f1, f2), calc.max(f1, f2), i))
    edges.push((calc.min(f2, f3), calc.max(f2, f3), i))
    edges.push((calc.min(f3, f1), calc.max(f3, f1), i))
  }
  let edges = edges.sorted(key: ((e_1, e_2, _)) => (e_1, e_2))
  let i = 0
  while i+1 < edges.len() {
    let (e11, e12, f1) = edges.at(i)
    let (e21, e22, f2) = edges.at(i+1)
    if e11 == e21 and e12 == e22 {
      d_edges.push((f1, f2))
      i += 2
    } else {
      i += 1
    }
  }
  d_edges
}
