// =====================================================================
// bieu-do-thong-ke.typ — BIỂU ĐỒ THỐNG KÊ (CT GDPT 2018)
//
//   #import "bieu-do-thong-ke.typ": *
//
// 5 biểu đồ dựng sẵn (KHÔNG nhận ctx — tự dựng khung như truc-so;
// vẽ chồng qua `them: ctx => ...` như mọi hình khác):
//   bieu-do-tan-so   : HISTOGRAM tần số ghép nhóm — cột DÍNH SÁT nhau
//                      (kèm `gap-khuc: true` vẽ chồng đường gấp khúc tần số)
//   da-giac-tan-so   : đường gấp khúc tần số (ogive) đứng riêng
//   bieu-do-cot      : biểu đồ cột RỜI cho giá trị rời rạc (số hoặc chữ)
//   bieu-do-hop      : biểu đồ hộp (box plot) — tứ phân vị Toán 10
//   bieu-do-quat     : biểu đồ quạt tròn (pie chart) — chia góc theo %
//
// 2 hàm TRẢ GIÁ TRỊ (không vẽ):
//   tu-phan-vi(du-lieu)            -> (min:, q1:, q2:, q3:, max:)  [SGK 10]
//   tu-phan-vi-ghep-nhom(moc, tan-so) -> (q1:, q2:, q3:)           [SGK 11]
//
// Dữ liệu vào KHỚP với bang-thong-ke.typ: cùng `moc:` (n+1 mốc -> n nhóm)
// và `tan-so:` — một nguồn số liệu dùng được cả bảng lẫn biểu đồ.
// =====================================================================
#import "ve.typ": *
#import "do-thi.typ": so-dep, so-toan

// Bảng màu mặc định cho biểu đồ quạt/cột.
#let _mau-bd = (
  rgb("#4e79a7"), rgb("#f28e2b"), rgb("#e15759"), rgb("#76b7b4"),
  rgb("#59a14f"), rgb("#edc949"), rgb("#b07aa1"), rgb("#9c755f"),
)

// Bước chia "đẹp" 1/2/5·10^k cho trục tung (~muc vạch).
#let _buoc-dep(vmax, muc: 5) = {
  let raw = calc.max(vmax, 1e-9) / muc
  let k = calc.floor(calc.log(raw))
  let p = calc.pow(10.0, k)
  let r = raw / p
  let m = if r <= 1 { 1 } else if r <= 2 { 2 } else if r <= 5 { 5 } else { 10 }
  m * p
}

// Trục Ox + Oy (mũi tên), nhãn tên trục.
#let _truc-bd(ctx, x0, xb, ytop, ten-x, ten-y) = {
  doan(ctx, (x0, 0), (xb, 0), day: 0.9pt)
  dau-mui-ten(ctx, (x0, 0), (xb, 0))
  doan(ctx, (x0, 0), (x0, ytop), day: 0.9pt)
  dau-mui-ten(ctx, (x0, 0), (x0, ytop))
  if ten-x != none { nhan(ctx, (xb, 0), ten-x, huong: "above-left", cach: 5pt) }
  if ten-y != none { nhan(ctx, (x0, ytop), ten-y, huong: "right", cach: 7pt) }
}

// Vạch chia + số trên trục tung (tại k·buoc) và các đường lưới ngang mờ.
#let _vach-tung(ctx, x0, xb, buoc, vmax, so: true, luoi: false) = {
  let dx = 2.6pt / ctx.sx
  let k = 1
  while k * buoc <= vmax * 1.02 + buoc * 0.0001 {
    let y = k * buoc
    if luoi { doan(ctx, (x0, y), (xb, y), mau: luma(86%), day: 0.5pt) }
    doan(ctx, (x0 - dx, y), (x0 + dx, y), day: 0.8pt)
    if so { nhan(ctx, (x0, y), [#so-dep(y)], huong: "left", cach: 5pt) }
    k += 1
  }
}

// Vạch chia + số trên trục hoành tại các hoành độ xs.
#let _vach-hoanh(ctx, xs, so: true) = {
  let dy = 2.6pt / ctx.sy
  for x in xs {
    doan(ctx, (x, -dy), (x, dy), day: 0.8pt)
    if so { nhan(ctx, (x, 0), [#so-dep(x)], huong: "below", cach: 5pt) }
  }
}

// =====================================================================
// HISTOGRAM — biểu đồ tần số ghép nhóm, cột dính sát nhau.
//   moc    : n+1 mốc SỐ (như bang-ghep-nhom) -> n cột
//   tan-so : n tần số (hoặc tần số tương đối — đổi ten-y cho khớp)
//   gap-khuc: true -> vẽ chồng đường gấp khúc tần số (nối trung điểm đỉnh cột,
//             kéo dài về 0 ở hai nhóm ảo ngoài cùng)
// =====================================================================
#let bieu-do-tan-so(
  moc: (),
  tan-so: (),
  w: 9cm, h: 5.5cm,
  mau: rgb(78, 121, 167, 160),   // màu tô cột
  vien: rgb("#2f5d8a"),          // màu viền cột
  ten-x: none,                   // nhãn trục hoành (vd [Chiều cao (cm)])
  ten-y: [Tần số],
  so-dinh: true,                 // ghi tần số trên đỉnh mỗi cột
  so-truc: true,                 // số trên 2 trục
  buoc-y: auto,                  // bước chia trục tung (auto = 1/2/5·10^k)
  luoi-ngang: false,             // lưới ngang mờ theo vạch trục tung
  gap-khuc: false,
  mau-gap-khuc: red,
  co-chu: 10pt,
  them: none,
) = {
  let n = tan-so.len()
  let m0 = moc.first()
  let mn = moc.last()
  let fmax = calc.max(..tan-so)
  let by = if buoc-y == auto { _buoc-dep(fmax) } else { buoc-y }
  let b1 = moc.at(1) - m0
  let bn = mn - moc.at(n - 1)
  let x0 = m0 - b1 * 0.55        // trục tung đặt hụt sang trái nửa nhóm
  let xb = mn + bn * 0.7
  let ytop = calc.max(fmax * 1.18, by)
  hinh(
    w: w, h: h,
    xmin: x0 - (xb - x0) * 0.02, xmax: xb,
    ymin: -ytop * 0.16, ymax: ytop * 1.06,
    co-chu: co-chu,
    ctx => {
      if luoi-ngang { _vach-tung(ctx, x0, xb, by, fmax, so: false, luoi: true) }
      // các cột dính sát nhau
      for i in range(n) {
        let (a, b, f) = (moc.at(i), moc.at(i + 1), tan-so.at(i))
        da-giac(ctx, ((a, 0), (b, 0), (b, f), (a, f)), to: mau, mau: vien, day: 0.9pt)
        if so-dinh and f > 0 {
          nhan(ctx, ((a + b) / 2, f), [#so-dep(f)], huong: "above", cach: 4pt)
        }
      }
      // đường gấp khúc tần số chồng lên (kéo về 0 ở 2 nhóm ảo ngoài cùng)
      if gap-khuc {
        let pts = ((m0 - b1 / 2, 0),)
        for i in range(n) {
          pts.push(((moc.at(i) + moc.at(i + 1)) / 2, tan-so.at(i)))
        }
        pts.push((mn + bn / 2, 0))
        duong-gap-khuc(ctx, pts, mau: mau-gap-khuc, day: 1.1pt)
        for p in pts { diem(ctx, p, mau: mau-gap-khuc, bk: 1.8pt) }
      }
      _truc-bd(ctx, x0, xb, ytop, ten-x, ten-y)
      _vach-tung(ctx, x0, xb, by, fmax, so: so-truc)
      _vach-hoanh(ctx, moc, so: so-truc)
      if them != none { them(ctx) }
    },
  )
}

// =====================================================================
// ĐƯỜNG GẤP KHÚC TẦN SỐ (ogive) đứng riêng — nối trung điểm các nhóm.
//   keo-dai: true -> nối thêm về 0 tại trung điểm 2 nhóm ảo ngoài cùng (SGK)
// =====================================================================
#let da-giac-tan-so(
  moc: (),
  tan-so: (),
  w: 9cm, h: 5.5cm,
  mau: rgb("#1d4ed8"),
  ten-x: none,
  ten-y: [Tần số],
  so-dinh: true,
  so-truc: true,
  buoc-y: auto,
  luoi-ngang: false,
  keo-dai: true,
  co-chu: 10pt,
  them: none,
) = {
  let n = tan-so.len()
  let m0 = moc.first()
  let mn = moc.last()
  let fmax = calc.max(..tan-so)
  let by = if buoc-y == auto { _buoc-dep(fmax) } else { buoc-y }
  let b1 = moc.at(1) - m0
  let bn = mn - moc.at(n - 1)
  let x0 = m0 - b1 * 0.55
  let xb = mn + bn * 0.7
  let ytop = calc.max(fmax * 1.18, by)
  hinh(
    w: w, h: h,
    xmin: x0 - (xb - x0) * 0.02, xmax: xb,
    ymin: -ytop * 0.16, ymax: ytop * 1.06,
    co-chu: co-chu,
    ctx => {
      if luoi-ngang { _vach-tung(ctx, x0, xb, by, fmax, so: false, luoi: true) }
      let giua = range(n).map(i => ((moc.at(i) + moc.at(i + 1)) / 2, tan-so.at(i)))
      let pts = if keo-dai {
        ((m0 - b1 / 2, 0),) + giua + ((mn + bn / 2, 0),)
      } else { giua }
      duong-gap-khuc(ctx, pts, mau: mau, day: 1.1pt)
      for p in pts { diem(ctx, p, mau: mau, bk: 1.9pt) }
      if so-dinh {
        for (i, p) in giua.enumerate() {
          if tan-so.at(i) > 0 { nhan(ctx, p, [#so-dep(p.at(1))], huong: "above", cach: 5pt, mau: mau) }
        }
      }
      _truc-bd(ctx, x0, xb, ytop, ten-x, ten-y)
      _vach-tung(ctx, x0, xb, by, fmax, so: so-truc)
      _vach-hoanh(ctx, moc, so: so-truc)
      if them != none { them(ctx) }
    },
  )
}

// =====================================================================
// BIỂU ĐỒ CỘT RỜI — giá trị rời rạc (số HOẶC nhãn chữ), cột cách nhau.
//   gia-tri: mảng số (đặt cột đúng hoành độ) hoặc mảng nội dung/chuỗi
//            (cột đặt đều tại 1, 2, 3, ...)
//   rong   : bề rộng cột theo tỉ lệ khoảng cách nhỏ nhất giữa 2 cột
// =====================================================================
#let bieu-do-cot(
  gia-tri: (),
  tan-so: (),
  w: 9cm, h: 5.5cm,
  mau: rgb(78, 121, 167, 160),
  vien: rgb("#2f5d8a"),
  ten-x: none,
  ten-y: [Tần số],
  rong: 0.5,
  so-dinh: true,
  so-truc: true,
  buoc-y: auto,
  luoi-ngang: false,
  co-chu: 10pt,
  them: none,
) = {
  let n = tan-so.len()
  let bang-so = gia-tri.all(v => type(v) == int or type(v) == float)
  let xs = if bang-so { gia-tri } else { range(1, n + 1) }
  // khoảng cách nhỏ nhất giữa 2 cột kề nhau
  let kc = if n >= 2 {
    calc.min(..range(n - 1).map(i => xs.at(i + 1) - xs.at(i)))
  } else { 1 }
  let nua = kc * rong / 2
  let fmax = calc.max(..tan-so)
  let by = if buoc-y == auto { _buoc-dep(fmax) } else { buoc-y }
  let x0 = xs.first() - kc * 0.8
  let xb = xs.last() + kc * 0.8
  let ytop = calc.max(fmax * 1.18, by)
  hinh(
    w: w, h: h,
    xmin: x0 - (xb - x0) * 0.02, xmax: xb,
    ymin: -ytop * 0.16, ymax: ytop * 1.06,
    co-chu: co-chu,
    ctx => {
      if luoi-ngang { _vach-tung(ctx, x0, xb, by, fmax, so: false, luoi: true) }
      for i in range(n) {
        let (x, f) = (xs.at(i), tan-so.at(i))
        da-giac(ctx, ((x - nua, 0), (x + nua, 0), (x + nua, f), (x - nua, f)),
          to: mau, mau: vien, day: 0.9pt)
        if so-dinh and f > 0 { nhan(ctx, (x, f), [#so-dep(f)], huong: "above", cach: 4pt) }
      }
      _truc-bd(ctx, x0, xb, ytop, ten-x, ten-y)
      _vach-tung(ctx, x0, xb, by, fmax, so: so-truc)
      // nhãn chân cột: số -> so-dep, chữ -> in nguyên
      let dy = 2.6pt / ctx.sy
      for (i, x) in xs.enumerate() {
        doan(ctx, (x, -dy), (x, dy), day: 0.8pt)
        if so-truc {
          let nd = if bang-so { [#so-dep(x)] } else { [#gia-tri.at(i)] }
          nhan(ctx, (x, 0), nd, huong: "below", cach: 5pt)
        }
      }
      if them != none { them(ctx) }
    },
  )
}

// =====================================================================
// TỨ PHÂN VỊ (số liệu KHÔNG ghép nhóm — SGK Toán 10):
// sắp xếp tăng; Q2 = trung vị; Q1/Q3 = trung vị nửa dưới/nửa trên
// (n lẻ thì KHÔNG kể Q2 vào hai nửa).
// =====================================================================
#let _trung-vi(d) = {
  let n = d.len()
  if calc.rem(n, 2) == 1 { d.at(int((n - 1) / 2)) }
  else { (d.at(int(n / 2) - 1) + d.at(int(n / 2))) / 2 }
}

#let tu-phan-vi(du-lieu) = {
  let d = du-lieu.sorted()
  let n = d.len()
  let nd = int(calc.floor(n / 2))
  (
    min: d.first(),
    q1: _trung-vi(d.slice(0, nd)),
    q2: _trung-vi(d),
    q3: _trung-vi(d.slice(n - nd)),
    max: d.last(),
  )
}

// Tứ phân vị của mẫu GHÉP NHÓM (SGK Toán 11): nội suy trong nhóm chứa Qk,
//   Qk = L + (k·n/4 − cf)/f · (R − L).
#let tu-phan-vi-ghep-nhom(moc, tan-so) = {
  let n = tan-so.sum()
  let q(k) = {
    let muc = k * n / 4
    let cf = 0
    for i in range(tan-so.len()) {
      let f = tan-so.at(i)
      if f > 0 and cf + f >= muc {
        return moc.at(i) + (muc - cf) / f * (moc.at(i + 1) - moc.at(i))
      }
      cf += f
    }
    moc.last()
  }
  (q1: q(1), q2: q(2), q3: q(3))
}

// =====================================================================
// BIỂU ĐỒ HỘP (box plot) — nằm ngang trên trục số, gióng đứt xuống trục.
//   du-lieu: mảng số thô (tự tính 5 số tóm tắt theo SGK 10), HOẶC
//   tom-tat: (min, q1, q2, q3, max) — mảng 5 số hay dict cùng khoá.
// =====================================================================
#let bieu-do-hop(
  du-lieu: none,
  tom-tat: none,
  w: 10cm, h: 3.9cm,
  mau: rgb(78, 121, 167, 90),
  vien: rgb("#2f5d8a"),
  ten: $x$,
  so: true,             // ghi 5 giá trị dưới trục
  co-chu: 10pt,
  them: none,
) = {
  let t = if du-lieu != none { tu-phan-vi(du-lieu) }
    else if type(tom-tat) == array {
      (min: tom-tat.at(0), q1: tom-tat.at(1), q2: tom-tat.at(2),
       q3: tom-tat.at(3), max: tom-tat.at(4))
    } else { tom-tat }
  let pad = calc.max((t.max - t.min) * 0.14, 0.5)
  let xa = t.min - pad
  let xb = t.max + pad * 1.4
  // hộp ở trên (tâm yc), trục số ở dưới (y = ytr)
  let yc = 0.42
  let nb = 0.4           // nửa chiều cao hộp
  let nr = 0.2           // nửa chiều cao vạch râu min/max
  let ytr = -0.78        // cao độ trục số
  hinh(w: w, h: h, xmin: xa, xmax: xb, ymin: -1.62, ymax: 1.05, co-chu: co-chu, ctx => {
    // gióng nét đứt 5 đặc trưng xuống trục
    for x in (t.min, t.q1, t.q2, t.q3, t.max) {
      doan(ctx, (x, yc - nb), (x, ytr), mau: luma(55%), day: 0.6pt, dut: true)
    }
    // râu + 2 vạch đầu mút
    doan(ctx, (t.min, yc), (t.q1, yc), day: 1pt)
    doan(ctx, (t.q3, yc), (t.max, yc), day: 1pt)
    doan(ctx, (t.min, yc - nr), (t.min, yc + nr), mau: vien, day: 1.2pt)
    doan(ctx, (t.max, yc - nr), (t.max, yc + nr), mau: vien, day: 1.2pt)
    // hộp Q1–Q3 + trung vị đậm
    da-giac(ctx, ((t.q1, yc - nb), (t.q3, yc - nb), (t.q3, yc + nb), (t.q1, yc + nb)),
      to: mau, mau: vien, day: 1.1pt)
    doan(ctx, (t.q2, yc - nb), (t.q2, yc + nb), mau: vien, day: 2pt)
    // trục số + vạch + 5 số
    doan(ctx, (xa, ytr), (xb, ytr), day: 0.9pt)
    dau-mui-ten(ctx, (xa, ytr), (xb, ytr))
    nhan(ctx, (xb, ytr), ten, huong: "below", cach: 6pt)
    let dv = 2.6pt / ctx.sy
    for x in (t.min, t.q1, t.q2, t.q3, t.max) {
      doan(ctx, (x, ytr - dv), (x, ytr + dv), day: 0.9pt)
      if so { nhan(ctx, (x, ytr), so-toan(x), huong: "below", cach: 6pt) }
    }
    if them != none { them(ctx) }
  })
}

// =====================================================================
// BIỂU ĐỒ QUẠT TRÒN (pie chart) — chia góc theo tỉ lệ %.
// Mỗi mục positional: (tên, số-liệu) hoặc (tên, số-liệu, màu).
// Bắt đầu từ 12 giờ, quay theo chiều kim đồng hồ (kiểu SGK).
//   phan-tram: true -> ghi % trong quạt (quạt bé thì ghi kèm tên ngoài)
// =====================================================================
#let bieu-do-quat(
  ..muc,
  w: 7.5cm,
  phan-tram: true,
  vien: white,          // màu đường phân cách các quạt
  co-chu: 10pt,
  them: none,
) = {
  let ms = muc.pos()
  let tong = ms.map(m => m.at(1)).sum()
  hinh(
    w: w, xmin: -1.8, xmax: 1.8, ymin: -1.45, ymax: 1.45, co-chu: co-chu,
    ctx => {
      let g = 90deg                       // bắt đầu 12 giờ
      for (i, m) in ms.enumerate() {
        let phan = m.at(1) / tong
        let g2 = g - phan * 360deg        // chiều kim đồng hồ
        let mq = if m.len() >= 3 { m.at(2) } else { _mau-bd.at(calc.rem(i, _mau-bd.len())) }
        let pts = ((0, 0),) + diem-cung((0, 0), 1, 1, g2, g, n: calc.max(int(phan * 72), 2))
        da-giac(ctx, pts, to: mq, mau: vien, day: 1.2pt)
        // nhãn tại tia phân giác của quạt
        let gm = g - phan * 180deg
        let (hx, hy) = (calc.cos(gm), calc.sin(gm))
        let pc = [#so-dep(calc.round(phan * 100, digits: 1))%]
        let huong = if hx > 0.35 { "right" } else if hx < -0.35 { "left" }
          else if hy > 0 { "above" } else { "below" }
        if phan >= 0.08 {
          // % trắng đậm trong quạt, tên ngoài
          if phan-tram {
            nhan(ctx, (hx * 0.62, hy * 0.62), text(fill: white, weight: "bold", pc),
              huong: "center")
          }
          nhan(ctx, (hx * 1.06, hy * 1.06), [#m.at(0)], huong: huong, cach: 4pt)
        } else {
          // quạt bé: tên + % gộp chung bên ngoài
          let nd = if phan-tram { [#m.at(0) (#pc)] } else { [#m.at(0)] }
          nhan(ctx, (hx * 1.06, hy * 1.06), nd, huong: huong, cach: 4pt)
        }
        g = g2
      }
      if them != none { them(ctx) }
    },
  )
}

// =====================================================================
// SỐ ĐẶC TRƯNG MẪU SỐ LIỆU (TRẢ GIÁ TRỊ, không vẽ — dùng thẳng trong lời giải)
// KHÔNG ghép nhóm: nhận mảng thô, hoặc gia-tri + tan-so: (bảng tần số).
// GHÉP NHÓM (moc, tan-so): trung bình/phương sai theo GIÁ TRỊ ĐẠI DIỆN
// (trung điểm nhóm); mốt/trung vị/tứ phân vị NỘI SUY theo SGK 11–12.
// =====================================================================

// Bung bảng tần số (gia-tri + tan-so) thành mảng thô; tan-so: none -> giữ nguyên.
#let _bung(du-lieu, tan-so) = {
  if tan-so == none { return du-lieu }
  let d = ()
  for (i, v) in du-lieu.enumerate() {
    for _ in range(tan-so.at(i)) { d.push(v) }
  }
  d
}

#let so-trung-binh(du-lieu, tan-so: none) = {
  if tan-so == none { du-lieu.sum() / du-lieu.len() }
  else {
    range(du-lieu.len()).map(i => du-lieu.at(i) * tan-so.at(i)).sum() / tan-so.sum()
  }
}

// Mốt: TRẢ VỀ MẢNG các giá trị có tần số lớn nhất (mẫu có thể nhiều mốt).
#let mot(du-lieu, tan-so: none) = {
  let (gt, ts) = if tan-so != none { (du-lieu, tan-so) } else {
    let dem = (:)
    for v in du-lieu {
      let k = repr(v)
      if k in dem { dem.insert(k, (v, dem.at(k).at(1) + 1)) }
      else { dem.insert(k, (v, 1)) }
    }
    (dem.values().map(c => c.at(0)), dem.values().map(c => c.at(1)))
  }
  let fmax = calc.max(..ts)
  range(gt.len()).filter(i => ts.at(i) == fmax).map(i => gt.at(i))
}

#let trung-vi(du-lieu, tan-so: none) = _trung-vi(_bung(du-lieu, tan-so).sorted())

// tu-phan-vi nay nhận thêm tan-so: (bảng tần số) — bọc lại bản gốc phía trên.
#let _tpv-tho = tu-phan-vi
#let tu-phan-vi(du-lieu, tan-so: none) = _tpv-tho(_bung(du-lieu, tan-so))

#let khoang-bien-thien(du-lieu, tan-so: none) = {
  let d = _bung(du-lieu, tan-so)
  calc.max(..d) - calc.min(..d)
}

#let khoang-tu-phan-vi(du-lieu, tan-so: none) = {
  let q = tu-phan-vi(du-lieu, tan-so: tan-so)
  q.q3 - q.q1
}

// Phương sai s² (SGK: chia n); hieu-chinh: true -> s'² chia (n − 1).
#let phuong-sai(du-lieu, tan-so: none, hieu-chinh: false) = {
  let d = _bung(du-lieu, tan-so)
  let n = d.len()
  let m = d.sum() / n
  d.map(v => (v - m) * (v - m)).sum() / (if hieu-chinh { n - 1 } else { n })
}

#let do-lech-chuan(du-lieu, tan-so: none, hieu-chinh: false) = calc.sqrt(
  phuong-sai(du-lieu, tan-so: tan-so, hieu-chinh: hieu-chinh),
)

// -------------------- GHÉP NHÓM (moc: n+1 mốc, tan-so: n) --------------------

// Giá trị đại diện = trung điểm từng nhóm.
#let _dai-dien(moc) = range(moc.len() - 1).map(i => (moc.at(i) + moc.at(i + 1)) / 2)

#let so-trung-binh-ghep-nhom(moc, tan-so) = so-trung-binh(_dai-dien(moc), tan-so: tan-so)

// Mốt (SGK 11): nhóm chứa mốt = nhóm tần số LỚN NHẤT (nhiều nhóm bằng nhau
// thì lấy nhóm đầu); Mo = L + (f₁−f₀)/((f₁−f₀)+(f₁−f₂))·h, f ngoài biên = 0.
#let mot-ghep-nhom(moc, tan-so) = {
  let fmax = calc.max(..tan-so)
  let j = tan-so.position(f => f == fmax)
  let f0 = if j > 0 { tan-so.at(j - 1) } else { 0 }
  let f2 = if j < tan-so.len() - 1 { tan-so.at(j + 1) } else { 0 }
  let h = moc.at(j + 1) - moc.at(j)
  let ms = (fmax - f0) + (fmax - f2)
  if ms == 0 { moc.at(j) + h / 2 } else { moc.at(j) + (fmax - f0) / ms * h }
}

#let trung-vi-ghep-nhom(moc, tan-so) = tu-phan-vi-ghep-nhom(moc, tan-so).q2

#let phuong-sai-ghep-nhom(moc, tan-so, hieu-chinh: false) = phuong-sai(
  _dai-dien(moc), tan-so: tan-so, hieu-chinh: hieu-chinh,
)

#let do-lech-chuan-ghep-nhom(moc, tan-so, hieu-chinh: false) = calc.sqrt(
  phuong-sai-ghep-nhom(moc, tan-so, hieu-chinh: hieu-chinh),
)

// R = mốc phải nhóm CUỐI có dữ liệu − mốc trái nhóm ĐẦU có dữ liệu.
#let khoang-bien-thien-ghep-nhom(moc, tan-so) = {
  let i = tan-so.position(f => f > 0)
  let j = tan-so.len() - 1 - tan-so.rev().position(f => f > 0)
  moc.at(j + 1) - moc.at(i)
}

#let khoang-tu-phan-vi-ghep-nhom(moc, tan-so) = {
  let q = tu-phan-vi-ghep-nhom(moc, tan-so)
  q.q3 - q.q1
}
