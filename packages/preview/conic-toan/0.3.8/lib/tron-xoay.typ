// =====================================================================
// tron-xoay.typ — MIỀN PHẲNG & KHỐI TRÒN XOAY (Giải tích 12)
//
//   #khoi-tron-xoay(x => calc.sqrt(x), 0, 4)
//     -> TRÁI: miền phẳng giới hạn bởi y = f(x), trục hoành, x = a, x = b
//        (đã tô màu);  PHẢI: khối tròn xoay sinh ra khi quay miền đó quanh Ox.
//
// Tham số chính:
//   truc     : "Ox" (mặc định) hoặc "Oy". Với "Oy" thì f là BÁN KÍNH theo y,
//              tức miền giới hạn bởi x = f(y), trục tung, y = a, y = b.
//   hien     : "ca-hai" (mặc định) | "mien" (chỉ miền phẳng) | "khoi" (chỉ khối)
//   g        : biên trong (khối rỗng — vành khăn), none = khối đặc
//   mat-cat  : c -> vẽ thiết diện (đĩa/vành khăn) tại x = c kèm bán kính
//   the-tich : true -> ghi công thức thể tích dưới hình
//
// Hàm lõi `ve-khoi-xoay(ctx, f, a, b, ...)` vẽ RIÊNG khối vào một khung
// #hinh có sẵn (gọi được không cần ctx như mọi hàm vẽ khác).
// =====================================================================
#import "ve.typ": *
#import "do-thi.typ": so-toan

// ---------- Tiện ích nội bộ ----------
// Điểm trong hệ "chuẩn hoá": u dọc theo TRỤC QUAY, v vuông góc trục quay.
#let _pxy(ngang, u, v) = if ngang { (u, v) } else { (v, u) }

// Điểm trên đường tròn thiết diện đã chiếu thành elip (k = tỉ lệ bán trục):
//   t = 0° đỉnh trên · 90° mép "sau" · 180° đỉnh dưới · 270° mép "trước"
#let _e-diem(ngang, k, u, R, t) = _pxy(
  ngang,
  u + k * R * calc.sin(t),
  R * calc.cos(t),
)

// Cung elip thiết diện từ t1 đến t2.
#let _cung-td(
  ctx, ngang, k, u, R, t1, t2,
  mau: black, day: 1pt, dut: false, n: 40,
) = {
  if R <= 0.0001 { return }
  duong-cong(
    ctx,
    range(n + 1).map(i => _e-diem(ngang, k, u, R, t1 + (t2 - t1) * i / n)),
    mau: mau, day: day, dut: dut,
  )
}

// Elip thiết diện ĐẦY ĐỦ (dùng để tô).
#let _to-td(ctx, ngang, k, u, R, mau) = {
  if R <= 0.0001 { return }
  da-giac-pt(
    range(49).map(i => toa-pt(ctx, _e-diem(ngang, k, u, R, 360deg * i / 48))),
    to: mau,
  )
}

// Giá trị lớn nhất của |f| trên [a, b] (lấy mẫu).
#let _ban-kinh-max(f, a, b, n: 120) = calc.max(
  0.0001,
  ..range(n + 1).map(i => calc.abs(f(a + (b - a) * i / n))),
)

// Hệ trục cho hình: trục quay (có mũi tên + tên) và trục vuông góc nếu 0 thuộc
// phạm vi. `ngang = true` -> trục quay là Ox.
#let _truc-xoay(
  ctx, ngang, umin, umax, vmin, vmax,
  mau: black, day: 0.9pt, ten-goc: $O$,
) = {
  let (ten-u, ten-v) = if ngang { ($x$, $y$) } else { ($y$, $x$) }
  mui-ten(ctx, _pxy(ngang, umin, 0), _pxy(ngang, umax, 0), mau: mau, day: day)
  nhan(
    ctx, _pxy(ngang, umax, 0), ten-u,
    huong: if ngang { "duoi-phai" } else { "tren-phai" }, cach: 3pt,
  )
  if vmin <= 0 and vmax >= 0 and umin <= 0 and umax >= 0 {
    mui-ten(ctx, _pxy(ngang, 0, vmin), _pxy(ngang, 0, vmax), mau: mau, day: day)
    nhan(
      ctx, _pxy(ngang, 0, vmax), ten-v,
      huong: if ngang { "tren-phai" } else { "duoi-phai" }, cach: 3pt,
    )
    if ten-goc != none {
      nhan(ctx, (0, 0), ten-goc, huong: "duoi-trai", cach: 4pt, mau: mau)
    }
  }
}

// =====================================================================
// ve-khoi-xoay — vẽ KHỐI TRÒN XOAY vào khung #hinh có sẵn
// (trục quay đi qua gốc; `ngang: true` = quay quanh Ox, false = quanh Oy)
// =====================================================================
#let ve-khoi-xoay(
  ctx, f, a, b,
  g: none,                       // bán kính trong (vành khăn); none = đặc
  ngang: true,
  k: 0.26,                       // tỉ lệ bán trục ngang của elip / bán kính
  mau: blue, day: 1.2pt,
  mau-to: rgb(70, 130, 200, 60),
  duong-sinh: true,              // vẽ biên trên/dưới của khối
  truc-mo: true,                 // đoạn trục quay bên trong khối vẽ nét đứt
  mat-cat: none,                 // vẽ thiết diện tại u = c
  mau-mat-cat: rgb(235, 130, 40, 120),
  ten-ban-kinh: auto,            // nhãn bán kính thiết diện (none = bỏ)
  ten-mat-cat: auto,             // nhãn mốc c trên trục (none = bỏ)
  n: 120,
) = {
  let R = u => calc.abs(f(u))
  let Rt = if g == none { u => 0.0 } else { u => calc.abs(g(u)) }
  let Ra = R(a)
  let Rb = R(b)
  let M = _ban-kinh-max(f, a, b)
  let tren = range(n + 1).map(i => {
    let u = a + (b - a) * i / n
    _pxy(ngang, u, R(u))
  })
  let duoi = range(n + 1).map(i => {
    let u = b + (a - b) * i / n
    _pxy(ngang, u, -R(u))
  })
  // ---- tô khối: nắp trái (nửa ngoài) + biên trên + nắp phải + biên dưới
  let nap-t = range(41).map(i => _e-diem(ngang, k, a, Ra, 180deg + 180deg * i / 40))
  let nap-p = range(41).map(i => _e-diem(ngang, k, b, Rb, 180deg * i / 40))
  da-giac-pt((nap-t + tren + nap-p + duoi).map(P => toa-pt(ctx, P)), to: mau-to)
  // ---- trục quay bên trong khối (bị che -> nét đứt)
  if truc-mo {
    doan(
      ctx, _pxy(ngang, a, 0), _pxy(ngang, b, 0),
      mau: black, day: 0.7pt, dut: true,
    )
  }
  // ---- thiết diện
  if mat-cat != none {
    let c = mat-cat
    let Rc = R(c)
    _to-td(ctx, ngang, k, c, Rc, mau-mat-cat)
    if g != none { _to-td(ctx, ngang, k, c, Rt(c), white) }
    _cung-td(ctx, ngang, k, c, Rc, 0deg, 360deg, mau: mau.darken(10%), day: 0.9pt)
    if g != none {
      _cung-td(ctx, ngang, k, c, Rt(c), 0deg, 360deg, mau: mau.darken(10%), day: 0.9pt)
    }
    doan(ctx, _pxy(ngang, c, 0), _pxy(ngang, c, Rc), mau: red.darken(10%), day: 0.9pt)
    if ten-ban-kinh != none {
      let nd = if ten-ban-kinh == auto {
        if ngang { $f(x)$ } else { $f(y)$ }
      } else { ten-ban-kinh }
      nhan(
        ctx, _e-diem(ngang, k, c, Rc, 90deg + 45deg), nd,
        huong: if ngang { "phai" } else { "duoi" },
        cach: 3pt, mau: red.darken(10%),
      )
    }
    if ten-mat-cat != none {
      let nd = if ten-mat-cat == auto { so-toan(c) } else { ten-mat-cat }
      doan(
        ctx, _pxy(ngang, c, -Rc), _pxy(ngang, c, -M - 0.3),
        mau: gray.darken(20%), day: 0.7pt, dut: true,
      )
      nhan(
        ctx, _pxy(ngang, c, -M - 0.3), nd,
        huong: if ngang { "duoi" } else { "trai" }, cach: 3pt,
      )
    }
  }
  // ---- đường sinh (biên trên / biên dưới)
  if duong-sinh {
    duong-cong(ctx, tren, mau: mau, day: day)
    duong-cong(ctx, duoi, mau: mau, day: day)
  }
  // ---- nắp hai đầu: trái nửa trong bị che (đứt), phải thấy trọn
  _cung-td(ctx, ngang, k, a, Ra, 180deg, 360deg, mau: mau, day: day)
  _cung-td(ctx, ngang, k, a, Ra, 0deg, 180deg, mau: mau, day: 0.8pt, dut: true)
  _cung-td(ctx, ngang, k, b, Rb, 0deg, 360deg, mau: mau, day: day)
  // ---- khối rỗng: mặt trong + lỗ ở nắp phải
  if g != none {
    _to-td(ctx, ngang, k, b, Rt(b), white)
    _cung-td(ctx, ngang, k, b, Rt(b), 0deg, 360deg, mau: mau, day: day)
    _cung-td(ctx, ngang, k, a, Rt(a), 0deg, 360deg, mau: mau, day: 0.8pt, dut: true)
    for s in (1, -1) {
      duong-cong(
        ctx,
        range(n + 1).map(i => {
          let u = a + (b - a) * i / n
          _pxy(ngang, u, s * Rt(u))
        }),
        mau: mau, day: 0.9pt, dut: true,
      )
    }
  }
}

// =====================================================================
// ve-mien-xoay — vẽ MIỀN PHẲNG sinh ra khối (tô màu + cận a, b)
// =====================================================================
#let ve-mien-xoay(
  ctx, f, a, b,
  g: none,
  ngang: true,
  mau: blue, day: 1.3pt,
  mau-to: rgb(70, 130, 200, 90),
  ten-ham: auto, ten-ham-trong: none,
  ten-a: auto, ten-b: auto,
  giong-ab: true,
  n: 120,
) = {
  let R = u => calc.abs(f(u))
  let Rt = if g == none { u => 0.0 } else { u => calc.abs(g(u)) }
  let tren = range(n + 1).map(i => {
    let u = a + (b - a) * i / n
    _pxy(ngang, u, R(u))
  })
  let duoi = range(n + 1).map(i => {
    let u = b + (a - b) * i / n
    _pxy(ngang, u, Rt(u))
  })
  da-giac-pt((tren + duoi).map(P => toa-pt(ctx, P)), to: mau-to)
  duong-cong(ctx, tren, mau: mau, day: day)
  if g != none { duong-cong(ctx, duoi, mau: mau.darken(25%), day: day) }
  if giong-ab {
    for (u, t) in ((a, ten-a), (b, ten-b)) {
      doan(
        ctx, _pxy(ngang, u, Rt(u)), _pxy(ngang, u, R(u)),
        mau: gray.darken(25%), day: 0.8pt, dut: true,
      )
      // cận trùng gốc toạ độ thì bỏ nhãn (kẻo đè chữ O)
      if t != none and not (t == auto and calc.abs(u) < 0.001) {
        nhan(
          ctx, _pxy(ngang, u, 0), if t == auto { so-toan(u) } else { t },
          huong: if ngang { "duoi" } else { "trai" }, cach: 4pt,
        )
      }
    }
  }
  if ten-ham != none {
    let u = a + (b - a) * 0.78
    let nd = if ten-ham == auto {
      if ngang { $y = f(x)$ } else { $x = f(y)$ }
    } else { ten-ham }
    nhan(
      ctx, _pxy(ngang, u, R(u)), nd,
      huong: if ngang { "tren-phai" } else { "phai" }, cach: 5pt, mau: mau,
    )
  }
  if ten-ham-trong != none and g != none {
    let u = a + (b - a) * 0.3
    nhan(
      ctx, _pxy(ngang, u, Rt(u)), ten-ham-trong,
      huong: if ngang { "duoi-phai" } else { "trai" }, cach: 5pt, mau: mau.darken(25%),
    )
  }
}

// =====================================================================
// khoi-tron-xoay — HÌNH HOÀN CHỈNH: miền phẳng  ->  khối tròn xoay
// =====================================================================
#let khoi-tron-xoay(
  f, a, b,
  g: none,
  truc: "Ox",
  hien: "ca-hai",                 // "ca-hai" | "mien" | "khoi"
  w: 6cm,
  k: 0.26,
  mau: blue, day: 1.3pt,
  mau-to: rgb(70, 130, 200, 60),
  mau-mien: rgb(70, 130, 200, 95),
  ten-ham: auto, ten-ham-trong: none,
  ten-a: auto, ten-b: auto,
  mat-cat: none,
  ten-mat-cat: auto, ten-ban-kinh: auto,
  the-tich: false,                // ghi công thức thể tích dưới hình
  nhan-giua: auto,                // nội dung giữa 2 hình
  ten-goc: $O$,                   // nhãn gốc toạ độ (none = bỏ)
  co-chu: 10pt,
  khung: false,
  them: none, them-mien: none,
) = {
  let ngang = truc != "Oy"
  let M = _ban-kinh-max(f, a, b)
  let d = calc.abs(b - a)
  let (a, b) = (calc.min(a, b), calc.max(a, b))
  let le = 0.16 * calc.max(M, d / 2) + 0.22
  let e = k * M
  let umin = a - e - le
  let umax = b + e + le + 0.12 * d
  let vmax = M + le
  let vmin = -M - le - (if mat-cat != none and ten-mat-cat != none { 0.42 } else { 0 })
  // cửa sổ của hình miền phẳng: chỉ cần chút chỗ dưới trục để ghi cận
  let vmin-m = -0.4 * M - 0.22
  let ti-le = w / (umax - umin)          // giữ ĐÚNG một tỉ lệ cho cả 2 hình

  let khung-khoi(rong, x1, x2, y1, y2, ve) = hinh(
    w: rong, xmin: x1, xmax: x2, ymin: y1, ymax: y2,
    co-chu: co-chu, khung: khung, ve,
  )

  let h-khoi = {
    let (x1, x2, y1, y2) = if ngang {
      (umin, umax, vmin, vmax)
    } else {
      (vmin, vmax, umin, umax)
    }
    khung-khoi(ti-le * (x2 - x1), x1, x2, y1, y2, ctx => {
      _truc-xoay(ctx, ngang, umin, umax, vmin, vmax, ten-goc: ten-goc)
      ve-khoi-xoay(
        ctx, f, a, b, g: g, ngang: ngang, k: k,
        mau: mau, day: day, mau-to: mau-to,
        mat-cat: mat-cat, ten-mat-cat: ten-mat-cat, ten-ban-kinh: ten-ban-kinh,
      )
      if them != none { them(ctx) }
    })
  }

  let h-mien = {
    let (x1, x2, y1, y2) = if ngang {
      (umin, umax, vmin-m, vmax)
    } else {
      (vmin-m, vmax, umin, umax)
    }
    khung-khoi(ti-le * (x2 - x1), x1, x2, y1, y2, ctx => {
      _truc-xoay(ctx, ngang, umin, umax, vmin-m, vmax, ten-goc: ten-goc)
      ve-mien-xoay(
        ctx, f, a, b, g: g, ngang: ngang,
        mau: mau, day: day, mau-to: mau-mien,
        ten-ham: ten-ham, ten-ham-trong: ten-ham-trong,
        ten-a: ten-a, ten-b: ten-b,
      )
      if them-mien != none { them-mien(ctx) }
    })
  }

  let giua = if nhan-giua == auto {
    align(center, {
      text(size: 0.82 * co-chu)[quay quanh #truc]
      linebreak()
      text(size: 1.3 * co-chu)[$arrow.r.long$]
    })
  } else { nhan-giua }

  let ct = if the-tich {
    let (bien, kx) = if ngang { ($x$, $dif x$) } else { ($y$, $dif y$) }
    let (na, nb) = (so-toan(a), so-toan(b))
    if g == none {
      $V = pi integral_(#na)^(#nb) f^2 (#bien) #kx$
    } else {
      $V = pi integral_(#na)^(#nb) [f^2 (#bien) - g^2 (#bien)] #kx$
    }
  } else { none }

  let than = if hien == "mien" {
    h-mien
  } else if hien == "khoi" {
    h-khoi
  } else {
    grid(
      columns: 3, column-gutter: 10pt, align: horizon,
      h-mien, giua, h-khoi,
    )
  }
  if ct == none { than } else {
    align(center, { than; v(2pt); ct })
  }
}
