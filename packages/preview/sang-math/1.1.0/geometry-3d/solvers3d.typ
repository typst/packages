// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / SOLVERS3D.TYP — Bộ Giải Thuật Toán Hình Học 3D
// Giao tuyến: Mặt phẳng - Cầu, Cầu - Cầu, Đường thẳng - Cầu, Mặt phẳng - Mặt phẳng
// Cắt gọt Chỏm Cầu (cut-sphere) như Luadraw
// ═══════════════════════════════════════════════════════════════

#import "vec3.typ": *
#import "camera.typ": *
#import "objects3d.typ": *

// ─────────────────────────────────────────────────────────────
// 1. TƯƠNG THÍCH NGƯỢC (BACKWARD COMPATIBILITY)
// ─────────────────────────────────────────────────────────────

#let make-plane(point, normal) = plane(point, normal)
#let point-plane-dist(p, pl) = plane-dist(pl, p)
#let line-plane-intersection(line-pt, line-dir, pl) = {
  inter-line-plane(line3d(line-pt, line-dir), pl)
}
#let orthonormal-basis(normal) = {
  let basis = plane-basis(plane((0, 0, 0), normal))
  (basis.u, basis.v)
}
#let sample-circle3d(center, radius, normal, n-samples: 64) = {
  let c = circle3d(center, radius, normal)
  circle3d-sample(c, n: n-samples)
}
#let sphere-plane-intersection(sphere-center, sphere-radius, pl) = {
  let s = sphere(sphere-center, sphere-radius)
  inter-plane-sphere(pl, s)
}

// ─────────────────────────────────────────────────────────────
// 2. GIAO TUYẾN MẶT PHẲNG VÀ MẶT CẦU (PLANE - SPHERE)
// ─────────────────────────────────────────────────────────────

/// Tính giao tuyến giữa Mặt phẳng P và Mặt cầu S
/// Trả về:
/// - (type: "none") nếu mặt phẳng không cắt mặt cầu (d > R)
/// - (type: "point", point: P) nếu mặt phẳng tiếp xúc mặt cầu (d == R)
/// - circle3d(...) nếu mặt phẳng cắt mặt cầu tạo thành đường tròn giao tuyến (d < R)
#let inter-plane-sphere(P, S) = {
  let d = plane-dist(P, S.center)
  let abs-d = calc.abs(d)
  let R = S.radius

  if abs-d > R + 1e-7 {
    (type: "none")
  } else if calc.abs(abs-d - R) <= 1e-7 {
    let pt = vec3-sub(S.center, vec3-scale(P.normal, d))
    (type: "point", point: pt)
  } else {
    let r = calc.sqrt(calc.max(0.0, R * R - d * d))
    let c = vec3-sub(S.center, vec3-scale(P.normal, d))
    circle3d(c, r, P.normal)
  }
}

// ─────────────────────────────────────────────────────────────
// 3. GIAO TUYẾN 2 MẶT CẦU (SPHERE - SPHERE)
// ─────────────────────────────────────────────────────────────

/// Tính đường tròn giao tuyến giữa hai mặt cầu S1 và S2
/// Trả về:
/// - (type: "none") nếu 2 mặt cầu rời nhau hoặc lồng vào nhau không chạm
/// - (type: "point", point: P) nếu 2 mặt cầu tiếp xúc nhau
/// - circle3d(...) nếu 2 mặt cầu cắt nhau tạo thành đường tròn giao tuyến
#let inter-sphere-sphere(S1, S2) = {
  let d = vec3-dist(S1.center, S2.center)
  let r1 = S1.radius
  let r2 = S2.radius

  if d < 1e-7 or d > r1 + r2 + 1e-7 or d < calc.abs(r1 - r2) - 1e-7 {
    return (type: "none")
  }

  // Khoảng cách từ tâm S1 đến mặt phẳng chứa đường tròn giao tuyến:
  // x = (d^2 + r1^2 - r2^2) / (2 * d)
  let x = (d * d + r1 * r1 - r2 * r2) / (2.0 * d)
  let h2 = r1 * r1 - x * x
  let n = vec3-unit(vec3-sub(S2.center, S1.center))
  let c = vec3-add(S1.center, vec3-scale(n, x))

  if h2 <= 1e-7 {
    (type: "point", point: c)
  } else {
    let r = calc.sqrt(calc.max(0.0, h2))
    circle3d(c, r, n)
  }
}

// ─────────────────────────────────────────────────────────────
// 4. GIAO ĐIỂM ĐƯỜNG THẲNG VÀ MẶT CẦU (LINE - SPHERE)
// ─────────────────────────────────────────────────────────────

/// Tìm giao điểm của Đường thẳng L và Mặt cầu S
/// Trả về mảng các điểm:
/// - () nếu không cắt
/// - (P,) nếu tiếp xúc
/// - (P1, P2) nếu cắt xuyên qua 2 điểm
#let inter-line-sphere(L, S) = {
  let m = vec3-sub(L.origin, S.center)
  let b = vec3-dot(m, L.dir)
  let c = vec3-dot(m, m) - S.radius * S.radius
  let delta = b * b - c

  if delta < -1e-7 {
    ()
  } else if calc.abs(delta) <= 1e-7 {
    let t = -b
    (line3d-point(L, t),)
  } else {
    let sqrt-d = calc.sqrt(delta)
    let t1 = -b - sqrt-d
    let t2 = -b + sqrt-d
    (line3d-point(L, t1), line3d-point(L, t2))
  }
}

// ─────────────────────────────────────────────────────────────
// 5. GIAO ĐIỂM ĐƯỜNG THẲNG VÀ MẶT PHẲNG (LINE - PLANE)
// ─────────────────────────────────────────────────────────────

/// Tìm giao điểm giữa Đường thẳng L và Mặt phẳng P
/// Trả về điểm 3D (x, y, z) hoặc none nếu song song
#let inter-line-plane(L, P) = {
  let denom = vec3-dot(L.dir, P.normal)
  if calc.abs(denom) < 1e-8 {
    return none
  }
  let diff = vec3-sub(P.point, L.origin)
  let t = vec3-dot(diff, P.normal) / denom
  line3d-point(L, t)
}

// ─────────────────────────────────────────────────────────────
// 6. GIAO TUYẾN 2 MẶT PHẲNG (PLANE - PLANE)
// ─────────────────────────────────────────────────────────────

/// Tìm đường thẳng giao tuyến giữa hai Mặt phẳng P1 và P2
/// Trả về line3d(...) hoặc none nếu 2 mặt phẳng song song hoặc trùng
#let inter-plane-plane(P1, P2) = {
  let dir = vec3-cross(P1.normal, P2.normal)
  let len = vec3-norm(dir)
  if len < 1e-7 {
    return none // Hai mặt phẳng song song
  }
  let u-dir = vec3-scale(dir, 1.0 / len)

  // Tìm một điểm nằm trên cả 2 mặt phẳng:
  // Giải hệ: n1.P = d1, n2.P = d2, u_dir.P = 0
  let d1 = vec3-dot(P1.normal, P1.point)
  let d2 = vec3-dot(P2.normal, P2.point)
  let n1 = P1.normal
  let n2 = P2.normal

  // Điểm P0 = (d1 * (n2 x u) + d2 * (u x n1)) / (||n1 x n2||^2)
  let p0 = vec3-scale(
    vec3-add(
      vec3-scale(vec3-cross(n2, u-dir), d1),
      vec3-scale(vec3-cross(u-dir, n1), d2)
    ),
    1.0 / (len * len)
  )

  line3d(p0, u-dir)
}

// ─────────────────────────────────────────────────────────────
// 7. ĐƯỜNG CHÂN TRỜI MẶT CẦU THEO CAMERA (SPHERE HORIZON)
// ─────────────────────────────────────────────────────────────

/// Tính đường tròn chân trời (apparent horizon silhouette circle) của mặt cầu dưới góc nhìn camera
#let sphere-horizon(S, cam) = {
  // Với camera trực giao (orthographic), đường chân trời là vòng tròn lớn có pháp tuyến = view-dir
  circle3d(S.center, S.radius, cam.view-dir)
}

// ─────────────────────────────────────────────────────────────
// 8. ĐỐI TƯỢNG CẮT CHỎM CẦU THUẬT TOÁN (CUT-SPHERE OBJECT)
// ─────────────────────────────────────────────────────────────

/// Tạo đối tượng Cắt Chỏm Cầu (tương đương g:Dcut_sphere của luadraw)
/// - S: Mặt cầu (tạo từ sphere(center, radius))
/// - P: Mặt phẳng cắt (tạo từ plane(point, normal))
/// - keep: "below" (lấy phần chỏm bên dưới / chùm đèn) hoặc "above" (lấy phần chỏm bên trên)
#let cut-sphere(S, P, keep: "below") = {
  let rim = inter-plane-sphere(P, S)
  assert(rim.type == "circle3d", message: "Cut plane must intersect the sphere to form a circle")

  let d = vec3-dot(P.normal, vec3-sub(P.point, S.center))
  let r-rim = rim.radius
  let c-rim = rim.center
  let n-rim = rim.normal

  // Định nghĩa hàm lấy điểm bất kỳ trên vành miệng cắt theo góc
  let rim-point = (angle) => circle3d-point(rim, angle)

  // Định nghĩa hàm lấy n điểm đều nhau trên vành miệng cắt (đa giác đều n cạnh)
  let rim-points = (n, phase: 0deg) => circle3d-n-points(rim, n, phase: phase)

  (
    type: "cut-sphere",
    sphere: S,
    plane: P,
    rim: rim,
    keep: keep,
    center: S.center,
    radius: S.radius,
    rim-center: c-rim,
    rim-radius: r-rim,
    rim-normal: n-rim,
    dist: d,
    rim-point: rim-point,
    rim-points: rim-points,
  )
}

/// Hàm truy vấn điểm trên vành miệng cắt chỏm cầu theo góc (tiện lợi, không cần ngoặc kép)
#let cut-rim-point(cut, angle) = circle3d-point(cut.rim, angle)

/// Hàm truy vấn n điểm đều nhau trên vành miệng cắt chỏm cầu
#let cut-rim-points(cut, n, phase: 0deg) = circle3d-n-points(cut.rim, n, phase: phase)
