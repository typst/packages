// =====================================================================
// hinh-khong-gian.typ — HÌNH KHÔNG GIAN THPT
// Hình chóp, lăng trụ, hình hộp, lập phương, nón, trụ, cầu, trục Oxyz.
// Nét khuất tự động vẽ đứt theo đúng quy ước SGK.
//
// Mỗi hình đều có tham số `them`: hàm (ctx, dinh) => nội dung, cho phép
// vẽ THÊM điểm/đoạn/thiết diện lên hình bằng chính các đỉnh có sẵn.
//   vd: them: (ctx, d) => { diem(ctx, chia(d.S, d.A, 0.5), ten: $M$) }
// =====================================================================
#import "ve.typ": *
#import "hinh-phang.typ": huong-ra, trong-tam

// Phép chiếu song song đơn giản: (x, y, z) -> mặt phẳng.
// x: sang phải, y: chiều sâu (ra sau), z: lên trên.
#let chieu(P, k: 0.45, goc: 40deg) = (
  P.at(0) + k * P.at(1) * calc.cos(goc),
  P.at(2) + k * P.at(1) * calc.sin(goc),
)

// Gọi callback `them` nếu có.
#let goi-them(them, ctx, dinh) = {
  if them != none { them(ctx, dinh) }
}

// ---------- HÌNH CHÓP TAM GIÁC S.ABC ----------
// duong-cao: none | "tam" (chân H trong tam giác) | "dinh-a" (SA vuông đáy)
#let hinh-chop-tam-giac(
  w: 7cm,
  ten: ($S$, $A$, $B$, $C$),
  duong-cao: none,
  ten-chan: $H$,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -0.6, xmax: 5.0, ymin: -0.5, ymax: 5.0, ctx => {
  let d = (
    A: (0.0, 1.1),
    B: (3.1, 0.0),
    C: (4.3, 1.9),
    S: (2.1, 4.4),
  )
  // nét liền
  doan(ctx, d.A, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.A, mau: mau, day: day)
  doan(ctx, d.S, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.C, mau: mau, day: day)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  // nét khuất
  doan(ctx, d.A, d.C, mau: mau, day: day, dut: true)
  // đường cao
  if duong-cao == "tam" {
    let H = (2.35, 1.15)
    d.insert("H", H)
    doan(ctx, d.S, H, mau: mau-phu, day: 1pt, dut: true)
    goc-vuong(ctx, H, d.S, d.B, r: 0.28, mau: mau-phu)
    diem(ctx, H, ten: ten-chan, huong: "duoi", bk: 1.6pt, mau: mau-phu)
  } else if duong-cao == "dinh-a" {
    goc-vuong(ctx, d.A, d.S, d.B, r: 0.3, mau: mau-phu)
  }
  // nhãn đỉnh
  let G = trong-tam(d.A, d.B, d.C, d.S)
  for (P, t) in ((d.S, d.A, d.B, d.C).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

// ---------- HÌNH CHÓP TỨ GIÁC S.ABCD (đáy hình bình hành / vuông) ----------
// duong-cheo: vẽ 2 đường chéo đáy (đứt) + tâm O.
// duong-cao: none | "tam" (SO vuông đáy, chóp đều) | "dinh-a" (SA vuông đáy)

#let hinh-chop-tu-giac-thuong(
  w: 7.6cm,
  ten: ($S$, $A$, $B$, $C$, $D$),
  duong-cheo: false,
  duong-cao: none,
  ten-tam: $O$,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -1, xmax: 5, ymin: -0.5, ymax: 7, ctx => {
  let d = (
    A: (-1, 3),
    B: (5, 3),
    C: (4, 1),
    D: (0, 0),       // = A + C - B (hình bình hành)
    S: (2, 7),
  )
  let O = trung-diem(d.A, d.C)
  // nét liền
  doan(ctx, d.A, d.B, mau: mau, day: day, dut: true)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.A, mau: mau, day: day)
  doan(ctx, d.S, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.C, mau: mau, day: day)
  // nét khuất
  doan(ctx, d.A, d.D, mau: mau, day: day)
  doan(ctx, d.D, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.D, mau: mau, day: day)
  if duong-cheo or duong-cao == "tam" {
    d.insert("O", O)
    doan(ctx, d.A, d.C, mau: mau, day: 0.9pt, dut: true)
    doan(ctx, d.B, d.D, mau: mau, day: 0.9pt, dut: true)
    diem(ctx, O, ten: ten-tam, huong: "duoi", bk: 1.6pt)
  }
  if duong-cao == "tam" {
    doan(ctx, d.S, O, mau: mau-phu, day: 1pt, dut: true)
    goc-vuong(ctx, O, d.S, d.C, r: 0.3, mau: mau-phu)
  } else if duong-cao == "dinh-a" {
    goc-vuong(ctx, d.A, d.S, d.B, r: 0.3, mau: mau-phu)
  }
  // nhãn đỉnh
  let G = trong-tam(d.A, d.B, d.C, d.D, d.S)
  for (P, t) in ((d.S, d.A, d.B, d.C, d.D).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

#let hinh-chop-tu-giac(
  w: 7.6cm,
  ten: ($S$, $A$, $B$, $C$, $D$),
  duong-cheo: false,
  duong-cao: none,
  ten-tam: $O$,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: 0, xmax: 9, ymin: -0.5, ymax: 6, ctx => {
  let d = (
    A: (3, 2),
    B: (9, 2),
    C: (6, 0),
    D: (0, 0),       // = A + C - B (hình bình hành)
    S: (4.5, 6),
  )
  let O = trung-diem(d.A, d.C)
  // nét liền
  doan(ctx, d.A, d.B, mau: mau, day: day, dut: true)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.A, mau: mau, day: day, dut: true)
  doan(ctx, d.S, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.C, mau: mau, day: day)
  // nét khuất
  doan(ctx, d.A, d.D, mau: mau, day: day, dut: true)
  doan(ctx, d.D, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.D, mau: mau, day: day)
  if duong-cheo or duong-cao == "tam" {
    d.insert("O", O)
    doan(ctx, d.A, d.C, mau: mau, day: 0.9pt, dut: true)
    doan(ctx, d.B, d.D, mau: mau, day: 0.9pt, dut: true)
    diem(ctx, O, ten: ten-tam, huong: "duoi", bk: 1.6pt)
  }
  if duong-cao == "tam" {
    doan(ctx, d.S, O, mau: mau-phu, day: 1pt, dut: true)
    goc-vuong(ctx, O, d.S, d.C, r: 0.3, mau: mau-phu)
  } else if duong-cao == "dinh-a" {
    goc-vuong(ctx, d.A, d.S, d.B, r: 0.3, mau: mau-phu)
  }
  // nhãn đỉnh
  let G = trong-tam(d.A, d.B, d.C, d.D, d.S)
  for (P, t) in ((d.S, d.A, d.B, d.C, d.D).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

#let hinh-chop-day-hinh-thang(
  w: 7.6cm,
  ten: ($S$, $A$, $B$, $C$, $D$),
  duong-cheo: false,
  duong-cao: none,
  ten-tam: $O$,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: 0, xmax: 9, ymin: -0.5, ymax: 6, ctx => {
  let d = (
    A: (2, 2),
    B: (9, 2),
    C: (3.5, 0),
    D: (0, 0),       // = A + C - B (hình bình hành)
    S: (2, 6),
  )
  let O = trung-diem(d.A, d.C)
  // nét liền
  doan(ctx, d.A, d.B, mau: mau, day: day, dut: true)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.A, mau: mau, day: day, dut: true)
  doan(ctx, d.S, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.C, mau: mau, day: day)
  // nét khuất
  doan(ctx, d.A, d.D, mau: mau, day: day, dut: true)
  doan(ctx, d.D, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.D, mau: mau, day: day)
  if duong-cheo or duong-cao == "tam" {
    d.insert("O", O)
    doan(ctx, d.A, d.C, mau: mau, day: 0.9pt, dut: true)
    doan(ctx, d.B, d.D, mau: mau, day: 0.9pt, dut: true)
    diem(ctx, O, ten: ten-tam, huong: "duoi", bk: 1.6pt)
  }
  if duong-cao == "tam" {
    doan(ctx, d.S, O, mau: mau-phu, day: 1pt, dut: true)
    goc-vuong(ctx, O, d.S, d.C, r: 0.3, mau: mau-phu)
  } else if duong-cao == "dinh-a" {
    goc-vuong(ctx, d.A, d.S, d.B, r: 0.3, mau: mau-phu)
  }
  // nhãn đỉnh
  let G = trong-tam(d.A, d.B, d.C, d.D, d.S)
  for (P, t) in ((d.S, d.A, d.B, d.C, d.D).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

// ---------- HÌNH CHÓP TAM GIÁC ĐỀU S.ABC ----------
// S thẳng trên trọng tâm O của đáy; SO vuông góc đáy (nét đứt).
// trung-tuyen: vẽ thêm trung tuyến AM của đáy đi qua O.
#let hinh-chop-tam-giac-deu(
  w: 7cm,
  ten: ($S$, $A$, $B$, $C$),
  ten-tam: $O$,
  ten-trung-diem: $M$,   // tên trung điểm BC (khi trung-tuyen: true)
  trung-tuyen: false,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -0.6, xmax: 6.0, ymin: -0.5, ymax: 5.3, ctx => {
  let d = (A: (0.0, 2), B: (1.5, 0.0), C: (6, 2))
  let O = trong-tam(d.A, d.B, d.C)
  let S = (O.at(0), O.at(1) + 3.7)
  d.insert("O", O)
  d.insert("S", S)
  // cạnh đáy
  doan(ctx, d.A, d.B, mau: mau, day: day)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.A, d.C, mau: mau, day: day, dut: true)
  // cạnh bên
  doan(ctx, S, d.A, mau: mau, day: day)
  doan(ctx, S, d.B, mau: mau, day: day)
  doan(ctx, S, d.C, mau: mau, day: day)
  // đường cao SO
  if trung-tuyen {
    let M = trung-diem(d.B, d.C)
    d.insert("M", M)
    doan(ctx, d.A, M, mau: mau, day: 0.9pt, dut: true)
    diem(ctx, M, ten: ten-trung-diem, huong: "phai", bk: 1.5pt)
  }
  doan(ctx, S, O, mau: mau-phu, day: 1pt, dut: true)
  goc-vuong(ctx, O, S, d.A, r: 0.26, mau: mau-phu)
  diem(ctx, O, ten: ten-tam, huong: "duoi", bk: 1.5pt)
  let G = trong-tam(d.A, d.B, d.C, S)
  for (P, t) in ((S, d.A, d.B, d.C).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

// ---------- HÌNH CHÓP TỨ GIÁC ĐỀU S.ABCD ----------
// (đáy hình vuông, SO vuông góc đáy tại tâm O — vẽ sẵn 2 đường chéo)
#let hinh-chop-tu-giac-deu(w: 7.6cm, ten: ($S$, $A$, $B$, $C$, $D$), ten-tam: $O$, them: none) = {
  hinh-chop-tu-giac(w: w, ten: ten, ten-tam: ten-tam, duong-cao: "tam", duong-cheo: true, them: them)
}

// ---------- HÌNH CHÓP TAM DIỆN VUÔNG O.ABC ----------
// OA, OB, OC đôi một vuông góc (vẽ kiểu "góc phòng", 3 dấu vuông tại O).
#let hinh-chop-tam-dien-vuong(
  w: 6.6cm,
  ten: ($O$, $A$, $B$, $C$),
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -2.9, xmax: 3.3, ymin: -2.7, ymax: 3.4, ctx => {
  let d = (O: (0.0, 0.0), A: (-2.1, -1.9), B: (2.7, -0.4), C: (0.0, 2.8))
  doan(ctx, d.O, d.A, mau: mau, day: day, dut: true)
  doan(ctx, d.O, d.B, mau: mau, day: day, dut: true)
  doan(ctx, d.O, d.C, mau: mau, day: day, dut: true)
  doan(ctx, d.A, d.B, mau: mau, day: day)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.C, d.A, mau: mau, day: day)
  goc-vuong(ctx, d.O, d.A, d.B, r: 0.30, mau: mau-phu)
  goc-vuong(ctx, d.O, d.B, d.C, r: 0.38, mau: mau-phu)
  goc-vuong(ctx, d.O, d.A, d.C, r: 0.46, mau: mau-phu)
  diem(ctx, d.O, ten: ten.at(0), huong: "tren-phai", bk: 1.5pt)
  diem(ctx, d.A, ten: ten.at(1), huong: "duoi-trai", bk: 1.5pt)
  diem(ctx, d.B, ten: ten.at(2), huong: "phai", bk: 1.5pt)
  diem(ctx, d.C, ten: ten.at(3), huong: "tren", bk: 1.5pt)
  goi-them(them, ctx, d)
})

// ---------- CHÓP ĐÁY TAM GIÁC VUÔNG, CẠNH BÊN VUÔNG GÓC ĐÁY ----------
// Đáy ABC vuông tại B; SA vuông góc với đáy (S thẳng trên A).
#let hinh-chop-day-tam-giac-vuong(
  w: 6.8cm,
  ten: ($S$, $A$, $B$, $C$),
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -0.7, xmax: 4.6, ymin: -0.6, ymax: 5.9, ctx => {
  let d = (A: (0.0, 2), B: (3.4, 0.0), C: (4.6, 2), S: (0.0, 5.5))
  // đáy
  doan(ctx, d.A, d.B, mau: mau, day: day)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.A, d.C, mau: mau, day: day, dut: true)
  // cạnh bên
  doan(ctx, d.S, d.A, mau: mau, day: day)
  doan(ctx, d.S, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.C, mau: mau, day: day)
  // SA vuông đáy + đáy vuông tại B
  goc-vuong(ctx, d.A, d.S, d.B, r: 0.3, mau: mau-phu)
  goc-vuong(ctx, d.B, d.A, d.C, r: 0.3, mau: mau-phu)
  let G = trong-tam(d.A, d.B, d.C, d.S)
  for (P, t) in ((d.S, d.A, d.B, d.C).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

// ---------- CHÓP ĐÁY HÌNH CHỮ NHẬT, CẠNH BÊN VUÔNG GÓC ĐÁY ----------
// Đáy ABCD hình chữ nhật; SA vuông góc đáy (S thẳng trên A).
#let hinh-chop-day-chu-nhat(
  w: 7.6cm,
  ten: ($S$, $A$, $B$, $C$, $D$),
  duong-cheo: false,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -3, xmax: 6.0, ymin: -2, ymax: 5.5, ctx => {
  let d = (A: (0.0, 0.0), B: (6, 0.0), C: (3, -2), D: (-3, -2), S: (0.0, 4.8))
  // đáy: nét liền phía trước, nét khuất phía sau
  doan(ctx, d.A, d.B, mau: mau, day: day, dut: true)
  doan(ctx, d.B, d.C, mau: mau, day: day)
  doan(ctx, d.A, d.D, mau: mau, day: day, dut: true)
  doan(ctx, d.D, d.C, mau: mau, day: day)
  // cạnh bên
  doan(ctx, d.S, d.A, mau: mau, day: day, dut: true)
  doan(ctx, d.S, d.B, mau: mau, day: day)
  doan(ctx, d.S, d.C, mau: mau, day: day)
  doan(ctx, d.S, d.D, mau: mau, day: day)
  if duong-cheo {
    doan(ctx, d.A, d.C, mau: mau, day: 0.9pt, dut: true)
    doan(ctx, d.B, d.D, mau: mau, day: 0.9pt, dut: true)
  }
  // SA vuông với AB và AD
  goc-vuong(ctx, d.A, d.S, d.B, r: 0.3, mau: mau-phu)
  goc-vuong(ctx, d.A, d.S, d.D, r: 0.42, mau: mau-phu)
  let G = trong-tam(d.A, d.B, d.C, d.D, d.S)
  for (P, t) in ((d.S, d.A, d.B, d.C, d.D).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

// ---------- HÌNH HỘP CHỮ NHẬT / LẬP PHƯƠNG ABCD.A'B'C'D' ----------
// Đáy ABCD, đỉnh trên A'B'C'D'. dai, cao: kích thước; sau: độ "lùi" phối cảnh.
#let hinh-hop(
  w: 7.6cm,
  dai: 3.6, cao: 2.6, sau: 1.5, nghieng: -0.7,
  ten: ($A$, $B$, $C$, $D$, $A'$, $B'$, $C'$, $D'$),
  duong-cheo: false,   // đường chéo không gian AC' (đứt)
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = {
  let dx = -sau * 0.75
  let dy = -sau * 0.62
  hinh(
    w: w,
    xmin: -dx - 2, xmax: dai - dx ,
    ymin: -dy - 2, ymax: cao - dy,
    ctx => {
      let d = (
        A: (0.0, 0.0),
        B: (dai, 0.0),
        C: (dai + dx, dy),
        D: (dx, dy),
      )
      d.insert("A1", (d.A.at(0) + nghieng, d.A.at(1) + cao))
      d.insert("B1", (d.B.at(0) + nghieng, d.B.at(1) + cao))
      d.insert("C1", (d.C.at(0) + nghieng, d.C.at(1) + cao))
      d.insert("D1", (d.D.at(0) + nghieng, d.D.at(1) + cao))
      // nét liền: mặt trước, mặt phải, mặt trên
      duong-cong(ctx, (d.A1, d.B1, d.C1, d.D1), mau: mau, day: day, dong: true)

      
      doan(ctx, d.B, d.C, mau: mau, day: day)
      doan(ctx, d.D, d.C, mau: mau, day: day)
      doan(ctx, d.D, d.D1, mau: mau, day: day)      
      doan(ctx, d.B, d.B1, mau: mau, day: day)
      doan(ctx, d.C, d.C1, mau: mau, day: day)
      // nét khuất: 3 cạnh tại đỉnh A
      doan(ctx, d.A, d.D, mau: mau, day: day, dut: true)
      doan(ctx, d.A, d.B, mau: mau, day: day, dut: true)
      doan(ctx, d.A, d.A1, mau: mau, day: day, dut: true)
      
      if duong-cheo {
        doan(ctx, d.A, d.C1, mau: mau-phu, day: 1pt, dut: true)
      }
      let G = trong-tam(d.A, d.C1)
      for (P, t) in ((d.A, d.B, d.C, d.D, d.A1, d.B1, d.C1, d.D1).zip(ten)) {
        diem(ctx, P, ten: t, huong: huong-ra(P, G))
      }
      goi-them(them, ctx, d)
    },
  )
}

// Hình lập phương cạnh chuẩn.
#let hinh-lap-phuong(w: 7cm, ten: ($A$, $B$, $C$, $D$, $A'$, $B'$, $C'$, $D'$), duong-cheo: false, them: none) = {
  hinh-hop(w: w, dai: 2.8, cao: 2.8, sau: 1.5, nghieng: 0, ten: ten, duong-cheo: duong-cheo, them: them)
}

// Hình lập phương cạnh chuẩn.
#let hinh-hop-chu-nhat(w: 7cm, ten: ($A$, $B$, $C$, $D$, $A'$, $B'$, $C'$, $D'$), duong-cheo: false, them: none) = {
  hinh-hop(w: w, dai: 4, cao: 2.8, sau: 1.5, nghieng: 0, ten: ten, duong-cheo: duong-cheo, them: them)
}


// ---------- LĂNG TRỤ TAM GIÁC ABC.A'B'C' (đứng) ----------
#let hinh-lang-tru-tam-giac(
  w: 6.6cm,
  cao: 3.0,
  ten: ($A$, $B$, $C$, $A'$, $B'$, $C'$),
  mau: black, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -0.6, xmax: 4.4, ymin: -0.5, ymax: cao + 1.9, ctx => {
  let d = (
    A: (0.0, 0.0),
    B: (3.4, -0.0),
    C: (2.4, 1.3),
  )
  d.insert("A1", (d.A.at(0), d.A.at(1) + cao))
  d.insert("B1", (d.B.at(0), d.B.at(1) + cao))
  d.insert("C1", (d.C.at(0), d.C.at(1) + cao))
  // đáy trên: nét liền
  da-giac(ctx, (d.A1, d.B1, d.C1), mau: mau, day: day)
  // cạnh bên
  doan(ctx, d.A, d.A1, mau: mau, day: day)
  doan(ctx, d.B, d.B1, mau: mau, day: day)
  doan(ctx, d.C, d.C1, mau: mau, day: day, dut: true)
  // đáy dưới
  doan(ctx, d.A, d.B, mau: mau, day: day)
  doan(ctx, d.A, d.C, mau: mau, day: day, dut: true)
  doan(ctx, d.B, d.C, mau: mau, day: day, dut: true)
  let G = trong-tam(d.A, d.B, d.C, d.A1, d.B1, d.C1)
  for (P, t) in ((d.A, d.B, d.C, d.A1, d.B1, d.C1).zip(ten)) {
    diem(ctx, P, ten: t, huong: huong-ra(P, G))
  }
  goi-them(them, ctx, d)
})

// ---------- HÌNH NÓN ----------
#let hinh-non(
  w: 5.6cm,
  r: 1.6, cao: 3.4,
  ten-dinh: $S$, ten-tam: $O$, ten-bk: $r$,
  truc: true,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -r - 0.7, xmax: r + 0.7, ymin: -r * 0.42 - 0.5, ymax: cao + 0.6, ctx => {
  let ry = r * 0.32
  let S = (0.0, cao)
  let O = (0.0, 0.0)
  let d = (S: S, O: O, T1: (-r, 0.0), T2: (r, 0.0))
  // đáy: nửa trước liền, nửa sau đứt
  cung-elip(ctx, O, r, ry, tu: 180deg, den: 360deg, mau: mau, day: day)
  cung-elip(ctx, O, r, ry, tu: 0deg, den: 180deg, mau: mau, day: day, dut: true)
  // hai đường sinh
  doan(ctx, S, d.T1, mau: mau, day: day)
  doan(ctx, S, d.T2, mau: mau, day: day)
  if truc {
    doan(ctx, S, O, mau: mau-phu, day: 1pt, dut: true)
    doan(ctx, O, d.T2, mau: mau-phu, day: 1pt)
    goc-vuong(ctx, O, S, d.T2, r: 0.24, mau: mau-phu)
    nhan(ctx, (r / 2, 0), ten-bk, huong: "duoi", mau: mau-phu)
    diem(ctx, O, ten: ten-tam, huong: "duoi-trai", bk: 1.5pt)
  }
  diem(ctx, S, ten: ten-dinh, huong: "tren", bk: 1.5pt)
  goi-them(them, ctx, d)
})

// ---------- HÌNH TRỤ ----------
#let hinh-tru(
  w: 5.6cm,
  r: 1.5, cao: 3.2,
  ten-tam: ($O$, $O'$), ten-bk: $r$,
  truc: true,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -r - 0.7, xmax: r + 0.7, ymin: -r * 0.42 - 0.4, ymax: cao + r * 0.42 + 0.5, ctx => {
  let ry = r * 0.3
  let O = (0.0, 0.0)
  let O1 = (0.0, cao)
  let d = (O: O, O1: O1)
  // đáy dưới: nửa trước liền, nửa sau đứt
  cung-elip(ctx, O, r, ry, tu: 180deg, den: 360deg, mau: mau, day: day)
  cung-elip(ctx, O, r, ry, tu: 0deg, den: 180deg, mau: mau, day: day, dut: true)
  // đáy trên: liền hoàn toàn
  cung-elip(ctx, O1, r, ry, tu: 0deg, den: 360deg, mau: mau, day: day)
  // hai cạnh bên
  doan(ctx, (-r, 0), (-r, cao), mau: mau, day: day)
  doan(ctx, (r, 0), (r, cao), mau: mau, day: day)
  if truc {
    doan(ctx, O, O1, mau: mau-phu, day: 1pt, dut: true)
    doan(ctx, O1, (r, cao), mau: mau-phu, day: 1pt)
    nhan(ctx, (r / 2, cao), ten-bk, huong: "tren", mau: mau-phu)
    diem(ctx, O, ten: ten-tam.at(0), huong: "trai", bk: 1.5pt)
    diem(ctx, O1, ten: ten-tam.at(1), huong: "trai", bk: 1.5pt)
  }
  goi-them(them, ctx, d)
})

// ---------- HÌNH CẦU ----------
#let hinh-cau(
  w: 5.6cm,
  r: 2.0,
  ten-tam: $O$, ten-bk: $R$,
  ban-kinh: true,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = hinh(w: w, xmin: -r - 0.5, xmax: r + 0.5, ymin: -r - 0.5, ymax: r + 0.5, ctx => {
  let O = (0.0, 0.0)
  let ry = r * 0.32
  duong-tron(ctx, O, r, mau: mau, day: day)
  // xích đạo: nửa trước liền, nửa sau đứt
  cung-elip(ctx, O, r, ry, tu: 180deg, den: 360deg, mau: mau, day: 0.9pt)
  cung-elip(ctx, O, r, ry, tu: 0deg, den: 180deg, mau: mau, day: 0.9pt, dut: true)
  diem(ctx, O, ten: ten-tam, huong: "duoi-trai", bk: 1.5pt)
  if ban-kinh {
    let M = (r * calc.cos(40deg), r * calc.sin(40deg))
    doan(ctx, O, M, mau: mau-phu, day: 1pt)
    diem(ctx, M, ten: none, bk: 1.5pt, mau: mau-phu)
    nhan(ctx, trung-diem(O, M), ten-bk, huong: "tren-trai", mau: mau-phu)
  }
  goi-them(them, ctx, (O: O))
})

// ---------- HỆ TRỤC TOẠ ĐỘ Oxyz ----------
#let truc-oxyz(
  w: 6cm,
  ten: ($x$, $y$, $z$),
  ten-goc: $O$,
  don-vi: false,   // vẽ 3 điểm đơn vị i, j, k
  mau: black, day: 1pt,
  them: none,
) = hinh(w: w, xmin: -2.2, xmax: 2.6, ymin: -1.9, ymax: 2.6, ctx => {
  let O = (0.0, 0.0)
  // Ox: chéo xuống trái (hướng về người nhìn), Oy: phải, Oz: lên
  let X = (-1.55, -1.55)
  let Y = (2.3, 0.0)
  let Z = (0.0, 2.3)
  mui-ten(ctx, O, X, mau: mau, day: day)
  mui-ten(ctx, O, Y, mau: mau, day: day)
  mui-ten(ctx, O, Z, mau: mau, day: day)
  nhan(ctx, X, ten.at(0), huong: "duoi-trai")
  nhan(ctx, Y, ten.at(1), huong: "duoi")
  nhan(ctx, Z, ten.at(2), huong: "phai")
  diem(ctx, O, ten: ten-goc, huong: "tren-phai", bk: 1.5pt)
  if don-vi {
    vecto(ctx, O, (-0.62, -0.62), ten: $arrow(i)$, huong: "duoi", mau: red)
    vecto(ctx, O, (0.9, 0), ten: $arrow(j)$, huong: "tren", mau: red)
    vecto(ctx, O, (0, 0.9), ten: $arrow(k)$, huong: "trai", mau: red)
  }
  goi-them(them, ctx, (O: O))
})

// =====================================================================
// HỆ TRỤC Oxyz CÓ TOẠ ĐỘ THẬT — điểm, vectơ, hộp gióng theo đơn vị
// Phép chiếu: Oy sang phải, Oz lên trên, Ox chéo xuống-trái về người nhìn.
//   #oxyz(x: 5, y: 8, z: 8, them: (ctx, t3) => {
//     diem-oxyz(ctx, t3, (5, 8, 8), ten: $B$, huong: "above-right")
//     giong-oxyz(ctx, t3, (5, 8, 8))
//     vecto-oxyz(ctx, t3, (0, 0, 0), (5, 8, 8), mau: purple)
//   })
// `them` nhận (ctx, t3): t3 đổi (x, y, z) -> điểm 2D, dùng được với MỌI
// hàm vẽ phẳng: diem(ctx, t3((1,2,3)), ...), doan(ctx, t3(A), t3(B), ...).
// =====================================================================
// Điểm 3D: chấm + nhãn.
#let diem-oxyz(ctx, t3, P, ten: none, huong: "above", bk: 2pt, mau: black) = {
  diem(ctx, t3(P), ten: ten, huong: huong, bk: bk, mau: mau)
}

// Đoạn / vectơ nối hai điểm 3D.
#let doan-oxyz(ctx, t3, A, B, mau: black, day: 1pt, dut: false) = {
  doan(ctx, t3(A), t3(B), mau: mau, day: day, dut: dut)
}
#let vecto-oxyz(ctx, t3, A, B, ten: none, huong: "tren", mau: black, day: 1.1pt, dut: false) = {
  vecto(ctx, t3(A), t3(B), ten: ten, huong: huong, mau: mau, day: day, dut: dut)
}

// Hộp gióng nét đứt từ gốc O đến điểm P = (a, b, c): vẽ các cạnh của
// hình hộp chữ nhật [0,a]×[0,b]×[0,c] (trừ 3 cạnh nằm trên trục).
#let giong-oxyz(ctx, t3, P, mau: blue, day: 0.8pt) = {
  let (a, b, c) = (P.at(0), P.at(1), P.at(2))
  let canh = ()
  if a != 0 and b != 0 {
    canh += (((a, 0, 0), (a, b, 0)), ((0, b, 0), (a, b, 0)))
  }
  if c != 0 {
    if a != 0 or b != 0 { canh += (((a, b, 0), (a, b, c)),) }
    if a != 0 { canh += (((0, 0, c), (a, 0, c)), ((a, 0, 0), (a, 0, c))) }
    if b != 0 { canh += (((0, 0, c), (0, b, c)), ((0, b, 0), (0, b, c))) }
    if a != 0 and b != 0 {
      canh += (((a, 0, c), (a, b, c)), ((0, b, c), (a, b, c)))
    }
  }
  for (A, B) in canh {
    doan(ctx, t3(A), t3(B), mau: mau, day: day, dut: true)
  }
}

// Các mốc bội của buoc trong [a, b], bỏ 0 (vạch chia/số/lưới của oxyz).
#let _moc-oxyz(a, b, buoc) = {
  let kq = ()
  let t = calc.ceil(a / buoc - 0.0001) * buoc
  while t <= b + 0.0001 {
    if calc.abs(t) > 0.0001 { kq.push(t) }
    t = t + buoc
  }
  kq
}

// Phạm vi một trục: n -> (0, n) | số âm -> (n, 0) | tuple (mn, mx) giữ nguyên.
#let _mien-oxyz(v) = if type(v) == array {
  (v.at(0), v.at(1))
} else if v < 0 { (v, 0) } else { (0, v) }

// Định dạng số gọn cho nhãn trục: 2.0 -> "2", 0.5 -> "0.5".
#let _so-oxyz(t) = if calc.abs(t - calc.round(t)) < 0.0001 {
  str(int(calc.round(t)))
} else { str(t) }

#let oxyz(
  w: 7cm,
  x: 4, y: 5, z: 4,        // phạm vi trục: n = [0, n] | số âm = [n, 0]
                           //   | tuple (mn, mx) = hai phía, vd x: (-2, 3)
  am: 0.8,                 // kéo dài thêm trục quá phạm vi (phía không mũi tên)
  ten: ($x$, $y$, $z$), ten-goc: $O$,
  don-vi: true,            // vẽ 3 vectơ đơn vị i, j, k
  mau-don-vi: (red, purple, green.darken(30%)),
  vach: false,             // vạch chia đơn vị trên 3 trục
  so: false,               // ghi số tại các vạch (bỏ qua 0)
  buoc: 1,                 // bước của vạch chia / số / lưới
  luoi: (),                // lưới trên mặt phẳng toạ độ: true = cả 3,
                           // hoặc tuple chọn: ("xy",), ("xy", "xz", "yz")
  mau-luoi: luma(84%),
  k: 0.55, goc: 35deg,     // hệ số & góc chiếu của trục Ox
  mau: black, day: 0.9pt,
  co-chu: 10pt,
  them: none,              // (ctx, t3) => nội dung vẽ thêm
) = {
  let t3 = P => (
    P.at(1) - k * P.at(0) * calc.cos(goc),
    P.at(2) - k * P.at(0) * calc.sin(goc),
  )
  let dm = 0.9   // lề cho mũi tên + nhãn
  // phạm vi từng trục (chấp nhận số âm / tuple 2 phía)
  let (xa, xb) = _mien-oxyz(x)
  let (ya, yb) = _mien-oxyz(y)
  let (za, zb) = _mien-oxyz(z)
  // cửa sổ: bao 8 đỉnh hộp phạm vi và đầu mút các trục
  let chot = (
    (xb + am + dm, 0, 0), (xa - am, 0, 0),
    (0, yb + am + dm, 0), (0, ya - am, 0),
    (0, 0, zb + am + dm), (0, 0, za - am),
  )
  for cx in (xa, xb) {
    for cy in (ya, yb) {
      for cz in (za, zb) { chot.push((cx, cy, cz)) }
    }
  }
  let chot = chot.map(t3)
  let xs = chot.map(p => p.at(0))
  let ys = chot.map(p => p.at(1))
  let (x1, x2) = (calc.min(..xs) - 0.35, calc.max(..xs) + 0.35)
  let (y1, y2) = (calc.min(..ys) - 0.35, calc.max(..ys) + 0.35)
  hinh(w: w, xmin: x1, xmax: x2, ymin: y1, ymax: y2, co-chu: co-chu, ctx => {
    // lưới trên các mặt phẳng toạ độ (vẽ TRƯỚC để nằm dưới trục)
    let mp = if luoi == true { ("xy", "xz", "yz") } else if luoi == none or luoi == false { () } else if type(luoi) == str { (luoi,) } else { luoi }
    for m in mp {
      if m == "xy" {
        for i in _moc-oxyz(xa, xb, buoc) { doan(ctx, t3((i, ya, 0)), t3((i, yb, 0)), mau: mau-luoi, day: 0.5pt) }
        for j in _moc-oxyz(ya, yb, buoc) { doan(ctx, t3((xa, j, 0)), t3((xb, j, 0)), mau: mau-luoi, day: 0.5pt) }
      } else if m == "xz" {
        for i in _moc-oxyz(xa, xb, buoc) { doan(ctx, t3((i, 0, za)), t3((i, 0, zb)), mau: mau-luoi, day: 0.5pt) }
        for l in _moc-oxyz(za, zb, buoc) { doan(ctx, t3((xa, 0, l)), t3((xb, 0, l)), mau: mau-luoi, day: 0.5pt) }
      } else if m == "yz" {
        for j in _moc-oxyz(ya, yb, buoc) { doan(ctx, t3((0, j, za)), t3((0, j, zb)), mau: mau-luoi, day: 0.5pt) }
        for l in _moc-oxyz(za, zb, buoc) { doan(ctx, t3((0, ya, l)), t3((0, yb, l)), mau: mau-luoi, day: 0.5pt) }
      }
    }
    mui-ten(ctx, t3((xa - am, 0, 0)), t3((xb + am + dm, 0, 0)), mau: mau, day: day)
    mui-ten(ctx, t3((0, ya - am, 0)), t3((0, yb + am + dm, 0)), mau: mau, day: day)
    mui-ten(ctx, t3((0, 0, za - am)), t3((0, 0, zb + am + dm)), mau: mau, day: day)
    nhan(ctx, t3((xb + am + dm, 0, 0)), ten.at(0), huong: "below-left", cach: 5pt)
    nhan(ctx, t3((0, yb + am + dm, 0)), ten.at(1), huong: "below", cach: 5pt)
    nhan(ctx, t3((0, 0, zb + am + dm)), ten.at(2), huong: "left", cach: 5pt)
    nhan(ctx, t3((0, 0, 0)), ten-goc, huong: "below-right", cach: 4pt)
    // vạch chia đơn vị + số trên 3 trục (vạch vuông góc với trục trên trang)
    if vach or so {
      let bo3 = (
        ((1, 0, 0), xa, xb, tm => t3((tm, 0, 0)), "below"),
        ((0, 1, 0), ya, yb, tm => t3((0, tm, 0)), "below"),
        ((0, 0, 1), za, zb, tm => t3((0, 0, tm)), "left"),
      )
      for (u, lo, hi, f, hg) in bo3 {
        let o2 = toa-pt(ctx, t3((0, 0, 0)))
        let u2 = toa-pt(ctx, t3(u))
        let (dx, dy) = (u2.at(0) - o2.at(0), u2.at(1) - o2.at(1))
        let l = calc.sqrt(dx * dx + dy * dy)
        let (nx, ny) = (-dy / l, dx / l)
        for tm in _moc-oxyz(lo, hi, buoc) {
          let p = toa-pt(ctx, f(tm))
          if vach {
            doan-pt(
              (p.at(0) - 2.2 * nx, p.at(1) - 2.2 * ny),
              (p.at(0) + 2.2 * nx, p.at(1) + 2.2 * ny),
              mau: mau, day: 0.8pt,
            )
          }
          if so { nhan(ctx, f(tm), $#_so-oxyz(tm)$, huong: hg, cach: 4pt) }
        }
      }
    }
    if don-vi {
      vecto(ctx, t3((0, 0, 0)), t3((1, 0, 0)), ten: $arrow(i)$, huong: "trai", mau: mau-don-vi.at(0), day: 1.2pt)
      vecto(ctx, t3((0, 0, 0)), t3((0, 1, 0)), ten: $arrow(j)$, huong: "tren", mau: mau-don-vi.at(1), day: 1.2pt)
      vecto(ctx, t3((0, 0, 0)), t3((0, 0, 1)), ten: $arrow(k)$, huong: "trai", mau: mau-don-vi.at(2), day: 1.2pt)
    }
    if them != none { them(ctx, t3) }
  })
}

// =====================================================================
// LỤC GIÁC ĐỀU & CHÓP CỤT ĐỀU — engine chiếu + phân loại nét khuất
// Đáy đa giác đều NẰM NGANG (z = const), nhìn chếch từ trước-trên.
// Nét khuất (đáy sau + cạnh bên tới đỉnh sau) TỰ vẽ đứt theo hình chiếu.
//   #hinh-chop-luc-giac-deu()          — chóp lục giác đều S.ABCDEF
//   #hinh-lang-tru-luc-giac-deu()      — lăng trụ lục giác đều ABCDEF.A'…F'
//   #hinh-chop-cut-deu(n: 3|4|6)       — chóp cụt đều tam/tứ/lục giác
// =====================================================================
// Chiếu điểm 3D (x, y, z) -> điểm 2D trên trang (y = chiều sâu ra sau).
#let _pr(P) = (
  P.at(0) + 0.5 * P.at(1) * calc.cos(40deg),
  P.at(2) + 0.5 * P.at(1) * calc.sin(40deg),
)

// Đỉnh đa giác đều n cạnh, tâm trục Oz, bán kính R, độ cao z, lệch pha.
#let _dinh-deu(n, R, z, pha) = range(n).map(i => {
  let a = pha + i * 360deg / n
  (R * calc.cos(a), R * calc.sin(a), z)
})

// Pha mặc định: đỉnh A rơi vào phía trước-trái, các cạnh trước hiện rõ.
// n = 6 dùng 210° (như n = 3): các đỉnh toả đều 2 phía, D và E (hay D', E')
// không dồn sát nhau bên phải như pha 180° cũ.
#let _pha-deu(n) = if n == 3 { 210deg } else if n == 4 { 225deg } else { 210deg }

// Phân loại nét khuất của đáy: trả (canh-sau, dinh-sau).
// P2: đỉnh đáy đã chiếu; y3: độ sâu 3D tương ứng. Đáy lồi -> hai chuỗi
// giữa đỉnh trái-nhất và phải-nhất; chuỗi có độ sâu lớn hơn là "sau" (khuất).
#let _khuat(P2, y3) = {
  let n = P2.len()
  let L = 0
  let R = 0
  for i in range(n) {
    if P2.at(i).at(0) < P2.at(L).at(0) { L = i }
    if P2.at(i).at(0) > P2.at(R).at(0) { R = i }
  }
  let ch1 = ()
  let i = L
  while i != R { ch1.push(i); i = calc.rem(i + 1, n) }
  ch1.push(R)
  let ch2 = ()
  let j = L
  while j != R { ch2.push(j); j = calc.rem(j + n - 1, n) }
  ch2.push(R)
  let tb(ch) = ch.map(k => y3.at(k)).sum() / ch.len()
  let sau = if tb(ch1) >= tb(ch2) { ch1 } else { ch2 }
  let canh-sau = ()
  for t in range(sau.len() - 1) { canh-sau.push((sau.at(t), sau.at(t + 1))) }
  (canh-sau: canh-sau, dinh-sau: sau.slice(1, sau.len() - 1))
}
#let _la-khuat(canh, i, j) = canh.any(c => (c.at(0) == i and c.at(1) == j) or (c.at(0) == j and c.at(1) == i))

// Cửa sổ bao các điểm 2D + lề.
#let _cua-so-2d(pts, mg: 0.7) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  (xmin: calc.min(..xs) - mg, xmax: calc.max(..xs) + mg, ymin: calc.min(..ys) - mg, ymax: calc.max(..ys) + mg)
}

// ---------- CHÓP LỤC GIÁC ĐỀU S.ABCDEF ----------
#let hinh-chop-luc-giac-deu(
  w: 7cm,
  R: 2.0, cao: 3.8,
  ten: ($S$, $A$, $B$, $C$, $D$, $E$, $F$),
  ten-tam: $O$,
  duong-cao: true,
  mau: black, mau-phu: red, day: 1.1pt,
  them: none,
) = {
  let n = 6
  let B3 = _dinh-deu(n, R, 0, _pha-deu(n))
  let S3 = (0, 0, cao)
  let O3 = (0, 0, 0)
  let B2 = B3.map(_pr)
  let S2 = _pr(S3)
  let O2 = _pr(O3)
  let kl = _khuat(B2, B3.map(P => P.at(1)))
  let cs = _cua-so-2d(B2 + (S2,))
  hinh(w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax, ctx => {
    // cạnh đáy: sau đứt
    for i in range(n) {
      let j = calc.rem(i + 1, n)
      doan(ctx, B2.at(i), B2.at(j), mau: mau, day: day, dut: _la-khuat(kl.canh-sau, i, j))
    }
    // cạnh bên: tới đỉnh sau thì đứt
    for i in range(n) {
      doan(ctx, S2, B2.at(i), mau: mau, day: day, dut: kl.dinh-sau.contains(i))
    }
    if duong-cao {
      doan(ctx, S2, O2, mau: mau-phu, day: 1pt, dut: true)
      goc-vuong(ctx, O2, S2, B2.at(0), r: 0.26, mau: mau-phu)
      diem(ctx, O2, ten: ten-tam, huong: "below", bk: 1.5pt, mau: mau-phu)
    }
    let G = trong-tam(..B2, S2)
    diem(ctx, S2, ten: ten.at(0), huong: huong-ra(S2, G))
    for i in range(n) { diem(ctx, B2.at(i), ten: ten.at(i + 1), huong: huong-ra(B2.at(i), G)) }
    if them != none { them(ctx, (S: S3, O: O3, day: B3)) }
  })
}

// ---------- LĂNG TRỤ LỤC GIÁC ĐỀU ABCDEF.A'B'C'D'E'F' ----------
#let hinh-lang-tru-luc-giac-deu(
  w: 7cm,
  R: 1.9, cao: 3.4,
  ten: ($A$, $B$, $C$, $D$, $E$, $F$, $A'$, $B'$, $C'$, $D'$, $E'$, $F'$),
  mau: black, day: 1.1pt,
  them: none,
) = {
  let n = 6
  let pha = _pha-deu(n)
  let B3 = _dinh-deu(n, R, 0, pha)
  let T3 = _dinh-deu(n, R, cao, pha)
  let B2 = B3.map(_pr)
  let T2 = T3.map(_pr)
  let kl = _khuat(B2, B3.map(P => P.at(1)))
  let cs = _cua-so-2d(B2 + T2)
  hinh(w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax, ctx => {
    // đáy trên: liền hết
    for i in range(n) {
      let j = calc.rem(i + 1, n)
      doan(ctx, T2.at(i), T2.at(j), mau: mau, day: day)
    }
    // cạnh bên
    for i in range(n) {
      doan(ctx, B2.at(i), T2.at(i), mau: mau, day: day, dut: kl.dinh-sau.contains(i))
    }
    // đáy dưới: sau đứt
    for i in range(n) {
      let j = calc.rem(i + 1, n)
      doan(ctx, B2.at(i), B2.at(j), mau: mau, day: day, dut: _la-khuat(kl.canh-sau, i, j))
    }
    let Gb = trong-tam(..B2)
    let Gt = trong-tam(..T2)
    for i in range(n) { diem(ctx, B2.at(i), ten: ten.at(i), huong: huong-ra(B2.at(i), Gt)) }
    for i in range(n) { diem(ctx, T2.at(i), ten: ten.at(i + n), huong: huong-ra(T2.at(i), Gb)) }
    if them != none { them(ctx, (duoi: B3, tren: T3)) }
  })
}

// ---------- CHÓP CỤT ĐỀU (tam/tứ/lục giác) ABCD….A'B'C'D'… ----------
// n: 3 | 4 | 6.  R: bán kính đáy lớn (dưới), r: bán kính đáy nhỏ (trên).
#let hinh-chop-cut-luc-giac-deu(
  n: 6,
  w: 7cm,
  R: 2.3, r: 1.25, cao: 3.0,
  ten: auto,        // auto: A,B,… (đáy dưới) + phẩy (đáy trên); hoặc mảng 2n nội dung
  mau: black, day: 1.1pt,
  truc: false, ten-tam: ($O$, $O'$),
  mau-phu: red,
  them: none,
) = {
  let pha = _pha-deu(n)
  let B3 = _dinh-deu(n, R, 0, pha)
  let T3 = _dinh-deu(n, r, cao, pha)
  let B2 = B3.map(_pr)
  let T2 = T3.map(_pr)
  let kl = _khuat(B2, B3.map(P => P.at(1)))
  let chu = ("A", "B", "C", "D", "E", "F", "G", "H")
  let ten2 = if ten == auto {
    range(n).map(i => eval(chu.at(i), mode: "math")) + range(n).map(i => eval(chu.at(i) + "'", mode: "math"))
  } else { ten }
  let O3 = (0, 0, 0)
  let O13 = (0, 0, cao)
  let cs = _cua-so-2d(B2 + T2)
  hinh(w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax, ctx => {
    // đáy trên: liền hết
    for i in range(n) {
      let j = calc.rem(i + 1, n)
      doan(ctx, T2.at(i), T2.at(j), mau: mau, day: day)
    }
    // cạnh bên
    for i in range(n) {
      doan(ctx, B2.at(i), T2.at(i), mau: mau, day: day, dut: kl.dinh-sau.contains(i))
    }
    // đáy dưới: sau đứt
    for i in range(n) {
      let j = calc.rem(i + 1, n)
      doan(ctx, B2.at(i), B2.at(j), mau: mau, day: day, dut: _la-khuat(kl.canh-sau, i, j))
    }
    if truc {
      let O2 = _pr(O3)
      let O12 = _pr(O13)
      doan(ctx, O2, O12, mau: mau-phu, day: 1pt, dut: true)
      diem(ctx, O2, ten: ten-tam.at(0), huong: "below", bk: 1.1pt, mau: mau-phu)
      diem(ctx, O12, ten: ten-tam.at(1), huong: "above", bk: 1.1pt, mau: mau-phu)
    }
    let Gb = trong-tam(..B2)
    let Gt = trong-tam(..T2)
    for i in range(n) { diem(ctx, B2.at(i), ten: ten2.at(i), huong: huong-ra(B2.at(i), Gt)) }
    for i in range(n) { diem(ctx, T2.at(i), ten: ten2.at(i + n), huong: huong-ra(T2.at(i), Gb)) }
    if them != none { them(ctx, (duoi: B3, tren: T3)) }
  })
}

// Bí danh chóp cụt đều theo số cạnh đáy (cùng bộ tham số ở trên):
//   #hinh-chop-cut-deu(n: 3|4|6)      — gọi chung
//   #hinh-chop-cut-tam-giac-deu()     — ABC.A'B'C'
//   #hinh-chop-cut-tu-giac-deu()      — ABCD.A'B'C'D'
#let hinh-chop-cut-deu = hinh-chop-cut-luc-giac-deu
#let hinh-chop-cut-tam-giac-deu(..th) = hinh-chop-cut-luc-giac-deu(n: 3, ..th)
#let hinh-chop-cut-tu-giac-deu(..th) = hinh-chop-cut-luc-giac-deu(n: 4, ..th)
