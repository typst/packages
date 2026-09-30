// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / LUADRAW_CONTOUR.TYP — Động Cơ Giải Tích Đường Bao & Cắt Khối 3D
// Tái hiện & phát triển toàn diện thuật toán Dcut_sphere & Silhouette Tracing
// từ luadraw (Patrick Fradin - LuaLaTeX) cho Typst
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "vec3.typ": *
#import "camera.typ": *
#import "objects3d.typ": *
#import "solvers3d.typ": *

// Định nghĩa các alias nội bộ tương thích toán học vector
#let v3-add = vec3-add
#let v3-sub = vec3-sub
#let v3-scale = vec3-scale
#let v3-dot = vec3-dot
#let v3-cross = vec3-cross
#let v3-norm = vec3-norm
#let v3-unit = vec3-unit

// ─────────────────────────────────────────────────────────────
// 1. THUẬT TOÁN ĐƯỜNG BAO & TIẾP TUYẾN SILHOUETTE
// ─────────────────────────────────────────────────────────────

/// Tính 2 tiếp điểm T1, T2 giữa đường tròn giao tuyến mặt phẳng P
/// với đường bao silhouette của mặt cầu (C, R) dưới góc nhìn camera
/// Thuật toán tương đương Sphere_tangency trong luadraw_frustum_and_co.lua
#let tinh-tiep-diem-mat-cau(center, radius, plane-pt, plane-normal, cam) = {
  let C = center
  let R = float(radius)
  let n_p = v3-unit(plane-normal)
  let v_cam = cam.at("view-dir", default: (0.8, 0.5, 0.4))

  // 1. Tính tâm c và bán kính r của đường tròn thiết diện
  let d_plane = v3-dot(v3-sub(plane-pt, C), n_p)
  if calc.abs(d_plane) >= R {
    return (has_tangents: false, circle_center: C, circle_radius: 0.0, T1: none, T2: none)
  }

  let c = v3-add(C, v3-scale(n_p, d_plane))
  let r = calc.sqrt(calc.max(0.0, R * R - d_plane * d_plane))

  // 2. Hệ cơ sở trực chuẩn trong mặt phẳng P
  let v_proj = v3-sub(v_cam, v3-scale(n_p, v3-dot(v_cam, n_p)))
  let len_proj = v3-norm(v_proj)

  if len_proj < 1e-7 {
    return (
      has_tangents: false,
      circle_center: c,
      circle_radius: r,
      normal: n_p,
      T1: none,
      T2: none,
      is_front: v3-dot(v3-sub(c, C), v_cam) > 0.0,
    )
  }

  let e1 = v3-unit(v_proj)
  let e2 = v3-cross(n_p, e1)

  // 3. Tìm giao điểm của đường tròn (c, r) với mặt phẳng contour (X - C) . v_cam = 0
  let dot_e1_v = v3-dot(e1, v_cam)
  let w1 = -v3-dot(v3-sub(c, C), v_cam) / dot_e1_v

  if r * r < w1 * w1 {
    return (
      has_tangents: false,
      circle_center: c,
      circle_radius: r,
      normal: n_p,
      T1: none,
      T2: none,
      is_front: w1 < 0.0,
    )
  }

  let w2 = calc.sqrt(calc.max(0.0, r * r - w1 * w1))

  let T1 = v3-add(c, v3-add(v3-scale(e1, w1), v3-scale(e2, w2)))
  let T2 = v3-add(c, v3-add(v3-scale(e1, w1), v3-scale(e2, -w2)))

  (
    has_tangents: true,
    circle_center: c,
    circle_radius: r,
    normal: n_p,
    e1: e1,
    e2: e2,
    w1: w1,
    w2: w2,
    T1: T1,
    T2: T2,
  )
}

/// Lấy n điểm phân bố đều trên vành miệng cắt (dùng cho bài toán chùm đèn)
#let lay-diem-tren-vanh-cat(center, radius, plane-pt, plane-normal, n: 4, phase: 0deg) = {
  let C = center
  let R = float(radius)
  let n_p = v3-unit(plane-normal)
  let d_plane = v3-dot(v3-sub(plane-pt, C), n_p)
  let c = v3-add(C, v3-scale(n_p, d_plane))
  let r = calc.sqrt(calc.max(0.0, R * R - d_plane * d_plane))

  // Chọn 2 vector cơ sở u1, u2 trong mặt phẳng cắt
  let ref = if calc.abs(n_p.at(0)) < 0.8 { (1.0, 0.0, 0.0) } else { (0.0, 1.0, 0.0) }
  let u1 = v3-unit(v3-cross(n_p, ref))
  let u2 = v3-cross(n_p, u1)

  let pts = ()
  let step = 360deg / float(n)
  for i in range(n) {
    let ang = phase + float(i) * step
    let pt = v3-add(c, v3-add(v3-scale(u1, r * calc.cos(ang)), v3-scale(u2, r * calc.sin(ang))))
    pts.push(pt)
  }
  pts
}

// ─────────────────────────────────────────────────────────────
// 2. DCUT_SPHERE — VẼ MẶT CẦU BỊ CẮT VỚI ĐỔ BÓNG 3D CHUẨN LUADRAW
// ─────────────────────────────────────────────────────────────

/// Vẽ mặt cầu bị cắt bởi mặt phẳng chuẩn Luadraw (tương đương g:Dcut_sphere)
/// Tự động chia đường tròn miệng cắt thành cung thấy (nét liền) và cung khuất (nét đứt),
/// đổ bóng Gradient studio đa tầng mượt mà và hỗ trợ lấy tọa độ các đỉnh trên vành
#let dcut-sphere(
  center: (0.0, 0.0, 0.0),
  radius: 2.8,
  plane-pt: (0.0, 0.0, -1.0),
  plane-normal: (0.0, 0.0, 1.0),
  keep: "below", // "below" (giữ chỏm dưới) hoặc "above" (giữ chỏm trên)
  cam: none,
  shading: "orange", // "orange", "blue", "emerald", "purple"
  fill-rim: true,
  stroke-rim: none,
  stroke-body: none,
  them: none,
) = {
  let d_cetz = cetz.draw
  let cam-obj = if cam != none { cam } else { make-camera(elevation: 20deg, azimuth: 35deg) }
  let C = center
  let R = float(radius)

  // Bảng màu đổ bóng Studio
  let pal = if shading == "orange" {
    (
      hi: rgb("fed7aa"),
      mid: rgb("f97316"),
      dark: rgb("c2410c"),
      deep: rgb("431407"),
      rim: rgb("ea580c"),
      cap: gradient.radial(rgb("ffedd5"), rgb("fed7aa"), rgb("fdba74"), center: (40%, 40%), radius: 75%),
    )
  } else if shading == "blue" {
    (
      hi: rgb("bae6fd"),
      mid: rgb("0284c7"),
      dark: rgb("0369a1"),
      deep: rgb("082f49"),
      rim: rgb("0284c7"),
      cap: gradient.radial(rgb("e0f2fe"), rgb("bae6fd"), rgb("7dd3fc"), center: (40%, 40%), radius: 75%),
    )
  } else if shading == "emerald" {
    (
      hi: rgb("a7f3d0"),
      mid: rgb("10b981"),
      dark: rgb("047857"),
      deep: rgb("064e3b"),
      rim: rgb("059669"),
      cap: gradient.radial(rgb("d1fae5"), rgb("a7f3d0"), rgb("6ee7b7"), center: (40%, 40%), radius: 75%),
    )
  } else {
    (
      hi: rgb("e9d5ff"),
      mid: rgb("a855f7"),
      dark: rgb("7e22ce"),
      deep: rgb("3b0764"),
      rim: rgb("9333ea"),
      cap: gradient.radial(rgb("f3e8ff"), rgb("e9d5ff"), rgb("d8b4fe"), center: (40%, 40%), radius: 75%),
    )
  }

  let st-rim = if stroke-rim != none { stroke-rim } else { 0.75pt + pal.rim }
  let st-body = if stroke-body != none { stroke-body } else { 0.4pt + pal.deep }

  // Thông số giải tích
  let n_p = v3-unit(plane-normal)
  let d_plane = v3-dot(v3-sub(plane-pt, C), n_p)
  let c3d = v3-add(C, v3-scale(n_p, d_plane))
  let r3d = calc.sqrt(calc.max(0.0, R * R - d_plane * d_plane))

  let c2d = project-pt(c3d, cam-obj)
  let C2d = project-pt(C, cam-obj)

  let alpha = cam-obj.elevation
  let cos-a = calc.cos(alpha)
  let sin-a = calc.sin(alpha)
  let tan-a = calc.tan(alpha)

  // Kiểm tra nếu mặt cắt nằm ngang (z-cut)
  let is-horizontal = calc.abs(n_p.at(2)) > 0.95

  if is-horizontal {
    let z0 = d_plane
    let a = r3d
    let b = r3d * sin-a
    let xc = c2d.at(0)
    let yc = c2d.at(1)

    // Góc tiếp xúc silhouette chân trời
    let sin-gamma = z0 / (R * cos-a)
    let gamma = if calc.abs(sin-gamma) < 0.9999 { calc.asin(sin-gamma) } else { 0deg }

    // Góc tiếp xúc trên elip
    let cos-psi = - (z0 * tan-a) / r3d
    let psi = if calc.abs(cos-psi) < 0.9999 { calc.acos(cos-psi) } else { 90deg }

    // 1. Sinh cung đáy silhouette mặt cầu (hoặc đỉnh)
    let n-arc = 48
    let body-pts = ()
    if keep == "below" {
      let ang-start = gamma
      let ang-end = -180deg - gamma
      for i in range(n-arc + 1) {
        let t = i / n-arc
        let ang = ang-start * (1 - t) + ang-end * t
        body-pts.push((C2d.at(0) + R * calc.cos(ang), C2d.at(1) + R * calc.sin(ang)))
      }
      // Sinh cung trước elip miệng
      let n-el = 36
      for i in range(n-el + 1) {
        let t = i / n-el
        let p = psi * (1 - t) + (-psi) * t
        let px = xc - r3d * calc.sin(p)
        let py = yc - b * calc.cos(p)
        body-pts.push((px, py))
      }
    } else {
      let ang-start = gamma
      let ang-end = 180deg - gamma
      for i in range(n-arc + 1) {
        let t = i / n-arc
        let ang = ang-start * (1 - t) + ang-end * t
        body-pts.push((C2d.at(0) + R * calc.cos(ang), C2d.at(1) + R * calc.sin(ang)))
      }
      let n-el = 36
      for i in range(n-el + 1) {
        let t = i / n-el
        let p = (-psi) * (1 - t) + psi * t
        let px = xc - r3d * calc.sin(p)
        let py = yc + b * calc.cos(p)
        body-pts.push((px, py))
      }
    }

    // 2. Vẽ thân chỏm cầu đổ bóng Radial mượt mà
    let sph-grad = gradient.radial(pal.hi, pal.mid, pal.dark, pal.deep, center: (35%, 35%), radius: 72%)
    d_cetz.line(..body-pts, close: true, stroke: st-body, fill: sph-grad)

    // 3. Vẽ mặt phẳng miệng cắt (elip)
    if fill-rim {
      d_cetz.circle(c2d, radius: (a, b), fill: pal.cap, stroke: st-rim)
    }

  } else {
    // Trường hợp mặt phẳng cắt tổng quát
    let R2d = R * cam-obj.scale
    d_cetz.circle(
      C2d,
      radius: R2d,
      fill: gradient.radial(pal.hi, pal.mid, pal.dark, pal.deep, center: (35%, 35%), radius: 72%),
      stroke: st-body,
    )
    if fill-rim {
      let rim_pts_3d = lay-diem-tren-vanh-cat(C, R, plane-pt, plane-normal, n: 48)
      let rim_pts_2d = rim_pts_3d.map(p => project-pt(p, cam-obj))
      d_cetz.line(..rim_pts_2d, close: true, fill: pal.cap, stroke: st-rim)
    }
  }

  // Dữ liệu truyền cho callback vẽ thêm
  let d_data = (
    center: C,
    radius: R,
    circle_center: c3d,
    circle_radius: r3d,
    center_2d: C2d,
    rim_center_2d: c2d,
    cam: cam-obj,
    lay-diem: (n, phase: 0deg) => lay-diem-tren-vanh-cat(C, R, plane-pt, plane-normal, n: n, phase: phase),
    project: pt3d => project-pt(pt3d, cam-obj),
  )

  if them != none {
    them(d_data)
  }
}

/// Bao đóng dcut-sphere trong CeTZ canvas độc lập
#let dcut-sphere-fig(..args) = cetz.canvas({ dcut-sphere(..args) })

// ─────────────────────────────────────────────────────────────
// 3. PRESET CHÙM ĐÈN N ĐỈNH CHUẨN BÀI ĐĂNG FACEBOOK LUADRAW
// ─────────────────────────────────────────────────────────────

/// Mô hình chùm đèn đa giác đều n đỉnh treo trên chỏm cầu cắt
/// Tái hiện chuẩn xác 100% hình ảnh Facebook tham chiếu từ luadraw
#let preset-chum-den-luadraw(
  n: 3,
  R: 2.8,
  z-cut: -0.9,
  S-height: 4.2,
  phase: auto,
  cam: none,
  shading: "orange",
  ten-dinh: ($S$, $A$, $B$, $C$, $D$, $E$, $F$, $G$, $H$),
  hien-luc: true,
) = {
  let d_cetz = cetz.draw
  let cam-obj = if cam != none { cam } else { make-camera(elevation: 20deg, azimuth: 35deg) }
  let pha = if phase != auto { phase } else if n == 3 { 25deg } else if n == 4 { 15deg } else { 10deg }

  dcut-sphere(
    center: (0.0, 0.0, 0.0),
    radius: R,
    plane-pt: (0.0, 0.0, z-cut),
    plane-normal: (0.0, 0.0, 1.0),
    keep: "below",
    cam: cam-obj,
    shading: shading,
    them: d => {
      let S3d = (0.0, 0.0, S-height)
      let S2d = project-pt(S3d, cam-obj)

      // Lấy n điểm đều trên vành
      let pts3d = (d.lay-diem)(n, phase: pha)
      let pts2d = pts3d.map(p => project-pt(p, cam-obj))

      // 1. Chấm điểm đỉnh S và nhãn
      d_cetz.circle(S2d, radius: 2.2pt, fill: black, stroke: none)
      d_cetz.content((S2d.at(0), S2d.at(1) + 0.22), anchor: "south", text(weight: "bold")[#ten-dinh.at(0)])

      // 2. Vẽ các dây treo từ S đến các điểm trên vành miệng chao
      for (i, p2) in pts2d.enumerate() {
        d_cetz.line(S2d, p2, stroke: 0.95pt + black)

        // Chấm điểm và nhãn trên vành
        d_cetz.circle(p2, radius: 2pt, fill: black, stroke: none)
        let lbl = if i + 1 < ten-dinh.len() { ten-dinh.at(i + 1) } else { str.from-unicode(65 + i) }
        let h_dir = if p2.at(0) < d.rim_center_2d.at(0) { "north-east" } else { "north-west" }
        d_cetz.content((p2.at(0), p2.at(1) - 0.18), anchor: h_dir, text(weight: "bold")[#lbl])

        // 3. Vẽ vector lực F_i dọc theo dây treo (mũi tên hướng xuống vành chao đèn)
        if hien-luc {
          let t_start = 0.38
          let t_end = 0.68
          let F_start = (S2d.at(0) + (p2.at(0) - S2d.at(0)) * t_start, S2d.at(1) + (p2.at(1) - S2d.at(1)) * t_start)
          let F_end   = (S2d.at(0) + (p2.at(0) - S2d.at(0)) * t_end,   S2d.at(1) + (p2.at(1) - S2d.at(1)) * t_end)

          d_cetz.line(F_start, F_end, stroke: 1.15pt + black, mark: (end: "stealth", fill: black, size: 0.18))

          // Nhãn vector lực F_1, F_2...
          let F_mid = ( (F_start.at(0) + F_end.at(0)) / 2.0, (F_start.at(1) + F_end.at(1)) / 2.0 )
          let sign_x = if p2.at(0) >= S2d.at(0) { 0.2 } else { -0.2 }
          d_cetz.content((F_mid.at(0) + sign_x, F_mid.at(1)), anchor: "center")[$arrow(F)_#(i + 1)$]
        }
      }
    }
  )
}

/// Bao đóng preset chùm đèn trong canvas độc lập
#let preset-chum-den-luadraw-fig(..args) = cetz.canvas({ preset-chum-den-luadraw(..args) })
