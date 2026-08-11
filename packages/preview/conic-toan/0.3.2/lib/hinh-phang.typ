// =====================================================================
// hinh-phang.typ — HÌNH HỌC PHẲNG THPT
// Tam giác + các đường đặc biệt, tứ giác, đường tròn nội/ngoại tiếp,
// tiếp tuyến, giao hai đường tròn, đường tròn lượng giác...
// Mọi hàm nhận ctx từ #hinh (xem ve.typ). Toạ độ nên dùng 2 trục cùng tỉ lệ
// (để h: auto trong #hinh).
// =====================================================================
#import "ve.typ": *

// Hướng nhãn tự động: đẩy nhãn ra xa điểm G (thường là trọng tâm hình).
#let huong-ra(P, G) = {
  let d = calc.atan2(P.at(0) - G.at(0), P.at(1) - G.at(1)).deg()
  if d < 0 { d = d + 360 }
  let idx = calc.rem(calc.floor((d + 22.5) / 45), 8)
  ("phai", "tren-phai", "tren", "tren-trai", "trai", "duoi-trai", "duoi", "duoi-phai").at(idx)
}

// Trọng tâm của dãy điểm.
#let trong-tam(..pts) = {
  let ds = pts.pos()
  let n = ds.len()
  (
    ds.map(P => P.at(0)).sum() / n,
    ds.map(P => P.at(1)).sum() / n,
  )
}

// Vẽ đa giác + nhãn đỉnh tự động hướng ra ngoài.
// ten: mảng nội dung nhãn (cùng độ dài số đỉnh) hoặc none.
#let da-giac-ten(ctx, dinh, ten: none, mau: black, day: 1.1pt, to: none, cham: true) = {
  da-giac(ctx, dinh, mau: mau, day: day, to: to)
  let G = trong-tam(..dinh)
  if ten != none {
    for (P, t) in dinh.zip(ten) {
      if cham {
        diem(ctx, P, ten: t, huong: huong-ra(P, G))
      } else {
        nhan(ctx, P, t, huong: huong-ra(P, G))
      }
    }
  }
}

// ---------- Tam giác ----------
#let tam-giac(ctx, A, B, C, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, cham: true) = {
  da-giac-ten(ctx, (A, B, C), ten: ten, mau: mau, day: day, to: to, cham: cham)
}

// Đường cao hạ từ P xuống đường thẳng AB (kèm ký hiệu vuông góc).
// ten-chan: nhãn chân đường cao (vd $H$).
#let duong-cao(ctx, P, A, B, ten-chan: none, mau: red, day: 1pt, dut: false, vuong: true) = {
  let H = hinh-chieu(P, A, B)
  doan(ctx, P, H, mau: mau, day: day, dut: dut)
  if vuong {
    let Q = if khoang-cach(H, A) > khoang-cach(H, B) { A } else { B }
    goc-vuong(ctx, H, P, Q, mau: mau)
  }
  if ten-chan != none {
    diem(ctx, H, ten: ten-chan, huong: huong-ra(H, trong-tam(P, A, B)))
  }
}

// Trung tuyến từ P đến trung điểm AB (kèm 2 vạch đánh dấu bằng nhau).
#let trung-tuyen(ctx, P, A, B, ten-chan: none, mau: blue, day: 1pt, dut: false, so-vach: 1) = {
  let M = trung-diem(A, B)
  doan(ctx, P, M, mau: mau, day: day, dut: dut)
  danh-dau(ctx, A, M, so: so-vach, mau: mau)
  danh-dau(ctx, M, B, so: so-vach, mau: mau)
  if ten-chan != none {
    diem(ctx, M, ten: ten-chan, huong: huong-ra(M, trong-tam(P, A, B)))
  }
}

// Phân giác trong góc O của tam giác OAB (kèm 2 cung đánh dấu góc bằng nhau).
#let phan-giac(ctx, O, A, B, ten-chan: none, mau: green.darken(20%), day: 1pt, dut: false, r-cung: 0.5) = {
  let oa = khoang-cach(O, A)
  let ob = khoang-cach(O, B)
  let D = chia(A, B, oa / (oa + ob))
  doan(ctx, O, D, mau: mau, day: day, dut: dut)
  goc(ctx, O, A, D, r: r-cung, mau: mau)
  goc(ctx, O, D, B, r: r-cung * 1.18, mau: mau)
  if ten-chan != none {
    diem(ctx, D, ten: ten-chan, huong: huong-ra(D, trong-tam(O, A, B)))
  }
}

// Đường trung trực của đoạn AB (đoạn vuông góc tại trung điểm, dài 2*dai).
#let trung-truc(ctx, A, B, dai: 1.5, mau: purple, day: 1pt, dut: true, so-vach: 1) = {
  let M = trung-diem(A, B)
  let d = khoang-cach(A, B)
  let ux = (B.at(0) - A.at(0)) / d
  let uy = (B.at(1) - A.at(1)) / d
  let P1 = (M.at(0) - dai * uy, M.at(1) + dai * ux)
  let P2 = (M.at(0) + dai * uy, M.at(1) - dai * ux)
  doan(ctx, P1, P2, mau: mau, day: day, dut: dut)
  goc-vuong(ctx, M, B, P1, mau: mau)
  danh-dau(ctx, A, M, so: so-vach, mau: mau)
  danh-dau(ctx, M, B, so: so-vach, mau: mau)
}

// ---------- Tam giác đặc biệt ----------
// Tam giác đều cạnh `canh`, đỉnh A ở dưới-trái, đáy nằm ngang.
// vach: số vạch đánh dấu cạnh bằng nhau (0 = không vẽ).
#let tam-giac-deu(ctx, A, canh, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, vach: 1) = {
  let B = (A.at(0) + canh, A.at(1))
  let C = (A.at(0) + canh / 2, A.at(1) + canh * calc.sqrt(3) / 2)
  da-giac-ten(ctx, (A, B, C), ten: ten, mau: mau, day: day, to: to)
  if vach > 0 {
    danh-dau(ctx, A, B, so: vach, mau: mau)
    danh-dau(ctx, B, C, so: vach, mau: mau)
    danh-dau(ctx, C, A, so: vach, mau: mau)
  }
}

// Tam giác vuông tại A: cạnh AB ngang dài a, cạnh AC đứng dài b.
#let tam-giac-vuong(ctx, A, a, b, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none) = {
  let B = (A.at(0) + a, A.at(1))
  let C = (A.at(0), A.at(1) + b)
  da-giac-ten(ctx, (A, B, C), ten: ten, mau: mau, day: day, to: to)
  goc-vuong(ctx, A, B, C, mau: mau)
}

// Tam giác cân tại C: đáy AB ngang dài `canh-day`, chiều cao `chieu-cao`.
#let tam-giac-can(ctx, A, canh-day, chieu-cao, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, vach: 1) = {
  let B = (A.at(0) + canh-day, A.at(1))
  let C = (A.at(0) + canh-day / 2, A.at(1) + chieu-cao)
  da-giac-ten(ctx, (A, B, C), ten: ten, mau: mau, day: day, to: to)
  if vach > 0 {
    danh-dau(ctx, C, A, so: vach, mau: mau)
    danh-dau(ctx, C, B, so: vach, mau: mau)
  }
}

// Tam giác vuông cân tại A, hai cạnh góc vuông dài `canh`.
#let tam-giac-vuong-can(ctx, A, canh, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, vach: 1) = {
  tam-giac-vuong(ctx, A, canh, canh, ten: ten, mau: mau, day: day, to: to)
  if vach > 0 {
    let B = (A.at(0) + canh, A.at(1))
    let C = (A.at(0), A.at(1) + canh)
    danh-dau(ctx, A, B, so: vach, mau: mau)
    danh-dau(ctx, A, C, so: vach, mau: mau)
  }
}

// ---------- Tứ giác thường gặp ----------
// Tứ giác bất kỳ ABCD.
#let tu-giac(ctx, A, B, C, D, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none) = {
  da-giac-ten(ctx, (A, B, C, D), ten: ten, mau: mau, day: day, to: to)
}

// Hình bình hành biết 3 đỉnh liên tiếp A, B, C (D tự tính = A + C - B).
#let hinh-binh-hanh(ctx, A, B, C, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none) = {
  let D = (A.at(0) + C.at(0) - B.at(0), A.at(1) + C.at(1) - B.at(1))
  da-giac-ten(ctx, (A, B, C, D), ten: ten, mau: mau, day: day, to: to)
}

// Hình chữ nhật: góc dưới-trái A, chiều rộng r, chiều cao c.
#let hinh-chu-nhat(ctx, A, r, c, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none, goc-vg: true) = {
  let B = (A.at(0) + r, A.at(1))
  let C = (A.at(0) + r, A.at(1) + c)
  let D = (A.at(0), A.at(1) + c)
  da-giac-ten(ctx, (A, B, C, D), ten: ten, mau: mau, day: day, to: to)
  if goc-vg { goc-vuong(ctx, A, B, D, mau: mau) }
}

// Hình thang: đáy lớn AB (dưới, dài a), đáy nhỏ DC (trên, dài b),
// cao c, lech: độ lệch ngang của D so với A.
#let hinh-thang(ctx, A, a, b, c, lech: 0.6, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none) = {
  let B = (A.at(0) + a, A.at(1))
  let D = (A.at(0) + lech, A.at(1) + c)
  let C = (D.at(0) + b, D.at(1))
  da-giac-ten(ctx, (A, B, C, D), ten: ten, mau: mau, day: day, to: to)
}

// ---------- Đường tròn liên quan tam giác ----------
// Đường tròn ngoại tiếp tam giác ABC. ten-tam: nhãn tâm (vd $O$).
#let duong-tron-ngoai-tiep(ctx, A, B, C, ten-tam: $O$, mau: blue, day: 1pt, ban-kinh: false) = {
  let O = tam-ngoai-tiep(A, B, C)
  let r = khoang-cach(O, A)
  duong-tron(ctx, O, r, mau: mau, day: day)
  if ten-tam != none { diem(ctx, O, ten: ten-tam, huong: "duoi-phai") }
  if ban-kinh { doan(ctx, O, A, mau: mau, day: 0.8pt, dut: true) }
}

// Đường tròn nội tiếp tam giác ABC.
#let duong-tron-noi-tiep(ctx, A, B, C, ten-tam: $I$, mau: orange.darken(10%), day: 1pt, ban-kinh: false) = {
  let (I, r) = tam-noi-tiep(A, B, C)
  duong-tron(ctx, I, r, mau: mau, day: day)
  if ten-tam != none { diem(ctx, I, ten: ten-tam, huong: "tren") }
  if ban-kinh {
    let H = hinh-chieu(I, A, B)
    doan(ctx, I, H, mau: mau, day: 0.8pt, dut: true)
    goc-vuong(ctx, H, I, A, r: 0.22, mau: mau)
  }
}

// ---------- Trực tâm ----------
// Ba đường cao của tam giác ABC + trực tâm H.
//   ten       : nhãn trực tâm (none = không ghi)
//   ten-chan  : nhãn 3 chân đường cao theo thứ tự hạ từ A, B, C
//               (none = không ghi; mặc định $H_A$, $H_B$, $H_C$)
//   vuong     : vẽ ký hiệu góc vuông tại chân đường cao
//   canh      : true = vẽ luôn tam giác ABC (kèm nhãn đỉnh)
#let ve-truc-tam(
  ctx, A, B, C,
  ten: $H$,
  ten-chan: ($H_A$, $H_B$, $H_C$),
  ten-dinh: ($A$, $B$, $C$),
  canh: true,
  mau: black, mau-cao: red, day: 1.1pt, dut: false, vuong: true,
) = {
  if canh { tam-giac(ctx, A, B, C, ten: ten-dinh, mau: mau, day: day) }
  let H = truc-tam(A, B, C)
  for (i, (P, X, Y)) in ((A, B, C), (B, C, A), (C, A, B)).enumerate() {
    let K = hinh-chieu(P, X, Y)
    // kéo dài tới chân đường cao (tam giác tù thì chân nằm ngoài cạnh)
    doan(ctx, P, K, mau: mau-cao, day: 0.9pt, dut: dut)
    // nối dài cạnh nếu chân đường cao rơi ra ngoài đoạn XY
    let t = (
      ((K.at(0) - X.at(0)) * (Y.at(0) - X.at(0))
        + (K.at(1) - X.at(1)) * (Y.at(1) - X.at(1)))
        / calc.pow(khoang-cach(X, Y), 2)
    )
    if t < 0 { doan(ctx, X, K, mau: mau, day: 0.7pt, dut: true) }
    if t > 1 { doan(ctx, Y, K, mau: mau, day: 0.7pt, dut: true) }
    if vuong { goc-vuong(ctx, K, P, if t < 0.5 { Y } else { X }, r: 0.22, mau: mau-cao) }
    if ten-chan != none {
      diem(ctx, K, bk: 1.6pt, mau: mau-cao, ten: ten-chan.at(i),
        huong: huong-ra(K, trong-tam(A, B, C)))
    }
  }
  if ten != none {
    diem(ctx, H, mau: mau-cao, ten: ten, huong: huong-ra(H, trong-tam(A, B, C)))
  } else {
    diem(ctx, H, mau: mau-cao)
  }
}

// ---------- Đường tròn bàng tiếp ----------
// Đường tròn bàng tiếp TRONG GÓC A của tam giác ABC (tiếp xúc cạnh BC và
// phần kéo dài của AB, AC). Muốn góc B thì gọi duong-tron-bang-tiep(ctx, B, C, A).
//   ten-tam   : nhãn tâm (mặc định $J$)
//   keo-dai   : vẽ nét đứt kéo dài hai cạnh AB, AC tới tiếp điểm
//   tiep-diem : chấm 3 tiếp điểm
//   ban-kinh  : vẽ bán kính tới cạnh BC (kèm ký hiệu vuông góc)
#let duong-tron-bang-tiep(
  ctx, A, B, C,
  ten-tam: $J$, ten-tiep: none,
  mau: green.darken(25%), day: 1pt,
  keo-dai: true, tiep-diem: true, ban-kinh: false,
) = {
  let (J, r) = tam-bang-tiep(A, B, C)
  let a = khoang-cach(B, C)
  let b = khoang-cach(C, A)
  let c = khoang-cach(A, B)
  let s = (a + b + c) / 2
  let X = chia(B, C, (s - c) / a)     // tiếp điểm trên cạnh BC
  let Y = chia(A, B, s / c)           // trên tia AB (ngoài B)
  let Z = chia(A, C, s / b)           // trên tia AC (ngoài C)
  if keo-dai {
    doan(ctx, B, Y, mau: mau, day: 0.7pt, dut: true)
    doan(ctx, C, Z, mau: mau, day: 0.7pt, dut: true)
  }
  duong-tron(ctx, J, r, mau: mau, day: day)
  if tiep-diem {
    for (i, P) in (X, Y, Z).enumerate() {
      diem(ctx, P, bk: 1.6pt, mau: mau,
        ten: if ten-tiep == none { none } else { ten-tiep.at(i) },
        huong: huong-ra(P, J))
    }
  }
  if ban-kinh {
    doan(ctx, J, X, mau: mau, day: 0.8pt, dut: true)
    goc-vuong(ctx, X, J, B, r: 0.22, mau: mau)
  }
  if ten-tam != none { diem(ctx, J, mau: mau, ten: ten-tam, huong: huong-ra(J, A)) }
}

// ---------- Tiếp tuyến ----------
// Hai tiếp tuyến kẻ từ điểm M ngoài đường tròn (O; r).
#let tiep-tuyen-tu-diem(
  ctx, O, r, M,
  ten-tam: $O$, ten-diem: $M$, ten-tiep: ($T_1$, $T_2$),
  mau: black, mau-tt: red, day: 1pt,
) = {
  duong-tron(ctx, O, r, mau: mau, day: day)
  let (T1, T2) = tiep-diem(O, r, M)
  doan(ctx, M, T1, mau: mau-tt, day: day)
  doan(ctx, M, T2, mau: mau-tt, day: day)
  doan(ctx, O, T1, mau: mau, day: 0.8pt, dut: true)
  doan(ctx, O, T2, mau: mau, day: 0.8pt, dut: true)
  doan(ctx, O, M, mau: mau, day: 0.8pt, dut: true)
  goc-vuong(ctx, T1, O, M, r: 0.24, mau: mau-tt)
  goc-vuong(ctx, T2, O, M, r: 0.24, mau: mau-tt)
  if ten-tam != none { diem(ctx, O, ten: ten-tam, huong: "duoi") }
  if ten-diem != none { diem(ctx, M, ten: ten-diem, huong: "phai") }
  if ten-tiep != none {
    diem(ctx, T1, ten: ten-tiep.at(0), huong: huong-ra(T1, O))
    diem(ctx, T2, ten: ten-tiep.at(1), huong: huong-ra(T2, O))
  }
}

// Giao điểm hai đường tròn (O1;r1), (O2;r2): trả về (P1, P2).
#let giao-hai-duong-tron(O1, r1, O2, r2) = {
  let d = khoang-cach(O1, O2)
  let a = (d * d + r1 * r1 - r2 * r2) / (2 * d)
  let h = calc.sqrt(r1 * r1 - a * a)
  let ux = (O2.at(0) - O1.at(0)) / d
  let uy = (O2.at(1) - O1.at(1)) / d
  let H = (O1.at(0) + a * ux, O1.at(1) + a * uy)
  (
    (H.at(0) - h * uy, H.at(1) + h * ux),
    (H.at(0) + h * uy, H.at(1) - h * ux),
  )
}

// Giao điểm hai đường thẳng AB và CD (giả sử không song song).
#let giao-duong-thang(A, B, C, D) = {
  let x1 = A.at(0); let y1 = A.at(1)
  let x2 = B.at(0); let y2 = B.at(1)
  let x3 = C.at(0); let y3 = C.at(1)
  let x4 = D.at(0); let y4 = D.at(1)
  let m = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  (
    ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / m,
    ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / m,
  )
}

// ---------- Đường tròn lượng giác (hình hoàn chỉnh, tự tạo khung) ----------
// goc: góc của điểm M trên đường tròn; hien: hiển thị hình chiếu sin/cos.
#let duong-tron-luong-giac(
  w: 7cm,
  so-do: 55deg,   // số đo góc của điểm M
  ten-goc: $alpha$,
  hien-chieu: true,
  mau-tron: blue,
  mau-goc: red,
) = hinh(w: w, xmin: -1.55, xmax: 1.55, ymin: -1.5, ymax: 1.5, ctx => {
  // hai trục
  mui-ten(ctx, (-1.4, 0), (1.4, 0), day: 0.9pt)
  mui-ten(ctx, (0, -1.35), (0, 1.35), day: 0.9pt)
  nhan(ctx, (1.4, 0), $x$, huong: "duoi")
  nhan(ctx, (0, 1.35), $y$, huong: "phai")
  duong-tron(ctx, (0, 0), 1, mau: mau-tron, day: 1.2pt)
  // các điểm đặc biệt
  nhan(ctx, (1, 0), $1$, huong: "duoi-phai", cach: 4pt)
  nhan(ctx, (-1, 0), $-1$, huong: "duoi-trai", cach: 4pt)
  nhan(ctx, (0, 1), $1$, huong: "tren-trai", cach: 4pt)
  nhan(ctx, (0, -1), $-1$, huong: "duoi-trai", cach: 4pt)
  diem(ctx, (0, 0), ten: $O$, huong: "duoi-trai", bk: 1.6pt)
  // điểm M và bán kính OM
  let M = (calc.cos(so-do), calc.sin(so-do))
  doan(ctx, (0, 0), M, mau: mau-goc, day: 1.2pt)
  diem(ctx, M, ten: $M$, huong: huong-ra(M, (0, 0)), mau: mau-goc)
  goc(ctx, (0, 0), (1, 0), M, r: 0.3, ten: ten-goc, mau: mau-goc)
  if hien-chieu {
    doan(ctx, M, (M.at(0), 0), mau: gray, day: 0.8pt, dut: true)
    doan(ctx, M, (0, M.at(1)), mau: gray, day: 0.8pt, dut: true)
    diem(ctx, (M.at(0), 0), ten: $cos alpha$, huong: "duoi", bk: 1.6pt, mau: mau-goc)
    diem(ctx, (0, M.at(1)), ten: $sin alpha$, huong: "trai", bk: 1.6pt, mau: mau-goc)
  }
})
