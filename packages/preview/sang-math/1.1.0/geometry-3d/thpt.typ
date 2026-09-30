// ═══════════════════════════════════════════════════════════════
// TYPDRAW3D / THPT.TYP — Hình Học Không Gian THPT Chuẩn SGK Việt Nam
// Tích hợp tinh hoa của conic-toan & động cơ 3D Luadraw
// Hỗ trợ cơ chế hook `them: d => { ... }` cực kỳ trực quan, dễ vẽ thêm
// ═══════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"

// ─────────────────────────────────────────────────────────────
// 1. CÁC HÀM TIỆN ÍCH TOÁN HỌC DỰNG HÌNH NHANH (HELPERS)
// ─────────────────────────────────────────────────────────────

/// Tính trung điểm của đoạn thẳng AB
#let trung-diem(A, B) = (
  (A.at(0) + B.at(0)) / 2.0,
  (A.at(1) + B.at(1)) / 2.0,
)

/// Điểm chia đoạn thẳng AB theo tỉ lệ k: P = A + k * (B - A)
/// Ví dụ: k = 0.5 là trung điểm, k = 2/3 là trọng tâm
#let ti-le(A, B, k) = (
  A.at(0) + k * (B.at(0) - A.at(0)),
  A.at(1) + k * (B.at(1) - A.at(1)),
)

/// Tính trọng tâm của tập hợp các điểm
#let trong-tam(..pts) = {
  let arr = pts.pos()
  let n = float(arr.len())
  let sx = 0.0
  let sy = 0.0
  for p in arr {
    sx += p.at(0)
    sy += p.at(1)
  }
  (sx / n, sy / n)
}

/// Tính vector hướng từ trọng tâm G ra điểm P để đặt nhãn không bị đè
#let huong-nhan(P, G, dist: 0.22) = {
  let dx = P.at(0) - G.at(0)
  let dy = P.at(1) - G.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 1e-6 {
    (0.0, dist)
  } else {
    (dx / len * dist, dy / len * dist)
  }
}

/// Chấm điểm và đặt nhãn trong canvas CeTZ
#let ve-diem(
  pt,
  ten: none,
  huong: "north",
  lech: (0.0, 0.0),
  bk: 2.2pt,
  mau: black,
  co-chu: 9pt,
  dam: false,
) = {
  let d = cetz.draw
  if bk > 0pt {
    d.circle(pt, radius: bk, fill: mau, stroke: none)
  }
  if ten != none {
    let (dx, dy) = lech
    let pos = (pt.at(0) + dx, pt.at(1) + dy)
    let w = if dam { "bold" } else { "regular" }
    d.content(pos, anchor: huong, text(size: co-chu, weight: w, fill: mau)[#ten])
  }
}

/// Vẽ đoạn thẳng liền hoặc đứt
#let ve-doan(
  A,
  B,
  dut: false,
  mau: black,
  day: 0.9pt,
  ten: none,
  ten-huong: "north",
) = {
  let d = cetz.draw
  let st = if dut {
    (paint: mau, thickness: day, dash: "dashed")
  } else {
    day + mau
  }
  d.line(A, B, stroke: st)
  if ten != none {
    let mid = trung-diem(A, B)
    d.content(mid, anchor: ten-huong)[#ten]
  }
}

/// Vẽ ký hiệu góc vuông giữa 3 điểm A-O-B (vuông tại O)
#let ve-goc-vuong(
  A,
  O,
  B,
  r: 0.25,
  mau: black,
  day: 0.75pt,
  to: none,
) = {
  let d = cetz.draw
  let v1x = A.at(0) - O.at(0)
  let v1y = A.at(1) - O.at(1)
  let len1 = calc.sqrt(v1x * v1x + v1y * v1y)

  let v2x = B.at(0) - O.at(0)
  let v2y = B.at(1) - O.at(1)
  let len2 = calc.sqrt(v2x * v2x + v2y * v2y)

  if len1 < 1e-6 or len2 < 1e-6 { return }

  let u1 = (v1x / len1 * r, v1y / len1 * r)
  let u2 = (v2x / len2 * r, v2y / len2 * r)

  let P1 = (O.at(0) + u1.at(0), O.at(1) + u1.at(1))
  let P2 = (O.at(0) + u1.at(0) + u2.at(0), O.at(1) + u1.at(1) + u2.at(1))
  let P3 = (O.at(0) + u2.at(0), O.at(1) + u2.at(1))

  if to != none {
    d.line(O, P1, P2, P3, close: true, stroke: day + mau, fill: to)
  } else {
    d.line(P1, P2, P3, stroke: day + mau)
  }
}

/// Vẽ cung tròn ký hiệu góc giữa 3 điểm A-O-B kèm nhãn góc
#let ve-cung-goc(
  A,
  O,
  B,
  r: 0.45,
  nhan: none,
  mau: black,
  day: 0.75pt,
) = {
  let d = cetz.draw
  let ang1 = calc.atan2(A.at(0) - O.at(0), A.at(1) - O.at(1))
  let ang2 = calc.atan2(B.at(0) - O.at(0), B.at(1) - O.at(1))

  let start = ang1
  let delta = ang2 - ang1
  if delta < 0deg { delta += 360deg }
  if delta > 180deg {
    start = ang2
    delta = 360deg - delta
  }

  d.arc(O, start: start, delta: delta, radius: r, stroke: day + mau)

  if nhan != none {
    let mid-ang = start + delta / 2.0
    let lx = O.at(0) + (r + 0.22) * calc.cos(mid-ang)
    let ly = O.at(1) + (r + 0.22) * calc.sin(mid-ang)
    d.content((lx, ly))[#nhan]
  }
}

/// Vẽ mặt phẳng thiết diện (đa giác tô màu mờ)
#let ve-thiet-dien(
  pts,
  to: auto,
  mau: rgb("ef4444"),
  do-mo: 25%,
  vien: auto,
) = {
  let fill-color = if to != auto { to } else { mau.transparentize(100% - do-mo) }
  let stroke-style = if vien != auto { vien } else { 1.0pt + mau }
  let d = cetz.draw
  d.line(..pts, close: true, fill: fill-color, stroke: stroke-style)
}


// ─────────────────────────────────────────────────────────────
// 2. KHỐI CHÓP TAM GIÁC (PYRAMID S.ABC)
// ─────────────────────────────────────────────────────────────

/// Vẽ hình chóp tam giác S.ABC chuẩn SGK
///
/// - duong-cao: none | "dinh-a" (SA vuông đáy) | "tam" (SH vuông đáy tại trọng tâm H)
/// - ten: danh sách nhãn đỉnh ($S$, $A$, $B$, $C$)
/// - them: hàm callback d => { ... } cho phép vẽ thêm điểm, đoạn thẳng, thiết diện
#let hinh-chop-tam-giac(
  ten: ($S$, $A$, $B$, $C$),
  duong-cao: none,
  ten-chan: $H$,
  mau: black,
  mau-cao: rgb("dc2626"),
  day: 0.95pt,
  them: none,
) = {
  let d-draw = cetz.draw

  // Tọa độ chuẩn SGK: A ở bên trái, B ở giữa trước, C ở bên phải
  let d = (
    A: (0.0, 1.2),
    B: (2.8, 0.0),
    C: (4.6, 1.6),
    S: (1.8, 4.4),
  )

  if duong-cao == "dinh-a" {
    d.S = (d.A.at(0), d.A.at(1) + 3.4)
  } else if duong-cao == "tam" {
    let H = trong-tam(d.A, d.B, d.C)
    d.insert("H", H)
    d.S = (H.at(0), H.at(1) + 3.4)
  }

  // Cạnh nét liền: AB, BC, SA, SB, SC
  ve-doan(d.A, d.B, mau: mau, day: day)
  ve-doan(d.B, d.C, mau: mau, day: day)
  ve-doan(d.S, d.A, mau: mau, day: day)
  ve-doan(d.S, d.B, mau: mau, day: day)
  ve-doan(d.S, d.C, mau: mau, day: day)

  // Cạnh nét khuất: AC ở phía sau
  ve-doan(d.A, d.C, dut: true, mau: mau, day: day)

  // Đường cao nếu có
  if duong-cao == "dinh-a" {
    ve-goc-vuong(d.B, d.A, d.S, mau: mau-cao)
  } else if duong-cao == "tam" {
    let H = d.H
    ve-doan(d.S, H, dut: true, mau: mau-cao, day: 0.85pt)
    ve-goc-vuong(d.B, H, d.S, mau: mau-cao)
    ve-diem(H, ten: ten-chan, huong: "north", lech: (0.0, -0.2), mau: mau-cao)
  }

  // Gán nhãn các đỉnh
  let G = trong-tam(d.A, d.B, d.C, d.S)
  ve-diem(d.S, ten: ten.at(0), huong: "south", lech: (0.0, 0.15))
  ve-diem(d.A, ten: ten.at(1), huong: "east", lech: (-0.15, 0.0))
  ve-diem(d.B, ten: ten.at(2), huong: "north", lech: (0.0, -0.18))
  ve-diem(d.C, ten: ten.at(3), huong: "west", lech: (0.15, 0.0))

  // Callback vẽ thêm
  if them != none {
    them(d)
  }
}

// ─────────────────────────────────────────────────────────────
// 3. KHỐI CHÓP TỨ GIÁC (PYRAMID S.ABCD)
// ─────────────────────────────────────────────────────────────

/// Vẽ hình chóp tứ giác S.ABCD (đáy hình bình hành / chữ nhật / vuông) chuẩn SGK
///
/// - duong-cao: none | "dinh-a" (SA vuông đáy) | "tam" (SO vuông đáy tại tâm O)
/// - duong-cheo: vẽ 2 đường chéo đáy nét đứt kèm tâm O
/// - them: callback d => { ... } nhận vào d = (S, A, B, C, D, O...)
#let hinh-chop-tu-giac(
  ten: ($S$, $A$, $B$, $C$, $D$),
  duong-cao: none,
  duong-cheo: false,
  ten-tam: $O$,
  mau: black,
  mau-cao: rgb("dc2626"),
  day: 0.95pt,
  them: none,
) = {
  // Tọa độ chuẩn SGK:
  // AD nét đứt phía sau bên trái, AB nét đứt phía sau bên phải
  let d = (
    A: (1.4, 1.6),
    B: (5.4, 1.6),
    C: (4.0, 0.0),
    D: (0.0, 0.0),
    S: (1.4, 4.8), // Mặc định SA vuông đáy
  )

  let O = trung-diem(d.A, d.C)
  d.insert("O", O)

  if duong-cao == "tam" {
    d.S = (O.at(0), O.at(1) + 3.6)
  } else if duong-cao == none {
    d.S = (2.6, 4.6)
  }

  // Nét liền: CD, BC, SC, SD, SB
  ve-doan(d.D, d.C, mau: mau, day: day)
  ve-doan(d.B, d.C, mau: mau, day: day)
  ve-doan(d.S, d.B, mau: mau, day: day)
  ve-doan(d.S, d.C, mau: mau, day: day)
  ve-doan(d.S, d.D, mau: mau, day: day)

  // Nét đứt: AB, AD, SA (vì A ở góc khuất phía sau)
  ve-doan(d.A, d.B, dut: true, mau: mau, day: day)
  ve-doan(d.A, d.D, dut: true, mau: mau, day: day)
  ve-doan(d.S, d.A, dut: true, mau: mau, day: day)

  // Đường chéo đáy nếu bật hoặc khi duong-cao == "tam"
  if duong-cheo or duong-cao == "tam" {
    ve-doan(d.A, d.C, dut: true, mau: rgb("64748b"), day: 0.75pt)
    ve-doan(d.B, d.D, dut: true, mau: rgb("64748b"), day: 0.75pt)
    ve-diem(O, ten: ten-tam, huong: "north", lech: (0.0, -0.16), bk: 1.8pt)
  }

  // Đường cao
  if duong-cao == "dinh-a" {
    ve-goc-vuong(d.D, d.A, d.S, mau: mau-cao)
    ve-goc-vuong(d.B, d.A, d.S, mau: mau-cao)
  } else if duong-cao == "tam" {
    ve-doan(d.S, O, dut: true, mau: mau-cao, day: 0.85pt)
    ve-goc-vuong(d.C, O, d.S, mau: mau-cao)
  }

  // Nhãn đỉnh
  ve-diem(d.S, ten: ten.at(0), huong: "south", lech: (0.0, 0.15))
  ve-diem(d.A, ten: ten.at(1), huong: "south", lech: (-0.12, 0.12))
  ve-diem(d.B, ten: ten.at(2), huong: "west", lech: (0.15, 0.0))
  ve-diem(d.C, ten: ten.at(3), huong: "north", lech: (0.12, -0.15))
  ve-diem(d.D, ten: ten.at(4), huong: "north", lech: (-0.12, -0.15))

  if them != none {
    them(d)
  }
}

// ─────────────────────────────────────────────────────────────
// 4. KHỐI CHÓP ĐỀU (REGULAR PYRAMIDS)
// ─────────────────────────────────────────────────────────────

/// Vẽ chóp tam giác đều S.ABC (đáy là tam giác đều, SO vuông góc đáy tại tâm O)
#let hinh-chop-tam-giac-deu(
  ten: ($S$, $A$, $B$, $C$),
  ten-tam: $O$,
  trung-tuyen: false,
  ten-trung-diem: $M$,
  them: none,
) = {
  let d = (
    A: (0.0, 1.4),
    B: (2.4, 0.0),
    C: (5.0, 1.4),
  )
  let O = trong-tam(d.A, d.B, d.C)
  let S = (O.at(0), O.at(1) + 3.8)
  d.insert("O", O)
  d.insert("S", S)

  // Cạnh đáy
  ve-doan(d.A, d.B, day: 0.95pt)
  ve-doan(d.B, d.C, day: 0.95pt)
  ve-doan(d.A, d.C, dut: true, day: 0.95pt)

  // Cạnh bên
  ve-doan(S, d.A, day: 0.95pt)
  ve-doan(S, d.B, day: 0.95pt)
  ve-doan(S, d.C, day: 0.95pt)

  // Đường cao SO
  ve-doan(S, O, dut: true, mau: rgb("dc2626"), day: 0.85pt)
  ve-goc-vuong(d.B, O, S, mau: rgb("dc2626"))
  ve-diem(O, ten: ten-tam, huong: "north", lech: (0.0, -0.18))

  // Trung tuyến AM nếu bật
  if trung-tuyen {
    let M = trung-diem(d.B, d.C)
    d.insert("M", M)
    ve-doan(d.A, M, dut: true, mau: rgb("64748b"), day: 0.75pt)
    ve-diem(M, ten: ten-trung-diem, huong: "west", lech: (0.12, 0.0), bk: 1.8pt)
  }

  // Nhãn đỉnh
  ve-diem(S, ten: ten.at(0), huong: "south", lech: (0.0, 0.15))
  ve-diem(d.A, ten: ten.at(1), huong: "east", lech: (-0.15, 0.0))
  ve-diem(d.B, ten: ten.at(2), huong: "north", lech: (0.0, -0.18))
  ve-diem(d.C, ten: ten.at(3), huong: "west", lech: (0.15, 0.0))

  if them != none {
    them(d)
  }
}

/// Vẽ chóp tứ giác đều S.ABCD (SO vuông góc đáy tại giao điểm hai đường chéo O)
#let hinh-chop-tu-giac-deu(
  ten: ($S$, $A$, $B$, $C$, $D$),
  ten-tam: $O$,
  duong-cao: true,
  them: none,
  ..rest,
) = {
  hinh-chop-tu-giac(
    ten: ten,
    duong-cao: if duong-cao { "tam" } else { none },
    duong-cheo: true,
    ten-tam: ten-tam,
    them: them,
    ..rest,
  )
}

/// Vẽ chóp tam diện vuông O.ABC (vuông tại gốc O: OA, OB, OC đôi một vuông góc)
#let hinh-chop-tam-dien-vuong(
  ten: ($O$, $A$, $B$, $C$),
  them: none,
) = {
  let d = (
    O: (1.2, 1.2),
    A: (1.2, 4.4),
    B: (4.8, 1.2),
    C: (0.0, 0.0),
  )

  // Nét đứt từ gốc O
  ve-doan(d.O, d.A, dut: true)
  ve-doan(d.O, d.B, dut: true)
  ve-doan(d.O, d.C, dut: true)

  // Nét liền đáy ABC
  ve-doan(d.A, d.B)
  ve-doan(d.B, d.C)
  ve-doan(d.C, d.A)

  // Ba ký hiệu góc vuông tại O
  ve-goc-vuong(d.A, d.O, d.B, r: 0.25)
  ve-goc-vuong(d.A, d.O, d.C, r: 0.25)
  ve-goc-vuong(d.B, d.O, d.C, r: 0.25)

  // Nhãn điểm
  ve-diem(d.O, ten: ten.at(0), huong: "south", lech: (0.12, 0.12))
  ve-diem(d.A, ten: ten.at(1), huong: "south", lech: (0.0, 0.15))
  ve-diem(d.B, ten: ten.at(2), huong: "west", lech: (0.15, 0.0))
  ve-diem(d.C, ten: ten.at(3), huong: "north", lech: (-0.12, -0.15))

  if them != none {
    them(d)
  }
}

// ─────────────────────────────────────────────────────────────
// 5. HÌNH LĂNG TRỤ & HÌNH HỘP (PRISMS & BOXES)
// ─────────────────────────────────────────────────────────────

/// Vẽ hình lăng trụ tam giác ABC.A'B'C' (đứng hoặc xiên)
#let hinh-lang-tru-tam-giac(
  ten: ($A$, $B$, $C$, $A'$, $B'$, $C'$),
  dung: true,
  them: none,
) = {
  let dx = if dung { 0.0 } else { 0.6 }
  let dy = 3.2

  let d = (
    A: (0.0, 1.0),
    B: (2.6, 0.0),
    C: (4.2, 1.3),
    A_prime: (dx, 1.0 + dy),
    B_prime: (2.6 + dx, dy),
    C_prime: (4.2 + dx, 1.3 + dy),
    A1: (dx, 1.0 + dy),
    B1: (2.6 + dx, dy),
    C1: (4.2 + dx, 1.3 + dy),
  )

  // Đáy dưới: AB, BC liền; AC đứt
  ve-doan(d.A, d.B)
  ve-doan(d.B, d.C)
  ve-doan(d.A, d.C, dut: true)

  // Đáy trên: A'B'C' liền toàn bộ
  ve-doan(d.A_prime, d.B_prime)
  ve-doan(d.B_prime, d.C_prime)
  ve-doan(d.C_prime, d.A_prime)

  // Cạnh bên: BB', CC' liền; AA' đứt
  ve-doan(d.B, d.B_prime)
  ve-doan(d.C, d.C_prime)
  ve-doan(d.A, d.A_prime, dut: true)

  // Nhãn điểm
  ve-diem(d.A, ten: ten.at(0), huong: "east", lech: (-0.15, 0.0))
  ve-diem(d.B, ten: ten.at(1), huong: "north", lech: (0.0, -0.18))
  ve-diem(d.C, ten: ten.at(2), huong: "west", lech: (0.15, 0.0))
  ve-diem(d.A_prime, ten: ten.at(3), huong: "east", lech: (-0.15, 0.0))
  ve-diem(d.B_prime, ten: ten.at(4), huong: "south", lech: (0.0, 0.18))
  ve-diem(d.C_prime, ten: ten.at(5), huong: "west", lech: (0.15, 0.0))

  if them != none {
    them(d)
  }
}

/// Vẽ hình hộp chữ nhật / hình lập phương ABCD.A'B'C'D'
#let hinh-hop(
  ten: ($A$, $B$, $C$, $D$, $A'$, $B'$, $C'$, $D'$),
  duong-cheo: false,
  them: none,
) = {
  let dy = 2.8
  let d = (
    A: (1.2, 1.4),
    B: (4.8, 1.4),
    C: (3.6, 0.0),
    D: (0.0, 0.0),
    A_prime: (1.2, 1.4 + dy),
    B_prime: (4.8, 1.4 + dy),
    C_prime: (3.6, dy),
    D_prime: (0.0, dy),
    A1: (1.2, 1.4 + dy),
    B1: (4.8, 1.4 + dy),
    C1: (3.6, dy),
    D1: (0.0, dy),
  )

  // Đáy dưới: DC, BC liền; AB, AD đứt
  ve-doan(d.D, d.C)
  ve-doan(d.B, d.C)
  ve-doan(d.A, d.B, dut: true)
  ve-doan(d.A, d.D, dut: true)

  // Đáy trên: toàn bộ liền
  ve-doan(d.A_prime, d.B_prime)
  ve-doan(d.B_prime, d.C_prime)
  ve-doan(d.C_prime, d.D_prime)
  ve-doan(d.D_prime, d.A_prime)

  // Cạnh bên: BB', CC', DD' liền; AA' đứt
  ve-doan(d.B, d.B_prime)
  ve-doan(d.C, d.C_prime)
  ve-doan(d.D, d.D_prime)
  ve-doan(d.A, d.A_prime, dut: true)

  // Đường chéo lớn AC' nếu bật
  if duong-cheo {
    ve-doan(d.A, d.C_prime, dut: true, mau: rgb("dc2626"), day: 0.85pt)
  }

  // Nhãn điểm
  ve-diem(d.A, ten: ten.at(0), huong: "south-east", lech: (-0.12, 0.12))
  ve-diem(d.B, ten: ten.at(1), huong: "west", lech: (0.15, 0.0))
  ve-diem(d.C, ten: ten.at(2), huong: "north", lech: (0.12, -0.15))
  ve-diem(d.D, ten: ten.at(3), huong: "east", lech: (-0.15, 0.0))

  ve-diem(d.A_prime, ten: ten.at(4), huong: "south-east", lech: (-0.12, 0.12))
  ve-diem(d.B_prime, ten: ten.at(5), huong: "west", lech: (0.15, 0.0))
  ve-diem(d.C_prime, ten: ten.at(6), huong: "north", lech: (0.12, -0.15))
  ve-diem(d.D_prime, ten: ten.at(7), huong: "east", lech: (-0.15, 0.0))

  if them != none {
    them(d)
  }
}

#let hinh-hop-chu-nhat = hinh-hop
#let hinh-lap-phuong = hinh-hop

// ─────────────────────────────────────────────────────────────
// 6. KHỐI TRÒN XOAY CHUẨN SGK (NÓN, TRỤ, CẦU)
// ─────────────────────────────────────────────────────────────

/// Vẽ cung elip bằng cách lấy mẫu tham số chuẩn xác (tránh lỗi méo dạng)
#let ve-cung-elip(
  O,
  rx,
  ry,
  start: 0deg,
  stop: 360deg,
  dut: false,
  mau: black,
  day: 0.95pt,
  n: 36,
) = {
  let d = cetz.draw
  let pts = ()
  let d_ang = (stop - start) / float(n)
  for i in range(n + 1) {
    let ang = start + float(i) * d_ang
    pts.push((
      O.at(0) + rx * calc.cos(ang),
      O.at(1) + ry * calc.sin(ang),
    ))
  }
  let st = if dut {
    (paint: mau, thickness: day, dash: "dashed")
  } else {
    day + mau
  }
  d.line(..pts, stroke: st)
}

/// Vẽ hình nón tròn xoay chuẩn SGK (đỉnh S, đáy elip tâm O, trục SO nét đứt)
#let hinh-non-thpt(
  ten: ($S$, $O$, $A$, $B$),
  r: 2.0,
  h: 3.5,
  b: 0.55,
  them: none,
) = {
  let O = (0.0, 0.0)
  let S = (0.0, h)
  let A = (-r, 0.0)
  let B = (r, 0.0)

  let d = (S: S, O: O, A: A, B: B)

  // Đường sinh ngoài
  ve-doan(S, A)
  ve-doan(S, B)

  // Trục SO nét đứt
  ve-doan(S, O, dut: true, mau: rgb("dc2626"))
  ve-goc-vuong(B, O, S, r: 0.22, mau: rgb("dc2626"))

  // Bán kính đáy OB nét đứt
  ve-doan(O, B, dut: true, mau: rgb("64748b"))

  // Đáy elip: nửa trước liền, nửa sau đứt
  ve-cung-elip(O, r, b, start: 180deg, stop: 360deg, dut: false, mau: black, day: 0.95pt)
  ve-cung-elip(O, r, b, start: 0deg, stop: 180deg, dut: true, mau: rgb("94a3b8"), day: 0.75pt)

  // Điểm và nhãn
  ve-diem(S, ten: ten.at(0), huong: "south", lech: (0.0, 0.15))
  ve-diem(O, ten: ten.at(1), huong: "north", lech: (0.0, -0.15), bk: 1.8pt)
  ve-diem(A, ten: ten.at(2), huong: "east", lech: (-0.15, 0.0))
  ve-diem(B, ten: ten.at(3), huong: "west", lech: (0.15, 0.0))

  if them != none {
    them(d)
  }
}

/// Vẽ hình trụ tròn xoay chuẩn SGK (đáy trên O', đáy dưới O, trục OO')
#let hinh-tru-thpt(
  ten: ($O$, $O'$, $A$, $B$, $A'$, $B'$),
  r: 1.8,
  h: 3.2,
  b: 0.5,
  them: none,
) = {
  let O = (0.0, 0.0)
  let O_prime = (0.0, h)
  let A = (-r, 0.0)
  let B = (r, 0.0)
  let A_prime = (-r, h)
  let B_prime = (r, h)

  let d = (O: O, O_prime: O_prime, A: A, B: B, A_prime: A_prime, B_prime: B_prime)

  // Hai đường sinh ngoài
  ve-doan(A, A_prime)
  ve-doan(B, B_prime)

  // Trục OO' nét đứt
  ve-doan(O, O_prime, dut: true, mau: rgb("dc2626"))

  // Bán kính đáy OB và O'B'
  ve-doan(O, B, dut: true, mau: rgb("64748b"))
  ve-doan(O_prime, B_prime, mau: rgb("64748b"))

  // Đáy trên: elip liền toàn bộ
  ve-cung-elip(O_prime, r, b, start: 0deg, stop: 360deg, dut: false, mau: black, day: 0.95pt)

  // Đáy dưới: nửa trước liền, nửa sau đứt
  ve-cung-elip(O, r, b, start: 180deg, stop: 360deg, dut: false, mau: black, day: 0.95pt)
  ve-cung-elip(O, r, b, start: 0deg, stop: 180deg, dut: true, mau: rgb("94a3b8"), day: 0.75pt)

  // Nhãn điểm
  ve-diem(O, ten: ten.at(0), huong: "north", lech: (0.0, -0.15), bk: 1.8pt)
  ve-diem(O_prime, ten: ten.at(1), huong: "south", lech: (0.0, 0.15), bk: 1.8pt)
  ve-diem(A, ten: ten.at(2), huong: "east", lech: (-0.15, 0.0))
  ve-diem(B, ten: ten.at(3), huong: "west", lech: (0.15, 0.0))
  ve-diem(A_prime, ten: ten.at(4), huong: "east", lech: (-0.15, 0.0))
  ve-diem(B_prime, ten: ten.at(5), huong: "west", lech: (0.15, 0.0))

  if them != none {
    them(d)
  }
}

/// Vẽ khối cầu chuẩn SGK (đường tròn bao ngoài, đường elip xích đạo)
#let hinh-cau-thpt(
  ten: ($O$, $R$),
  r: 2.2,
  b: 0.6,
  them: none,
) = {
  let d_cetz = cetz.draw
  let O = (0.0, 0.0)
  let A = (r, 0.0)
  let d = (O: O, A: A)

  // Đường tròn lớn silhouette bao ngoài
  d_cetz.circle(O, radius: r, stroke: 0.95pt + black)

  // Bán kính R từ tâm O ra mép phải
  ve-doan(O, A, dut: true, mau: rgb("dc2626"), ten: ten.at(1), ten-huong: "south")

  // Xích đạo: nửa trước liền, nửa sau đứt
  ve-cung-elip(O, r, b, start: 180deg, stop: 360deg, dut: false, mau: black, day: 0.95pt)
  ve-cung-elip(O, r, b, start: 0deg, stop: 180deg, dut: true, mau: rgb("94a3b8"), day: 0.75pt)

  // Nhãn tâm O
  ve-diem(O, ten: ten.at(0), huong: "north", lech: (0.0, -0.16), bk: 1.8pt)

  if them != none {
    them(d)
  }
}

// ─────────────────────────────────────────────────────────────
// 7. HÌNH CHÓP LỤC GIÁC & LĂNG TRỤ LỤC GIÁC & CHÓP CỤT ĐỀU
// ─────────────────────────────────────────────────────────────

/// Vẽ hình chóp lục giác đều S.ABCDEF
#let hinh-chop-luc-giac-deu(
  ten: ($S$, $A$, $B$, $C$, $D$, $E$, $F$),
  duong-cao: true,
  ten-tam: $O$,
  mau: black,
  mau-cao: rgb("dc2626"),
  day: 0.95pt,
  them: none,
) = {
  let A = (-2.0, 0.4)
  let B = (-0.9, -0.6)
  let C = (1.1, -0.6)
  let D = (2.1, 0.4)
  let E = (1.0, 1.4)
  let F = (-0.9, 1.4)
  let O = (0.1, 0.4)
  let S = (0.1, 4.2)

  let d = (S: S, O: O, A: A, B: B, C: C, D: D, E: E, F: F)

  // Cạnh đáy phía trước: AB, BC, CD (liền)
  ve-doan(A, B, mau: mau, day: day)
  ve-doan(B, C, mau: mau, day: day)
  ve-doan(C, D, mau: mau, day: day)

  // Cạnh đáy phía sau: DE, EF, FA (đứt)
  ve-doan(D, E, dut: true, mau: mau, day: day)
  ve-doan(E, F, dut: true, mau: mau, day: day)
  ve-doan(F, A, dut: true, mau: mau, day: day)

  // Cạnh bên phía trước: SA, SB, SC, SD (liền)
  ve-doan(S, A, mau: mau, day: day)
  ve-doan(S, B, mau: mau, day: day)
  ve-doan(S, C, mau: mau, day: day)
  ve-doan(S, D, mau: mau, day: day)

  // Cạnh bên phía sau: SE, SF (đứt)
  ve-doan(S, E, dut: true, mau: mau, day: day)
  ve-doan(S, F, dut: true, mau: mau, day: day)

  // Đường cao SO nếu bật
  if duong-cao {
    ve-doan(S, O, dut: true, mau: mau-cao, day: 0.85pt)
    ve-doan(O, D, dut: true, mau: rgb("94a3b8"), day: 0.75pt)
    ve-goc-vuong(D, O, S, r: 0.2, mau: mau-cao)
    ve-diem(O, ten: ten-tam, huong: "north", lech: (0.0, -0.15), bk: 1.6pt, mau: mau-cao)
  }

  // Nhãn các đỉnh
  ve-diem(S, ten: ten.at(0), huong: "south", lech: (0.0, 0.15))
  ve-diem(A, ten: ten.at(1), huong: "east", lech: (-0.15, 0.0))
  ve-diem(B, ten: ten.at(2), huong: "north", lech: (-0.1, -0.15))
  ve-diem(C, ten: ten.at(3), huong: "north", lech: (0.1, -0.15))
  ve-diem(D, ten: ten.at(4), huong: "west", lech: (0.15, 0.0))
  ve-diem(E, ten: ten.at(5), huong: "south", lech: (0.1, 0.15))
  ve-diem(F, ten: ten.at(6), huong: "south", lech: (-0.1, 0.15))

  if them != none {
    them(d)
  }
}

/// Vẽ hình lăng trụ lục giác đều ABCDEF.A'B'C'D'E'F'
#let hinh-lang-tru-luc-giac-deu(
  ten: ($A$, $B$, $C$, $D$, $E$, $F$, $A'$, $B'$, $C'$, $D'$, $E'$, $F'$),
  h: 3.2,
  mau: black,
  day: 0.95pt,
  them: none,
) = {
  let A = (-2.0, 0.4)
  let B = (-0.9, -0.6)
  let C = (1.1, -0.6)
  let D = (2.1, 0.4)
  let E = (1.0, 1.4)
  let F = (-0.9, 1.4)

  let A_prime = (A.at(0), A.at(1) + h)
  let B_prime = (B.at(0), B.at(1) + h)
  let C_prime = (C.at(0), C.at(1) + h)
  let D_prime = (D.at(0), D.at(1) + h)
  let E_prime = (E.at(0), E.at(1) + h)
  let F_prime = (F.at(0), F.at(1) + h)

  let d = (
    A: A, B: B, C: C, D: D, E: E, F: F,
    A_prime: A_prime, B_prime: B_prime, C_prime: C_prime,
    D_prime: D_prime, E_prime: E_prime, F_prime: F_prime,
  )

  // Đáy trên: toàn bộ liền
  ve-doan(A_prime, B_prime, mau: mau, day: day)
  ve-doan(B_prime, C_prime, mau: mau, day: day)
  ve-doan(C_prime, D_prime, mau: mau, day: day)
  ve-doan(D_prime, E_prime, mau: mau, day: day)
  ve-doan(E_prime, F_prime, mau: mau, day: day)
  ve-doan(F_prime, A_prime, mau: mau, day: day)

  // Đáy dưới: trước liền, sau đứt
  ve-doan(A, B, mau: mau, day: day)
  ve-doan(B, C, mau: mau, day: day)
  ve-doan(C, D, mau: mau, day: day)
  ve-doan(D, E, dut: true, mau: mau, day: day)
  ve-doan(E, F, dut: true, mau: mau, day: day)
  ve-doan(F, A, dut: true, mau: mau, day: day)

  // Cạnh bên: AA', BB', CC', DD' liền; EE', FF' đứt
  ve-doan(A, A_prime, mau: mau, day: day)
  ve-doan(B, B_prime, mau: mau, day: day)
  ve-doan(C, C_prime, mau: mau, day: day)
  ve-doan(D, D_prime, mau: mau, day: day)
  ve-doan(E, E_prime, dut: true, mau: mau, day: day)
  ve-doan(F, F_prime, dut: true, mau: mau, day: day)

  // Gán nhãn
  ve-diem(A, ten: ten.at(0), huong: "east", lech: (-0.12, 0.0))
  ve-diem(B, ten: ten.at(1), huong: "north", lech: (-0.1, -0.15))
  ve-diem(C, ten: ten.at(2), huong: "north", lech: (0.1, -0.15))
  ve-diem(D, ten: ten.at(3), huong: "west", lech: (0.12, 0.0))
  ve-diem(E, ten: ten.at(4), huong: "south", lech: (0.1, 0.15))
  ve-diem(F, ten: ten.at(5), huong: "south", lech: (-0.1, 0.15))

  ve-diem(A_prime, ten: ten.at(6), huong: "east", lech: (-0.12, 0.0))
  ve-diem(B_prime, ten: ten.at(7), huong: "north", lech: (-0.1, -0.15))
  ve-diem(C_prime, ten: ten.at(8), huong: "north", lech: (0.1, -0.15))
  ve-diem(D_prime, ten: ten.at(9), huong: "west", lech: (0.12, 0.0))
  ve-diem(E_prime, ten: ten.at(10), huong: "south", lech: (0.1, 0.15))
  ve-diem(F_prime, ten: ten.at(11), huong: "south", lech: (-0.1, 0.15))

  if them != none {
    them(d)
  }
}

/// Vẽ hình chóp cụt đều tứ giác ABCD.A'B'C'D'
#let hinh-chop-cut-deu(
  ten: ($A$, $B$, $C$, $D$, $A'$, $B'$, $C'$, $D'$),
  truc: true,
  ten-tam: ($O$, $O'$),
  mau: black,
  mau-cao: rgb("dc2626"),
  day: 0.95pt,
  them: none,
) = {
  // Đáy dưới lớn
  let A = (0.0, 1.2)
  let B = (1.4, 0.0)
  let C = (4.8, 0.0)
  let D = (3.4, 1.2)
  let O = trung-diem(A, C)

  // Đáy trên nhỏ hơn (tỉ lệ 0.55, dịch lên cao 2.8)
  let k = 0.55
  let h = 2.8
  let O_prime = (O.at(0), O.at(1) + h)

  let A_prime = (O_prime.at(0) + (A.at(0) - O.at(0)) * k, O_prime.at(1) + (A.at(1) - O.at(1)) * k)
  let B_prime = (O_prime.at(0) + (B.at(0) - O.at(0)) * k, O_prime.at(1) + (B.at(1) - O.at(1)) * k)
  let C_prime = (O_prime.at(0) + (C.at(0) - O.at(0)) * k, O_prime.at(1) + (C.at(1) - O.at(1)) * k)
  let D_prime = (O_prime.at(0) + (D.at(0) - O.at(0)) * k, O_prime.at(1) + (D.at(1) - O.at(1)) * k)

  let d = (
    A: A, B: B, C: C, D: D, O: O,
    A_prime: A_prime, B_prime: B_prime, C_prime: C_prime, D_prime: D_prime, O_prime: O_prime,
  )

  // Đáy trên: toàn bộ nét liền
  ve-doan(A_prime, B_prime, mau: mau, day: day)
  ve-doan(B_prime, C_prime, mau: mau, day: day)
  ve-doan(C_prime, D_prime, mau: mau, day: day)
  ve-doan(D_prime, A_prime, mau: mau, day: day)

  // Đáy dưới: BC, CD liền; AB, AD đứt
  ve-doan(B, C, mau: mau, day: day)
  ve-doan(C, D, mau: mau, day: day)
  ve-doan(A, B, dut: true, mau: mau, day: day)
  ve-doan(A, D, dut: true, mau: mau, day: day)

  // Cạnh bên: BB', CC', DD' liền; AA' đứt
  ve-doan(B, B_prime, mau: mau, day: day)
  ve-doan(C, C_prime, mau: mau, day: day)
  ve-doan(D, D_prime, mau: mau, day: day)
  ve-doan(A, A_prime, dut: true, mau: mau, day: day)

  // Trục OO'
  if truc {
    ve-doan(O, O_prime, dut: true, mau: mau-cao, day: 0.85pt)
    ve-diem(O, ten: ten-tam.at(0), huong: "north", lech: (0.0, -0.15), bk: 1.6pt, mau: mau-cao)
    ve-diem(O_prime, ten: ten-tam.at(1), huong: "south", lech: (0.0, 0.15), bk: 1.6pt, mau: mau-cao)
  }

  // Nhãn các đỉnh
  ve-diem(A, ten: ten.at(0), huong: "south", lech: (-0.12, 0.12))
  ve-diem(B, ten: ten.at(1), huong: "north", lech: (0.0, -0.16))
  ve-diem(C, ten: ten.at(2), huong: "north", lech: (0.14, -0.14))
  ve-diem(D, ten: ten.at(3), huong: "west", lech: (0.15, 0.0))

  ve-diem(A_prime, ten: ten.at(4), huong: "south", lech: (-0.12, 0.12))
  ve-diem(B_prime, ten: ten.at(5), huong: "north", lech: (0.0, -0.16))
  ve-diem(C_prime, ten: ten.at(6), huong: "north", lech: (0.14, -0.14))
  ve-diem(D_prime, ten: ten.at(7), huong: "west", lech: (0.15, 0.0))

  if them != none {
    them(d)
  }
}

// ─────────────────────────────────────────────────────────────
// 8. TIỆN ÍCH VẼ MẶT PHẲNG VÀ KHÔNG GIAN BỔ TRỢ
// ─────────────────────────────────────────────────────────────

/// Vẽ hình bình hành biểu diễn mặt phẳng không gian (alpha), (P)...
#let ve-mat-phang-khong-gian(
  goc: (0.0, 0.0),
  dai: 5.0,
  rong: 2.2,
  nghieng: 1.4,
  ten: $(alpha)$,
  mau: rgb("0284c7"),
  do-mo: 10%,
) = {
  let d_cetz = cetz.draw
  let A = goc
  let B = (A.at(0) + dai, A.at(1))
  let C = (B.at(0) + nghieng, B.at(1) + rong)
  let D = (A.at(0) + nghieng, A.at(1) + rong)

  d_cetz.line(A, B, C, D, close: true, fill: mau.transparentize(100% - do-mo), stroke: 0.95pt + mau)
  if ten != none {
    let p_ten = (A.at(0) + 0.6, A.at(1) + 0.5)
    d_cetz.circle(p_ten, radius: 0.35, stroke: 0.8pt + mau)
    d_cetz.content(p_ten, anchor: "center", text(size: 9pt, fill: mau, weight: "bold")[#ten])
  }
}

// ─────────────────────────────────────────────────────────────
// 9. CÁC HÀM BAO ĐÓNG CANVAS ĐỘC LẬP (-FIG)
// Cho phép giáo viên chèn trực tiếp 1 dòng vào bài giảng / đề thi
// ─────────────────────────────────────────────────────────────

#let hinh-chop-tam-giac-fig(..args) = cetz.canvas({ hinh-chop-tam-giac(..args) })
#let hinh-chop-tu-giac-fig(..args) = cetz.canvas({ hinh-chop-tu-giac(..args) })
#let hinh-chop-tam-giac-deu-fig(..args) = cetz.canvas({ hinh-chop-tam-giac-deu(..args) })
#let hinh-chop-tu-giac-deu-fig(..args) = cetz.canvas({ hinh-chop-tu-giac-deu(..args) })
#let hinh-chop-tam-dien-vuong-fig(..args) = cetz.canvas({ hinh-chop-tam-dien-vuong(..args) })
#let hinh-chop-luc-giac-deu-fig(..args) = cetz.canvas({ hinh-chop-luc-giac-deu(..args) })
#let hinh-lang-tru-tam-giac-fig(..args) = cetz.canvas({ hinh-lang-tru-tam-giac(..args) })
#let hinh-hop-fig(..args) = cetz.canvas({ hinh-hop(..args) })
#let hinh-hop-chu-nhat-fig = hinh-hop-fig
#let hinh-lap-phuong-fig = hinh-hop-fig
#let hinh-lang-tru-luc-giac-deu-fig(..args) = cetz.canvas({ hinh-lang-tru-luc-giac-deu(..args) })
#let hinh-chop-cut-deu-fig(..args) = cetz.canvas({ hinh-chop-cut-deu(..args) })
#let hinh-non-thpt-fig(..args) = cetz.canvas({ hinh-non-thpt(..args) })
#let hinh-tru-thpt-fig(..args) = cetz.canvas({ hinh-tru-thpt(..args) })
#let hinh-cau-thpt-fig(..args) = cetz.canvas({ hinh-cau-thpt(..args) })

// Các bí danh ngắn gọn thuận tiện cho người dùng:
#let chop-s-abcd = hinh-chop-tu-giac
#let chop-s-abcd-fig = hinh-chop-tu-giac-fig
#let chop-s-abc = hinh-chop-tam-giac
#let chop-s-abc-fig = hinh-chop-tam-giac-fig
#let chop-deu-tam-giac-fig = hinh-chop-tam-giac-deu-fig
#let chop-deu-tu-giac-fig = hinh-chop-tu-giac-deu-fig
#let lang-tru-tam-giac-fig = hinh-lang-tru-tam-giac-fig
#let hop-chu-nhat-fig = hinh-hop-chu-nhat-fig
#let lap-phuong-fig = hinh-lap-phuong-fig
#let non-fig = hinh-non-thpt-fig
#let tru-fig = hinh-tru-thpt-fig
#let cau-fig = hinh-cau-thpt-fig
#let chop-cut-deu = hinh-chop-cut-deu
#let chop-cut-deu-fig = hinh-chop-cut-deu-fig
#let tam-dien-vuong = hinh-chop-tam-dien-vuong
#let tam-dien-vuong-fig = hinh-chop-tam-dien-vuong-fig
