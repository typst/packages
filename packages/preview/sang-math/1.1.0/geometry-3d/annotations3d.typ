// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / ANNOTATIONS3D.TYP — Điểm, Nhãn, Vector & Ký hiệu góc 3D
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "vec3.typ": *
#import "camera.typ": *

/// Vẽ điểm 3D và gán nhãn toán học
///
/// - p: Tọa độ 3D (x, y, z)
/// - cam: Camera 3D
/// - label: Nội dung nhãn (content hoặc str, ví dụ [$S$], [$A$])
/// - anchor: Vị trí neo nhãn so với điểm ("north", "south", "west", "east", "south-east"...)
/// - offset: Độ dịch chuyển nhãn (dx, dy) tính bằng cm/pt
/// - radius: Bán kính dấu chấm đỉnh (2.0pt)
/// - fill: Màu dấu chấm đỉnh (black)
#let draw-point3d(
  p,
  cam: none,
  label: none,
  anchor: "north",
  offset: (0.0, 0.0),
  radius: 2.2pt,
  fill: black,
  text-size: 9pt,
  text-weight: "bold",
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }
  let (u, v) = project-pt(p, cam-obj)

  // Vẽ chấm tròn tại điểm
  if radius > 0pt {
    d.circle((u, v), radius: radius, fill: fill, stroke: none)
  }

  // Vẽ nhãn văn bản
  if label != none {
    let lbl-pos = (u + offset.at(0), v + offset.at(1))
    d.content(
      lbl-pos,
      anchor: anchor,
      text(size: text-size, weight: text-weight)[#label]
    )
  }
}

/// Vẽ đoạn thẳng 3D giữa 2 điểm
#let draw-segment3d(
  start,
  end,
  cam: none,
  stroke: 0.8pt + black,
  label: none,
  label-anchor: "west",
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }
  let p1 = project-pt(start, cam-obj)
  let p2 = project-pt(end, cam-obj)

  d.line(p1, p2, stroke: stroke)

  if label != none {
    let mid = ((p1.at(0) + p2.at(0)) / 2.0, (p1.at(1) + p2.at(1)) / 2.0)
    d.content(mid, anchor: label-anchor)[#label]
  }
}

/// Vẽ Vector 3D có mũi tên và nhãn toán học
///
/// - start: Điểm gốc (x, y, z)
/// - end: Điểm ngọn (x, y, z)
/// - cam: Camera 3D
/// - stroke: Màu và độ dày nét vẽ vector
/// - mark-size: Kích thước đầu mũi tên
/// - label: Nhãn toán học (ví dụ [$arrow(F)_1$])
/// - label-side: "right" | "left" | "top" | "bottom"
#let draw-vector3d(
  start,
  end,
  cam: none,
  stroke: 0.9pt + black,
  mark-fill: black,
  mark-size: 0.16,
  label: none,
  label-pos: 0.6,
  label-side: "right",
  label-dist: 0.22,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }
  let p1 = project-pt(start, cam-obj)
  let p2 = project-pt(end, cam-obj)

  d.line(
    p1, p2,
    stroke: stroke,
    mark: (end: "stealth", fill: mark-fill, size: mark-size),
  )

  if label != none {
    let vx = p2.at(0) - p1.at(0)
    let vy = p2.at(1) - p1.at(1)
    let len = calc.sqrt(vx * vx + vy * vy)
    if len > 1e-6 {
      let ux = vx / len
      let uy = vy / len
      // Pháp tuyến 2D bên phải
      let (nx, ny) = if label-side == "right" {
        (uy, -ux)
      } else if label-side == "left" {
        (-uy, ux)
      } else if label-side == "top" {
        (0.0, 1.0)
      } else {
        (0.0, -1.0)
      }

      let lx = p1.at(0) + label-pos * vx + nx * label-dist
      let ly = p1.at(1) + label-pos * vy + ny * label-dist
      d.content((lx, ly))[#label]
    }
  }
}

/// Đánh dấu góc vuông trong không gian 3D tại đỉnh O
/// Tự động biến dạng theo phép chiếu camera (thành hình bình hành chính xác toán học)
#let draw-right-angle3d(
  A,
  O,
  B,
  cam: none,
  size: 0.35,
  stroke: 0.8pt + black,
  fill: none,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }

  let u1 = vec3-unit(vec3-sub(A, O))
  let u2 = vec3-unit(vec3-sub(B, O))

  let P1 = vec3-add(O, vec3-scale(u1, size))
  let P2 = vec3-add(O, vec3-add(vec3-scale(u1, size), vec3-scale(u2, size)))
  let P3 = vec3-add(O, vec3-scale(u2, size))

  let pt-O = project-pt(O, cam-obj)
  let pt-1 = project-pt(P1, cam-obj)
  let pt-2 = project-pt(P2, cam-obj)
  let pt-3 = project-pt(P3, cam-obj)

  if fill != none {
    d.line(pt-O, pt-1, pt-2, pt-3, close: true, stroke: stroke, fill: fill)
  } else {
    d.line(pt-1, pt-2, pt-3, stroke: stroke)
  }
}

/// Đánh dấu cung tròn góc ∠AOB trong không gian 3D
#let draw-angle-arc3d(
  A,
  O,
  B,
  cam: none,
  radius: 0.6,
  label: none,
  stroke: 0.7pt + black,
  n-samples: 24,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }

  let u = vec3-unit(vec3-sub(A, O))
  let v-raw = vec3-sub(B, O)
  let v = vec3-unit(vec3-sub(v-raw, vec3-scale(u, vec3-dot(v-raw, u))))

  let total-angle = vec3-angle(vec3-sub(A, O), vec3-sub(B, O))

  let arc-pts2d = ()
  for i in range(n-samples + 1) {
    let t = i / n-samples
    let ang = t * total-angle
    let pt3d = vec3-add(O, vec3-add(vec3-scale(u, radius * calc.cos(ang)), vec3-scale(v, radius * calc.sin(ang))))
    arc-pts2d.push(project-pt(pt3d, cam-obj))
  }

  d.line(..arc-pts2d, stroke: stroke)

  if label != none {
    let mid-t = 0.5
    let mid-ang = mid-t * total-angle
    let lbl-pt3d = vec3-add(O, vec3-add(vec3-scale(u, (radius + 0.35) * calc.cos(mid-ang)), vec3-scale(v, (radius + 0.35) * calc.sin(mid-ang))))
    let lbl-pt2d = project-pt(lbl-pt3d, cam-obj)
    d.content(lbl-pt2d)[#label]
  }
}

/// Vẽ hệ trục tọa độ Oxyz trong không gian 3D
#let draw-axes3d(
  origin: (0.0, 0.0, 0.0),
  length: 3.2,
  cam: none,
  labels: ([$x$], [$y$], [$z$]),
  stroke: 0.9pt + black,
  show-origin: true,
) = {
  let d = cetz.draw
  let cam-obj = if cam == none { make-camera() } else { cam }

  let x-end = vec3-add(origin, (length, 0.0, 0.0))
  let y-end = vec3-add(origin, (0.0, length, 0.0))
  let z-end = vec3-add(origin, (0.0, 0.0, length))

  draw-vector3d(origin, x-end, cam: cam-obj, stroke: stroke, label: labels.at(0), label-pos: 1.08)
  draw-vector3d(origin, y-end, cam: cam-obj, stroke: stroke, label: labels.at(1), label-pos: 1.08)
  draw-vector3d(origin, z-end, cam: cam-obj, stroke: stroke, label: labels.at(2), label-pos: 1.08)

  if show-origin {
    draw-point3d(origin, cam: cam-obj, radius: 2.0pt, label: [$O$], anchor: "north-east", offset: (-0.1, -0.1))
  }
}
