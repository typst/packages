// =====================================================================
// do-thi.typ — ĐỒ THỊ HÀM SỐ THPT
// Hệ trục, lưới, vạch chia, đường gióng + các đồ thị dựng sẵn:
// bậc nhất, bậc hai, bậc ba, trùng phương, phân thức b1/b1, hữu tỉ b2/b1,
// mũ, lôgarit, sin/cos/tan, căn thức.
//
// CỬA SỔ THÔNG MINH: khung nhìn tự tính từ các điểm then chốt
// (cực trị, điểm uốn, tâm đối xứng, tiệm cận, giao trục) và luôn chứa gốc O.
//
// THAM SỐ NHÃN CHUNG cho các đồ thị dựng sẵn:
//   cuc-tri : auto  = gióng cực trị vào 2 trục + nhãn tự động
//             none  = không gióng
//             (x: "below", y: "left")  = đổi hướng nhãn (mọi điểm)
//             ((x:.., y:..), (x:.., y:..), ...) = hướng riêng từng điểm
//                                                 (thứ tự x tăng dần)
//   giao-ox : none | auto | "below" | ("below", "above", ...) — nhãn giao Ox
//   giao-oy : none | auto | "left"                            — nhãn giao Oy
//   Hướng nhãn (tiếng Anh): above, below, left, right,
//   above-left, above-right, below-left, below-right.
//   Tiệm cận (nếu có) LUÔN được vẽ kèm nhãn trên trục.
//   goc-ten : vị trí nhãn tên hàm — "above-right" (mặc định) | "above-left"
//             | "below-left" | "below-right" | (x, y) toạ độ tuỳ ý
//   dan-x, dan-y : co/giãn cửa sổ quanh tâm theo từng trục —
//             > 1 phóng to (đơn vị lớn hơn), < 1 thu nhỏ (thấy vùng rộng hơn)
// Mỗi đồ thị dựng sẵn có `them: ctx => ...` để vẽ chồng nội dung tuỳ ý.
// =====================================================================
#import "ve.typ": *

// Định dạng số gọn: 2 -> "2", 2.50 -> "2.5"
#let so-dep(v) = {
  let r = calc.round(v, digits: 2)
  if calc.fract(r) == 0 { str(int(r)) } else { str(r) }
}

// Nhãn toán "đẹp": nhận dạng số nguyên, phân số p/q (q ≤ 20),
// căn thức k√n (n ≤ 50), dạng a ± k√n (ví dụ 1 + √2).
// Không khớp thì trả về số thập phân.
#let so-toan(v) = {
  let eps = 0.0001
  if calc.abs(v - calc.round(v)) < eps { return $#int(calc.round(v))$ }
  for q in range(2, 21) {
    let p = calc.round(v * q)
    if calc.abs(v - p / q) < eps and calc.gcd(int(calc.abs(p)), q) == 1 {
      let p = int(p)
      return if p < 0 { $- #(-p) / #q$ } else { $#p / #q$ }
    }
  }
  // phân số mẫu LỚN (vd 283/27 — giá trị cực trị bậc ba, mẫu 27a²):
  // khớp CHẶT (1e-9) nên không "nhận nhầm" số vô tỉ thành phân số.
  for q in range(21, 401) {
    let p = calc.round(v * q)
    if calc.abs(v - p / q) < 1e-9 and calc.gcd(int(calc.abs(p)), q) == 1 {
      let p = int(p)
      return if p < 0 { $- #(-p) / #q$ } else { $#p / #q$ }
    }
  }
  for n in range(2, 51) {
    let r = calc.sqrt(n)
    for k in range(1, 6) {
      if calc.abs(calc.abs(v) - k * r) < eps {
        let ct = if k == 1 { $sqrt(#[#n])$ } else { $#k sqrt(#[#n])$ }
        return if v < 0 { $-#ct$ } else { ct }
      }
    }
  }
  for n in range(2, 31) {
    let cn = calc.sqrt(n)
    if calc.abs(cn - calc.round(cn)) < eps { continue }
    for k in range(1, 4) {
      let ct = if k == 1 { $sqrt(#[#n])$ } else { $#k sqrt(#[#n])$ }
      let du = v - k * cn   // v = a + k√n ?
      if calc.abs(du - calc.round(du)) < eps and calc.abs(du) > eps and calc.abs(calc.round(du)) <= 12 {
        return $#int(calc.round(du)) + #ct$
      }
      let du = v + k * cn   // v = a - k√n ?
      if calc.abs(du - calc.round(du)) < eps and calc.abs(du) > eps and calc.abs(calc.round(du)) <= 12 {
        return $#int(calc.round(du)) - #ct$
      }
    }
  }
  // dạng (m ± √n)/q — nghiệm phương trình bậc hai (vd (1+√7)/3, √3/2)
  for q in range(2, 13) {
    let t = v * q
    let m0 = int(calc.round(t))
    for dm in range(-16, 17) {
      let m = m0 + dm
      let s = t - m           // s = ±√n
      let n = calc.round(s * s)
      if n >= 2 and n <= 400 and calc.abs(s * s - n) < 0.00001 {
        let cn = calc.sqrt(n)
        if calc.abs(cn - calc.round(cn)) < eps { continue }   // n chính phương -> hữu tỉ, đã xét
        // rút thừa số chính phương: √96 -> 4√6
        let n = int(n)
        let k = 1
        let j = 2
        while j * j <= n {
          if calc.rem(n, j * j) == 0 { k = j }
          j = j + 1
        }
        let n = int(n / (k * k))
        let ct = if k == 1 { $sqrt(#[#n])$ } else { $#k sqrt(#[#n])$ }
        return if m == 0 {
          if s > 0 { $#ct / #q$ } else { $- #ct / #q$ }
        } else if s > 0 { $(#m + #ct) / #q$ } else { $(#m - #ct) / #q$ }
      }
    }
  }
  $#so-dep(v)$
}

// Căn thức CHÍNH XÁC: hiển thị (P + K·√n)/Q từ các thành phần đã biết
// (P, K, Q gần-nguyên; n hữu tỉ ≥ 0). Tự chuẩn hoá n hữu tỉ (√(u/den) =
// √(u·den)/den), rút thừa số chính phương, rút gọn gcd(P, K, Q).
// Không "đẹp" được thì rơi về so-toan(giá trị số) — không tệ hơn trước.
#let so-can-thuc(P, K, n, Q) = {
  let eps = 0.000001
  let gan-int(x) = calc.abs(x - calc.round(x)) < eps * calc.max(1, calc.abs(x))
  if Q == 0 or n < -eps { return $#so-dep(0)$ }   // phòng hờ (không xảy ra)
  let gia = (P + K * calc.sqrt(calc.max(n, 0))) / Q
  // chuẩn hoá n về nguyên: (P + K√(u/den))/Q = (P·den + K√(u·den))/(Q·den)
  let cap = if gan-int(n) { (calc.round(n), P, Q) } else {
    let ket = none
    for den in range(2, 21) {
      if gan-int(n * den) {
        ket = (calc.round(n * den) * den, P * den, Q * den)
        break
      }
    }
    ket
  }
  if cap == none { return so-toan(gia) }
  let (n, P, Q) = cap
  if not (gan-int(P) and gan-int(K) and gan-int(Q)) { return so-toan(gia) }
  let P = int(calc.round(P))
  let K = int(calc.round(K))
  let Q = int(calc.round(Q))
  let n = int(calc.round(n))
  if Q < 0 { P = -P; K = -K; Q = -Q }
  // rút thừa số chính phương: √96 -> 4√6
  if K != 0 and n > 1 {
    let j = 2
    let h = 1
    while j * j <= n {
      if calc.rem(n, j * j) == 0 { h = j }
      j = j + 1
    }
    K = K * h
    n = int(n / (h * h))
  }
  if n == 1 { P = P + K; K = 0 }
  if K == 0 or n == 0 {
    // hữu tỉ P/Q chính xác
    let g = calc.max(calc.gcd(calc.abs(P), Q), 1)
    let (P, Q) = (int(P / g), int(Q / g))
    return if Q == 1 { $#P$ } else if P < 0 { $- #(-P) / #Q$ } else { $#P / #Q$ }
  }
  let g = calc.max(calc.gcd(calc.gcd(calc.abs(P), calc.abs(K)), Q), 1)
  let (P, K, Q) = (int(P / g), int(K / g), int(Q / g))
  let ct = if calc.abs(K) == 1 { $sqrt(#[#n])$ } else { $#calc.abs(K) sqrt(#[#n])$ }
  if Q == 1 {
    if P == 0 { if K > 0 { ct } else { $-#ct$ } }
    else if K > 0 { $#P + #ct$ } else { $#P - #ct$ }
  } else {
    if P == 0 { if K > 0 { $#ct / #Q$ } else { $- #ct / #Q$ } }
    else if K > 0 { $(#P + #ct) / #Q$ } else { $(#P - #ct) / #Q$ }
  }
}

// ---- Cực trị CHÍNH XÁC theo hệ số (dùng chung cho bang.typ + khao-sat.typ) ----
// Bậc ba y = ax³+bx²+cx+d, Δ' = b²−3ac > 0: trả (x1:, y1:, x2:, y2:) với
// x1 < x2. x = (−b ∓ σ√Δ')/(3a), σ = sign(a);
// y = (P0 ± 2σΔ'√Δ')/(27a²), P0 = 2b³ − 9abc + 27a²d (chia đa thức f cho f').
#let cuc-tri-bac-ba(a, b, c, d) = {
  let delta = b * b - 3 * a * c
  let sg = if a > 0 { 1 } else { -1 }
  let P0 = 2 * b * b * b - 9 * a * b * c + 27 * a * a * d
  (
    x1: so-can-thuc(-b, -sg, delta, 3 * a),
    y1: so-can-thuc(P0, 2 * sg * delta, delta, 27 * a * a),
    x2: so-can-thuc(-b, sg, delta, 3 * a),
    y2: so-can-thuc(P0, -2 * sg * delta, delta, 27 * a * a),
  )
}
// Hữu tỉ y = (ax²+bx+c)/(dx+e) có 2 cực trị: E = ae² − bde + cd² (E/a > 0),
// x = (−e ∓ σ√(E/a))/d, σ = sign(d); tại cực trị y = (2ax+b)/d
// ⇒ y = (bd − 2ae ∓ 2aσ√(E/a))/d², x1 < x2.
#let cuc-tri-huu-ti(a, b, c, d, e) = {
  let E = a * e * e - b * d * e + c * d * d
  let sg = if d > 0 { 1 } else { -1 }
  (
    x1: so-can-thuc(-e, -sg, E / a, d),
    y1: so-can-thuc(b * d - 2 * a * e, -2 * a * sg, E / a, d * d),
    x2: so-can-thuc(-e, sg, E / a, d),
    y2: so-can-thuc(b * d - 2 * a * e, 2 * a * sg, E / a, d * d),
  )
}

// Nội dung "y = px + q" rút gọn (nhãn tiệm cận xiên).
#let _pt-bac-nhat(p, q) = {
  let hs = if calc.abs(p - 1) < 0.001 { $x$ } else if calc.abs(p + 1) < 0.001 { $-x$ } else { $#so-toan(p) x$ }
  if calc.abs(q) < 0.001 { $y = #hs$ } else if q > 0 { $y = #hs + #so-toan(q)$ } else { $y = #hs - #so-toan(-q)$ }
}

// ---------- Đạo hàm số & tiếp tuyến ----------
// Đạo hàm của f tại x bằng sai phân trung tâm (đủ chính xác để vẽ hình).
//   let k = dao-ham(f, 1)     // hệ số góc tiếp tuyến tại x = 1
#let dao-ham(f, x, h: auto) = {
  let b = if h == auto { 0.0001 * calc.max(1, calc.abs(x)) } else { h }
  (f(x + b) - f(x - b)) / (2 * b)
}

// TIẾP TUYẾN của đồ thị y = f(x) tại điểm có hoành độ x0 (hoặc DÃY hoành độ).
// Hệ số góc lấy bằng đạo hàm số nên dùng được cho MỌI hàm f viết bằng closure.
//   tiep-tuyen(f, 1)                                  // tiếp tuyến tại x = 1
//   tiep-tuyen(f, (-1, 2), mau: green)                // nhiều tiếp điểm
//   tiep-tuyen(f, 1, ten: auto)                       // tự ghi y = kx + m
//   tiep-tuyen(f, 1, ten: $Delta$, ten-diem: $M$)     // đặt tên tuỳ ý
// Tham số:
//   dai   : auto = kéo hết bề ngang khung (tự cắt gọn theo cửa sổ);
//           số   = nửa độ dài đoạn tiếp tuyến theo trục Ox quanh tiếp điểm
//   cham  : chấm tiếp điểm · ten-diem/huong-diem: nhãn tiếp điểm
//   ten   : nhãn đường tiếp tuyến (auto = phương trình y = kx + m rút gọn)
//   tai/huong-ten/cach/ten-quay: vị trí & kiểu nhãn (như `ten:` của `doan`)
//   giong : true = kẻ đường gióng đứt từ tiếp điểm về 2 trục
#let tiep-tuyen(
  ctx, f, x0,
  mau: red, day: 1.2pt, dut: false, dai: auto,
  cham: true, mau-cham: auto, ten-diem: none, huong-diem: "above-left",
  ten: none, tai: 0.9, huong-ten: auto, cach: 6pt, ten-quay: false,
  giong: false, h: auto,
) = {
  for x in (if type(x0) == array { x0 } else { (x0,) }) {
    let y = f(x)
    let k = dao-ham(f, x, h: h)
    let tt = u => y + k * (u - x)
    // hai đầu đoạn tiếp tuyến: cắt gọn trong cửa sổ hoặc theo `dai`
    let (X1, X2) = if dai != auto { (x - dai, x + dai) } else if calc.abs(k) > 0.0001 {
      let ca = ((ctx.ymin - y) / k + x, (ctx.ymax - y) / k + x).sorted()
      (calc.max(ctx.xmin, ca.at(0)), calc.min(ctx.xmax, ca.at(1)))
    } else { (ctx.xmin, ctx.xmax) }
    if X2 - X1 > 0.0001 {
      doan(
        ctx, (X1, tt(X1)), (X2, tt(X2)),
        mau: mau, day: day, dut: dut,
        ten: if ten == auto { _pt-bac-nhat(k, y - k * x) } else { ten },
        tai: tai, huong: huong-ten, cach: cach, ten-quay: ten-quay, mau-ten: mau,
      )
    }
    if giong {
      doan(ctx, (x, y), (x, 0), mau: gray.darken(20%), day: 0.8pt, dut: true)
      doan(ctx, (x, y), (0, y), mau: gray.darken(20%), day: 0.8pt, dut: true)
    }
    if cham {
      diem(ctx, (x, y), bk: 2.2pt, mau: if mau-cham == auto { mau } else { mau-cham },
        ten: ten-diem, huong: huong-diem)
    }
  }
}

// ---------- Hệ trục Oxy ----------
#let truc(ctx, ten-x: $x$, ten-y: $y$, ten-goc: $O$, mau: black, day: 0.9pt) = {
  mui-ten(ctx, (ctx.xmin, 0), (ctx.xmax, 0), mau: mau, day: day)
  mui-ten(ctx, (0, ctx.ymin), (0, ctx.ymax), mau: mau, day: day)
  nhan(ctx, (ctx.xmax, 0), ten-x, huong: "below", cach: 5pt)
  nhan(ctx, (0, ctx.ymax), ten-y, huong: "left", cach: 5pt)
  if ten-goc != none { nhan(ctx, (0, 0), ten-goc, huong: "below-left", cach: 4pt) }
}

// Lưới ô vuông mờ.
#let luoi(ctx, buoc: 1, mau: luma(87%), day: 0.5pt) = {
  let x = calc.ceil(ctx.xmin / buoc) * buoc
  while x <= ctx.xmax + 0.0001 {
    doan(ctx, (x, ctx.ymin), (x, ctx.ymax), mau: mau, day: day)
    x = x + buoc
  }
  let y = calc.ceil(ctx.ymin / buoc) * buoc
  while y <= ctx.ymax + 0.0001 {
    doan(ctx, (ctx.xmin, y), (ctx.xmax, y), mau: mau, day: day)
    y = y + buoc
  }
}

// Vạch chia + số trên hai trục (bỏ qua 0).
#let vach-chia(ctx, buoc-x: 1, buoc-y: 1, so: true, mau: black) = {
  let t = 3pt / ctx.sy   // nửa chiều dài vạch, đổi sang đơn vị toạ độ
  let x = calc.ceil((ctx.xmin + 0.3) / buoc-x) * buoc-x
  while x <= ctx.xmax - 0.3 {
    if calc.abs(x) > 0.0001 {
      doan(ctx, (x, -t), (x, t), mau: mau, day: 0.8pt)
      if so { nhan(ctx, (x, 0), $#so-dep(x)$, huong: "below", cach: 4pt) }
    }
    x = x + buoc-x
  }
  let s = 3pt / ctx.sx
  let y = calc.ceil((ctx.ymin + 0.3) / buoc-y) * buoc-y
  while y <= ctx.ymax - 0.3 {
    if calc.abs(y) > 0.0001 {
      doan(ctx, (-s, y), (s, y), mau: mau, day: 0.8pt)
      if so { nhan(ctx, (0, y), $#so-dep(y)$, huong: "left", cach: 4pt) }
    }
    y = y + buoc-y
  }
}

// Hệ trục TRỌN GÓI: lưới + trục + vạch chia + số — một lệnh thay ba.
//   #hinh(xmin: -4, xmax: 4, ymin: -3, ymax: 3, ctx => { he-truc(ctx) ... })
//   luoi-o: lưới ô vuông mờ · vach: vạch chia đơn vị · so: ghi số trên vạch
#let he-truc(
  ctx,
  ten-x: $x$, ten-y: $y$, ten-goc: $O$,
  luoi-o: true, buoc-luoi: auto,     // auto = theo buoc-x
  vach: true, so: true, buoc-x: 1, buoc-y: 1,
  mau: black, day: 0.9pt, mau-luoi: luma(87%),
) = {
  if luoi-o {
    luoi(ctx, buoc: if buoc-luoi == auto { buoc-x } else { buoc-luoi }, mau: mau-luoi)
  }
  truc(ctx, ten-x: ten-x, ten-y: ten-y, ten-goc: ten-goc, mau: mau, day: day)
  if vach { vach-chia(ctx, buoc-x: buoc-x, buoc-y: buoc-y, so: so) }
}

// Đường gióng từ điểm P về 2 trục (nét đứt) + nhãn toạ độ trên trục.
// ten-x / ten-y: auto = tự ghi số; none = không ghi; hoặc nội dung tuỳ ý.
#let giong(
  ctx, P,
  ten-x: auto, ten-y: auto,
  huong-x: "below", huong-y: "left",
  mau: gray.darken(20%), mau-diem: red, diem-to: true,
) = {
  // điểm nằm ngay trên một trục thì bỏ đường gióng (tránh đè lên trục)
  if calc.abs(P.at(0)) > 0.0001 and calc.abs(P.at(1)) > 0.0001 {
    doan(ctx, P, (P.at(0), 0), mau: mau, day: 0.8pt, dut: true)
    doan(ctx, P, (0, P.at(1)), mau: mau, day: 0.8pt, dut: true)
  }
  if diem-to { diem(ctx, P, bk: 1.9pt, mau: mau-diem) }
  if ten-x != none and calc.abs(P.at(0)) > 0.0001 {
    let tx = if ten-x == auto { so-toan(P.at(0)) } else { ten-x }
    nhan(ctx, (P.at(0), 0), tx, huong: huong-x, cach: 4pt)
  }
  if ten-y != none and calc.abs(P.at(1)) > 0.0001 {
    let ty = if ten-y == auto { so-toan(P.at(1)) } else { ten-y }
    nhan(ctx, (0, P.at(1)), ty, huong: huong-y, cach: 4pt)
  }
}

// ---------- Bộ trợ giúp cửa sổ & nhãn (dùng nội bộ) ----------
// Cửa sổ thông minh: bao các "điểm chốt" + gốc O, thêm lề tương xứng,
// bảo đảm kích thước tối thiểu.
#let _cua-so(diem-chot, le: 0.16, rong-min: 4.2, cao-min: 3.4, goc: true) = {
  let pts = diem-chot
  if goc { pts = pts + ((0, 0),) }
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let (x1, x2) = (calc.min(..xs), calc.max(..xs))
  let (y1, y2) = (calc.min(..ys), calc.max(..ys))
  let px = calc.max((x2 - x1) * le, 0.65)
  let py = calc.max((y2 - y1) * le, 0.6)
  let (xa, xb, ya, yb) = (x1 - px, x2 + px, y1 - py, y2 + py)
  if xb - xa < rong-min {
    let t = (rong-min - (xb - xa)) / 2
    xa = xa - t
    xb = xb + t
  }
  if yb - ya < cao-min {
    let t = (cao-min - (yb - ya)) / 2
    ya = ya - t
    yb = yb + t
  }
  (xmin: xa, xmax: xb, ymin: ya, ymax: yb)
}

// Nghiệm của f trên [a, b] bằng chia đôi (chỉ bắt nghiệm đổi dấu).
#let _nghiem(f, a, b, n: 160) = {
  let kq = ()
  let m = lay-mau(f, a, b, n: n)
  for i in range(n) {
    let (x1, y1) = m.at(i)
    let (x2, y2) = m.at(i + 1)
    if y1 * y2 <= 0 and (y1 != 0 or y2 != 0) {
      let (lo, hi) = (x1, x2)
      for _ in range(36) {
        let g = (lo + hi) / 2
        if f(lo) * f(g) <= 0 { hi = g } else { lo = g }
      }
      let x = (lo + hi) / 2
      if kq.len() == 0 or x - kq.last() > (b - a) / n * 1.5 { kq.push(x) }
    }
  }
  kq
}

// Lấy hướng thứ i từ tuỳ chọn none|auto|chuỗi|tuple chuỗi.
#let _huong-i(tuy-chon, i, mac-dinh) = {
  if type(tuy-chon) == str { tuy-chon } else if type(tuy-chon) == array and i < tuy-chon.len() { tuy-chon.at(i) } else { mac-dinh }
}

// Gióng điểm cực trị thứ i theo tuỳ chọn cuc-tri (xem đầu file).
// ten-x/ten-y: nhãn CHÍNH XÁC (căn thức/phân số) tính sẵn từ hệ số — dùng khi
// người dùng không tự đặt tên; auto = lấy số từ toạ độ (so-toan).
#let _giong-ct(ctx, P, tuy-chon, i, ten-x: auto, ten-y: auto) = {
  if tuy-chon == none or tuy-chon == false { return }
  let o = if type(tuy-chon) == array {
    if i < tuy-chon.len() { tuy-chon.at(i) } else { (:) }
  } else if type(tuy-chon) == dictionary { tuy-chon } else { (:) }
  giong(
    ctx, P,
    huong-x: o.at("x", default: "below"),
    huong-y: o.at("y", default: "left"),
    ten-x: o.at("ten-x", default: ten-x),
    ten-y: o.at("ten-y", default: ten-y),
  )
}

// Nhãn các giao điểm với Ox (cac-x: mảng hoành độ đã tính sẵn).
// ten: mảng nhãn CHÍNH XÁC song song với cac-x (thiếu thì tự lấy so-toan).
#let _nhan-giao-ox(ctx, cac-x, tuy-chon, ten: ()) = {
  if tuy-chon == none { return }
  let le = (ctx.xmax - ctx.xmin) * 0.02
  let i = 0
  let j = 0
  for x in cac-x {
    // giao điểm trùng gốc O thì bỏ qua hẳn
    if x >= ctx.xmin + le and x <= ctx.xmax - le and calc.abs(x) > 0.001 {
      diem(ctx, (x, 0), bk: 1.9pt, mau: red)
      let nd = if j < ten.len() { ten.at(j) } else { so-toan(x) }
      nhan(ctx, (x, 0), nd, huong: _huong-i(tuy-chon, i, "below"), cach: 4pt)
      i = i + 1
    }
    j = j + 1
  }
}

// Nhãn giao điểm với Oy (y = f(0)).
#let _nhan-giao-oy(ctx, y, tuy-chon) = {
  if tuy-chon == none or y == none { return }
  // giao điểm trùng gốc O thì bỏ qua hẳn
  if y < ctx.ymin or y > ctx.ymax or ctx.xmin > 0 or ctx.xmax < 0 or calc.abs(y) <= 0.001 { return }
  diem(ctx, (0, y), bk: 1.9pt, mau: red)
  nhan(ctx, (0, y), so-toan(y), huong: _huong-i(tuy-chon, 0, "left"), cach: 4pt)
}

// Chuẩn hoá true/false cũ về auto/none.
#let _chuan-tc(t) = if t == true { auto } else if t == false { none } else { t }

// Nhãn tên hàm đặt ở 1 trong 4 góc hoặc toạ độ (x, y) tuỳ ý.
//   goc-ten: "above-right" (mặc định) | "above-left" | "below-left"
//            | "below-right" | (x, y)
#let _nhan-ten(ctx, ten, goc, mau) = {
  if ten == none { return }
  let dx = ctx.xmax - ctx.xmin
  let dy = ctx.ymax - ctx.ymin
  let P = if type(goc) == array { goc } else {
    (
      above-right: (ctx.xmax - dx * 0.14, ctx.ymax - dy * 0.09),
      above-left: (ctx.xmin + dx * 0.14, ctx.ymax - dy * 0.09),
      below-left: (ctx.xmin + dx * 0.14, ctx.ymin + dy * 0.09),
      below-right: (ctx.xmax - dx * 0.14, ctx.ymin + dy * 0.09),
    ).at(goc, default: (ctx.xmax - dx * 0.14, ctx.ymax - dy * 0.09))
  }
  // nền trắng để đường cong không xuyên qua nhãn
  nhan(ctx, P, box(fill: white, inset: (x: 2.5pt, y: 1pt), radius: 1.5pt, ten), huong: "center", mau: mau)
}

// Co/giãn cửa sổ quanh tâm: dan > 1 phóng to (đơn vị trục lớn hơn),
// dan < 1 thu nhỏ (nhìn được vùng rộng hơn). Dùng khi đơn vị quá lớn/bé.
#let _dan(cs, dan-x, dan-y) = {
  if dan-x == 1 and dan-y == 1 { return cs }
  let cx = (cs.xmin + cs.xmax) / 2
  let cy = (cs.ymin + cs.ymax) / 2
  let hx = (cs.xmax - cs.xmin) / 2 / dan-x
  let hy = (cs.ymax - cs.ymin) / 2 / dan-y
  (xmin: cx - hx, xmax: cx + hx, ymin: cy - hy, ymax: cy + hy)
}

// ---------- Đồ thị tổng quát ----------
// Vẽ hàm f bất kỳ trên hệ trục hoàn chỉnh, tự tạo khung.
#let do-thi-ham(
  f,
  w: 8cm, h: auto,
  xmin: -4, xmax: 4, ymin: -3, ymax: 3,
  tu: auto, den: auto,
  mau: blue, day: 1.4pt, n: 150,
  ten: none,        // nhãn hàm (vd $y = x^2$)
  goc-ten: "above-right",   // vị trí nhãn: 4 góc hoặc toạ độ (x, y)
  luoi-o: false,
  vach: false,      // true => vạch chia bước 1
  dan-x: 1, dan-y: 1,   // co/giãn cửa sổ quanh tâm (xem đầu file)
  them: none,       // ctx => nội dung vẽ thêm
) = {
  let hh = if h == auto { w * 0.68 } else { h }
  let cs = _dan((xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax), dan-x, dan-y)
  hinh(w: w, h: hh, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax, ctx => {
    if luoi-o { luoi(ctx) }
    truc(ctx)    
    if vach { vach-chia(ctx) }
    ve-ham(ctx, f, tu: tu, den: den, n: n, mau: mau, day: day,)
    _nhan-ten(ctx, ten, goc-ten, mau)
    if them != none { them(ctx) }
  })
}

// ---------- Bậc nhất: y = ax + b ----------
#let do-thi-bac-nhat(
  a, b,
  w: 7cm, mau: blue, ten: auto, goc-ten: "above-right",
  giao-ox: auto, giao-oy: auto, giao-truc: true,
  luoi-o: false, vach: false,
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let f = x => a * x + b
  let chot = ((0, b),)
  if a != 0 { chot = chot + ((-b / a, 0),) }
  let cs = _dan(_cua-so(chot, rong-min: 4.6), dan-x, dan-y)
  do-thi-ham(
    f,
    w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    mau: mau, luoi-o: luoi-o, vach: vach,
    ten: if ten == auto { none } else { ten },
    goc-ten: goc-ten,
    them: ctx => {
      if giao-truc {
        if a != 0 { _nhan-giao-ox(ctx, (-b / a,), giao-ox) }
        _nhan-giao-oy(ctx, b, giao-oy)
      }
      if them != none { them(ctx) }
    },
  )
}

// ---------- Bậc hai: y = ax² + bx + c ----------
// Cửa sổ tự tính từ đỉnh + giao trục.
#let do-thi-bac-hai(
  a, b, c,
  w: 7.6cm, mau: blue, ten: none, goc-ten: "above-right",
  dinh: auto,        // gióng đỉnh: auto | none | (x: "below", y: "left")
  giao-ox: auto, giao-oy: auto,
  truc-dx: false,    // trục đối xứng
  luoi-o: false, vach: false,
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let f = x => a * x * x + b * x + c
  let xv = -b / (2 * a)
  let yv = c - b * b / (4 * a)
  let dinh = _chuan-tc(dinh)
  // điểm chốt: đỉnh, giao Oy, giao Ox (nếu có)
  let chot = ((xv, yv), (0, c))
  let dlt = b * b - 4 * a * c
  let ng = ()
  if dlt > 0 {
    let s = calc.sqrt(dlt) / (2 * calc.abs(a))
    ng = (xv - s, xv + s)
    chot = chot + ((xv - s, 0), (xv + s, 0))
  }
  // cánh parabol: mở cửa sổ theo bề ngang các điểm chốt
  let xs = chot.map(p => p.at(0)) + (0,)
  let mien = calc.max(calc.max(..xs) - calc.min(..xs), 3.0)
  let (e1, e2) = (f(xv - 0.62 * mien), f(xv + 0.62 * mien))
  let ye = if a > 0 { calc.min(e1, e2) } else { calc.max(e1, e2) }
  let cs = _dan(_cua-so(chot + ((xv - 0.62 * mien, ye), (xv + 0.62 * mien, ye)), rong-min: 4.6), dan-x, dan-y)
  do-thi-ham(
    f,
    w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    mau: mau, ten: ten, goc-ten: goc-ten, luoi-o: luoi-o, vach: vach,
    them: ctx => {
      if truc-dx and calc.abs(xv) > 0.001 {
        doan(ctx, (xv, cs.ymin), (xv, cs.ymax), mau: red, day: 0.8pt, dut: true)
      }
      _giong-ct(
        ctx, (xv, yv), dinh, 0,
        ten-x: so-can-thuc(-b, 0, 0, 2 * a),
        ten-y: so-can-thuc(4 * a * c - b * b, 0, 0, 4 * a),
      )
      _nhan-giao-ox(
        ctx, ng, giao-ox,
        ten: if dlt > 0 {
          let sg = if a > 0 { 1 } else { -1 }
          (so-can-thuc(-b, -sg, dlt, 2 * a), so-can-thuc(-b, sg, dlt, 2 * a))
        } else { () },
      )
      _nhan-giao-oy(ctx, c, giao-oy)
      if them != none { them(ctx) }
    },
  )
}

// ---------- Bậc ba: y = ax³ + bx² + cx + d ----------
// Cửa sổ tự tính từ 2 cực trị (nếu có) hoặc điểm uốn (nếu không).
#let do-thi-bac-ba(
  a, b, c, d,
  w: 7.6cm, mau: blue, ten: none, goc-ten: "above-right",
  cuc-tri: auto,     // gióng 2 điểm cực trị (nếu có)
  diem-uon: none,    // gióng điểm uốn: none | auto | (x:.., y:..)
  giao-ox: none, giao-oy: none,
  luoi-o: false, vach: false,
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let f = x => ((a * x + b) * x + c) * x + d
  let delta = b * b - 3 * a * c
  let tam = -b / (3 * a)
  let cuc-tri = _chuan-tc(cuc-tri)
  let (x1, x2) = (none, none)
  let chot = ((tam, f(tam)),)
  if delta > 0 {
    let s = calc.sqrt(delta) / (3 * calc.abs(a))
    x1 = tam - s
    x2 = tam + s
    chot = chot + (
      (x1, f(x1)), (x2, f(x2)),
      (tam - 2.1 * s, f(tam - 2.1 * s)), (tam + 2.1 * s, f(tam + 2.1 * s)),
    )
  } else {
    // không cực trị: bán kính quanh điểm uốn sao cho biến thiên y vừa mắt
    let m = c - b * b / (3 * a)
    let bien = t => calc.abs(a * t * t * t + m * t)
    let r = 1.0
    while bien(r) < 4 and r < 6 { r = r * 1.25 }
    while bien(r) > 7 and r > 0.9 { r = r / 1.15 }
    chot = chot + ((tam - r, f(tam - r)), (tam + r, f(tam + r)))
  }
  // giao Ox (tìm số) chỉ khi cần nhãn
  let ng = if giao-ox != none {
    let bk = 1 + calc.max(calc.abs(b), calc.abs(c), calc.abs(d)) / calc.abs(a)
    _nghiem(f, tam - calc.min(bk, 12), tam + calc.min(bk, 12))
  } else { () }
  let cs = _dan(_cua-so(chot + ng.map(x => (x, 0))), dan-x, dan-y)
  do-thi-ham(
    f,
    w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    mau: mau, ten: ten, goc-ten: goc-ten, n: 180, luoi-o: luoi-o, vach: vach,
    them: ctx => {
      if x1 != none {
        // giá trị cực trị CHÍNH XÁC (phân số/căn thức) thay vì số thập phân
        let ct = cuc-tri-bac-ba(a, b, c, d)
        _giong-ct(ctx, (x1, f(x1)), cuc-tri, 0, ten-x: ct.x1, ten-y: ct.y1)
        _giong-ct(ctx, (x2, f(x2)), cuc-tri, 1, ten-x: ct.x2, ten-y: ct.y2)
      }
      _giong-ct(
        ctx, (tam, f(tam)), diem-uon, 0,
        ten-x: so-can-thuc(-b, 0, 0, 3 * a),
        ten-y: so-can-thuc(2 * b * b * b - 9 * a * b * c + 27 * a * a * d, 0, 0, 27 * a * a),
      )
      _nhan-giao-ox(ctx, ng, giao-ox)
      _nhan-giao-oy(ctx, d, giao-oy)
      if them != none { them(ctx) }
    },
  )
}

// ---------- Trùng phương: y = ax⁴ + bx² + c ----------
// Cửa sổ tự tính từ 3 cực trị (a·b < 0) hoặc 1 cực trị (0, c).
#let do-thi-trung-phuong(
  a, b, c,
  w: 7.6cm, mau: blue, ten: none, goc-ten: "above-right",
  cuc-tri: auto,
  giao-ox: none, giao-oy: none,
  luoi-o: false, vach: false,
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let f = x => a * calc.pow(x, 4) + b * x * x + c
  let co-3ct = a * b < 0
  let cuc-tri = _chuan-tc(cuc-tri)
  let xc = if co-3ct { calc.sqrt(-b / (2 * a)) } else { 0 }
  let chot = ((0, c),)
  if co-3ct {
    chot = chot + (
      (xc, f(xc)), (-xc, f(xc)),
      (1.45 * xc, f(1.45 * xc)), (-1.45 * xc, f(1.45 * xc)),
    )
  } else {
    let bien = t => calc.abs(f(t) - c)
    let r = 1.0
    while bien(r) < 4 and r < 5 { r = r * 1.25 }
    while bien(r) > 7 and r > 0.8 { r = r / 1.15 }
    chot = chot + ((r, f(r)), (-r, f(r)))
  }
  let ng = if giao-ox != none {
    let xs = chot.map(p => p.at(0))
    _nghiem(f, calc.min(..xs) - 0.5, calc.max(..xs) + 0.5)
  } else { () }
  let cs = _dan(_cua-so(chot + ng.map(x => (x, 0))), dan-x, dan-y)
  do-thi-ham(
    f,
    w: w, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    mau: mau, ten: ten, goc-ten: goc-ten, n: 180, luoi-o: luoi-o, vach: vach,
    them: ctx => {
      if cuc-tri != none {
        if co-3ct {
          let Xc = so-can-thuc(0, 1, -b / (2 * a), 1)
          let nXc = so-can-thuc(0, -1, -b / (2 * a), 1)
          let Yc = so-can-thuc(4 * a * c - b * b, 0, 0, 4 * a)
          _giong-ct(ctx, (-xc, f(xc)), cuc-tri, 0, ten-x: nXc, ten-y: Yc)
          _giong-ct(ctx, (0, c), cuc-tri, 1)
          _giong-ct(ctx, (xc, f(xc)), cuc-tri, 2, ten-x: Xc, ten-y: Yc)
        } else {
          _giong-ct(ctx, (0, c), cuc-tri, 0)
        }
      }
      _nhan-giao-ox(ctx, ng, giao-ox)
      _nhan-giao-oy(ctx, c, giao-oy)
      if them != none { them(ctx) }
    },
  )
}

// ---------- Phân thức bậc nhất/bậc nhất: y = (ax + b)/(cx + d) ----------
// Hai nhánh hypebol; tiệm cận LUÔN vẽ + nhãn trên trục.
// Cửa sổ tự tính từ tâm đối xứng (x0, y0), giao trục và gốc O.
#let do-thi-phan-thuc(
  a, b, c, d,
  w: 7.6cm, mau: blue, ten: none, goc-ten: "above-right",
  giao-ox: none, giao-oy: none,
  huong-x0: "below-left", huong-y0: "above-left",   // hướng nhãn 2 tiệm cận
  luoi-o: false, vach: false,
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let x0 = -d / c       // tiệm cận đứng
  let y0 = a / c        // tiệm cận ngang
  let f = x => (a * x + b) / (c * x + d)
  let chot = ((x0, y0), (x0 - 1.7, y0 - 1.7), (x0 + 1.7, y0 + 1.7))
  if a != 0 { chot = chot + ((-b / a, 0),) }
  if d != 0 { chot = chot + ((0, b / d),) }
  let cs = _dan(_cua-so(chot, le: 0.2), dan-x, dan-y)
  hinh(
    w: w, h: w * 0.74,
    xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    ctx => {
      if luoi-o { luoi(ctx) }
      truc(ctx)
      if vach { vach-chia(ctx) }
      // tiệm cận + nhãn trên trục
      doan(ctx, (x0, cs.ymin), (x0, cs.ymax), mau: red, day: 0.9pt, dut: true)
      doan(ctx, (cs.xmin, y0), (cs.xmax, y0), mau: red, day: 0.9pt, dut: true)
      if calc.abs(x0) > 0.001 { nhan(ctx, (x0, 0), so-can-thuc(-d, 0, 0, c), huong: huong-x0, cach: 4pt) }
      if calc.abs(y0) > 0.001 { nhan(ctx, (0, y0), so-can-thuc(a, 0, 0, c), huong: huong-y0, cach: 4pt) }
      // hai nhánh
      let g = (cs.xmax - cs.xmin) * 0.012
      ve-ham(ctx, f, tu: cs.xmin, den: x0 - g, n: 130, mau: mau)
      ve-ham(ctx, f, tu: x0 + g, den: cs.xmax, n: 130, mau: mau)
      if a != 0 { _nhan-giao-ox(ctx, (-b / a,), giao-ox) }
      if d != 0 { _nhan-giao-oy(ctx, b / d, giao-oy) }
      _nhan-ten(ctx, ten, goc-ten, mau)
      if them != none { them(ctx) }
    },
  )
}

// ---------- Hữu tỉ bậc hai/bậc nhất: y = (ax² + bx + c)/(dx + e) ----------
// Tự nhận 4 tình huống: (a/d > 0 hay < 0) × (có 2 cực trị hay không).
// Có cực trị  -> cửa sổ bao 2 điểm cực trị (+ gióng nhãn).
// Không cực trị -> cửa sổ quanh tâm đối xứng (giao 2 tiệm cận).
// LUÔN vẽ tiệm cận đứng x = x0 (nhãn trên Ox) và tiệm cận xiên
// y = px + q (nhãn ten-tcx: auto = "y = px + q" | none | nội dung tuỳ ý).
#let do-thi-huu-ti(
  a, b, c, d, e,
  w: 7.6cm, mau: blue, ten: none, goc-ten: "above-right",
  dan-x: 1, dan-y: 1,
  cuc-tri: auto,
  tam: auto,         // gióng tâm đối xứng I(x0, px0+q) + nhãn:
                     // auto = chỉ khi không có cực trị | true/(x:..,y:..) = luôn | none = tắt
  giao-ox: none, giao-oy: none,
  huong-x0: "below-right",          // hướng nhãn tiệm cận đứng trên Ox
  ten-tcx: auto, huong-tcx: "above-left",   // nhãn tiệm cận xiên
  luoi-o: false, vach: false,
  them: none,
) = {
  let x0 = -e / d                    // tiệm cận đứng
  let p = a / d                      // tiệm cận xiên y = px + q
  let q = (b * d - a * e) / (d * d)
  let r = c - q * e                  // y = px + q + r/(dx + e)
  let f = x => (a * x * x + b * x + c) / (d * x + e)
  let tcx = x => p * x + q
  let cuc-tri = _chuan-tc(cuc-tri)
  let co-ct = p != 0 and r * d * p > 0
  let hien-tam = if tam == none { false } else if tam == auto { not co-ct } else { true }
  let (xt1, xt2) = (none, none)
  let chot = ((x0, tcx(x0)),)
  if co-ct {
    let t = calc.sqrt(r * d / p)
    let xs = ((-e - t) / d, (-e + t) / d).sorted()
    xt1 = xs.at(0)
    xt2 = xs.at(1)
    let s = xt2 - xt1
    chot = chot + (
      (xt1, f(xt1)), (xt2, f(xt2)),
      (xt1 - 0.55 * s, f(xt1 - 0.55 * s)), (xt2 + 0.55 * s, f(xt2 + 0.55 * s)),
    )
  } else {
    // không cực trị: mở quanh tâm sao cho nhánh tách rõ khỏi tiệm cận
    let t = calc.max(calc.min(calc.abs(r / (2 * d)), 3), 0.9)
    chot = chot + (
      (x0 - t, f(x0 - t)), (x0 + t, f(x0 + t)),
      (x0 - 2.4 * t, f(x0 - 2.4 * t)), (x0 + 2.4 * t, f(x0 + 2.4 * t)),
    )
  }
  // giao Ox: nghiệm tử thức (nếu cần nhãn)
  let ng = if giao-ox != none and b * b - 4 * a * c > 0 {
    let s = calc.sqrt(b * b - 4 * a * c) / (2 * calc.abs(a))
    (-b / (2 * a) - s, -b / (2 * a) + s)
  } else { () }
  let cs = _dan(_cua-so(chot + ng.map(x => (x, 0)), le: 0.14), dan-x, dan-y)
  hinh(
    w: w, h: w * 0.78,
    xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax,
    ctx => {
      if luoi-o { luoi(ctx) }
      truc(ctx)
      if vach { vach-chia(ctx) }
      // tiệm cận đứng (khi gióng tâm thì nhãn x0 do gióng đảm nhiệm, tránh ghi 2 lần)
      doan(ctx, (x0, cs.ymin), (x0, cs.ymax), mau: red, day: 0.9pt, dut: true)
      if calc.abs(x0) > 0.001 and not hien-tam { nhan(ctx, (x0, 0), so-can-thuc(-e, 0, 0, d), huong: huong-x0, cach: 4pt) }
      // tiệm cận xiên (cắt gọn trong cửa sổ)
      let (X1, X2) = if calc.abs(p) > 0.0001 {
        let ca = ((cs.ymin - q) / p, (cs.ymax - q) / p).sorted()
        (calc.max(cs.xmin, ca.at(0)), calc.min(cs.xmax, ca.at(1)))
      } else { (cs.xmin, cs.xmax) }
      doan(ctx, (X1, tcx(X1)), (X2, tcx(X2)), mau: red, day: 0.9pt, dut: true)
      if ten-tcx != none {
        let nd = if ten-tcx == auto { _pt-bac-nhat(p, q) } else { ten-tcx }
        let Xn = X1 + 0.88 * (X2 - X1)
        nhan(ctx, (Xn, tcx(Xn)), nd, huong: huong-tcx, cach: 5pt, mau: red)
      }
      // hai nhánh
      let g = (cs.xmax - cs.xmin) * 0.012
      ve-ham(ctx, f, tu: cs.xmin, den: x0 - g, n: 140, mau: mau)
      ve-ham(ctx, f, tu: x0 + g, den: cs.xmax, n: 140, mau: mau)
      // cực trị (nếu có)
      if xt1 != none {
        let ct = cuc-tri-huu-ti(a, b, c, d, e)
        _giong-ct(ctx, (xt1, f(xt1)), cuc-tri, 0, ten-x: ct.x1, ten-y: ct.y1)
        _giong-ct(ctx, (xt2, f(xt2)), cuc-tri, 1, ten-x: ct.x2, ten-y: ct.y2)
      }
      // tâm đối xứng I = giao 2 tiệm cận
      if hien-tam {
        let o = if type(tam) == dictionary { tam } else { (:) }
        giong(
          ctx, (x0, tcx(x0)),
          huong-x: o.at("x", default: "below"),
          huong-y: o.at("y", default: "left"),
          ten-x: o.at("ten-x", default: so-can-thuc(-e, 0, 0, d)),
          ten-y: o.at("ten-y", default: so-can-thuc(b * d - 2 * a * e, 0, 0, d * d)),
        )
      }
      _nhan-giao-ox(
        ctx, ng, giao-ox,
        ten: if ng.len() == 2 {
          let dl = b * b - 4 * a * c
          let sg = if a > 0 { 1 } else { -1 }
          (so-can-thuc(-b, -sg, dl, 2 * a), so-can-thuc(-b, sg, dl, 2 * a))
        } else { () },
      )
      if e != 0 { _nhan-giao-oy(ctx, c / e, giao-oy) }
      _nhan-ten(ctx, ten, goc-ten, mau)
      if them != none { them(ctx) }
    },
  )
}

// ---------- Mũ: y = aˣ (a > 0, a ≠ 1) ----------
#let do-thi-mu(a, w: 7cm, mau: blue, ten: auto, goc-ten: auto, diem-db: true, luoi-o: false, vach: false, them: none) = {
  // cơ số: nguyên -> số nguyên; còn lại -> số đẹp (phân số/căn) trong ngoặc
  let cs = if calc.abs(a - calc.round(a)) < 0.001 { $#int(calc.round(a))$ } else { $(#so-toan(a))$ }
  let nd = if ten == auto { $y = #cs^x$ } else { ten }
  // a > 1 tăng (góc trống trên-trái) · a < 1 giảm (trên-phải)
  let gt = if goc-ten == auto { if a > 1 { "above-left" } else { "above-right" } } else { goc-ten }
  do-thi-ham(
    x => calc.pow(a, x),
    w: w, xmin: -2.9, xmax: 2.9, ymin: -1.2, ymax: 5.2,
    mau: mau, ten: nd, goc-ten: gt, n: 160, luoi-o: luoi-o, vach: vach,
    them: ctx => {
      if diem-db {
        giong(ctx, (0, 1), ten-x: none)
        giong(ctx, (1, a))
      }
      if them != none { them(ctx) }
    },
  )
}

// ---------- Lôgarit: y = log_a(x) ----------
#let do-thi-log(a, w: 7cm, mau: blue, ten: auto, goc-ten: auto, diem-db: true, luoi-o: false, vach: false, them: none) = {
  let cs = if calc.abs(a - calc.round(a)) < 0.001 { $#int(calc.round(a))$ } else { so-toan(a) }
  let nd = if ten == auto { $y = log_#cs x$ } else { ten }
  // a > 1 tăng (góc trống dưới-phải) · a < 1 giảm (dưới-trái)
  let gt = if goc-ten == auto { if a > 1 { "below-right" } else { "below-left" } } else { goc-ten }
  do-thi-ham(
    x => calc.ln(x) / calc.ln(a),
    w: w, xmin: -1.4, xmax: 6, ymin: -3.1, ymax: 3.1,
    tu: 0.035, den: 5.8,
    mau: mau, ten: nd, goc-ten: gt, n: 220, luoi-o: luoi-o, vach: vach,
    them: ctx => {
      if diem-db {
        giong(ctx, (1, 0), ten-y: none)
        giong(ctx, (a, 1))
      }
      if them != none { them(ctx) }
    },
  )
}

// ---------- Lượng giác ----------
// Ghi nhãn các bội của π trên trục hoành.
#let nhan-pi(ctx) = {
  let cap = (
    (-2 * calc.pi, $-2pi$), (-calc.pi, $-pi$), (-calc.pi / 2, $-pi/2$),
    (calc.pi / 2, $pi/2$), (calc.pi, $pi$), (2 * calc.pi, $2pi$),
  )
  for (v, t) in cap {
    if v > ctx.xmin + 0.3 and v < ctx.xmax - 0.3 {
      let s = 3pt / ctx.sy
      doan(ctx, (v, -s), (v, s), day: 0.8pt)
      nhan(ctx, (v, 0), t, huong: "below", cach: 5pt)
    }
  }
}

#let do-thi-sin(w: 10cm, mau: blue, ten: $y = sin x$, goc-ten: "above-right", luoi-o: false, them: none) = do-thi-ham(
  x => calc.sin(x),
  w: w, h: w * 0.34,
  xmin: -6.9, xmax: 6.9, ymin: -1.7, ymax: 1.7,
  tu: -6.6, den: 6.6,
  mau: mau, ten: ten, goc-ten: goc-ten, n: 220, luoi-o: luoi-o,
  them: ctx => {
    nhan-pi(ctx)
    nhan(ctx, (0, 1), $1$, huong: "above-left", cach: 3pt)
    nhan(ctx, (0, -1), $-1$, huong: "below-left", cach: 3pt)
    if them != none { them(ctx) }
  },
)

#let do-thi-cos(w: 10cm, mau: blue, ten: $y = cos x$, goc-ten: "above-right", luoi-o: false, them: none) = do-thi-ham(
  x => calc.cos(x),
  w: w, h: w * 0.34,
  xmin: -6.9, xmax: 6.9, ymin: -1.7, ymax: 1.7,
  tu: -6.6, den: 6.6,
  mau: mau, ten: ten, goc-ten: goc-ten, n: 220, luoi-o: luoi-o,
  them: ctx => {
    nhan-pi(ctx)
    nhan(ctx, (0, 1), $1$, huong: "above-right", cach: 3pt)
    if them != none { them(ctx) }
  },
)

#let do-thi-tan(w: 8cm, mau: blue, ten: $y = tan x$, goc-ten: "above-right", luoi-o: false, them: none) = {
  let p2 = calc.pi / 2
  do-thi-ham(
    x => calc.tan(x),
    w: w, h: w * 0.8,
    xmin: -4.6, xmax: 4.6, ymin: -3.6, ymax: 3.6,
    tu: -4.55, den: 4.55,
    mau: mau, ten: ten, goc-ten: goc-ten, n: 260, luoi-o: luoi-o,
    them: ctx => {
      for k in (-3, -1, 1, 3) {
        doan(ctx, (k * p2, -3.6), (k * p2, 3.6), mau: red, day: 0.8pt, dut: true)
      }
      nhan-pi(ctx)
      if them != none { them(ctx) }
    },
  )
}

// ---------- Côtang: y = cot x (tiệm cận đứng x = kπ) ----------
// cot x = cos x / sin x; nhánh tự tách tại các tiệm cận (giống tan).
#let do-thi-cot(w: 8cm, mau: blue, ten: $y = cot x$, goc-ten: "above-left", luoi-o: false, them: none) = {
  let pi = calc.pi
  let cot = x => {
    let s = calc.sin(x)
    if calc.abs(s) < 0.000001 { 1000000 } else { calc.cos(x) / s }
  }
  do-thi-ham(
    cot,
    w: w, h: w * 0.8,
    xmin: -4.6, xmax: 4.6, ymin: -3.6, ymax: 3.6,
    tu: -4.55, den: 4.55,
    mau: mau, ten: ten, goc-ten: goc-ten, n: 260, luoi-o: luoi-o,
    them: ctx => {
      // tiệm cận x = ±π (x = 0 trùng trục Oy nên không vẽ lại)
      for k in (-1, 1) {
        doan(ctx, (k * pi, -3.6), (k * pi, 3.6), mau: red, day: 0.8pt, dut: true)
      }
      nhan-pi(ctx)
      if them != none { them(ctx) }
    },
  )
}

// ---------- VẼ NHANH: chỉ cần công thức + màu ----------
// Tự lấy mẫu hàm số và chọn cửa sổ y hợp lý (kể cả khi hàm tăng rất nhanh).
//   #ve-do-thi(x => x*x*x - 3*x, mau: red)
//   #ve-do-thi(x => calc.sin(2*x), mau: purple, ten: $y = sin 2x$)
// Lưu ý: hàm phải xác định trên [xmin, xmax] (hoặc trên [tu, den] nếu đặt);
// với hàm phân thức có tiệm cận, dùng #do-thi-phan-thuc / #do-thi-huu-ti.
#let ve-do-thi(
  f,
  mau: blue,
  w: 8cm,
  xmin: -4, xmax: 4,
  tu: auto, den: auto,
  ten: none, goc-ten: "above-right",
  vach: false, luoi-o: false,
  gioi-han-y: 12,   // bề cao tối đa của cửa sổ nhìn theo trục y
  giao-ox: none, giao-oy: none,
  day: 1.4pt,
  them: none,
) = {
  let a = if tu == auto { xmin } else { tu }
  let b = if den == auto { xmax } else { den }
  let ys = lay-mau(f, a, b, n: 160).map(p => p.at(1)).sorted()
  let lo = ys.first()
  let hi = ys.last()
  // gộp trục hoành vào cửa sổ nếu không làm cửa sổ quá cao
  if lo > 0 and hi <= gioi-han-y { lo = 0 }
  if hi < 0 and -lo <= gioi-han-y { hi = 0 }
  // hàm biến thiên quá mạnh: thu cửa sổ quanh trung vị (đồ thị tự cắt nhánh)
  if hi - lo > gioi-han-y {
    let tv = ys.at(calc.floor(ys.len() / 2))
    lo = calc.max(lo, tv - gioi-han-y / 2)
    hi = calc.min(hi, tv + gioi-han-y / 2)
  }
  let dem = (hi - lo) * 0.1 + 0.35
  do-thi-ham(
    f,
    w: w, xmin: xmin, xmax: xmax,
    ymin: lo - dem, ymax: hi + dem,
    tu: a, den: b,
    mau: mau, day: day, n: 180,
    ten: ten, goc-ten: goc-ten, vach: vach, luoi-o: luoi-o,
    them: them,
  )
}

// =====================================================================
// NHIỀU ĐỒ THỊ TRÊN CÙNG MỘT HỆ TRỤC
// Mỗi hàm gói bằng #ham(...); truyền hàm trần x => ... cũng được.
//   #do-thi-nhieu-ham(
//     ham(x => x*x - 2, mau: blue, ten: $y = x^2 - 2$),
//     ham(x => x, mau: red, ten: $y = x$, dut: true),
//     xmin: -3, xmax: 3, giao-diem: auto,
//   )
// =====================================================================
// Gói thông số một hàm.
//   tai   : auto = nhãn đặt gần đầu phải của đường; hoặc hoành độ x cụ thể
//   huong-ten : hướng nhãn so với điểm đặt
#let ham(
  f,
  mau: blue, day: 1.3pt, dut: false,
  ten: none, tai: auto, huong-ten: "above",
  tu: auto, den: auto,
) = (
  f: f, mau: mau, day: day, dut: dut,
  ten: ten, tai: tai, huong-ten: huong-ten, tu: tu, den: den,
)

#let do-thi-nhieu-ham(
  ..cac-ham,
  w: 8cm, h: auto,
  xmin: -4, xmax: 4, ymin: -3, ymax: 3,
  vach: false, luoi-o: false,
  giao-diem: none,   // auto = chấm đỏ tại giao điểm của từng cặp đồ thị
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let ds = cac-ham.pos().map(hs => if type(hs) == function { ham(hs) } else { hs })
  let cs = _dan((xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax), dan-x, dan-y)
  let hh = if h == auto { w * 0.68 } else { h }
  hinh(w: w, h: hh, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax, ctx => {
    if luoi-o { luoi(ctx) }
    truc(ctx)
    if vach { vach-chia(ctx) }
    for hs in ds {
      let a = if hs.tu == auto { cs.xmin } else { hs.tu }
      let b = if hs.den == auto { cs.xmax } else { hs.den }
      ve-ham(ctx, hs.f, tu: a, den: b, mau: hs.mau, day: hs.day, dut: hs.dut)
      if hs.ten != none {
        // vị trí nhãn: hoành độ chỉ định, hoặc điểm trong cửa sổ gần đầu phải
        let P = none
        if hs.tai != auto {
          P = (hs.tai, (hs.f)(hs.tai))
        } else {
          let le = (cs.ymax - cs.ymin) * 0.08
          let i = 40
          while i >= 0 and P == none {
            let x = a + (b - a) * (0.06 + 0.88 * i / 40)
            let y = (hs.f)(x)
            if y > cs.ymin + le and y < cs.ymax - le { P = (x, y) }
            i = i - 1
          }
        }
        if P != none { nhan(ctx, P, hs.ten, huong: hs.huong-ten, mau: hs.mau, cach: 7pt) }
      }
    }
    if giao-diem == auto {
      for i in range(ds.len()) {
        for j in range(i + 1, ds.len()) {
          let fi = ds.at(i).f
          let fj = ds.at(j).f
          for x in _nghiem(x => fi(x) - fj(x), cs.xmin, cs.xmax) {
            let y = fi(x)
            if y > cs.ymin and y < cs.ymax { diem(ctx, (x, y), bk: 2pt, mau: red) }
          }
        }
      }
    }
    if them != none { them(ctx) }
  })
}

// =====================================================================
// MIỀN NGHIỆM BPT / HỆ BPT BẬC NHẤT HAI ẨN
// Quy ước SGK: GẠCH phần KHÔNG là miền nghiệm; miền nghiệm để trắng
// (hoặc tô nhạt bằng to-mien).
//   #mien-nghiem(bpt(4, 5, -8, dau: "<"), xmin: -4, xmax: 4)
//   #mien-nghiem(
//     bpt(3, -2, -9, dau: "<=", mau: red),
//     bpt(3, -5, -18, dau: ">=", mau: green.darken(20%)),
//     to-mien: rgb(30, 100, 200, 40),
//   )
// =====================================================================
// Một BPT: a·x + b·y (dau) c.   dau: "<=", ">=", "<", ">"
//   mau      : màu đường thẳng; mau-gach: auto = cùng màu (nhạt hơn)
//   goc-gach : GÓC gạch chéo RIÊNG cho bpt này; auto = theo goc-gach chung
//              của mien-nghiem (giống lối mau-gach). buoc-gach: bước gạch riêng
//   ten      : nhãn đường thẳng (vd $d: 4x + 5y = -8$); ten-tai: 0..1 vị trí
//              dọc theo đoạn nhìn thấy tại điểm đặt nhãn
//   nghieng-ten : true (mặc định) = chữ NẰM NGHIÊNG theo chiều đường thẳng
//              (tự đọc xuôi, không lộn ngược); false = chữ nằm ngang như cũ
//   huong-ten : PHÍA đặt nhãn tại điểm đó — "above" hoặc "below". Khi nghiêng,
//              đây là phía trên/dưới so với đường (theo pháp tuyến); khi không
//              nghiêng vẫn nhận mọi hướng cũ ("above"/"below"/"left"/tuple…)
//   cach-ten : khoảng cách từ đường tới nhãn
#let bpt(
  a, b, c,
  dau: "<=",
  mau: red, day: 1.1pt,
  mau-gach: auto, goc-gach: auto, buoc-gach: auto,
  ten: none, ten-tai: 0.78, huong-ten: "above",
  nghieng-ten: true, cach-ten: 3pt,
) = (
  a: a, b: b, c: c, dau: dau, mau: mau, day: day,
  mau-gach: mau-gach, goc-gach: goc-gach, buoc-gach: buoc-gach,
  ten: ten, ten-tai: ten-tai, huong-ten: huong-ten,
  nghieng-ten: nghieng-ten, cach-ten: cach-ten,
)

// Đoạn nhìn thấy của đường a·x + b·y = c trong cửa sổ (none nếu ngoài).
#let _doan-cua-so(ctx, a, b, c) = {
  let gd = ()
  let canh = (
    ((ctx.xmin, ctx.ymin), (ctx.xmax, ctx.ymin)),
    ((ctx.xmax, ctx.ymin), (ctx.xmax, ctx.ymax)),
    ((ctx.xmax, ctx.ymax), (ctx.xmin, ctx.ymax)),
    ((ctx.xmin, ctx.ymax), (ctx.xmin, ctx.ymin)),
  )
  for (P, Q) in canh {
    let fp = a * P.at(0) + b * P.at(1) - c
    let fq = a * Q.at(0) + b * Q.at(1) - c
    if fp * fq <= 0 and fp != fq {
      let s = fp / (fp - fq)
      let G = (P.at(0) + s * (Q.at(0) - P.at(0)), P.at(1) + s * (Q.at(1) - P.at(1)))
      if gd.len() == 0 or khoang-cach(gd.at(0), G) > 0.0001 { gd.push(G) }
    }
  }
  if gd.len() >= 2 { (gd.at(0), gd.at(1)) } else { none }
}

#let mien-nghiem(
  ..cac-bpt,
  w: 7cm, h: auto,
  xmin: -5, xmax: 5, ymin: -4, ymax: 4,
  to-mien: none,       // màu tô miền nghiệm (nên trong suốt), none = bỏ
  giao-truc: none,     // auto = ghi số giao điểm của các đường với 2 trục
  buoc-gach: 6.5pt, goc-gach: 45deg,
  vach: false, luoi-o: false,
  them: none,
) = {
  let ds = cac-bpt.pos()
  let hh = if h == auto { w * (ymax - ymin) / (xmax - xmin) } else { h }
  hinh(w: w, h: hh, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax, ctx => {
    let khung = ((xmin, ymin), (xmax, ymin), (xmax, ymax), (xmin, ymax))
    if luoi-o { luoi(ctx) }
    // tô miền nghiệm: giao các nửa mặt phẳng
    if to-mien != none {
      let mn = khung
      for d in ds {
        // chuẩn hoá về dạng ≤: miền nghiệm là a·x + b·y ≤ c
        let (a, b, c) = if d.dau in ("<=", "<") { (d.a, d.b, d.c) } else { (-d.a, -d.b, -d.c) }
        mn = cat-nua-mp(mn, a, b, c)
      }
      if mn.len() >= 3 { da-giac-pt(mn.map(P => toa-pt(ctx, P)), to: to-mien) }
    }
    // gạch phần loại bỏ của từng BPT
    for d in ds {
      let (a, b, c) = if d.dau in ("<=", "<") { (d.a, d.b, d.c) } else { (-d.a, -d.b, -d.c) }
      let loai = cat-nua-mp(khung, -a, -b, -c)   // nửa mặt phẳng a·x + b·y ≥ c
      let mg = if d.mau-gach == auto { d.mau.lighten(25%) } else { d.mau-gach }
      // góc/bước gạch RIÊNG của từng bpt (auto = theo giá trị chung của mien-nghiem)
      let gg = if d.at("goc-gach", default: auto) == auto { goc-gach } else { d.goc-gach }
      let bg = if d.at("buoc-gach", default: auto) == auto { buoc-gach } else { d.buoc-gach }
      if loai.len() >= 3 {
        gach-mien(ctx, loai, goc: gg, buoc: bg, mau: mg)
      }
    }
    truc(ctx)
    if vach { vach-chia(ctx) }
    // đường biên (đứt nếu BPT ngặt) + nhãn
    for d in ds {
      let dc = _doan-cua-so(ctx, d.a, d.b, d.c)
      if dc != none {
        let (A, B) = dc
        doan(ctx, A, B, mau: d.mau, day: d.day, dut: d.dau in ("<", ">"))
        if d.ten != none {
          let P = chia(A, B, d.ten-tai)
          let cach = d.at("cach-ten", default: 3pt)
          if d.at("nghieng-ten", default: true) {
            // chữ nằm nghiêng theo chiều đường; PHÍA above/below theo pháp tuyến.
            // Đặt SÁT đường: lệch = cach + nửa bề DÀY chữ (vuông góc đường) —
            // KHÔNG dùng offset của `nhan` (offset đó theo nửa khung ĐÃ XOAY, với
            // nhãn dài + đường xiên thì khung rất to nên nhãn bị đẩy xa đường).
            let xuoi = toa-pt(ctx, A).at(0) <= toa-pt(ctx, B).at(0)
            let ang = if xuoi { goc-truc(ctx, A, B) } else { goc-truc(ctx, B, A) }
            let n = _phap-tuyen(ctx, A, B)                 // pháp tuyến hướng LÊN (trang)
            if d.huong-ten in ("below", "duoi") { n = (-n.at(0), -n.at(1)) }
            context {
              let nd = text(fill: d.mau, d.ten)
              let nd2 = rotate(ang, reflow: true, nd)
              let s = measure(nd2)                         // khung sau khi xoay (canh giữa)
              let off = cach + measure(nd).height / 2      // bề dày chữ, vuông góc đường
              let p = toa(ctx, P)
              place(
                dx: p.at(0) - s.width / 2 + n.at(0) * off,
                dy: p.at(1) - s.height / 2 + n.at(1) * off,
                nd2,
              )
            }
          } else {
            nhan(ctx, P, d.ten, huong: d.huong-ten, mau: d.mau, cach: cach)
          }
        }
      }
      if giao-truc == auto {
        if d.a != 0 { _nhan-giao-ox(ctx, (d.c / d.a,), auto) }
        if d.b != 0 { _nhan-giao-oy(ctx, d.c / d.b, auto) }
      }
    }
    if them != none { them(ctx) }
  })
}

// =====================================================================
// DIỆN TÍCH HÌNH PHẲNG GIỚI HẠN BỞI HAI ĐỒ THỊ
//   g mặc định là trục hoành (y = 0).
//   a, b: auto = tự lấy giao điểm ngoài cùng của f và g trong [tu, den];
//         hoặc chỉ định đoạn [a, b] cụ thể.
//   Miền tô tự tách tại các giao điểm ở giữa nên tô đúng cả khi f − g đổi dấu.
//   #dien-tich-2-ham(x => x*x, g: x => x + 2)                    // tự tìm giao
//   #dien-tich-2-ham(x => calc.sin(x), a: 0, b: calc.pi)         // trên [a, b]
// =====================================================================
// Điểm đặt nhãn: điểm trên đồ thị gần mép phải mà còn nằm trong cửa sổ.
#let _diem-nhan(cs, f, a, b) = {
  let le = (cs.ymax - cs.ymin) * 0.08
  let i = 40
  while i >= 0 {
    let x = a + (b - a) * (0.06 + 0.88 * i / 40)
    let y = f(x)
    if y > cs.ymin + le and y < cs.ymax - le { return (x, y) }
    i = i - 1
  }
  none
}

#let dien-tich-2-ham(
  f, g: x => 0.0,
  a: auto, b: auto,
  tu: -5, den: 5,          // phạm vi tìm giao điểm khi a, b: auto
  w: 8cm, h: auto,
  mau-f: blue, mau-g: red, day: 1.3pt,
  ten-f: none, ten-g: none,
  huong-ten-f: "above", huong-ten-g: "below",
  mau-to: rgb(70, 90, 200, 70),
  ten-a: auto, ten-b: auto,          // nhãn cận trên Ox; none = bỏ
  giong-ab: true,                    // đường đứt x = a, x = b
  cham-giao: true,                   // chấm đỏ tại giao điểm
  keo-dai: 0.22,                     // vẽ đồ thị dài thêm ra 2 phía (tỉ lệ đoạn)
  dan-x: 1, dan-y: 1,
  them: none,
) = {
  let hieu = x => f(x) - g(x)
  let giao = _nghiem(hieu, tu, den)
  let aa = if a == auto { if giao.len() > 0 { giao.first() } else { tu } } else { a }
  let bb = if b == auto { if giao.len() > 0 { giao.last() } else { den } } else { b }
  let m = (bb - aa) * keo-dai + 0.3
  // cửa sổ: bao miền tô trên [aa, bb]; đồ thị ngoài đoạn bị cắt theo cửa sổ
  let chot = lay-mau(f, aa, bb, n: 60) + lay-mau(g, aa, bb, n: 60)
  let cs = _dan(_cua-so(chot + ((aa - m, 0), (bb + m, 0))), dan-x, dan-y)
  let hh = if h == auto { w * 0.68 } else { h }
  hinh(w: w, h: hh, xmin: cs.xmin, xmax: cs.xmax, ymin: cs.ymin, ymax: cs.ymax, ctx => {
    // các đoạn con tách tại giao điểm nằm trong (aa, bb)
    let moc = (aa,) + giao.filter(x => x > aa + 0.0001 and x < bb - 0.0001) + (bb,)
    for i in range(moc.len() - 1) {
      to-vung-2-ham(ctx, f, g, moc.at(i), moc.at(i + 1), mau: mau-to)
    }
    truc(ctx)
    ve-ham(ctx, f, tu: aa - m, den: bb + m, mau: mau-f, day: day)
    ve-ham(ctx, g, tu: aa - m, den: bb + m, mau: mau-g, day: day)
    if giong-ab {
      for (x, t) in ((aa, ten-a), (bb, ten-b)) {
        let (y1, y2) = (calc.min(f(x), g(x), 0), calc.max(f(x), g(x), 0))
        if y2 - y1 > 0.0001 {
          doan(ctx, (x, y1), (x, y2), mau: gray.darken(20%), day: 0.8pt, dut: true)
        }
        if t != none and calc.abs(x) > 0.001 {
          nhan(ctx, (x, 0), if t == auto { so-toan(x) } else { t },
            huong: if calc.max(f(x), g(x)) < 0.0001 { "above" } else { "below" }, cach: 4pt)
        }
      }
    }
    if cham-giao {
      for x in giao.filter(x => x >= aa - 0.0001 and x <= bb + 0.0001) {
        diem(ctx, (x, f(x)), bk: 2pt, mau: red)
      }
    }
    if ten-f != none {
      let P = _diem-nhan(cs, f, aa - m, bb + m)
      if P != none { nhan(ctx, P, ten-f, huong: huong-ten-f, mau: mau-f, cach: 7pt) }
    }
    if ten-g != none {
      let P = _diem-nhan(cs, g, aa - m, bb + m)
      if P != none { nhan(ctx, P, ten-g, huong: huong-ten-g, mau: mau-g, cach: 7pt) }
    }
    if them != none { them(ctx) }
  })
}

// ---------- Căn thức: y = √x ----------
#let do-thi-can(w: 7cm, mau: blue, ten: $y = sqrt(x)$, goc-ten: "above-right", luoi-o: false, vach: false, them: none) = do-thi-ham(
  x => calc.sqrt(x),
  w: w, xmin: -1.2, xmax: 6.2, ymin: -1, ymax: 3.2,
  tu: 0, den: 6,
  mau: mau, ten: ten, goc-ten: goc-ten, n: 160, luoi-o: luoi-o, vach: vach,
  them: ctx => {
    giong(ctx, (1, 1))
    giong(ctx, (4, 2))
    if them != none { them(ctx) }
  },
)

// =====================================================================
// TRỤC SỐ — biểu diễn đoạn / khoảng / nửa khoảng (một hoặc nhiều)
// Mỗi khoảng là tuple: (a, b, kieu) hoặc (a, b, kieu, mau)
//   a, b : số  HOẶC  "-oo" / "+oo" (vô cực)  — a < b
//   kieu : chuỗi 2 kí tự đầu mút trái+phải, chọn trong:
//          "[]" đoạn · "()" khoảng · "[)" · "(]" nửa khoảng
// Quy ước (SGK): GIỮ trống vùng nghiệm, GẠCH CHÉO phần loại bỏ;
//   [ ] = lấy đầu mút (đặc), ( ) = không lấy (rỗng).
//   #truc-so((-2, 3, "[)"))
//   #truc-so((-2, 1, "()"), (3, "+oo", "[)"))
// dau: "ngoac" (mặc định) | "cham" (chấm đặc/rỗng)
// =====================================================================
#let _vc(v) = type(v) == str          // v là vô cực ("-oo"/"+oo") ?

#let truc-so(
  ..khoang,
  w: 10cm, h: 1.5cm,        // h: chiều cao khung cố định (hết khoảng trống dọc)
  min: auto, max: auto,
  ten: $x$,
  mau: rgb("#1d4ed8"),      // màu đoạn nghiệm
  gach: true,               // gạch chéo phần loại bỏ
  mau-gach: red,
  dau: "ngoac",             // kiểu đầu mút: "ngoac" | "cham"
  moc-phu: (),              // mốc phụ chỉ để ghi số (không thuộc nghiệm)
  so: true,
  co-chu: 13pt,             // cỡ chữ số tại mốc
  cao-gach: 2mm,            // chiều cao dải gạch chéo (đo trên trang)
) = {
  let ks = khoang.pos()
  // các đầu mút hữu hạn -> cửa sổ tự động
  let huu-han = ()
  for k in ks {
    if not _vc(k.at(0)) { huu-han.push(k.at(0)) }
    if not _vc(k.at(1)) { huu-han.push(k.at(1)) }
  }
  for m in moc-phu { huu-han.push(if type(m) == array { m.at(0) } else { m }) }
  let lo = if huu-han.len() > 0 { calc.min(..huu-han) } else { -4 }
  let hi = if huu-han.len() > 0 { calc.max(..huu-han) } else { 4 }
  let pad = calc.max((hi - lo) * 0.2, 1.5)
  let xa = if min == auto { lo - pad } else { min }
  let xb = if max == auto { hi + pad } else { max }
  hinh(w: w, h: h, xmin: xa, xmax: xb, ymin: -1.1, ymax: 1.1, co-chu: co-chu, ctx => {
    // ---- gạch chéo phần loại bỏ (bù của hợp các khoảng) ----
    if gach {
      let segs = ks.map(k => {
        let a = if _vc(k.at(0)) { xa } else { k.at(0) }
        let b = if _vc(k.at(1)) { xb } else { k.at(1) }
        (calc.min(a, b), calc.max(a, b))
      }).sorted(key: s => s.at(0))
      let merged = ()
      for s in segs {
        if merged.len() == 0 or s.at(0) > merged.last().at(1) + 0.000001 {
          merged.push(s)
        } else {
          let last = merged.pop()
          merged.push((last.at(0), calc.max(last.at(1), s.at(1))))
        }
      }
      let unc = ()
      let cur = xa
      for s in merged {
        if s.at(0) > cur + 0.000001 { unc.push((cur, s.at(0))) }
        cur = calc.max(cur, s.at(1))
      }
      if cur < xb - 0.000001 { unc.push((cur, xb)) }
      // dải gạch cao CỐ ĐỊNH trên trang (không phình theo cửa sổ toạ độ)
      let hb = cao-gach / 2 / ctx.sy
      for (u1, u2) in unc {
        gach-mien(
          ctx, ((u1, -hb), (u2, -hb), (u2, hb), (u1, hb)),
          goc: 45deg, buoc: 6pt, mau: mau-gach, day: 0.5pt,
        )
      }
    }
    // ---- trục (mũi tên 2 đầu) + nhãn x ----
    doan(ctx, (xa, 0), (xb, 0), day: 1pt)
    dau-mui-ten(ctx, (xa, 0), (xb, 0))
    dau-mui-ten(ctx, (xb, 0), (xa, 0))
    nhan(ctx, (xb, 0), ten, huong: "below", cach: 6pt)
    // ---- vạch + số tại đầu mút và mốc phụ ----
    let t = 3pt / ctx.sy
    let ghi-moc(x) = {
      doan(ctx, (x, -t), (x, t), day: 0.9pt)
      if so { nhan(ctx, (x, 0), so-toan(x), huong: "below", cach: 6pt) }
    }
    for k in ks {
      if not _vc(k.at(0)) { ghi-moc(k.at(0)) }
      if not _vc(k.at(1)) { ghi-moc(k.at(1)) }
    }
    for m in moc-phu { ghi-moc(if type(m) == array { m.at(0) } else { m }) }
    // ---- đoạn nghiệm + đầu mút ----
    let dau-mut(x, mo, ben) = {
      // ben: "trai" | "phai" (quyết định chiều ngoặc / hướng)
      let m = mau
      if dau == "cham" {
        let p = toa(ctx, (x, 0))
        if mo {
          place(dx: p.at(0) - 3pt, dy: p.at(1) - 3pt,
            circle(radius: 3pt, fill: white, stroke: 1pt + m))
        } else {
          place(dx: p.at(0) - 3pt, dy: p.at(1) - 3pt,
            circle(radius: 3pt, fill: m, stroke: none))
        }
      } else {
        let sym = if ben == "trai" { if mo { "(" } else { "[" } }
                  else { if mo { ")" } else { "]" } }
        nhan(ctx, (x, 0), text(size: 1.45em, weight: "bold", fill: m)[#sym], huong: "center")
      }
    }
    for k in ks {
      let (a, b, kieu) = (k.at(0), k.at(1), k.at(2))
      let m = if k.len() >= 4 { k.at(3) } else { mau }
      let xl = if _vc(a) { xa } else { a }
      let xr = if _vc(b) { xb } else { b }
      doan(ctx, (xl, 0), (xr, 0), mau: m, day: 2.6pt)
      if not _vc(a) {
        let mo = kieu.at(0) == "("
        if dau == "cham" { dau-mut(a, mo, "trai") }
        else {
          let sym = if mo { "(" } else { "[" }
          nhan(ctx, (a, 0), text(size: 1.45em, weight: "bold", fill: m)[#sym], huong: "center")
        }
      }
      if not _vc(b) {
        let mo = kieu.at(1) == ")"
        if dau == "cham" { dau-mut(b, mo, "phai") }
        else {
          let sym = if mo { ")" } else { "]" }
          nhan(ctx, (b, 0), text(size: 1.45em, weight: "bold", fill: m)[#sym], huong: "center")
        }
      }
    }
  })
}

// =====================================================================
// HYPERBOL  x²/a² − y²/b² = 1   (nhập bán trục thực a, ảo b)
// Mặc định vẽ kèm: 2 tiệm cận y = ±(b/a)x, đỉnh A₁A₂, tiêu điểm F₁F₂.
// =====================================================================
#let hyperbol(
  a, b,
  w: 8.4cm,
  mau: blue, day: 1.4pt,
  ten: auto, goc-ten: auto,
  tiem-can: true, dinh: true, tieu-diem: true,
  ten-dinh: ($A_1$, $A_2$), ten-tieu: ($F_1$, $F_2$),
  luoi-o: false, vach: false,
  them: none,
) = {
  let eexp = t => calc.pow(2.718281828459045, t)
  let ch = t => (eexp(t) + eexp(-t)) / 2
  let sh = t => (eexp(t) - eexp(-t)) / 2
  let c = calc.sqrt(a * a + b * b)
  let X = calc.max(a * 2.4, c * 1.12)
  let Y = (b / a) * X * 0.9
  let T = calc.ln(X / a + calc.sqrt((X / a) * (X / a) - 1))
  let nhanh = s => range(0, 121).map(i => {
    let tt = -T + 2 * T * i / 120
    (s * a * ch(tt), b * sh(tt))
  })
  let nd = if ten == auto {
    $x^2 / #so-dep(a * a) - y^2 / #so-dep(b * b) = 1$
  } else { ten }
  let gt = if goc-ten == auto { (X * 0.3, Y * 0.82) } else { goc-ten }
  hinh(w: w, xmin: -X, xmax: X, ymin: -Y, ymax: Y, ctx => {
    if luoi-o { luoi(ctx) }
    if tiem-can {
      let xl = Y * a / b
      doan(ctx, (-xl, -Y), (xl, Y), mau: gray.darken(15%), day: 0.9pt, dut: true)
      doan(ctx, (-xl, Y), (xl, -Y), mau: gray.darken(15%), day: 0.9pt, dut: true)
    }
    truc(ctx)
    if vach { vach-chia(ctx) }
    duong-cong(ctx, nhanh(1), mau: mau, day: day)
    duong-cong(ctx, nhanh(-1), mau: mau, day: day)
    if dinh {
      diem(ctx, (-a, 0), ten: ten-dinh.at(0), huong: "below", bk: 1.9pt, mau: red)
      diem(ctx, (a, 0), ten: ten-dinh.at(1), huong: "below", bk: 1.9pt, mau: red)
    }
    if tieu-diem {
      diem(ctx, (-c, 0), ten: ten-tieu.at(0), huong: "above", bk: 1.9pt)
      diem(ctx, (c, 0), ten: ten-tieu.at(1), huong: "above", bk: 1.9pt)
    }
    _nhan-ten(ctx, nd, gt, mau)
    if them != none { them(ctx) }
  })
}

// =====================================================================
// PARABOL  y² = 2px   (nhập tham số tiêu p ≠ 0; p > 0 mở phải, p < 0 mở trái)
// Mặc định vẽ kèm: đỉnh O, tiêu điểm F(p/2; 0), đường chuẩn x = −p/2.
// =====================================================================
#let parabol(
  p,
  w: 8cm,
  mau: blue, day: 1.4pt,
  ten: auto, goc-ten: auto,
  tieu-diem: true, duong-chuan: true, dinh: true,
  ten-tieu: $F$,
  luoi-o: false, vach: false,
  them: none,
) = {
  let s = if p > 0 { 1 } else { -1 }
  let Xt = 4.2
  let Y = calc.sqrt(2 * calc.abs(p) * Xt)
  let xdc = -p / 2      // đường chuẩn
  let xf = p / 2        // tiêu điểm
  let xs = (0, s * Xt, xdc, xf)
  let xa = calc.min(..xs) - 0.9
  let xb = calc.max(..xs) + 0.9
  let ya = -Y - 0.6
  let yb = Y + 0.6
  let cur = range(0, 121).map(i => {
    let yy = -Y + 2 * Y * i / 120
    (yy * yy / (2 * p), yy)
  })
  let nd = if ten == auto { $y^2 = #so-dep(2 * p) x$ } else { ten }
  // p > 0 mở phải -> nhãn bên trái trống; p < 0 mở trái -> nhãn bên phải
  let gt = if goc-ten == auto { if s > 0 { "above-left" } else { "above-right" } } else { goc-ten }
  hinh(w: w, xmin: xa, xmax: xb, ymin: ya, ymax: yb, ctx => {
    if luoi-o { luoi(ctx) }
    if duong-chuan {
      doan(ctx, (xdc, ya + 0.2), (xdc, yb - 0.2), mau: gray.darken(15%), day: 1pt, dut: true)
      nhan(ctx, (xdc, yb - 0.2), $Delta$, huong: if s > 0 { "above-left" } else { "above-right" }, cach: 3pt)
    }
    truc(ctx)
    if vach { vach-chia(ctx) }
    duong-cong(ctx, cur, mau: mau, day: day)
    if dinh { diem(ctx, (0, 0), bk: 1.9pt, mau: red) }
    if tieu-diem {
      diem(ctx, (xf, 0), ten: ten-tieu, huong: "below", bk: 1.9pt, mau: red)
    }
    _nhan-ten(ctx, nd, gt, mau)
    if them != none { them(ctx) }
  })
}

// =====================================================================
// ELIP  x²/a² + y²/b² = 1   (nhập 2 bán trục a, b như hyperbol)
// Mặc định vẽ kèm: 4 đỉnh (±a; 0), (0; ±b) và 2 tiêu điểm trên trục lớn
// (a > b: F(±c; 0); b > a: F(0; ±c); c = √|a² − b²|). a = b -> đường tròn.
// =====================================================================
#let duong-elip(
  a, b,
  w: 8cm,
  mau: blue, day: 1.4pt,
  ten: auto, goc-ten: "above-right",
  dinh: true, tieu-diem: true,
  ten-tieu: ($F_1$, $F_2$),
  luoi-o: false, vach: false,
  them: none,
) = {
  let c = calc.sqrt(calc.abs(a * a - b * b))
  let mg = 0.85
  let X = a + mg
  let Y = b + mg
  let nd = if ten == auto { $x^2 / #so-dep(a * a) + y^2 / #so-dep(b * b) = 1$ } else { ten }
  hinh(w: w, xmin: -X, xmax: X, ymin: -Y, ymax: Y, ctx => {
    if luoi-o { luoi(ctx) }
    truc(ctx)
    if vach { vach-chia(ctx) }
    elip(ctx, (0, 0), a, b, mau: mau, day: day)
    if dinh {
      diem(ctx, (-a, 0), ten: $A_1$, huong: "below-left", bk: 1.9pt, mau: red)
      diem(ctx, (a, 0), ten: $A_2$, huong: "below-right", bk: 1.9pt, mau: red)
      diem(ctx, (0, b), ten: $B_2$, huong: "above-left", bk: 1.9pt, mau: red)
      diem(ctx, (0, -b), ten: $B_1$, huong: "below-left", bk: 1.9pt, mau: red)
    }
    if tieu-diem and c > 0.001 {
      if a >= b {
        diem(ctx, (-c, 0), ten: ten-tieu.at(0), huong: "above", bk: 1.9pt)
        diem(ctx, (c, 0), ten: ten-tieu.at(1), huong: "above", bk: 1.9pt)
      } else {
        diem(ctx, (0, -c), ten: ten-tieu.at(0), huong: "right", bk: 1.9pt)
        diem(ctx, (0, c), ten: ten-tieu.at(1), huong: "right", bk: 1.9pt)
      }
    }
    _nhan-ten(ctx, nd, goc-ten, mau)
    if them != none { them(ctx) }
  })
}
// (đồng bộ mount 07/2026)
