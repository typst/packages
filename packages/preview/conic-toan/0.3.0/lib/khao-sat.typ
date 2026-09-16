// =====================================================================
// khao-sat.typ — KHẢO SÁT & VẼ ĐỒ THỊ TỰ ĐỘNG TỪ HỆ SỐ
//
// 5 hàm, chỉ cần nhập hệ số (như bbt-*/do-thi-*) là xổ ra TRỌN lời giải
// (tập xác định, đạo hàm, giới hạn, chiều biến thiên, cực trị / tiệm cận,
//  bảng biến thiên) kèm ĐỒ THỊ — bao quát mọi trường hợp của mỗi hàm:
//
//   #khao-sat-ve-do-thi-ham-bac-hai(a, b, c)          y = ax² + bx + c
//   #khao-sat-ve-do-thi-ham-bac-ba(a, b, c, d)        y = ax³ + bx² + cx + d
//   #khao-sat-ve-do-thi-ham-trung-phuong(a, b, c)     y = ax⁴ + bx² + c
//   #khao-sat-ve-do-thi-ham-phan-thuc(a, b, c, d)     y = (ax + b)/(cx + d)
//   #khao-sat-ve-do-thi-ham-huu-ti(a, b, c, d, e)     y = (ax² + bx + c)/(dx + e)
//
// Tham số chung:
//   tieu-de: auto  -> dòng đậm "Khảo sát sự biến thiên và vẽ đồ thị của
//                     hàm số y = ..."; none -> bỏ tiêu đề; hoặc nội dung tuỳ ý.
//   w: bề rộng đồ thị (mặc định 7.6cm).  giua: true -> canh giữa BBT + đồ thị.
// =====================================================================
#import "do-thi.typ": so-toan, so-dep, so-can-thuc, cuc-tri-bac-ba, cuc-tri-huu-ti, do-thi-bac-hai, do-thi-bac-ba, do-thi-trung-phuong, do-thi-phan-thuc, do-thi-huu-ti
#import "bang.typ": bbt-bac-hai, bbt-bac-ba, bbt-trung-phuong, bbt-phan-thuc, bbt-huu-ti

#let _eps = 0.000001
#let _ninf = $-oo$
#let _pinf = $+oo$

// ----- Đơn thức |co|·x^mu (không kèm dấu) -----
#let _don-thuc(co, mu) = {
  let mag = calc.abs(co)
  let bien = if mu == 0 { none } else if mu == 1 { $x$ } else { $x^#mu$ }
  if bien == none { so-toan(mag) }
  else if calc.abs(mag - 1) < _eps { bien }
  else { $#so-toan(mag) #bien$ }
}

// ----- Đa thức: danh sách (hệ số, số mũ) giảm dần -> nội dung math -----
#let _da-thuc(cac) = {
  let cac = cac.filter(t => calc.abs(t.at(0)) > _eps)
  if cac.len() == 0 { return $0$ }
  let acc = $0$
  for (i, t) in cac.enumerate() {
    let (co, mu) = t
    let than = _don-thuc(co, mu)
    if i == 0 {
      acc = if co < 0 { $-#than$ } else { than }
    } else {
      acc = if co < 0 { $#acc - #than$ } else { $#acc + #than$ }
    }
  }
  acc
}

// ----- Khoảng (a; b) — a, b là nội dung math; dùng TRONG MARKUP: #_kh(..) -----
#let _kh(a, b) = $(#a ; #b)$

// ----- Dòng tiêu đề "Khảo sát ... y = <bt>" -----
#let _tieu-de(tieu-de, bt) = {
  if tieu-de == none { return none }
  let nd = if tieu-de == auto { [Khảo sát sự biến thiên và vẽ đồ thị của hàm số $y = #bt$] } else { tieu-de }
  [*#nd* ]
}

// ----- Khối canh giữa (hoặc để nguyên) cho BBT/đồ thị -----
#let _o(giua, than) = if giua { align(center, than) } else { than }

// =====================================================================
// 1) BẬC HAI: y = ax² + bx + c
// =====================================================================
#let khao-sat-ve-do-thi-ham-bac-hai(a, b, c, tieu-de: auto, w: 7.6cm, giua: false) = {
  assert(calc.abs(a) > _eps, message: "bac-hai: cần a ≠ 0")
  let bt = _da-thuc(((a, 2), (b, 1), (c, 0)))
  let xd = -b / (2 * a)          // hoành độ đỉnh
  let yd = c - b * b / (4 * a)   // tung độ đỉnh
  let dlt = b * b - 4 * a * c
  let Xd = so-toan(xd)
  let Yd = so-toan(yd)
  let cbt = if a > 0 {
    [Hàm số nghịch biến trên khoảng #_kh(_ninf, Xd) và đồng biến trên khoảng #_kh(Xd, _pinf)#"."]
  } else {
    [Hàm số đồng biến trên khoảng #_kh(_ninf, Xd) và nghịch biến trên khoảng #_kh(Xd, _pinf)#"."]
  }
  let ct = if a > 0 {
    [Hàm số đạt cực tiểu tại $x = #Xd$, $y_("CT") = #Yd$; không có cực đại.]
  } else {
    [Hàm số đạt cực đại tại $x = #Xd$, $y_("CĐ") = #Yd$; không có cực tiểu.]
  }
  let gh = if a > 0 {
    [$limits(lim)_(x -> -oo) y = +oo$; $limits(lim)_(x -> +oo) y = +oo$.]
  } else {
    [$limits(lim)_(x -> -oo) y = -oo$; $limits(lim)_(x -> +oo) y = -oo$.]
  }
  let giao-ox = if dlt > _eps {
    let s = calc.sqrt(dlt) / (2 * calc.abs(a))
    [cắt trục hoành tại hai điểm $(#so-toan(xd - s) ; 0)$ và $(#so-toan(xd + s) ; 0)$]
  } else if dlt < -_eps {
    [không cắt trục hoành]
  } else {
    [tiếp xúc trục hoành tại $(#Xd ; 0)$]
  }
  [
    #_tieu-de(tieu-de, bt)
    - Tập xác định: $D = RR$.
    - Sự biến thiên:
      + Đạo hàm: $y' = #_da-thuc(((2 * a, 1), (b, 0)))$; $y' = 0 <=> x = #Xd$.
      + Giới hạn: #gh
      + Chiều biến thiên: #cbt
      + Cực trị: #ct
      + Bảng biến thiên:
      #_o(giua, bbt-bac-hai(a, b, c))
    - Đồ thị:
      + Đỉnh $I(#Xd ; #Yd)$, trục đối xứng $x = #Xd$.
      + Đồ thị cắt trục tung tại $(0; #so-toan(c))$ và #giao-ox.
      #_o(giua, do-thi-bac-hai(a, b, c, w: w))
  ]
}

// =====================================================================
// 2) BẬC BA: y = ax³ + bx² + cx + d   (Δ' = b² − 3ac)
// =====================================================================
#let khao-sat-ve-do-thi-ham-bac-ba(a, b, c, d, tieu-de: auto, w: 7.6cm, giua: false) = {
  assert(calc.abs(a) > _eps, message: "bac-ba: cần a ≠ 0")
  let bt = _da-thuc(((a, 3), (b, 2), (c, 1), (d, 0)))
  let f = x => ((a * x + b) * x + c) * x + d
  let delta = b * b - 3 * a * c
  let xu = -b / (3 * a)                 // hoành độ điểm uốn
  let yu = f(xu)
  let gh = if a > 0 {
    [$limits(lim)_(x -> -oo) y = -oo$; $limits(lim)_(x -> +oo) y = +oo$.]
  } else {
    [$limits(lim)_(x -> -oo) y = +oo$; $limits(lim)_(x -> +oo) y = -oo$.]
  }
  let dao = _da-thuc(((3 * a, 2), (2 * b, 1), (c, 0)))
  let cbt = []
  let ct = []
  let dao-them = []
  if delta > _eps {
    // hai cực trị — hoành độ & giá trị CHÍNH XÁC dạng căn thức
    let ctr = cuc-tri-bac-ba(a, b, c, d)
    let U = ctr.x1
    let V = ctr.x2
    let Fu = ctr.y1
    let Fv = ctr.y2
    dao-them = [ $y' = 0 <=> x = #U$ hoặc $x = #V$.]
    if a > 0 {
      cbt = [Hàm số đồng biến trên các khoảng #_kh(_ninf, U) và #_kh(V, _pinf)#"; "nghịch biến trên khoảng #_kh(U, V)#"."]
      ct = [Hàm số đạt cực đại tại $x = #U$, $y_("CĐ") = #Fu$; đạt cực tiểu tại $x = #V$, $y_("CT") = #Fv$.]
    } else {
      cbt = [Hàm số nghịch biến trên các khoảng #_kh(_ninf, U) và #_kh(V, _pinf)#"; "đồng biến trên khoảng #_kh(U, V)#"."]
      ct = [Hàm số đạt cực tiểu tại $x = #U$, $y_("CT") = #Fu$; đạt cực đại tại $x = #V$, $y_("CĐ") = #Fv$.]
    }
  } else if delta < -_eps {
    // đơn điệu, y' vô nghiệm
    dao-them = [ Vì $Delta' = #so-toan(delta) < 0$ nên $y'$ không đổi dấu.]
    cbt = if a > 0 {
      [Hàm số đồng biến trên khoảng #_kh(_ninf, _pinf)#"."]
    } else {
      [Hàm số nghịch biến trên khoảng #_kh(_ninf, _pinf)#"."]
    }
    ct = [Hàm số không có cực trị.]
  } else {
    // Δ' = 0: nghiệm kép, vẫn đơn điệu
    dao-them = [ $y' = 0 <=> x = #so-toan(xu)$ (nghiệm kép), $y'$ không đổi dấu.]
    cbt = if a > 0 {
      [Hàm số đồng biến trên khoảng #_kh(_ninf, _pinf)#"."]
    } else {
      [Hàm số nghịch biến trên khoảng #_kh(_ninf, _pinf)#"."]
    }
    ct = [Hàm số không có cực trị.]
  }
  [
    #_tieu-de(tieu-de, bt)
    - Tập xác định: $D = RR$.
    - Sự biến thiên:
      + Đạo hàm: $y' = #dao$.#dao-them
      + Giới hạn: #gh
      + Chiều biến thiên: #cbt
      + Cực trị: #ct
      + Bảng biến thiên:
      #_o(giua, bbt-bac-ba(a, b, c, d))
    - Đồ thị:
      + Đạo hàm cấp hai: $y'' = #_da-thuc(((6 * a, 1), (2 * b, 0)))$; $y'' = 0 <=> x = #so-toan(xu)$. Điểm uốn $I(#so-toan(xu) ; #so-toan(yu))$.
      + Đồ thị cắt trục tung tại $(0; #so-toan(d))$.
      #_o(giua, do-thi-bac-ba(a, b, c, d, w: w))
  ]
}

// =====================================================================
// 3) TRÙNG PHƯƠNG: y = ax⁴ + bx² + c   (a·b < 0 -> 3 cực trị)
// =====================================================================
#let khao-sat-ve-do-thi-ham-trung-phuong(a, b, c, tieu-de: auto, w: 7.6cm, giua: false) = {
  assert(calc.abs(a) > _eps, message: "trung-phuong: cần a ≠ 0")
  let bt = _da-thuc(((a, 4), (b, 2), (c, 0)))
  let f = x => a * calc.pow(x, 4) + b * x * x + c
  let dao = _da-thuc(((4 * a, 3), (2 * b, 1)))
  let gh = if a > 0 {
    [$limits(lim)_(x -> -oo) y = +oo$; $limits(lim)_(x -> +oo) y = +oo$.]
  } else {
    [$limits(lim)_(x -> -oo) y = -oo$; $limits(lim)_(x -> +oo) y = -oo$.]
  }
  let cbt = []
  let ct = []
  let dao-them = []
  if a * b < -_eps {
    // 3 cực trị: x = 0, x = ±xc
    let Xc = so-can-thuc(0, 1, -b / (2 * a), 1)
    let nXc = so-can-thuc(0, -1, -b / (2 * a), 1)
    let yc = so-can-thuc(4 * a * c - b * b, 0, 0, 4 * a)
    let y0 = so-toan(c)
    dao-them = [ $y' = 0 <=> x = 0$ hoặc $x = plus.minus #Xc$.]
    if a > 0 {
      cbt = [Hàm số nghịch biến trên các khoảng #_kh(_ninf, nXc) và #_kh($0$, Xc)#"; "đồng biến trên các khoảng #_kh(nXc, $0$) và #_kh(Xc, _pinf)#"."]
      ct = [Hàm số đạt cực tiểu tại $x = plus.minus #Xc$, $y_("CT") = #yc$; đạt cực đại tại $x = 0$, $y_("CĐ") = #y0$.]
    } else {
      cbt = [Hàm số đồng biến trên các khoảng #_kh(_ninf, nXc) và #_kh($0$, Xc)#"; "nghịch biến trên các khoảng #_kh(nXc, $0$) và #_kh(Xc, _pinf)#"."]
      ct = [Hàm số đạt cực đại tại $x = plus.minus #Xc$, $y_("CĐ") = #yc$; đạt cực tiểu tại $x = 0$, $y_("CT") = #y0$.]
    }
  } else {
    // 1 cực trị tại x = 0
    dao-them = [ $y' = 0 <=> x = 0$.]
    if a > 0 {
      cbt = [Hàm số nghịch biến trên khoảng #_kh(_ninf, $0$) và đồng biến trên khoảng #_kh($0$, _pinf)#"."]
      ct = [Hàm số đạt cực tiểu tại $x = 0$, $y_("CT") = #so-toan(c)$; không có cực đại.]
    } else {
      cbt = [Hàm số đồng biến trên khoảng #_kh(_ninf, $0$) và nghịch biến trên khoảng #_kh($0$, _pinf)#"."]
      ct = [Hàm số đạt cực đại tại $x = 0$, $y_("CĐ") = #so-toan(c)$; không có cực tiểu.]
    }
  }
  [
    #_tieu-de(tieu-de, bt)
    - Tập xác định: $D = RR$.
    - Sự biến thiên:
      + Đạo hàm: $y' = #dao$.#dao-them
      + Giới hạn: #gh
      + Chiều biến thiên: #cbt
      + Cực trị: #ct
      + Bảng biến thiên:
      #_o(giua, bbt-trung-phuong(a, b, c))
    - Đồ thị:
      + Đồ thị cắt trục tung tại $(0; #so-toan(c))$; là hàm số chẵn nên nhận trục $O y$ làm trục đối xứng.
      #_o(giua, do-thi-trung-phuong(a, b, c, w: w))
  ]
}

// =====================================================================
// 4) PHÂN THỨC BẬC NHẤT/BẬC NHẤT: y = (ax + b)/(cx + d)
// =====================================================================
#let khao-sat-ve-do-thi-ham-phan-thuc(a, b, c, d, tieu-de: auto, w: 7.6cm, giua: false) = {
  assert(calc.abs(c) > _eps, message: "phan-thuc: cần c ≠ 0")
  let D = a * d - b * c
  assert(calc.abs(D) > _eps, message: "phan-thuc: ad − bc = 0 (hàm hằng)")
  let tu = _da-thuc(((a, 1), (b, 0)))
  let mau = _da-thuc(((c, 1), (d, 0)))
  let bt = $(#tu)/(#mau)$
  let x0 = -d / c        // TCĐ
  let y0 = a / c         // TCN
  let X0 = so-toan(x0)
  let Y0 = so-toan(y0)
  let dong = D > 0
  let dao = if dong {
    $y' = #so-toan(D)/(#mau)^2 > 0, forall x != #X0$
  } else {
    $y' = #so-toan(D)/(#mau)^2 < 0, forall x != #X0$
  }
  let cbt = if dong {
    [Hàm số đồng biến trên từng khoảng #_kh(_ninf, X0) và #_kh(X0, _pinf)#"."]
  } else {
    [Hàm số nghịch biến trên từng khoảng #_kh(_ninf, X0) và #_kh(X0, _pinf)#"."]
  }
  let trai = if dong { _ninf } else { _pinf }
  let phai = if dong { _pinf } else { _ninf }
  [
    #_tieu-de(tieu-de, bt)
    - Tập xác định: $D = RR without {#X0}$.
    - Sự biến thiên:
      + Chiều biến thiên: #dao. #cbt
      + Cực trị: Hàm số không có cực trị.
      + Tiệm cận:
        $limits(lim)_(x -> #X0^-) y = #trai$, $limits(lim)_(x -> #X0^+) y = #phai$ nên đường thẳng $x = #X0$ là tiệm cận đứng.
        $limits(lim)_(x -> plus.minus oo) y = #Y0$ nên đường thẳng $y = #Y0$ là tiệm cận ngang.
      + Bảng biến thiên:
      #_o(giua, bbt-phan-thuc(a, b, c, d))
    - Đồ thị:
      + Đồ thị nhận điểm $I(#X0 ; #Y0)$ (giao hai tiệm cận) làm tâm đối xứng.
      #_o(giua, do-thi-phan-thuc(a, b, c, d, w: w))
  ]
}

// =====================================================================
// 5) HỮU TỈ BẬC HAI/BẬC NHẤT: y = (ax² + bx + c)/(dx + e)
//    Viết y = px + q + r/(dx + e); p = a/d, q = (bd − ae)/d², r = c − qe.
// =====================================================================
#let khao-sat-ve-do-thi-ham-huu-ti(a, b, c, d, e, tieu-de: auto, w: 7.6cm, giua: false) = {
  assert(calc.abs(a) > _eps and calc.abs(d) > _eps, message: "huu-ti: cần a ≠ 0 và d ≠ 0")
  let tu = _da-thuc(((a, 2), (b, 1), (c, 0)))
  let mau = _da-thuc(((d, 1), (e, 0)))
  let bt = $(#tu)/(#mau)$
  let x0 = -e / d
  let p = a / d
  let q = (b * d - a * e) / (d * d)
  let r = c - q * e
  let f = x => (a * x * x + b * x + c) / (d * x + e)
  let X0 = so-toan(x0)
  let tcx = _da-thuc(((p, 1), (q, 0)))        // y = px + q
  let co-ct = p != 0 and r * d * p > _eps
  // y' = p + k/(dx+e)² với k = −rd
  let k = -r * d
  let dao = if k > _eps { $y' = #so-toan(p) + #so-toan(k)/(#mau)^2$ }
    else if k < -_eps { $y' = #so-toan(p) - #so-toan(-k)/(#mau)^2$ }
    else { $y' = #so-toan(p)$ }
  let cbt = []
  let ct = []
  let dao-them = []
  if co-ct {
    // hoành độ & giá trị cực trị CHÍNH XÁC dạng căn thức
    let ctr = cuc-tri-huu-ti(a, b, c, d, e)
    let U = ctr.x1
    let V = ctr.x2
    let Fu = ctr.y1
    let Fv = ctr.y2
    dao-them = [ $y' = 0 <=> x = #U$ hoặc $x = #V$.]
    if p > 0 {
      cbt = [Hàm số đồng biến trên các khoảng #_kh(_ninf, U) và #_kh(V, _pinf)#"; "nghịch biến trên các khoảng #_kh(U, X0) và #_kh(X0, V)#"."]
      ct = [Hàm số đạt cực đại tại $x = #U$, $y_("CĐ") = #Fu$; đạt cực tiểu tại $x = #V$, $y_("CT") = #Fv$.]
    } else {
      cbt = [Hàm số nghịch biến trên các khoảng #_kh(_ninf, U) và #_kh(V, _pinf)#"; "đồng biến trên các khoảng #_kh(U, X0) và #_kh(X0, V)#"."]
      ct = [Hàm số đạt cực tiểu tại $x = #U$, $y_("CT") = #Fu$; đạt cực đại tại $x = #V$, $y_("CĐ") = #Fv$.]
    }
  } else {
    dao-them = [ (không đổi dấu trên tập xác định).]
    if p > 0 {
      cbt = [Hàm số đồng biến trên từng khoảng #_kh(_ninf, X0) và #_kh(X0, _pinf)#"."]
    } else {
      cbt = [Hàm số nghịch biến trên từng khoảng #_kh(_ninf, X0) và #_kh(X0, _pinf)#"."]
    }
    ct = [Hàm số không có cực trị.]
  }
  let trai = if r * d > 0 { _ninf } else { _pinf }
  let phai = if r * d > 0 { _pinf } else { _ninf }
  [
    #_tieu-de(tieu-de, bt)
    - Tập xác định: $D = RR without {#X0}$.
    - Sự biến thiên:
      + Chiều biến thiên: #dao.#dao-them #cbt
      + Cực trị: #ct
      + Tiệm cận:
        $limits(lim)_(x -> #X0^-) y = #trai$, $limits(lim)_(x -> #X0^+) y = #phai$ nên đường thẳng $x = #X0$ là tiệm cận đứng.
        $limits(lim)_(x -> plus.minus oo) [y - (#tcx)] = 0$ nên đường thẳng $y = #tcx$ là tiệm cận xiên.
      + Bảng biến thiên:
      #_o(giua, bbt-huu-ti(a, b, c, d, e))
    - Đồ thị:
      + Đồ thị nhận giao hai tiệm cận làm tâm đối xứng.
      #_o(giua, do-thi-huu-ti(a, b, c, d, e, w: w))
  ]
}
// (đồng bộ mount 07/2026)
