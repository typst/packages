// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / CURVED3D.TYP — Mặt Cong, Khối Tròn Xoay & Cắt Chỏm Cầu
// Tích hợp hệ thống Đổ Bóng 3D Radial Gradients chân thực chuẩn Luadraw
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "vec3.typ": *
#import "camera.typ": *
#import "objects3d.typ": *
#import "solvers3d.typ": *
#import "culling.typ": *

// ─────────────────────────────────────────────────────────────
// 1. CÁC DẢI MÀU ĐỔ BÓNG 3D CHUẨN STUDIO (SHADING PALETTES)
// ─────────────────────────────────────────────────────────────

/// Dải màu Cam Hổ Phách 3D (Ấm áp, chuẩn hình mẫu Facebook luadraw)
#let shading-warm-orange = gradient.radial(
  rgb("ffedd5"),
  rgb("fb923c"),
  rgb("ea580c"),
  rgb("c2410c"),
  rgb("7c2d12"),
  rgb("431407"),
  center: (35%, 28%),
  radius: 78%,
)

#let shading-warm-cap = gradient.radial(
  rgb("ffedd5"),
  rgb("fb923c"),
  rgb("ea580c"),
  center: (45%, 40%),
  radius: 80%,
)

/// Dải màu Lam Ngọc 3D (Hiện đại, thanh lịch)
#let shading-cool-blue = gradient.radial(
  rgb("f0f9ff"),
  rgb("38bdf8"),
  rgb("0284c7"),
  rgb("0369a1"),
  rgb("075985"),
  rgb("082f49"),
  center: (35%, 28%),
  radius: 78%,
)

#let shading-cool-cap = gradient.radial(
  rgb("e0f2fe"),
  rgb("38bdf8"),
  rgb("0284c7"),
  center: (45%, 40%),
  radius: 80%,
)

/// Dải màu Ngọc Lục Bảo 3D (Emerald)
#let shading-emerald = gradient.radial(
  rgb("ecfdf5"),
  rgb("34d399"),
  rgb("059669"),
  rgb("047857"),
  rgb("064e3b"),
  rgb("022c22"),
  center: (35%, 28%),
  radius: 78%,
)

#let shading-emerald-cap = gradient.radial(
  rgb("d1fae5"),
  rgb("34d399"),
  rgb("059669"),
  center: (45%, 40%),
  radius: 80%,
)

/// Dải màu Vàng Hoàng Kim 3D (Gold)
#let shading-gold = gradient.radial(
  rgb("fefce8"),
  rgb("fde047"),
  rgb("eab308"),
  rgb("ca8a04"),
  rgb("713f12"),
  rgb("422006"),
  center: (35%, 28%),
  radius: 78%,
)

/// Dải màu Thạch Anh Tím 3D (Amethyst)
#let shading-amethyst = gradient.radial(
  rgb("faf5ff"),
  rgb("c084fc"),
  rgb("9333ea"),
  rgb("7e22ce"),
  rgb("581c87"),
  rgb("2e1065"),
  center: (35%, 28%),
  radius: 78%,
)

// ─────────────────────────────────────────────────────────────
// 2. VẼ ĐƯỜNG TRÒN 3D (DRAW-CIRCLE3D)
// ─────────────────────────────────────────────────────────────

/// Vẽ đường tròn trong không gian 3D tự động chia nửa nét đứt / nét liền
#let draw-circle3d(
  center,
  radius,
  normal,
  cam: none,
  sphere-center: none,
  stroke-visible: 0.9pt + black,
  stroke-hidden: (paint: rgb("888888"), thickness: 0.6pt, dash: "dashed"),
  fill: none,
  n-samples: 64,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }
  let C3d = circle3d(center, radius, normal)
  let pts3d = circle3d-sample(C3d, n: n-samples)
  let pts2d = project-pts(pts3d, cam-obj)

  if fill != none {
    d.line(..pts2d, close: true, stroke: none, fill: fill)
  }

  let is-vis = ()
  for pt in pts3d {
    if sphere-center != none {
      let out-dir = vec3-sub(pt, sphere-center)
      is-vis.push(vec3-dot(out-dir, cam-obj.view-dir) > -1e-5)
    } else {
      let radial = vec3-sub(pt, center)
      is-vis.push(vec3-dot(radial, cam-obj.view-dir) > -1e-5)
    }
  }

  let n = pts2d.len()
  for i in range(n) {
    let next-i = calc.rem(i + 1, n)
    let p1 = pts2d.at(i)
    let p2 = pts2d.at(next-i)
    let v1 = is-vis.at(i)
    let v2 = is-vis.at(next-i)

    let st = if v1 or v2 { stroke-visible } else { stroke-hidden }
    d.line(p1, p2, stroke: st)
  }
}

// ─────────────────────────────────────────────────────────────
// 3. VẼ MẶT CẦU HOÀN CHỈNH ĐỔ BÓNG 3D (DRAW-SPHERE)
// ─────────────────────────────────────────────────────────────

/// Vẽ khối cầu hoàn chỉnh với hiệu ứng đổ bóng 3D chân thực (Radial Shading)
#let draw-sphere(
  center: (0.0, 0.0, 0.0),
  radius: 2.5,
  cam: none,
  shading: "orange", // "orange" | "blue" | "emerald" | "gold" | "amethyst" | none | gradient
  stroke: 0.3pt + rgb("431407"),
  show-equator: true,
  equator-stroke-vis: 0.8pt + black,
  equator-stroke-hid: (paint: rgb("888888"), thickness: 0.6pt, dash: "dashed"),
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }
  let c2d = project-pt(center, cam-obj)
  let r-eff = radius * cam-obj.at("scale", default: 1.0)

  // Lựa chọn gradient đổ bóng
  let fill-grad = if shading == "orange" {
    shading-warm-orange
  } else if shading == "blue" {
    shading-cool-blue
  } else if shading == "emerald" {
    shading-emerald
  } else if shading == "gold" {
    shading-gold
  } else if shading == "amethyst" {
    shading-amethyst
  } else if shading == none {
    none
  } else {
    shading
  }

  let st = if shading == "orange" {
    0.3pt + rgb("431407")
  } else if shading == "blue" {
    0.3pt + rgb("082f49")
  } else {
    stroke
  }

  // 1. Vẽ hình cầu đổ bóng
  d.circle(c2d, radius: r-eff, stroke: st, fill: fill-grad)

  // 2. Vẽ đường xích đạo
  if show-equator {
    draw-circle3d(
      center,
      radius,
      vec3-k,
      cam: cam-obj,
      sphere-center: center,
      stroke-visible: equator-stroke-vis,
      stroke-hidden: equator-stroke-hid,
    )
  }
}

// ─────────────────────────────────────────────────────────────
// 4. CHỨC NĂNG CẮT MẶT CẦU THUẬT TOÁN (DRAW-CUT-SPHERE)
// Tương đương g:Dcut_sphere của luadraw với đổ bóng 3D chân thực
// ─────────────────────────────────────────────────────────────

/// Vẽ phần chỏm cầu hoặc hình cầu bị cắt bởi mặt phẳng (chuẩn Luadraw)
///
/// - cut: Đối tượng CutSphere (từ cut-sphere(S, P, keep: ...)) hoặc none
/// - center: Tâm mặt cầu nếu không truyền cut
/// - radius: Bán kính mặt cầu nếu không truyền cut
/// - cut-plane: Mặt phẳng cắt nếu không truyền cut
/// - keep: "below" (lấy chỏm dưới / chùm đèn) hoặc "above" (lấy chỏm trên)
/// - cam: Đối tượng Camera
/// - shading: Dải màu thân cầu ("orange" | "blue" | "emerald" | gradient)
/// - cap-shading: Dải màu mặt cắt elip miệng
/// - stroke-rim: Đường viền miệng cắt (mặc định: 0.6pt + cam/coral)
/// - stroke-contour: Đường bao silhouette thân cầu
#let draw-cut-sphere(
  cut: none,
  center: (0.0, 0.0, 0.0),
  radius: 3.0,
  cut-plane: none,
  keep: "below",
  cam: none,
  shading: "orange",
  cap-shading: none,
  stroke-rim: none,
  stroke-contour: none,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }

  // 1. Xác định đối tượng CutSphere
  let cut-obj = if cut != none {
    cut
  } else {
    let S = sphere(center, radius)
    let P = if cut-plane != none { cut-plane } else { plane((0.0, 0.0, -1.0), (0.0, 0.0, 1.0)) }
    cut-sphere(S, P, keep: keep)
  }

  let S = cut-obj.sphere
  let R = S.radius
  let C = S.center
  let z0 = cut-obj.dist // Khoảng cách từ tâm đến mặt phẳng cắt
  let r = cut-obj.rim.radius

  // 2. Thông số góc nhìn camera
  let alpha = cam-obj.elevation
  let cos-a = calc.cos(alpha)
  let sin-a = calc.sin(alpha)
  let tan-a = calc.tan(alpha)

  let c2d = project-pt(C, cam-obj)
  let xc-center = c2d.at(0)
  let yc-center = c2d.at(1) + z0 * cos-a
  let a = r
  let b = r * sin-a

  // 3. Tính góc tiếp xúc silhouette chân trời
  let sin-gamma = z0 / (R * cos-a)
  let gamma = if calc.abs(sin-gamma) < 0.9999 { calc.asin(sin-gamma) } else { 0deg }

  // Góc tiếp xúc trên elip
  let cos-psi = - (z0 * tan-a) / r
  let psi = if calc.abs(cos-psi) < 0.9999 { calc.acos(cos-psi) } else { 90deg }

  // 4. Chọn dải màu đổ bóng 3D
  let sph-grad = if shading == "orange" {
    shading-warm-orange
  } else if shading == "blue" {
    shading-cool-blue
  } else if shading == "emerald" {
    shading-emerald
  } else if shading == "gold" {
    shading-gold
  } else if shading == "amethyst" {
    shading-amethyst
  } else if shading == none {
    none
  } else {
    shading
  }

  let cap-grad = if cap-shading != none {
    cap-shading
  } else if shading == "orange" {
    shading-warm-cap
  } else if shading == "blue" {
    shading-cool-cap
  } else if shading == "emerald" {
    shading-emerald-cap
  } else {
    none
  }

  let st-rim = if stroke-rim != none {
    stroke-rim
  } else if shading == "orange" {
    0.6pt + rgb("ea580c")
  } else if shading == "blue" {
    0.6pt + rgb("0284c7")
  } else {
    0.6pt + black
  }

  let st-cont = if stroke-contour != none {
    stroke-contour
  } else if shading == "orange" {
    0.3pt + rgb("431407")
  } else if shading == "blue" {
    0.3pt + rgb("082f49")
  } else {
    0.5pt + black
  }

  // 5. Sinh cung đáy silhouette mặt cầu
  let n-arc = 48
  let bottom-pts = ()
  let ang-start = gamma
  let ang-end = -180deg - gamma
  for i in range(n-arc + 1) {
    let t = i / n-arc
    let ang = ang-start * (1 - t) + ang-end * t
    bottom-pts.push((xc-center + R * calc.cos(ang), c2d.at(1) + R * calc.sin(ang)))
  }

  // 6. Sinh cung trước elip miệng
  let n-el = 36
  let front-el-pts = ()
  for i in range(n-el + 1) {
    let t = i / n-el
    let p = psi * (1 - t) + (-psi) * t
    let px = xc-center - r * calc.sin(p)
    let py = yc-center - b * calc.cos(p)
    front-el-pts.push((px, py))
  }

  // 7. Vẽ thân chỏm cầu đổ bóng
  d.line(..bottom-pts, ..front-el-pts, close: true, stroke: st-cont, fill: sph-grad)

  // 8. Vẽ mặt cắt ngang elip miệng
  d.circle((xc-center, yc-center), radius: (a, b), fill: cap-grad, stroke: st-rim)
}

// ─────────────────────────────────────────────────────────────
// 5. HÌNH TRỤ 3D & HÌNH NÓN 3D ĐỔ BÓNG (CYLINDER & CONE 3D)
// ─────────────────────────────────────────────────────────────

/// Vẽ hình trụ 3D với đổ bóng mượt
#let draw-cylinder3d(
  center: (0.0, 0.0, 0.0),
  radius: 1.5,
  height-vector: (0.0, 0.0, 3.8),
  cam: none,
  fill-side: gradient.linear(rgb("e0f2fe"), rgb("38bdf8"), rgb("0369a1"), angle: 0deg),
  fill-top: rgb("bae6fd"),
  stroke: 0.8pt + rgb("0369a1"),
  stroke-hidden: (paint: rgb("94a3b8"), thickness: 0.6pt, dash: "dashed"),
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }

  let h-vec = if type(height-vector) == array { height-vector } else { (0.0, 0.0, float(height-vector)) }
  let top-center = vec3-add(center, h-vec)
  let axis = vec3-unit(h-vec)

  let gen-dir = vec3-unit(vec3-cross(axis, cam-obj.view-dir))
  if vec3-norm(gen-dir) < 1e-5 { gen-dir = cam-obj.right }

  let p-bot-left = vec3-sub(center, vec3-scale(gen-dir, radius))
  let p-bot-right = vec3-add(center, vec3-scale(gen-dir, radius))
  let p-top-left = vec3-sub(top-center, vec3-scale(gen-dir, radius))
  let p-top-right = vec3-add(top-center, vec3-scale(gen-dir, radius))

  let p-bl2d = project-pt(p-bot-left, cam-obj)
  let p-br2d = project-pt(p-bot-right, cam-obj)
  let p-tl2d = project-pt(p-top-left, cam-obj)
  let p-tr2d = project-pt(p-top-right, cam-obj)

  if fill-side != none {
    d.line(p-bl2d, p-tl2d, p-tr2d, p-br2d, close: true, stroke: none, fill: fill-side)
  }

  d.line(p-bl2d, p-tl2d, stroke: stroke)
  d.line(p-br2d, p-tr2d, stroke: stroke)

  draw-circle3d(
    center,
    radius,
    axis,
    cam: cam-obj,
    stroke-visible: stroke,
    stroke-hidden: stroke-hidden,
  )

  draw-circle3d(
    top-center,
    radius,
    axis,
    cam: cam-obj,
    fill: fill-top,
    stroke-visible: stroke,
    stroke-hidden: stroke,
  )
}

/// Vẽ hình nón 3D với đổ bóng mượt
#let draw-cone3d(
  center: (0.0, 0.0, 0.0),
  radius: 2.0,
  apex: (0.0, 0.0, 4.0),
  cam: none,
  fill-side: gradient.linear(rgb("ffedd5"), rgb("fb923c"), rgb("c2410c"), angle: 0deg),
  fill-base: none,
  stroke: 0.8pt + rgb("9a3412"),
  stroke-hidden: (paint: rgb("cbd5e1"), thickness: 0.6pt, dash: "dashed"),
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }

  let axis = vec3-unit(vec3-sub(apex, center))
  let gen-dir = vec3-unit(vec3-cross(axis, cam-obj.view-dir))
  if vec3-norm(gen-dir) < 1e-5 { gen-dir = cam-obj.right }

  let p-bot-left = vec3-sub(center, vec3-scale(gen-dir, radius))
  let p-bot-right = vec3-add(center, vec3-scale(gen-dir, radius))

  let p-bl2d = project-pt(p-bot-left, cam-obj)
  let p-br2d = project-pt(p-bot-right, cam-obj)
  let p-apex2d = project-pt(apex, cam-obj)

  if fill-side != none {
    d.line(p-bl2d, p-apex2d, p-br2d, close: true, stroke: none, fill: fill-side)
  }

  d.line(p-bl2d, p-apex2d, stroke: stroke)
  d.line(p-br2d, p-apex2d, stroke: stroke)

  draw-circle3d(
    center,
    radius,
    axis,
    cam: cam-obj,
    fill: fill-base,
    stroke-visible: stroke,
    stroke-hidden: stroke-hidden,
  )
}

// ─────────────────────────────────────────────────────────────
// 6. ĐƯỜNG XOẮN ỐC 3D (HELIX) & HÌNH XUYẾN 3D (TORUS)
// ─────────────────────────────────────────────────────────────

/// Vẽ đường xoắn ốc 3D (Helix / Spring) với phân đoạn nét liền trước và nét đứt sau
#let draw-helix3d(
  center: (0.0, 0.0, -1.8),
  radius: 1.5,
  height: 3.6,
  turns: 3.0,
  cam: none,
  stroke-visible: 1.15pt + rgb("0284c7"),
  stroke-hidden: (paint: rgb("94a3b8"), thickness: 0.75pt, dash: "dashed"),
  samples-per-turn: 36,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera(elevation: 20deg, azimuth: 35deg) } else { cam }
  let total-samples = int(turns * samples-per-turn)
  let (cx, cy, cz) = center
  let h-step = height / float(total-samples)
  let ang-step = (turns * 360deg) / float(total-samples)

  let prev-pt2d = none
  let prev-vis = none

  for i in range(total-samples + 1) {
    let ang = float(i) * ang-step
    let z = cz + float(i) * h-step
    let p3d = (cx + radius * calc.cos(ang), cy + radius * calc.sin(ang), z)
    let p2d = project-pt(p3d, cam-obj)

    let radial = (calc.cos(ang), calc.sin(ang), 0.0)
    let is-vis = vec3-dot(radial, cam-obj.view-dir) > -0.05

    if prev-pt2d != none {
      let st = if is-vis or prev-vis { stroke-visible } else { stroke-hidden }
      d.line(prev-pt2d, p2d, stroke: st)
    }
    prev-pt2d = p2d
    prev-vis = is-vis
  }
}

/// Vẽ hình xuyến 3D (Torus) tự động khử nét khuất và đổ bóng Lambertian
#let draw-torus3d(
  center: (0.0, 0.0, 0.0),
  R: 2.0,
  r: 0.65,
  cam: none,
  palette: "gold",
  num-u: 16,
  num-v: 12,
  stroke: 0.4pt + rgb("a16207"),
) = {
  let cam-obj = if cam == none { make-camera(elevation: 25deg, azimuth: 35deg) } else { cam }
  let (cx, cy, cz) = center

  let vertices = ()
  for i in range(num-u) {
    let u = float(i) * 360deg / float(num-u)
    let cu = calc.cos(u)
    let su = calc.sin(u)
    for j in range(num-v) {
      let v = float(j) * 360deg / float(num-v)
      let cv = calc.cos(v)
      let sv = calc.sin(v)
      let x = cx + (R + r * cv) * cu
      let y = cy + (R + r * cv) * su
      let z = cz + r * sv
      vertices.push((x, y, z))
    }
  }

  let faces = ()
  for i in range(num-u) {
    let next-i = calc.rem(i + 1, num-u)
    for j in range(num-v) {
      let next-j = calc.rem(j + 1, num-v)
      let idx0 = i * num-v + j
      let idx1 = next-i * num-v + j
      let idx2 = next-i * num-v + next-j
      let idx3 = i * num-v + next-j
      faces.push((idx0, idx1, idx2, idx3))
    }
  }

  // Import draw-polyhedron dynamically or via polyhedra
  let solid = (vertices: vertices, faces: faces, center: center)
  // We call culling and drawing
  let culled = cull-polyhedron(vertices, faces, cam-obj)
  let pts2d = project-pts(vertices, cam-obj)
  let d = cetz.draw

  let base-color = if palette == "gold" { rgb("fef08a") } else if palette == "emerald" { rgb("a7f3d0") } else { rgb("bae6fd") }
  let l-unit = vec3-unit((-0.6, -0.7, 0.9))

  let sorted-front = culled.front-faces.map(f-idx => {
    let f = faces.at(f-idx)
    let f-center = vec3-barycenter(f.map(k => vertices.at(k)))
    let depth = vec3-dot(f-center, cam-obj.view-dir)
    (f-idx: f-idx, depth: depth, f: f)
  }).sorted(key: item => item.depth)

  for item in sorted-front {
    let f = item.f
    let face-pts2d = f.map(k => pts2d.at(k))
    let norm = face-normal(f, vertices, poly-center: center)
    let cos-val = vec3-dot(norm, l-unit)
    let intensity = calc.max(0.2, calc.min(1.0, 0.4 + 0.6 * cos-val))
    let f-color = if intensity >= 0.7 {
      base-color.lighten((intensity - 0.7) / 0.3 * 25%)
    } else {
      base-color.darken((0.7 - intensity) / 0.7 * 40%)
    }
    d.line(..face-pts2d, close: true, stroke: stroke, fill: f-color)
  }
}

// ─────────────────────────────────────────────────────────────
// 7. CÁC HÀM BAO ĐÓNG CANVAS ĐỘC LẬP (-FIG)
// ─────────────────────────────────────────────────────────────

#let sphere-fig(..args) = cetz.canvas({ draw-sphere(..args) })
#let cylinder-fig(..args) = cetz.canvas({ draw-cylinder3d(..args) })
#let cone-fig(..args) = cetz.canvas({ draw-cone3d(..args) })
#let torus-fig(..args) = cetz.canvas({ draw-torus3d(..args) })
#let helix-fig(..args) = cetz.canvas({ draw-helix3d(..args) })
