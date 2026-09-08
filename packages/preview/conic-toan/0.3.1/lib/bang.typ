// =====================================================================
// bang.typ — BẢNG BIẾN THIÊN & BẢNG XÉT DẤU
//
// #bbt(
//   x:       (n mốc, vd ($-oo$, $1$, $+oo$)),
//   dau:     2n-1 phần tử xen kẽ [tại x0, khoảng, tại x1, ...]
//            dùng chuỗi "+", "-", "0", "||", "" hoặc nội dung tuỳ ý
//            (none => ẩn dòng f'),
//   gia-tri: n giá trị của f tại các mốc; tại điểm gián đoạn dùng cặp
//            ($-oo$, $+oo$) — giá trị 2 bên kẹp,
//   huong:   n-1 chiều mũi tên: "len" | "xuong" | "ngang";
//            NỬA Ô (07/2026, để 2 mũi tên cùng chiều nằm TRÊN 1 ĐƯỜNG qua
//            giá trị đặt GIỮA ô): "len-duoi" (đáy→giữa) + "len-tren"
//            (giữa→đỉnh); "xuong-tren" (đỉnh→giữa) + "xuong-duoi" (giữa→đáy).
//            Giá trị tại mốc kề đầu mút "giữa" tự đặt chính giữa ô,
//   kep:     chỉ số các mốc có kẹp ‖ (tiệm cận đứng), vd (1,),
//   gach:    chỉ số các KHOẢNG hàm KHÔNG XÁC ĐỊNH -> gạch chéo, vd (1,)
//            (khoảng k nằm giữa mốc k và k+1; huong tại khoảng đó ghi "ngang";
//            dau tại mốc kề bên ghi "||" -> kẹp ‖ vẽ CAO KÍN dòng dấu ngay
//            giữa cột mốc, dải gạch phủ lấn tới tận kẹp),
// )
//
// #bang-xet-dau(x: (...), dong: ((ten, mang-dau-2n-1), ...), gach: (...))
// =====================================================================
#import "ve.typ": doan-pt, da-giac-pt
#import "do-thi.typ": so-toan, so-can-thuc, cuc-tri-bac-ba, cuc-tri-huu-ti

// Cặp vạch đứng ‖ cao `cao`.
#let kep-vach(cao, day: 0.7pt) = stack(
  dir: ltr, spacing: 1.9pt,
  line(angle: 90deg, length: cao, stroke: day),
  line(angle: 90deg, length: cao, stroke: day),
)

// Khối gạch chéo 45° (miền không xác định) — phần tử KHỐI, kích thước
// tuyệt đối nên đặt trong ô/grid là khít, không dính metric dòng chữ.
#let o-gach(rong, cao, buoc: 5.5pt, day: 0.5pt, mau: luma(45%)) = block(
  width: rong, height: cao, clip: true,
  {
    let w = rong.pt()
    let h = cao.pt()
    let t = -h
    while t < w {
      doan-pt((t, h), (t + h, 0), mau: mau, day: day)
      t = t + buoc.pt()
    }
  },
)

// Đổi ký hiệu dấu -> nội dung.
#let ky-hieu-dau(s) = {
  if type(s) == str {
    if s == "+" { $+$ } else if s == "-" { $-$ } else if s == "0" { $0$ }
    else if s == "||" { kep-vach(1.1em) } else if s == "" { none } else { s }
  } else { s }
}

// Mũi tên biến thiên trong ô (rong × cao).
#let mui-ten-bbt(rong, cao, huong: "len", mau: black, day: 1pt) = box(
  width: rong, height: cao,
  {
    let w = rong.pt()
    let h = cao.pt()
    // (y đầu, y cuối) theo toạ độ trang (y hướng xuống); các hướng "-duoi"/
    // "-tren" là mũi tên NỬA Ô: đầu mút tại h/2 khớp giá trị đặt giữa ô,
    // để 2 mũi tên cùng chiều ở 2 khoảng kề nhau nằm trên 1 đường thẳng.
    let dau-cuoi = (
      "len":        (h - 1.5, 1.5),
      "len-duoi":   (h - 1.5, h / 2),
      "len-tren":   (h / 2, 1.5),
      "xuong":      (1.5, h - 1.5),
      "xuong-tren": (1.5, h / 2),
      "xuong-duoi": (h / 2, h - 1.5),
      "ngang":      (h / 2, h / 2),
    ).at(huong)
    let (p, q) = ((1.5, dau-cuoi.at(0)), (w - 1.5, dau-cuoi.at(1)))
    doan-pt(p, q, mau: mau, day: day)
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    let l = calc.sqrt(dx * dx + dy * dy)
    let ux = dx / l
    let uy = dy / l
    let px = -uy
    let py = ux
    let k = 6.5
    da-giac-pt(
      (
        q,
        (q.at(0) - k * ux + 0.38 * k * px, q.at(1) - k * uy + 0.38 * k * py),
        (q.at(0) - 0.72 * k * ux, q.at(1) - 0.72 * k * uy),
        (q.at(0) - k * ux - 0.38 * k * px, q.at(1) - k * uy - 0.38 * k * py),
      ),
      to: mau,
    )
  },
)

// Ô giá trị: `vi` là bool (true = đỉnh, false = đáy — form cũ) hoặc
// alignment dọc (top/horizon/bottom).
#let o-gia-tri(v, vi, cao) = {
  let doc = if type(vi) == bool { if vi { top } else { bottom } } else { vi }
  box(height: cao, align(doc + center, v))
}

// Ô có kẹp ‖: giá trị trái + kẹp + giá trị phải.
#let o-kep(trai, phai, tren-trai, tren-phai, cao) = grid(
  columns: 3,
  column-gutter: 2.6pt,
  rows: cao,
  o-gia-tri(trai, tren-trai, cao),
  align(horizon, kep-vach(cao)),
  o-gia-tri(phai, tren-phai, cao),
)

// ---------- BẢNG BIẾN THIÊN ----------
#let bbt(
  x: (),
  dau: none,
  gia-tri: (),
  huong: (),
  kep: (),
  gach: (),          // khoảng không xác định -> gạch chéo
  ten-x: $x$,
  ten-fp: $f'(x)$,
  ten-f: $f(x)$,
  rong-cot: 2.5cm,   // bề rộng mỗi khoảng
  rong-so-gach: 0.9cm, // bề rộng cột MỐC kề vùng gạch (nhỏ -> số sát mũi tên)
  cao-bt: 2.3cm,     // chiều cao dòng biến thiên
  mau-mui-ten: blue.darken(20%),
  co-chu: 11pt,
) = {
  let n = x.len()
  let m = 2 * n - 1
  let inset = 5pt
  let cao-o = cao-bt - 2 * inset
  let co-dau = dau != none
  // dòng dấu cao CỐ ĐỊNH để kẹp ‖ và dải gạch phủ kín từ mép trên tới mép dưới
  let cao-hang-dau = co-chu * 1.3 + 2 * inset
  // ô gạch kín (tự đo đúng kích thước ô qua layout)
  let o-gach-kin = table.cell(inset: 0pt, layout(sz => o-gach(sz.width, sz.height)))
  // dải gạch phủ nửa ô mốc, cao `cao`
  let nua-gach(cao) = layout(sz => o-gach(sz.width, cao))
  // các cột: nhãn + xen kẽ (mốc, khoảng)
  // mốc kề vùng gạch -> bề rộng cố định nhỏ để nửa ô hẹp (số gần mũi tên)
  let cols = (auto,) + range(m).map(j => {
    if calc.odd(j) { rong-cot }
    else {
      let i = int(j / 2)
      if ((i - 1) in gach) or (i in gach) { rong-so-gach } else { auto }
    }
  })

  // ----- dòng x -----
  let hang-x = (align(horizon + center, ten-x),)
  for j in range(m) {
    hang-x.push(
      if calc.even(j) { align(horizon + center, x.at(int(j / 2))) } else { none }
    )
  }

  // ----- dòng dấu f' -----
  let hang-dau = ()
  if co-dau {
    hang-dau.push(align(horizon + center, ten-fp))
    for j in range(m) {
      if calc.odd(j) {
        // khoảng: gạch kín ô hoặc ký hiệu dấu
        hang-dau.push(
          if int((j - 1) / 2) in gach { o-gach-kin }
          else { align(horizon + center, ky-hieu-dau(dau.at(j))) }
        )
      } else {
        // mốc: nếu kề vùng gạch thì kẹp ‖ cao kín dòng đặt GIỮA cột
        // (thẳng hàng với số ở dòng x), gạch phủ nửa ô phía vùng gạch
        let i = int(j / 2)
        let trai = (i - 1) in gach
        let phai = i in gach
        hang-dau.push(
          if trai or phai {
            let giua = if dau.at(j) == "||" { kep-vach(cao-hang-dau) } else {
              block(height: 100%, inset: (x: 2.5pt), align(horizon + center, ky-hieu-dau(dau.at(j))))
            }
            table.cell(inset: 0pt, grid(
              columns: (1fr, auto, 1fr),
              rows: cao-hang-dau,
              if trai { nua-gach(cao-hang-dau) } else { none },
              giua,
              if phai { nua-gach(cao-hang-dau) } else { none },
            ))
          } else { align(horizon + center, ky-hieu-dau(dau.at(j))) }
        )
      }
    }
  }

  // ----- dòng biến thiên -----
  // vị trí dọc của giá trị tại mốc i: theo ĐẦU MÚT mũi tên chạm vào mốc
  // (mũi tên kết thúc/bắt đầu ở giữa ô -> giá trị đặt chính giữa "horizon").
  // Đầu mút mũi tên bên PHẢI mốc (nơi mũi tên huong.at(i) XUẤT PHÁT):
  let mut-phai = (
    "len": bottom, "len-duoi": bottom, "len-tren": horizon,
    "xuong": top, "xuong-tren": top, "xuong-duoi": horizon,
  )
  // Đầu mút mũi tên bên TRÁI mốc (nơi mũi tên huong.at(i-1) KẾT THÚC):
  let mut-trai = (
    "len": top, "len-tren": top, "len-duoi": horizon,
    "xuong": bottom, "xuong-duoi": bottom, "xuong-tren": horizon,
  )
  // Số bám theo mũi tên KHÔNG "ngang" (nét bằng/vùng gạch không định chiều):
  // ưu tiên mũi tên trái, nếu trái là "ngang" thì theo mũi tên phải (và ngược
  // lại) — nhờ vậy mốc kề vùng gạch, số đặt đúng đầu mút mũi tên thật.
  let vi-tri-tai(i) = {
    let ben-trai = if i > 0 { huong.at(i - 1) } else { none }
    let ben-phai = if i < n - 1 { huong.at(i) } else { none }
    if ben-trai != none and ben-trai != "ngang" {
      mut-trai.at(ben-trai, default: bottom)
    } else if ben-phai != none and ben-phai != "ngang" {
      mut-phai.at(ben-phai, default: bottom)
    } else { horizon }
  }
  let hang-f = (align(horizon + center, ten-f),)
  for j in range(m) {
    if calc.even(j) {
      let i = int(j / 2)
      let v = gia-tri.at(i)
      let trai = (i - 1) in gach
      let phai = i in gach
      if i in kep {
        let (tr, ph) = if type(v) == array { (v.at(0), v.at(1)) } else { (v, v) }
        hang-f.push(o-kep(
          tr, ph,
          if i > 0 { huong.at(i - 1) == "len" } else { false },
          if i < n - 1 { huong.at(i) == "xuong" } else { false },
          cao-o,
        ))
      } else if trai or phai {
        // mốc kề vùng gạch: gạch phủ nửa ô tới đúng tim cột (thẳng với ‖ ở trên),
        // giá trị dạt SÁT về phía mép gạch (trai -> căn trái, phai -> căn phải)
        let doc = vi-tri-tai(i)
        let ngang = if trai and phai { center } else if trai { left } else { right }
        // inset nhỏ ở phía mép gạch, nhỏ luôn phía mũi tên để số gần cả hai
        let inset-x = if trai and phai { (x: 1pt) }
          else if trai { (left: 2pt, right: 1pt) }
          else { (left: 1pt, right: 2pt) }
        let o-gia = block(width: 100%, height: 100%, inset: (..inset-x, y: inset), align(doc + ngang, v))
        hang-f.push(table.cell(inset: 0pt,
          if trai and phai {
            grid(columns: (1fr, auto, 1fr), rows: cao-bt,
              nua-gach(cao-bt), o-gia, nua-gach(cao-bt))
          } else if trai {
            grid(columns: (1fr, 1fr), rows: cao-bt, nua-gach(cao-bt), o-gia)
          } else {
            grid(columns: (1fr, 1fr), rows: cao-bt, o-gia, nua-gach(cao-bt))
          }
        ))
      } else {
        hang-f.push(o-gia-tri(v, vi-tri-tai(i), cao-o))
      }
    } else {
      let k = int((j - 1) / 2)
      // khoảng kề vùng gạch: đẩy mũi tên SÁT về phía mép gạch
      let ngang-mt = if (k + 1) in gach { right }
        else if (k - 1) in gach { left }
        else { center }
      hang-f.push(
        if k in gach { o-gach-kin }
        else {
          align(horizon + ngang-mt, mui-ten-bbt(
            rong-cot - 2 * inset - 6pt, cao-o - 4pt,
            huong: huong.at(k), mau: mau-mui-ten,
          ))
        }
      )
    }
  }

  let so-hang = if co-dau { 3 } else { 2 }
  set text(size: co-chu)
  table(
    columns: cols,
    rows: if co-dau { (auto, cao-hang-dau, cao-bt) } else { (auto, cao-bt) },
    inset: inset,
    align: center + horizon,
    stroke: (x, y) => (
      left: if x <= 1 { 0.7pt } else { none },
      right: if x == m { 0.7pt } else { none },
      top: 0.7pt,
      bottom: if y == so-hang - 1 { 0.7pt } else { none },
    ),
    ..hang-x,
    ..hang-dau,
    ..hang-f,
  )
}

// ---------- BẢNG XÉT DẤU ----------
// dong: mảng các cặp (ten, mang-dau) — mỗi mảng dấu dài 2n-1.
#let bang-xet-dau(
  x: (),
  dong: (),
  gach: (),          // khoảng không xác định -> gạch chéo
  ten-x: $x$,
  rong-cot: 2.2cm,
  co-chu: 11pt,
) = {
  let n = x.len()
  let m = 2 * n - 1
  let cols = (auto,) + range(m).map(j => if calc.odd(j) { rong-cot } else { auto })
  // hàng cao cố định để kẹp ‖ và dải gạch phủ kín
  let cao-hang = co-chu * 1.3 + 14pt
  let o-gach-kin = table.cell(inset: 0pt, layout(sz => o-gach(sz.width, sz.height)))
  let nua-gach = layout(sz => o-gach(sz.width, cao-hang))

  let cells = (align(horizon + center, ten-x),)
  for j in range(m) {
    cells.push(if calc.even(j) { align(horizon + center, x.at(int(j / 2))) } else { none })
  }
  for (ten, mang) in dong {
    cells.push(align(horizon + center, ten))
    for j in range(m) {
      if calc.odd(j) {
        cells.push(
          if int((j - 1) / 2) in gach { o-gach-kin }
          else { align(horizon + center, ky-hieu-dau(mang.at(j))) }
        )
      } else {
        let i = int(j / 2)
        let trai = (i - 1) in gach
        let phai = i in gach
        cells.push(
          if trai or phai {
            let giua = if mang.at(j) == "||" { kep-vach(cao-hang) } else {
              block(height: 100%, inset: (x: 2.5pt), align(horizon + center, ky-hieu-dau(mang.at(j))))
            }
            table.cell(inset: 0pt, grid(
              columns: (1fr, auto, 1fr),
              rows: cao-hang,
              if trai { nua-gach } else { none },
              giua,
              if phai { nua-gach } else { none },
            ))
          } else { align(horizon + center, ky-hieu-dau(mang.at(j))) }
        )
      }
    }
  }

  set text(size: co-chu)
  table(
    columns: cols,
    rows: cao-hang,
    inset: (x: 5pt, y: 7pt),
    align: center + horizon,
    stroke: (x, y) => (
      left: if x <= 1 { 0.7pt } else { none },
      right: if x == m { 0.7pt } else { none },
      top: 0.7pt,
      bottom: if y == dong.len() { 0.7pt } else { none },
    ),
    ..cells,
  )
}

// ---------- CÁC BẢNG DỰNG SẴN THƯỜNG GẶP ----------
//
// FORM MỚI (07/2026) — nhập HỆ SỐ (positional), thuật toán tự tìm cực trị/
// tiệm cận/chiều biến thiên, phủ MỌI trường hợp, nhãn đẹp qua `so-toan`:
//   #bbt-bac-hai(1, -2, 3)          y = x² − 2x + 3
//   #bbt-bac-ba(1, 0, -3, 1)        y = x³ − 3x + 1   (2 cực trị/y'=0 kép/đơn điệu)
//   #bbt-trung-phuong(1, -2, 0)     y = x⁴ − 2x²      (3 hoặc 1 cực trị)
//   #bbt-phan-thuc(2, -1, 1, -1)    y = (2x−1)/(x−1)  (tự xét dấu ad−bc)
//   #bbt-huu-ti(1, -1, 1, 1, -1)    y = (x²−x+1)/(x−1) (2 cực trị/đơn điệu)
// FORM CŨ (named: a:, x1:, y1:, x0:, yc:, dong-bien:, ...) vẫn chạy song song.

// eps so sánh 0 (hệ số thường là số "đẹp")
#let _eps-bbt = 0.000001

// BBT hàm bậc hai y = ax² + bx + c.
// Form mới: bbt-bac-hai(a, b, c). Form cũ: bbt-bac-hai(a: 1, xd: .., yd: ..).
#let bbt-bac-hai(..he-so, a: 1, xd: $(-b)/(2a)$, yd: $(-Delta)/(4a)$, ten-f: $y$, ten-fp: $y'$) = {
  let hs = he-so.pos()
  let (a, xd, yd) = if hs.len() == 3 {
    let (a, b, c) = hs
    assert(calc.abs(a) > _eps-bbt, message: "bbt-bac-hai: cần a ≠ 0")
    (a, so-toan(-b / (2 * a)), so-toan(c - b * b / (4 * a)))
  } else { (a, xd, yd) }
  if a > 0 {
    bbt(
      x: ($-oo$, xd, $+oo$),
      dau: ("", "-", "0", "+", ""),
      gia-tri: ($+oo$, yd, $+oo$),
      huong: ("xuong", "len"),
      ten-f: ten-f, ten-fp: ten-fp,
    )
  } else {
    bbt(
      x: ($-oo$, xd, $+oo$),
      dau: ("", "+", "0", "-", ""),
      gia-tri: ($-oo$, yd, $-oo$),
      huong: ("len", "xuong"),
      ten-f: ten-f, ten-fp: ten-fp,
    )
  }
}

// BBT hàm y = √(ax² + bx + c) — CHỈ CÓ form hệ số. Đặt g(x) = ax² + bx + c,
// Δ = b² − 4ac, đỉnh x₀ = −b/(2a), giá trị đỉnh y₀ = √((4ac − b²)/(4a)).
// Tự phân 3 trường hợp:
//   a > 0, Δ > 0 (g có 2 nghiệm): TXĐ = (−∞, x₁] ∪ [x₂, +∞); nghịch biến rồi
//       (khoảng giữa gạch chéo — ngoài TXĐ) đồng biến; giá trị 2 nghiệm = 0.
//   a > 0, Δ ≤ 0 (nghiệm kép / vô nghiệm): TXĐ = ℝ; giảm rồi tăng, cực tiểu tại
//       đỉnh. Δ < 0 → cực tiểu y₀ > 0, y' = 0 tại đỉnh; Δ = 0 → y = √a·|x − x₀|,
//       cực tiểu 0, y' KHÔNG xác định tại đỉnh (ghi ‖).
//   a < 0, Δ > 0 (g có 2 nghiệm): TXĐ = [x₁, x₂]; đồng biến rồi nghịch biến,
//       cực đại y₀ tại đỉnh, giá trị 2 nghiệm = 0. (a < 0 mà Δ ≤ 0 → TXĐ rỗng.)
#let bbt-can-bac-hai-ham-bac-hai(a, b, c, ten-f: $y$, ten-fp: $y'$) = {
  assert(calc.abs(a) > _eps-bbt, message: "bbt-can-bac-hai-ham-bac-hai: cần a ≠ 0")
  let delta = b * b - 4 * a * c
  let x-dinh = so-toan(-b / (2 * a))
  // giá trị tại đỉnh: y₀ = √((4ac − b²)/(4a)) (đúng cho cả a≷0 khi TXĐ ≠ ∅)
  let y-dinh = so-can-thuc(0, 1, (4 * a * c - b * b) / (4 * a), 1)
  if a > 0 {
    if delta > _eps-bbt {
      // 2 nghiệm: gạch khoảng giữa (ngoài TXĐ), x₁ < x₂
      let x1 = so-can-thuc(-b, -1, delta, 2 * a)
      let x2 = so-can-thuc(-b, 1, delta, 2 * a)
      bbt(
        x: ($-oo$, x1, x2, $+oo$),
        dau: ("", "-", "||", "", "||", "+", ""),
        gia-tri: ($+oo$, $0$, $0$, $+oo$),
        huong: ("xuong", "ngang", "len"),
        gach: (1,),
        ten-f: ten-f, ten-fp: ten-fp,
      )
    } else if delta < -_eps-bbt {
      // vô nghiệm: TXĐ = ℝ, cực tiểu y₀ tại đỉnh (y' = 0)
      bbt(
        x: ($-oo$, x-dinh, $+oo$),
        dau: ("", "-", "0", "+", ""),
        gia-tri: ($+oo$, y-dinh, $+oo$),
        huong: ("xuong", "len"),
        ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
      )
    } else {
      // nghiệm kép: y = √a·|x − x₀|, cực tiểu 0, y' không xác định tại đỉnh (‖)
      bbt(
        x: ($-oo$, x-dinh, $+oo$),
        dau: ("", "-", "||", "+", ""),
        gia-tri: ($+oo$, $0$, $+oo$),
        huong: ("xuong", "len"),
        ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
      )
    }
  } else {
    // a < 0: TXĐ = [x₁, x₂] chỉ khi Δ > 0
    assert(delta > _eps-bbt, message: "bbt-can-bac-hai-ham-bac-hai: a < 0 thì cần Δ > 0 (nếu không TXĐ rỗng)")
    let x1 = so-can-thuc(-b, 1, delta, 2 * a)
    let x2 = so-can-thuc(-b, -1, delta, 2 * a)
    bbt(
      x: (x1, x-dinh, x2),
      dau: ("", "+", "0", "-", ""),
      gia-tri: ($0$, y-dinh, $0$),
      huong: ("len", "xuong"),
      ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
    )
  }
}

// BBT hàm bậc ba.
// Form mới: bbt-bac-ba(a, b, c, d) — tự phân 3 trường hợp theo Δ' = b² − 3ac:
//   Δ' > 0: 2 cực trị | Δ' = 0: y' = 0 kép (vẫn đơn điệu, có mốc) | Δ' < 0: đơn điệu.
// Form cũ: bbt-bac-ba(a: 1, x1:, y1:, x2:, y2:) — luôn coi là có 2 cực trị.
#let bbt-bac-ba(
  ..he-so,
  a: 1,
  x1: $x_1$, y1: $y_(c d)$,
  x2: $x_2$, y2: $y_(c t)$,
  ten-f: $y$, ten-fp: $y'$,
) = {
  let hs = he-so.pos()
  if hs.len() == 4 {
    let (a, b, c, d) = hs
    assert(calc.abs(a) > _eps-bbt, message: "bbt-bac-ba: cần a ≠ 0")
    let f = x => ((a * x + b) * x + c) * x + d
    let delta = b * b - 3 * a * c
    if delta > _eps-bbt {
      // 2 cực trị — giá trị CHÍNH XÁC dạng căn thức (cuc-tri-bac-ba)
      let ct = cuc-tri-bac-ba(a, b, c, d)
      return bbt-bac-ba(
        a: a,
        x1: ct.x1, y1: ct.y1,
        x2: ct.x2, y2: ct.y2,
        ten-f: ten-f, ten-fp: ten-fp,
      )
    }
    if delta < -_eps-bbt {
      // y' vô nghiệm: đơn điệu, không mốc
      return if a > 0 {
        bbt(
          x: ($-oo$, $+oo$), dau: ("", "+", ""),
          gia-tri: ($-oo$, $+oo$), huong: ("len",),
          ten-f: ten-f, ten-fp: ten-fp, rong-cot: 5cm,
        )
      } else {
        bbt(
          x: ($-oo$, $+oo$), dau: ("", "-", ""),
          gia-tri: ($+oo$, $-oo$), huong: ("xuong",),
          ten-f: ten-f, ten-fp: ten-fp, rong-cot: 5cm,
        )
      }
    }
    // Δ' = 0: nghiệm kép x₀ = −b/(3a), vẫn đơn điệu nhưng ghi mốc y' = 0.
    // Hai mũi tên NỬA Ô (đáy→giữa rồi giữa→đỉnh) nằm trên CÙNG 1 đường thẳng
    // đi qua giá trị mốc đặt chính giữa ô.
    let t = -b / (3 * a)
    let y-moc = so-can-thuc(2 * b * b * b - 9 * a * b * c + 27 * a * a * d, 0, 0, 27 * a * a)
    let (dau0, huong2, dau-vc) = if a > 0 {
      ("+", ("len-duoi", "len-tren"), ($-oo$, $+oo$))
    } else {
      ("-", ("xuong-tren", "xuong-duoi"), ($+oo$, $-oo$))
    }
    return bbt(
      x: ($-oo$, so-toan(t), $+oo$),
      dau: ("", dau0, "0", dau0, ""),
      gia-tri: (dau-vc.at(0), y-moc, dau-vc.at(1)),
      huong: huong2,
      ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
    )
  }
  // ----- form cũ: 2 cực trị nhập tay -----
  if a > 0 {
    bbt(
      x: ($-oo$, x1, x2, $+oo$),
      dau: ("", "+", "0", "-", "0", "+", ""),
      gia-tri: ($-oo$, y1, y2, $+oo$),
      huong: ("len", "xuong", "len"),
      ten-f: ten-f, ten-fp: ten-fp,
    )
  } else {
    bbt(
      x: ($-oo$, x1, x2, $+oo$),
      dau: ("", "-", "0", "+", "0", "-", ""),
      gia-tri: ($+oo$, y1, y2, $-oo$),
      huong: ("xuong", "len", "xuong"),
      ten-f: ten-f, ten-fp: ten-fp,
    )
  }
}

// BBT hàm bậc ba đơn điệu (y' không đổi dấu).
#let bbt-bac-ba-don-dieu(a: 1, ten-f: $y$, ten-fp: $y'$) = {
  if a > 0 {
    bbt(
      x: ($-oo$, $+oo$),
      dau: ("", "+", ""),
      gia-tri: ($-oo$, $+oo$),
      huong: ("len",),
      ten-f: ten-f, ten-fp: ten-fp,
      rong-cot: 5cm,
    )
  } else {
    bbt(
      x: ($-oo$, $+oo$),
      dau: ("", "-", ""),
      gia-tri: ($+oo$, $-oo$),
      huong: ("xuong",),
      ten-f: ten-f, ten-fp: ten-fp,
      rong-cot: 5cm,
    )
  }
}

// BBT hàm trùng phương y = ax⁴ + bx² + c.
// Form mới: bbt-trung-phuong(a, b, c) — tự phân 2 trường hợp:
//   a·b < 0: 3 cực trị tại ±√(−b/2a) và 0 | còn lại: 1 cực trị tại 0.
// Form cũ: bbt-trung-phuong(a: 1, x0:, yc:, y0:) — luôn coi là 3 cực trị.
#let bbt-trung-phuong(
  ..he-so,
  a: 1,
  x0: $x_0$,   // = √(-b/2a)
  yc: $y_1$,   // giá trị tại ±x0
  y0: $y_0$,   // giá trị tại 0
  ten-f: $y$, ten-fp: $y'$,
) = {
  let hs = he-so.pos()
  if hs.len() == 3 {
    let (a, b, c) = hs
    assert(calc.abs(a) > _eps-bbt, message: "bbt-trung-phuong: cần a ≠ 0")
    if a * b < -_eps-bbt {
      // 3 cực trị — x0 và giá trị cực trị CHÍNH XÁC (kể cả căn thức/phân số)
      return bbt-trung-phuong(
        a: a,
        x0: so-can-thuc(0, 1, -b / (2 * a), 1),
        yc: so-can-thuc(4 * a * c - b * b, 0, 0, 4 * a),
        y0: so-toan(c),
        ten-f: ten-f, ten-fp: ten-fp,
      )
    }
    // 1 cực trị tại x = 0 (b = 0 hoặc a·b > 0)
    return if a > 0 {
      bbt(
        x: ($-oo$, $0$, $+oo$),
        dau: ("", "-", "0", "+", ""),
        gia-tri: ($+oo$, so-toan(c), $+oo$),
        huong: ("xuong", "len"),
        ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
      )
    } else {
      bbt(
        x: ($-oo$, $0$, $+oo$),
        dau: ("", "+", "0", "-", ""),
        gia-tri: ($-oo$, so-toan(c), $-oo$),
        huong: ("len", "xuong"),
        ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
      )
    }
  }
  // ----- form cũ: 3 cực trị nhập tay -----
  if a > 0 {
    bbt(
      x: ($-oo$, $-$ + x0, $0$, x0, $+oo$),
      dau: ("", "-", "0", "+", "0", "-", "0", "+", ""),
      gia-tri: ($+oo$, yc, y0, yc, $+oo$),
      huong: ("xuong", "len", "xuong", "len"),
      ten-f: ten-f, ten-fp: ten-fp,
      rong-cot: 2.1cm,
    )
  } else {
    bbt(
      x: ($-oo$, $-$ + x0, $0$, x0, $+oo$),
      dau: ("", "+", "0", "-", "0", "+", "0", "-", ""),
      gia-tri: ($-oo$, yc, y0, yc, $-oo$),
      huong: ("len", "xuong", "len", "xuong"),
      ten-f: ten-f, ten-fp: ten-fp,
      rong-cot: 2.1cm,
    )
  }
}

// BBT hàm phân thức y = (ax+b)/(cx+d).
// Form mới: bbt-phan-thuc(a, b, c, d) — tự tính x₀ = −d/c, y₀ = a/c,
// chiều biến thiên theo dấu ad − bc.
// Form cũ: bbt-phan-thuc(x0:, y0:, dong-bien:).
#let bbt-phan-thuc(
  ..he-so,
  x0: $x_0$, y0: $y_0$,
  dong-bien: true,   // y' > 0 trên từng khoảng?
  ten-f: $y$, ten-fp: $y'$,
) = {
  let hs = he-so.pos()
  let (x0, y0, dong-bien) = if hs.len() == 4 {
    let (a, b, c, d) = hs
    assert(calc.abs(c) > _eps-bbt, message: "bbt-phan-thuc: cần c ≠ 0")
    let D = a * d - b * c
    assert(calc.abs(D) > _eps-bbt, message: "bbt-phan-thuc: ad − bc = 0 (hàm hằng, không có BBT)")
    (so-toan(-d / c), so-toan(a / c), D > 0)
  } else { (x0, y0, dong-bien) }
  if dong-bien {
    bbt(
      x: ($-oo$, x0, $+oo$),
      dau: ("", "+", "||", "+", ""),
      gia-tri: (y0, ($+oo$, $-oo$), y0),
      huong: ("len", "len"),
      kep: (1,),
      ten-f: ten-f, ten-fp: ten-fp,
      rong-cot: 3.2cm,
    )
  } else {
    bbt(
      x: ($-oo$, x0, $+oo$),
      dau: ("", "-", "||", "-", ""),
      gia-tri: (y0, ($-oo$, $+oo$), y0),
      huong: ("xuong", "xuong"),
      kep: (1,),
      ten-f: ten-f, ten-fp: ten-fp,
      rong-cot: 3.2cm,
    )
  }
}

// BBT hàm hữu tỉ y = (ax² + bx + c)/(dx + e) — CHỈ CÓ form hệ số.
// Viết y = px + q + r/(dx + e) với p = a/d, q = (bd − ae)/d², r = c − qe.
// Tự phân 3 trường hợp: p·r·d > 0: 2 cực trị hai bên tiệm cận đứng |
// p·r·d < 0: đơn điệu (2 khoảng) | r = 0: suy biến (đường thẳng khuyết điểm).
#let bbt-huu-ti(a, b, c, d, e, ten-f: $y$, ten-fp: $y'$) = {
  assert(calc.abs(a) > _eps-bbt and calc.abs(d) > _eps-bbt, message: "bbt-huu-ti: cần a ≠ 0 và d ≠ 0")
  let x0 = -e / d
  let p = a / d
  let q = (b * d - a * e) / (d * d)
  let r = c - q * e
  let f = x => (a * x * x + b * x + c) / (d * x + e)
  if p * r * d > _eps-bbt {
    // 2 cực trị — hoành độ & giá trị CHÍNH XÁC dạng căn thức (cuc-tri-huu-ti)
    let ct = cuc-tri-huu-ti(a, b, c, d, e)
    return if p > 0 {
      bbt(
        x: ($-oo$, ct.x1, so-toan(x0), ct.x2, $+oo$),
        dau: ("", "+", "0", "-", "||", "-", "0", "+", ""),
        gia-tri: ($-oo$, ct.y1, ($-oo$, $+oo$), ct.y2, $+oo$),
        huong: ("len", "xuong", "xuong", "len"),
        kep: (2,),
        ten-f: ten-f, ten-fp: ten-fp, rong-cot: 2.1cm,
      )
    } else {
      bbt(
        x: ($-oo$, ct.x1, so-toan(x0), ct.x2, $+oo$),
        dau: ("", "-", "0", "+", "||", "+", "0", "-", ""),
        gia-tri: ($+oo$, ct.y1, ($+oo$, $-oo$), ct.y2, $-oo$),
        huong: ("xuong", "len", "len", "xuong"),
        kep: (2,),
        ten-f: ten-f, ten-fp: ten-fp, rong-cot: 2.1cm,
      )
    }
  }
  // đơn điệu trên từng khoảng. Giới hạn tại x₀: trái = −sign(rd)·∞,
  // phải = +sign(rd)·∞; riêng r = 0 (suy biến): 2 bên hữu hạn = px₀ + q.
  let (trai, phai) = if calc.abs(r) < _eps-bbt {
    let l = so-toan(p * x0 + q)
    (l, l)
  } else if r * d > 0 { ($-oo$, $+oo$) } else { ($+oo$, $-oo$) }
  if p > 0 {
    bbt(
      x: ($-oo$, so-toan(x0), $+oo$),
      dau: ("", "+", "||", "+", ""),
      gia-tri: ($-oo$, (trai, phai), $+oo$),
      huong: ("len", "len"),
      kep: (1,),
      ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
    )
  } else {
    bbt(
      x: ($-oo$, so-toan(x0), $+oo$),
      dau: ("", "-", "||", "-", ""),
      gia-tri: ($+oo$, (trai, phai), $-oo$),
      huong: ("xuong", "xuong"),
      kep: (1,),
      ten-f: ten-f, ten-fp: ten-fp, rong-cot: 3.2cm,
    )
  }
}

// Bảng xét dấu tam thức bậc hai có 2 nghiệm (dấu theo a).
// (form hệ số: xem các bbt-* phía trên)
#let xet-dau-tam-thuc(a: 1, x1: $x_1$, x2: $x_2$, ten: $f(x)$) = {
  let (ngoai, trong) = if a > 0 { ("+", "-") } else { ("-", "+") }
  bang-xet-dau(
    x: ($-oo$, x1, x2, $+oo$),
    dong: ((ten, ("", ngoai, "0", trong, "0", ngoai, "")),),
  )
}
// (đồng bộ mount 07/2026)
