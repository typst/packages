// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / POLYHEDRA.TYP — Dựng hình khối đa diện tự động
// Hỗ trợ 5 khối đa diện đều Platon, khối Archimedes, chóp, lăng trụ
// Tự động phân tích khử nét khuất (Back-face Culling) & Đổ bóng Lambertian
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "vec3.typ": *
#import "camera.typ": *
#import "culling.typ": *

// ─────────────────────────────────────────────────────────────
// 1. CÁC HÀM TẠO 5 KHỐI ĐA DIỆN ĐỀU PLATON & ARCHIMEDES
// (Tọa độ giải tích chuẩn xác theo luadraw / Patrick Fradin)
// ─────────────────────────────────────────────────────────────

/// 1. Tứ diện đều (Regular Tetrahedron) — 4 đỉnh, 4 mặt tam giác đều
#let make-tetrahedron(center: (0.0, 0.0, 0.0), radius: 2.5) = {
  let s = radius / calc.sqrt(3.0)
  let raw = (
    (-1.0, -1.0, 1.0),
    (1.0, 1.0, 1.0),
    (-1.0, 1.0, -1.0),
    (1.0, -1.0, -1.0),
  )
  let vertices = raw.map(p => vec3-add(center, vec3-scale(p, s)))
  let faces = (
    (0, 1, 2),
    (0, 2, 3),
    (0, 3, 1),
    (1, 3, 2),
  )
  (
    type: "tetrahedron",
    vertices: vertices,
    faces: faces,
    center: center,
    radius: radius,
  )
}

/// 2. Hình lập phương (Cube / Hexahedron) — 8 đỉnh, 6 mặt vuông
#let make-cube(center: (0.0, 0.0, 0.0), size: 2.8, radius: none) = {
  let h = if radius != none { radius / calc.sqrt(3.0) } else { size / 2.0 }
  let raw = (
    (-h, -h, -h), // 0
    (h, -h, -h),  // 1
    (h, h, -h),   // 2
    (-h, h, -h),  // 3
    (-h, -h, h),  // 4
    (h, -h, h),   // 5
    (h, h, h),    // 6
    (-h, h, h),   // 7
  )
  let vertices = raw.map(p => vec3-add(center, p))
  let faces = (
    (0, 3, 2, 1), // Đáy dưới (z = -h)
    (4, 5, 6, 7), // Đáy trên (z = +h)
    (0, 1, 5, 4), // Mặt trước (y = -h)
    (1, 2, 6, 5), // Mặt phải (x = +h)
    (2, 3, 7, 6), // Mặt sau (y = +h)
    (3, 0, 4, 7), // Mặt trái (x = -h)
  )
  (
    type: "cube",
    vertices: vertices,
    faces: faces,
    center: center,
    size: h * 2.0,
  )
}

/// 3. Bát diện đều (Regular Octahedron) — 6 đỉnh, 8 mặt tam giác đều
#let make-octahedron(center: (0.0, 0.0, 0.0), radius: 2.5) = {
  let raw = (
    (0.0, 0.0, radius),   // 0: Đỉnh trên
    (-radius, 0.0, 0.0),  // 1: Trái
    (0.0, radius, 0.0),   // 2: Sau
    (0.0, -radius, 0.0),  // 3: Trước
    (radius, 0.0, 0.0),   // 4: Phải
    (0.0, 0.0, -radius),  // 5: Đỉnh dưới
  )
  let vertices = raw.map(p => vec3-add(center, p))
  let faces = (
    (0, 4, 2),
    (0, 2, 1),
    (0, 1, 3),
    (0, 3, 4),
    (5, 2, 4),
    (5, 1, 2),
    (5, 3, 1),
    (5, 4, 3),
  )
  (
    type: "octahedron",
    vertices: vertices,
    faces: faces,
    center: center,
    radius: radius,
  )
}

/// 4. Khối 20 mặt đều (Regular Icosahedron) — 12 đỉnh, 20 mặt tam giác đều
#let make-icosahedron(center: (0.0, 0.0, 0.0), radius: 2.5) = {
  let p = (1.0 + calc.sqrt(5.0)) / 2.0
  let norm = calc.sqrt(1.0 + p * p)
  let s = radius / norm
  let raw = (
    (-1.0, 0.0, p),   // 0
    (1.0, 0.0, p),    // 1
    (0.0, p, 1.0),    // 2
    (0.0, -p, 1.0),   // 3
    (-p, 1.0, 0.0),   // 4
    (-p, -1.0, 0.0),  // 5
    (p, 1.0, 0.0),    // 6
    (p, -1.0, 0.0),   // 7
    (0.0, p, -1.0),   // 8
    (0.0, -p, -1.0),  // 9
    (-1.0, 0.0, -p),  // 10
    (1.0, 0.0, -p),   // 11
  )
  let vertices = raw.map(pt => vec3-add(center, vec3-scale(pt, s)))
  let faces = (
    (0, 1, 2), (0, 2, 4), (0, 4, 5), (0, 5, 3), (0, 3, 1),
    (4, 10, 5), (5, 10, 9), (9, 3, 5), (3, 9, 7), (3, 7, 1),
    (1, 7, 6), (1, 6, 2), (2, 6, 8), (2, 8, 4), (4, 8, 10),
    (11, 6, 7), (11, 7, 9), (11, 8, 6), (11, 9, 10), (11, 10, 8),
  )
  (
    type: "icosahedron",
    vertices: vertices,
    faces: faces,
    center: center,
    radius: radius,
  )
}

/// 5. Khối 12 mặt đều (Regular Dodecahedron) — 20 đỉnh, 12 mặt ngũ giác đều
#let make-dodecahedron(center: (0.0, 0.0, 0.0), radius: 2.5) = {
  let p = (1.0 + calc.sqrt(5.0)) / 2.0
  let q = (calc.sqrt(5.0) - 1.0) / 2.0
  let s = radius / calc.sqrt(3.0)
  let raw = (
    (-q, 0.0, p),    // 0
    (q, 0.0, p),     // 1
    (-1.0, 1.0, 1.0),// 2
    (-1.0, -1.0, 1.0),// 3
    (1.0, 1.0, 1.0), // 4
    (1.0, -1.0, 1.0),// 5
    (0.0, p, q),     // 6
    (0.0, -p, q),    // 7
    (-p, q, 0.0),    // 8
    (-p, -q, 0.0),   // 9
    (p, q, 0.0),     // 10
    (p, -q, 0.0),    // 11
    (0.0, p, -q),    // 12
    (0.0, -p, -q),   // 13
    (-1.0, 1.0, -1.0),// 14
    (-1.0, -1.0, -1.0),// 15
    (1.0, 1.0, -1.0),// 16
    (1.0, -1.0, -1.0),// 17
    (-q, 0.0, -p),   // 18
    (q, 0.0, -p),    // 19
  )
  let vertices = raw.map(pt => vec3-add(center, vec3-scale(pt, s)))
  let faces = (
    (0, 1, 4, 6, 2),
    (0, 2, 8, 9, 3),
    (0, 3, 7, 5, 1),
    (1, 5, 11, 10, 4),
    (14, 12, 16, 19, 18),
    (15, 9, 8, 14, 18),
    (19, 17, 13, 15, 18),
    (16, 10, 11, 17, 19),
    (15, 13, 7, 3, 9),
    (11, 5, 7, 13, 17),
    (8, 2, 6, 12, 14),
    (16, 12, 6, 4, 10),
  )
  (
    type: "dodecahedron",
    vertices: vertices,
    faces: faces,
    center: center,
    radius: radius,
  )
}

/// 6. Khối Cuboctahedron (Bán đều Archimedes) — 12 đỉnh, 8 tam giác & 6 hình vuông
#let make-cuboctahedron(center: (0.0, 0.0, 0.0), radius: 2.5) = {
  let c0 = radius * calc.sqrt(2.0) / 2.0
  let raw = (
    (c0, 0.0, c0),   // 0
    (c0, 0.0, -c0),  // 1
    (-c0, 0.0, c0),  // 2
    (-c0, 0.0, -c0), // 3
    (c0, c0, 0.0),   // 4
    (c0, -c0, 0.0),  // 5
    (-c0, c0, 0.0),  // 6
    (-c0, -c0, 0.0), // 7
    (0.0, c0, c0),   // 8
    (0.0, c0, -c0),  // 9
    (0.0, -c0, c0),  // 10
    (0.0, -c0, -c0), // 11
  )
  let vertices = raw.map(p => vec3-add(center, p))
  let faces = (
    // 6 mặt vuông
    (0, 5, 1, 4),
    (0, 8, 2, 10),
    (7, 2, 6, 3),
    (7, 11, 5, 10),
    (9, 1, 11, 3),
    (9, 6, 8, 4),
    // 8 mặt tam giác
    (0, 4, 8),
    (1, 5, 11),
    (2, 7, 10),
    (3, 6, 9),
    (4, 1, 9),
    (5, 0, 10),
    (6, 2, 8),
    (7, 3, 11),
  )
  (
    type: "cuboctahedron",
    vertices: vertices,
    faces: faces,
    center: center,
    radius: radius,
  )
}

// ─────────────────────────────────────────────────────────────
// 2. CÁC HÀM TẠO CHÓP & LĂNG TRỤ TỔNG QUÁT
// ─────────────────────────────────────────────────────────────

/// Tạo cấu trúc chóp từ đa giác đáy bất kỳ và đỉnh apex S
#let make-pyramid(base-vertices, apex) = {
  let vertices = (apex,) + base-vertices
  let n = base-vertices.len()

  let faces = ()
  // 1. Mặt đáy: (1, 2, ..., n)
  let base-face = range(1, n + 1)
  faces.push(base-face)

  // 2. Các mặt bên: tam giác (0, i, next_i)
  for i in range(1, n + 1) {
    let next-i = if i == n { 1 } else { i + 1 }
    faces.push((0, i, next-i))
  }

  (
    type: "pyramid",
    vertices: vertices,
    faces: faces,
  )
}

/// Tạo cấu trúc chóp đều n đỉnh (đáy nằm trên z = 0)
#let make-pyramid-n(n: 4, radius: 2.6, height: 3.6, center: (0.0, 0.0, 0.0), apex-shift: (0.0, 0.0), start-angle: 0deg) = {
  let base-pts = ()
  for i in range(n) {
    let ang = start-angle + (2 * calc.pi * i / n) * 1rad
    let x = center.at(0) + radius * calc.cos(ang)
    let y = center.at(1) + radius * calc.sin(ang)
    let z = center.at(2)
    base-pts.push((x, y, z))
  }
  let apex = (
    center.at(0) + apex-shift.at(0),
    center.at(1) + apex-shift.at(1),
    center.at(2) + height,
  )
  make-pyramid(base-pts, apex)
}

/// Tạo cấu trúc lăng trụ từ đa giác đáy và vector chiều cao/xiên
#let make-prism(base-vertices, dir-vector) = {
  let n = base-vertices.len()
  let top-vertices = base-vertices.map(p => vec3-add(p, dir-vector))
  let vertices = base-vertices + top-vertices

  let faces = ()
  // Đáy dưới: 0 .. n-1
  faces.push(range(0, n))
  // Đáy trên: n .. 2n-1
  faces.push(range(n, 2 * n).rev())

  // Các mặt bên (hình bình hành 4 đỉnh)
  for i in range(n) {
    let next-i = calc.rem(i + 1, n)
    faces.push((i, next-i, next-i + n, i + n))
  }

  (
    type: "prism",
    vertices: vertices,
    faces: faces,
  )
}

/// Tạo cấu trúc lăng trụ đều n cạnh
#let make-prism-n(n: 3, radius: 2.2, height: 3.5, center: (0.0, 0.0, 0.0), start-angle: 0deg) = {
  let base-pts = ()
  for i in range(n) {
    let ang = start-angle + (2 * calc.pi * i / n) * 1rad
    let x = center.at(0) + radius * calc.cos(ang)
    let y = center.at(1) + radius * calc.sin(ang)
    let z = center.at(2)
    base-pts.push((x, y, z))
  }
  make-prism(base-pts, (0.0, 0.0, height))
}

/// Tạo cấu trúc hình hộp chữ nhật / lập phương tổng quát
#let make-box(size: (3.2, 2.6, 2.2), center: (0.0, 0.0, 0.0)) = {
  let (dx, dy, dz) = size
  let hx = dx / 2.0; let hy = dy / 2.0; let hz = dz / 2.0
  let (cx, cy, cz) = center

  let vertices = (
    (cx - hx, cy - hy, cz - hz), // 0
    (cx + hx, cy - hy, cz - hz), // 1
    (cx + hx, cy + hy, cz - hz), // 2
    (cx - hx, cy + hy, cz - hz), // 3
    (cx - hx, cy - hy, cz + hz), // 4
    (cx + hx, cy - hy, cz + hz), // 5
    (cx + hx, cy + hy, cz + hz), // 6
    (cx - hx, cy + hy, cz + hz), // 7
  )

  let faces = (
    (0, 3, 2, 1), // Đáy dưới
    (4, 5, 6, 7), // Đáy trên
    (0, 1, 5, 4), // Mặt trước
    (1, 2, 6, 5), // Mặt phải
    (2, 3, 7, 6), // Mặt sau
    (3, 0, 4, 7), // Mặt trái
  )

  (
    type: "box",
    vertices: vertices,
    faces: faces,
    center: center,
  )
}

// ─────────────────────────────────────────────────────────────
// 3. ĐỘNG CƠ VẼ ĐA DIỆN TỰ ĐỘNG KHỬ NÉT KHUẤT & ĐỔ BÓNG LAMBERTIAN
// ─────────────────────────────────────────────────────────────

/// Vẽ khối đa diện tự động khử nét khuất và đổ bóng 3D chân thực
///
/// - solid: Đối tượng đa diện (gồm vertices và faces)
/// - cam: Camera 3D (mặc định elevation: 20deg, azimuth: 35deg)
/// - stroke-visible: Nét vẽ các cạnh nhìn thấy (mặc định: 0.95pt + black)
/// - stroke-hidden: Nét vẽ các cạnh bị khuất (mặc định nét đứt màu xám nhạt)
/// - fill-faces: Màu tô đơn sắc hoặc none
/// - shading: Bật đổ bóng Lambertian theo hướng sáng ("blue", "orange", "emerald", "violet", "gold", "gray" hoặc true/false)
/// - light-dir: Vector hướng nguồn sáng (mặc định: (-0.6, -0.7, 0.9) chiếu từ trên trái xuống)
/// - draw-vertices: Chấm các điểm đỉnh (mặc định: true)
/// - vertex-radius: Bán kính điểm đỉnh (mặc định: 2pt)
/// - them: Hàm hook callback `them: d => { ... }` nhận thông tin đa diện để vẽ thêm
#let draw-polyhedron(
  solid,
  cam: none,
  stroke-visible: 0.95pt + black,
  stroke-hidden: (paint: rgb("94a3b8"), thickness: 0.75pt, dash: "dashed"),
  fill-faces: none,
  shading: true,
  palette: "blue",
  light-dir: (-0.6, -0.7, 0.9),
  draw-vertices: true,
  vertex-radius: 2pt,
  them: none,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera(elevation: 20deg, azimuth: 35deg) } else { cam }
  let vertices = solid.vertices
  let faces = solid.faces
  let poly-center = if "center" in solid { solid.center } else { vec3-barycenter(vertices) }

  // 1. Phân loại nét khuất/thấy bằng thuật toán culling
  let culled = cull-polyhedron(vertices, faces, cam-obj)

  // 2. Chiếu tất cả đỉnh sang tọa độ 2D của canvas
  let pts2d = project-pts(vertices, cam-obj)

  // 3. Bảng màu cơ sở cho shading
  let base-color = if type(fill-faces) == color {
    fill-faces
  } else if palette == "blue" {
    rgb("bae6fd")
  } else if palette == "orange" {
    rgb("fed7aa")
  } else if palette == "emerald" {
    rgb("a7f3d0")
  } else if palette == "violet" {
    rgb("e9d5ff")
  } else if palette == "gold" {
    rgb("fef08a")
  } else {
    rgb("e2e8f0")
  }

  let l-unit = vec3-unit(light-dir)

  // 4. Vẽ và tô màu các mặt nhìn thấy (Front faces) theo thứ tự chiều sâu
  // Sắp xếp các mặt theo khoảng cách tâm mặt đến camera để tránh đè lỗi (Painter's algorithm)
  let sorted-front = culled.front-faces.map(f-idx => {
    let f = faces.at(f-idx)
    let f-center = vec3-barycenter(f.map(i => vertices.at(i)))
    let depth = vec3-dot(f-center, cam-obj.view-dir)
    (f-idx: f-idx, depth: depth, f: f)
  }).sorted(key: item => item.depth)

  for item in sorted-front {
    let f-idx = item.f-idx
    let f = item.f
    let face-pts2d = f.map(i => pts2d.at(i))

    let f-color = none
    if shading != false and shading != none {
      // Tính độ chiếu sáng Lambertian: cos(theta) = norm . light
      let norm = face-normal(f, vertices, poly-center: poly-center)
      let cos-val = vec3-dot(norm, l-unit)
      let intensity = calc.max(0.2, calc.min(1.0, 0.4 + 0.6 * cos-val))
      if intensity >= 0.7 {
        f-color = base-color.lighten((intensity - 0.7) / 0.3 * 22%)
      } else {
        f-color = base-color.darken((0.7 - intensity) / 0.7 * 38%)
      }
    } else if fill-faces != none {
      f-color = fill-faces
    }

    if f-color != none {
      d.line(..face-pts2d, close: true, stroke: none, fill: f-color)
    }
  }

  // 5. Vẽ các cạnh khuất (Nét đứt)
  if stroke-hidden != none {
    for (u, v) in culled.hidden-edges {
      d.line(pts2d.at(u), pts2d.at(v), stroke: stroke-hidden)
    }
  }

  // 6. Vẽ các cạnh nhìn thấy (Nét liền)
  for (u, v) in culled.visible-edges {
    d.line(pts2d.at(u), pts2d.at(v), stroke: stroke-visible)
  }

  // 7. Vẽ các điểm đỉnh nếu bật (chỉ vẽ các đỉnh nhìn thấy để bề mặt sạch đẹp)
  if draw-vertices != false and draw-vertices != none {
    let vis-v-indices = ()
    for (u, v) in culled.visible-edges {
      if u not in vis-v-indices { vis-v-indices.push(u) }
      if v not in vis-v-indices { vis-v-indices.push(v) }
    }
    let target-indices = if draw-vertices == "all" { range(vertices.len()) } else { vis-v-indices }
    for idx in target-indices {
      d.circle(pts2d.at(idx), radius: vertex-radius, fill: black, stroke: none)
    }
  }

  // 8. Gọi hook them nếu có
  if them != none {
    them((
      vertices: vertices,
      pts2d: pts2d,
      faces: faces,
      cam: cam-obj,
      cull: culled,
      d: d,
    ))
  }
}

// ─────────────────────────────────────────────────────────────
// 4. BỘ HÀM FIG ĐỘC LẬP CHO 5 KHỐI PLATON & CÁC ĐA DIỆN
// (Cú pháp 1 dòng, sẵn sàng chèn ngay vào bài giảng & đề thi)
// ─────────────────────────────────────────────────────────────

#let tetrahedron-fig(center: (0.0, 0.0, 0.0), radius: 2.5, cam: none, palette: "orange", ..args) = cetz.canvas({
  let poly = make-tetrahedron(center: center, radius: radius)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let cube-fig(center: (0.0, 0.0, 0.0), size: 2.8, cam: none, palette: "blue", ..args) = cetz.canvas({
  let poly = make-cube(center: center, size: size)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let octahedron-fig(center: (0.0, 0.0, 0.0), radius: 2.5, cam: none, palette: "emerald", ..args) = cetz.canvas({
  let poly = make-octahedron(center: center, radius: radius)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let dodecahedron-fig(center: (0.0, 0.0, 0.0), radius: 2.5, cam: none, palette: "violet", ..args) = cetz.canvas({
  let poly = make-dodecahedron(center: center, radius: radius)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let icosahedron-fig(center: (0.0, 0.0, 0.0), radius: 2.5, cam: none, palette: "gold", ..args) = cetz.canvas({
  let poly = make-icosahedron(center: center, radius: radius)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let cuboctahedron-fig(center: (0.0, 0.0, 0.0), radius: 2.5, cam: none, palette: "blue", ..args) = cetz.canvas({
  let poly = make-cuboctahedron(center: center, radius: radius)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let pyramid-fig(n: 4, radius: 2.6, height: 3.5, cam: none, palette: "blue", ..args) = cetz.canvas({
  let poly = make-pyramid-n(n: n, radius: radius, height: height)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

#let prism-fig(n: 3, radius: 2.2, height: 3.5, cam: none, palette: "emerald", ..args) = cetz.canvas({
  let poly = make-prism-n(n: n, radius: radius, height: height)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})

/// Tạo cấu trúc khối chóp đôi đều n cạnh (Bipyramid)
#let make-bipyramid-n(n: 5, radius: 2.2, height: 3.5, center: (0.0, 0.0, 0.0), start-angle: 0deg) = {
  let h2 = height / 2.0
  let apex-top = vec3-add(center, (0.0, 0.0, h2))
  let apex-bot = vec3-add(center, (0.0, 0.0, -h2))

  let base-pts = ()
  for i in range(n) {
    let ang = start-angle + (2 * calc.pi * i / n) * 1rad
    let x = center.at(0) + radius * calc.cos(ang)
    let y = center.at(1) + radius * calc.sin(ang)
    let z = center.at(2)
    base-pts.push((x, y, z))
  }

  let vertices = (apex-top, apex-bot) + base-pts
  let faces = ()

  // n mặt tam giác trên
  for i in range(n) {
    let next-i = calc.rem(i + 1, n)
    faces.push((0, 2 + i, 2 + next-i))
  }
  // n mặt tam giác dưới
  for i in range(n) {
    let next-i = calc.rem(i + 1, n)
    faces.push((1, 2 + next-i, 2 + i))
  }

  (
    type: "bipyramid",
    vertices: vertices,
    faces: faces,
    center: center,
  )
}

#let bipyramid-fig(n: 5, radius: 2.2, height: 3.5, cam: none, palette: "emerald", ..args) = cetz.canvas({
  let poly = make-bipyramid-n(n: n, radius: radius, height: height)
  draw-polyhedron(poly, cam: cam, palette: palette, ..args)
})
