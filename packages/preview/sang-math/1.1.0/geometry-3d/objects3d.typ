// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / OBJECTS3D.TYP — Đối tượng Hình học 3D Thuần Túy
// Cung cấp các cấu trúc Sphere, Plane, Circle3D, Line3D composable
// ═══════════════════════════════════════════════════════════════

#import "vec3.typ": *

// ─────────────────────────────────────────────────────────────
// 1. MẶT CẦU (SPHERE 3D)
// ─────────────────────────────────────────────────────────────

/// Khởi tạo đối tượng Mặt Cầu
/// - center: Tâm mặt cầu (x, y, z)
/// - radius: Bán kính mặt cầu (float > 0)
#let sphere(center, radius) = {
  assert(type(center) == array and center.len() == 3, message: "Center must be (x, y, z)")
  assert(radius > 0, message: "Radius must be positive")
  (
    type: "sphere",
    center: (float(center.at(0)), float(center.at(1)), float(center.at(2))),
    radius: float(radius),
  )
}

/// Lấy điểm trên mặt cầu theo tọa độ cầu:
/// - theta: Kinh độ (azimuth góc quay quanh trục Z)
/// - phi: Vĩ độ (elevation góc so với mặt phẳng xOy)
#let sphere-point(S, theta, phi) = {
  let c = S.center
  let r = S.radius
  let cos-phi = calc.cos(phi)
  let sin-phi = calc.sin(phi)
  let cos-th = calc.cos(theta)
  let sin-th = calc.sin(theta)
  (
    c.at(0) + r * cos-phi * cos-th,
    c.at(1) + r * cos-phi * sin-th,
    c.at(2) + r * sin-phi,
  )
}

/// Kiểm tra điểm có thuộc mặt cầu hay không (với sai số epsilon)
#let sphere-contains(S, pt, eps: 1e-4) = {
  let d = vec3-dist(S.center, pt)
  calc.abs(d - S.radius) < eps
}

/// Lập mặt phẳng tiếp diện với mặt cầu tại điểm P thuộc mặt cầu
#let sphere-tangent-plane(S, pt) = {
  let n = vec3-unit(vec3-sub(pt, S.center))
  (
    type: "plane",
    point: pt,
    normal: n,
    d: vec3-dot(n, pt),
  )
}

/// Tính các điểm trên cung tròn lớn (Geodesic Arc / Great Circle) nối 2 điểm A và B trên mặt cầu
/// Sử dụng nội suy SLERP (Spherical Linear Interpolation)
#let sphere-geodesic(S, A, B, n: 32) = {
  let O = S.center
  let vA = vec3-unit(vec3-sub(A, O))
  let vB = vec3-unit(vec3-sub(B, O))
  let dot-val = calc.min(1.0, calc.max(-1.0, vec3-dot(vA, vB)))
  let omega = calc.acos(dot-val)

  if omega < 1e-5 * 1rad {
    return (A, B)
  }

  let sin-omega = calc.sin(omega)
  let pts = ()
  for i in range(n + 1) {
    let t = i / n
    let s1 = calc.sin((1.0 - t) * omega) / sin-omega
    let s2 = calc.sin(t * omega) / sin-omega
    let v = vec3-add(vec3-scale(vA, s1), vec3-scale(vB, s2))
    pts.push(vec3-add(O, vec3-scale(v, S.radius)))
  }
  pts
}

// ─────────────────────────────────────────────────────────────
// 2. MẶT PHẲNG (PLANE 3D)
// ─────────────────────────────────────────────────────────────

/// Khởi tạo Mặt phẳng qua 1 điểm và vector pháp tuyến
#let plane(point, normal) = {
  let n = vec3-unit(normal)
  (
    type: "plane",
    point: (float(point.at(0)), float(point.at(1)), float(point.at(2))),
    normal: n,
    d: vec3-dot(n, point),
  )
}

/// Khởi tạo Mặt phẳng đi qua 3 điểm không thẳng hàng A, B, C
#let plane-3p(A, B, C) = {
  let AB = vec3-sub(B, A)
  let AC = vec3-sub(C, A)
  let n = vec3-unit(vec3-cross(AB, AC))
  plane(A, n)
}

/// Khởi tạo Mặt phẳng từ phương trình tổng quát: a*x + b*y + c*z + d = 0
#let plane-eq(a, b, c, d) = {
  let n = vec3-unit((a, b, c))
  let len = vec3-norm((a, b, c))
  let d-norm = d / len
  // Điểm trên mặt phẳng: P0 = - d_norm * n
  let P0 = vec3-scale(n, -d-norm)
  (
    type: "plane",
    point: P0,
    normal: n,
    d: -d-norm,
  )
}

/// Khoảng cách đại số (có dấu) từ điểm P đến mặt phẳng
#let plane-dist(P, pt) = {
  vec3-dot(P.normal, vec3-sub(pt, P.point))
}

/// Hình chiếu vuông góc của điểm P lên mặt phẳng
#let plane-project(P, pt) = {
  let dist = plane-dist(P, pt)
  vec3-sub(pt, vec3-scale(P.normal, dist))
}

/// Kiểm tra điểm có thuộc mặt phẳng hay không
#let plane-contains(P, pt, eps: 1e-4) = {
  calc.abs(plane-dist(P, pt)) < eps
}

/// Sinh cơ sở trực chuẩn (u, v) nằm trong mặt phẳng
#let plane-basis(P) = {
  let n = P.normal
  let ref = if calc.abs(n.at(2)) < 0.9 { (0.0, 0.0, 1.0) } else { (1.0, 0.0, 0.0) }
  let u = vec3-unit(vec3-cross(ref, n))
  let v = vec3-unit(vec3-cross(n, u))
  (u: u, v: v, n: n)
}

/// Lấy điểm trên mặt phẳng từ tọa độ 2D cục bộ (u_coord, v_coord)
#let plane-point(P, u-coord, v-coord) = {
  let basis = plane-basis(P)
  vec3-add(
    P.point,
    vec3-add(vec3-scale(basis.u, u-coord), vec3-scale(basis.v, v-coord))
  )
}

// ─────────────────────────────────────────────────────────────
// 3. ĐƯỜNG TRÒN 3D (CIRCLE 3D)
// ─────────────────────────────────────────────────────────────

/// Khởi tạo Đường tròn trong không gian 3D
/// - center: Tâm đường tròn
/// - radius: Bán kính đường tròn
/// - normal: Vector pháp tuyến của mặt phẳng chứa đường tròn
#let circle3d(center, radius, normal) = {
  let n = vec3-unit(normal)
  let ref = if calc.abs(n.at(2)) < 0.9 { (0.0, 0.0, 1.0) } else { (1.0, 0.0, 0.0) }
  let u = vec3-unit(vec3-cross(ref, n))
  let v = vec3-unit(vec3-cross(n, u))
  (
    type: "circle3d",
    center: (float(center.at(0)), float(center.at(1)), float(center.at(2))),
    radius: float(radius),
    normal: n,
    u: u,
    v: v,
  )
}

/// Lấy điểm trên đường tròn 3D tại góc angle (radians hoặc angle)
#let circle3d-point(C, angle) = {
  let cos-a = calc.cos(angle)
  let sin-a = calc.sin(angle)
  vec3-add(
    C.center,
    vec3-add(
      vec3-scale(C.u, C.radius * cos-a),
      vec3-scale(C.v, C.radius * sin-a)
    )
  )
}

/// Lấy danh sách điểm mẫu xấp xỉ đường tròn 3D
#let circle3d-sample(C, n: 64) = {
  let pts = ()
  for i in range(n) {
    let ang = i * 360deg / n
    pts.push(circle3d-point(C, ang))
  }
  pts
}

/// Lấy n đỉnh của đa giác đều n cạnh nội tiếp đường tròn 3D
/// Hữu ích cho bài toán chùm đèn n đỉnh, chóp n-giác đều
#let circle3d-n-points(C, n, phase: 0deg) = {
  let pts = ()
  for i in range(n) {
    let ang = phase + i * 360deg / n
    pts.push(circle3d-point(C, ang))
  }
  pts
}

// ─────────────────────────────────────────────────────────────
// 4. ĐƯỜNG THẲNG 3D (LINE 3D)
// ─────────────────────────────────────────────────────────────

/// Khởi tạo Đường thẳng trong không gian 3D qua điểm gốc và vector chỉ phương
#let line3d(origin, dir) = {
  let d = vec3-unit(dir)
  (
    type: "line3d",
    origin: (float(origin.at(0)), float(origin.at(1)), float(origin.at(2))),
    dir: d,
  )
}

/// Khởi tạo Đường thẳng qua 2 điểm phân biệt A và B
#let line3d-2p(A, B) = {
  line3d(A, vec3-sub(B, A))
}

/// Lấy điểm trên đường thẳng tại tham số t: P(t) = origin + t * dir
#let line3d-point(L, t) = {
  vec3-add(L.origin, vec3-scale(L.dir, t))
}

/// Hình chiếu vuông góc của điểm P lên đường thẳng L
#let line3d-project(L, pt) = {
  let v = vec3-sub(pt, L.origin)
  let t = vec3-dot(v, L.dir)
  line3d-point(L, t)
}

/// Khoảng cách từ điểm P đến đường thẳng L
#let line3d-dist(L, pt) = {
  let proj = line3d-project(L, pt)
  vec3-dist(pt, proj)
}
