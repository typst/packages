// ═══════════════════════════════════════════════════════════════
// GEOMETRY-3D / CURVES-3D.TYP — Đường cong trong không gian 3D
// (chiếu phối cảnh 2D để in ra giấy)
// ═══════════════════════════════════════════════════════════════
// Dùng: #import "geometry-3d/curves-3d.typ": *
//
// DANH SÁCH HÀM:
//   helix-points(...)       Trả về mảng tọa độ (x,y) của đường xoắn ốc
//   draw-helix(...)         Vẽ đường xoắn ốc (bọc helix-points)
//   draw-spring(...)        Vẽ lò xo (helix dày hơn, nhiều vòng hơn)
// ───────────────────────────────────────────────────────────────
// CÁCH DÙNG MẪU (bài kiến bò trên mặt trụ):
//
//   #import "@local/sang-math:1.0.1": *
//   #cetz.canvas(length: 0.8cm, {
//     import cetz.draw: *
//
//     // Vẽ khung trụ trước...
//     // Vẽ đường xoắn chỉ cần 1 dòng:
//     draw-helix(
//       center: (-8, 0),     // Tâm đáy dưới
//       radius: 2,           // Bán kính trụ
//       height: 8,           // Chiều cao trụ
//       loops: 1.5,          // 1.5 vòng xoắn
//       color: sm-red,
//     )
//   })
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "../core/math-utils.typ": linspace, lerp

// ── Hằng nội bộ ───────────────────────────────────────────────
// Tỉ lệ co theo trục Y để tạo ảo giác phối cảnh (ellipse đáy)
// 0.3 = đáy trụ trông như ellipse thoải nhẹ — cảm giác 3D tự nhiên
#let _PERSP-Y = 0.3

// ── HÀM DATA ──────────────────────────────────────────────────

/// Tính mảng tọa độ (x, y) chiếu phối cảnh của đường xoắn ốc.
/// Đây là hàm "data thuần" — không vẽ, chỉ trả về mảng điểm.
/// Người dùng có thể lấy ra để chỉnh sửa trước khi vẽ.
///
/// - center (array): Tọa độ tâm đáy dưới `(cx, cy)`. Mặc định: `(0, 0)`.
/// - radius (float): Bán kính của đường tròn đáy (trục X).
/// - height (float): Chiều cao tổng của đường xoắn.
/// - loops (float): Số vòng xoắn. Mặc định: `1`.
/// - steps (int): Số đoạn xấp xỉ. Mặc định: `60` (mỗi vòng = 60/loops điểm).
/// - persp-y (float): Tỉ lệ phối cảnh theo trục Y dọc (0.1–0.5). Mặc định: `0.3`.
/// - offset-angle (float): Góc bắt đầu tính bằng radian. Mặc định: `calc.pi` (bắt đầu từ điểm xa nhất).
/// → returns array of (float, float)
#let helix-points(
  center: (0, 0),
  radius: 1,
  height: 4,
  loops: 1,
  steps: 60,
  persp-y: 0.3,
  offset-angle: calc.pi,   // π = bắt đầu từ điểm trái nhất (xa người xem)
) = {
  let (cx, cy) = center
  let total-angle = loops * 2 * calc.pi
  let ts = linspace(0, 1, steps + 1)
  ts.map(t => {
    let angle = offset-angle + t * total-angle
    let x = cx + radius * calc.cos(angle)
    let y = cy + t * height + radius * persp-y * calc.sin(angle)
    (x, y)
  })
}

/// Chia mảng điểm helix thành các segment visible/hidden theo sin(angle).
/// Trả về tuple (vis-segs, hid-segs): mỗi seg là mảng điểm.
/// Lưu ý: Typst array là immutable, dùng += (item,) để thêm phần tử.
///
/// - pts (array): Mảng tọa độ từ helix-points.
/// - loops (float): Số vòng xoắn.
/// - offset-angle (float): Góc bắt đầu khớp với helix-points.
#let helix-split-visible(pts, loops: 1, offset-angle: calc.pi) = {
  let n = pts.len()
  let total-angle = loops * 2 * calc.pi
  let vis-segs = ()
  let hid-segs = ()
  let cur = ()
  let cur-front = none

  for i in range(0, n) {
    let t = if n > 1 { i / (n - 1) } else { 0.0 }
    let angle = offset-angle + t * total-angle
    let is-front = calc.sin(angle) >= 0
    let pt = pts.at(i)

    if cur-front == none {
      cur = (pt,)
      cur-front = is-front
    } else if is-front == cur-front {
      cur += (pt,)
    } else {
      // Thêm điểm giao để các segment nối liền nhau
      cur += (pt,)
      if cur.len() >= 2 {
        if cur-front { vis-segs += (cur,) } else { hid-segs += (cur,) }
      }
      cur = (pt,)
      cur-front = is-front
    }
  }

  // Flush segment cuối
  if cur.len() >= 2 {
    if cur-front { vis-segs += (cur,) } else { hid-segs += (cur,) }
  }
  (vis-segs, hid-segs)
}


// ── HÀM VẼ ────────────────────────────────────────────────────

/// Vẽ đường xoắn ốc (helix) quanh trục thẳng đứng.
/// Tự động xử lý phần khuất (nét đứt) và phần nhìn thấy (nét liền).
///
/// Hữu dụng cho bài toán: kiến bò trên mặt trụ,
/// dây quấn quanh ống, đường ren vít.
///
/// - center (array): Tọa độ tâm đáy dưới `(cx, cy)`. Mặc định: `(0, 0)`.
/// - radius (float): Bán kính của đường tròn đáy.
/// - height (float): Chiều cao tổng của đường xoắn.
/// - loops (float): Số vòng xoắn. Mặc định: `1`.
/// - steps (int): Số đoạn xấp xỉ. Mặc định: `60`.
/// - color (color): Màu nét vẽ. Mặc định: `rgb("E91E63")`.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - auto-dashed (bool): Tự động vẽ phần khuất bằng nét đứt. Mặc định: `true`.
/// - persp-y (float): Tỉ lệ phối cảnh ellipse. Mặc định: `0.3`.
/// - offset-angle (float): Góc bắt đầu (radian). Mặc định: `calc.pi`.
#let draw-helix(
  center: (0, 0),
  radius: 1,
  height: 4,
  loops: 1,
  steps: 60,
  color: rgb("E91E63"),
  stroke-width: 1.5pt,
  auto-dashed: true,
  persp-y: 0.3,
  offset-angle: calc.pi,
) = {
  let d = cetz.draw
  let pts = helix-points(
    center: center,
    radius: radius,
    height: height,
    loops: loops,
    steps: steps,
    persp-y: persp-y,
    offset-angle: offset-angle,
  )

  if auto-dashed {
    let (vis-segs, hid-segs) = helix-split-visible(
      pts,
      loops: loops,
      offset-angle: offset-angle,
    )
    for seg in vis-segs {
      if seg.len() >= 2 {
        d.line(..seg, stroke: stroke-width + color)
      }
    }
    for seg in hid-segs {
      if seg.len() >= 2 {
        d.line(..seg, stroke: (dash: "dashed", paint: color, thickness: stroke-width))
      }
    }
  } else {
    // Vẽ đơn giản: toàn bộ 1 màu, 1 nét
    d.line(..pts, stroke: stroke-width + color)
  }
}

/// Vẽ lò xo (nhiều vòng hơn helix, bán kính nhỏ, thường dùng cho bài vật lý-toán).
/// Là wrapper của draw-helix với preset phù hợp.
///
/// - center (array): Tọa độ tâm đáy dưới.
/// - radius (float): Bán kính lò xo. Mặc định: `0.4`.
/// - height (float): Chiều dài lò xo.
/// - coils (float): Số vòng cuộn. Mặc định: `6`.
/// - color (color): Màu nét. Mặc định: `rgb("1976D2")`.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.2pt`.
#let draw-spring(
  center: (0, 0),
  radius: 0.4,
  height: 4,
  coils: 6,
  color: rgb("1976D2"),
  stroke-width: 1.2pt,
) = {
  draw-helix(
    center: center,
    radius: radius,
    height: height,
    loops: coils,
    steps: coils * 30,
    color: color,
    stroke-width: stroke-width,
    auto-dashed: false,  // Lò xo không cần nét đứt
    persp-y: 0.5,
  )
}
