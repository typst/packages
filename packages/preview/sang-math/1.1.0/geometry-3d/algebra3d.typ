// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / ALGEBRA3D.TYP — Động Cơ Đại Số Hình Học Không Gian Linh Hoạt
// Flexible Geometric Algebra for 3D Space (Vector, Affine & Synthetic Geometry)
// Tác giả: Nguyễn Sáng <sangnhc87@gmail.com>
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "vec3.typ": *
#import "camera.typ": *
#import "objects3d.typ": *
#import "solvers3d.typ": *

// ─────────────────────────────────────────────────────────────
// 1. CÁC HÀM KHỞI TẠO ĐỐI TƯỢNG HÌNH HỌC (PRIMITIVES & CONSTRUCTORS)
// ─────────────────────────────────────────────────────────────

/// Khởi tạo điểm 3D (x, y, z) hoặc từ mảng (x, y, z) hoặc 2D (x, y).
#let pt(..args) = {
  let pos = args.pos()
  if pos.len() == 1 and type(pos.at(0)) == array {
    let arr = pos.at(0)
    if arr.len() >= 3 { (float(arr.at(0)), float(arr.at(1)), float(arr.at(2))) }
    else if arr.len() == 2 { (float(arr.at(0)), float(arr.at(1)), 0.0) }
    else { (0.0, 0.0, 0.0) }
  } else if pos.len() >= 3 {
    (float(pos.at(0)), float(pos.at(1)), float(pos.at(2)))
  } else if pos.len() == 2 {
    (float(pos.at(0)), float(pos.at(1)), 0.0)
  } else if pos.len() == 1 {
    (float(pos.at(0)), 0.0, 0.0)
  } else {
    (0.0, 0.0, 0.0)
  }
}
#let diem3d = pt

/// Khởi tạo vector 3D (vx, vy, vz) hoặc từ mảng.
#let vec(..args) = pt(..args)
#let vecto = vec

/// Vector đi từ điểm A đến điểm B: arrow(AB) = B - A
#let vec-ab(A, B) = {
  let pA = pt(A); let pB = pt(B)
  (pB.at(0) - pA.at(0), pB.at(1) - pA.at(1), pB.at(2) - pA.at(2))
}
#let vecto-ab = vec-ab

/// Khởi tạo đối tượng Đường thẳng trong không gian 3D.
/// Hỗ trợ:
/// - dt(A, B): Đường thẳng đi qua 2 điểm A và B
/// - dt(A, huong: u): Đường thẳng đi qua A với vector chỉ phương u
#let duong-thang(..args, huong: none, diem2: none) = {
  let pos = args.pos()
  let pA = if pos.len() >= 1 { pt(pos.at(0)) } else { pt(0, 0, 0) }
  let u = if pos.len() >= 2 {
    vec-ab(pA, pt(pos.at(1)))
  } else if diem2 != none {
    vec-ab(pA, pt(diem2))
  } else if huong != none {
    pt(huong)
  } else {
    (0.0, 0.0, 1.0)
  }
  let len = vec3-norm(u)
  assert(len > 1e-8, message: "Direction vector cannot be zero")
  let u-unit = vec3-scale(u, 1.0 / len)
  (type: "line3d", point: pA, origin: pA, dir: u-unit)
}
#let dt = duong-thang

/// Khởi tạo đối tượng Mặt phẳng trong không gian 3D.
/// Hỗ trợ:
/// - mp(A, B, C): Mặt phẳng qua 3 điểm không thẳng hàng
/// - mp(A, phap-tuyen: n): Mặt phẳng qua điểm A với vector pháp tuyến n
#let mat-phang(..args, B: none, C: none, phap-tuyen: none) = {
  let pos = args.pos()
  let pA = if pos.len() >= 1 { pt(pos.at(0)) } else { pt(0, 0, 0) }
  let n = if phap-tuyen != none {
    pt(phap-tuyen)
  } else if pos.len() >= 3 {
    let u = vec-ab(pA, pt(pos.at(1)))
    let v = vec-ab(pA, pt(pos.at(2)))
    vec3-cross(u, v)
  } else if B != none and C != none {
    let u = vec-ab(pA, pt(B))
    let v = vec-ab(pA, pt(C))
    vec3-cross(u, v)
  } else {
    (0.0, 0.0, 1.0)
  }
  let len = vec3-norm(n)
  assert(len > 1e-8, message: "Normal vector cannot be zero or 3 points are collinear")
  let n-unit = vec3-scale(n, 1.0 / len)
  (type: "plane", point: pA, normal: n-unit)
}
#let mp = mat-phang

/// Mặt phẳng tổng quát Ax + By + Cz + D = 0
#let mat-phang-tong-quat(A, B, C, D) = {
  let norm = (float(A), float(B), float(C))
  let len = vec3-norm(norm)
  assert(len > 1e-8, message: "A, B, C cannot all be zero")
  let n-unit = vec3-scale(norm, 1.0 / len)
  // Tìm 1 điểm p0: nếu |C| lớn nhất thì lấy z = -D/C
  let p0 = if calc.abs(C) >= calc.abs(A) and calc.abs(C) >= calc.abs(B) {
    (0.0, 0.0, -float(D) / float(C))
  } else if calc.abs(B) >= calc.abs(A) {
    (0.0, -float(D) / float(B), 0.0)
  } else {
    (-float(D) / float(A), 0.0, 0.0)
  }
  (type: "plane", point: p0, normal: n-unit)
}
#let mp-pt = mat-phang-tong-quat

/// Khởi tạo đối tượng Đoạn thẳng nối 2 điểm A, B
#let doan-thang(A, B) = {
  (type: "segment3d", A: pt(A), B: pt(B))
}

/// Khởi tạo đối tượng Mặt cầu:
/// - cau(O, R): Mặt cầu tâm O bán kính R
/// - cau(A, diem-doi: B): Mặt cầu nhận AB làm đường kính
#let mat-cau(O, R: none, diem-doi: none) = {
  let pO = pt(O)
  if diem-doi != none {
    let pB = pt(diem-doi)
    let center = vec3-scale(vec3-add(pO, pB), 0.5)
    let radius = vec3-dist(pO, pB) * 0.5
    (type: "sphere", center: center, radius: radius)
  } else {
    let r = if R != none { float(R) } else { 1.0 }
    (type: "sphere", center: pO, radius: r)
  }
}
#let cau = mat-cau

// ─────────────────────────────────────────────────────────────
// 2. CÁC PHÉP TOÁN ĐẠI SỐ VECTOR & ĐIỂM (VECTOR & AFFINE ALGEBRA)
// ─────────────────────────────────────────────────────────────

#let v-add(u, v) = vec3-add(pt(u), pt(v))
#let v-sub(u, v) = vec3-sub(pt(u), pt(v))
#let v-scale(u, k) = vec3-scale(pt(u), float(k))
#let v-dot(u, v) = vec3-dot(pt(u), pt(v))
#let v-cross(u, v) = vec3-cross(pt(u), pt(v))
#let v-norm(u) = vec3-norm(pt(u))
#let v-len = v-norm
#let v-unit(u) = vec3-unit(pt(u))

/// Tịnh tiến điểm A theo vector u: A' = A + u
#let pt-add(A, u) = vec3-add(pt(A), pt(u))

/// Trung điểm của đoạn thẳng nối A và B: M = (A + B)/2
#let trung-diem(A, B) = {
  let pA = pt(A); let pB = pt(B)
  ( (pA.at(0) + pB.at(0)) * 0.5, (pA.at(1) + pB.at(1)) * 0.5, (pA.at(2) + pB.at(2)) * 0.5 )
}

/// Điểm M chia đoạn AB theo tỉ số k: arrow(AM) = k * arrow(AB)
/// Ví dụ: k = 1/2 là trung điểm, k = 1/3 là điểm cách A một phần ba đoạn AB
#let chia-doan(A, B, k) = {
  let pA = pt(A); let pB = pt(B); let fk = float(k)
  (
    pA.at(0) + fk * (pB.at(0) - pA.at(0)),
    pA.at(1) + fk * (pB.at(1) - pA.at(1)),
    pA.at(2) + fk * (pB.at(2) - pA.at(2))
  )
}

/// Trọng tâm của danh sách n điểm (tam giác, tứ diện, đa giác...)
#let trong-tam(..pts) = {
  let arr = pts.pos()
  if arr.len() == 1 and type(arr.at(0)) == array and type(arr.at(0).at(0)) == array {
    arr = arr.at(0)
  }
  let n = arr.len()
  assert(n > 0, message: "Points list cannot be empty")
  let sx = 0.0; let sy = 0.0; let sz = 0.0
  for p in arr {
    let pp = pt(p)
    sx += pp.at(0); sy += pp.at(1); sz += pp.at(2)
  }
  (sx / n, sy / n, sz / n)
}

/// Trọng tâm tam giác ABC
#let trong-tam-tam-giac(A, B, C) = trong-tam(A, B, C)

/// Trọng tâm tứ diện ABCD
#let trong-tam-tu-dien(A, B, C, D) = trong-tam(A, B, C, D)

/// Tâm đường tròn ngoại tiếp tam giác ABC trong không gian 3D
#let tam-ngoai-tiep(A, B, C) = {
  let pA = pt(A); let pB = pt(B); let pC = pt(C)
  let vBC = vec-ab(pB, pC); let a2 = v-dot(vBC, vBC)
  let vCA = vec-ab(pC, pA); let b2 = v-dot(vCA, vCA)
  let vAB = vec-ab(pA, pB); let c2 = v-dot(vAB, vAB)

  let wA = a2 * (b2 + c2 - a2)
  let wB = b2 * (c2 + a2 - b2)
  let wC = c2 * (a2 + b2 - c2)
  let sum-w = wA + wB + wC
  assert(calc.abs(sum-w) > 1e-8, message: "Points A, B, C are collinear")

  (
    (wA * pA.at(0) + wB * pB.at(0) + wC * pC.at(0)) / sum-w,
    (wA * pA.at(1) + wB * pB.at(1) + wC * pC.at(1)) / sum-w,
    (wA * pA.at(2) + wB * pB.at(2) + wC * pC.at(2)) / sum-w
  )
}

/// Trực tâm tam giác ABC trong không gian 3D (Định lý đường thẳng Euler: H = 3G - 2O)
#let truc-tam(A, B, C) = {
  let G = trong-tam-tam-giac(A, B, C)
  let O = tam-ngoai-tiep(A, B, C)
  (
    3.0 * G.at(0) - 2.0 * O.at(0),
    3.0 * G.at(1) - 2.0 * O.at(1),
    3.0 * G.at(2) - 2.0 * O.at(2)
  )
}

/// Tâm đường tròn nội tiếp tam giác ABC trong không gian 3D
#let tam-noi-tiep(A, B, C) = {
  let pA = pt(A); let pB = pt(B); let pC = pt(C)
  let a = vec3-dist(pB, pC)
  let b = vec3-dist(pC, pA)
  let c = vec3-dist(pA, pB)
  let p = a + b + c
  assert(p > 1e-8, message: "Degenerate triangle")
  (
    (a * pA.at(0) + b * pB.at(0) + c * pC.at(0)) / p,
    (a * pA.at(1) + b * pB.at(1) + c * pC.at(1)) / p,
    (a * pA.at(2) + b * pB.at(2) + c * pC.at(2)) / p
  )
}

// ─────────────────────────────────────────────────────────────
// 3. HÌNH CHIẾU VUÔNG GÓC & ĐỐI XỨNG (PROJECTIONS & REFLECTIONS)
// ─────────────────────────────────────────────────────────────

/// Hình chiếu vuông góc của điểm P lên Đường thẳng L
#let chieu-len-duong(P, L) = {
  let pP = pt(P)
  let line-obj = if type(L) == dictionary and L.at("type", default: "") == "line3d" {
    L
  } else if type(L) == array and L.len() == 2 {
    duong-thang(L.at(0), diem2: L.at(1))
  } else {
    L
  }
  let v = vec-ab(line-obj.origin, pP)
  let t = vec3-dot(v, line-obj.dir)
  vec3-add(line-obj.origin, vec3-scale(line-obj.dir, t))
}

/// Hình chiếu vuông góc của điểm P lên Mặt phẳng P_plane
#let chieu-len-mat(P, P-plane) = {
  let pP = pt(P)
  let pl = if type(P-plane) == dictionary and P-plane.at("type", default: "") == "plane" {
    P-plane
  } else if type(P-plane) == array and P-plane.len() == 3 {
    mat-phang(P-plane.at(0), B: P-plane.at(1), C: P-plane.at(2))
  } else {
    P-plane
  }
  let v = vec-ab(pl.point, pP)
  let d = vec3-dot(v, pl.normal)
  vec3-sub(pP, vec3-scale(pl.normal, d))
}

/// Điểm đối xứng với P qua tâm I: P' = 2I - P
#let doi-xung-qua-diem(P, I) = {
  let pP = pt(P); let pI = pt(I)
  (2.0 * pI.at(0) - pP.at(0), 2.0 * pI.at(1) - pP.at(1), 2.0 * pI.at(2) - pP.at(2))
}

/// Điểm đối xứng với P qua Đường thẳng L: P' = 2H - P (H là hình chiếu của P lên L)
#let doi-xung-qua-duong(P, L) = {
  let H = chieu-len-duong(P, L)
  doi-xung-qua-diem(P, H)
}

/// Điểm đối xứng với P qua Mặt phẳng: P' = 2H - P (H là hình chiếu của P lên mặt phẳng)
#let doi-xung-qua-mat(P, P-plane) = {
  let H = chieu-len-mat(P, P-plane)
  doi-xung-qua-diem(P, H)
}

// ─────────────────────────────────────────────────────────────
// 4. KHOẢNG CÁCH & ĐOẠN VUÔNG GÓC CHUNG (DISTANCES & COMMON PERPENDICULAR)
// ─────────────────────────────────────────────────────────────

/// Khoảng cách giữa 2 điểm
#let khoang-cach-diem-diem(A, B) = vec3-dist(pt(A), pt(B))
#let khoang-cach = khoang-cach-diem-diem

/// Khoảng cách từ điểm P đến Đường thẳng L
#let khoang-cach-diem-duong(P, L) = {
  let H = chieu-len-duong(P, L)
  vec3-dist(pt(P), H)
}

/// Khoảng cách từ điểm P đến Mặt phẳng
#let khoang-cach-diem-mat(P, P-plane) = {
  let H = chieu-len-mat(P, P-plane)
  vec3-dist(pt(P), H)
}

/// Khoảng cách giữa hai đường thẳng L1 và L2 trong không gian
#let khoang-cach-hai-duong(L1, L2) = {
  let l1 = if type(L1) == array { duong-thang(L1.at(0), diem2: L1.at(1)) } else { L1 }
  let l2 = if type(L2) == array { duong-thang(L2.at(0), diem2: L2.at(1)) } else { L2 }

  let n = vec3-cross(l1.dir, l2.dir)
  let len-n = vec3-norm(n)
  if len-n < 1e-7 {
    // Hai đường thẳng song song: khoảng cách từ 1 điểm trên l1 đến l2
    khoang-cach-diem-duong(l1.origin, l2)
  } else {
    // Hai đường thẳng chéo nhau: |(A2 - A1) . n| / ||n||
    let v12 = vec-ab(l1.origin, l2.origin)
    calc.abs(vec3-dot(v12, n)) / len-n
  }
}

/// Tìm đoạn vuông góc chung giữa 2 đường thẳng chéo nhau L1 và L2
/// Trả về: (M1, M2) sao cho M1 thuộc L1, M2 thuộc L2 và đoạn M1M2 vuông góc với cả L1 và L2
#let doan-vuong-goc-chung(L1, L2) = {
  let l1 = if type(L1) == array { duong-thang(L1.at(0), diem2: L1.at(1)) } else { L1 }
  let l2 = if type(L2) == array { duong-thang(L2.at(0), diem2: L2.at(1)) } else { L2 }

  let u1 = l1.dir
  let u2 = l2.dir
  let b = vec3-dot(u1, u2)
  let denom = 1.0 - b * b

  assert(denom > 1e-7, message: "Lines are parallel, infinite common perpendiculars exist")

  let v0 = vec-ab(l2.origin, l1.origin)
  let d = vec3-dot(v0, u1)
  let e = vec3-dot(v0, u2)

  let s = (b * e - d) / denom
  let t = (e - b * d) / denom

  let M1 = vec3-add(l1.origin, vec3-scale(u1, s))
  let M2 = vec3-add(l2.origin, vec3-scale(u2, t))

  (M1: M1, M2: M2)
}

// ─────────────────────────────────────────────────────────────
// 5. GIAO ĐIỂM & GIAO TUYẾN (INTERSECTIONS)
// ─────────────────────────────────────────────────────────────

/// Giao điểm của Đường thẳng L và Mặt phẳng P_plane
#let giao-duong-mat(L, P-plane) = {
  let l = if type(L) == array { duong-thang(L.at(0), diem2: L.at(1)) } else { L }
  let pl = if type(P-plane) == array { mat-phang(P-plane.at(0), B: P-plane.at(1), C: P-plane.at(2)) } else { P-plane }
  inter-line-plane(l, pl)
}

/// Giao tuyến của hai Mặt phẳng P1 và P2
#let giao-hai-mat(P1, P2) = {
  let pl1 = if type(P1) == array { mat-phang(P1.at(0), B: P1.at(1), C: P1.at(2)) } else { P1 }
  let pl2 = if type(P2) == array { mat-phang(P2.at(0), B: P2.at(1), C: P2.at(2)) } else { P2 }
  inter-plane-plane(pl1, pl2)
}

/// Giao điểm của hai đường thẳng L1 và L2 (nếu đồng phẳng cắt nhau)
/// Trả về điểm giao M hoặc none nếu song song hoặc chéo nhau
#let giao-hai-duong(L1, L2) = {
  let l1 = if type(L1) == array { duong-thang(L1.at(0), diem2: L1.at(1)) } else { L1 }
  let l2 = if type(L2) == array { duong-thang(L2.at(0), diem2: L2.at(1)) } else { L2 }

  let d = khoang-cach-hai-duong(l1, l2)
  if d > 1e-5 { return none } // Chéo nhau hoặc song song cách nhau

  let perp = doan-vuong-goc-chung(l1, l2)
  perp.M1
}

// ─────────────────────────────────────────────────────────────
// 6. ĐO GÓC KHÔNG GIAN (ANGLES IN 3D)
// ─────────────────────────────────────────────────────────────

/// Góc giữa 2 vector u và v (trả về góc tính bằng radian hoặc degree)
#let goc-hai-vecto(u, v) = {
  let nu = vec3-norm(pt(u))
  let nv = vec3-norm(pt(v))
  assert(nu > 1e-8 and nv > 1e-8, message: "Zero vector has undefined angle")
  let cos-a = calc.clamp(vec3-dot(pt(u), pt(v)) / (nu * nv), -1.0, 1.0)
  calc.acos(cos-a)
}

/// Góc giữa 2 đường thẳng trong không gian in [0, pi/2]
#let goc-hai-duong(L1, L2) = {
  let l1 = if type(L1) == array { duong-thang(L1.at(0), diem2: L1.at(1)) } else { L1 }
  let l2 = if type(L2) == array { duong-thang(L2.at(0), diem2: L2.at(1)) } else { L2 }
  let cos-a = calc.clamp(calc.abs(vec3-dot(l1.dir, l2.dir)), 0.0, 1.0)
  calc.acos(cos-a)
}

/// Góc giữa đường thẳng L và mặt phẳng P in [0, pi/2]
#let goc-duong-mat(L, P-plane) = {
  let l = if type(L) == array { duong-thang(L.at(0), diem2: L.at(1)) } else { L }
  let pl = if type(P-plane) == array { mat-phang(P-plane.at(0), B: P-plane.at(1), C: P-plane.at(2)) } else { P-plane }
  let sin-a = calc.clamp(calc.abs(vec3-dot(l.dir, pl.normal)), 0.0, 1.0)
  calc.asin(sin-a)
}

/// Góc giữa 2 mặt phẳng (góc phẳng nhị diện) in [0, pi/2]
#let goc-hai-mat(P1, P2) = {
  let pl1 = if type(P1) == array { mat-phang(P1.at(0), B: P1.at(1), C: P1.at(2)) } else { P1 }
  let pl2 = if type(P2) == array { mat-phang(P2.at(0), B: P2.at(1), C: P2.at(2)) } else { P2 }
  let cos-a = calc.clamp(calc.abs(vec3-dot(pl1.normal, pl2.normal)), 0.0, 1.0)
  calc.acos(cos-a)
}

// ─────────────────────────────────────────────────────────────
// 7. BIẾN HÌNH KHÔNG GIAN (RIGID TRANSFORMATIONS & HOMOTHETY)
// ─────────────────────────────────────────────────────────────

/// Phép quay quanh trục bất kỳ theo Công thức Rodrigues
/// - point: Điểm cần quay
/// - truc-goc: Điểm nằm trên trục quay
/// - truc-huong: Vector chỉ phương của trục quay
/// - goc: Góc quay (ví dụ: 45deg, 90deg, calc.pi/3)
#let quay-quanh-truc(point, truc-goc, truc-huong, goc) = {
  let p = pt(point)
  let origin = pt(truc-goc)
  let k = vec3-unit(pt(truc-huong))
  let v = vec-ab(origin, p)

  let cos-t = calc.cos(goc)
  let sin-t = calc.sin(goc)

  // Công thức Rodrigues: v_rot = v*cos(t) + (k x v)*sin(t) + k*(k.v)*(1 - cos(t))
  let v-cos = vec3-scale(v, cos-t)
  let k-cross-v = vec3-scale(vec3-cross(k, v), sin-t)
  let k-dot-v = vec3-dot(k, v)
  let k-term = vec3-scale(k, k-dot-v * (1.0 - cos-t))

  let v-rot = vec3-add(vec3-add(v-cos, k-cross-v), k-term)
  vec3-add(origin, v-rot)
}

/// Phép vị tự tâm I tỉ số k: P' = I + k*(P - I)
#let vi-tu(point, tam: (0, 0, 0), k: 1.0) = {
  let p = pt(point); let pI = pt(tam); let fk = float(k)
  (
    pI.at(0) + fk * (p.at(0) - pI.at(0)),
    pI.at(1) + fk * (p.at(1) - pI.at(1)),
    pI.at(2) + fk * (p.at(2) - pI.at(2))
  )
}

// ─────────────────────────────────────────────────────────────
// 8. CẮT THIẾT DIỆN TỰ ĐỘNG KHỐI ĐA DIỆN (AUTOMATED CROSS-SECTION SLICER)
// ─────────────────────────────────────────────────────────────

/// Cắt một khối đa diện bởi Mặt phẳng P-plane
/// Trả về mảng các đỉnh của đa giác thiết diện theo đúng thứ tự chu vi lồi!
#let cat-thiet-dien(poly-or-vertices, P-plane, faces: none) = {
  let vertices = if type(poly-or-vertices) == dictionary and "vertices" in poly-or-vertices {
    poly-or-vertices.vertices
  } else {
    poly-or-vertices
  }
  let poly-faces = if faces != none {
    faces
  } else if type(poly-or-vertices) == dictionary and "faces" in poly-or-vertices {
    poly-or-vertices.faces
  } else {
    ()
  }
  let pl = if type(P-plane) == array { mat-phang(P-plane.at(0), B: P-plane.at(1), C: P-plane.at(2)) } else { P-plane }

  // 1. Thu thập tất cả các cạnh duy nhất
  let edges = ()
  let edge-keys = (:)
  for f in poly-faces {
    let k = f.len()
    for i in range(k) {
      let u = f.at(i); let v = f.at(calc.rem(i + 1, k))
      let (cu, cv) = if u < v { (u, v) } else { (v, u) }
      let key = str(cu) + "_" + str(cv)
      if not (key in edge-keys) {
        edge-keys.insert(key, true)
        edges.push((cu, cv))
      }
    }
  }

  // 2. Tìm giao điểm của mặt phẳng pl với từng cạnh
  let cut-points = ()
  for (u-idx, v-idx) in edges {
    let pu = vertices.at(u-idx)
    let pv = vertices.at(v-idx)
    let du = vec3-dot(vec-ab(pl.point, pu), pl.normal)
    let dv = vec3-dot(vec-ab(pl.point, pv), pl.normal)

    // Nếu hai đỉnh nằm về 2 phía của mặt phẳng
    if du * dv < -1e-6 {
      let t = du / (du - dv)
      let Q = vec3-add(pu, vec3-scale(vec-ab(pu, pv), t))
      cut-points.push(Q)
    } else if calc.abs(du) < 1e-6 {
      // Đỉnh pu nằm chính xác trên mặt phẳng
      cut-points.push(pu)
    }
  }

  // Khử các điểm trùng lặp
  let unique-pts = ()
  for pt-i in cut-points {
    let dup = false
    for u-pt in unique-pts {
      if vec3-dist(pt-i, u-pt) < 1e-4 { dup = true; break }
    }
    if not dup { unique-pts.push(pt-i) }
  }

  if unique-pts.len() < 3 { return () }

  // 3. Sắp xếp các đỉnh giao điểm theo chiều kim đồng hồ trên mặt phẳng thiết diện
  let center = trong-tam(unique-pts)
  let basis = plane-basis(pl)
  let angles-pts = ()
  for p in unique-pts {
    let v = vec-ab(center, p)
    let x = vec3-dot(v, basis.u)
    let y = vec3-dot(v, basis.v)
    let ang = calc.atan2(x, y)
    angles-pts.push((ang: ang, pt: p))
  }

  // Sắp xếp theo góc
  angles-pts = angles-pts.sorted(key: item => item.ang)
  angles-pts.map(item => item.pt)
}

// ─────────────────────────────────────────────────────────────
// 9. MÔI TRƯỜNG DỰNG HÌNH ĐẠI SỐ LINH HOẠT (KHONG-GIAN-3D CANVAS)
// ─────────────────────────────────────────────────────────────

/// Môi trường dựng hình không gian 3D tương tác đại số trực quan
/// Tự động quản lý Camera, phép chiếu và cung cấp bộ cọ vẽ (draw tools) thông minh
#let khong-gian-3d(
  cam: none,
  length: 1.0cm,
  body
) = {
  let cam-obj = if cam == none {
    make-camera(elevation: 20deg, azimuth: 35deg, scale: 1.0)
  } else {
    cam
  }

  cetz.canvas(length: length, {
    let d_cetz = cetz.draw

    // Bộ công cụ vẽ hình học không gian trực tiếp từ tọa độ 3D
    let g = (
      cam: cam-obj,
      proj: pt3d => project-pt(pt(pt3d), cam-obj),

      // Vẽ điểm 3D
      diem: (P, ten: none, huong: "north", bk: 2.2pt, mau: black, lech: (0.0, 0.0)) => {
        let p2d = project-pt(pt(P), cam-obj)
        d_cetz.circle(p2d, radius: bk, fill: mau, stroke: none)
        if ten != none {
          d_cetz.content((p2d.at(0) + lech.at(0), p2d.at(1) + lech.at(1)), anchor: huong)[#ten]
        }
      },

      // Vẽ đoạn thẳng 3D nối 2 điểm
      doan: (A, B, dut: false, mau: black, day: 0.95pt) => {
        let pA = project-pt(pt(A), cam-obj)
        let pB = project-pt(pt(B), cam-obj)
        let st = if dut { (paint: mau, thickness: day, dash: "dashed") } else { day + mau }
        d_cetz.line(pA, pB, stroke: st)
      },

      // Vẽ vector 3D nối A -> B
      vecto: (A, B, ten: none, huong: "north", mau: black, day: 1.1pt) => {
        let pA = project-pt(pt(A), cam-obj)
        let pB = project-pt(pt(B), cam-obj)
        d_cetz.line(pA, pB, stroke: day + mau, mark: (end: ">", fill: mau, size: 0.16))
        if ten != none {
          let mid = ( (pA.at(0) + pB.at(0)) * 0.5, (pA.at(1) + pB.at(1)) * 0.5 )
          d_cetz.content(mid, anchor: huong)[#ten]
        }
      },

      // Vẽ đa giác 3D (tam giác, tứ giác, thiết diện...)
      da-giac: (pts, fill: none, stroke: 0.95pt + black, close: true) => {
        let pts2d = pts.map(p => project-pt(pt(p), cam-obj))
        d_cetz.line(..pts2d, close: close, fill: fill, stroke: stroke)
      },

      // Ký hiệu góc vuông 3D tại đỉnh B (A-B-C)
      goc-vuong: (A, B, C, size: 0.25, mau: rgb("94a3b8")) => {
        let pA = project-pt(pt(A), cam-obj)
        let pB = project-pt(pt(B), cam-obj)
        let pC = project-pt(pt(C), cam-obj)
        let v1 = (pA.at(0) - pB.at(0), pA.at(1) - pB.at(1))
        let v2 = (pC.at(0) - pB.at(0), pC.at(1) - pB.at(1))
        let l1 = calc.sqrt(v1.at(0) * v1.at(0) + v1.at(1) * v1.at(1))
        let l2 = calc.sqrt(v2.at(0) * v2.at(0) + v2.at(1) * v2.at(1))
        if l1 > 1e-6 and l2 > 1e-6 {
          let u1 = (v1.at(0) / l1 * size, v1.at(1) / l1 * size)
          let u2 = (v2.at(0) / l2 * size, v2.at(1) / l2 * size)
          let p1 = (pB.at(0) + u1.at(0), pB.at(1) + u1.at(1))
          let p2 = (pB.at(0) + u1.at(0) + u2.at(0), pB.at(1) + u1.at(1) + u2.at(1))
          let p3 = (pB.at(0) + u2.at(0), pB.at(1) + u2.at(1))
          d_cetz.line(p1, p2, p3, stroke: 0.75pt + mau)
        }
      },
    )

    body(g)
  })
}
#let ve-hinh-khong-gian = khong-gian-3d
