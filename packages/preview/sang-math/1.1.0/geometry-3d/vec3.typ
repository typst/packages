// ═══════════════════════════════════════════════════════════════
// GEOMETRY-3D / VEC3.TYP — Đại số Vector & Hình học Giải tích 3D
// ═══════════════════════════════════════════════════════════════

/// Tạo vector 3D từ 3 tọa độ x, y, z.
#let vec3(x, y, z) = (float(x), float(y), float(z))

/// Các vector đơn vị chuẩn và gốc tọa độ
#let origin3d = (0.0, 0.0, 0.0)
#let vec3-i = (1.0, 0.0, 0.0)
#let vec3-j = (0.0, 1.0, 0.0)
#let vec3-k = (0.0, 0.0, 1.0)

/// Cộng 2 vector 3D: u + v
#let vec3-add(u, v) = (
  u.at(0) + v.at(0),
  u.at(1) + v.at(1),
  u.at(2) + v.at(2),
)

/// Trừ 2 vector 3D: u - v
#let vec3-sub(u, v) = (
  u.at(0) - v.at(0),
  u.at(1) - v.at(1),
  u.at(2) - v.at(2),
)

/// Nhân vector 3D với một số thực: s * v
#let vec3-scale(v, s) = (
  v.at(0) * s,
  v.at(1) * s,
  v.at(2) * s,
)

/// Đổi dấu vector 3D: -v
#let vec3-neg(v) = vec3-scale(v, -1.0)

/// Tích vô hướng (dot product) của 2 vector 3D: u . v
#let vec3-dot(u, v) = (
  u.at(0) * v.at(0) + u.at(1) * v.at(1) + u.at(2) * v.at(2)
)

/// Tích có hướng (cross product) của 2 vector 3D: u x v
#let vec3-cross(u, v) = (
  u.at(1) * v.at(2) - u.at(2) * v.at(1),
  u.at(2) * v.at(0) - u.at(0) * v.at(2),
  u.at(0) * v.at(1) - u.at(1) * v.at(0),
)

/// Độ dài (Euclidean norm) của vector 3D: ||v||
#let vec3-norm(v) = calc.sqrt(vec3-dot(v, v))

/// Chuẩn hóa vector về độ dài 1 (unit vector). Trả về (0,0,0) nếu norm = 0.
#let vec3-unit(v) = {
  let len = vec3-norm(v)
  if len < 1e-10 { (0.0, 0.0, 0.0) } else { vec3-scale(v, 1.0 / len) }
}

/// Khoảng cách giữa 2 điểm A và B trong không gian: d(A, B)
#let vec3-dist(A, B) = vec3-norm(vec3-sub(B, A))

/// Trung điểm của đoạn thẳng AB: (A + B) / 2
#let vec3-mid(A, B) = vec3-scale(vec3-add(A, B), 0.5)

/// Nội suy tuyến tính giữa A và B theo tham số t ∈ [0, 1]: (1-t)A + tB
#let vec3-lerp(A, B, t) = vec3-add(A, vec3-scale(vec3-sub(B, A), t))

/// Trọng tâm hoặc tâm tỉ cự của một tập hợp điểm
#let vec3-barycenter(pts, weights: none) = {
  let n = pts.len()
  if n == 0 { return origin3d }
  if weights == none {
    let sum = pts.fold(origin3d, (acc, p) => vec3-add(acc, p))
    vec3-scale(sum, 1.0 / n)
  } else {
    let total-w = weights.fold(0.0, (acc, w) => acc + w)
    if calc.abs(total-w) < 1e-10 { return origin3d }
    let sum = origin3d
    for i in range(n) {
      sum = vec3-add(sum, vec3-scale(pts.at(i), weights.at(i)))
    }
    vec3-scale(sum, 1.0 / total-w)
  }
}

/// Góc giữa 2 vector u và v (tính bằng radian)
#let vec3-angle(u, v) = {
  let nu = vec3-norm(u)
  let nv = vec3-norm(v)
  if nu < 1e-10 or nv < 1e-10 { return 0.0 }
  let cos-val = calc.max(-1.0, calc.min(1.0, vec3-dot(u, v) / (nu * nv)))
  calc.acos(cos-val)
}

/// Hình chiếu của vector u lên vector on-v
#let vec3-proj(u, on-v) = {
  let d = vec3-dot(on-v, on-v)
  if d < 1e-10 { return origin3d }
  vec3-scale(on-v, vec3-dot(u, on-v) / d)
}

/// Hình chiếu của điểm p lên mặt phẳng (plane-pt, plane-normal)
#let vec3-plane-proj(p, plane-pt, plane-normal) = {
  let n = vec3-unit(plane-normal)
  let diff = vec3-sub(p, plane-pt)
  let dist-along-n = vec3-dot(diff, n)
  vec3-sub(p, vec3-scale(n, dist-along-n))
}

// ── Các phép quay trong không gian ──────────────────────────────

/// Xoay điểm/vector quanh trục X một góc angle (radian hoặc degree)
#let vec3-rot-x(v, angle) = {
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  (v.at(0), v.at(1) * c - v.at(2) * s, v.at(1) * s + v.at(2) * c)
}

/// Xoay điểm/vector quanh trục Y một góc angle
#let vec3-rot-y(v, angle) = {
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  (v.at(0) * c + v.at(2) * s, v.at(1), -v.at(0) * s + v.at(2) * c)
}

/// Xoay điểm/vector quanh trục Z một góc angle
#let vec3-rot-z(v, angle) = {
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  (v.at(0) * c - v.at(1) * s, v.at(0) * s + v.at(1) * c, v.at(2))
}

/// Xoay điểm/vector quanh một trục bất kỳ theo công thức Rodrigues
/// v_rot = v * cos(θ) + (k x v) * sin(θ) + k * (k . v) * (1 - cos(θ))
#let vec3-rot-axis(v, axis, angle) = {
  let k = vec3-unit(axis)
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  let term1 = vec3-scale(v, c)
  let term2 = vec3-scale(vec3-cross(k, v), s)
  let term3 = vec3-scale(k, vec3-dot(k, v) * (1.0 - c))
  vec3-add(vec3-add(term1, term2), term3)
}

/// So sánh 2 vector có bằng nhau trong ngưỡng epsilon không
#let vec3-equal(u, v, eps: 1e-6) = {
  vec3-dist(u, v) < eps
}
