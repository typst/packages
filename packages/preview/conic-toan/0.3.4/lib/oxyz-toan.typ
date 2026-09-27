// =====================================================================
// oxyz-toan.typ — TÍNH TOÁN trong không gian toạ độ Oxyz
//   Toàn bộ hàm ở file này TRẢ VỀ GIÁ TRỊ (số / điểm / dict) hoặc NỘI DUNG
//   toán đã định dạng ⇒ KHÔNG kê vào `ve-voi` / `_voi-ctx` của baigiang.typ.
//
//   Quy ước kiểu dữ liệu
//     điểm / vectơ : (x, y, z)
//     mặt phẳng    : (a: , b: , c: , d: )      ⇔  ax + by + cz + d = 0
//                    (cũng nhận dạng (n: , d: ) của da-dien.typ)
//     đường thẳng  : (P: điểm đi qua, u: vectơ chỉ phương)
//     mặt cầu      : (I: tâm, R: bán kính)
//
//   Nhóm hàm `hien-*` trả về NỘI DUNG toán CHÍNH XÁC (căn thức, phân số),
//   nhóm còn lại trả số thực để tính tiếp / vẽ hình.
// =====================================================================
#import "da-dien.typ": *
#import "do-thi.typ": so-toan, so-dep, so-can-thuc

#let _e0 = 1e-9

#let _gan-int(x, eps: 1e-9) = calc.abs(x - calc.round(x)) < eps * calc.max(1, calc.abs(x))

#let _gcd2(a, b) = {
  let (a, b) = (calc.abs(int(a)), calc.abs(int(b)))
  while b != 0 { let r = calc.rem(a, b); a = b; b = r }
  a
}

// Nhân dãy hệ số với số hữu tỉ nhỏ nhất để thành NGUYÊN rồi chia ước chung;
// dấu chuẩn hoá: hệ số khác 0 đầu tiên > 0. Không nguyên hoá được -> none.
#let _rut-gon(ds) = {
  let ok = none
  for q in range(1, 61) {
    let t = ds.map(v => v * q)
    if t.all(v => _gan-int(v, eps: 1e-7)) {
      ok = t.map(v => int(calc.round(v)))
      break
    }
  }
  if ok == none { return none }
  let g = 0
  for v in ok { g = _gcd2(g, v) }
  if g == 0 { return ok }
  let r = ok.map(v => int(v / g))
  let am = false
  for v in r {
    if v != 0 { am = v < 0; break }
  }
  if am { r = r.map(v => -v) }
  r
}

// Số -> CHUỖI toán (nguyên, phân số p/q rút gọn, cùng lắm là thập phân 3 chữ số).
// Lượt mẫu LỚN (tới 5000, khớp chặt 1e-11) để tâm ngoại tiếp/trực tâm — vốn là
// phân số mẫu vài trăm — vẫn hiện CHÍNH XÁC thay vì số thập phân.
#let _ms(v) = {
  if _gan-int(v) { return str(int(calc.round(v))) }
  for q in range(2, 101) {
    let p = v * q
    if _gan-int(p) {
      let p = int(calc.round(p))
      if _gcd2(p, q) == 1 { return str(p) + "/" + str(q) }
    }
  }
  for q in range(101, 5001) {
    let p = v * q
    if _gan-int(p, eps: 1e-11) {
      let p = int(calc.round(p))
      if _gcd2(p, q) == 1 { return str(p) + "/" + str(q) }
    }
  }
  let r = calc.round(v, digits: 3)
  if calc.fract(r) == 0 { str(int(r)) } else { str(r) }
}

// Có phải chuỗi số NGUYÊN (để biết cần bọc ngoặc hay không).
#let _la-nguyen(v) = _gan-int(v)

// Vế trái "2x - 3y + z - 5" từ hệ số + tên biến ("" = hạng tử tự do).
#let _ve-trai(hs, bien) = {
  let s = ""
  for (v, b) in hs.zip(bien) {
    if calc.abs(v) < 1e-12 { continue }
    let am = v < 0
    let a = calc.abs(v)
    let t = if b == "" {
      _ms(a)
    } else if _la-nguyen(a) and calc.round(a) == 1 {
      b
    } else if _la-nguyen(a) {
      _ms(a) + b
    } else {
      "(" + _ms(a) + ")" + b
    }
    if s == "" {
      s = if am { "-" + t } else { t }
    } else {
      s = s + (if am { " - " } else { " + " }) + t
    }
  }
  if s == "" { s = "0" }
  s
}

// Bọc ngoặc khi số âm hoặc là phân số (dùng làm mẫu số, hệ số đứng riêng).
#let _ms-ngoac(v) = {
  let s = _ms(v)
  if v < 0 or not _la-nguyen(v) { "(" + s + ")" } else { s }
}

// =====================================================================
// 1. VECTƠ
//    (các phép cơ bản v3-cong, v3-tru, v3-nhan, v3-chuan… có sẵn ở da-dien.typ)
// =====================================================================

// Toạ độ vectơ AB = B - A. Gọi 1 đối số thì trả về chính vectơ đó.
#let vecto-3d(..a) = {
  let p = a.pos()
  if p.len() == 1 { p.at(0) } else { v3-tru(p.at(1), p.at(0)) }
}

#let tich-vo-huong(u, v) = v3-vo-huong(u, v)
#let tich-co-huong(u, v) = v3-co-huong(u, v)
// Tích hỗn tạp [u, v, w] = (u × v) · w  (định thức cấp ba).
#let tich-hon-tap(u, v, w) = v3-vo-huong(v3-co-huong(u, v), w)

#let do-dai-vecto(u) = v3-dai(u)

// cos của góc giữa hai vectơ (giá trị thực, đã chặn trong [-1; 1]).
#let cos-goc-vecto(u, v) = {
  let m = v3-dai(u) * v3-dai(v)
  if m < _e0 { return 0.0 }
  calc.max(-1.0, calc.min(1.0, v3-vo-huong(u, v) / m))
}
// Góc giữa hai vectơ (0° -> 180°), trả về kiểu angle.
#let goc-vecto(u, v) = calc.acos(cos-goc-vecto(u, v))

#let cung-phuong(u, v) = v3-dai(v3-co-huong(u, v)) < 1e-7 * calc.max(1, v3-dai(u) * v3-dai(v))
#let vuong-goc(u, v) = calc.abs(v3-vo-huong(u, v)) < 1e-7 * calc.max(1, v3-dai(u) * v3-dai(v))
#let dong-phang(u, v, w) = calc.abs(tich-hon-tap(u, v, w)) < 1e-7

// =====================================================================
// 2. ĐIỂM — khoảng cách, điểm đặc biệt của tam giác
//    (trung-diem-3d, chia-3d, tam-3d đã có ở da-dien.typ)
// =====================================================================
#let khoang-cach-3d(A, B) = v3-dai(v3-tru(B, A))
#let do-dai-doan-3d(A, B) = khoang-cach-3d(A, B)

#let trong-tam-3d(..P) = {
  let ds = P.pos()
  v3-nhan(1 / ds.len(), ds.fold((0.0, 0.0, 0.0), v3-cong))
}

// Tâm đường tròn NGOẠI tiếp tam giác ABC (toạ độ tâm tỉ cự).
#let tam-ngoai-tiep-3d(A, B, C) = {
  let a2 = v3-vo-huong(v3-tru(C, B), v3-tru(C, B))
  let b2 = v3-vo-huong(v3-tru(C, A), v3-tru(C, A))
  let c2 = v3-vo-huong(v3-tru(B, A), v3-tru(B, A))
  let al = a2 * (b2 + c2 - a2)
  let be = b2 * (c2 + a2 - b2)
  let ga = c2 * (a2 + b2 - c2)
  let s = al + be + ga
  if calc.abs(s) < _e0 { return trong-tam-3d(A, B, C) }
  v3-nhan(1 / s, v3-cong(v3-cong(v3-nhan(al, A), v3-nhan(be, B)), v3-nhan(ga, C)))
}

// Trực tâm — hệ thức Euler: H = A + B + C - 2·O.
#let truc-tam-3d(A, B, C) = v3-tru(
  v3-cong(v3-cong(A, B), C),
  v3-nhan(2, tam-ngoai-tiep-3d(A, B, C)),
)

// Tâm đường tròn NỘI tiếp: I = (a·A + b·B + c·C)/(a + b + c).
#let tam-noi-tiep-3d(A, B, C) = {
  let a = khoang-cach-3d(B, C)
  let b = khoang-cach-3d(C, A)
  let c = khoang-cach-3d(A, B)
  let s = a + b + c
  if s < _e0 { return A }
  v3-nhan(1 / s, v3-cong(v3-cong(v3-nhan(a, A), v3-nhan(b, B)), v3-nhan(c, C)))
}

// Tâm đường tròn BÀNG tiếp trong góc A.
#let tam-bang-tiep-3d(A, B, C) = {
  let a = khoang-cach-3d(B, C)
  let b = khoang-cach-3d(C, A)
  let c = khoang-cach-3d(A, B)
  let s = -a + b + c
  if calc.abs(s) < _e0 { return A }
  v3-nhan(1 / s, v3-cong(v3-cong(v3-nhan(-a, A), v3-nhan(b, B)), v3-nhan(c, C)))
}

// =====================================================================
// 3. DIỆN TÍCH — THỂ TÍCH
// =====================================================================
#let dien-tich-tam-giac-3d(A, B, C) = 0.5 * v3-dai(v3-co-huong(v3-tru(B, A), v3-tru(C, A)))
#let dien-tich-hbh-3d(A, B, C) = v3-dai(v3-co-huong(v3-tru(B, A), v3-tru(C, A)))
#let the-tich-tu-dien(A, B, C, D) = calc.abs(
  tich-hon-tap(v3-tru(B, A), v3-tru(C, A), v3-tru(D, A)),
) / 6
#let the-tich-hinh-hop(A, B, C, D) = calc.abs(
  tich-hon-tap(v3-tru(B, A), v3-tru(C, A), v3-tru(D, A)),
)
#let bon-diem-dong-phang(A, B, C, D) = dong-phang(
  v3-tru(B, A), v3-tru(C, A), v3-tru(D, A),
)
#let ban-kinh-ngoai-tiep-3d(A, B, C) = {
  let s = dien-tich-tam-giac-3d(A, B, C)
  if s < _e0 { return 0.0 }
  (khoang-cach-3d(B, C) * khoang-cach-3d(C, A) * khoang-cach-3d(A, B)) / (4 * s)
}
#let ban-kinh-noi-tiep-3d(A, B, C) = {
  let p = (khoang-cach-3d(B, C) + khoang-cach-3d(C, A) + khoang-cach-3d(A, B)) / 2
  if p < _e0 { return 0.0 }
  dien-tich-tam-giac-3d(A, B, C) / p
}

// =====================================================================
// 4. MẶT PHẲNG  ax + by + cz + d = 0
// =====================================================================

// Nhận cả dạng (a,b,c,d) lẫn dạng (n: đơn vị, d:) của da-dien.typ.
#let _hs-mp(m) = {
  if "a" in m { (m.a, m.b, m.c, m.d) } else { (m.n.at(0), m.n.at(1), m.n.at(2), -m.d) }
}
#let phap-tuyen-mp(m) = {
  let h = _hs-mp(m)
  (h.at(0), h.at(1), h.at(2))
}
// Đổi sang dạng (n: , d: ) để VẼ bằng mat-phang-bh / hinh-chieu-mp của da-dien.
#let mp-de-ve(m) = {
  let h = _hs-mp(m)
  let n = v3-chuan((h.at(0), h.at(1), h.at(2)))
  let l = v3-dai((h.at(0), h.at(1), h.at(2)))
  (n: n, d: if l < _e0 { 0.0 } else { -h.at(3) / l })
}

#let mat-phang-qua-phap(A, n) = {
  let h = _rut-gon((n.at(0), n.at(1), n.at(2), -v3-vo-huong(n, A)))
  let h = if h == none { (n.at(0), n.at(1), n.at(2), -v3-vo-huong(n, A)) } else { h }
  (a: h.at(0), b: h.at(1), c: h.at(2), d: h.at(3))
}
#let mat-phang-qua-3-diem(A, B, C) = mat-phang-qua-phap(
  A, v3-co-huong(v3-tru(B, A), v3-tru(C, A)),
)
// Mặt phẳng đoạn chắn: x/p + y/q + z/r = 1.
#let mat-phang-doan-chan(p, q, r) = mat-phang-qua-3-diem((p, 0, 0), (0, q, 0), (0, 0, r))
#let mat-phang-song-song(m, A) = mat-phang-qua-phap(A, phap-tuyen-mp(m))
#let mat-phang-trung-truc(A, B) = mat-phang-qua-phap(trung-diem-3d(A, B), v3-tru(B, A))
// Mặt phẳng qua A và vuông góc đường thẳng d.
#let mat-phang-vuong-goc-duong(A, d) = mat-phang-qua-phap(A, d.u)
// Mặt phẳng qua A, chứa hai phương u, v.
#let mat-phang-qua-2-phuong(A, u, v) = mat-phang-qua-phap(A, v3-co-huong(u, v))

// Thay toạ độ điểm vào vế trái: ax + by + cz + d.
#let the-vao-mp(A, m) = {
  let h = _hs-mp(m)
  h.at(0) * A.at(0) + h.at(1) * A.at(1) + h.at(2) * A.at(2) + h.at(3)
}
#let khoang-cach-diem-mp(A, m) = {
  let n = phap-tuyen-mp(m)
  let l = v3-dai(n)
  if l < _e0 { return 0.0 }
  calc.abs(the-vao-mp(A, m)) / l
}
#let hinh-chieu-len-mp(A, m) = {
  let n = phap-tuyen-mp(m)
  let l2 = v3-vo-huong(n, n)
  if l2 < _e0 { return A }
  v3-tru(A, v3-nhan(the-vao-mp(A, m) / l2, n))
}
#let doi-xung-qua-mp(A, m) = {
  let n = phap-tuyen-mp(m)
  let l2 = v3-vo-huong(n, n)
  if l2 < _e0 { return A }
  v3-tru(A, v3-nhan(2 * the-vao-mp(A, m) / l2, n))
}
// Khung tứ giác biểu diễn mặt phẳng để VẼ bằng mat-phang-bh của da-dien.typ:
//   let (T, u, v) = khung-mp(P, tam: A, r: 2.2)
//   mat-phang-bh(ctx, t3, T, u, v)
#let khung-mp(m, tam: auto, r: 2) = {
  let n = v3-chuan(phap-tuyen-mp(m))
  let T = hinh-chieu-len-mp(if tam == auto { (0, 0, 0) } else { tam }, m)
  let t = if calc.abs(n.at(2)) < 0.9 { (0, 0, 1) } else { (1, 0, 0) }
  let u = v3-nhan(r, v3-chuan(v3-co-huong(n, t)))
  let v = v3-nhan(r, v3-chuan(v3-co-huong(n, u)))
  (T, u, v)
}

#let goc-2-mp(m1, m2) = calc.acos(
  calc.min(1.0, calc.abs(cos-goc-vecto(phap-tuyen-mp(m1), phap-tuyen-mp(m2)))),
)
#let vi-tri-2-mp(m1, m2) = {
  let (n1, n2) = (phap-tuyen-mp(m1), phap-tuyen-mp(m2))
  if not cung-phuong(n1, n2) { return "cắt nhau" }
  let (h1, h2) = (_hs-mp(m1), _hs-mp(m2))
  let k = 0.0
  for i in range(3) {
    if calc.abs(h2.at(i)) > _e0 { k = h1.at(i) / h2.at(i) }
  }
  if calc.abs(h1.at(3) - k * h2.at(3)) < 1e-7 { "trùng nhau" } else { "song song" }
}

// Phương trình mặt phẳng: nội dung  $2x - 3y + z - 5 = 0$
#let pt-mat-phang(m, an: ("x", "y", "z")) = {
  let h = _hs-mp(m)
  let r = _rut-gon(h)
  let h = if r == none { h } else { r }
  eval(_ve-trai(h, (an.at(0), an.at(1), an.at(2), "")) + " = 0", mode: "math")
}

// =====================================================================
// 5. ĐƯỜNG THẲNG  (P: điểm, u: vectơ chỉ phương)
// =====================================================================
// Vectơ chỉ phương "đẹp": nhân lên thành nguyên, chia ước chung, thành phần
// khác 0 đầu tiên dương. Không nguyên hoá được thì giữ nguyên.
#let vtcp-dep(u) = {
  let r = _rut-gon(u)
  if r == none { u } else { r }
}
#let duong-thang-qua-vtcp(A, u) = (P: A, u: u)
#let duong-thang-qua-2-diem(A, B) = (P: A, u: v3-tru(B, A))
#let duong-thang-vuong-goc-mp(A, m) = (P: A, u: phap-tuyen-mp(m))

#let khoang-cach-diem-duong(A, d) = {
  let l = v3-dai(d.u)
  if l < _e0 { return khoang-cach-3d(A, d.P) }
  v3-dai(v3-co-huong(v3-tru(A, d.P), d.u)) / l
}
#let hinh-chieu-len-duong(A, d) = {
  let l2 = v3-vo-huong(d.u, d.u)
  if l2 < _e0 { return d.P }
  v3-cong(d.P, v3-nhan(v3-vo-huong(v3-tru(A, d.P), d.u) / l2, d.u))
}
#let doi-xung-qua-duong(A, d) = v3-tru(v3-nhan(2, hinh-chieu-len-duong(A, d)), A)
#let goc-2-duong(d1, d2) = calc.acos(calc.min(1.0, calc.abs(cos-goc-vecto(d1.u, d2.u))))
#let goc-duong-mp(d, m) = calc.asin(
  calc.min(1.0, calc.abs(cos-goc-vecto(d.u, phap-tuyen-mp(m)))),
)

#let vi-tri-2-duong(d1, d2) = {
  let w = v3-tru(d2.P, d1.P)
  if cung-phuong(d1.u, d2.u) {
    if v3-dai(v3-co-huong(w, d1.u)) < 1e-7 { "trùng nhau" } else { "song song" }
  } else if calc.abs(tich-hon-tap(d1.u, d2.u, w)) < 1e-7 { "cắt nhau" } else { "chéo nhau" }
}
#let khoang-cach-2-duong(d1, d2) = {
  let n = v3-co-huong(d1.u, d2.u)
  if v3-dai(n) < 1e-7 { return khoang-cach-diem-duong(d2.P, d1) }
  calc.abs(v3-vo-huong(n, v3-tru(d2.P, d1.P))) / v3-dai(n)
}
// Giao điểm đường thẳng với mặt phẳng — song song / nằm trong thì trả none.
#let giao-duong-mp(d, m) = {
  let n = phap-tuyen-mp(m)
  let t0 = v3-vo-huong(n, d.u)
  if calc.abs(t0) < 1e-9 { return none }
  v3-cong(d.P, v3-nhan(-the-vao-mp(d.P, m) / t0, d.u))
}
// Giao điểm hai đường thẳng (chéo nhau / song song -> none).
#let giao-2-duong(d1, d2) = {
  if vi-tri-2-duong(d1, d2) != "cắt nhau" { return none }
  let w = v3-tru(d2.P, d1.P)
  let n = v3-co-huong(d1.u, d2.u)
  let t = v3-vo-huong(v3-co-huong(w, d2.u), n) / v3-vo-huong(n, n)
  v3-cong(d1.P, v3-nhan(t, d1.u))
}
// Giao tuyến hai mặt phẳng (song song / trùng -> none).
#let giao-2-mp(m1, m2) = {
  let (n1, n2) = (phap-tuyen-mp(m1), phap-tuyen-mp(m2))
  let u = v3-co-huong(n1, n2)
  if v3-dai(u) < 1e-7 { return none }
  let (h1, h2) = (_hs-mp(m1), _hs-mp(m2))
  let (k1, k2) = (-h1.at(3), -h2.at(3))
  let (a11, a12) = (v3-vo-huong(n1, n1), v3-vo-huong(n1, n2))
  let a22 = v3-vo-huong(n2, n2)
  let de = a11 * a22 - a12 * a12
  let al = (k1 * a22 - k2 * a12) / de
  let be = (k2 * a11 - k1 * a12) / de
  (P: v3-cong(v3-nhan(al, n1), v3-nhan(be, n2)), u: vtcp-dep(u))
}

// Phương trình THAM SỐ:  cases(x = ..., y = ..., z = ...)
#let pt-tham-so(d, t: "t", an: ("x", "y", "z")) = {
  let dong = range(3).map(i => (
    an.at(i) + " = " + _ve-trai((d.P.at(i), d.u.at(i)), ("", t))
  ))
  eval("cases(" + dong.join(", ") + ")", mode: "math")
}
// Phương trình CHÍNH TẮC (thành phần chỉ phương bằng 0 thì tách ra sau dấu phẩy).
#let pt-chinh-tac(d, an: ("x", "y", "z")) = {
  let ph = ()
  let le = ()
  for i in range(3) {
    if calc.abs(d.u.at(i)) < _e0 {
      le.push(an.at(i) + " = " + _ms(d.P.at(i)))
    } else {
      ph.push(
        "(" + _ve-trai((1, -d.P.at(i)), (an.at(i), "")) + ")/" + _ms-ngoac(d.u.at(i)),
      )
    }
  }
  let s = if ph.len() >= 2 { (ph.join(" = "),) + le } else { ph + le }
  eval(s.join(", "), mode: "math")
}

// =====================================================================
// 6. MẶT CẦU  (I: tâm, R: bán kính)
// =====================================================================
#let mat-cau(I, R) = (I: I, R: calc.abs(R))
#let mat-cau-duong-kinh(A, B) = (I: trung-diem-3d(A, B), R: khoang-cach-3d(A, B) / 2)
#let mat-cau-tam-tiep-xuc-mp(I, m) = (I: I, R: khoang-cach-diem-mp(I, m))
// Mặt cầu qua 4 điểm không đồng phẳng (đồng phẳng -> none).
#let mat-cau-qua-4-diem(A, B, C, D) = {
  let q = P => v3-vo-huong(P, P)
  let ha = (v3-tru(B, A), v3-tru(C, A), v3-tru(D, A))
  let ve = ((q(B) - q(A)) / 2, (q(C) - q(A)) / 2, (q(D) - q(A)) / 2)
  let de = tich-hon-tap(ha.at(0), ha.at(1), ha.at(2))
  if calc.abs(de) < 1e-9 { return none }
  let _cot-j(j) = {
    let m = ha.map(r => r)
    let k = range(3).map(i => {
      let r = m.at(i)
      range(3).map(t => if t == j { ve.at(i) } else { r.at(t) })
    })
    tich-hon-tap(k.at(0), k.at(1), k.at(2))
  }
  let I = (_cot-j(0) / de, _cot-j(1) / de, _cot-j(2) / de)
  (I: I, R: khoang-cach-3d(I, A))
}
#let vi-tri-mp-mat-cau(m, S) = {
  let k = khoang-cach-diem-mp(S.I, m)
  if k > S.R + 1e-7 { "không cắt" } else if k > S.R - 1e-7 { "tiếp xúc" } else { "cắt nhau" }
}
// Đường tròn giao tuyến của mặt phẳng và mặt cầu -> (I: tâm, R: bán kính).
#let duong-tron-giao(m, S) = {
  let k = khoang-cach-diem-mp(S.I, m)
  if k > S.R + 1e-9 { return none }
  (I: hinh-chieu-len-mp(S.I, m), R: calc.sqrt(calc.max(0.0, S.R * S.R - k * k)))
}

// Phương trình mặt cầu dạng CHÍNH TẮC: (x - a)^2 + (y - b)^2 + (z - c)^2 = R^2
#let pt-mat-cau(S, an: ("x", "y", "z")) = {
  let ve = range(3).map(i => {
    let t = _ve-trai((1, -S.I.at(i)), (an.at(i), ""))
    if t.contains(" ") { "(" + t + ")^2" } else { t + "^2" }
  })
  let r2 = S.R * S.R
  eval(ve.join(" + ") + " = " + _ms(r2), mode: "math")
}
// Phương trình mặt cầu dạng KHAI TRIỂN: x^2+y^2+z^2 - 2ax - 2by - 2cz + d = 0
#let pt-mat-cau-khai-trien(S, an: ("x", "y", "z")) = {
  let d0 = v3-vo-huong(S.I, S.I) - S.R * S.R
  let dau = _ve-trai(
    (-2 * S.I.at(0), -2 * S.I.at(1), -2 * S.I.at(2), d0),
    (an.at(0), an.at(1), an.at(2), ""),
  )
  let dau = if dau == "0" { "" } else if dau.starts-with("-") {
    " - " + dau.slice(1)
  } else { " + " + dau }
  eval(
    an.at(0) + "^2 + " + an.at(1) + "^2 + " + an.at(2) + "^2" + dau + " = 0",
    mode: "math",
  )
}

// =====================================================================
// 7. HIỂN THỊ — nội dung toán CHÍNH XÁC (căn thức, phân số)
// =====================================================================
// Số CHÍNH XÁC nếu là nguyên / phân số (mẫu tới 5000), ngược lại là thập phân
// 3 chữ số. KHÔNG "đoán" căn thức như so-toan (dễ ra dạng đẹp mà SAI với số vô
// tỉ); cần căn thức chính xác thì dùng hien-can / hien-do-dai / hien-dien-tich-*.
#let hien-so(v) = eval(_ms(v), mode: "math")
// Giá trị gần đúng (mặc định 2 chữ số thập phân).
#let hien-gan-dung(v, chu-so: 2) = {
  let r = calc.round(v, digits: chu-so)
  eval(if calc.fract(r) == 0 { str(int(r)) } else { str(r) }, mode: "math")
}
// Căn bậc hai CHÍNH XÁC của số nguyên n (tự rút thừa số chính phương).
#let hien-can(n) = so-can-thuc(0, 1, n, 1)
// Tên điểm/vectơ: chuỗi "AB" -> $A B$ (math của Typst coi chuỗi nhiều chữ cái
// là MỘT biến nên phải tách ra); truyền thẳng nội dung toán cũng được.
#let _ten-toan(t) = if type(t) == str { eval(t.clusters().join(" "), mode: "math") } else { t }
#let _bo-ba(u) = eval("(" + u.map(v => _ms(v)).join("; ") + ")", mode: "math")

// Toạ độ điểm:  A(1; 2; -3)
#let hien-diem(A, ten: none) = {
  let s = _bo-ba(A)
  if ten == none { s } else { $#_ten-toan(ten)#s$ }
}
// Toạ độ vectơ:  arrow(u) = (1; 2; -3)
#let hien-vecto(u, ten: none) = {
  let s = _bo-ba(u)
  if ten == none { s } else { $arrow(#_ten-toan(ten)) = #s$ }
}
#let hien-goc(g, chu-so: 1) = {
  let d = g.deg()
  let s = if _gan-int(d, eps: 1e-6) {
    str(int(calc.round(d)))
  } else { so-dep(calc.round(d, digits: chu-so)) }
  eval(s + " degree", mode: "math")
}
// Độ dài vectơ / khoảng cách hai điểm — dạng căn thức chính xác.
#let hien-do-dai(u) = so-can-thuc(0, 1, v3-vo-huong(u, u), 1)
#let hien-khoang-cach(A, B) = hien-do-dai(v3-tru(B, A))
// cos góc giữa hai vectơ — chính xác:  (u·v)/(|u||v|) = t√(N)/N
#let hien-cos-goc(u, v) = {
  let t = v3-vo-huong(u, v)
  let n = v3-vo-huong(u, u) * v3-vo-huong(v, v)
  if n < _e0 { return $0$ }
  so-can-thuc(0, t, n, n)
}
#let hien-khoang-cach-diem-mp(A, m) = {
  let h = _hs-mp(m)
  let r = _rut-gon(h)
  let h = if r == none { h } else { r }
  let n = h.at(0) * h.at(0) + h.at(1) * h.at(1) + h.at(2) * h.at(2)
  if n < _e0 { return $0$ }
  let t = calc.abs(h.at(0) * A.at(0) + h.at(1) * A.at(1) + h.at(2) * A.at(2) + h.at(3))
  so-can-thuc(0, t, n, n)
}
#let hien-khoang-cach-diem-duong(A, d) = {
  let n2 = v3-vo-huong(d.u, d.u)
  if n2 < _e0 { return hien-khoang-cach(A, d.P) }
  let c = v3-co-huong(v3-tru(A, d.P), d.u)
  so-can-thuc(0, 1, v3-vo-huong(c, c) * n2, n2)
}
#let hien-khoang-cach-2-duong(d1, d2) = {
  let n = v3-co-huong(d1.u, d2.u)
  let n2 = v3-vo-huong(n, n)
  if n2 < 1e-12 { return hien-khoang-cach-diem-duong(d2.P, d1) }
  let t = v3-vo-huong(n, v3-tru(d2.P, d1.P))
  so-can-thuc(0, 1, t * t / n2, 1)
}
// Diện tích hình bình hành dựng trên hai vectơ = √M (chính xác).
#let hien-dien-tich-hbh(A, B, C) = {
  let c = v3-co-huong(v3-tru(B, A), v3-tru(C, A))
  so-can-thuc(0, 1, v3-vo-huong(c, c), 1)
}
// Diện tích tam giác = √M/2 (chính xác).
#let hien-dien-tich-tam-giac(A, B, C) = {
  let c = v3-co-huong(v3-tru(B, A), v3-tru(C, A))
  so-can-thuc(0, 1, v3-vo-huong(c, c), 2)
}
#let hien-the-tich-tu-dien(A, B, C, D) = so-toan(the-tich-tu-dien(A, B, C, D))
