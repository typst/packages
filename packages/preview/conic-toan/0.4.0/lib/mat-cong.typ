// =====================================================================
// mat-cong.typ — ENGINE KHỐI (nón · trụ · cầu · ĐA DIỆN) NÉT KHUẤT TỰ ĐỘNG
//
// Bổ khuyết cho `da-dien.typ`: engine kia chỉ lo được KHỐI ĐA DIỆN LỒI và
// KHÔNG xử lý được hai khối che nhau. Ở đây dùng MỘT cơ chế duy nhất cho cả
// hai việc — BẮN TIA từ điểm đang xét về phía người nhìn; tia gặp lòng bất
// kì khối nào (kể cả chính nó) thì đoạn đó là NÉT KHUẤT.
//
// HỢP NHẤT HAI ENGINE (08/2026): `khoi-da-dien(..khoi-lap-phuong(a: 3))` đưa
// khối đa diện vào chính cơ chế bắn tia này ⇒ đa diện và mặt cong CHE NHAU
// ĐÚNG trong một lời gọi. `da-dien`/`ve-da-dien` cũ KHÔNG đụng tới — đây là
// đường đi THỨ HAI, bài soạn cũ giữ nguyên từng nét.
//   #mat-cong(khoi-da-dien(..khoi-lap-phuong(a: 3)), khoi-cau(r: 1.9))
// Khác biệt duy nhất so với `ve-da-dien`: `to:` ở đây tô BÓNG KHỐI một màu
// (bao lồi của hình chiếu), không tô từng mặt theo độ sâu.
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
// KHỐI CẦU (08/2026): `khoi-cau(tam:, r:, xich-dao:, kinh-tuyen:, nghieng:,
// huong:, truc:)` — TÊN `mat-cau` đã thuộc về `oxyz-toan.typ`, xem cảnh báo ở
// chỗ định nghĩa. Trục ở đây là TRỤC CỰC — xích đạo là đường tròn lớn vuông
// góc trục, kinh tuyến là các đường tròn lớn đi qua hai cực. Đường BIÊN của
// cầu KHÔNG phụ thuộc trục cực: dưới phép chiếu song song bất kì (kể cả chiếu
// xiên), tia nhìn tiếp xúc mặt cầu đúng trên đường tròn lớn VUÔNG GÓC hướng
// nhìn `e`, nên biên = `tron-ngang(tam, r, truc: e)` và chiếu ra một ELIP.
//   #mat-cong(khoi-cau(r: 2))                      // cầu + xích đạo nửa sau đứt
//   #mat-cong(khoi-cau(r: 2, kinh-tuyen: 4))       // dáng quả địa cầu
//
// Mọi công thức đều viết theo KHUNG RIÊNG (u, v, w) của khối — w là trục,
// (u, v) là hai phương trong mặt đáy — nên trục đứng chỉ là trường hợp riêng.
//
// Phép thử che khuất là GIẢI TÍCH, KHÔNG quét mẫu: giao của tia với mặt đáy
// là phương trình bậc nhất, với mặt bên là bậc hai; trạng thái trong/ngoài
// chỉ đổi tại các nghiệm đó nên chỉ cần xét trung điểm giữa hai mốc liên
// tiếp. Sai số duy nhất còn lại là ở mắt lưới của đường được vẽ (`n:`).
//
// GIỚI HẠN: đường BIÊN (silhouette — đường sinh của nón/trụ, đường tròn lớn
// của cầu) CỐ Ý không để chính khối của nó che — tia bắn từ đúng đường biên
// là tiếp tuyến, xét ở đó sẽ chập chờn làm nét biên lúc liền lúc đứt.
// =====================================================================
#import "ve.typ": *
#import "da-dien.typ": v3-cong, v3-tru, v3-nhan, v3-dai, v3-vo-huong, v3-co-huong, v3-chuan, _cam, chieu-3d, chieu-xien, chieu-oxyz, chieu-truc-giao, tam-3d, phap-da-giac, _canh-vong, _khoa, _huong-khe

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

// KHỐI CẦU — `tam` là TÂM cầu (không phải tâm đáy), `cao` không có nghĩa.
//   xich-dao   : vẽ đường tròn lớn vuông góc TRỤC CỰC (nửa sau tự đứt)
//   kinh-tuyen : số đường tròn lớn đi qua hai cực (0 = không vẽ)
//   nghieng/huong/truc : hướng TRỤC CỰC — chỉ đổi xích đạo/kinh tuyến,
//                        KHÔNG đổi đường biên (biên chỉ theo hướng nhìn).
// ⚠️ TÊN `mat-cau` ĐÃ CÓ CHỦ: `oxyz-toan.typ` dùng nó cho KIỂU DỮ LIỆU mặt
// cầu `mat-cau(I, R) -> (I:, R:)`, và file đó được import SAU mat-cong.typ
// trong `baigiang.typ` nên sẽ che mất. ĐỪNG đặt lại tên `mat-cau` ở đây.
#let khoi-cau(
  tam: (0, 0, 0), r: 2,
  xich-dao: true, kinh-tuyen: 0,
  nghieng: 0deg, huong: 0deg, truc: auto,
  mau: auto, to: auto,
) = _khoi("cau", tam, r, 0, nghieng, huong, truc, mau, to) + (
  xich-dao: xich-dao, kinh-tuyen: kinh-tuyen,
)

// KHỐI ĐA DIỆN LỒI đưa vào CHÍNH engine bắn tia này — nhờ vậy đa diện và mặt
// cong CHE NHAU ĐÚNG trong cùng một lời gọi `mat-cong`, việc mà `da-dien.typ`
// (back-face culling) không làm được.
//   #mat-cong(khoi-da-dien(..khoi-lap-phuong(a: 3)), khoi-cau(r: 1.5))
// Nhận thẳng các khối dựng sẵn của da-dien.typ qua toán tử `..` vì chúng trả
// đúng ba khoá (dinh:, mat:, ten:).
// ⚠️ `da-dien`/`ve-da-dien` cũ KHÔNG đụng tới — hàm này là đường đi THỨ HAI,
// dùng khi cần che khuất chéo; bài cũ giữ nguyên từng nét.
#let khoi-da-dien(
  dinh: (), mat: (),
  ten: none, hien-dinh: true, bk: 1.6pt, cach: 6pt, huong: auto,
  mau: auto, to: auto,
) = {
  let C = tam-3d(dinh)
  // Mỗi mặt -> nửa không gian (n·P <= d) với n là pháp tuyến HƯỚNG RA NGOÀI.
  // Lật theo tâm khối, đúng lối `phan-tich-khoi` của da-dien.typ, nên thứ tự
  // đỉnh trong mỗi mặt KHÔNG cần theo chiều nào.
  let mp = ()
  for m in mat {
    let ds = m.map(i => dinh.at(i))
    let nrm = phap-da-giac(ds)
    let T = tam-3d(ds)
    if v3-vo-huong(nrm, v3-tru(T, C)) < 0 { nrm = v3-nhan(-1, nrm) }
    mp.push((n: nrm, d: v3-vo-huong(nrm, T)))
  }
  // cạnh DUY NHẤT (bỏ trùng bằng khoá i-j như da-dien.typ)
  let bang = (:)
  for m in mat {
    for (i, j) in _canh-vong(m) {
      bang.insert(_khoa(i, j), (calc.min(i, j), calc.max(i, j)))
    }
  }
  (
    loai: "dadien",
    dinh: dinh, mat: mat, mp: mp, canh: bang.values(),
    tam: C,
    // `r` = bán kính bao, CHỈ dùng để `ve-mat-cong` tính `lui`
    r: calc.max(1e-6, ..dinh.map(P => v3-dai(v3-tru(P, C)))),
    ten: ten, hien-dinh: hien-dinh, bk: bk, cach: cach, huong: huong,
    mau: mau, to: to,
  )
}

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
  if k.loai == "cau" {
    return v3-dai(v3-tru(P, k.tam)) < k.r - lui
  }
  // ĐA DIỆN LỒI = giao của các nửa không gian; `lui` co khối lại một chút,
  // đúng vai trò như với mặt cong (chống chập chờn ở cạnh nằm trên biên).
  if k.loai == "dadien" {
    for f in k.mp {
      if v3-vo-huong(f.n, P) > f.d - lui { return false }
    }
    return true
  }
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
  // CẦU: chỉ một mặt bậc hai, không có mặt đáy ⇒ nhiều nhất 2 mốc.
  if k.loai == "cau" {
    let q = v3-tru(P, k.tam)
    let A = v3-vo-huong(e, e)
    let B = 2 * v3-vo-huong(q, e)
    let C = v3-vo-huong(q, q) - k.r * k.r
    let D = B * B - 4 * A * C
    if A < 1e-12 or D <= 0 { return () }
    let sq = calc.sqrt(D)
    return ((-B - sq) / (2 * A), (-B + sq) / (2 * A))
  }
  // ĐA DIỆN: mỗi MẶT PHẲNG cho một phương trình bậc nhất. Lấy mốc ở TẤT CẢ
  // mặt phẳng (không lọc theo bao mặt) — thừa mốc chỉ tốn một phép thử trung
  // điểm, còn thiếu mốc là bỏ sót nét khuất.
  if k.loai == "dadien" {
    let moc = ()
    for f in k.mp {
      let den = v3-vo-huong(f.n, e)
      if calc.abs(den) > 1e-12 {
        moc.push((f.d - v3-vo-huong(f.n, P)) / den)
      }
    }
    return moc
  }
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

// Đường tròn lớn của mặt cầu, nằm trong mặt phẳng có PHÁP TUYẾN `nrm`.
#let _tron-lon(k, nrm, n: 48) = tron-ngang(k.tam, k.r, truc: nrm, n: n)

// Các đường phải vẽ của một khối: mảng (pts, tu-che). `tu-che = false`
// nghĩa là đường BIÊN — không để chính khối đó che.
#let _duong-khoi(k, p, e, n: 48) = {
  // CẦU: biên là đường tròn lớn VUÔNG GÓC hướng nhìn (đúng với mọi phép
  // chiếu song song, kể cả chiếu xiên) ⇒ `tu-che: false` như đường sinh biên
  // của nón/trụ. Xích đạo/kinh tuyến thì để CHÍNH cầu che — nhờ vậy nửa sau
  // tự thành nét đứt mà không phải chia cung bằng tay.
  if k.loai == "cau" {
    let ds = ((_tron-lon(k, e, n: n), false),)
    if k.at("xich-dao", default: true) {
      ds.push((_tron-lon(k, k.w, n: n), true))
    }
    let sk = k.at("kinh-tuyen", default: 0)
    for i in range(sk) {
      let ph = 180deg * (i / sk)
      // mặt phẳng kinh tuyến chứa trục cực w và phương cos φ·u + sin φ·v,
      // pháp tuyến của nó là w × (cos φ·u + sin φ·v) = −sin φ·u + cos φ·v.
      let nrm = v3-cong(
        v3-nhan(-calc.sin(ph), k.u),
        v3-nhan(calc.cos(ph), k.v),
      )
      ds.push((_tron-lon(k, nrm, n: n), true))
    }
    return ds
  }
  // ĐA DIỆN: mỗi CẠNH là một đoạn thẳng, chia nhỏ để `_duong-tu-dong` cắt
  // được chỗ chui vào khối. `tu-che: true` — cạnh PHẢI để chính khối của nó
  // che, vì đó chính là cơ chế sinh ra nét khuất của đa diện (thay cho
  // back-face culling của da-dien.typ).
  if k.loai == "dadien" {
    let nc = calc.max(2, int(n / 2))
    return k.canh.map(c => {
      let A = k.dinh.at(c.at(0))
      let B = k.dinh.at(c.at(1))
      (range(nc + 1).map(i => v3-cong(A, v3-nhan(i / nc, v3-tru(B, A)))), true)
    })
  }
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
// BAO LỒI 2D — trả CHỈ SỐ theo thứ tự vòng. Dùng gói quà (Jarvis march):
// O(n²) nhưng n ≤ vài chục đỉnh, và KHÔNG phải sắp xếp mảng-khoá (Typst chưa
// chắc so sánh được hai mảng bằng `<`).
#let _bao-loi-cs(pts) = {
  let n = pts.len()
  if n < 3 { return range(n) }
  let i0 = 0
  for i in range(n) {
    let a = pts.at(i)
    let b = pts.at(i0)
    let bang-x = calc.abs(a.at(0) - b.at(0)) <= 1e-12
    if a.at(0) < b.at(0) - 1e-12 or (bang-x and a.at(1) < b.at(1)) { i0 = i }
  }
  let kq = ()
  let cur = i0
  let dem = 0
  while dem <= n {
    kq.push(cur)
    let nxt = calc.rem(cur + 1, n)
    for i in range(n) {
      if i == cur or i == nxt { continue }
      let o = pts.at(cur)
      let a = pts.at(nxt)
      let b = pts.at(i)
      let cheo = (a.at(0) - o.at(0)) * (b.at(1) - o.at(1)) - (a.at(1) - o.at(1)) * (b.at(0) - o.at(0))
      let da = calc.pow(a.at(0) - o.at(0), 2) + calc.pow(a.at(1) - o.at(1), 2)
      let db = calc.pow(b.at(0) - o.at(0), 2) + calc.pow(b.at(1) - o.at(1), 2)
      // b nằm ngoài cạnh (cur -> nxt), hoặc thẳng hàng mà XA hơn
      if cheo > 1e-12 or (calc.abs(cheo) <= 1e-12 and db > da) { nxt = i }
    }
    cur = nxt
    dem = dem + 1
    if cur == i0 { break }
  }
  kq
}

#let _bao-khoi(k, p, e, n: 48) = {
  if k.loai == "cau" { return _tron-lon(k, e, n: n) }
  // ĐA DIỆN: đường bao = BAO LỒI của các đỉnh ĐÃ CHIẾU (khối lồi nên hình
  // chiếu cũng lồi). Trả điểm 3D theo thứ tự vòng để chỗ gọi chiếu như mọi
  // khối khác. Đây là tô BÓNG KHỐI một màu, KHÔNG phải tô từng mặt như
  // `ve-da-dien` — muốn tô từng mặt thì dùng đường đi cũ.
  if k.loai == "dadien" {
    return _bao-loi-cs(k.dinh.map(p)).map(i => k.dinh.at(i))
  }
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
// `e` = hướng nhìn: CẦU không có vành cố định, chốt của nó chính là ĐƯỜNG
// BIÊN (đường tròn lớn vuông góc `e`) — lấy đúng đường bao nên khung hình
// khít, không phải nới rộng theo hộp bao r ở cả ba trục.
#let _chot-khoi(k, e, m: 12) = {
  if k.loai == "dadien" { return k.dinh }
  if k.loai == "cau" {
    let (u, v, w) = _khung(e)
    return range(m).map(i => {
      let t = 360deg * (i / m)
      v3-cong(
        k.tam,
        v3-cong(v3-nhan(k.r * calc.cos(t), u), v3-nhan(k.r * calc.sin(t), v)),
      )
    })
  }
  let ds = ()
  for h in (0, k.cao) {
    let bk = if k.loai == "non" and h == k.cao { 0.0 } else { k.r }
    for i in range(m) { ds.push(_diem-vanh(k, bk, 360deg * (i / m), h)) }
  }
  ds
}
#let _chot-tat-ca(ds, e) = {
  let kq = ()
  for k in ds { kq = kq + _chot-khoi(k, e) }
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
// Vẽ hệ trục Oxyz bằng CHÍNH camera của khối ⇒ cả khung hình chung một góc
// nghiêng (khác `oxyz`, vốn tự dựng phép chiếu xiên riêng).
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

// Chấm đỉnh + nhãn đỉnh cho khối đa diện. Hướng nhãn lấy PHÂN GIÁC KHE GÓC
// RỘNG NHẤT (`_huong-khe` mượn của da-dien.typ) nên nhãn không đè lên cạnh.
// `hien-khuat: false` thì bỏ luôn đỉnh bị che — phép thử là CHÍNH cơ chế bắn
// tia đang dùng cho nét, nên đỉnh và cạnh luôn nhất quán với nhau.
// ⚠️ PHẢI đặt SAU `_bi-che`: Typst phân giải tên lúc GỌI, hàm tham chiếu một
// binding định nghĩa phía dưới sẽ báo "unknown variable" khi chạy.
#let _diem-khoi(ctx, k, p, e, ds, hien-khuat: true, mau: black, cach: 6pt) = {
  if k.loai != "dadien" { return }
  let ten = k.at("ten", default: none)
  let hd = k.at("hien-dinh", default: true)
  if ten == none and not hd { return }
  let mk = if k.mau == auto { mau } else { k.mau }
  let hgs = k.at("huong", default: auto)
  let cx = k.at("cach", default: cach)
  let ke = (:)
  for c in k.canh {
    let (i, j) = c
    ke.insert(str(i), ke.at(str(i), default: ()) + (j,))
    ke.insert(str(j), ke.at(str(j), default: ()) + (i,))
  }
  for i in range(k.dinh.len()) {
    let P = k.dinh.at(i)
    if not hien-khuat and _bi-che(P, e, ds) { continue }
    let Q = p(P)
    let t = if ten == none { none } else { ten.at(i, default: none) }
    let hg = if hgs == auto {
      _huong-khe(ctx, Q, ke.at(str(i), default: ()).map(j => p(k.dinh.at(j))))
    } else { hgs.at(i, default: "above") }
    if hd {
      diem(ctx, Q, ten: t, huong: hg, bk: k.at("bk", default: 1.6pt),
        cach: cx, mau: mk, mau-ten: mk)
    } else if t != none {
      nhan(ctx, Q, t, huong: hg, cach: cx, mau: mk)
    }
  }
}

// =====================================================================
// VE-MAT-CONG — NHẬN ctx ⇒ PHẢI kê vào `ve-voi` và khối `_voi-ctx`
// =====================================================================
// Vẽ một hoặc nhiều khối nón/trụ/cầu/đa diện (trục đặt nghiêng được), TỰ chia
// nét liền/đứt bằng cách bắn tia về phía người nhìn — lo cả tự khuất lẫn hai
// khối che nhau.
// ve-mat-cong(mat-non(r: 2, cao: 4), khoi-cau(tam: (0, 0, 5), r: 1.4))
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
  // 4) chấm + nhãn đỉnh của các khối ĐA DIỆN — vẽ SAU nét để không bị đè
  for k in ds {
    _diem-khoi(ctx, k, p, e, ds, hien-khuat: hien-khuat, mau: mau)
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
  let chot = _chot-tat-ca(khoi.pos(), cm.nhin) + (if tr == none { () } else { _chot-truc(tr) })
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
