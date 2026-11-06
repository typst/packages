// ═══════════════════════════════════════════════════════════════
// CORE / MATH-UTILS.TYP — Hàm tính toán toán học phụ trợ
// ═══════════════════════════════════════════════════════════════
// Không import gì — đây là tầng nền, không phụ thuộc module khác.
// Dùng trong: geometry-2d, geometry-3d, calculus, statistics
// ───────────────────────────────────────────────────────────────

// ── Danh sách hàm ──────────────────────────────────────────────
//   linspace(start, stop, n)          Mảng n điểm đều từ start→stop
//   lerp(a, b, t)                     Nội suy tuyến tính
//   clamp(x, lo, hi)                  Kẹp giá trị trong [lo, hi]
//   rotate-2d(pt, angle)              Xoay điểm 2D quanh gốc tọa độ
//   vec-norm((dx, dy))                Chuẩn hóa vector 2D
//   vec-scale((x, y), s)              Nhân vector với scalar
//   vec-add((ax, ay), (bx, by))       Cộng hai vector
//   pt-lerp(A, B, t)                  Nội suy điểm giữa A và B
//   sign(x)                           Dấu của x: -1, 0, +1
//   deg-to-rad(d)                     Đổi độ → radian (wrapper tiện)
//   rad-to-deg(r)                     Đổi radian → độ
// ───────────────────────────────────────────────────────────────

/// Tạo mảng gồm `n` giá trị phân bố đều từ `start` đến `stop` (inclusive).
/// Tương đương numpy.linspace.
///
/// - start (float): Giá trị đầu.
/// - stop (float):  Giá trị cuối.
/// - n (int):       Số phần tử. Phải >= 2.
/// → returns array of float
#let linspace(start, stop, n) = {
  if n <= 1 { return (start,) }
  let step = (stop - start) / (n - 1)
  range(0, n).map(i => start + i * step)
}

/// Nội suy tuyến tính giữa `a` và `b` theo tham số `t ∈ [0, 1]`.
/// lerp(a, b, 0) = a; lerp(a, b, 1) = b.
///
/// - a (float): Giá trị đầu.
/// - b (float): Giá trị cuối.
/// - t (float): Tham số nội suy [0, 1].
/// → returns float
#let lerp(a, b, t) = a + (b - a) * t

/// Kẹp giá trị `x` vào khoảng `[lo, hi]`.
///
/// - x (float): Giá trị cần kẹp.
/// - lo (float): Cận dưới.
/// - hi (float): Cận trên.
/// → returns float
#let clamp(x, lo, hi) = calc.max(lo, calc.min(hi, x))

/// Dấu của x: trả về -1 (âm), 0 (zero), hoặc 1 (dương).
///
/// - x (float): Giá trị đầu vào.
/// → returns int
#let sign(x) = {
  if x > 0 { 1 } else if x < 0 { -1 } else { 0 }
}

/// Đổi đơn vị đo góc từ độ (degree) sang radian.
///
/// - d (float): Góc tính bằng độ.
/// → returns float (radian)
#let deg-to-rad(d) = d * calc.pi / 180

/// Đổi đơn vị đo góc từ radian sang độ (degree).
///
/// - r (float): Góc tính bằng radian.
/// → returns float (degree)
#let rad-to-deg(r) = r * 180 / calc.pi

/// Xoay điểm `pt = (x, y)` quanh gốc tọa độ `(0, 0)` một góc `angle` (radian).
///
/// - pt (array): Điểm cần xoay dạng `(x, y)`.
/// - angle (float): Góc xoay tính bằng radian (dương = ngược chiều kim đồng hồ).
/// → returns (float, float)
#let rotate-2d(pt, angle) = {
  let (x, y) = pt
  let cos-a = calc.cos(angle)
  let sin-a = calc.sin(angle)
  (x * cos-a - y * sin-a, x * sin-a + y * cos-a)
}

/// Cộng hai vector 2D.
///
/// - a (array): Vector thứ nhất `(ax, ay)`.
/// - b (array): Vector thứ hai `(bx, by)`.
/// → returns (float, float)
#let vec-add(a, b) = {
  let (ax, ay) = a
  let (bx, by) = b
  (ax + bx, ay + by)
}

/// Nhân vector 2D với một scalar.
///
/// - v (array): Vector `(x, y)`.
/// - s (float): Scalar.
/// → returns (float, float)
#let vec-scale(v, s) = {
  let (x, y) = v
  (x * s, y * s)
}

/// Tính độ dài (norm) của vector 2D.
///
/// - v (array): Vector `(x, y)`.
/// → returns float
#let vec-length(v) = {
  let (x, y) = v
  calc.sqrt(x * x + y * y)
}

/// Chuẩn hóa vector 2D về độ dài bằng 1.
/// Trả về `(0, 0)` nếu vector có độ dài bằng 0.
///
/// - v (array): Vector `(x, y)`.
/// → returns (float, float)
#let vec-norm(v) = {
  let len = vec-length(v)
  if len < 1e-10 { (0.0, 0.0) } else { vec-scale(v, 1.0 / len) }
}

/// Nội suy tuyến tính giữa hai điểm `A` và `B` theo tham số `t ∈ [0, 1]`.
/// Trả về điểm nằm trên đoạn AB: pt-lerp(A, B, 0) = A, pt-lerp(A, B, 1) = B.
///
/// - A (array): Điểm đầu `(ax, ay)`.
/// - B (array): Điểm cuối `(bx, by)`.
/// - t (float): Tham số nội suy [0, 1].
/// → returns (float, float)
#let pt-lerp(A, B, t) = {
  let (ax, ay) = A
  let (bx, by) = B
  (lerp(ax, bx, t), lerp(ay, by, t))
}
