// =====================================================================
// mat-cong.typ — ENGINE MẶT CONG (nón · trụ) CÓ NÉT KHUẤT TỰ ĐỘNG (08/2026)
//
// Bổ khuyết cho `da-dien.typ`: engine kia chỉ lo được KHỐI ĐA DIỆN LỒI và
// KHÔNG xử lý được hai khối che nhau. Ở đây dùng MỘT cơ chế duy nhất cho cả
// hai việc — BẮN TIA từ điểm đang xét về phía người nhìn; tia gặp lòng bất
// kì khối nào (kể cả chính nó) thì đoạn đó là NÉT KHUẤT.
//
//   #mat-cong(
//     mat-non(r: 2, cao: 4, mau: red),
//     mat-tru(tam: (0, 2, 0), r: 2, cao: 4, mau: blue),
//     cam: chieu-truc-giao(ngang: 15deg, cao: 22deg),
//     truc: (x: 2.6, y: 4.4, z: 4.6),
//   )
//
// TRỤC KHỐI ĐẶT NGHIÊNG ĐƯỢC: `nghieng:` là góc giữa trục khối và Oz,
// `huong:` là hướng ngả. Khi trục nghiêng thì TOÀN THÂN nghiêng theo — mặt
// đáy luôn VUÔNG GÓC với trục, đường sinh nghiêng cùng trục:
//
//   #mat-cong(mat-tru(r: 1.2, cao: 5, nghieng: 70deg))    // trụ nằm nghiêng
//   #mat-cong(mat-non(r: 1.6, cao: 4.5, nghieng: 90deg))  // nón nằm ngang
//
// Mọi công thức đều viết theo KHUNG RIÊNG (u, v, w) của khối — w là trục,
// (u, v) là hai phương trong mặt đáy — nên trục đứng chỉ là trường hợp riêng.
//
// Phép thử che khuất là GIẢI TÍCH, KHÔNG quét mẫu: giao của tia với mặt đáy
// là phương trình bậc nhất, với mặt bên là bậc hai; trạng thái trong/ngoài
// chỉ đổi tại các nghiệm đó nên chỉ cần xét trung điểm giữa hai mốc liên
// tiếp. Sai số duy nhất còn lại là ở mắt lưới của đường được vẽ (`n:`).
//
// GIỚI HẠN: đường sinh BIÊN (silhouette) CỐ Ý không để chính khối của nó
// che — tia bắn từ đúng đường biên là tiếp tuyến, xét ở đó sẽ chập chờn làm
// nét biên lúc liền lúc đứt. Chưa có mặt cầu.
// =====================================================================
#import "ve.typ": *
#import "da-dien.typ": v3-cong, v3-tru, v3-nhan, v3-dai, v3-vo-huong, v3-co-huong, v3-chuan, _cam, chieu-3d, chieu-xien, chieu-oxyz, chieu-truc-giao

// =====================================================================
// KHUNG RIÊNG CỦA KHỐI — (u, v) trong mặt đáy, w dọc trục
// =====================================================================
// Camera MẶC ĐỊNH của engine này là chiếu TRỰC GIAO, KHÔNG phải `chieu-xien`
// như `da-dien.typ`. Lý do: chiếu xiên làm đường tròn nằm ngang chiếu ra elip
// NGHIÊNG trong khi trục khối vẫn dựng đứng — đáy nghiêng mà trục đứng, nhìn
// vô lý. Chiếu trực giao cho elip đáy có trục lớn NẰM NGANG, khối vẽ ra NGAY
// NGẮN đúng lối sách giáo khoa. Muốn lối cũ thì khai rõ `cam: chieu-xien()`.
#let _cam-mc(c) = if c == auto {
  chieu-truc-giao(ngang: 15deg, cao: 22deg)
} else { _cam(c) }

#let _khung(w0) = {
  let w = v3-chuan(w0)
  // chọn vectơ mồi KHÔNG song song với w, kẻo tích có hướng ra vectơ không
  let moi = if calc.abs(w.at(2)) > 0.9 { (1.0, 0.0, 0.0) } else { (0.0, 0.0, 1.0) }
  let u = v3-chuan(v3-co-huong(moi, w))
  (u, v3-co-huong(w, u), w)
}

// Nhận CẢ kiểu angle (`30deg`) LẪN số trần (`30` = 30 ĐỘ) — cùng lối
// `toa-cuc` của ve.typ. Không có dòng này thì `nghieng: 210` bị Typst hiểu
// là 210 RADIAN, khối quay đi đâu không biết mà KHÔNG hề báo lỗi.
#let _goc-do(a) = if type(a) == angle { a } else { a * 1deg }

// Trục khối suy từ hai góc: `nghieng` = góc so với Oz, `huong` = hướng ngả.
#let _truc-tu-goc(nghieng0, huong0) = {
  let nghieng = _goc-do(nghieng0)
  let huong = _goc-do(huong0)
  (
    calc.sin(nghieng) * calc.cos(huong),
    calc.sin(nghieng) * calc.sin(huong),
    calc.cos(nghieng),
  )
}

#let _khoi(loai, tam, r, cao, nghieng, huong, truc, mau, to) = {
  let w0 = if truc == auto { _truc-tu-goc(nghieng, huong) } else { truc }
  let (u, v, w) = _khung(w0)
  (loai: loai, tam: tam, r: r, cao: cao, u: u, v: v, w: w, mau: mau, to: to)
}

// =====================================================================
// MÔ TẢ KHỐI — TRẢ GIÁ TRỊ (KHÔNG kê vào ve-voi)
//   tam     : tâm mặt đáy (đáy DƯỚI nếu trục đứng)
//   r, cao  : bán kính đáy, chiều cao ĐO DỌC TRỤC
//   nghieng : góc giữa trục khối và Oz (0 = đứng, 90° = nằm ngang)
//   huong   : hướng ngả của trục, đo trong mặt phẳng Oxy
//   truc    : ghi đè thẳng bằng vectơ 3D (auto = suy từ nghieng/huong)
// =====================================================================
#let mat-non(
  tam: (0, 0, 0), r: 2, cao: 4,
  nghieng: 0deg, huong: 0deg, truc: auto,
  mau: auto, to: auto,
) = _khoi("non", tam, r, cao, nghieng, huong, truc, mau, to)

#let mat-tru(
  tam: (0, 0, 0), r: 2, cao: 4,
  nghieng: 0deg, huong: 0deg, truc: auto,
  mau: auto, to: auto,
) = _khoi("tru", tam, r, cao, nghieng, huong, truc, mau, to)

// Đỉnh nón (cũng là tâm đáy trên của trụ).
#let dinh-non(k) = v3-cong(k.tam, v3-nhan(k.cao, k.w))

// Mảng điểm 3D của một ĐƯỜNG TRÒN tâm `tam`, bán kính r, nằm trong mặt phẳng
// vuông góc với `truc` — đưa vào `duong:` của `ve-mat-cong` để vẽ thiết diện,
// đường tròn phụ… mà vẫn được tự chia liền/đứt. TRẢ GIÁ TRỊ (không kê).
#let tron-ngang(tam, r, truc: (0, 0, 1), n: 48) = {
  let (u, v, w) = _khung(truc)
  range(n + 1).map(i => {
    let t = 360deg * (i / n)
    v3-cong(tam, v3-cong(v3-nhan(r * calc.cos(t), u), v3-nhan(r * calc.sin(t), v)))
  })
}

// Điểm P có nằm HẲN trong lòng khối không?
// `lui` CO KHỐI LẠI một chút — KHÔNG phải để làm đẹp mà là BẮT BUỘC:
// đường tròn được vẽ bằng đa giác n cạnh, nên TRUNG ĐIỂM DÂY CUNG (điểm mà
// `_duong-tu-dong` đem đi thử) thụt vào trong vành đúng bằng độ võng
// `r·(1 − cos(180°/n))`. Tia bắn từ đó xuyên qua một LÁT MỎNG của chính khối
// rồi ra ngay ⇒ phép thử giải tích bắt đúng lát đó và báo KHUẤT oan, làm cả
// vành đáy thành nét đứt. Vì vậy `ve-mat-cong` tính `lui` theo `n` rồi gắn
// vào từng khối. (Bản quét mẫu cũ vô tình NHẢY QUA lát này nên không lộ lỗi.)
#let _trong-khoi(k, P) = {
  let lui = k.at("lui", default: 1e-4)
  let q = v3-tru(P, k.tam)
  let z = v3-vo-huong(q, k.w)          // toạ độ DỌC TRỤC
  if z < lui or z > k.cao - lui { return false }
  let d = v3-dai(v3-tru(q, v3-nhan(z, k.w)))   // khoảng cách tới trục
  let bk = if k.loai == "non" { k.r * (1 - z / k.cao) } else { k.r }
  d < bk - lui
}

// Các MỐC s > 0 mà trạng thái trong/ngoài khối k CÓ THỂ đổi dọc tia P + s·e:
// hai mặt đáy (mặt phẳng) + mặt bên (phương trình bậc hai).
// ⚠️ ĐỪNG quay lại lối QUÉT MẪU đều: bước quét luôn có thể dài hơn dây cung
// đi qua khối ⇒ tia "nhảy qua" khối và nét khuất bị bỏ sót. Đã vấp đúng lỗi
// đó (đường sinh trụ nằm trong lòng nón mà vẫn vẽ liền): bước 1.13 trong khi
// dây cung chỉ 0.5.
#let _moc-tia(k, P, e) = {
  let q = v3-tru(P, k.tam)
  let z0 = v3-vo-huong(q, k.w)
  let ez = v3-vo-huong(e, k.w)
  let a = v3-tru(q, v3-nhan(z0, k.w))     // phần vuông góc trục
  let b = v3-tru(e, v3-nhan(ez, k.w))
  let moc = ()
  if calc.abs(ez) > 1e-12 {
    moc.push(-z0 / ez)
    moc.push((k.cao - z0) / ez)
  }
  // mặt bên: |a + s·b|² = bán kính(s)²
  let he = if k.loai == "tru" {
    (v3-vo-huong(b, b), 2 * v3-vo-huong(a, b), v3-vo-huong(a, a) - k.r * k.r)
  } else {
    let m = k.r / k.cao
    let a0 = k.r - m * z0
    let k1 = m * ez
    (
      v3-vo-huong(b, b) - k1 * k1,
      2 * (v3-vo-huong(a, b) + a0 * k1),
      v3-vo-huong(a, a) - a0 * a0,
    )
  }
  let (A, B, C) = he
  if calc.abs(A) > 1e-12 {
    let D = B * B - 4 * A * C
    if D > 0 {
      let sq = calc.sqrt(D)
      moc.push((-B - sq) / (2 * A))
      moc.push((-B + sq) / (2 * A))
    }
  } else if calc.abs(B) > 1e-12 {
    moc.push(-C / B)
  }
  moc
}

// Điểm P có bị khối nào che không: bắn tia P + s·e về phía người nhìn.
// CHÍNH XÁC (không quét mẫu): trạng thái trong/ngoài chỉ đổi tại các mốc
// của `_moc-tia`, nên chỉ cần xét TRUNG ĐIỂM giữa hai mốc liên tiếp.
// `bo` = chỉ số khối được BỎ QUA (không tự che).
#let _bi-che(P, e, ds-khoi, bo: -1) = {
  let moc = (1e-6,)
  for j in range(ds-khoi.len()) {
    if j == bo { continue }
    for s in _moc-tia(ds-khoi.at(j), P, e) {
      if s > 1e-6 { moc.push(s) }
    }
  }
  let moc = moc.sorted()
  for i in range(moc.len() - 1) {
    let Q = v3-cong(P, v3-nhan((moc.at(i) + moc.at(i + 1)) / 2, e))
    for j in range(ds-khoi.len()) {
      if j != bo and _trong-khoi(ds-khoi.at(j), Q) { return true }
    }
  }
  false
}

// =====================================================================
// VẼ MỘT ĐƯỜNG 3D, TỰ CHIA LIỀN / ĐỨT
// Mỗi mắt lưới xét ở TRUNG ĐIỂM rồi gom các mắt liên tiếp cùng trạng thái
// (cùng lối với `_doan-tu-dong` của da-dien.typ).
// =====================================================================
#let _duong-tu-dong(
  ctx, p, e, ds-khoi, pts,
  mau: black, day: 1.1pt, hien-khuat: true,
  mau-khuat: auto, day-khuat: auto, bo: -1,
) = {
  let m = pts.len()
  if m < 2 { return }
  let trang = range(m - 1).map(i => {
    let M = v3-nhan(0.5, v3-cong(pts.at(i), pts.at(i + 1)))
    _bi-che(M, e, ds-khoi, bo: bo)
  })
  let dau = 0
  let i = 1
  while i <= m - 1 {
    let het = i == m - 1
    if het or trang.at(i) != trang.at(dau) {
      let cuoi = if het { m - 1 } else { i }
      let che = trang.at(dau)
      if not che or hien-khuat {
        duong-cong(
          ctx, range(dau, cuoi + 1).map(j => p(pts.at(j))),
          mau: if not che or mau-khuat == auto { mau } else { mau-khuat },
          day: if not che or day-khuat == auto { day } else { day-khuat },
          dut: che,
        )
      }
      dau = i
    }
    i = i + 1
  }
}

// =====================================================================
// HÌNH HỌC CỦA TỪNG KHỐI — viết theo KHUNG RIÊNG (u, v, w)
// =====================================================================
// Điểm trên đường tròn bán kính R quanh trục, cách đáy `h` dọc trục.
#let _diem-vanh(k, R, t, h) = v3-cong(
  v3-cong(k.tam, v3-nhan(h, k.w)),
  v3-cong(v3-nhan(R * calc.cos(t), k.u), v3-nhan(R * calc.sin(t), k.v)),
)
#let _cung-vanh(k, R, h, tu, den, n: 48) = range(n + 1).map(i => {
  _diem-vanh(k, R, tu + (den - tu) * (i / n), h)
})

// Hiệu hai điểm 2D · tích có hướng 2D.
#let _tru2(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let _cheo2(a, b) = a.at(0) * b.at(1) - a.at(1) * b.at(0)

// Góc ứng với điểm GẦN người nhìn nhất trên vành: độ sâu tỉ lệ với
// cos t·(u·e) + sin t·(v·e), lớn nhất tại atan2(u·e, v·e).
#let _goc-gan(k, e) = calc.atan2(v3-vo-huong(k.u, e), v3-vo-huong(k.v, e))

// Hai góc ứng với ĐƯỜNG SINH BIÊN của khối.
//   • trụ : pháp tuyến mặt bên vuông góc tia nhìn ⇔ _goc-gan ± 90°.
//   • nón : điều kiện hình chiếu đường sinh TIẾP XÚC elip đáy —
//       (W×U)·sin t − (W×V)·cos t = −r·(U×V)/cao,
//     với U, V, W là ảnh của khung riêng (u, v, w) qua phép chiếu.
//     (Kiểm chứng với trục đứng + chieu-oxyz: ra đúng
//      cos t + k·cos(goc)·sin t = −r·k·sin(goc)/cao.)
#let _goc-bien(k, p, e) = {
  let g0 = _goc-gan(k, e)
  if k.loai != "non" { return (g0 - 90deg, g0 + 90deg) }
  let o = p((0, 0, 0))
  let U = _tru2(p(k.u), o)
  let V = _tru2(p(k.v), o)
  let W = _tru2(p(k.w), o)
  let a = _cheo2(W, U)
  let b = -_cheo2(W, V)
  let bien-do = calc.sqrt(a * a + b * b)
  if bien-do < 1e-12 { return (g0 - 90deg, g0 + 90deg) }
  let ve-phai = -k.r * _cheo2(U, V) / (k.cao * bien-do)
  let dt = calc.acos(calc.max(-1.0, calc.min(1.0, ve-phai)))
  let ph = calc.atan2(b, a)
  (ph - dt, ph + dt)
}

// Các đường phải vẽ của một khối: mảng (pts, tu-che). `tu-che = false`
// nghĩa là đường BIÊN — không để chính khối đó che.
#let _duong-khoi(k, p, e, n: 48) = {
  let (t1, t2) = _goc-bien(k, p, e)
  // ÉP KIỂU int: calc.round và phép chia của Typst trả FLOAT, mà `range`
  // chỉ nhận số nguyên ("expected integer, found float").
  let ns = calc.max(2, int(n / 2))
  let ds = ((_cung-vanh(k, k.r, 0, 0deg, 360deg, n: n), true),)
  if k.loai == "non" {
    let S = dinh-non(k)
    for t in (t1, t2) {
      let B = _diem-vanh(k, k.r, t, 0)
      ds.push((
        range(ns + 1).map(i => v3-cong(B, v3-nhan(i / ns, v3-tru(S, B)))),
        false,
      ))
    }
  } else {
    ds.push((_cung-vanh(k, k.r, k.cao, 0deg, 360deg, n: n), true))
    for t in (t1, t2) {
      let A = _diem-vanh(k, k.r, t, 0)
      ds.push((
        range(ns + 1).map(i => v3-cong(A, v3-nhan(k.cao * i / ns, k.w))),
        false,
      ))
    }
  }
  ds
}

// Đường bao ngoài (dùng để tô màu): nón = cung đáy thấy được + đỉnh;
// trụ = cung đáy phía trước + cung nắp phía sau.
#let _bao-khoi(k, p, e, n: 48) = {
  let (t1, t2) = _goc-bien(k, p, e)
  if k.loai == "non" {
    _cung-vanh(k, k.r, 0, t1, t2, n: n) + (dinh-non(k),)
  } else {
    // BẮT BUỘC bọc ngoặc: `+` ở ĐẦU dòng nối bị Typst đọc thành dấu dương
    // một ngôi ("cannot apply unary '+' to array").
    (
      _cung-vanh(k, k.r, 0, t1, t2, n: n)
        + _cung-vanh(k, k.r, k.cao, t2, t1 + 360deg, n: n)
    )
  }
}

// Các điểm bao của khối (để dựng cửa sổ khung hình). Lấy 12 hướng quanh mỗi
// vành chứ không phải 4 — hình chiếu của đường tròn là elip XIÊN nên bốn
// điểm theo trục toạ độ hụt mất phần chìa ra hai bên.
#let _chot-khoi(k, m: 12) = {
  let ds = ()
  for h in (0, k.cao) {
    let bk = if k.loai == "non" and h == k.cao { 0.0 } else { k.r }
    for i in range(m) { ds.push(_diem-vanh(k, bk, 360deg * (i / m), h)) }
  }
  ds
}
#let _chot-tat-ca(ds) = {
  let kq = ()
  for k in ds { kq = kq + _chot-khoi(k) }
  kq
}

// =====================================================================
// HỆ TRỤC Oxyz VẼ BẰNG CHÍNH CAMERA CỦA KHỐI
// Lý do phải có: `oxyz` của hinh-khong-gian.typ tự dựng phép chiếu XIÊN
// riêng của nó. Trong phép chiếu xiên, đường tròn nằm ngang chiếu ra elip
// NGHIÊNG trong khi Oz vẫn dựng đứng — nhìn vô lý. Vẽ trục bằng chính
// camera của khối thì cả khung hình chung MỘT góc nhìn. Với
// `chieu-truc-giao(cao:)` thì elip đáy của khối ĐỨNG có trục lớn NẰM NGANG
// và trục khối THẲNG ĐỨNG — đúng như nhìn vật thật.
// NHẬN ctx ⇒ PHẢI kê vào `ve-voi` và khối `_voi-ctx`.
// =====================================================================
#let ve-truc-3d(
  ctx, cam,
  x: 3, y: 4, z: 4,
  am: 0.4,            // kéo dài thêm về phía âm
  dm: 0.55,           // chừa chỗ cho mũi tên + nhãn ở đầu dương
  ten: ($x$, $y$, $z$), ten-goc: $O$,
  huong-ten: ("below-left", "below-right", "left"),
  huong-goc: "below-right",
  mau: black, day: 0.9pt, cach: 5pt,
) = {
  let p = _cam(cam).p
  let bo3 = (
    ((1, 0, 0), x, ten.at(0), huong-ten.at(0)),
    ((0, 1, 0), y, ten.at(1), huong-ten.at(1)),
    ((0, 0, 1), z, ten.at(2), huong-ten.at(2)),
  )
  for (u, L, t, hg) in bo3 {
    let B = v3-nhan(L + am + dm, u)
    mui-ten(ctx, p(v3-nhan(-am, u)), p(B), mau: mau, day: day)
    if t != none { nhan(ctx, p(B), t, huong: hg, cach: cach) }
  }
  if ten-goc != none {
    nhan(ctx, p((0, 0, 0)), ten-goc, huong: huong-goc, cach: 4pt)
  }
}

// Hai đầu mút ba trục (để cửa sổ khung hình bao được cả hệ trục).
#let _chot-truc(tr) = {
  let am = tr.at("am", default: 0.4)
  let dm = tr.at("dm", default: 0.55)
  let kq = ()
  for (khoa, u) in (("x", (1, 0, 0)), ("y", (0, 1, 0)), ("z", (0, 0, 1))) {
    let L = tr.at(khoa, default: if khoa == "x" { 3 } else { 4 })
    kq.push(v3-nhan(-am, u))
    kq.push(v3-nhan(L + am + dm, u))
  }
  kq
}

// =====================================================================
// VE-MAT-CONG — NHẬN ctx ⇒ PHẢI kê vào `ve-voi` và khối `_voi-ctx`
// =====================================================================
#let ve-mat-cong(
  ctx,
  ..khoi,
  cam: auto,
  mau: black, day: 1.1pt, to: none,
  hien-khuat: true, mau-khuat: auto, day-khuat: auto,
  n: 48,
  duong: (),
  truc: none,        // dict tuỳ chọn của `ve-truc-3d`, vd truc: (x: 3, y: 5, z: 5)
  truoc: none,       // vẽ TRƯỚC khối · them: vẽ SAU khối
  them: none,
) = {
  let ds0 = khoi.pos()
  if ds0.len() == 0 { return }
  // gắn `lui` cho từng khối: phải LỚN HƠN độ võng dây cung của lưới n cạnh,
  // xem giải thích ở `_trong-khoi`. Hệ số 1.6 là biên an toàn.
  let ds = ds0.map(k => k + (
    lui: calc.max(1e-4, 1.6 * k.r * (1 - calc.cos(180deg / n))),
  ))
  let cm = _cam-mc(cam)
  let p = cm.p
  let e = cm.nhin
  // 0) hệ trục + lớp vẽ nền — nằm DƯỚI khối
  if truc != none { ve-truc-3d(ctx, cm, ..truc) }
  if truoc != none { truoc(ctx, p) }
  // 1) tô màu trước, để nét không bị màu đè lên
  for k in ds {
    let mt = if k.to == auto { to } else { k.to }
    if mt != none {
      da-giac-pt(_bao-khoi(k, p, e, n: n).map(P => toa-pt(ctx, p(P))), to: mt)
    }
  }
  // 2) rồi mới kẻ nét, tự chia liền / đứt
  for j in range(ds.len()) {
    let k = ds.at(j)
    let mk = if k.mau == auto { mau } else { k.mau }
    for (pts, tu-che) in _duong-khoi(k, p, e, n: n) {
      _duong-tu-dong(
        ctx, p, e, ds, pts,
        mau: mk, day: day, hien-khuat: hien-khuat,
        mau-khuat: mau-khuat, day-khuat: day-khuat,
        bo: if tu-che { -1 } else { j },
      )
    }
  }
  // 3) các đường vẽ thêm (thiết diện, đường tròn phụ…) — cũng tự chia liền/đứt.
  //    Mỗi mục là một DICT: (pts: mảng điểm 3D, mau: …, day: …, hien-khuat: …)
  for m in duong {
    _duong-tu-dong(
      ctx, p, e, ds, m.pts,
      mau: m.at("mau", default: mau),
      day: m.at("day", default: day),
      hien-khuat: m.at("hien-khuat", default: hien-khuat),
      mau-khuat: mau-khuat, day-khuat: day-khuat,
    )
  }
  if them != none { them(ctx, p) }
}

// =====================================================================
// MAT-CONG — TỰ tạo khung hình (KHÔNG kê vào ve-voi)
// Mọi tuỳ chọn khác đều chảy thẳng xuống `ve-mat-cong` qua sink `..khoi`.
// =====================================================================
#let mat-cong(..khoi, cam: auto, w: 7cm, le: 0.75, co-chu: 10pt) = {
  let cm = _cam-mc(cam)
  let tr = khoi.named().at("truc", default: none)
  let chot = _chot-tat-ca(khoi.pos()) + (if tr == none { () } else { _chot-truc(tr) })
  let pts = chot.map(cm.p)
  let xs = pts.map(q => q.at(0))
  let ys = pts.map(q => q.at(1))
  hinh(
    w: w,
    xmin: calc.min(..xs) - le, xmax: calc.max(..xs) + le,
    ymin: calc.min(..ys) - le, ymax: calc.max(..ys) + le,
    co-chu: co-chu,
    ctx => ve-mat-cong(ctx, ..khoi, cam: cm),
  )
}
