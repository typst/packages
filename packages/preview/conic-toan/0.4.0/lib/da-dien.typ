// =====================================================================
// da-dien.typ — ENGINE ĐA DIỆN TỔNG QUÁT (07/2026)
//
// Nhập DANH SÁCH ĐỈNH 3D + DANH SÁCH MẶT (mảng chỉ số đỉnh) là vẽ được
// BẤT KÌ khối đa diện LỒI: tự chiếu, tự xác định mặt trước/mặt sau
// (back-face culling), tự vẽ nét liền / nét khuất, tự tô mặt theo độ sâu.
//
//   #da-dien(..khoi-chop-deu(n: 4, R: 2, cao: 3.6))
//   #da-dien(dinh: ((0,0,0), (3,0,0), (0,3,0), (0,0,3)),
//            mat: ((0,1,2), (0,1,3), (0,2,3), (1,2,3)),
//            ten: ($O$, $A$, $B$, $C$))
//
// QUY TẮC nét khuất: cạnh LIỀN nếu thuộc ít nhất một mặt hướng về người
// nhìn, ĐỨT nếu chỉ thuộc các mặt hướng ra sau. Quy tắc này CHÍNH XÁC với
// khối LỒI (chóp, lăng trụ, hộp, chóp cụt, tứ diện, bát diện… — tức toàn
// bộ hình học THPT). Khối KHÔNG lồi hoặc hai khối che nhau thì cần z-buffer,
// KHÔNG dùng được engine này.
//
// Thứ tự đỉnh trong mỗi mặt KHÔNG cần theo chiều nào: pháp tuyến được lật
// ra ngoài theo tâm khối.
// =====================================================================
#import "ve.typ": *

// Bí danh nội bộ: `ve-da-dien` có THAM SỐ tên `diem`/`duong`, mà tham số CHE
// mất hàm cùng tên của ve.typ. Giữ tham chiếu tới hàm vẽ ở đây để dùng bên
// trong thân hàm. (Đừng bỏ hai dòng này.)
#let _ve-diem = diem
#let _ve-duong = duong

// =====================================================================
// VECTƠ 3D — mọi hàm ở khối này TRẢ VỀ GIÁ TRỊ (không kê vào ve-voi)
// =====================================================================
#let v3-cong(A, B) = (A.at(0) + B.at(0), A.at(1) + B.at(1), A.at(2) + B.at(2))
#let v3-tru(A, B) = (A.at(0) - B.at(0), A.at(1) - B.at(1), A.at(2) - B.at(2))
#let v3-nhan(k, A) = (k * A.at(0), k * A.at(1), k * A.at(2))
// Tích vô hướng (dot) và tích có hướng (cross).
#let v3-vo-huong(A, B) = A.at(0) * B.at(0) + A.at(1) * B.at(1) + A.at(2) * B.at(2)
#let v3-co-huong(A, B) = (
  A.at(1) * B.at(2) - A.at(2) * B.at(1),
  A.at(2) * B.at(0) - A.at(0) * B.at(2),
  A.at(0) * B.at(1) - A.at(1) * B.at(0),
)
#let v3-dai(A) = calc.sqrt(calc.max(0.0, v3-vo-huong(A, A)))
#let v3-chuan(A) = {
  let d = v3-dai(A)
  if d < 1e-12 { A } else { v3-nhan(1 / d, A) }
}
// Trung điểm, điểm chia theo tỉ lệ t (0 = A, 1 = B), tâm (trung bình) của mảng.
#let trung-diem-3d(A, B) = v3-nhan(0.5, v3-cong(A, B))
#let chia-3d(A, B, t) = v3-cong(A, v3-nhan(t, v3-tru(B, A)))
#let tam-3d(ds) = v3-nhan(1 / ds.len(), ds.fold((0.0, 0.0, 0.0), v3-cong))

// Pháp tuyến của đa giác phẳng (mảng điểm 3D) — công thức Newell, bền với
// đa giác gần suy biến và không cần biết chiều quay.
#let phap-da-giac(ds) = {
  let n = ds.len()
  let s = (0.0, 0.0, 0.0)
  for i in range(n) {
    let A = ds.at(i)
    let B = ds.at(calc.rem(i + 1, n))
    s = v3-cong(s, (
      (A.at(1) - B.at(1)) * (A.at(2) + B.at(2)),
      (A.at(2) - B.at(2)) * (A.at(0) + B.at(0)),
      (A.at(0) - B.at(0)) * (A.at(1) + B.at(1)),
    ))
  }
  v3-chuan(s)
}

// =====================================================================
// CAMERA — phép chiếu song song + HƯỚNG NHÌN tự suy ra
// Phép chiếu p là hàm tuyến tính (x, y, z) -> (u, v) toạ độ toán của khung.
// Hai hàng của ma trận chiếu là hai trục màn hình (phải, lên); tích có hướng
// của chúng chính là hướng TỪ hình VỀ PHÍA người nhìn ⇒ suy được mặt trước.
// =====================================================================
#let _nhin(p) = {
  let o = p((0, 0, 0))
  let c1 = p((1, 0, 0))
  let c2 = p((0, 1, 0))
  let c3 = p((0, 0, 1))
  let r1 = (c1.at(0) - o.at(0), c2.at(0) - o.at(0), c3.at(0) - o.at(0))
  let r2 = (c1.at(1) - o.at(1), c2.at(1) - o.at(1), c3.at(1) - o.at(1))
  v3-chuan(v3-co-huong(r1, r2))
}

// Bọc một phép chiếu bất kì thành camera: (p: hàm chiếu, nhin: hướng nhìn).
#let chieu-3d(p) = (p: p, nhin: _nhin(p))

// Chiếu XIÊN mặc định (y = chiều sâu ra sau, z lên trên, x sang phải) —
// KHỚP với phép chiếu của các hình chóp/lăng trụ dựng sẵn trong lib.
#let chieu-xien(goc: 40deg, k: 0.5) = chieu-3d(P => (
  P.at(0) + k * P.at(1) * calc.cos(goc),
  P.at(2) + k * P.at(1) * calc.sin(goc),
))

// Chiếu KHỚP hệ trục #oxyz (Oy sang phải, Oz lên, Ox chéo xuống-trái về
// phía người nhìn). Dùng khi vẽ khối trong `oxyz(them: (ctx, t3) => ...)`
// — nhớ để k/goc trùng với oxyz.
#let chieu-oxyz(k: 0.55, goc: 35deg) = chieu-3d(P => (
  P.at(1) - k * P.at(0) * calc.cos(goc),
  P.at(2) - k * P.at(0) * calc.sin(goc),
))

// Camera TRỰC GIAO thật theo góc Euler: quay quanh Oz góc `ngang`, nâng
// cao `cao`. Oz luôn dựng đứng trên trang. `cao` lớn = nhìn từ trên xuống.
#let chieu-truc-giao(ngang: 65deg, cao: 22deg, ti-le: 1) = {
  let e = (
    calc.cos(cao) * calc.cos(ngang),
    calc.cos(cao) * calc.sin(ngang),
    calc.sin(cao),
  )
  let r = (-calc.sin(ngang), calc.cos(ngang), 0)
  let u = v3-co-huong(e, r)
  (
    p: P => (ti-le * v3-vo-huong(P, r), ti-le * v3-vo-huong(P, u)),
    nhin: e,
  )
}

// auto -> chiếu xiên mặc định · hàm -> tự suy hướng nhìn · dict -> dùng luôn.
#let _cam(c) = {
  if c == auto { chieu-xien() }
  else if type(c) == function { chieu-3d(c) }
  else { c }
}

// =====================================================================
// PHÂN TÍCH KHỐI — TRẢ GIÁ TRỊ (không kê vào ve-voi)
//   .cam   camera đã chuẩn hoá
//   .d2    mảng đỉnh đã chiếu (toạ độ toán 2D)
//   .sau   độ sâu từng đỉnh (LỚN hơn = gần người nhìn hơn)
//   .mat   mảng thông tin mặt: (chi-so, phap (ra ngoài), tam, sau, truoc)
//   .canh  mảng cạnh duy nhất: (i, j, hien) — hien = false thì vẽ ĐỨT
// =====================================================================
#let _canh-vong(m) = {
  let n = m.len()
  range(n).map(i => (m.at(i), m.at(calc.rem(i + 1, n))))
}
#let _khoa(i, j) = if i < j { str(i) + "-" + str(j) } else { str(j) + "-" + str(i) }

#let phan-tich-khoi(dinh, mat, cam: auto) = {
  let cm = _cam(cam)
  let e = cm.nhin
  let C = tam-3d(dinh)
  let d2 = dinh.map(cm.p)
  let ttm = ()
  for m in mat {
    let n = phap-da-giac(m.map(i => dinh.at(i)))
    let T = tam-3d(m.map(i => dinh.at(i)))
    // lật pháp tuyến RA NGOÀI khối (khối lồi: ra xa tâm khối)
    if v3-vo-huong(n, v3-tru(T, C)) < 0 { n = v3-nhan(-1, n) }
    ttm.push((
      chi-so: m,
      phap: n,
      tam: T,
      sau: v3-vo-huong(T, e),
      truoc: v3-vo-huong(n, e) > 1e-9,
    ))
  }
  // cạnh: hiện nếu thuộc ÍT NHẤT MỘT mặt trước; mặt hở (cạnh 1 mặt) luôn hiện
  let bang = (:)
  for f in ttm {
    for (i, j) in _canh-vong(f.chi-so) {
      let k = _khoa(i, j)
      let cu = bang.at(k, default: (i: calc.min(i, j), j: calc.max(i, j), hien: false, so: 0))
      bang.insert(k, (i: cu.i, j: cu.j, hien: cu.hien or f.truoc, so: cu.so + 1))
    }
  }
  let canh = bang.values().map(c => (
    i: c.i,
    j: c.j,
    hien: if c.so == 1 { true } else { c.hien },
  ))
  (cam: cm, d2: d2, sau: dinh.map(P => v3-vo-huong(P, e)), mat: ttm, canh: canh)
}

// Cửa sổ bao các điểm 2D + lề (nội bộ).
#let _cs2(pts, mg: 0.7) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  (
    xmin: calc.min(..xs) - mg, xmax: calc.max(..xs) + mg,
    ymin: calc.min(..ys) - mg, ymax: calc.max(..ys) + mg,
  )
}

// Hướng đặt nhãn cho đỉnh Q: PHÂN GIÁC của KHE GÓC RỘNG NHẤT giữa các cạnh
// đi ra từ Q (ds-ke = các đỉnh kề, toạ độ toán 2D) — nhãn không đè lên cạnh
// nào. Tính trên TOẠ ĐỘ TRANG nên đúng cả khi hai trục khác tỉ lệ.
// Trả vectơ (dx, dy) trên trang (y hướng XUỐNG) — đúng dạng `huong` của `nhan`.
#let _huong-khe(ctx, Q, ds-ke) = {
  let q = toa-pt(ctx, Q)
  let gs = ()
  for R in ds-ke {
    let r = toa-pt(ctx, R)
    let dx = r.at(0) - q.at(0)
    let dy = r.at(1) - q.at(1)
    if calc.sqrt(dx * dx + dy * dy) > 1e-6 { gs.push(calc.atan2(dx, dy).deg()) }
  }
  if gs.len() == 0 { return (0, -1) }
  let gs = gs.sorted()
  let n = gs.len()
  let khe = -1.0
  let giua = 0.0
  for i in range(n) {
    let a = gs.at(i)
    let b = if i + 1 < n { gs.at(i + 1) } else { gs.at(0) + 360 }
    if b - a > khe {
      khe = b - a
      giua = (a + b) / 2
    }
  }
  let g = giua * 1deg
  (calc.cos(g), calc.sin(g))
}

// Hướng nhãn TOẢ RA XA tâm hình chiếu (cho điểm KHÔNG nằm trên cạnh nào).
#let _huong-xa(Q, C2) = {
  let dx = Q.at(0) - C2.at(0)
  let dy = Q.at(1) - C2.at(1)
  let l = calc.sqrt(dx * dx + dy * dy)
  if l < 1e-9 { (0, -1) } else { (dx / l, -dy / l) }
}

// ---------------------------------------------------------------------
// CHE BỞI CHÍNH KHỐI — kiểm CHÍNH XÁC (không quét mẫu, không cần z-buffer):
// tia đi từ P về phía người nhìn có cắt khối LỒI hay không. Giao đoạn tham
// số t của tia với mọi nửa không gian của khối rồi xem còn t > 0 nào không.
// Nhất quán với quy tắc nét khuất của cạnh: điểm trên một mặt TRƯỚC thì
// KHÔNG bị che; điểm trong khối hoặc trên mặt SAU thì bị che.
// ---------------------------------------------------------------------
#let _bi-khoi-che(P, e, mat-tt) = {
  let lo = -1e9
  let hi = 1e9
  for f in mat-tt {
    let df = v3-vo-huong(f.phap, e)
    let f0 = v3-vo-huong(f.phap, P) - v3-vo-huong(f.phap, f.tam)
    if calc.abs(df) < 1e-12 {
      if f0 > 1e-9 { return false }   // ở ngoài một mặt song song tia nhìn
    } else if df > 0 {
      hi = calc.min(hi, -f0 / df)
    } else {
      lo = calc.max(lo, -f0 / df)
    }
  }
  calc.max(lo, 1e-6) <= hi - 1e-9
}

// Vẽ ĐOẠN PHỤ trong/quanh khối, TỰ phân loại nét: phần bị khối che vẽ ĐỨT,
// phần thấy vẽ LIỀN (một đoạn có thể vừa liền vừa đứt — vd đường cao SO
// xuất phát từ đỉnh S thấy được rồi chui vào trong khối).
#let _doan-tu-dong(
  ctx, p, e, mat-tt, A, B,
  n: 160, mau: black, day: 1pt,
  hien-khuat: true, mau-khuat: auto, day-khuat: auto, dut: auto,
) = {
  if dut != auto {
    doan(ctx, p(A), p(B), mau: mau, day: day, dut: dut)
    return
  }
  let moc = ()
  let tt = none
  let dau = 0.0
  for st in range(n) {
    let che = _bi-khoi-che(chia-3d(A, B, (st + 0.5) / n), e, mat-tt)
    if tt == none {
      tt = che
    } else if che != tt {
      moc.push((dau, st / n, tt))
      tt = che
      dau = st / n
    }
  }
  moc.push((dau, 1.0, tt))
  for (u, v, che) in moc {
    if che and not hien-khuat { continue }
    doan(
      ctx, p(chia-3d(A, B, u)), p(chia-3d(A, B, v)),
      mau: if not che or mau-khuat == auto { mau } else { mau-khuat },
      day: if not che or day-khuat == auto { day } else { day-khuat },
      dut: che,
    )
  }
}

// Cạnh của khối CHỨA điểm P (nếu có) — trả phần tử của `.canh`, hoặc none.
#let _canh-chua(dinh, canh, P, eps: 1e-6) = {
  for c in canh {
    let A = dinh.at(c.i)
    let B = dinh.at(c.j)
    let AB = v3-tru(B, A)
    let L2 = v3-vo-huong(AB, AB)
    if L2 < 1e-12 { continue }
    let t = v3-vo-huong(v3-tru(P, A), AB) / L2
    if t < -eps or t > 1 + eps { continue }
    let H = chia-3d(A, B, calc.max(0.0, calc.min(1.0, t)))
    if v3-dai(v3-tru(P, H)) < eps { return c }
  }
  none
}

// Nhận dạng một điểm 3D trần (mảng 3 số) — phân biệt với mục (P, ten, ...).
#let _la-diem3(x) = (
  type(x) == array and x.len() == 3 and type(x.at(0)) != array
)

// ---------- Tiện ích dựng điểm (TRẢ GIÁ TRỊ) ----------
// Điểm chia cạnh nối đỉnh thứ i và thứ j của khối (t = 0 tại i, 1 tại j).
#let diem-canh(dinh, i, j, t: 0.5) = chia-3d(dinh.at(i), dinh.at(j), t)
// Hình chiếu vuông góc của P lên ĐƯỜNG THẲNG AB.
#let hinh-chieu-3d(P, A, B) = {
  let AB = v3-tru(B, A)
  let L2 = v3-vo-huong(AB, AB)
  if L2 < 1e-12 { A } else {
    v3-cong(A, v3-nhan(v3-vo-huong(v3-tru(P, A), AB) / L2, AB))
  }
}
// Hình chiếu vuông góc của P lên MẶT PHẲNG mp = (n: pháp đơn vị, d:).
#let hinh-chieu-mp(P, mp) = v3-tru(P, v3-nhan(v3-vo-huong(mp.n, P) - mp.d, mp.n))

// =====================================================================
// VẼ KHỐI ĐA DIỆN trong khung có sẵn (nhận ctx ⇒ KÊ vào ve-voi)
//   dinh   mảng điểm 3D · mat mảng mặt (mảng chỉ số đỉnh)
//   ten    mảng nhãn theo thứ tự đỉnh (none = không ghi)
//   huong  auto = toả ra từ tâm hình chiếu · hoặc mảng hướng từng đỉnh
//   to     màu tô CÁC MẶT TRƯỚC (vẽ xa -> gần) · to-mat mảng màu riêng
//   diem   ĐIỂM PHỤ (trung điểm cạnh, chân đường cao…): mỗi mục là
//          P · (P, ten) · (P, ten, huong) · (P, ten, huong, mau).
//          Điểm nằm TRÊN CẠNH: nhãn tự đặt VUÔNG GÓC với cạnh đó; điểm bị
//          khối che thì `hien-khuat: false` sẽ ẩn luôn.
//   duong  ĐOẠN PHỤ (đường cao, hình chiếu…): mỗi mục là (A, B) hoặc
//          (A, B, tuỳ-chọn) với tuỳ-chọn là dict nhận mau/day/ten/tai/huong/
//          cach/dut/hien-khuat/mau-khuat/day-khuat/vuong/r. Phần đoạn bị khối
//          che TỰ vẽ đứt. `vuong: C` = ký hiệu góc vuông tại B, giữa BA và BC.
//   them   (ctx, p) => ... với p là hàm chiếu (x, y, z) -> điểm 2D
// =====================================================================
#let ve-da-dien(
  ctx,
  dinh: (), mat: (),
  cam: auto,
  ten: none, huong: auto, cach: 6pt, mau-ten: black,
  hien-dinh: true, bk: 1.6pt,
  mau: black, day: 1.1pt,
  mau-khuat: auto, day-khuat: auto, hien-khuat: true,
  to: none, to-mat: none,
  diem: (), duong: (), mau-diem: auto, bk-diem: 1.8pt,
  them: none,
) = {
  let pt = phan-tich-khoi(dinh, mat, cam: cam)
  let d2 = pt.d2
  // ---- tô mặt trước, xa vẽ trước (painter's algorithm)
  if to != none or to-mat != none {
    let thu-tu = range(pt.mat.len()).sorted(key: i => pt.mat.at(i).sau)
    for i in thu-tu {
      let f = pt.mat.at(i)
      if not f.truoc { continue }
      let c = if to-mat == none { to } else {
        let v = to-mat.at(i, default: auto)
        if v == auto { to } else { v }
      }
      if c != none {
        da-giac-pt(f.chi-so.map(k => toa-pt(ctx, d2.at(k))), to: c)
      }
    }
  }
  // ---- cạnh khuất (vẽ trước) rồi cạnh liền
  for lan in (false, true) {
    for c in pt.canh {
      if c.hien != lan { continue }
      if not c.hien and not hien-khuat { continue }
      doan(
        ctx, d2.at(c.i), d2.at(c.j),
        mau: if c.hien or mau-khuat == auto { mau } else { mau-khuat },
        day: if c.hien or day-khuat == auto { day } else { day-khuat },
        dut: not c.hien,
      )
    }
  }
  // ---- đoạn phụ (đường cao, hình chiếu…): tự liền/đứt theo khối
  let p = pt.cam.p
  let e = pt.cam.nhin
  for m in duong {
    let A = m.at(0)
    let B = m.at(1)
    let tc = if m.len() > 2 { m.at(2) } else { (:) }
    let mc = tc.at("mau", default: mau)
    let hk = tc.at("hien-khuat", default: hien-khuat)
    _doan-tu-dong(
      ctx, p, e, pt.mat, A, B,
      mau: mc, day: tc.at("day", default: day),
      hien-khuat: hk,
      mau-khuat: tc.at("mau-khuat", default: mau-khuat),
      day-khuat: tc.at("day-khuat", default: day-khuat),
      dut: tc.at("dut", default: auto),
    )
    // ẩn nét khuất thì bỏ luôn ký hiệu góc vuông / nhãn ở chỗ bị khối che
    if "vuong" in tc and (hk or not _bi-khoi-che(B, e, pt.mat)) {
      goc-vuong(
        ctx, p(B), p(A), p(tc.at("vuong")),
        r: tc.at("r", default: 0.3), mau: mc, day: 0.8pt,
      )
    }
    if tc.at("ten", default: none) != none {
      let M = chia-3d(A, B, tc.at("tai", default: 0.5))
      let hg = tc.at("huong", default: auto)
      if hk or not _bi-khoi-che(M, e, pt.mat) {
        nhan(
          ctx, p(M), tc.at("ten"),
          huong: if hg == auto { _phap-tuyen(ctx, p(A), p(B)) } else { hg },
          cach: tc.at("cach", default: cach), mau: mc,
        )
      }
    }
  }
  // ---- đỉnh + nhãn
  // đỉnh kề (chỉ tính theo các cạnh ĐƯỢC VẼ) để đặt nhãn vào khe trống
  let ke = (:)
  for c in pt.canh {
    if not c.hien and not hien-khuat { continue }
    ke.insert(str(c.i), ke.at(str(c.i), default: ()) + (c.j,))
    ke.insert(str(c.j), ke.at(str(c.j), default: ()) + (c.i,))
  }
  for i in range(dinh.len()) {
    // ẩn nét khuất thì ẩn luôn đỉnh chỉ thuộc các mặt sau
    if not hien-khuat and not pt.mat.any(f => f.truoc and i in f.chi-so) { continue }
    let t = if ten == none { none } else { ten.at(i, default: none) }
    let hg = if huong == auto {
      _huong-khe(ctx, d2.at(i), ke.at(str(i), default: ()).map(j => d2.at(j)))
    } else { huong.at(i, default: "above") }
    if hien-dinh {
      _ve-diem(ctx, d2.at(i), ten: t, huong: hg, bk: bk, cach: cach, mau: mau, mau-ten: mau-ten)
    } else if t != none {
      nhan(ctx, d2.at(i), t, huong: hg, cach: cach, mau: mau-ten)
    }
  }
  // ---- điểm phụ: nhãn tự đặt vuông góc với cạnh chứa nó
  let C2 = (
    d2.map(q => q.at(0)).sum() / d2.len(),
    d2.map(q => q.at(1)).sum() / d2.len(),
  )
  for m in diem {
    let (P, t, hg, mc) = if _la-diem3(m) { (m, none, auto, auto) } else {
      (m.at(0), m.at(1, default: none), m.at(2, default: auto), m.at(3, default: auto))
    }
    if not hien-khuat and _bi-khoi-che(P, e, pt.mat) { continue }
    let c = _canh-chua(dinh, pt.canh, P)
    let h = if hg != auto { hg } else if c != none {
      _huong-khe(ctx, p(P), (d2.at(c.i), d2.at(c.j)))
    } else { _huong-xa(p(P), C2) }
    let m2 = if mc != auto { mc } else if mau-diem == auto { mau } else { mau-diem }
    _ve-diem(ctx, p(P), ten: t, huong: h, bk: bk-diem, cach: cach, mau: m2, mau-ten: m2)
  }
  if them != none { them(ctx, p) }
}

// Các điểm 3D phụ (từ `diem`/`duong`) — để cửa sổ bao luôn phần chìa ra ngoài.
#let _diem-phu(diem, duong) = {
  let ds = ()
  for m in diem { ds.push(if _la-diem3(m) { m } else { m.at(0) }) }
  for m in duong {
    ds.push(m.at(0))
    ds.push(m.at(1))
    if m.len() > 2 and "vuong" in m.at(2) { ds.push(m.at(2).at("vuong")) }
  }
  ds
}

// Bản TỰ TẠO KHUNG (không nhận ctx ⇒ KHÔNG kê vào ve-voi).
#let da-dien(
  dinh: (), mat: (),
  cam: auto, w: 7cm, le: 0.75, co-chu: 10pt,
  diem: (), duong: (),
  ..dt,
) = {
  let cm = _cam(cam)
  let cs = _cs2((dinh + _diem-phu(diem, duong)).map(cm.p), mg: le)
  hinh(
    w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    co-chu: co-chu,
    ctx => ve-da-dien(
      ctx, dinh: dinh, mat: mat, cam: cm, diem: diem, duong: duong, ..dt,
    ),
  )
}

// =====================================================================
// KHỐI DỰNG SẴN — TRẢ (dinh:, mat:, ten:), dùng với toán tử `..`
//   #da-dien(..khoi-lang-tru-deu(n: 6, R: 1.8, cao: 3.4), to: blue.lighten(88%))
// =====================================================================
#let _chu = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "K", "L", "M")
#let _ten-day(n, phay: false) = range(n).map(i => {
  let t = _chu.at(calc.rem(i, _chu.len()))
  eval(if phay { t + "'" } else { t }, mode: "math")
})
// Pha mặc định của đa giác đều: đỉnh A rơi ra phía trước-trái.
#let _pha(n) = if n == 4 { 225deg } else { 210deg }
// Mảng đỉnh đa giác đều n cạnh, tâm trên trục Oz, bán kính R, cao z.
#let day-deu(n, R, z: 0, pha: auto) = {
  let ph = if pha == auto { _pha(n) } else { pha }
  range(n).map(i => {
    let a = ph + i * 360deg / n
    (R * calc.cos(a), R * calc.sin(a), z)
  })
}

// Hình chóp: đáy là mảng điểm 3D bất kì (đa giác lồi), đỉnh S.
#let khoi-chop(day, S, ten: auto) = {
  let n = day.len()
  (
    dinh: day + (S,),
    mat: (range(n),) + range(n).map(i => (i, calc.rem(i + 1, n), n)),
    ten: if ten == auto { _ten-day(n) + ($S$,) } else { ten },
  )
}
// Lăng trụ: đáy `day` tịnh tiến theo vectơ v (đáy trên ghi dấu phẩy).
#let khoi-lang-tru(day, v, ten: auto) = {
  let n = day.len()
  let tren = day.map(P => v3-cong(P, v))
  (
    dinh: day + tren,
    mat: (range(n), range(n).map(i => i + n))
      + range(n).map(i => {
        let j = calc.rem(i + 1, n)
        (i, j, j + n, i + n)
      }),
    ten: if ten == auto { _ten-day(n) + _ten-day(n, phay: true) } else { ten },
  )
}
// Chóp cụt: hai đáy CÙNG số đỉnh, tương ứng theo thứ tự.
#let khoi-chop-cut(day, day-tren, ten: auto) = {
  let n = day.len()
  (
    dinh: day + day-tren,
    mat: (range(n), range(n).map(i => i + n))
      + range(n).map(i => {
        let j = calc.rem(i + 1, n)
        (i, j, j + n, i + n)
      }),
    ten: if ten == auto { _ten-day(n) + _ten-day(n, phay: true) } else { ten },
  )
}
// Hình hộp tổng quát: đỉnh A + ba vectơ cạnh u, v, w.
#let khoi-hop(A, u, v, w, ten: auto) = khoi-lang-tru(
  (A, v3-cong(A, u), v3-cong(v3-cong(A, u), v), v3-cong(A, v)),
  w,
  ten: ten,
)

#let khoi-chop-deu(n: 4, R: 2, cao: 3.6, pha: auto, ten: auto) = khoi-chop(
  day-deu(n, R, pha: pha), (0, 0, cao), ten: ten,
)
#let khoi-lang-tru-deu(n: 6, R: 1.8, cao: 3.4, pha: auto, ten: auto) = khoi-lang-tru(
  day-deu(n, R, pha: pha), (0, 0, cao), ten: ten,
)
#let khoi-chop-cut-deu(n: 4, R: 2, r: 1.1, cao: 3, pha: auto, ten: auto) = khoi-chop-cut(
  day-deu(n, R, pha: pha), day-deu(n, r, z: cao, pha: pha), ten: ten,
)
#let khoi-hop-chu-nhat(dai: 4, rong: 2.6, cao: 3, ten: auto) = khoi-hop(
  (0, 0, 0), (dai, 0, 0), (0, rong, 0), (0, 0, cao), ten: ten,
)
#let khoi-lap-phuong(a: 3, ten: auto) = khoi-hop-chu-nhat(
  dai: a, rong: a, cao: a, ten: ten,
)
// Tứ diện đều cạnh a: đáy đều bán kính a/√3, chiều cao a·√(2/3).
// `pha` = góc quay ĐÁY. Mặc định 270° (từ 0.3.5; các bản trước là 210°):
// A ra TRÁI, C ra PHẢI, B ra TRƯỚC-DƯỚI, D trên đỉnh, cạnh khuất là AC —
// bốn mặt đều "thoáng", không mặt nào bị nhìn nghiêng thành nét mỏng.
// Dáng đẹp nhất khi xem bằng `cam: chieu-truc-giao(ngang: 25deg, cao: 25deg)`.
// Muốn dáng CŨ thì đặt `pha: 210deg` (hoặc `pha: auto` — lấy pha chung của
// đa giác đều 3 cạnh).
// ⚠️ ĐỪNG dùng `chieu-xien` với k·cos(goc) ≈ 1/√3 = 0.577 (vd goc: 15deg,
// k: 0.6): hai đỉnh đáy chồng lên nhau trên trang, một mặt co lại thành nét.
#let khoi-tu-dien-deu(a: 3, pha: 270deg, ten: auto) = khoi-chop(
  day-deu(3, a / calc.sqrt(3), pha: pha),
  (0, 0, a * calc.sqrt(2 / 3)),
  ten: if ten == auto { ($A$, $B$, $C$, $D$) } else { ten },
)
// Bát diện đều cạnh a: 6 đỉnh (±s, 0, 0), (0, ±s, 0), (0, 0, ±s), s = a/√2.
#let khoi-bat-dien-deu(a: 3, ten: auto) = {
  let s = a / calc.sqrt(2)
  (
    dinh: ((s, 0, 0), (0, s, 0), (-s, 0, 0), (0, -s, 0), (0, 0, s), (0, 0, -s)),
    mat: (
      (0, 1, 4), (1, 2, 4), (2, 3, 4), (3, 0, 4),
      (0, 1, 5), (1, 2, 5), (2, 3, 5), (3, 0, 5),
    ),
    ten: if ten == auto { ($A$, $B$, $C$, $D$, $S$, $S'$) } else { ten },
  )
}

// =====================================================================
// MẶT PHẲNG
//   mp = (n: pháp tuyến ĐƠN VỊ, d: hằng số)  ⇔  n · P = d
// =====================================================================
#let mp-qua-phap(P, n) = {
  let u = v3-chuan(n)
  (n: u, d: v3-vo-huong(u, P))
}
#let mp-qua-3-diem(A, B, C) = mp-qua-phap(A, v3-co-huong(v3-tru(B, A), v3-tru(C, A)))
// Mặt phẳng cắt ba trục tại (a,0,0), (0,b,0), (0,0,c): x/a + y/b + z/c = 1.
#let mp-cat-truc(a, b, c) = mp-qua-3-diem((a, 0, 0), (0, b, 0), (0, 0, c))
// Mặt phẳng song song với mp, đi qua P.
#let mp-song-song(mp, P) = (n: mp.n, d: v3-vo-huong(mp.n, P))

// Điểm 2D có nằm trong đa giác LỒI (mảng điểm 2D) hay không.
#let _trong-dg2(q, dg) = {
  let duong = false
  let am = false
  let n = dg.len()
  for i in range(n) {
    let A = dg.at(i)
    let B = dg.at(calc.rem(i + 1, n))
    let c = (
      (B.at(0) - A.at(0)) * (q.at(1) - A.at(1))
        - (B.at(1) - A.at(1)) * (q.at(0) - A.at(0))
    )
    if c > 1e-9 { duong = true }
    if c < -1e-9 { am = true }
  }
  not (duong and am)
}

// Vẽ ĐỨT phần đoạn AB (3D) bị đa giác `dg3` che: nằm SAU mặt phẳng chứa
// đa giác VÀ hình chiếu rơi vào trong đa giác. Quét mẫu nên đúng với mọi
// cấu hình (đoạn cắt ngang mặt phẳng, ló ra hai đầu…).
#let _dut-bi-che(ctx, p, nhin, dg3, A, B, n: 240, mau: black, day: 0.9pt) = {
  let dg2 = dg3.map(p)
  let nm = phap-da-giac(dg3)
  let d0 = v3-vo-huong(nm, dg3.at(0))
  // người nhìn ở phía f > 0 nếu nm cùng hướng nhìn; điểm SAU mặt phẳng: f·phia < 0
  let phia = if v3-vo-huong(nm, nhin) >= 0 { 1 } else { -1 }
  let dai = ()
  let dau = none
  for s in range(n + 1) {
    let t = s / n
    let P = chia-3d(A, B, t)
    let f = (v3-vo-huong(nm, P) - d0) * phia
    let che = f < -1e-9 and _trong-dg2(p(P), dg2)
    if che and dau == none { dau = t }
    if not che and dau != none {
      dai.push((dau, t))
      dau = none
    }
  }
  if dau != none { dai.push((dau, 1)) }
  for (u, v) in dai {
    doan(ctx, p(chia-3d(A, B, u)), p(chia-3d(A, B, v)), mau: mau, day: day, dut: true)
  }
}

// ---------------------------------------------------------------------
// Vẽ MỘT MẶT PHẲNG (đa giác phẳng 3D) — lõi chung, nhận ctx.
//   p     hàm chiếu (x, y, z) -> 2D (vd t3 của #oxyz)
//   dinh3 mảng đỉnh 3D của đa giác biểu diễn mặt phẳng
//   che   mảng đoạn 3D ((A, B), ...) sẽ được vẽ ĐỨT ở phần bị mặt phẳng che
// ---------------------------------------------------------------------
#let mat-phang(
  ctx, p, dinh3,
  to: auto, mau: blue.darken(15%), day: 1pt, dut: false,
  ten: none, ten-tai: 0, huong: "above-left", cach: 5pt,
  che: (), mau-che: black, day-che: 0.9pt,
  nhin: auto,
  them: none,
) = {
  let e = if nhin == auto { _nhin(p) } else { nhin }
  let d2 = dinh3.map(p)
  let mau-to = if to == auto { rgb(80, 140, 220, 46) } else { to }
  if mau-to != none { da-giac-pt(d2.map(q => toa-pt(ctx, q)), to: mau-to) }
  let n = d2.len()
  for i in range(n) {
    doan(ctx, d2.at(i), d2.at(calc.rem(i + 1, n)), mau: mau, day: day, dut: dut)
  }
  for (A, B) in che {
    _dut-bi-che(ctx, p, e, dinh3, A, B, mau: mau-che, day: day-che)
  }
  if ten != none {
    nhan(ctx, d2.at(calc.rem(ten-tai, n)), ten, huong: huong, cach: cach, mau: mau)
  }
  if them != none { them(ctx, p) }
}

// ---------------------------------------------------------------------
// MẶT PHẲNG CẮT BA TRỤC trong hệ #oxyz — tam giác A(a,0,0) B(0,b,0) C(0,0,c),
// tự vẽ ĐỨT phần ba trục toạ độ nằm SAU mặt phẳng (bị mặt phẳng che).
//   #oxyz(x: 5, y: 6, z: 5, them: (ctx, t3) => {
//     mat-phang-oxyz(ctx, t3, 4, 5, 3, ten-dinh: true, ten: $(P)$)
//   })
// `truc: auto` tự lấy phạm vi (0 -> mốc cắt trục); truyền tuple 3 khoảng để
// đổi, vd truc: ((-1, 5), (-1, 6), (-1, 5)); truc: none = không xử lí nét đứt.
// ---------------------------------------------------------------------
#let mat-phang-oxyz(
  ctx, t3, a, b, c,
  to: auto, mau: blue.darken(15%), day: 1pt, dut: false,
  ten: none, ten-tai: 0, huong: "above-left", cach: 5pt,
  ten-dinh: false, ten-abc: ($A$, $B$, $C$), hien-dinh: true, bk: 1.8pt,
  truc: auto, mau-che: black, day-che: 0.9pt,
  them: none,
) = {
  let A = (a, 0, 0)
  let B = (0, b, 0)
  let C = (0, 0, c)
  let ds-truc = if truc == none { () } else if truc == auto {
    (((0, 0, 0), A), ((0, 0, 0), B), ((0, 0, 0), C))
  } else {
    (
      ((truc.at(0).at(0), 0, 0), (truc.at(0).at(1), 0, 0)),
      ((0, truc.at(1).at(0), 0), (0, truc.at(1).at(1), 0)),
      ((0, 0, truc.at(2).at(0)), (0, 0, truc.at(2).at(1))),
    )
  }
  mat-phang(
    ctx, t3, (A, B, C),
    to: to, mau: mau, day: day, dut: dut,
    ten: ten, ten-tai: ten-tai, huong: huong, cach: cach,
    che: ds-truc, mau-che: mau-che, day-che: day-che,
  )
  if ten-dinh or hien-dinh {
    let bo = ((A, ten-abc.at(0), "below-left"), (B, ten-abc.at(1), "below-right"), (C, ten-abc.at(2), "above-right"))
    for (P, t, h) in bo {
      diem(
        ctx, t3(P),
        ten: if ten-dinh { t } else { none },
        huong: h, bk: if hien-dinh { bk } else { 0pt }, cach: 5pt, mau: mau,
      )
    }
  }
  if them != none { them(ctx, t3) }
}

// ---------------------------------------------------------------------
// MẶT PHẲNG "LƠ LỬNG" dạng hình bình hành: tâm `tam`, hai nửa-vectơ u, v
// (4 đỉnh = tam ± u ± v). Ba trục toạ độ đi sau nó cũng tự vẽ đứt.
//   mat-phang-bh(ctx, t3, (2, 2, 2), (2.4, 0, 0), (0, 2.4, 0), ten: $(alpha)$)
// ---------------------------------------------------------------------
#let mat-phang-bh(
  ctx, t3, tam, u, v,
  to: auto, mau: blue.darken(15%), day: 1pt, dut: false,
  ten: none, ten-tai: 1, huong: "above-right", cach: 5pt,
  truc: none, mau-che: black, day-che: 0.9pt,
  them: none,
) = {
  let dinh3 = (
    v3-tru(v3-tru(tam, u), v),
    v3-tru(v3-cong(tam, u), v),
    v3-cong(v3-cong(tam, u), v),
    v3-cong(v3-tru(tam, u), v),
  )
  let ds-truc = if truc == none or truc == auto { () } else {
    (
      ((truc.at(0).at(0), 0, 0), (truc.at(0).at(1), 0, 0)),
      ((0, truc.at(1).at(0), 0), (0, truc.at(1).at(1), 0)),
      ((0, 0, truc.at(2).at(0)), (0, 0, truc.at(2).at(1))),
    )
  }
  mat-phang(
    ctx, t3, dinh3,
    to: to, mau: mau, day: day, dut: dut,
    ten: ten, ten-tai: ten-tai, huong: huong, cach: cach,
    che: ds-truc, mau-che: mau-che, day-che: day-che,
    them: them,
  )
}

// =====================================================================
// THIẾT DIỆN — cắt khối LỒI bởi một mặt phẳng
// thiet-dien TRẢ VỀ mảng điểm 3D đã SẮP THEO VÒNG (rỗng nếu không cắt).
// Cách làm: lấy mọi giao điểm của mặt phẳng với các CẠNH của khối (kể cả
// đỉnh nằm đúng trên mặt phẳng), bỏ điểm trùng, rồi sắp theo GÓC quanh tâm
// trong hệ hai vectơ của mặt phẳng — thiết diện của khối lồi là đa giác lồi
// nên phép sắp theo góc cho đúng thứ tự vòng.
// =====================================================================
#let thiet-dien(dinh, mat, mp, eps: 1e-7) = {
  let f = P => v3-vo-huong(mp.n, P) - mp.d
  let bang = (:)
  for m in mat {
    for (i, j) in _canh-vong(m) {
      bang.insert(_khoa(i, j), (calc.min(i, j), calc.max(i, j)))
    }
  }
  let ds = ()
  for (i, j) in bang.values() {
    let A = dinh.at(i)
    let B = dinh.at(j)
    let fa = f(A)
    let fb = f(B)
    if calc.abs(fa) < eps { ds.push(A) }
    if calc.abs(fb) < eps { ds.push(B) }
    if calc.abs(fa) >= eps and calc.abs(fb) >= eps and fa * fb < 0 {
      ds.push(chia-3d(A, B, fa / (fa - fb)))
    }
  }
  let kq = ()
  for P in ds {
    if not kq.any(Q => v3-dai(v3-tru(P, Q)) < 1e-6) { kq.push(P) }
  }
  if kq.len() < 3 { return () }
  let T = tam-3d(kq)
  let u = v3-chuan(v3-tru(kq.at(0), T))
  let v = v3-co-huong(mp.n, u)
  kq.sorted(key: P => {
    let w = v3-tru(P, T)
    calc.atan2(v3-vo-huong(w, u), v3-vo-huong(w, v)).deg()
  })
}

// Vẽ thiết diện TRÊN một khối: tô miền + viền LIỀN ở phần nằm trên mặt
// THẤY, ĐỨT ở phần nằm trên mặt KHUẤT (nhận ctx ⇒ kê vào ve-voi).
//   ve-thiet-dien(ctx, dinh: d, mat: m, mp: mp-qua-3-diem(P, Q, R))
#let ve-thiet-dien(
  ctx,
  dinh: (), mat: (), mp: none,
  cam: auto,
  to: auto, mau: red.darken(10%), day: 1.1pt,
  hien-khuat: true, mau-khuat: auto, day-khuat: auto,
  ten: none, huong: auto, cach: 6pt, hien-dinh: true, bk: 1.8pt, mau-ten: auto,
  them: none,
) = {
  let pt = phan-tich-khoi(dinh, mat, cam: cam)
  let p = pt.cam.p
  let dd = thiet-dien(dinh, mat, mp)
  if dd.len() < 3 { return }
  let d2 = dd.map(p)
  let mau-to = if to == auto { rgb(220, 70, 70, 40) } else { to }
  if mau-to != none { da-giac-pt(d2.map(q => toa-pt(ctx, q)), to: mau-to) }
  let n = dd.len()
  for i in range(n) {
    let j = calc.rem(i + 1, n)
    let M = trung-diem-3d(dd.at(i), dd.at(j))
    // cạnh thiết diện nằm trên mặt nào? thấy nếu có một mặt CHỨA nó là mặt trước
    let hien = pt.mat.any(f => (
      calc.abs(v3-vo-huong(f.phap, M) - v3-vo-huong(f.phap, f.tam)) < 1e-5 and f.truoc
    ))
    if not hien and not hien-khuat { continue }
    doan(
      ctx, d2.at(i), d2.at(j),
      mau: if hien or mau-khuat == auto { mau } else { mau-khuat },
      day: if hien or day-khuat == auto { day } else { day-khuat },
      dut: not hien,
    )
  }
  for i in range(n) {
    let t = if ten == none { none } else { ten.at(i, default: none) }
    let hg = if huong == auto {
      _huong-khe(ctx, d2.at(i), (d2.at(calc.rem(i + n - 1, n)), d2.at(calc.rem(i + 1, n))))
    } else { huong.at(i, default: "above") }
    if hien-dinh {
      diem(ctx, d2.at(i), ten: t, huong: hg, bk: bk, cach: cach, mau: mau, mau-ten: if mau-ten == auto { mau } else { mau-ten })
    } else if t != none {
      nhan(ctx, d2.at(i), t, huong: hg, cach: cach, mau: if mau-ten == auto { mau } else { mau-ten })
    }
  }
  if them != none { them(ctx, p) }
}

// Khối + thiết diện trong MỘT lệnh, tự tạo khung (không nhận ctx).
#let da-dien-thiet-dien(
  dinh: (), mat: (), mp: none,
  cam: auto, w: 7cm, le: 0.75, co-chu: 10pt,
  ten: none, huong: auto,
  mau: black, day: 1.1pt, to: none, to-mat: none,
  hien-khuat: true, hien-dinh: true, mau-ten: black,
  diem: (), duong: (), mau-diem: auto, bk-diem: 1.8pt,
  td: (:),          // tuỳ chọn riêng cho thiết diện (mau, to, ten, …)
  them: none,
) = {
  let cm = _cam(cam)
  let cs = _cs2((dinh + _diem-phu(diem, duong)).map(cm.p), mg: le)
  hinh(
    w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    co-chu: co-chu,
    ctx => {
      ve-da-dien(
        ctx, dinh: dinh, mat: mat, cam: cm,
        ten: ten, huong: huong, mau: mau, day: day, to: to, to-mat: to-mat,
        hien-khuat: hien-khuat, hien-dinh: hien-dinh, mau-ten: mau-ten,
        diem: diem, duong: duong, mau-diem: mau-diem, bk-diem: bk-diem,
      )
      if mp != none {
        ve-thiet-dien(ctx, dinh: dinh, mat: mat, mp: mp, cam: cm, ..td)
      }
      if them != none { them(ctx, cm.p) }
    },
  )
}
