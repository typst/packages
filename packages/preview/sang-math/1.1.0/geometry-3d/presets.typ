// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / PRESETS.TYP — Các Mô Hình Dựng Sẵn Mở Rộng Toán & Vật Lý
// Chuẩn xác theo tham chiếu Luadraw (Chùm đèn n đỉnh & Cắt cầu góc alpha)
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "vec3.typ": *
#import "camera.typ": *
#import "objects3d.typ": *
#import "solvers3d.typ": *
#import "curved3d.typ": *
#import "polyhedra.typ": *
#import "annotations3d.typ": *

/// Preset Mô hình Chùm Đèn Treo n Đỉnh (Tái hiện chuẩn xác bài toán Luadraw trên Facebook)
/// Chao đèn hình chỏm cầu, treo bởi n sợi dây từ đỉnh S chịu n vector lực F_i
///
/// - n: Số sợi dây treo / số đỉnh đa giác đều (3, 4, 5, 6, 8...)
/// - R: Bán kính mặt cầu tạo chao đèn (mặc định: 3.0)
/// - z-cut: Cao độ mặt phẳng cắt ngang miệng chao (mặc định: -1.0)
/// - S-height: Chiều cao điểm treo S (mặc định: 4.2)
/// - cam: Đối tượng Camera
/// - shading: Dải màu thân chao ("orange" | "blue" | "emerald"...)
/// - show-forces: Vẽ các vector lực căng dây F_i
/// - force-scale: Chiều dài vector lực (mặc định: 1.4)
/// - labels: Danh sách tên đỉnh (mặc định: ("A", "B", "C", "D", "E", "F", "G", "H"))
#let preset-chum-den(
  n: 3,
  R: 3.0,
  z-cut: none,
  h-cut: none,
  S-height: 4.2,
  cam: none,
  shading: "orange",
  show-forces: true,
  force-scale: 1.4,
  labels: ("A", "B", "C", "D", "E", "F", "G", "H"),
  phase: none,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none {
    make-camera(elevation: 20deg, azimuth: 35deg, scale: 1.0)
  } else {
    cam
  }

  let z-cut-val = if z-cut != none {
    z-cut
  } else if h-cut != none {
    -h-cut
  } else {
    -1.0
  }

  // 1. Tạo mặt cầu và mặt phẳng cắt
  let S-sphere = sphere((0.0, 0.0, 0.0), R)
  let P-cut = plane((0.0, 0.0, z-cut-val), (0.0, 0.0, 1.0))
  let cut = cut-sphere(S-sphere, P-cut, keep: "below")

  // 2. Vẽ chao đèn chỏm cầu với đổ bóng 3D chân thực
  draw-cut-sphere(cut: cut, cam: cam-obj, shading: shading)

  // 3. Tọa độ đỉnh treo S
  let S = (0.0, 0.0, S-height)
  draw-point3d(S, cam: cam-obj, radius: 2.2pt, label: [$S$], anchor: "south", offset: (0.0, 0.15))

  // 4. Lấy n đỉnh trên vành chao đèn theo thuật toán đa giác đều
  let def-phase = if phase != none {
    phase
  } else if n == 3 {
    -35deg
  } else if n == 4 {
    15deg
  } else {
    0deg
  }

  let rim-pts = cut-rim-points(cut, n, phase: def-phase)

  // 5. Vẽ các dây treo, đỉnh và vector lực
  for i in range(n) {
    let Pi = rim-pts.at(i)
    let lbl-name = if i < labels.len() { labels.at(i) } else { "A" + str(i + 1) }

    // Dây treo S -> Pi
    draw-segment3d(S, Pi, cam: cam-obj, stroke: 0.65pt + black)

    // Đỉnh trên vành chao
    let (u, v) = project-pt(Pi, cam-obj)
    let c2d = project-pt(cut.rim-center, cam-obj)
    let anchor-pos = if v < c2d.at(1) { "north" } else { "south" }
    let y-off = if v < c2d.at(1) { -0.18 } else { 0.15 }
    let x-off = if u > c2d.at(0) { 0.12 } else { -0.12 }

    draw-point3d(
      Pi,
      cam: cam-obj,
      radius: 2.0pt,
      label: lbl-name,
      anchor: anchor-pos,
      offset: (x-off, y-off),
      text-size: 8.5pt,
    )

    // Vector lực căng dây F_i (đặt ở khoảng 40% - 70% chiều dài dây treo)
    if show-forces {
      let f-start = vec3-lerp(S, Pi, 0.38)
      let f-end = vec3-lerp(S, Pi, 0.68)
      let side = if u >= c2d.at(0) { "right" } else { "left" }
      draw-vector3d(
        f-start,
        f-end,
        cam: cam-obj,
        stroke: 0.95pt + black,
        label: $arrow(F)_#(i + 1)$,
        label-pos: 0.75,
        label-side: side,
        label-dist: 0.22,
      )
    }
  }
}

/// Preset Mô hình Mặt Cầu Cắt Góc Alpha tại Tâm (Tái hiện chuẩn xác hình 1 bài đăng Facebook)
/// Khối cầu tâm O, mặt phẳng cắt phía trên, bán kính nét đứt OA, OB, góc alpha tại tâm
#let preset-sphere-cut-alpha(
  R: 2.8,
  z-cut: none,
  h-cut: none,
  cam: none,
  shading: "orange",
  alpha-label: [$alpha$],
) = {
  let d = cetz.draw
  let cam-obj = if cam == none {
    make-camera(elevation: 20deg, azimuth: 35deg, scale: 1.0)
  } else {
    cam
  }

  let z-cut-val = if z-cut != none {
    z-cut
  } else if h-cut != none {
    h-cut
  } else {
    1.6
  }

  let O = (0.0, 0.0, 0.0)
  let S = sphere(O, R)
  let P = plane((0.0, 0.0, z-cut-val), (0.0, 0.0, 1.0))
  let cut = cut-sphere(S, P, keep: "below")

  // 1. Vẽ khối cầu cắt với đổ bóng 3D chân thực
  draw-cut-sphere(cut: cut, cam: cam-obj, shading: shading)

  // 2. Điểm tâm O
  draw-point3d(O, cam: cam-obj, radius: 2.2pt, label: [$O$], anchor: "north", offset: (0.0, -0.22))

  // 3. Hai điểm A và B trên vành miệng cắt
  let A = cut-rim-point(cut, 150deg)
  let B = cut-rim-point(cut, 30deg)

  // 4. Đoạn thẳng nét đứt OA, OB
  draw-segment3d(O, A, cam: cam-obj, stroke: (paint: black, thickness: 0.75pt, dash: "dashed"))
  draw-segment3d(O, B, cam: cam-obj, stroke: (paint: black, thickness: 0.75pt, dash: "dashed"))

  draw-point3d(A, cam: cam-obj, radius: 1.8pt, label: [$A$], anchor: "east", offset: (-0.12, 0.0))

  // 5. Cung đo góc alpha tại tâm O
  draw-angle-arc3d(B, O, A, cam: cam-obj, radius: 0.6, label: alpha-label, stroke: 0.75pt + black)
}

/// Preset Mô hình Giao Tuyến Hai Mặt Cầu (Two Intersecting Spheres)
/// Minh họa tính toán hình học giải tích tự động: tìm đường tròn giao tuyến
#let preset-two-spheres-intersection(
  S1: sphere((-1.5, 0.0, 0.0), 2.2),
  S2: sphere((1.2, 0.0, 0.0), 1.8),
  cam: none,
) = {
  let cam-obj = if cam == none { make-camera(elevation: 20deg, azimuth: 35deg) } else { cam }

  // 1. Tính toán đường tròn giao tuyến bằng solver
  let inter = inter-sphere-sphere(S1, S2)

  // 2. Vẽ 2 mặt cầu
  draw-sphere(center: S1.center, radius: S1.radius, cam: cam-obj, shading: "orange")
  draw-sphere(center: S2.center, radius: S2.radius, cam: cam-obj, shading: "blue")

  // 3. Nếu cắt nhau, vẽ đường tròn giao tuyến
  if inter.type == "circle3d" {
    draw-circle3d(
      inter.center,
      inter.radius,
      inter.normal,
      cam: cam-obj,
      stroke-visible: 1.2pt + rgb("dc2626"),
      stroke-hidden: (paint: rgb("dc2626"), thickness: 0.8pt, dash: "dashed"),
    )
  }

  // 4. Đường nối tâm
  draw-segment3d(S1.center, S2.center, cam: cam-obj, stroke: (paint: black, thickness: 0.7pt, dash: "dashed"))
  draw-point3d(S1.center, cam: cam-obj, label: [$O_1$], anchor: "north", offset: (0.0, -0.2))
  draw-point3d(S2.center, cam: cam-obj, label: [$O_2$], anchor: "north", offset: (0.0, -0.2))
}

// Các hàm bao đóng canvas độc lập (-fig):
#let preset-chum-den-fig(..args) = cetz.canvas({ preset-chum-den(..args) })
#let preset-sphere-cut-alpha-fig(..args) = cetz.canvas({ preset-sphere-cut-alpha(..args) })
#let preset-two-spheres-intersection-fig(..args) = cetz.canvas({ preset-two-spheres-intersection(..args) })
