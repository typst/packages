// ═══════════════════════════════════════════════════════════════
// GEOMETRY-3D / REVOLUTION.TYP — Hình khối tròn xoay
// (Nón, Trụ, Cầu — chiếu phối cảnh 2D)
// ═══════════════════════════════════════════════════════════════
// Dùng: #import "geometry-3d/revolution.typ": *
//
// DANH SÁCH HÀM:
//   draw-cylinder(...)      Hình trụ với đầy đủ anchor
//   draw-cone(...)          Hình nón với đầy đủ anchor
//   draw-sphere(...)        Hình cầu với đầy đủ anchor
// ───────────────────────────────────────────────────────────────
// CÁC ANCHOR CÓ SẴN (truyền vào draw.content, draw.line, v.v.):
//
//   Trụ (draw-cylinder name: "C"):
//     C.top         Tâm mặt trên
//     C.bottom      Tâm mặt dưới  
//     C.top-left    Điểm trái mặt trên (điểm tiếp xúc đường sinh)
//     C.top-right   Điểm phải mặt trên
//     C.bot-left    Điểm trái mặt dưới
//     C.bot-right   Điểm phải mặt dưới
//     C.center      Trung điểm trục
//
//   Nón (draw-cone name: "N"):
//     N.apex        Đỉnh S
//     N.center      Tâm đáy O
//     N.left        Điểm trái đáy
//     N.right       Điểm phải đáy
//
//   Cầu (draw-sphere name: "S"):
//     S.center      Tâm O
//     S.top         Điểm cực Bắc
//     S.bottom      Điểm cực Nam
//     S.left        Điểm cực Tây
//     S.right       Điểm cực Đông
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "../core/colors.typ": sm-blue, sm-gray, sm-face-top, sm-face-front

// ── Tỉ lệ phối cảnh mặc định (bán trục ngắn ellipse / bán trục dài) ──
#let _PERSP = 0.35


// ────────────────────────────────────────────────────────────────
// HÌNH TRỤ
// ────────────────────────────────────────────────────────────────

/// Vẽ hình trụ đứng chiếu phối cảnh, kèm theo các anchor.
///
/// - name (str): Tên định danh để tham chiếu anchor. Mặc định: `"cyl"`.
/// - center (array): Tọa độ tâm đáy dưới `(cx, cy)`. Mặc định: `(0, 0)`.
/// - radius (float): Bán kính đáy.
/// - height (float): Chiều cao hình trụ.
/// - color (color): Màu nét viền. Mặc định: sm-blue.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - fill-side (color / none): Tô màu thân trụ. Mặc định: `none`.
/// - fill-top (color / none): Tô màu mặt trên. Mặc định: `none`.
/// - persp (float): Tỉ lệ phối cảnh ellipse. Mặc định: `0.35`.
/// - show-hidden (bool): Vẽ nét đứt cho phần khuất của đáy dưới. Mặc định: `true`.
#let draw-cylinder(
  name: "cyl",
  center: (0, 0),
  radius: 1,
  height: 4,
  color: rgb("1976D2"),   // sm-blue
  stroke-width: 1.5pt,
  fill-side: none,
  fill-top: none,
  persp: 0.35,
  show-hidden: true,
) = {
  let d = cetz.draw
  let (cx, cy) = center
  let ry = radius * persp

  d.group(name: name, {
    if fill-side != none {
      let fill-pts = (
        (cx - radius, cy),
        (cx - radius, cy + height),
        (cx + radius, cy + height),
        (cx + radius, cy),
      )
      d.line(..fill-pts, close: true, fill: fill-side)
    }

    if show-hidden {
      d.arc((cx, cy), start: 0deg, stop: 180deg,
          radius: (radius, ry),
          stroke: (dash: "dashed", paint: rgb("888888"), thickness: 0.8pt))
    }
    d.arc((cx, cy), start: 0deg, stop: -180deg,
        radius: (radius, ry),
        stroke: stroke-width + color)

    if fill-top != none {
      d.arc((cx, cy + height), start: 0deg, stop: 360deg,
          radius: (radius, ry),
          fill: fill-top,
          stroke: stroke-width + color)
    } else {
      d.arc((cx, cy + height), start: 0deg, stop: 360deg,
          radius: (radius, ry),
          stroke: stroke-width + color)
    }

    d.line((cx - radius, cy), (cx - radius, cy + height), stroke: stroke-width + color)
    d.line((cx + radius, cy), (cx + radius, cy + height), stroke: stroke-width + color)

    d.anchor("bottom",    (cx,          cy))
    d.anchor("top",       (cx,          cy + height))
    d.anchor("center",    (cx,          cy + height / 2))
    d.anchor("bot-left",  (cx - radius, cy))
    d.anchor("bot-right", (cx + radius, cy))
    d.anchor("top-left",  (cx - radius, cy + height))
    d.anchor("top-right", (cx + radius, cy + height))
  })
}


// ────────────────────────────────────────────────────────────────
// HÌNH NÓN
// ────────────────────────────────────────────────────────────────

/// Vẽ hình nón đứng chiếu phối cảnh, kèm theo các anchor.
///
/// - name (str): Tên định danh để tham chiếu anchor. Mặc định: `"cone"`.
/// - center (array): Tọa độ tâm đáy `(cx, cy)`. Mặc định: `(0, 0)`.
/// - radius (float): Bán kính đáy.
/// - height (float): Chiều cao hình nón.
/// - color (color): Màu nét viền. Mặc định: sm-blue.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - fill-base (color / none): Tô màu mặt đáy. Mặc định: `none`.
/// - persp (float): Tỉ lệ phối cảnh ellipse. Mặc định: `0.35`.
/// - show-hidden (bool): Vẽ nét đứt phần khuất của đáy. Mặc định: `true`.
/// - label-apex (content / none): Nhãn tại đỉnh. Ví dụ: `[$S$]`.
/// - label-center (content / none): Nhãn tại tâm đáy. Ví dụ: `[$O$]`.
#let draw-cone(
  name: "cone",
  center: (0, 0),
  radius: 1,
  height: 4,
  color: rgb("1976D2"),   // sm-blue
  stroke-width: 1.5pt,
  fill-base: none,
  persp: 0.35,
  show-hidden: true,
  label-apex: none,
  label-center: none,
) = {
  let d = cetz.draw
  let (cx, cy) = center
  let ry = radius * persp
  let apex = (cx, cy + height)

  d.group(name: name, {
    if show-hidden {
      d.arc((cx, cy), start: 0deg, stop: 180deg,
          radius: (radius, ry),
          stroke: (dash: "dashed", paint: rgb("888888"), thickness: 0.8pt))
    }
    if fill-base != none {
      d.arc((cx, cy), start: 0deg, stop: -180deg,
          radius: (radius, ry),
          fill: fill-base,
          stroke: stroke-width + color)
    } else {
      d.arc((cx, cy), start: 0deg, stop: -180deg,
          radius: (radius, ry),
          stroke: stroke-width + color)
    }

    d.line((cx - radius, cy), apex, stroke: stroke-width + color)
    d.line((cx + radius, cy), apex, stroke: stroke-width + color)

    if label-apex != none {
      d.content((cx, cy + height + 0.3), label-apex, anchor: "south")
    }
    if label-center != none {
      d.content((cx, cy - 0.3), label-center, anchor: "north")
    }

    d.anchor("apex",   apex)
    d.anchor("center", (cx, cy))
    d.anchor("left",   (cx - radius, cy))
    d.anchor("right",  (cx + radius, cy))
    d.anchor("mid",    (cx, cy + height / 2))
  })
}


// ────────────────────────────────────────────────────────────────
// HÌNH CẦU
// ────────────────────────────────────────────────────────────────

/// Vẽ hình cầu chiếu phối cảnh (đường tròn ngoài + đường xích đạo ellipse).
///
/// - name (str): Tên định danh để tham chiếu anchor. Mặc định: `"sph"`.
/// - center (array): Tọa độ tâm cầu `(cx, cy)`. Mặc định: `(0, 0)`.
/// - radius (float): Bán kính cầu.
/// - color (color): Màu nét viền. Mặc định: sm-blue.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - fill (color / none): Tô màu mặt cầu. Mặc định: `none`.
/// - persp (float): Tỉ lệ phối cảnh ellipse xích đạo. Mặc định: `0.35`.
/// - show-equator (bool): Vẽ đường xích đạo. Mặc định: `true`.
/// - show-meridian (bool): Vẽ kinh tuyến đứng. Mặc định: `false`.
#let draw-sphere(
  name: "sph",
  center: (0, 0),
  radius: 1,
  color: rgb("1976D2"),   // sm-blue literal
  stroke-width: 1.5pt,
  fill: none,
  persp: 0.35,            // _PERSP literal
  show-equator: true,
  show-meridian: false,
) = {
  let d = cetz.draw
  let (cx, cy) = center
  let ry-eq = radius * persp

  d.group(name: name, {
    if fill != none {
      d.circle((cx, cy), radius: radius, fill: fill, stroke: stroke-width + color)
    } else {
      d.circle((cx, cy), radius: radius, stroke: stroke-width + color)
    }

    if show-equator {
      d.arc((cx, cy), start: 0deg, stop: 180deg,
          radius: (radius, ry-eq),
          stroke: (dash: "dashed", paint: rgb("888888"), thickness: 0.8pt))
      d.arc((cx, cy), start: 0deg, stop: -180deg,
          radius: (radius, ry-eq),
          stroke: stroke-width + color)
    }

    if show-meridian {
      d.arc((cx, cy), start: 90deg, stop: 270deg,
          radius: (ry-eq, radius),
          stroke: (dash: "dashed", paint: rgb("888888"), thickness: 0.8pt))
      d.arc((cx, cy), start: -90deg, stop: 90deg,
          radius: (ry-eq, radius),
          stroke: stroke-width + color)
    }

    d.anchor("center", (cx,          cy))
    d.anchor("top",    (cx,          cy + radius))
    d.anchor("bottom", (cx,          cy - radius))
    d.anchor("left",   (cx - radius, cy))
    d.anchor("right",  (cx + radius, cy))
  })
}
