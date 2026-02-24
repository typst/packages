
#let det(p1, p2, p3) = {
  let (p1x, p1y) = p1
  let (p2x, p2y) = p2
  let (p3x, p3y) = p3
  let v1x = p2x - p1x
  let v1y = p2y - p1y
  let v2x = p3x - p1x
  let v2y = p3y - p1y
  v1x * v2y - v2x * v1y
}

#let is-inside(point, triangle) = {
  let p = point
  let (p1, p2, p3) = triangle
  det(p, p1, p2) > 0 and det(p, p2, p3) > 0 and det(p, p3, p1) > 0
}

// No input checks (degenerate or aligned vertices)
#let is-in-circle(p, get-vertex, triangle) = {
  let (f1, f2, f3) = triangle
  let p1 = get-vertex(f1)
  let p2 = get-vertex(f2)
  let p3 = get-vertex(f3)
  // if 3 of them are inf, true
  // if 1 of them, check on which size of th triangle the point is
  // ie if p, p2, p3 is cw or ccw
  let (ax, ay) = p1
  let (bx, by) = p2
  let (cx, cy) = p3
  let (dx, dy) = p
  let ax_ = ax - dx
  let ay_ = ay - dy
  let bx_ = bx - dx
  let by_ = by - dy
  let cx_ = cx - dx
  let cy_ = cy - dy

  (
    (ax_ * ax_ + ay_ * ay_) * (bx_ * cy_ - cx_ * by_) -
    (bx_ * bx_ + by_ * by_) * (ax_ * cy_ - cx_ * ay_) +
    (cx_ * cx_ + cy_ * cy_) * (ax_ * by_ - bx_ * ay_)
  ) > 0
}

#let get-circumcenter(get-vertex, face) = {
  let (f1, f2, f3) = face
  let (p1x, p1y) = get-vertex(f1)
  let (p2x, p2y) = get-vertex(f2)
  let (p3x, p3y) = get-vertex(f3)
  let d = 2 * (p1x * (p2y - p3y) + p2x * (p3y - p1y) + p3x * (p1y - p2y))
  let ux = ((p1x * p1x + p1y * p1y) * (p2y - p3y) + (p2x * p2x + p2y * p2y) * (p3y - p1y) + (p3x * p3x + p3y * p3y) * (p1y - p2y)) / d
  let uy = ((p1x * p1x + p1y * p1y) * (p3x - p2x) + (p2x * p2x + p2y * p2y) * (p1x - p3x) + (p3x * p3x + p3y * p3y) * (p2x - p1x)) / d
  (ux, uy)
}
