// ═══════════════════════════════════════════════════════════════
// GEOMETRY-3D / CULLING.TYP — Thuật toán Khử nét khuất tự động
// ═══════════════════════════════════════════════════════════════

#import "vec3.typ": *
#import "camera.typ": *

/// Chuẩn hóa cặp chỉ số cạnh (u, v) sao cho u < v
#let canonical-edge(u, v) = {
  if u < v { (u, v) } else { (v, u) }
}

/// Tính vector pháp tuyến hướng ra ngoài (outward normal) của một mặt F
/// Tự động kiểm tra tâm khối đa diện để đảo dấu nếu cần, chống lỗi ngược chiều kim đồng hồ
#let face-normal(face-indices, vertices, poly-center: none) = {
  let n = face-indices.len()
  if n < 3 { return origin3d }
  let p0 = vertices.at(face-indices.at(0))
  let p1 = vertices.at(face-indices.at(1))
  let p2 = vertices.at(face-indices.at(2))

  let v1 = vec3-sub(p1, p0)
  let v2 = vec3-sub(p2, p0)
  let norm = vec3-cross(v1, v2)

  // Nếu 3 điểm đầu thẳng hàng, thử tìm điểm thứ 3 không thẳng hàng
  if vec3-norm(norm) < 1e-7 and n > 3 {
    for k in range(3, n) {
      let pk = vertices.at(face-indices.at(k))
      let vk = vec3-sub(pk, p0)
      norm = vec3-cross(v1, vk)
      if vec3-norm(norm) >= 1e-7 { break }
    }
  }

  let unit-norm = vec3-unit(norm)

  // Nếu có tâm khối đa diện, đảm bảo pháp tuyến luôn chĩa ra ngoài
  if poly-center != none and vec3-norm(unit-norm) > 1e-7 {
    // Tính tâm mặt F
    let f-center = origin3d
    for idx in face-indices {
      f-center = vec3-add(f-center, vertices.at(idx))
    }
    f-center = vec3-scale(f-center, 1.0 / n)
    let out-dir = vec3-sub(f-center, poly-center)
    if vec3-dot(unit-norm, out-dir) < 0 {
      unit-norm = vec3-neg(unit-norm)
    }
  }

  unit-norm
}

/// Phân tích độ hiển thị (visibility) của đa diện dưới góc nhìn Camera
/// Trả về dictionary gồm:
/// - visible-edges: mảng các cặp đỉnh (u, v) nhìn thấy (nét liền)
/// - hidden-edges: mảng các cặp đỉnh (u, v) bị khuất (nét đứt)
/// - front-faces: mảng chỉ số các mặt hướng về camera
/// - back-faces: mảng chỉ số các mặt quay đi
#let cull-polyhedron(vertices, faces, cam) = {
  let num-v = vertices.len()
  let num-f = faces.len()

  // 1. Tính tâm khối đa diện (barycenter)
  let poly-center = vec3-barycenter(vertices)

  // 2. Phân loại từng mặt: Thấy (front) hay Khuất (back)
  let face-is-front = ()
  let front-faces = ()
  let back-faces = ()

  for f-idx in range(num-f) {
    let f = faces.at(f-idx)
    let norm = face-normal(f, vertices, poly-center: poly-center)

    // Vector hướng nhìn
    let is-front = false
    if cam.at("mode", default: "ortho") == "perspective" {
      // Với perspective: vector từ tâm mặt tới mắt camera
      let f-center = vec3-barycenter(f.map(i => vertices.at(i)))
      let d = cam.at("distance", default: 12.0)
      let eye-pos = vec3-scale(cam.view-dir, d)
      let to-eye = vec3-sub(eye-pos, f-center)
      is-front = vec3-dot(norm, to-eye) > 1e-5
    } else {
      // Ortho & Cavalier: chiếu trực tiếp lên vector tia nhìn
      is-front = vec3-dot(norm, cam.view-dir) > 1e-5
    }

    face-is-front.push(is-front)
    if is-front {
      front-faces.push(f-idx)
    } else {
      back-faces.push(f-idx)
    }
  }

  // 3. Xây dựng danh sách các cạnh và các mặt kề
  // Dictionary: "u_v" -> mảng chỉ số các mặt kề
  let edge-faces = (:)
  let edge-list = ()

  for f-idx in range(num-f) {
    let f = faces.at(f-idx)
    let k = f.len()
    for i in range(k) {
      let u = f.at(i)
      let v = f.at(calc.rem(i + 1, k))
      let (cu, cv) = canonical-edge(u, v)
      let key = str(cu) + "_" + str(cv)
      if key in edge-faces {
        let arr = edge-faces.at(key)
        arr.push(f-idx)
        edge-faces.insert(key, arr)
      } else {
        edge-faces.insert(key, (f-idx,))
        edge-list.push((cu, cv))
      }
    }
  }

  // 4. Phân loại cạnh: Nét liền (visible) hay Nét đứt (hidden)
  let visible-edges = ()
  let hidden-edges = ()

  for edge in edge-list {
    let (u, v) = edge
    let key = str(u) + "_" + str(v)
    let adj-faces = edge-faces.at(key)

    // Kiểm tra xem có mặt nào kề là mặt thấy (front-face) không
    let has-front = false
    for f-idx in adj-faces {
      if face-is-front.at(f-idx) {
        has-front = true
        break
      }
    }

    if has-front {
      visible-edges.push(edge)
    } else {
      hidden-edges.push(edge)
    }
  }

  (
    visible-edges: visible-edges,
    hidden-edges: hidden-edges,
    front-faces: front-faces,
    back-faces: back-faces,
  )
}
