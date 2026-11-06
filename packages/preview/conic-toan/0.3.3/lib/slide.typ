// =====================================================================
// slide.typ — ENGINE TRÌNH CHIẾU THUẦN TYPST (16:9)
//
// Cách dùng:
//   #show: bai-giang.with(
//     tieu-de: [CHƯƠNG I. HÀM SỐ], gv: "Thầy/Cô ...", ...
//   )
//   #muc[1. Định nghĩa]
//   #slide(tieu-de: [Khái niệm])[ ... nội dung ... ]
//
// Khung nội dung: #dinh-nghia[...], #dinh-ly[...], #vi-du[...],
// #loi-giai[...], #chu-y[...], #ghi-nho[...], #nhan-xet[...], #luyen-tap[...]
// Bố cục: #chia-cot(trai, phai, ti-le: (3fr, 2fr))
// =====================================================================

// Bảng màu (đọc qua state để mọi hàm dùng chung).
#let _mau = state("bg-mau", (
  chinh: rgb("#0f4c81"),   // xanh đậm chủ đạo
  nhan: rgb("#e67e22"),    // cam nhấn
  nen: rgb("#f7f9fc"),
))
#let _thong-tin = state("bg-thong-tin", (tieu-de: [], gv: none, ngan: none))
#let _muc-ht = state("bg-muc", none)
#let _buoc-ht = state("bg-buoc", 1)     // bước hoạt hình hiện tại
#let _dem-slide = counter("bg-slide")   // số thứ tự slide (không tính bước)

// ----- Hồ sơ hiển thị: "beamer" (trình chiếu) hoặc bản in A4 -----
//   "sach-dethi"  : A4, ví dụ hiện lời giải, 4 loại câu ẩn đáp án.
//   "sach-loigiai": A4, mọi thứ hiện lời giải + đánh dấu đáp án.
#let _ho-so = state("bg-ho-so", "beamer")
#let _chuan-hs(hs) = lower(hs).replace("-", "").replace("_", "")
#let _la-sach(hs) = _chuan-hs(hs) != "beamer"   // khác beamer = bản in A4

// ----- KÍCH THƯỚC THÂN SLIDE 16:9 -----
// Rút thành hằng số để `slide()` và bộ TỰ NGẮT MÀN (che-do.typ) dùng CHUNG
// một bộ số — đổi lề ở đây là chỗ đo cũng đổi theo, không lệch nhau.
// `presentation-16-9` của Typst = 297mm × 167,06mm.
#let _kho-slide = (rong: 841.89pt, cao: 473.55pt)
#let _le-slide = (
  tren: 73pt,        // chừa thanh tiêu đề slide
  tren-tron: 26pt,   // slide không có tiêu đề
  duoi: 34pt,        // chừa thanh điều hướng
  ngang: 28pt,
  du: 8pt,           // hụt an toàn khi đo (đo bao giờ cũng có sai số)
)
// Vùng chữ thật sự của một slide — dùng để biết lời giải có tràn trang không.
#let _vung-than(co-tieu-de: true) = (
  rong: _kho-slide.rong - 2 * _le-slide.ngang,
  cao: _kho-slide.cao - _le-slide.duoi - _le-slide.du
    - (if co-tieu-de { _le-slide.tren } else { _le-slide.tren-tron }),
)

// ----- GIÃN DÒNG (khoảng cách giữa các dòng) -----
// `nen`   : leading NỀN của hồ sơ đang dùng (bai-giang/de-toan ghi vào);
// `he-so` : HỆ SỐ NHÂN do người dùng đặt — 1.0 = mốc mặc định,
//           1.3 = giãn thêm 30%, 0.9 = thu lại 10%.
// Cách đặt:
//   #bai-giang(gian-dong: 1.25)  /  #de-toan(gian-dong: 1.25)  — toàn tài liệu
//   #gian-dong(1.4)              — đổi giữa bài (áp cho các slide/khung sau đó)
//   #tn(..., gian-dong: 1.4)     — ghi đè RIÊNG một câu
// Dùng khi phân số / căn thức / chỉ số chồng tầng làm hai dòng dính nhau.
// `doan` = khoảng cách GIỮA HAI ĐOẠN (khi nội dung có DÒNG TRỐNG). Phải giãn
// theo cùng hệ số với `leading`, kẻo dòng nối bằng `\` (cùng một đoạn) thì
// giãn ra mà chỗ cách bằng dòng trống (sang đoạn mới) lại y nguyên — đó là lý
// do trước đây #voi-gian-dong "chỉ ăn đoạn đầu".
// 1.2em là mốc mặc định của Typst ⇒ he-so = 1.0 giữ nguyên bố cục mọi bài cũ.
#let _doan-nen = 1.2em
#let _gd = state("bg-gian-dong", (nen: 0.62em, doan: _doan-nen, he-so: 1.0))
#let _dat-gian(nen, k, doan: _doan-nen) = _gd.update((nen: nen, doan: doan, he-so: k))
#let gian-dong(k) = _gd.update(g => (
  nen: g.nen, doan: g.at("doan", default: _doan-nen), he-so: k))
// Ba helper dưới đây CHỈ gọi được trong `context`.
#let _he-so-gian() = _gd.get().he-so
#let _gian-ht() = {
  let g = _gd.get()
  g.nen * g.he-so
}
#let _gian-doan() = {
  let g = _gd.get()
  g.at("doan", default: _doan-nen) * g.he-so
}
// Áp hệ số giãn dòng cho MỘT KHỐI nội dung bất kì (phần còn lại không đổi):
//   #voi-gian-dong(1.4)[ ... đoạn nhiều phân số ... ]
// Giãn CẢ khoảng cách dòng lẫn khoảng cách đoạn.
#let voi-gian-dong(k, body) = context {
  let g = _gd.get()
  set par(leading: g.nen * k, spacing: g.at("doan", default: _doan-nen) * k)
  body
}

// ----- CHIỀU CAO THẬT CỦA CÔNG THỨC TRONG DÒNG (chống dính chữ) -----
// VÌ SAO CẦN: Typst đóng khung công thức TRONG DÒNG theo SỐ ĐO PHÔNG CHỮ
// (cap-height → đường chân chữ, ≈6.83pt ở cỡ 10pt) chứ KHÔNG theo nét vẽ thật.
// `measure($1/2$)` và `measure($0,5$)` vì thế ra CÙNG chiều cao, trong khi phân
// số vẽ ra cao ≈12pt và TRÀN cả trên lẫn dưới khung. Hệ quả:
//   • trong một đoạn: dòng không cao lên ⇒ tử số dòng dưới chạm mẫu dòng trên;
//   • trong ô của `grid` (phương án #tn, ý #ds, `cot-item`): ô cũng lấy chiều
//     cao HỤT đó ⇒ phân số đè sang hàng trên, mà `gian-dong` (chỉ chạm
//     par.leading/par.spacing) KHÔNG với tới được.
// Trước đây phải bù bằng `gian-dong: 3` — giãn ĐỀU cả bài, chỗ cần thì vừa,
// chỗ chữ thường thì trống hoác.
//
// CÁCH CHỮA: đo nét vẽ thật (top-edge/bottom-edge: "bounds" — xem `co-net` của
// ve.typ) rồi chèn một CỘT CHỐNG vô hình RỘNG 0 ngay trước công thức, cao đúng
// phần nét nhô lên/thò xuống. Cột chống là hộp trong dòng nên Typst tính nó vào
// chiều cao dòng VÀ chiều cao ô ⇒ dòng/ô tự nới ĐÚNG chỗ cần, chữ thường không
// đổi một pt nào. Vì rộng 0 nên `measure(...).width` (chỗ `cot: auto` chọn số
// cột) cũng không đổi.
// CỐ Ý dùng cột chống chứ KHÔNG bọc công thức trong `box`: bọc box sẽ chặn
// Typst ngắt dòng giữa công thức dài.
//   bat    : bật/tắt toàn bộ cơ chế.
//   nguong : nét tràn dưới mức này thì bỏ qua (khỏi chèn cột chống vô ích).
//   them   : nới thêm bấy nhiêu ở MỖI phía (chỉ dùng khi muốn thoáng hơn nữa).
#let _cao-that = state("bg-cao-that", (bat: true, nguong: 1pt, them: 0pt, chia: 0.5, hien: false))

// #cao-that(false) — tắt từ đây trở đi;  #cao-that() — bật lại;
// #cao-that(them: 1pt) — nới thêm 1pt mỗi phía cho mọi công thức có tràn nét.
// Dùng SINK để nhận `bat` ở dạng ĐỐI SỐ VỊ TRÍ mà vẫn gọi được #cao-that().
// hien: true — CHẨN ĐOÁN, in phần `thieu` (pt) màu đỏ ngay sau mỗi công thức.
// Không thấy số đỏ nào hiện ra ⇒ bản lib đang chạy KHÔNG phải bản này.
#let cao-that(..a, nguong: auto, them: auto, chia: auto, hien: auto) = {
  let bat = if a.pos().len() > 0 { a.pos().first() } else { true }
  _cao-that.update(c => (
    bat: bat,
    nguong: if nguong == auto { c.at("nguong", default: 1pt) } else { nguong },
    them: if them == auto { c.at("them", default: 0pt) } else { them },
    chia: if chia == auto { c.at("chia", default: 0.5) } else { chia },
    hien: if hien == auto { c.at("hien", default: false) } else { hien },
  ))
}

// (tren, duoi) = phần NÉT VẼ nhô lên trên / thò xuống dưới đường chân chữ.
// CHỈ gọi trong `context`.
#let _do-net(nd) = (
  measure({ set text(top-edge: "bounds", bottom-edge: "baseline"); nd }).height,
  measure({ set text(top-edge: "baseline", bottom-edge: "bounds"); nd }).height,
)

// ⚠️ KHÔNG tách được nét vẽ thành (trên, dưới) một cách đáng tin. Đã thử và
// SAI: với công thức CAO (nhất là khi tài liệu bật `math.display` cho công
// thức trong dòng — kiểu \displaystyle của LaTeX, người dùng rất hay dùng để
// phân số to đẹp), hai phép đo một phía trả về CÙNG một số (đo được 17.31 /
// 17.31 cho `$1/2$`), tức mỗi phép đo đã gồm cả hai phía ⇒ cộng lại là nới
// GẤP ĐÔI. Đừng quay lại lối đó.
//
// LỐI ĐÚNG — TỰ HIỆU CHỈNH, chỉ dùng phép đo CẢ DÒNG (đáng tin):
//   du  = nét vẽ dòng "mẫu + công thức" trừ nét vẽ dòng "mẫu"  → chỗ ink CẦN
//   hop = khung dòng "mẫu + công thức" trừ khung dòng "mẫu"    → chỗ Typst CHO
//   thieu = du − hop                                           → phần TRÀN
// `thieu` chính là phần đè sang hàng trên/dòng trên. Cách này không phụ thuộc
// vào việc Typst tính khung công thức thế nào, nên đúng với cả math.display,
// cả phông chữ khác, cả cỡ chữ khác.
#let _mau-chu = [Ág]

#let _cao-ink(nd) = measure({
  set text(top-edge: "bounds", bottom-edge: "bounds")
  nd
}).height

// Cột chống vô hình + chính công thức. Thiếu ít hơn `nguong` ⇒ TRẢ NGUYÊN.
// `chia` = phần `thieu` dồn xuống DƯỚI đường chân chữ (0.5 = chia đôi, hợp với
// phân số vì tử tràn lên còn mẫu tràn xuống gần bằng nhau).
#let _chong-net(nd) = context {
  let c = _cao-that.get()
  if not c.at("bat", default: true) { nd } else {
    let mau = _mau-chu
    let ca = [#mau#nd]
    let du = _cao-ink(ca) - _cao-ink(mau)
    let hop = measure(ca).height - measure(mau).height
    let thieu = calc.max(0pt, du - hop)
    let ng = c.at("nguong", default: 1pt)
    let them = c.at("them", default: 0pt)
    let chia = c.at("chia", default: 0.5)
    // Chỉ chèn cột chống khi thật sự tràn; không tràn thì KHÔNG thêm gì cả.
    if thieu > ng {
      box(width: 0pt, height: measure(nd).height + thieu + 2 * them,
        baseline: thieu * chia + them)
    }
    nd
    // Chẩn đoán: #cao-that(hien: true) -> in số `thieu` màu đỏ sau công thức.
    if c.at("hien", default: false) {
      text(size: 6pt, fill: red, weight: "bold")[ (#calc.round(thieu.pt(), digits: 2))]
    }
  }
}

// Áp cơ chế cho MỘT khối bất kì (bai-giang/de-toan đã tự áp cho cả tài liệu):
//   #voi-cao-that[ ... ]
#let voi-cao-that(body) = {
  show math.equation.where(block: false): _chong-net
  body
}

// ----- Bộ đếm "đóng băng" theo slide -----
// Slide hoạt hình được in thành nhiều trang lặp; nếu đếm kiểu thường thì
// "Ví dụ 1" sẽ thành "Ví dụ 2, 3..." qua từng bước. Cách giải quyết:
//   goc = tổng tích luỹ đến HẾT slide trước (state),
//   cnt = đếm trong slide, được ĐẶT LẠI ở mỗi bước lặp,
//   số hiển thị = goc + cnt  =>  không đổi giữa các bước.
#let _bd-cau = (goc: state("bg-goc-cau", 0), cnt: counter("bg-cnt-cau"))
#let _bd-vd = (goc: state("bg-goc-vd", 0), cnt: counter("bg-cnt-vd"))
#let _bd-lt = (goc: state("bg-goc-lt", 0), cnt: counter("bg-cnt-lt"))
#let _bd-hd = (goc: state("bg-goc-hd", 0), cnt: counter("bg-cnt-hd"))
#let _bd-vdtt = (goc: state("bg-goc-vdtt", 0), cnt: counter("bg-cnt-vdtt"))
#let _bd-tat-ca = (_bd-cau, _bd-vd, _bd-lt, _bd-hd, _bd-vdtt)

// Tăng bộ đếm và hiển thị số hiện tại.
#let _so-moi(bd) = {
  bd.cnt.step()
  context [#(bd.goc.get() + bd.cnt.get().first())]
}

// =====================================================================
// TRANG BÌA — 5 kiểu (kieu-bia: 1..5 hoặc tên)
//   1 "toi-gian"      Tối giản & Thanh lịch
//   2 "tre-trung"     Trẻ trung & Sáng tạo
//   3 "co-dien"       Chuẩn mực Học thuật Cổ điển
//   4 "chuyen-nghiep" Chuyên nghiệp & Khoa học
//   5 "ky-thuat"      Tiêu chuẩn cho Tài liệu Kỹ thuật
// Mỗi kiểu có tông màu MẶC ĐỊNH riêng; nếu người dùng truyền mau-chinh /
// mau-nhan (khác auto) thì màu đó GHI ĐÈ tông mặc định.
// =====================================================================

// Tông màu mặc định của từng kiểu bìa: (chính, nhấn).
#let _bia-mau(kieu) = (
  (chinh: rgb("#0f4c81"), nhan: rgb("#e67e22")),   // 1 tối giản   — navy + cam (mặc định, giữ tương thích)
  (chinh: rgb("#5b2a86"), nhan: rgb("#ff5d73")),   // 2 trẻ trung  — tím + hồng san hô
  (chinh: rgb("#14213d"), nhan: rgb("#c8a24b")),   // 3 cổ điển    — navy + vàng đồng
  (chinh: rgb("#0f4c81"), nhan: rgb("#17a2b8")),   // 4 chuyên nghiệp — xanh + lam ngọc
  (chinh: rgb("#263238"), nhan: rgb("#ef6c00")),   // 5 kỹ thuật   — xám lam + cam
).at(kieu - 1)

// Chuẩn hoá kieu-bia: nhận số 1..5 hoặc chuỗi tên.
#let _bia-so(k) = {
  if type(k) == int { return calc.max(1, calc.min(5, k)) }
  let s = lower(str(k)).replace("-", "").replace("_", "").replace(" ", "")
  (
    toigian: 1, thanhlich: 1, minimal: 1,
    tretrung: 2, sangtao: 2, creative: 2,
    codien: 3, hocthuat: 3, classic: 3,
    chuyennghiep: 4, khoahoc: 4, pro: 4,
    kythuat: 5, tailieu: 5, tech: 5,
  ).at(s, default: 1)
}

// Logo: PHẢI truyền image(...) — không nhận chuỗi đường dẫn. Vì image() gọi
// trong file này (bên trong package) sẽ tìm ảnh CẠNH package, không phải cạnh
// file bài giảng của người dùng. Bọc image(...) trong file người dùng thì Typst
// mới tìm đúng thư mục. Truyền chuỗi => panic có hướng dẫn.
#let _bia-logo(logo, cao) = if logo != none {
  if type(logo) == str {
    panic("logo phải bọc image(...): dùng  logo: image(\"" + logo + "\")  thay cho chuỗi \"" + logo + "\" (ảnh đặt cùng thư mục file .typ của bạn).")
  }
  box(height: cao, logo)
}

// Gom các trường phụ có giá trị thành mảng (nhan, gia-tri).
#let _bia-truong(mon, lop, gv, ngay) = {
  let ds = ()
  if mon != none { ds.push(("Môn", mon)) }
  if lop != none { ds.push(("Lớp", lop)) }
  if gv != none { ds.push(("Giáo viên", gv)) }
  if ngay != none { ds.push(("Ngày", ngay)) }
  ds
}

#let _co(x) = x != none

// ---------- Kiểu 1: Tối giản & Thanh lịch ----------
#let _bia-1(c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay) = {
  place(rect(width: 100%, height: 100%, fill: white))
  place(bottom, rect(width: 100%, height: 5pt, fill: n))
  place(top + right, dx: -2.4cm, dy: 2.2cm, _bia-logo(logo, 1.9cm))
  place(left + horizon, dx: 2.6cm, block(width: 19.5cm, {
    rect(width: 42pt, height: 4pt, fill: n)
    v(18pt)
    if _co(don-vi) {
      text(size: 12.5pt, tracking: 2.5pt, fill: luma(45%), upper(don-vi))
      v(14pt)
    }
    text(fill: c, weight: "bold", size: 40pt, tieu-de)
    if _co(phu-de) { v(10pt); text(size: 19pt, fill: luma(38%), phu-de) }
    v(22pt)
    line(length: 6.5cm, stroke: 0.6pt + luma(55%))
    v(16pt)
    let ds = _bia-truong(mon, lop, gv, ngay)
    if ds.len() > 0 {
      text(size: 14pt, fill: c.darken(5%), ds.map(p =>
        [#text(fill: luma(50%))[#p.at(0): ]#p.at(1)]).join(text(fill: n)[#h(10pt)•#h(10pt)]))
    }
  }))
}

// ---------- Kiểu 2: Trẻ trung & Sáng tạo ----------
#let _bia-2(c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay) = {
  place(rect(width: 100%, height: 100%,
    fill: gradient.linear(c, n, angle: 40deg)))
  // Khối hình học trang trí (bán trong suốt).
  place(top + right, dx: 2.5cm, dy: -3cm,
    circle(radius: 4.4cm, fill: white.transparentize(80%)))
  place(bottom + left, dx: -2.6cm, dy: 2.6cm,
    circle(radius: 3.4cm, fill: white.transparentize(85%)))
  place(top + left, dx: 3.2cm, dy: 2.4cm,
    box(rotate(18deg, rect(width: 26pt, height: 26pt, radius: 6pt,
      fill: white.transparentize(70%)))))
  place(bottom + right, dx: -3.6cm, dy: -2.4cm,
    box(rotate(12deg, rect(width: 34pt, height: 34pt, radius: 8pt,
      fill: white.transparentize(78%)))))
  place(top + right, dx: -2.2cm, dy: 2cm, _bia-logo(logo, 1.7cm))
  place(center + horizon, align(center, block(width: 21cm, {
    if _co(don-vi) {
      box(fill: white.transparentize(78%), radius: 20pt, inset: (x: 16pt, y: 7pt),
        text(fill: white, size: 13pt, weight: "medium", tracking: 1pt, upper(don-vi)))
      v(20pt)
    }
    text(fill: white, weight: "bold", size: 42pt, tieu-de)
    if _co(phu-de) {
      v(12pt)
      text(fill: white.transparentize(12%), size: 21pt, phu-de)
    }
    v(26pt)
    let ds = _bia-truong(mon, lop, gv, ngay)
    if ds.len() > 0 {
      grid(columns: ds.len(), column-gutter: 12pt,
        ..ds.map(p => box(fill: white.transparentize(82%), radius: 10pt,
          inset: (x: 14pt, y: 9pt), align(center, {
            text(fill: white.transparentize(20%), size: 10pt, upper(p.at(0)))
            linebreak()
            text(fill: white, size: 14pt, weight: "bold", p.at(1))
          }))))
    }
  })))
}

// ---------- Kiểu 3: Chuẩn mực Học thuật Cổ điển ----------
#let _bia-3(c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay) = {
  place(rect(width: 100%, height: 100%, fill: rgb("#f6f1e6")))
  // Khung viền kép cổ điển.
  place(center + horizon, rect(width: 100% - 1.6cm, height: 100% - 1.6cm,
    stroke: 1.4pt + c))
  place(center + horizon, rect(width: 100% - 2.0cm, height: 100% - 2.0cm,
    stroke: 0.6pt + n))
  place(center + horizon, align(center, block(width: 20cm, {
    _bia-logo(logo, 2.1cm)
    if _co(logo) { v(14pt) }
    if _co(don-vi) {
      text(size: 14pt, tracking: 3pt, fill: c, upper(don-vi))
      v(6pt)
    }
    // Đường phân cách trang trí ✦
    grid(columns: (1fr, auto, 1fr), column-gutter: 12pt, align: horizon,
      line(length: 100%, stroke: 0.6pt + n),
      text(fill: n, size: 13pt, "✦"),
      line(length: 100%, stroke: 0.6pt + n))
    v(18pt)
    text(fill: c, weight: "bold", size: 38pt,
      font: ("Charis SIL", "Noto Serif", "Libertinus Serif"), tieu-de)
    if _co(phu-de) {
      v(12pt)
      text(size: 19pt, style: "italic", fill: c.lighten(15%), phu-de)
    }
    v(18pt)
    grid(columns: (1fr, auto, 1fr), column-gutter: 12pt, align: horizon,
      line(length: 100%, stroke: 0.6pt + n),
      text(fill: n, size: 13pt, "✦"),
      line(length: 100%, stroke: 0.6pt + n))
    v(20pt)
    let ds = _bia-truong(mon, lop, gv, ngay)
    if ds.len() > 0 {
      text(size: 14pt, fill: c, ds.map(p =>
        [#emph[#p.at(0):] #p.at(1)]).join(h(18pt)))
    }
  })))
}

// ---------- Kiểu 4: Chuyên nghiệp & Khoa học ----------
#let _bia-4(c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay) = {
  place(rect(width: 100%, height: 100%, fill: white))
  // Dải màu dọc bên trái (~38%).
  place(left + top, rect(width: 38%, height: 100%,
    fill: gradient.linear(c, c.darken(30%), angle: 90deg)))
  place(left + top, dx: 38%, rect(width: 6pt, height: 100%, fill: n))
  // Nội dung panel trái.
  place(left + horizon, dx: 1.6cm, block(width: 8cm, {
    _bia-logo(logo, 2cm)
    if _co(logo) { v(20pt) }
    if _co(don-vi) {
      text(fill: white, size: 15pt, weight: "bold", don-vi)
      v(16pt)
    }
    let ds = _bia-truong(mon, lop, gv, ngay)
    for p in ds {
      text(fill: white.transparentize(45%), size: 10.5pt, upper(p.at(0)))
      linebreak()
      text(fill: white, size: 14pt, weight: "medium", p.at(1))
      v(9pt)
    }
  }))
  // Nội dung bên phải.
  place(left + horizon, dx: 38% + 1.4cm, block(width: 13cm, {
    rect(width: 46pt, height: 5pt, fill: n)
    v(16pt)
    text(fill: c, weight: "bold", size: 34pt, tieu-de)
    if _co(phu-de) {
      v(12pt)
      text(fill: luma(35%), size: 19pt, phu-de)
    }
  }))
}

// ---------- Kiểu 5: Tiêu chuẩn cho Tài liệu Kỹ thuật ----------
#let _bia-5(c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay) = {
  place(rect(width: 100%, height: 100%, fill: white))
  // Thanh đầu trang.
  place(top, block(width: 100%, height: 1.7cm, fill: c,
    align(horizon, pad(x: 1.6cm, grid(columns: (1fr, auto), align: horizon + left,
      text(fill: white, size: 14pt, weight: "bold", tracking: 1pt,
        if _co(don-vi) { upper(don-vi) } else { [TÀI LIỆU] }),
      _bia-logo(logo, 1.1cm))))))
  place(top, dy: 1.7cm, rect(width: 100%, height: 4pt, fill: n))
  // Nhãn loại tài liệu + tiêu đề.
  place(left + horizon, dx: 1.7cm, dy: -1.2cm, block(width: 21cm, {
    box(fill: n, inset: (x: 10pt, y: 4pt), radius: 3pt,
      text(fill: white, size: 11pt, weight: "bold", tracking: 2pt,
        font: ("DejaVu Sans Mono", "Consolas"), "TAI-LIEU / DOC"))
    v(16pt)
    text(fill: c, weight: "bold", size: 36pt, tieu-de)
    if _co(phu-de) {
      v(10pt)
      text(fill: luma(35%), size: 19pt, phu-de)
    }
    v(22pt)
    // Bảng siêu dữ liệu.
    let ds = _bia-truong(mon, lop, gv, ngay)
    if ds.len() > 0 {
      block(stroke: (left: 3pt + n), inset: (left: 14pt, y: 2pt),
        grid(columns: (auto, auto), column-gutter: 16pt, row-gutter: 7pt,
          ..ds.map(p => (
            text(fill: luma(45%), size: 12.5pt,
              font: ("DejaVu Sans Mono", "Consolas"), upper(p.at(0)) + " :"),
            text(fill: c, size: 13.5pt, weight: "medium", p.at(1)),
          )).flatten()))
    }
  }))
  // Thanh chân trang.
  place(bottom, block(width: 100%, height: 0.8cm, fill: c.lighten(8%),
    align(horizon, pad(x: 1.6cm, text(fill: white.transparentize(25%), size: 9.5pt,
      font: ("DejaVu Sans Mono", "Consolas"),
      if _co(ngay) { [\/\/ #ngay] } else { [\/\/ bài giảng · typst] })))))
}

// Dispatch trang bìa theo kiểu.
#let _ve-bia(kieu, c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay) = {
  let f = (_bia-1, _bia-2, _bia-3, _bia-4, _bia-5).at(kieu - 1)
  block(width: 100%, height: 100%,
    f(c, n, don-vi, logo, tieu-de, phu-de, mon, lop, gv, ngay))
}

// ---------- Thiết lập tổng ----------
// (bai-giang: điểm vào chính của hệ thống trình chiếu)
#let bai-giang(
  tieu-de: [BÀI GIẢNG TOÁN],
  tieu-de-ngan: none,  // tên bài rút gọn hiện trên DẢI ĐẦU TRANG của mọi
                       // slide (beamer); none => dùng nguyên tieu-de
  phu-de: none,
  gv: none,
  don-vi: none,
  ngay: none,
  lop: none,           // Lớp/khối hiện trên BÌA (vd "Lớp 12A1")
  mon: none,           // Môn/chương hiện trên BÌA (vd "Đại số & Giải tích")
  logo: none,          // Logo trường trên BÌA: đường dẫn ảnh HOẶC nội dung ảnh
  kieu-bia: 1,         // KIỂU TRANG BÌA: 1..5 hoặc tên
                       //   1 "toi-gian"  2 "tre-trung"  3 "co-dien"
                       //   4 "chuyen-nghiep"  5 "ky-thuat"
  mau-chinh: auto,     // auto = dùng TÔNG MẶC ĐỊNH của kieu-bia; đặt màu để GHI ĐÈ
  mau-nhan: auto,      // auto = dùng tông nhấn mặc định của kieu-bia
  nen: "trang",        // NỀN SLIDE (beamer): "trang" | "kem" | "xanh-nhat"
                       // | "luc-nhat" | "xam" — hoặc màu tuỳ ý: rgb("#fdf8ee")
                       // (chọn tông SÁNG để hình vẽ/bảng nét sẫm còn rõ)
  // Charis SIL đứng ĐẦU: font của SIL, thiết kế riêng cho dấu CHỒNG tiếng Việt
  // (Ể Ổ Ữ Ẩ...). Với chữ HOA (tiêu đề đề thi) nó vẫn giữ dấu hỏi/ngã NGUYÊN CỠ
  // và chồng THẲNG trên dấu mũ; Noto Serif thu nhỏ + đẩy lệch phải, còn
  // Libertinus/Times vẽ hook nhỏ nằm ngang -> nhìn như mất dấu.
  phong: ("Charis SIL", "Noto Serif", "Libertinus Serif", "Times New Roman"),
  co-chu: 19pt,
  ti-le-chu: 1.0,      // HỆ SỐ PHÓNG CỠ CHỮ THÂN NỘI DUNG (toàn file):
                       // 1.0 = giữ nguyên; 1.1 = to hơn 10%; 0.9 = nhỏ đi 10%.
                       // Nhân vào cỡ chữ nền -> mọi phần thân + khung dùng em
                       // (định nghĩa/ví dụ/lời giải...) co giãn theo; các thanh
                       // tiêu đề/header/footer (pt tuyệt đối) giữ nguyên.
  gian-dong: 1.0,      // HỆ SỐ GIÃN DÒNG thân nội dung (toàn file):
                       // 1.0 = mốc mặc định (A4 0.6em, trình chiếu 0.62em);
                       // 1.25 = giãn thêm 25%; 0.9 = thu lại 10%. Tăng khi
                       // phân số/căn thức nhiều tầng làm hai dòng dính nhau.
                       // Đổi giữa bài: #gian-dong(1.4); riêng một câu:
                       // #vd/#tn/#ds/... (gian-dong: 1.4).
  mau-cong-thuc: auto, // MÀU MỌI CÔNG THỨC/KÍ HIỆU trong $...$ (toàn file):
                       // auto (mặc định) = thừa kế màu chữ xung quanh — thân
                       // bài màu đen nên công thức hiển thị ĐEN, còn công thức
                       // nằm trong tiêu đề/bìa (chữ trắng) vẫn TRẮNG. Đặt một
                       // màu cụ thể, vd rgb("#0f4c81"), để nhuộm TẤT CẢ công
                       // thức theo màu đó (kể cả trong thanh tiêu đề).
  ho-so: "beamer",     // "beamer" | "sach-dethi" | "sach-loigiai"
  body,
) = {
  _ho-so.update(_chuan-hs(ho-so))
  // Giải màu theo kiểu bìa: auto -> tông mặc định của kieu-bia; nếu người
  // dùng truyền màu cụ thể thì GHI ĐÈ. mau-chinh/mau-nhan cũng là màu chủ đạo
  // của toàn slide (header/footer/khung) nên bìa và bài luôn đồng bộ.
  let _kb = _bia-so(kieu-bia)
  let _tm = _bia-mau(_kb)
  let mau-chinh = if mau-chinh == auto { _tm.chinh } else { mau-chinh }
  let mau-nhan = if mau-nhan == auto { _tm.nhan } else { mau-nhan }
  // Nền slide: tên preset hoặc màu tuỳ ý; chân trang tự pha đậm hơn một chút.
  let _giay = if type(nen) == str {
    (
      trang: white,
      kem: rgb("#fdf8ee"),
      xanhnhat: rgb("#eef4fb"),
      lucnhat: rgb("#f1f8f2"),
      xam: rgb("#f4f5f7"),
    ).at(lower(nen).replace("-", "").replace("_", ""), default: white)
  } else { nen }
  _mau.update((
    chinh: mau-chinh, nhan: mau-nhan,
    nen: if type(_giay) == color { _giay.darken(3%) } else { rgb("#f7f9fc") },
  ))
  _thong-tin.update((
    tieu-de: tieu-de, gv: gv,
    ngan: if tieu-de-ngan == none { tieu-de } else { tieu-de-ngan },
  ))
  // Cỡ công thức bằng thân; màu: auto = thừa kế (đen ở thân, trắng ở tiêu đề),
  // hoặc nhuộm theo mau-cong-thuc nếu chỉ định.
  show math.equation: it => {
    set text(size: 1em)
    // Lưu ý: set text(fill) phải ĐI TRƯỚC `it` trong CÙNG nhánh mới áp được;
    // đặt trong `if {...}` rồi để `it` ngoài thì fill KHÔNG tác dụng.
    if mau-cong-thuc == auto { it } else {
      set text(fill: mau-cong-thuc)
      it
    }
  }

  if _la-sach(ho-so) {
    // ================= BẢN IN A4 (sách / đề) =================
    // Công tắc đáp án: "loigiai" -> hiện tất cả; ngược lại (dethi) -> ẩn.
    state("ch-hien-da", false).update(_chuan-hs(ho-so).contains("loigiai"))
    _buoc-ht.update(1000000)   // mọi #lo(n) hiện hết trên bản in
    set page(
      paper: "a4",
      margin: (x: 2cm, top: 2cm, bottom: 2cm),
      fill: white,
      footer: context align(center, text(size: 9pt, fill: luma(40%),
        [Trang #counter(page).display() / #counter(page).final().first()])),
    )
    set text(font: phong, size: 11.5pt * ti-le-chu, lang: "vi", fill: rgb("#1c2833"))
    _dat-gian(0.6em, gian-dong)
    set par(justify: true, leading: 0.6em * gian-dong, spacing: _doan-nen * gian-dong)
    // Công thức trong dòng khai ĐÚNG chiều cao nét vẽ ⇒ dòng/ô tự nới đúng chỗ.
    show math.equation.where(block: false): _chong-net
    set heading(numbering: none)   // không đánh số — chỉ dùng thanh màu
    // Thanh tiêu đề màu thay cho heading (giữ heading để có bookmark + mục lục).
    show heading.where(level: 1): it => block(width: 100%, above: 16pt, below: 10pt,
      block(width: 100%, fill: mau-chinh, inset: (x: 12pt, y: 7pt), radius: 4pt,
        text(fill: white, weight: "bold", size: 1.15em, it.body)))
    show heading.where(level: 2): it => block(width: 100%, above: 13pt, below: 7pt, {
      block(width: 100%, fill: mau-chinh, inset: (x: 10pt, y: 5pt),
        radius: (top: 4pt, rest: 0pt),
        text(fill: white, weight: "bold", size: 1.05em, it.body))
      block(width: 100%, height: 2.5pt, fill: mau-nhan)
    })
    // ----- Tiêu đề tài liệu -----
    align(center, {
      if don-vi != none { text(size: 12pt, fill: luma(30%), don-vi); linebreak() }
      text(weight: "bold", size: 17pt, fill: mau-chinh, tieu-de)
      if phu-de != none { linebreak(); v(2pt); text(size: 12pt, fill: luma(25%), phu-de) }
      if gv != none { linebreak(); v(3pt); text(size: 11pt, style: "italic", [Giáo viên: #gv]) }
      if ngay != none { linebreak(); text(size: 10pt, fill: luma(40%), ngay) }
    })
    v(4pt)
    line(length: 100%, stroke: 0.8pt + mau-chinh)
    v(2pt)
    body
  } else {
    // ================= BẢN TRÌNH CHIẾU 16:9 =================
    // Bật công tắc đáp án: khi trình chiếu, đáp án luôn được đánh dấu
    // ở bước lo-da (bước cuối) của mỗi câu. Muốn ẩn hẳn: #tat-dap-an().
    state("ch-hien-da", false).update(true)
    set page(paper: "presentation-16-9", margin: 0pt, fill: _giay)
    set text(font: phong, size: co-chu * ti-le-chu, lang: "vi", fill: rgb("#1c2833"))
    _dat-gian(0.62em, gian-dong)
    set par(justify: false, leading: 0.62em * gian-dong, spacing: _doan-nen * gian-dong)
    show math.equation.where(block: false): _chong-net

    // ----- Trang bìa (1 trong 5 kiểu) -----
    _ve-bia(_kb, mau-chinh, mau-nhan, don-vi, logo, tieu-de, phu-de,
      mon, lop, gv, ngay)

    body
  }
}

// ---------- Gỡ enum trong tiêu đề ----------
// Nội dung "[1. Tên mục]" bị Typst parse thành MỤC DANH SÁCH đánh số (enum);
// khi căn phải/giữa, số "1." bị tách xa phần chữ. Hàm này gỡ về chữ thường.
#let _go-enum(nd) = {
  if type(nd) != content { return nd }
  if nd.func() == enum.item {
    let so = nd.at("number", default: none)
    if so == none { nd.body } else { [#so. #nd.body] }
  } else if nd.func() == list.item {
    nd.body
  } else if nd.has("children") {
    nd.children.map(c => _go-enum(c)).join()
  } else { nd }
}

// ---------- Slide mục (chuyển phần) ----------
// ngan: tên rút gọn hiển thị trên thanh điều hướng (mặc định = ten).
#let muc(ten, ngan: none) = {
  let ten = _go-enum(ten)
  let ngan = _go-enum(ngan)
  _muc-ht.update(ten)
  context {
    if _la-sach(_ho-so.get()) {
      // Bản in: mở phần mới ở đầu trang, tiêu đề = heading cấp 1 (thanh màu).
      pagebreak(weak: true)
      heading(level: 1, ten)
    } else {
      pagebreak(weak: true)
      // mốc điều hướng: tên mục + vị trí (để tạo liên kết)
      place([#metadata((
        loai: "muc", ten: ten,
        ngan: if ngan == none { ten } else { ngan },
      ))<bg-nav>])
      let m = _mau.get()
      block(width: 100%, height: 100%, {
        place(rect(width: 100%, height: 100%, fill: m.chinh))
        place(left + horizon, rect(width: 10pt, height: 42%, fill: m.nhan))
        place(center + horizon, align(center,
          text(fill: white, weight: "bold", size: 30pt, ten)
        ))
      })
    }
  }
}

// ---------- Slide thường ----------
// so-buoc: số bước hoạt hình — slide được in thành so-buoc trang,
// kết hợp với #lo(n)[...] / #chi(n)[...] / lo-da của câu hỏi.
// Nội dung dài quá một trang sẽ TỰ NGẮT sang trang kế tiếp:
// đầu/chân trang lặp lại, số slide và chấm điều hướng giữ nguyên.
#let slide(tieu-de: none, so-buoc: 1, body) = context {
  let tieu-de = _go-enum(tieu-de)
  // Giãn dòng hiện hành (nen × he-so) — đặt lại ở mỗi slide để #gian-dong(k)
  // gọi giữa bài có tác dụng cho các slide phía sau. Với he-so = 1.0 giá trị
  // này TRÙNG mốc mặc định nên bố cục không đổi.
  let _gl = _gian-ht()
  let _gs = _gian-doan()
  if _la-sach(_ho-so.get()) {
    // Bản in A4: thanh tiêu đề màu (heading cấp 2) + nội dung chảy liên tục.
    if tieu-de != none { heading(level: 2, tieu-de) }
    block(above: 4pt, below: 12pt, {
      set par(leading: _gl, spacing: _gs)
      body
    })
  } else {
  for k in range(1, so-buoc + 1) {
    set page(
      margin: (
        top: if tieu-de != none { _le-slide.tren } else { _le-slide.tren-tron },
        bottom: _le-slide.duoi, x: 0pt,
      ),
      header-ascent: 12pt,
      footer-descent: 12pt,
      // đầu trang: thanh tiêu đề (lặp lại nếu slide tràn trang)
      header: if tieu-de != none {
        context {
          let m = _mau.get()
          let tt = _thong-tin.get()
          let mh = _muc-ht.get()
          // Dải trên (đậm hơn): TÊN BÀI HỌC nổi bật trên MỌI slide,
          // kèm tên mục hiện tại ở góc phải.
          block(width: 100%, height: 17pt, fill: m.chinh.darken(30%), below: 0pt,
            align(horizon, pad(x: 26pt, grid(
              columns: (auto, 1fr), column-gutter: 14pt,
              align: (left + horizon, right + horizon),
              if tt.ngan != none {
                text(fill: white, weight: "bold", size: 10.5pt, tt.ngan)
              } else { [] },
              if mh != none {
                text(fill: white.transparentize(40%), size: 9.5pt, mh)
              } else { [] },
            ))))
          // Thanh tiêu đề slide (như cũ, đủ chỗ cho tiêu đề dài).
          block(width: 100%, height: 44pt, fill: m.chinh, above: 0pt,
            align(horizon, pad(x: 26pt,
              text(fill: white, weight: "bold", size: 21pt, tieu-de))))
        }
      },
      // chân trang: thanh điều hướng + số slide (không tăng theo bước)
      footer: context {
        let m = _mau.get()
        block(width: 100%, height: 22pt, fill: m.nen, {
          place(top, line(length: 100%, stroke: 0.5pt + m.chinh.lighten(55%)))
          let tat-ca = query(<bg-nav>)
          let mh = _muc-ht.get()
          let so-ht = _dem-slide.get().first()
          align(horizon, pad(x: 26pt, grid(
            columns: (auto, 1fr, auto),
            column-gutter: 14pt,
            // tên các mục — bấm để nhảy tới đầu mục
            {
              for (i, e) in tat-ca.filter(e => e.value.loai == "muc").enumerate() {
                if i > 0 { h(11pt) }
                let ht = e.value.ten == mh
                link(e.location(), text(size: 9pt,
                  weight: if ht { "bold" } else { "regular" },
                  fill: if ht { m.chinh } else { m.chinh.lighten(42%) },
                  e.value.ngan))
              }
            },
            // chấm tròn: các slide trong mục hiện tại — bấm để nhảy tới slide
            align(right, {
              for e in tat-ca.filter(e => e.value.loai == "slide" and e.value.muc == mh) {
                h(4pt)
                link(e.location(), box(baseline: 30%, circle(radius: 2.6pt,
                  fill: if e.value.so == so-ht { m.chinh } else { white },
                  stroke: 0.7pt + m.chinh)))
              }
            }),
            text(size: 10pt, fill: m.chinh,
              [#so-ht / #_dem-slide.final().first()]),
          )))
        })
      },
    )
    pagebreak(weak: true)
    _buoc-ht.update(k)
    // đặt lại bộ đếm trong-slide ở mỗi bước để số thứ tự không tăng
    for bd in _bd-tat-ca { bd.cnt.update(0) }
    // mốc điều hướng (chỉ đặt ở bước 1 — đích của liên kết)
    if k == 1 {
      _dem-slide.step()
      place(context [#metadata((
        loai: "slide", ten: tieu-de,
        muc: _muc-ht.get(), so: _dem-slide.get().first(),
      ))<bg-nav>])
    }
    pad(x: _le-slide.ngang, {
      set par(leading: _gl, spacing: _gs)
      body
    })
    // hết slide: cộng dồn số đã dùng vào tổng tích luỹ (đúng một lần)
    if k == so-buoc {
      context {
        let so = _bd-tat-ca.map(bd => bd.cnt.get().first())
        _bd-cau.goc.update(v => v + so.at(0))
        _bd-vd.goc.update(v => v + so.at(1))
        _bd-lt.goc.update(v => v + so.at(2))
        _bd-hd.goc.update(v => v + so.at(3))
        _bd-vdtt.goc.update(v => v + so.at(4))
      }
    }
  }
  }
}

// ---------- Hoạt hình xuất hiện từng bước ----------
// Dùng trong slide có so-buoc > 1:
//   #lo(2)[...]                 — hiện TỪ bước 2. Trước đó KHÔNG chiếm chỗ
//                                 (như \pause của LaTeX beamer) — nhờ vậy
//                                 slide dài không sinh trang trắng đệm;
//                                 nội dung hiện dần từ trên xuống nên bố cục
//                                 phần đã hiện không đổi giữa các bước.
//   #lo(2, giu-cho: true)[...]  — ẩn nhưng vẫn giữ chỗ (khi cần cố định
//                                 vị trí phần tử phía dưới; chỉ nên dùng
//                                 cho slide chắc chắn gói gọn 1 trang).
//   #chi(2)[...]                — CHỈ hiện ở bước 2
//   #chi(2, giu-cho: false)[..] — chỉ hiện ở bước 2, không giữ chỗ
#let lo(n, giu-cho: false, body) = context {
  if _la-sach(_ho-so.get()) or _buoc-ht.get() >= n { body }
  else if giu-cho { hide(body) }
}

#let chi(n, giu-cho: true, body) = context {
  if _la-sach(_ho-so.get()) { body }        // bản in: hiện hết
  else if _buoc-ht.get() == n { body } else if giu-cho { hide(body) }
}

// Danh sách hiện dần từng ý; ý đầu tiên xuất hiện ở bước `tu`.
//   #tung-buoc([ý 1], [ý 2], [ý 3])   // trong slide có so-buoc đủ lớn
#let tung-buoc(tu: 2, ..cac-y) = {
  for (i, y) in cac-y.pos().enumerate() {
    lo(tu + i, block(above: 6pt, below: 6pt, y))
  }
}

// ---------- Khung nội dung ----------
// Hai block rời (đầu khung "dính" với thân) thay vì stack,
// để khung dài có thể tự ngắt sang trang/slide kế tiếp.
#let _khung(nhan, mau, body) = {
  block(
    width: 100%, fill: mau, inset: (x: 12pt, y: 6.5pt),
    radius: (top: 5pt), above: 11pt, below: 0pt, sticky: true,
    text(fill: white, weight: "bold", size: 0.78em, nhan),
  )
  block(
    width: 100%, fill: mau.lighten(94%), inset: (x: 12pt, y: 10pt),
    radius: (bottom: 5pt), stroke: 1pt + mau, above: 0pt, below: 11pt,
    body,
  )
}

#let dinh-nghia(body, ten: none) = _khung(
  if ten == none { [ĐỊNH NGHĨA] } else { [ĐỊNH NGHĨA — #ten] },
  rgb("#0f4c81"), body,
)

#let dinh-ly(body, ten: none) = _khung(
  if ten == none { [ĐỊNH LÝ] } else { [ĐỊNH LÝ — #ten] },
  rgb("#a93226"), body,
)

#let tinh-chat(body, ten: none) = _khung(
  if ten == none { [TÍNH CHẤT] } else { [TÍNH CHẤT — #ten] },
  rgb("#6c3483"), body,
)

#let cong-thuc(body, ten: none) = _khung(
  if ten == none { [CÔNG THỨC] } else { [CÔNG THỨC — #ten] },
  rgb("#148f77"), body,
)

#let vi-du(body, ten: none) = _khung(
  {
    [VÍ DỤ ]
    _so-moi(_bd-vd)
    if ten != none { [ — #ten] }
  },
  rgb("#1e8449"), body,
)

#let luyen-tap(body, ten: none) = _khung(
  {
    [LUYỆN TẬP ]
    _so-moi(_bd-lt)
    if ten != none { [ — #ten] }
  },
  rgb("#b9770e"), body,
)

// Lời giải: khung trắng viền trái.
#let loi-giai(body) = block(
  width: 100%, inset: (left: 12pt, y: 6pt, right: 6pt),
  stroke: (left: 2.5pt + rgb("#1e8449")),
  above: 10pt, below: 10pt,
  {
    align(center, text(fill: rgb("#1e8449"), weight: "bold", size: 0.82em, [Lời giải]))
    body
  },
)

#let chu-y(body) = block(
  width: 100%, radius: 5pt, fill: rgb("#fef9e7"),
  stroke: 1pt + rgb("#f1c40f"), inset: (x: 12pt, y: 9pt),
  above: 11pt, below: 11pt,
  {
    text(fill: rgb("#b7950b"), weight: "bold", size: 0.82em, [⚠ Chú ý. ])
    body
  },
)

#let ghi-nho(body) = block(
  width: 100%, radius: 5pt, fill: rgb("#eaf2f8"),
  stroke: (left: 3pt + rgb("#0f4c81")), inset: (x: 12pt, y: 9pt),
  above: 11pt, below: 11pt,
  {
    text(fill: rgb("#0f4c81"), weight: "bold", size: 0.82em, [★ Ghi nhớ. ])
    body
  },
)

// Nhận xét (mục "Nhận xét" trong SGK): khung nhẹ nền lục nhạt, viền trái.
#let nhan-xet(body) = block(
  width: 100%, radius: 5pt, fill: rgb("#e8f6f3"),
  stroke: (left: 3pt + rgb("#148f77")), inset: (x: 12pt, y: 9pt),
  above: 11pt, below: 11pt,
  {
    text(fill: rgb("#117a65"), weight: "bold", size: 0.82em, [✎ Nhận xét. ])
    body
  },
)

// ---------- Bố cục ----------
// Hai (hoặc nhiều) cột: #chia-cot(a, b) hoặc #chia-cot(a, b, ti-le: (3fr, 2fr))
#let chia-cot(ti-le: auto, khoang: 16pt, ..noi-dung) = {
  let cells = noi-dung.pos()
  grid(
    columns: if ti-le == auto { (1fr,) * cells.len() } else { ti-le },
    column-gutter: khoang,
    ..cells,
  )
}

// Danh sách bước giải đánh số tròn.
// hien-dan: true => trong slide có so-buoc, các bước lần lượt xuất hiện
// từ bước hoạt hình `tu` (mặc định bước 2).
#let buoc(hien-dan: false, tu: 2, ..cac-buoc) = {
  for (i, b) in cac-buoc.pos().enumerate() {
    let nd = block(above: 7pt, below: 7pt, {
      box(baseline: 22%, circle(radius: 9pt, fill: rgb("#0f4c81"),
        align(center + horizon, text(fill: white, size: 11pt, weight: "bold", str(i + 1)))))
      h(8pt)
      b
    })
    if hien-dan { lo(tu + i, nd) } else { nd }
  }
}

// ---------- Slide mục lục điều hướng ----------
// Tự liệt kê mọi mục và tiêu đề slide; bấm vào là nhảy thẳng tới nơi.
// Đặt ngay sau trang bìa: #muc-luc()
#let muc-luc(tieu-de: [Nội dung bài học], cot-so: 2) = context {
  if _la-sach(_ho-so.get()) {
    // Bản in: mục lục tự sinh từ các thanh tiêu đề (heading cấp 1 & 2).
    block(above: 8pt, below: 12pt, {
      text(weight: "bold", size: 1.1em, fill: _mau.get().chinh, tieu-de)
      v(5pt)
      outline(title: none, depth: 2, indent: 1.2em)
    })
  } else {
    slide(tieu-de: tieu-de)[
      #context {
        let m = _mau.get()
        let tat-ca = query(<bg-nav>)
        let cac-muc = tat-ca.filter(e => e.value.loai == "muc")
        grid(
          columns: (1fr,) * cot-so,
          column-gutter: 24pt, row-gutter: 18pt,
          ..cac-muc.map(mm => block({
            link(mm.location(), text(weight: "bold", size: 0.88em, fill: m.chinh, mm.value.ten))
            for s in tat-ca.filter(e => e.value.loai == "slide" and e.value.muc == mm.value.ten) {
              block(above: 5pt, below: 0pt, link(s.location(), text(size: 0.74em, {
                text(fill: m.nhan, [▸ ])
                if s.value.ten == none { [Slide #s.value.so] } else { s.value.ten }
              })))
            }
          })),
        )
      }
    ]
  }
}

// Trang kết thúc.
#let trang-cam-on(loi: [Cảm ơn các em đã tích cực hợp tác!]) = context {
  if _la-sach(_ho-so.get()) {
    // Bản in: kết thúc gọn, không tạo trang bìa cuối.
    v(8pt)
    line(length: 100%, stroke: 0.5pt + luma(60%))
    align(center, text(style: "italic", fill: luma(40%), loi))
  } else {
    pagebreak(weak: true)
    let m = _mau.get()
    block(width: 100%, height: 100%, {
      place(rect(width: 100%, height: 100%,
        fill: gradient.linear(m.chinh, m.chinh.darken(35%), angle: 55deg)))
      place(bottom, rect(width: 100%, height: 8pt, fill: m.nhan))
      place(center + horizon, text(fill: white, weight: "bold", size: 30pt, loi))
    })
  }
}
