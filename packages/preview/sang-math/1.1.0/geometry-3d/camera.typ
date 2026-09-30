// ═══════════════════════════════════════════════════════════════
// GEOMETRY-3D / CAMERA.TYP — Hệ tọa độ Viewport & Phép chiếu 3D -> 2D
// ═══════════════════════════════════════════════════════════════

#import "vec3.typ": *

/// Tạo đối tượng Camera 3D để quản lý góc nhìn và phép chiếu
///
/// - elevation (angle): Góc ngẩng nhìn từ trên xuống (mặc định: 25deg)
/// - azimuth (angle): Góc xoay phương vị quanh trục thẳng đứng Z (mặc định: 45deg)
/// - roll (angle): Góc nghiêng camera quanh trục ngắm (mặc định: 0deg)
/// - mode (str): Kiểu phép chiếu:
///     - "ortho": Trực giao xoay tự do (chuẩn đồ họa kỹ thuật hiện đại)
///     - "cavalier": Phối cảnh trục đo nghiêng (chuẩn SGK Toán VN: Oy ngang, Oz đứng, Ox chéo)
///     - "perspective": Phối cảnh trung tâm (có điểm tụ xa gần)
/// - distance (float): Khoảng cách từ camera đến gốc tọa độ (cho mode "perspective")
/// - scale (float): Hệ số phóng to/thu nhỏ toàn bộ khung vẽ
/// - cavalier-angle (angle): Góc nghiêng của trục Ox trong mode cavalier (mặc định: 45deg)
/// - cavalier-ratio (float): Tỉ lệ co ngắn trục Ox trong mode cavalier (mặc định: 0.5)
#let make-camera(
  elevation: 25deg,
  azimuth: 45deg,
  roll: 0deg,
  mode: "ortho",
  distance: 12.0,
  scale: 1.0,
  cavalier-angle: 45deg,
  cavalier-ratio: 0.5,
) = {
  // Vector hướng từ gốc tọa độ về phía mắt người xem (Viewing direction)
  let cos-el = calc.cos(elevation)
  let sin-el = calc.sin(elevation)
  let cos-az = calc.cos(azimuth)
  let sin-az = calc.sin(azimuth)

  // Vị trí camera trên mặt cầu đơn vị
  let cam-dir = (cos-el * cos-az, cos-el * sin-az, sin-el)

  // Hệ trục tọa độ gắn trên màn hình camera:
  // Vector R (Right - trục hoành u trên màn hình)
  let right = (-sin-az, cos-az, 0.0)

  // Vector U (Up - trục tung v trên màn hình)
  let up = (-sin-el * cos-az, -sin-el * sin-az, cos-el)

  // Xử lý góc roll (nếu có)
  if roll != 0deg and roll != 0.0 {
    let cr = calc.cos(roll)
    let sr = calc.sin(roll)
    let new-right = vec3-add(vec3-scale(right, cr), vec3-scale(up, sr))
    let new-up = vec3-add(vec3-scale(right, -sr), vec3-scale(up, cr))
    right = new-right
    up = new-up
  }

  // Vector tia chiếu cho Cavalier (SGK VN)
  let cav-cos = calc.cos(cavalier-angle)
  let cav-sin = calc.sin(cavalier-angle)
  // Trong Cavalier SGK: Oy -> (1, 0), Oz -> (0, 1), Ox -> (-ratio*cos, -ratio*sin)
  let cav-dir = vec3-unit((1.0, cavalier-ratio * cav-cos, cavalier-ratio * cav-sin))

  (
    elevation: elevation,
    azimuth: azimuth,
    roll: roll,
    mode: mode,
    distance: float(distance),
    scale: float(scale),
    cavalier-angle: cavalier-angle,
    cavalier-ratio: float(cavalier-ratio),
    // Precomputed vectors
    view-dir: if mode == "cavalier" { cav-dir } else { cam-dir },
    right: right,
    up: up,
  )
}

/// Chiếu điểm 3D p = (x, y, z) lên tọa độ 2D (u, v) của canvas
#let project-pt(p, cam) = {
  let mode = cam.at("mode", default: "ortho")
  let s = cam.at("scale", default: 1.0)

  if mode == "cavalier" {
    let (x, y, z) = p
    let ang = cam.at("cavalier-angle", default: 45deg)
    let ratio = cam.at("cavalier-ratio", default: 0.5)
    let cos-a = calc.cos(ang)
    let sin-a = calc.sin(ang)
    // Quy ước SGK Toán THPT Việt Nam:
    // Trục Oy nằm ngang: (y, 0)
    // Trục Oz thẳng đứng: (0, z)
    // Trục Ox hướng ra ngoài góc chéo: (-x * ratio * cos_a, -x * ratio * sin_a)
    let u = (y - x * ratio * cos-a) * s
    let v = (z - x * ratio * sin-a) * s
    (u, v)
  } else if mode == "perspective" {
    // Chiếu phối cảnh trung tâm với tiêu cự/khoảng cách D
    let d = cam.at("distance", default: 12.0)
    let u-raw = vec3-dot(p, cam.right)
    let v-raw = vec3-dot(p, cam.up)
    let depth = vec3-dot(p, cam.view-dir)
    let denom = d - depth
    let factor = if denom > 0.1 { d / denom } else { 1.0 }
    (u-raw * factor * s, v-raw * factor * s)
  } else {
    // "ortho": Phép chiếu trực giao (mặc định cao cấp)
    let u = vec3-dot(p, cam.right) * s
    let v = vec3-dot(p, cam.up) * s
    (u, v)
  }
}

/// Chiếu một mảng các điểm 3D thành mảng các điểm 2D
#let project-pts(pts, cam) = {
  pts.map(p => project-pt(p, cam))
}

/// Tính độ sâu (depth) của điểm so với camera (dùng để sắp xếp Z-sort nếu cần)
#let point-depth(p, cam) = {
  vec3-dot(p, cam.view-dir)
}
