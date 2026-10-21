// =====================================================================
// cau-hoi.typ — CÂU HỎI THEO ĐỊNH DẠNG ĐỀ THI 2025
//   #cau-mc(...)    Trắc nghiệm nhiều phương án (tự chia cột theo độ dài)
//   #cau-tf(...)    Đúng — Sai 4 ý (tuỳ chọn ô tick sát lề phải)
//   #cau-sa(...)    Trả lời ngắn
//   #cau-tl(...)    Tự luận
//   #cau-hd(...)    Hoạt động (thẻ "HĐN", bộ đếm riêng, hình thức như TL)
//   #cau-lt(...)    Luyện tập (thẻ "Luyện tập N", chung bộ đếm với khung
//                   #luyen-tap của slide.typ)
//   #cau-vdtt(...)  Vận dụng thực tế (thẻ "Vận dụng N", bộ đếm riêng)
//
// Số câu tự đánh liên tục cho 4 dạng MC/TF/SA/TL; HĐ, Luyện tập, Vận dụng
// mỗi loại có bộ đếm riêng (không đổi qua bước hoạt hình).
// CÔNG TẮC ĐÁP ÁN: #bat-dap-an() / #tat-dap-an()
// KIỂU TIỀN TỐ (thẻ "Câu X", "A.", "a)"): #kieu-cau-hoi(mau: ..., hinh: ...)
//   hinh: "bo-tron" (mặc định) | "chu-nhat" | "luc-giac" | "khong-to"
//   ("khong-to" = không tô nền, chỉ viền + chữ màu — in không bị đen;
//    riêng hồ sơ dethi: bỏ cả viền — "Câu 1." / "A." đậm cùng màu)
//   hien-o: false = ẩn ô tick Đ/S (ds) + ô điền "Trả lời" (tln) toàn bài.
//   -> đổi MỘT LẦN, đồng bộ toàn bài.
// CHỪA CHỖ TL (bản in): #trong-tl(cao: 5cm) / #khong-trong-tl()
// =====================================================================
#import "slide.typ": _buoc-ht, _bd-cau, _bd-hd, _bd-lt, _bd-vdtt, _bd-tat-ca, _so-moi, _ho-so

#let _hien-da = state("ch-hien-da", false)

// Điều kiện hiện đáp án: công tắc bật + (nếu có lo-da) đã đến bước lo-da.
#let _da-hien(lo-da) = _hien-da.get() and (lo-da == none or _buoc-ht.get() >= lo-da)

#let bat-dap-an() = _hien-da.update(true)
#let tat-dap-an() = _hien-da.update(false)
// Đặt lại số thứ tự cho CẢ 8 dạng câu (Câu tn/ds/tln/tl + Ví dụ + Hoạt động
// + Luyện tập + Vận dụng thực tế):
//   #dat-lai-cau()  hoặc  #dat-lai-cau(0)  -> đánh lại từ 1;
//   #dat-lai-cau(3)                        -> đánh tiếp từ 4; ... tương tự.
#let dat-lai-cau(..so) = {
  let n = so.pos().at(0, default: 0)
  for bd in _bd-tat-ca {
    bd.goc.update(n)
    bd.cnt.update(0)
  }
}

// ---------- Chừa chỗ trống sau câu TL/HĐ/LT/VDTT (chỉ ở BẢN IN, khi ẩn đáp án) ----------
// Đổi ĐỒNG BỘ toàn bài, hai tuỳ chọn:
//   #trong-tl(cao: 5cm)  -> CHỪA chỗ làm bài sau mỗi câu:
//        • câu có đặt cho-trong: dùng đúng cho-trong đó;
//        • câu KHÔNG đặt cho-trong: chừa mặc định `cao`.
//   #khong-trong-tl()    -> KHÔNG chừa chỗ (bỏ qua cả cho-trong) — in gọn.
// Mặc định (bat: true, cao: 0pt): giữ nguyên hành vi cũ — chỉ chừa đúng
// theo cho-trong của từng câu. Ở beamer/loigiai (hiện đáp án) tuỳ chọn này
// không tác dụng vì chỗ đó dành cho lời giải.
#let _trong-tl = state("ch-trong-tl", (bat: true, cao: 0pt))
#let trong-tl(cao: 5cm) = _trong-tl.update((bat: true, cao: cao))
#let khong-trong-tl() = _trong-tl.update(k => (bat: false, cao: k.cao))

#let _xanh = rgb("#0f4c81")
#let _luc = rgb("#1e8449")
#let _do = rgb("#a93226")

// ---------- ĐÁNH DẤU ĐÁP ÁN ĐÚNG NGAY TRONG DANH SÁCH ----------
// Bọc phương án/phát biểu ĐÚNG bằng True(...) — đáp án đi kèm nội dung nên
// hoán vị/xáo trộn thoải mái, không lệch:
//   #tn([...], ([$A$], True([$B$]), [$C$], [$D$]))          -> đáp án B
//   #ds([...], ([a sai], True([b đúng]), True([c]), [d]))   -> (S, Đ, Đ, S)
// (bí danh tiếng Việt: Dung)
//
// LỜI GIẢI GẮN LIỀN TỪNG Ý (#ds) — cần khi công cụ trộn HOÁN VỊ các ý:
// khối lời giải viết cứng "a) … b) …" sẽ sai sau khi xáo, nên đặt lời giải
// ngay cạnh ý bằng `giai:`; lib tự đánh lại nhãn theo thứ tự SAU hoán vị.
//   #ds([Cho $y = x^3 - 3x$.], (
//     True([$y' = 3x^2 - 3$],  giai: [Đạo hàm của $x^n$ là $n x^(n-1)$.]),
//     False([Hàm số không có cực trị], giai: [$y' = 0$ có hai nghiệm phân biệt.]),
//     [Ý sai, không cần giải riêng — viết trần như cũ],
//   ))
// `loi-giai:` chung vẫn dùng được — in TRƯỚC phần giải theo ý (phần dẫn nhập).
#let True(nd, giai: none) = (bg-dung: true, nd: nd, giai: giai)
#let Dung = True
#let False(nd, giai: none) = (bg-dung: false, nd: nd, giai: giai)
#let _la-y(x) = type(x) == dictionary and "nd" in x
#let _la-true(x) = type(x) == dictionary and x.at("bg-dung", default: false)
#let _bo-true(x) = if _la-y(x) { x.nd } else { x }
#let _giai-y(x) = if _la-y(x) { x.at("giai", default: none) } else { none }

// Tách danh sách có True(...)/False(...): trả (ds: nội dung thuần,
// dung: mảng bool, giai: mảng lời giải từng ý — none nếu không khai).
#let _tach-true(ds) = (
  ds: ds.map(_bo-true),
  dung: ds.map(_la-true),
  giai: ds.map(_giai-y),
)

// ---------- TỰ THÊM DẤU CHẤM CUỐI PHƯƠNG ÁN / PHÁT BIỂU ----------
// Phương án của #tn và ý của #ds là một CÂU, đúng chính tả phải kết bằng "."
// Bộ dò dưới đây duyệt NGƯỢC cây nội dung tìm ký tự có nghĩa cuối cùng:
//   • đã có . ! ? … : ; (hoặc dấu đóng ngoặc kép/ngoặc sau chúng) -> giữ nguyên
//   • kết thúc bằng khối (danh sách, bảng, hình, xuống dòng...)   -> BỎ QUA
//   • còn lại (chữ, số, công thức toán, dấu ngoặc)                -> thêm "."
// Tắt toàn bài: #kieu-cau-hoi(cham-cuoi: false); tắt một câu: `cham: false`.
#let _dau-ket = (".", "!", "?", "…", ":", ";", "。", "！", "？")
// Dấu "vỏ" bọc ngoài dấu kết: "Anh ấy đi!" / (đúng.) — nhìn xuyên qua.
#let _dau-vo = ("\"", "'", "”", "’", "»", ")", "]", "}", "›")

// Các phần tử KHỐI: đứng cuối thì không thêm dấu chấm (chấm sẽ rơi xuống dòng).
// Lưu ý: trong markup, `- a` sinh thẳng `list.item` (chưa gom thành `list`).
#let _la-khoi(f) = (
  f == list or f == enum or f == terms or f == table or f == grid
    or f == list.item or f == enum.item or f == terms.item
    or f == figure or f == image or f == block or f == place
    or f == parbreak or f == linebreak or f == line or f == v or f == pagebreak
)
// Phần tử "khoảng trắng" của markup (bỏ qua khi dò ngược từ cuối).
#let _f-space = [ ].func()

// Đoạn văn bản có nghĩa CUỐI CÙNG (none = không tìm được: hình, công thức...).
#let _van-cuoi(c) = {
  if c == none { return none }
  let t = type(c)
  if t == int or t == float { return str(c) }
  if t == str {
    let s = c.trim()
    return if s == "" { none } else { s }
  }
  if t == array {
    for x in c.rev() {
      let r = _van-cuoi(x)
      if r != none { return r }
    }
    return none
  }
  if t != content { return none }
  if c.has("text") { return _van-cuoi(c.text) }
  if c.has("children") { return _van-cuoi(c.children) }
  if c.has("body") { return _van-cuoi(c.body) }
  none
}

// Phân loại phần tử có nghĩa CUỐI CÙNG:
//   1 = khối (danh sách/bảng/hình/ngắt dòng/công thức giữa dòng) -> KHÔNG chấm
//   0 = nội dung thường (chữ, số, công thức trong dòng)          -> chấm được
//  -1 = không có gì nhìn thấy (khoảng trắng, metadata, cập nhật trạng thái,
//       phần tử bọc rỗng) -> đi tiếp sang phần tử trước đó
#let _loai-cuoi(c) = {
  if c == none { return -1 }
  let t = type(c)
  if t == str { return if c.trim() == "" { -1 } else { 0 } }
  if t == int or t == float { return 0 }
  if t != content { return 0 }
  let f = c.func()
  if _la-khoi(f) { return 1 }
  if f == _f-space or f == metadata { return -1 }
  // công thức: TRÌNH BÀY GIỮA DÒNG ($ ... $) là khối; trong dòng luôn "thường"
  if f == math.equation {
    if c.at("block", default: false) { return 1 }
    return if _loai-cuoi(c.body) == 1 { 1 } else { 0 }
  }
  if c.has("text") { return if type(c.text) == str and c.text.trim() == "" { -1 } else { 0 } }
  if c.has("children") {
    for x in c.children.rev() {
      let r = _loai-cuoi(x)
      if r >= 0 { return r }
    }
    return -1
  }
  if c.has("body") { return _loai-cuoi(c.body) }
  if c.has("child") { return _loai-cuoi(c.child) }   // phần tử styled
  -1
}

// Thêm "." nếu thiếu (giữ nguyên nội dung gốc trong mọi trường hợp còn lại).
#let cham-cau(c) = {
  if c == none or c == [] { return c }
  if _loai-cuoi(c) != 0 { return c }   // kết bằng khối/hình hoặc rỗng -> bỏ qua
  let s = _van-cuoi(c)
  if s == none { return [#c#"."] }   // chỉ có công thức (vd $1/2$) -> vẫn chấm
  // bóc các dấu "vỏ" ngoài cùng: Đúng!" / (sai.) -> nhìn thấy ! và .
  let cl = s.clusters()
  let i = cl.len() - 1
  while i >= 0 and _dau-vo.contains(cl.at(i)) { i = i - 1 }
  if i >= 0 and _dau-ket.contains(cl.at(i)) { return c }
  [#c#"."]
}

// ---------- THU THẬP ĐÁP ÁN CHO BẢNG ĐÁP ÁN ----------
// Mỗi câu tn/ds/tln phát một metadata vô hình (nhãn <bg-da>). Hàm bang-dap-an
// (che-do.typ) query theo document-order rồi dựng 3 bảng. loai ∈ "tn"/"ds"/"tln":
//   tn  -> da = chữ cái đáp án đúng ("A".."F") hoặc none.
//   ds  -> da = mảng bool 4 ý (true = Đ, false = S).
//   tln -> da = đáp án (chuỗi/số/nội dung).
// khoa: true -> câu này KHÔNG được hoán vị phương án/ý (công cụ trộn đọc cờ này).
#let _ghi-da(loai, da, khoa: false) = [#metadata((loai: loai, da: da, khoa: khoa)) <bg-da>]

// Chữ cái đáp án đúng của câu tn (ưu tiên True(...) trong danh sách; nếu không
// có thì lấy dap-an dạng chữ "B" cũ).
#let _chu-da-tn(phuong-an, dap-an) = {
  let vi = phuong-an.map(_la-true).position(d => d)
  if vi != none { ("A", "B", "C", "D", "E", "F").at(vi) } else { dap-an }
}

// ---------- Kiểu tiền tố (thẻ) — đồng bộ màu & hình dáng ----------
// hien-o: hiện ô tick Đ/S (câu ds có o-tick) và ô điền "Trả lời" (câu tln);
//         false = ẨN đồng bộ toàn bài (đề gọn, HS làm thẳng vào phiếu).
#let _kieu = state("ch-kieu", (mau: rgb("#0f4c81"), hinh: "bo-tron", hien-o: true, cham: true))

// Đổi kiểu ở bất kỳ đâu trong tài liệu:
//   #kieu-cau-hoi(mau: rgb("#e67e22"), hinh: "luc-giac", hien-o: false)
#let kieu-cau-hoi(mau: auto, hinh: auto, hien-o: auto, cham-cuoi: auto) = _kieu.update(k => (
  mau: if mau == auto { k.mau } else { mau },
  hinh: if hinh == auto { k.hinh } else { hinh },
  hien-o: if hien-o == auto { k.at("hien-o", default: true) } else { hien-o },
  cham: if cham-cuoi == auto { k.at("cham", default: true) } else { cham-cuoi },
))

// Ô tick/ô điền có được hiện không (đọc trong context).
#let _hien-o() = _kieu.get().at("hien-o", default: true)

// Tự thêm dấu chấm cuối phương án/ý hỏi không? (đọc trong context)
// cham: auto = theo cài đặt toàn bài; true/false = ép riêng câu này.
#let _cham-ds(ds, cham) = {
  let bat = if cham == auto { _kieu.get().at("cham", default: true) } else { cham }
  if bat { ds.map(cham-cau) } else { ds }
}

// Thẻ tiền tố: nền màu chủ đạo, chữ trắng; 4 chế độ.
//   "bo-tron" | "chu-nhat" | "luc-giac" : TÔ nền màu, chữ trắng.
//   "khong-to" : KHÔNG tô nền — viền mảnh + chữ màu chủ đạo, đậm;
//                in ấn không bị mảng đen (tiết kiệm mực).
//                RIÊNG hồ sơ dethi: bỏ luôn viền — chỉ chữ ĐẬM cùng màu
//                kèm dấu liền kề ("Câu 1.", "A." — ý ds: "a)") kiểu LaTeX;
//                dấu tuỳ chỉnh qua `duoi` (mặc định ".").
#let _the(nd, mau: auto, duoi: ".") = context {
  let k = _kieu.get()
  let m = if mau == auto { k.mau } else { mau }
  if k.hinh == "khong-to" and _ho-so.get() == "sachdethi" {
    text(fill: m, weight: "bold")[#nd#duoi]
  } else if k.hinh == "khong-to" {
    box(
      stroke: 0.8pt + m,
      radius: 3.5pt,
      inset: (x: 6pt, y: 2.5pt),
      baseline: 1%,
      text(fill: m, weight: "bold", size: 0.8em, nd),
    )
  } else {
    let nd2 = text(fill: white, weight: "bold", size: 0.8em, nd)
    if k.hinh == "luc-giac" {
      let s = measure(nd2)
      let w = s.width + 15pt
      let h = s.height + 5.5pt
      box(width: w, height: h, baseline: 1%, {
        place(polygon(
          fill: m,
          (h / 2, 0pt), (w - h / 2, 0pt), (w, h / 2),
          (w - h / 2, h), (h / 2, h), (0pt, h / 2),
        ))
        place(center + horizon, nd2)
      })
    } else {
      box(
        fill: m,
        radius: if k.hinh == "chu-nhat" { 0pt } else { 3.5pt },
        inset: (x: 6pt, y: 2.5pt),
        baseline: 1%,
        nd2,
      )
    }
  }
}

// "Câu N (x điểm)" — đầu mỗi câu hỏi.
// prefix: chữ trên thẻ ("Câu", "Bài", ...); num: auto = đếm tự động,
// hoặc số/chữ chỉ định (khi chỉ định, bộ đếm KHÔNG tăng).
#let _dau-cau(diem: none, prefix: "Câu", num: auto) = {
  let so = if num == auto { _so-moi(_bd-cau) } else { [#num] }
  _the([#prefix #so])
  if diem != none {
    context text(weight: "bold", fill: _kieu.get().mau, size: 0.86em)[ (#diem điểm)]
  }
  h(6pt)
}

// Chừa `lines` dòng trống làm bài (chỉ khi ẨN đáp án — bản in đề thi).
#let _chua-dong(lines, lo-da) = context {
  if lines > 0 and not _da-hien(lo-da) { v(lines * 1.55em) }
}

// Đóng khung cả câu khi boxed: true.
#let _khung-cau(boxed, than) = block(
  width: 100%, above: 10pt, below: 10pt,
  stroke: if boxed { 0.7pt + luma(45%) } else { none },
  inset: if boxed { 8pt } else { 0pt },
  radius: if boxed { 4pt } else { 0pt },
  than,
)

// (_khoi-giai/_hien-giai chuyển xuống SAU voi-hinh — nay hỗ trợ hình
// kèm LỜI GIẢI thông qua voi-hinh.)

// ---------- BỐ CỤC ĐỀ + HÌNH ----------
// Quy tắc chung cho MỌI dạng câu (dùng qua tham số hinh: của
// cau-mc/cau-tf/cau-sa/cau-tl/... hoặc gọi trực tiếp trong thân câu):
//   • hình HẸP (bề rộng ≤ ti-le × bề rộng khung): hình canh giữa CỘT PHẢI —
//     cột phải ôm đúng bề rộng hình, cột trái (đề + phương án/ý hỏi) nhận
//     phần còn lại; hai cột canh giữa theo chiều dọc nên độ cao cân đối.
//   • hình RỘNG (BBT, bảng thống kê, hình khổ lớn): tự tách ra DÒNG RIÊNG
//     canh giữa — đặt sau phần đề `de`, trước phần `duoi` (phương án/ý hỏi).
// LƯU Ý: truyền hình TRỰC TIẾP (hinh: ve-do-thi(...)), KHÔNG bọc align/block
// quanh hình — bọc thêm sẽ đo sai bề rộng.
// vi-tri ("right" | "left" | "top" | "bottom"): vị trí hình so với đề;
// be-rong: auto = ôm đúng bề rộng hình (hình rộng tự xuống dòng riêng),
//          hoặc chỉ định (35%, 5cm...) = cột hình chiếm đúng bề rộng đó.
#let voi-hinh(de, hinh, duoi: none, ti-le: 0.46, khoang: 14pt, vi-tri: "right", be-rong: auto) = {
  let rieng = block(width: 100%, above: 8pt, below: 8pt, align(center, hinh))
  if hinh == none {
    de
    duoi
  } else if vi-tri == "top" {
    rieng
    de
    duoi
  } else if vi-tri == "bottom" {
    de
    duoi
    rieng
  } else {
    let hai-cot(o-hinh) = if vi-tri == "left" {
      grid(
        columns: (if be-rong == auto { auto } else { be-rong }, 1fr),
        column-gutter: khoang,
        align: (center + horizon, left + horizon),
        o-hinh, { de; duoi },
      )
    } else {
      grid(
        columns: (1fr, if be-rong == auto { auto } else { be-rong }),
        column-gutter: khoang,
        align: (left + horizon, center + horizon),
        { de; duoi }, o-hinh,
      )
    }
    if be-rong != auto {
      hai-cot(align(center + horizon, hinh))
    } else {
      context layout(kich => {
        if measure(hinh).width <= ti-le * kich.width {
          hai-cot(hinh)
        } else {
          de
          rieng
          duoi
        }
      })
    }
  }
}

// Khối "Hướng dẫn giải" dùng chung cho cả 4 dạng.
// hinh: hình kèm LỜI GIẢI — bố cục 2 cột/hàng riêng như voi-hinh
// (vi-tri: "right"|"left"|"top"|"bottom"; be-rong: auto hoặc chỉ định).
#let _khoi-giai(lg, hinh: none, vi-tri: "right", be-rong: auto) = block(
  width: 100%, inset: (left: 11pt, top: 4pt, bottom: 4pt),
  stroke: (left: 2.5pt + _luc), above: 8pt,
  voi-hinh({
    align(center, text(fill: _luc, weight: "bold", size: 0.84em)[Hướng dẫn giải])
    lg
  }, hinh, vi-tri: vi-tri, be-rong: be-rong),
)

// Hiện lời giải theo công tắc + bước `buoc`; trước bước đó KHÔNG chiếm chỗ
// (tránh phần ẩn tràn trang sinh trang trắng đệm khi trình chiếu).
#let _hien-giai(loi-giai, buoc, hinh: none, vi-tri: "right", be-rong: auto) = context {
  if _hien-da.get() and loi-giai != none {
    if buoc == none or _buoc-ht.get() >= buoc {
      _khoi-giai(loi-giai, hinh: hinh, vi-tri: vi-tri, be-rong: be-rong)
    }
  }
}

// ---------- MC: trắc nghiệm nhiều phương án ----------
// Một phương án: thẻ chữ cái + nội dung; phương án đúng tô xanh lá.
#let _o-pa(chu, noi-dung, dung) = {
  if dung {
    box(fill: _luc.lighten(87%), radius: 3.5pt, inset: (x: 5pt, y: 3.5pt))[
      #_the(chu, mau: _luc) #noi-dung
    ]
  } else {
    [#_the(chu) #noi-dung]
  }
}

// cot: auto = tự chọn 4 / 2 / 1 cột theo độ dài phương án dài nhất,
//      hoặc số cột cố định (1, 2, 4).
// lo-da: bước lộ đáp án; loi-giai + lo-giai: lời giải và bước lộ lời giải.
// Phương án đúng: bọc True(...) trong danh sách (ưu tiên) hoặc dap-an: "B" (cũ).
#let cau-mc(
  cau, phuong-an, dap-an: none, cot: auto, diem: none, hinh: none,
  lo-da: none, loi-giai: none, lo-giai: auto, cham: auto, khoa-pa: false,
  fig-pos: "right", fig-width: auto, lines: 0, num: auto, prefix: "Câu", boxed: false,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto,
) = {
  _ghi-da("tn", _chu-da-tn(phuong-an, dap-an), khoa: khoa-pa)
  _khung-cau(boxed, {
    let hinh-giai = if hinh-giai != none { hinh-giai } else { fig-giai }
    let t = _tach-true(phuong-an)
    let pa = t.ds
    let vi-dung = t.dung.position(d => d)
    let da = if vi-dung != none { ("A", "B", "C", "D", "E", "F").at(vi-dung) } else { dap-an }
    voi-hinh({ _dau-cau(diem: diem, prefix: prefix, num: num); cau }, hinh,
      vi-tri: fig-pos, be-rong: fig-width, duoi: {
    v(6pt)
    context {
      let hien = _da-hien(lo-da) and da != none
      let pa = _cham-ds(pa, cham)
      let cells = pa.enumerate().map(p => {
        let chu = ("A", "B", "C", "D", "E", "F").at(p.at(0))
        _o-pa(chu, p.at(1), hien and chu == da)
      })
      layout(kich => {
        let so-cot = if cot == auto {
          // đo phương án dài nhất, cộng bề rộng thẻ + khoảng đệm
          let rong = calc.max(..pa.map(x => measure([#x]).width)) + 42pt
          if 4 * rong <= kich.width { 4 } else if 2 * rong <= kich.width { 2 } else { 1 }
        } else { cot }
        grid(
          columns: (1fr,) * so-cot,
          row-gutter: 9pt, column-gutter: 12pt,
          ..cells,
        )
      })
    }
    })
    _chua-dong(lines, lo-da)
    _hien-giai(loi-giai, if lo-giai == auto { lo-da } else { lo-giai },
      hinh: hinh-giai, vi-tri: fig-giai-pos, be-rong: fig-giai-width)
  },
  )
}

// ---------- DÒ NHÃN THỨ TỰ GÕ TAY (chống lặp "a) a) …") ----------
// Người soạn (hoặc AI sinh bài) hay tự gõ sẵn "a)", "1.", "(b)"… vào đầu item,
// trong khi cot-item vốn TỰ đánh nhãn ⇒ ra "a) a) Phải quay…". Bộ dò dưới đây
// đọc CHUỖI ĐẦU của từng item; item nào đã có nhãn thì cot-item bỏ nhãn tự động.
//   NHẬN: a) a. a: A) (a) [b] 1) 1. (2) ii) IV.
//   KHÔNG nhận: "0,5 lít" · "0.5 lít" (sau dấu là chữ số) · "Ta có" · "$x = 1$"
#let _dau-nhan = (")", ".", ":")
#let _chu-cai = "abcdefghijklmnopqrstuvwxyz"
#let _chu-so = "0123456789"
#let _so-la-ma = ("i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x",
  "xi", "xii")

// Chuỗi văn bản ĐẦU của một nội dung (chỉ cần vài ký tự đủ soi nhãn).
// Gặp "vật cản" (toán, hình, bảng, danh sách) thì trả "$" để chắc chắn không khớp.
#let _dau-van(c, gh: 10) = {
  if c == none { return "" }
  let t = type(c)
  if t == int or t == float { return str(c) }
  if t == str { return c }
  if t == array {
    let s = ""
    for x in c {
      s = s + _dau-van(x, gh: gh)
      if s.trim(at: start).clusters().len() >= gh { break }
    }
    return s
  }
  if t != content { return "" }
  let f = c.func()
  if f == _f-space or f == linebreak or f == parbreak { return " " }
  if f == metadata { return "" }
  if _la-khoi(f) or f == math.equation { return "$" }
  if c.has("text") { return if type(c.text) == str { c.text } else { "$" } }
  if c.has("children") { return _dau-van(c.children, gh: gh) }
  if c.has("body") { return _dau-van(c.body, gh: gh) }
  if c.has("child") { return _dau-van(c.child, gh: gh) }   // phần tử styled
  ""
}

// Thứ tự của nhãn gõ tay ở đầu item: 1 cho a)/1)/(a), 2 cho b)/2)… ;
// none = không thấy nhãn nào.
#let _thu-nhan-tay(c) = {
  let cl = _dau-van(c).trim(at: start).clusters()
  if cl.len() == 0 { return none }
  let mo = (cl.at(0) == "(" or cl.at(0) == "[")
  let i = if mo { 1 } else { 0 }
  // thân nhãn: TOÀN chữ cái hoặc TOÀN chữ số, tối đa 4 ký tự
  let than = ""
  let loai = none
  while i < cl.len() and than.clusters().len() < 4 {
    let l = lower(cl.at(i))
    let la-so = (_chu-so.contains(l) and loai != "chu")
    let la-chu = (_chu-cai.contains(l) and loai != "so")
    if la-so { loai = "so" } else if la-chu { loai = "chu" } else { break }
    than = than + l
    i = i + 1
  }
  if loai == none or i >= cl.len() { return none }
  // dấu ngăn: trong ngoặc thì phải đóng ngoặc, ngoài ngoặc thì ) . :
  let d = cl.at(i)
  let hop-le = if mo { d == ")" or d == "]" } else { _dau-nhan.contains(d) }
  if not hop-le { return none }
  // Sau dấu CHẤM / HAI CHẤM bắt buộc là khoảng trắng hoặc hết chuỗi, kẻo nhận
  // nhầm "0.5 lít" hay "12:30". Sau dấu ĐÓNG NGOẶC thì "a)Nội dung" vẫn tính.
  i = i + 1
  let can-cach = (d == "." or d == ":")
  if can-cach and i < cl.len() and cl.at(i).trim() != "" { return none }
  if loai == "so" {
    if than.starts-with("0") { return none }   // "01." không phải nhãn
    let k = int(than)
    return if k >= 1 and k <= 99 { k } else { none }
  }
  if than.clusters().len() == 1 {
    let k = _chu-cai.clusters().position(x => x == than)
    return if k == none { none } else { k + 1 }
  }
  let k = _so-la-ma.position(x => x == than)
  if k == none { none } else { k + 1 }
}

// Quyết định BỎ nhãn tự động cho từng item:
//   • MỌI item đều đã có nhãn tay -> bỏ hết (kể cả khi đánh tiếp d), e), f)).
//   • chỉ VÀI item có nhãn tay -> chỉ bỏ ở item mà nhãn tay ĐÚNG thứ tự của nó
//     (tránh nhận nhầm câu mở đầu bằng "A. B. C thẳng hàng").
#let _bo-nhan-tu-dong(items) = {
  let n = items.len()
  let thu = items.map(_thu-nhan-tay)
  let co = thu.filter(x => x != none).len()
  if co == n and n > 0 { range(n).map(i => true) } else {
    range(n).map(i => thu.at(i) == i + 1)
  }
}

// ---------- CHIA CỘT CÁC ITEM (dùng trong thân câu, nhất là TL) ----------
// Tự đánh nhãn a) b) c)... và xếp các item thành nhiều cột.
// so-cot: auto => ĐO item dài nhất rồi chọn số cột lớn nhất còn vừa bề rộng
//         (thử lần lượt trong `muc-cot`); hoặc số cột cố định.
// theo-cot: true => xếp DỌC theo cột (a,b,c | d,e,f); false => theo hàng.
// kieu-nhan: mẫu numbering ("a)", "1)", ...); none => không đánh nhãn.
// do-nhan-tay: true (mặc định) => item nào ĐÃ gõ sẵn "a)", "1.", "(b)"… thì
//   KHÔNG đánh nhãn tự động nữa (chống lặp "a) a) …"); false => luôn đánh.
//
// LƯU Ý (beamer): các `\` NẰM TRONG một item chỉ là xuống dòng thường —
// KHÔNG tạo bước hoạt hình, vì chúng nằm trong lưới nên bộ tách bước ở cấp
// cao nhất của loi-giai không thấy. Cả item (thậm chí cả khối cot-item) hiện
// MỘT LƯỢT trong một bước. Muốn hiện dần từng cột theo bước thì bọc từng item
// bằng lo(n)[...], ví dụ: cot-item(so-cot: 2, lo(2)[...], lo(3)[...]).
// Cần hiện dần từng dòng như bình thường thì viết thẳng với `\`, đừng cho vào
// cot-item.
#let cot-item(
  ..noi-dung,
  so-cot: auto,
  muc-cot: (4, 3, 2, 1),   // các mức cột sẽ thử khi so-cot = auto (ưu tiên lớn)
  dem: 42pt,               // đệm mỗi cột (nhãn + khoảng cách), như cau-mc
  theo-cot: true,
  kieu-nhan: "a)",
  do-nhan-tay: true,       // dò nhãn a)/1)… gõ sẵn trong item -> không đánh chồng
  cach-cot: 14pt,
  cach-hang: 8pt,
) = {
  let items = noi-dung.pos()
  let n = items.len()
  if n == 0 { return }
  let bo = if do-nhan-tay { _bo-nhan-tu-dong(items) } else { range(n).map(i => false) }
  let nhan(i) = if kieu-nhan == none or bo.at(i) { [] } else {
    [#numbering(kieu-nhan, i + 1) ]
  }
  let o(i) = box(width: 100%, [#nhan(i)#items.at(i)])
  context layout(kich => {
    let so = if so-cot == auto {
      // đo item dài nhất (kèm nhãn) + đệm để tính số cột vừa khung
      let rong = calc.max(..range(n).map(i => measure([#nhan(i)#items.at(i)]).width)) + dem
      let vua = muc-cot.filter(k => k * rong <= kich.width)
      if vua.len() > 0 { calc.max(..vua) } else { 1 }
    } else { so-cot }
    let so = calc.min(so, n)
    let so-hang = calc.ceil(n / so)
    let cells = ()
    for r in range(so-hang) {
      for c in range(so) {
        let idx = if theo-cot { c * so-hang + r } else { r * so + c }
        cells.push(if idx < n { o(idx) } else { [] })
      }
    }
    grid(
      columns: (1fr,) * so,
      column-gutter: cach-cot, row-gutter: cach-hang,
      align: left + top,
      ..cells,
    )
  })
}

// ---------- TF: đúng — sai ----------
// o-tick: true => mỗi phát biểu có 2 ô Đ/S dóng thẳng sát lề phải
// (khi hiện đáp án sẽ tick ✓ vào ô tương ứng); false => nhãn Đ/S sau câu.
// Phát biểu ĐÚNG: bọc True(...) trong danh sách (ưu tiên) hoặc
// dap-an: (false, true, ...) như cũ.
// giai: của True/False -> lời giải riêng từng ý, tự đánh nhãn theo thứ tự hiện
// tại nên hoán vị không lệch. khoa-y: true -> báo công cụ trộn ĐỪNG xáo các ý
// (dùng cho câu mà ý sau dựa vào kết quả ý trước).
#let cau-tf(
  cau, cac-y, dap-an: none, diem: none, hinh: none,
  lo-da: none, loi-giai: none, lo-giai: auto, o-tick: false, cham: auto,
  khoa-y: false,
  fig-pos: "right", fig-width: auto, lines: 0, num: auto, prefix: "Câu", boxed: false,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto,
) = {
  _ghi-da("ds", if _tach-true(cac-y).dung.any(d => d) { _tach-true(cac-y).dung } else { dap-an },
    khoa: khoa-y)
  _khung-cau(boxed, {
    let hinh-giai = if hinh-giai != none { hinh-giai } else { fig-giai }
    let t = _tach-true(cac-y)
    let cac-y = t.ds
    let dap-an = if t.dung.any(d => d) { t.dung } else { dap-an }
    // Lời giải riêng từng ý -> ghép thành khối "a) … b) …" theo thứ tự HIỆN TẠI
    let loi-giai = if t.giai.any(g => g != none) {
      let nhan-y = ("a", "b", "c", "d", "e", "f")
      {
        if loi-giai != none { loi-giai; v(3pt) }
        for (j, g) in t.giai.enumerate() {
          if g != none {
            block(above: 5pt, below: 5pt, {
              _the(nhan-y.at(j), duoi: ")"); [ ]; g
            })
          }
        }
      }
    } else { loi-giai }
    voi-hinh({ _dau-cau(diem: diem, prefix: prefix, num: num); cau }, hinh,
      vi-tri: fig-pos, be-rong: fig-width, duoi: {
    v(4pt)
    context {
      let hien = _da-hien(lo-da) and dap-an != none
      let cac-y = _cham-ds(cac-y, cham)
      let nhan-y = ("a", "b", "c", "d", "e")
      let k-mau = _kieu.get().mau
      if o-tick and _hien-o() {
        let o-vuong(tick, m) = box(
          width: 15pt, height: 15pt, stroke: 0.8pt + luma(45%), radius: 2pt,
          fill: if tick { m.lighten(80%) } else { white },
          align(center + horizon,
            if tick { text(fill: m, weight: "bold", size: 9pt)[✓] }),
        )
        grid(
          columns: (1fr, 26pt, 26pt),
          align: (left + horizon, center + horizon, center + horizon),
          row-gutter: 8pt, column-gutter: 6pt,
          [], text(weight: "bold", fill: k-mau, size: 0.82em)[Đ],
          text(weight: "bold", fill: k-mau, size: 0.82em)[S],
          ..cac-y.enumerate().map(p => (
            [#_the(nhan-y.at(p.at(0)), duoi: ")") #p.at(1)],
            o-vuong(hien and dap-an.at(p.at(0)), _luc),
            o-vuong(hien and not dap-an.at(p.at(0)), _do),
          )).flatten(),
        )
      } else {
        for j in range(cac-y.len()) {
          block(above: 6pt, below: 6pt, {
            _the(nhan-y.at(j), duoi: ")")
            [ ]
            cac-y.at(j)
            if hien {
              h(7pt)
              let dung = dap-an.at(j)
              let m = if dung { _luc } else { _do }
              box(fill: m.lighten(86%), radius: 3pt, inset: (x: 6pt, y: 1.5pt),
                text(size: 0.78em, weight: "bold", fill: m, if dung { "Đ" } else { "S" }))
            }
          })
        }
      }
    }
    })
    _chua-dong(lines, lo-da)
    _hien-giai(loi-giai, if lo-giai == auto { lo-da } else { lo-giai },
      hinh: hinh-giai, vi-tri: fig-giai-pos, be-rong: fig-giai-width)
  },
  )
}

// ---------- SA: trả lời ngắn ----------
// Khi ẩn đáp án: hiện các ô vuông để điền (như phiếu trả lời).
// Đáp án đặt NGAY SAU đề (positional thứ 2, ưu tiên) hoặc dap-an: (cũ):
//   #cau-sa([Đề...], [$6$], loi-giai: [...])
// show-boxes/box-count: hiện/số ô điền (bí danh cũ o-dien vẫn chạy).
#let cau-sa(
  cau, ..tra-loi, dap-an: none, diem: none, o-dien: 4, hinh: none,
  lo-da: none, loi-giai: none, lo-giai: auto,
  fig-pos: "right", fig-width: auto, show-boxes: true, box-count: auto,
  lines: 0, num: auto, prefix: "Câu", boxed: false,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto,
) = {
  _ghi-da("tln", if tra-loi.pos().len() > 0 { tra-loi.pos().first() } else { dap-an })
  _khung-cau(boxed, {
    let hinh-giai = if hinh-giai != none { hinh-giai } else { fig-giai }
    let dap-an = if tra-loi.pos().len() > 0 { tra-loi.pos().first() } else { dap-an }
    let so-o = if box-count == auto { o-dien } else { box-count }
    voi-hinh({ _dau-cau(diem: diem, prefix: prefix, num: num); cau }, hinh,
      vi-tri: fig-pos, be-rong: fig-width, duoi: {
    v(6pt)
    context {
      if _da-hien(lo-da) and dap-an != none {
        text(weight: "bold", fill: _luc)[Đáp án: ]
        text(fill: _luc, dap-an)
      } else if show-boxes and _hien-o() {
        [Trả lời: ]
        box(baseline: 32%, stack(
          dir: ltr, spacing: 4pt,
          ..range(so-o).map(k => rect(width: 21pt, height: 21pt, stroke: 0.8pt + _xanh, radius: 2pt)),
        ))
      }
    }
    })
    _chua-dong(lines, lo-da)
    _hien-giai(loi-giai, if lo-giai == auto { lo-da } else { lo-giai },
      hinh: hinh-giai, vi-tri: fig-giai-pos, be-rong: fig-giai-width)
  },
  )
}

// ---------- Thân chung cho các dạng "kiểu tự luận" (TL / HĐ / VDTT) ----------
// dau: thẻ đầu câu; loi-giai: chỉ hiện khi bật đáp án;
// cho-trong: chừa chỗ trống khi in đề.
#let _than-tl(dau, cau, loi-giai, cho-trong, lo-da, hinh: none,
  hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto) = block(
  width: 100%, above: 10pt, below: 10pt,
  {
    voi-hinh({ dau; cau }, hinh)
    context {
      if _da-hien(lo-da) and loi-giai != none {
        _khoi-giai(loi-giai, hinh: hinh-giai, vi-tri: fig-giai-pos, be-rong: fig-giai-width)
      } else {
        let t = _trong-tl.get()
        if t.bat {
          let cao = if cho-trong > 0pt { cho-trong } else { t.cao }
          if cao > 0pt { v(cao) }
        }
      }
    }
  },
)

// Thẻ đầu câu có nhãn + bộ đếm + màu RIÊNG (HĐ, Vận dụng).
#let _dau-rieng(nhan, bd, mau, diem) = {
  _the([#nhan#_so-moi(bd)], mau: mau)
  if diem != none {
    text(weight: "bold", fill: mau, size: 0.86em)[ (#diem điểm)]
  }
  h(6pt)
}

// ---------- TL: tự luận ----------
#let cau-tl(cau, loi-giai: none, diem: none, cho-trong: 0pt, hinh: none, lo-da: none,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto) = _than-tl(
  _dau-cau(diem: diem), cau, loi-giai, cho-trong, lo-da, hinh: hinh,
  hinh-giai: if hinh-giai != none { hinh-giai } else { fig-giai },
  fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width,
)

// ---------- HĐ: hoạt động (khởi động / khám phá kiến thức) ----------
// Thẻ "HĐ1", "HĐ2"... — bộ đếm riêng, hình thức như TL (dùng được cot-item
// trong thân câu khi có nhiều ý hỏi).
#let _cam-hd = rgb("#d35400")
#let cau-hd(cau, loi-giai: none, diem: none, cho-trong: 0pt, hinh: none, lo-da: none,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto) = _than-tl(
  _dau-rieng([HĐ], _bd-hd, _cam-hd, diem), cau, loi-giai, cho-trong, lo-da, hinh: hinh,
  hinh-giai: if hinh-giai != none { hinh-giai } else { fig-giai },
  fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width,
)

// ---------- LT: luyện tập (củng cố lý thuyết vừa học) ----------
// Thẻ "Luyện tập 1", "Luyện tập 2"... — DÙNG CHUNG bộ đếm với khung
// #luyen-tap (slide.typ) nên số thứ tự liên tục dù trộn hai kiểu.
#let _vang-lt = rgb("#b9770e")
#let cau-lt(cau, loi-giai: none, diem: none, cho-trong: 0pt, hinh: none, lo-da: none,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto) = _than-tl(
  _dau-rieng([Luyện tập~], _bd-lt, _vang-lt, diem), cau, loi-giai, cho-trong, lo-da, hinh: hinh,
  hinh-giai: if hinh-giai != none { hinh-giai } else { fig-giai },
  fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width,
)

// ---------- VDTT: vận dụng thực tế ----------
// Thẻ "Vận dụng 1", "Vận dụng 2"... — bộ đếm riêng, hình thức như TL.
#let _tim-vdtt = rgb("#8e44ad")
#let cau-vdtt(cau, loi-giai: none, diem: none, cho-trong: 0pt, hinh: none, lo-da: none,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto) = _than-tl(
  _dau-rieng([Vận dụng~], _bd-vdtt, _tim-vdtt, diem), cau, loi-giai, cho-trong, lo-da, hinh: hinh,
  hinh-giai: if hinh-giai != none { hinh-giai } else { fig-giai },
  fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width,
)
