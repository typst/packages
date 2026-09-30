// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / OXYZ.TYP — Hình Học Tọa Độ Oxyz Chuẩn SGK Lớp 12
// Hệ trục tọa độ 3D, điểm gióng hình hộp, mặt phẳng đoạn chắn,
// vectơ đơn vị, lưới tọa độ, và bộ giải đại số giải tích không gian
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "thpt.typ": ve-diem, ve-doan, ve-goc-vuong, ve-cung-goc

// ─────────────────────────────────────────────────────────────
// 1. PHÉP CHIẾU TRỤC CHUẨN SGK VIỆT NAM
// ─────────────────────────────────────────────────────────────

/// Tạo hàm chiếu toạ độ 3D (x, y, z) -> 2D (u, v) trên trang
/// Ox chéo xuống-trái về phía người quan sát
/// Oy sang ngang bên phải
/// Oz hướng thẳng đứng lên trên
#let tao-chieu-oxyz(k: 0.55, goc: 35deg) = {
  return P => {
    let x = float(P.at(0))
    let y = float(P.at(1))
    let z = float(P.at(2))
    (
      y - k * x * calc.cos(goc),
      z - k * x * calc.sin(goc),
    )
  }
}

// ─────────────────────────────────────────────────────────────
// 2. CÁC HÀM TÍNH TOÁN GIẢI TÍCH OXYZ (SOLVERS)
// ─────────────────────────────────────────────────────────────

#let v3-cong(u, v) = (u.at(0) + v.at(0), u.at(1) + v.at(1), u.at(2) + v.at(2))
#let v3-tru(u, v) = (u.at(0) - v.at(0), u.at(1) - v.at(1), u.at(2) - v.at(2))
#let v3-nhan(u, s) = (u.at(0) * s, u.at(1) * s, u.at(2) * s)
#let v3-vo-huong(u, v) = u.at(0) * v.at(0) + u.at(1) * v.at(1) + u.at(2) * v.at(2)
#let v3-co-huong(u, v) = (
  u.at(1) * v.at(2) - u.at(2) * v.at(1),
  u.at(2) * v.at(0) - u.at(0) * v.at(2),
  u.at(0) * v.at(1) - u.at(1) * v.at(0),
)
#let v3-dai(u) = calc.sqrt(v3-vo-huong(u, u))
#let v3-don-vi(u) = {
  let d = v3-dai(u)
  if d < 1e-9 { (0.0, 0.0, 0.0) } else { v3-nhan(u, 1.0 / d) }
}

/// Tích hỗn tạp [u, v, w] = (u x v) . w
#let tich-hon-tap(u, v, w) = v3-vo-huong(v3-co-huong(u, v), w)

/// Khoảng cách giữa 2 điểm trong không gian Oxyz
#let khoang-cach-3d(A, B) = v3-dai(v3-tru(B, A))

/// Góc giữa 2 vectơ (trả về kiểu angle)
#let goc-vecto-3d(u, v) = {
  let d1 = v3-dai(u)
  let d2 = v3-dai(v)
  if d1 < 1e-9 or d2 < 1e-9 { return 0deg }
  let cos-val = calc.max(-1.0, calc.min(1.0, v3-vo-huong(u, v) / (d1 * d2)))
  calc.acos(cos-val)
}

/// Phương trình mặt phẳng đi qua 3 điểm không thẳng hàng: ax + by + cz + d = 0
/// Trả về dict: (a: ..., b: ..., c: ..., d: ...)
#let pt-mat-phang(A, B, C) = {
  let AB = v3-tru(B, A)
  let AC = v3-tru(C, A)
  let n = v3-co-huong(AB, AC)
  let d = -(n.at(0) * A.at(0) + n.at(1) * A.at(1) + n.at(2) * A.at(2))
  (a: n.at(0), b: n.at(1), c: n.at(2), d: d, n: n)
}

/// Khoảng cách từ điểm M(x0, y0, z0) đến mặt phẳng (P): ax + by + cz + d = 0
#let khoang-cach-diem-mp(M, mp) = {
  let tu = calc.abs(mp.a * M.at(0) + mp.b * M.at(1) + mp.c * M.at(2) + mp.d)
  let mau = calc.sqrt(mp.a * mp.a + mp.b * mp.b + mp.c * mp.c)
  if mau < 1e-9 { 0.0 } else { tu / mau }
}

/// Hình chiếu vuông góc của điểm M lên mặt phẳng (P)
#let hinh-chieu-diem-mp(M, mp) = {
  let tu = mp.a * M.at(0) + mp.b * M.at(1) + mp.c * M.at(2) + mp.d
  let mau = mp.a * mp.a + mp.b * mp.b + mp.c * mp.c
  if mau < 1e-9 { return M }
  let t = -tu / mau
  (
    M.at(0) + t * mp.a,
    M.at(1) + t * mp.b,
    M.at(2) + t * mp.c,
  )
}

/// Giao điểm của đường thẳng (đi qua M0, vtcp u) với mặt phẳng (P)
#let giao-dt-mp(M0, u, mp) = {
  let num = -(mp.a * M0.at(0) + mp.b * M0.at(1) + mp.c * M0.at(2) + mp.d)
  let den = mp.a * u.at(0) + mp.b * u.at(1) + mp.c * u.at(2)
  if calc.abs(den) < 1e-9 { return none } // song song hoặc nằm trong
  let t = num / den
  (
    M0.at(0) + t * u.at(0),
    M0.at(1) + t * u.at(1),
    M0.at(2) + t * u.at(2),
  )
}

// ─────────────────────────────────────────────────────────────
// 3. CÁC HÀM VẼ ĐỒ HỌA TRONG KHÔNG GIAN OXYZ
// ─────────────────────────────────────────────────────────────

#let _mien-truc(v) = {
  if type(v) == array { (float(v.at(0)), float(v.at(1))) }
  else if float(v) < 0.0 { (float(v), 0.0) }
  else { (0.0, float(v)) }
}

#let _danh-sach-moc(a, b, buoc) = {
  let res = ()
  let val = calc.ceil(a / buoc - 1e-5) * buoc
  while val <= b + 1e-5 {
    if calc.abs(val) > 1e-5 {
      res.push(val)
    }
    val += buoc
  }
  res
}

#let _dinh-dang-so(v) = {
  if calc.abs(v - calc.round(v)) < 1e-5 {
    str(int(calc.round(v)))
  } else {
    str(calc.round(v, digits: 2))
  }
}

/// Vẽ điểm 3D trong hệ tọa độ Oxyz với tùy chọn hộp gióng tự động
#let diem-oxyz(
  t3,
  P,
  ten: none,
  huong: "north-west",
  giong: false,
  bk: 2.2pt,
  mau: black,
  mau-giong: rgb("64748b"),
  co-chu: 9pt,
  hien-so-truc: true,
) = {
  let d_cetz = cetz.draw
  let p2 = t3(P)
  let (x, y, z) = (float(P.at(0)), float(P.at(1)), float(P.at(2)))

  // Hộp gióng tọa độ vào các trục và mặt phẳng nếu bật giong: true
  if giong {
    let p_xy = t3((x, y, 0.0))
    let p_x  = t3((x, 0.0, 0.0))
    let p_y  = t3((0.0, y, 0.0))
    let p_z  = t3((0.0, 0.0, z))

    // Nét gióng trên mặt phẳng Oxy: (x, 0, 0) -> (x, y, 0) -> (0, y, 0)
    if calc.abs(x) > 1e-4 and calc.abs(y) > 1e-4 {
      ve-doan(p_x, p_xy, dut: true, mau: mau-giong, day: 0.75pt)
      ve-doan(p_y, p_xy, dut: true, mau: mau-giong, day: 0.75pt)
    }

    // Nét gióng đứng lên điểm P: (x, y, 0) -> (x, y, z)
    if calc.abs(z) > 1e-4 {
      if calc.abs(x) > 1e-4 or calc.abs(y) > 1e-4 {
        ve-doan(p_xy, p2, dut: true, mau: mau-giong, day: 0.75pt)
      }
      // Gióng lên trục Oz và các mặt tương ứng
      if calc.abs(x) > 1e-4 {
        let p_xz = t3((x, 0.0, z))
        ve-doan(p_x, p_xz, dut: true, mau: mau-giong, day: 0.75pt)
        ve-doan(p_z, p_xz, dut: true, mau: mau-giong, day: 0.75pt)
        ve-doan(p_xz, p2, dut: true, mau: mau-giong, day: 0.75pt)
      }
      if calc.abs(y) > 1e-4 {
        let p_yz = t3((0.0, y, z))
        ve-doan(p_y, p_yz, dut: true, mau: mau-giong, day: 0.75pt)
        ve-doan(p_z, p_yz, dut: true, mau: mau-giong, day: 0.75pt)
        ve-doan(p_yz, p2, dut: true, mau: mau-giong, day: 0.75pt)
      }
    }

    // Đánh dấu các mốc trên 3 trục nếu có số
    if hien-so-truc {
      if calc.abs(x) > 1e-4 {
        ve-diem(p_x, ten: _dinh-dang-so(x), huong: "north-east", bk: 1.4pt, mau: mau-giong, co-chu: 8pt)
      }
      if calc.abs(y) > 1e-4 {
        ve-diem(p_y, ten: _dinh-dang-so(y), huong: "north", bk: 1.4pt, mau: mau-giong, co-chu: 8pt)
      }
      if calc.abs(z) > 1e-4 {
        ve-diem(p_z, ten: _dinh-dang-so(z), huong: "east", bk: 1.4pt, mau: mau-giong, co-chu: 8pt)
      }
    }
  }

  // Chấm điểm P và nhãn
  ve-diem(p2, ten: ten, huong: huong, bk: bk, mau: mau, co-chu: co-chu)
}

/// Vẽ đoạn thẳng nối 2 điểm 3D
#let doan-oxyz(
  t3,
  A,
  B,
  dut: false,
  mau: black,
  day: 0.9pt,
  ten: none,
  ten-huong: "north",
) = {
  ve-doan(t3(A), t3(B), dut: dut, mau: mau, day: day, ten: ten, ten-huong: ten-huong)
}

/// Vẽ vectơ 3D nối từ điểm A đến điểm B kèm mũi tên
#let vecto-oxyz(
  t3,
  A,
  B,
  ten: none,
  huong: "north",
  mau: black,
  day: 1.1pt,
  dut: false,
) = {
  let d_cetz = cetz.draw
  let pA = t3(A)
  let pB = t3(B)
  let st = if dut {
    (paint: mau, thickness: day, dash: "dashed")
  } else {
    day + mau
  }
  d_cetz.line(pA, pB, stroke: st, mark: (end: ">", fill: mau, size: 0.18))
  if ten != none {
    let mid = ( (pA.at(0) + pB.at(0)) / 2.0, (pA.at(1) + pB.at(1)) / 2.0 )
    d_cetz.content(mid, anchor: huong)[#ten]
  }
}

/// Vẽ mặt phẳng đoạn chắn x/a + y/b + z/c = 1 cắt 3 trục tọa độ tại A(a,0,0), B(0,b,0), C(0,0,c)
#let mat-phang-doan-chan(
  t3,
  a: 3.0,
  b: 3.5,
  c: 3.0,
  ten: $(alpha)$,
  mau: rgb("3b82f6"),
  do-mo: 20%,
  hien-goc-vuong: true,
) = {
  let d_cetz = cetz.draw
  let A = (a, 0.0, 0.0)
  let B = (0.0, b, 0.0)
  let C = (0.0, 0.0, c)
  let O = (0.0, 0.0, 0.0)

  let pA = t3(A)
  let pB = t3(B)
  let pC = t3(C)
  let pO = t3(O)

  // Đổ bóng tam giác thiết diện ABC
  d_cetz.line(pA, pB, pC, close: true, fill: mau.transparentize(100% - do-mo), stroke: 1.1pt + mau)

  // Các đoạn nằm trên trục: nét đứt OA, OB, OC
  ve-doan(pO, pA, dut: true, mau: mau.darken(20%), day: 0.85pt)
  ve-doan(pO, pB, dut: true, mau: mau.darken(20%), day: 0.85pt)
  ve-doan(pO, pC, dut: true, mau: mau.darken(20%), day: 0.85pt)

  // Điểm các mốc chắn
  ve-diem(pA, ten: $A$, huong: "north-east", bk: 2pt, mau: mau.darken(30%))
  ve-diem(pB, ten: $B$, huong: "north", bk: 2pt, mau: mau.darken(30%))
  ve-diem(pC, ten: $C$, huong: "east", bk: 2pt, mau: mau.darken(30%))

  // Tên mặt phẳng tại trọng tâm
  let G2 = ( (pA.at(0) + pB.at(0) + pC.at(0)) / 3.0, (pA.at(1) + pB.at(1) + pC.at(1)) / 3.0 )
  d_cetz.content(G2, anchor: "center", text(fill: mau.darken(40%), weight: "bold")[#ten])

  if hien-goc-vuong {
    ve-goc-vuong(pA, pO, pB, r: 0.2, mau: rgb("94a3b8"))
    ve-goc-vuong(pB, pO, pC, r: 0.2, mau: rgb("94a3b8"))
  }
}

// ─────────────────────────────────────────────────────────────
// 4. HỆ TRỤC TOẠ ĐỘ OXYZ TOÀN DIỆN (HE-TRUC-OXYZ)
// ─────────────────────────────────────────────────────────────

/// Vẽ hệ trục tọa độ Oxyz chuẩn SGK Toán 12
/// Cho phép truyền hook `them: d => { ... }` với d chứa t3, O, X, Y, Z
#let he-truc-oxyz(
  x: 3.5,
  y: 4.5,
  z: 4.0,
  am: 0.8,
  ten: ($x$, $y$, $z$),
  ten-goc: $O$,
  don-vi: true,
  mau-don-vi: (rgb("dc2626"), rgb("7c3aed"), rgb("059669")),
  vach: false,
  so: false,
  buoc: 1.0,
  luoi: (),
  mau-luoi: rgb("e2e8f0"),
  k: 0.55,
  goc: 35deg,
  mau: black,
  day: 0.95pt,
  them: none,
) = {
  let d_cetz = cetz.draw
  let t3 = tao-chieu-oxyz(k: k, goc: goc)

  let (xa, xb) = _mien-truc(x)
  let (ya, yb) = _mien-truc(y)
  let (za, zb) = _mien-truc(z)

  let dm = 0.8

  // Lưới tọa độ nếu có
  let mp = if luoi == true { ("xy", "xz", "yz") } else if luoi == none or luoi == false { () } else if type(luoi) == str { (luoi,) } else { luoi }
  for m in mp {
    if m == "xy" {
      for i in _danh-sach-moc(xa, xb, buoc) {
        ve-doan(t3((i, ya, 0.0)), t3((i, yb, 0.0)), mau: mau-luoi, day: 0.5pt)
      }
      for j in _danh-sach-moc(ya, yb, buoc) {
        ve-doan(t3((xa, j, 0.0)), t3((xb, j, 0.0)), mau: mau-luoi, day: 0.5pt)
      }
    } else if m == "xz" {
      for i in _danh-sach-moc(xa, xb, buoc) {
        ve-doan(t3((i, 0.0, za)), t3((i, 0.0, zb)), mau: mau-luoi, day: 0.5pt)
      }
      for l in _danh-sach-moc(za, zb, buoc) {
        ve-doan(t3((xa, 0.0, l)), t3((xb, 0.0, l)), mau: mau-luoi, day: 0.5pt)
      }
    } else if m == "yz" {
      for j in _danh-sach-moc(ya, yb, buoc) {
        ve-doan(t3((0.0, j, za)), t3((0.0, j, zb)), mau: mau-luoi, day: 0.5pt)
      }
      for l in _danh-sach-moc(za, zb, buoc) {
        ve-doan(t3((0.0, ya, l)), t3((0.0, yb, l)), mau: mau-luoi, day: 0.5pt)
      }
    }
  }

  // Ba trục tọa độ với mũi tên
  let pOx_start = t3((xa - am, 0.0, 0.0))
  let pOx_end   = t3((xb + am + dm, 0.0, 0.0))
  let pOy_start = t3((0.0, ya - am, 0.0))
  let pOy_end   = t3((0.0, yb + am + dm, 0.0))
  let pOz_start = t3((0.0, 0.0, za - am))
  let pOz_end   = t3((0.0, 0.0, zb + am + dm))

  d_cetz.line(pOx_start, pOx_end, stroke: day + mau, mark: (end: ">", fill: mau, size: 0.18))
  d_cetz.line(pOy_start, pOy_end, stroke: day + mau, mark: (end: ">", fill: mau, size: 0.18))
  d_cetz.line(pOz_start, pOz_end, stroke: day + mau, mark: (end: ">", fill: mau, size: 0.18))

  // Nhãn trục
  d_cetz.content(pOx_end, anchor: "north-east", text(weight: "bold")[#ten.at(0)])
  d_cetz.content(pOy_end, anchor: "north", text(weight: "bold")[#ten.at(1)])
  d_cetz.content(pOz_end, anchor: "east", text(weight: "bold")[#ten.at(2)])

  // Gốc tọa độ O
  let pO = t3((0.0, 0.0, 0.0))
  ve-diem(pO, ten: ten-goc, huong: "north-west", bk: 1.8pt, mau: mau)

  // Vạch chia và số trên trục
  if vach or so {
    // Trục Ox
    for val in _danh-sach-moc(xa, xb, buoc) {
      let pt = t3((val, 0.0, 0.0))
      if vach {
        d_cetz.circle(pt, radius: 1.2pt, fill: mau, stroke: none)
      }
      if so {
        d_cetz.content((pt.at(0) + 0.15, pt.at(1) - 0.15), anchor: "north-east", text(size: 8pt)[#_dinh-dang-so(val)])
      }
    }
    // Trục Oy
    for val in _danh-sach-moc(ya, yb, buoc) {
      let pt = t3((0.0, val, 0.0))
      if vach {
        d_cetz.circle(pt, radius: 1.2pt, fill: mau, stroke: none)
      }
      if so {
        d_cetz.content((pt.at(0), pt.at(1) - 0.2), anchor: "north", text(size: 8pt)[#_dinh-dang-so(val)])
      }
    }
    // Trục Oz
    for val in _danh-sach-moc(za, zb, buoc) {
      let pt = t3((0.0, 0.0, val))
      if vach {
        d_cetz.circle(pt, radius: 1.2pt, fill: mau, stroke: none)
      }
      if so {
        d_cetz.content((pt.at(0) - 0.2, pt.at(1)), anchor: "east", text(size: 8pt)[#_dinh-dang-so(val)])
      }
    }
  }

  // Vẽ 3 vectơ đơn vị i, j, k
  if don-vi {
    vecto-oxyz(t3, (0.0, 0.0, 0.0), (1.0, 0.0, 0.0), ten: $arrow(i)$, huong: "north-east", mau: mau-don-vi.at(0), day: 1.2pt)
    vecto-oxyz(t3, (0.0, 0.0, 0.0), (0.0, 1.0, 0.0), ten: $arrow(j)$, huong: "north", mau: mau-don-vi.at(1), day: 1.2pt)
    vecto-oxyz(t3, (0.0, 0.0, 0.0), (0.0, 0.0, 1.0), ten: $arrow(k)$, huong: "east", mau: mau-don-vi.at(2), day: 1.2pt)
  }

  // Dữ liệu truyền cho callback vẽ thêm
  let d = (
    t3: t3,
    O: pO,
    X: pOx_end,
    Y: pOy_end,
    Z: pOz_end,
    giong-hop: (x-val, y-val, z-val, nhan: none) => {
      diem-oxyz(t3, (x-val, y-val, z-val), ten: nhan, giong: true)
    },
    diem: (P, ten: none, giong: false) => diem-oxyz(t3, P, ten: ten, giong: giong),
    doan: (A, B, dut: false, mau: black) => doan-oxyz(t3, A, B, dut: dut, mau: mau),
    vecto: (A, B, ten: none, mau: black) => vecto-oxyz(t3, A, B, ten: ten, mau: mau),
  )

  if them != none {
    them(d)
  }
}

/// Bao đóng hệ trục Oxyz trong CeTZ canvas độc lập (dùng trực tiếp trong văn bản)
#let he-truc-oxyz-fig(..args) = {
  cetz.canvas({
    he-truc-oxyz(..args)
  })
}

// Bí danh ngắn gọn:
#let oxyz = he-truc-oxyz
#let oxyz-fig = he-truc-oxyz-fig

/// Vẽ mặt phẳng đoạn chắn x/a + y/b + z/c = 1 trong hệ trục Oxyz (Canvas độc lập)
#let mat-phang-doan-chan-fig(a: 2.5, b: 3.2, c: 2.8, ten: $(alpha)$, do-mo: 22%, mau: rgb("0284c7"), ..args) = {
  cetz.canvas({
    he-truc-oxyz(
      x: a + 0.8,
      y: b + 0.8,
      z: c + 0.8,
      don-vi: false,
      ..args,
      them: d => {
        mat-phang-doan-chan(d.t3, a: a, b: b, c: c, ten: ten, mau: mau, do-mo: do-mo)
      }
    )
  })
}

/// Vẽ tam giác trong không gian Oxyz kèm trọng tâm G và tọa độ đỉnh
#let tam-giac-oxyz-fig(
  A: (2.0, 1.0, 3.0),
  B: (1.0, 3.5, 0.5),
  C: (3.2, 2.0, 0.0),
  ten: ($A$, $B$, $C$, $G$),
  hien-trong-tam: true,
  giong-dinh: false,
  giong-trong-tam: true,
  mau-tam-giac: rgb("ea580c"),
  ..args
) = {
  cetz.canvas({
    let max-x = calc.max(A.at(0), B.at(0), C.at(0)) + 0.8
    let max-y = calc.max(A.at(1), B.at(1), C.at(1)) + 0.8
    let max-z = calc.max(A.at(2), B.at(2), C.at(2)) + 0.8
    he-truc-oxyz(
      x: max-x, y: max-y, z: max-z,
      don-vi: false,
      ..args,
      them: d => {
        let t3 = d.t3
        let pA = t3(A); let pB = t3(B); let pC = t3(C)
        let d_cetz = cetz.draw

        // Tô màu mặt tam giác
        d_cetz.line(pA, pB, pC, close: true, fill: mau-tam-giac.transparentize(80%), stroke: 1.2pt + mau-tam-giac)

        // Các đỉnh
        (d.diem)(A, ten: ten.at(0), giong: giong-dinh)
        (d.diem)(B, ten: ten.at(1), giong: giong-dinh)
        (d.diem)(C, ten: ten.at(2), giong: giong-dinh)

        if hien-trong-tam {
          let G = (
            (A.at(0) + B.at(0) + C.at(0)) / 3.0,
            (A.at(1) + B.at(1) + C.at(1)) / 3.0,
            (A.at(2) + B.at(2) + C.at(2)) / 3.0,
          )
          (d.diem)(G, ten: ten.at(3), giong: giong-trong-tam)
        }
      }
    )
  })
}
