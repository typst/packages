// ═══════════════════════════════════════════════════════════════
// GEOMETRY-2D / CONICS.TYP — Đường conic (Parabol, Elip, Hyperbol)
// ═══════════════════════════════════════════════════════════════
// Dùng: #import "geometry-2d/conics.typ": *
//
// DANH SÁCH HÀM:
//   parabola-points(...)     Mảng tọa độ parabol (data)
//   draw-parabola(...)       Vẽ parabol với nhãn và anchor
//   ellipse-points(...)      Mảng tọa độ elip (data)
//   draw-ellipse(...)        Vẽ elip với nhãn và anchor
//   hyperbola-points(...)    Mảng tọa độ hyperbol (data)
//   draw-hyperbola(...)      Vẽ hyperbol với nhãn và anchor
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "../core/math-utils.typ": linspace
#import "../core/colors.typ": sm-blue, sm-red, sm-purple


// ────────────────────────────────────────────────────────────────
// PARABOL  y = a(x - h)² + k
// ────────────────────────────────────────────────────────────────

/// Tính mảng tọa độ của parabol dạng y = a(x-h)² + k.
///
/// - a (float): Hệ số bậc 2 (a > 0: mở lên, a < 0: mở xuống).
/// - h (float): Hoành độ đỉnh.
/// - k (float): Tung độ đỉnh.
/// - x-range (array): Khoảng x `(xmin, xmax)`. Mặc định: `(-3, 3)`.
/// - steps (int): Số điểm lấy mẫu. Mặc định: `60`.
/// → returns array of (float, float)
#let parabola-points(
  a: 1,
  h: 0,
  k: 0,
  x-range: (-3.0, 3.0),
  steps: 60,
) = {
  let xs = linspace(x-range.at(0), x-range.at(1), steps + 1)
  xs.map(x => (x, a * (x - h) * (x - h) + k))
}

/// Vẽ parabol y = a(x-h)² + k với đầy đủ nhãn và anchor.
///
/// - name (str): Tên định danh anchor. Mặc định: `"par"`.
/// - a (float): Hệ số bậc 2.
/// - h (float): Hoành độ đỉnh.
/// - k (float): Tung độ đỉnh.
/// - x-range (array): Khoảng x `(xmin, xmax)`. Mặc định: `(-3, 3)`.
/// - color (color): Màu nét. Mặc định: sm-blue.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - label-vertex (content / none): Nhãn tại đỉnh. Ví dụ: `[$P$]`.
/// - fill (color / none): Tô màu bên trong nếu cắt trục x.
#let draw-parabola(
  name: "par",
  a: 1,
  h: 0,
  k: 0,
  x-range: (-3.0, 3.0),
  color: rgb("1565C0"),   // sm-func-1 / sm-blue
  stroke-width: 1.5pt,
  label-vertex: none,
  steps: 60,
) = {
  let d = cetz.draw
  let pts = parabola-points(a: a, h: h, k: k, x-range: x-range, steps: steps)

  d.group(name: name, {
    d.line(..pts, stroke: stroke-width + color)

    if label-vertex != none {
      let offset = if a > 0 { -0.4 } else { 0.4 }
      d.content((h, k + offset), label-vertex)
    }

    // ── Anchors ────────────────────────────────────────────
    d.anchor("vertex", (h, k))
    d.anchor("left",   (x-range.at(0), a * (x-range.at(0) - h) * (x-range.at(0) - h) + k))
    d.anchor("right",  (x-range.at(1), a * (x-range.at(1) - h) * (x-range.at(1) - h) + k))
  })
}


// ────────────────────────────────────────────────────────────────
// ELIP  x²/a² + y²/b² = 1
// ────────────────────────────────────────────────────────────────

/// Tính mảng tọa độ của elip x²/a² + y²/b² = 1.
///
/// - a (float): Bán trục dài (theo x).
/// - b (float): Bán trục ngắn (theo y).
/// - center (array): Tâm elip `(cx, cy)`. Mặc định: `(0, 0)`.
/// - steps (int): Số điểm lấy mẫu. Mặc định: `120`.
/// → returns array of (float, float)
#let ellipse-points(
  a: 2,
  b: 1,
  center: (0.0, 0.0),
  steps: 120,
) = {
  let (cx, cy) = center
  let angles = linspace(0, 2 * calc.pi, steps + 1)
  angles.map(t => (cx + a * calc.cos(t), cy + b * calc.sin(t)))
}

/// Vẽ elip x²/a² + y²/b² = 1 với đầy đủ nhãn và anchor.
///
/// - name (str): Tên định danh anchor. Mặc định: `"ell"`.
/// - a (float): Bán trục dài (theo x).
/// - b (float): Bán trục ngắn (theo y).
/// - center (array): Tâm elip `(cx, cy)`. Mặc định: `(0, 0)`.
/// - color (color): Màu nét. Mặc định: sm-purple.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - fill (color / none): Tô màu bên trong. Mặc định: `none`.
/// - show-axes (bool): Vẽ nửa trục (nét đứt). Mặc định: `false`.
/// - show-foci (bool): Đánh dấu 2 tiêu điểm F1, F2. Mặc định: `false`.
#let draw-ellipse(
  name: "ell",
  a: 2,
  b: 1,
  center: (0.0, 0.0),
  color: rgb("7B1FA2"),   // sm-purple
  stroke-width: 1.5pt,
  fill: none,
  show-axes: false,
  show-foci: false,
  steps: 120,
) = {
  let d = cetz.draw
  let (cx, cy) = center
  let pts = ellipse-points(a: a, b: b, center: center, steps: steps)
  let c-focal = calc.sqrt(calc.abs(a * a - b * b))

  d.group(name: name, {
    if fill != none {
      d.line(..pts, close: true, fill: fill, stroke: stroke-width + color)
    } else {
      d.line(..pts, close: true, stroke: stroke-width + color)
    }

    if show-axes {
      d.line((cx - a, cy), (cx + a, cy),
           stroke: (dash: "dashed", paint: rgb("1976D2"), thickness: 0.8pt))
      d.line((cx, cy - b), (cx, cy + b),
           stroke: (dash: "dashed", paint: rgb("1976D2"), thickness: 0.8pt))
    }

    if show-foci and a > b {
      d.circle((cx + c-focal, cy), radius: 0.08, fill: rgb("E91E63"))
      d.circle((cx - c-focal, cy), radius: 0.08, fill: rgb("E91E63"))
      d.content((cx + c-focal, cy - 0.3), [$F_2$])
      d.content((cx - c-focal, cy - 0.3), [$F_1$])
    }

    // ── Anchors ────────────────────────────────────────────
    d.anchor("center", (cx,      cy))
    d.anchor("right",  (cx + a,  cy))
    d.anchor("left",   (cx - a,  cy))
    d.anchor("top",    (cx,      cy + b))
    d.anchor("bottom", (cx,      cy - b))
    if a > b {
      d.anchor("focus-1", (cx - c-focal, cy))
      d.anchor("focus-2", (cx + c-focal, cy))
    }
  })
}


// ────────────────────────────────────────────────────────────────
// HYPERBOL  x²/a² - y²/b² = 1
// ────────────────────────────────────────────────────────────────

/// Tính mảng tọa độ của một nhánh hyperbol (nhánh phải: x > 0).
///
/// - a (float): Hệ số a của hyperbol.
/// - b (float): Hệ số b của hyperbol.
/// - branch (str): `"right"` hoặc `"left"`. Mặc định: `"right"`.
/// - y-range (array): Khoảng y `(ymin, ymax)`. Mặc định: `(-3, 3)`.
/// - center (array): Tâm hyperbol. Mặc định: `(0, 0)`.
/// - steps (int): Số điểm lấy mẫu. Mặc định: `60`.
/// → returns array of (float, float)
#let hyperbola-branch-points(
  a: 1,
  b: 1,
  branch: "right",
  y-range: (-3.0, 3.0),
  center: (0.0, 0.0),
  steps: 60,
) = {
  let (cx, cy) = center
  let ys = linspace(y-range.at(0), y-range.at(1), steps + 1)
  let sign = if branch == "right" { 1 } else { -1 }
  ys.map(y => (cx + sign * a * calc.sqrt(1 + (y - cy) * (y - cy) / (b * b)), y))
}

/// Vẽ cả hai nhánh của hyperbol x²/a² - y²/b² = 1.
///
/// - name (str): Tên định danh anchor. Mặc định: `"hyp"`.
/// - a (float): Hệ số a.
/// - b (float): Hệ số b.
/// - center (array): Tâm `(cx, cy)`. Mặc định: `(0, 0)`.
/// - y-range (array): Khoảng y `(ymin, ymax)`. Mặc định: `(-3, 3)`.
/// - color (color): Màu nét. Mặc định: sm-red.
/// - stroke-width (length): Độ dày nét. Mặc định: `1.5pt`.
/// - show-asymptotes (bool): Vẽ đường tiệm cận. Mặc định: `false`.
/// - show-foci (bool): Đánh dấu tiêu điểm. Mặc định: `false`.
#let draw-hyperbola(
  name: "hyp",
  a: 1,
  b: 1,
  center: (0.0, 0.0),
  y-range: (-3.0, 3.0),
  color: rgb("E91E63"),   // sm-red
  stroke-width: 1.5pt,
  show-asymptotes: false,
  show-foci: false,
  steps: 60,
) = {
  import cetz.draw: *
  let (cx, cy) = center
  let c-focal = calc.sqrt(a * a + b * b)
  let pts-r = hyperbola-branch-points(a: a, b: b, branch: "right",
               y-range: y-range, center: center, steps: steps)
  let pts-l = hyperbola-branch-points(a: a, b: b, branch: "left",
               y-range: y-range, center: center, steps: steps)

  group(name: name, {
    line(..pts-r, stroke: stroke-width + color)
    line(..pts-l, stroke: stroke-width + color)

    if show-asymptotes {
      let x-range-asm = (y-range.at(0) * a / b, y-range.at(1) * a / b)
      line((cx + x-range-asm.at(0), cy + y-range.at(0)),
           (cx + x-range-asm.at(1), cy + y-range.at(1)),
           stroke: (dash: "dashed", paint: rgb("1976D2"), thickness: 0.8pt))
      line((cx - x-range-asm.at(0), cy + y-range.at(0)),
           (cx - x-range-asm.at(1), cy + y-range.at(1)),
           stroke: (dash: "dashed", paint: rgb("1976D2"), thickness: 0.8pt))
    }

    if show-foci {
      circle((cx + c-focal, cy), radius: 0.08, fill: rgb("E91E63"))
      circle((cx - c-focal, cy), radius: 0.08, fill: rgb("E91E63"))
      content((cx + c-focal, cy - 0.3), [$F_2$])
      content((cx - c-focal, cy - 0.3), [$F_1$])
    }

    // ── Anchors ────────────────────────────────────────────
    anchor("center",  (cx, cy))
    anchor("right",   (cx + a, cy))
    anchor("left",    (cx - a, cy))
    anchor("focus-1", (cx - c-focal, cy))
    anchor("focus-2", (cx + c-focal, cy))
  })
}
