// =====================================================================
// che-do.typ — MỘT FILE NGUỒN, BA KIỂU PDF (hồ sơ hiển thị)
//
//   "dethi"   : dạng đề thi/sách A4 — MC, TF, SA, TL ẩn đáp án + lời giải;
//               riêng VÍ DỤ vẫn hiện lời giải.
//   "loigiai" : dạng A4 — tất cả hiện lời giải, đánh dấu đáp án.
//   "beamer"  : trình chiếu — MỖI CÂU MỘT SLIDE: hiện đề → lời giải hiện
//               dần theo từng dấu \ (xuống dòng) → cuối cùng đánh dấu đáp án.
// (Tên cũ "de-thi", "loi-giai" vẫn được chấp nhận.)
//
// Cách dùng (xem de-mau.typ):
//   #let ho-so = sys.inputs.at("ho-so", default: "dethi")
//   #show: de-toan.with(ho-so: ho-so, tieu-de: [...], ...)
//   rồi gọi THẲNG #vd/#tn/#ds/#tln/#tl/#hd/#lt/#vdtt/#phan — các hàm tự
//   nhận biết hồ sơ hiển thị, KHÔNG cần khai báo gì thêm.
//   (tn = trắc nghiệm, ds = đúng sai, tln = trả lời ngắn, tl = tự luận,
//    hd = hoạt động, lt = luyện tập, vdtt = vận dụng thực tế;
//    tên cũ mc/tf/sa và dòng tao-cau-hoi cũ vẫn dùng được)
// =====================================================================
#import "slide.typ": slide, muc, bai-giang, lo, vi-du, loi-giai, _ho-so, _la-sach, _buoc-ht
#import "cau-hoi.typ": cau-mc, cau-tf, cau-sa, cau-tl, cau-hd, cau-lt, cau-vdtt, bat-dap-an, tat-dap-an, voi-hinh, True, Dung

// Gộp tham số kiểu mới / kiểu cũ: ưu tiên giá trị kiểu mới nếu được đặt.
#let _uu-tien(moi, cu) = if moi != none { moi } else { cu }

#let _xanh = rgb("#0f4c81")
#let _luc = rgb("#1e8449")
#let _do = rgb("#a93226")
// giữ tham chiếu đến môi trường lời giải (vì tham số cùng tên sẽ che nó)
#let _mt-loi-giai = loi-giai

// Mã đề khai ở de-toan -> lưu vào state để #bang-dap-an tự lấy (khỏi nhập tay).
#let _ma-de = state("bg-ma-de", none)

// ---------- Tách lời giải thành từng dòng ----------
// Nhận nội dung có dấu \ (hoặc mảng nội dung), trả về mảng các dòng.
#let tach-dong(nd) = {
  if nd == none { return () }
  if type(nd) == array { return nd }
  if type(nd) == content and nd.has("children") {
    let phan = ()
    let dong = ()
    for c in nd.children {
      if c.func() == linebreak or c.func() == parbreak {
        phan.push(dong.join())
        dong = ()
      } else {
        dong.push(c)
      }
    }
    phan.push(dong.join())
    return phan.filter(p => p != none)
  }
  (nd,)
}

// ---------- Ngắt lời giải dài sang slide mới (chỉ tác dụng ở beamer) ----------
// Đặt #sang-man trên MỘT DÒNG RIÊNG trong lời giải:
//   loi-giai: [dòng 1 \ dòng 2 \ #sang-man \ dòng 3 \ ...]
// => "dòng 3" trở đi chuyển sang slide kế tiếp (nhãn "Hướng dẫn giải (tiếp)"),
// tránh lời giải tràn trang làm sinh trang đệm trắng khi hiện từng bước.
// Ở bản A4 ("dethi"/"loigiai"), dấu này được bỏ qua.
#let sang-man = metadata("bg-sang-man")

#let _co-sang-man(d) = {
  if type(d) != content { return false }
  if d.func() == metadata { return d.value == "bg-sang-man" }
  if d.has("children") { d.children.any(c => _co-sang-man(c)) } else { false }
}

// Tách lời giải thành các màn; mỗi màn là một mảng dòng.
#let tach-man(nd) = {
  let man = ()
  let ht = ()
  for d in tach-dong(nd) {
    if _co-sang-man(d) {
      if ht.len() > 0 { man.push(ht) }
      ht = ()
    } else { ht.push(d) }
  }
  if ht.len() > 0 { man.push(ht) }
  if man.len() == 0 { ((),) } else { man }
}

// Ghép lại thành một khối (dùng cho bản A4) — bỏ các dấu #sang-man.
#let _ghep(nd) = {
  if nd == none { return none }
  tach-dong(nd).filter(d => not _co-sang-man(d)).join(linebreak())
}

// ---------- Lời giải hiện dần từng dòng (dùng trong slide) ----------
// Khung hiện từ bước `tu`; dòng thứ i hiện ở bước tu + i.
// gian: giãn dòng trong lời giải (~150% so với thân slide 0.62em) —
// phân số, căn thức chồng tầng không còn dính vào nhau.
#let giai-buoc(nd, tu: 2, nhan: [Hướng dẫn giải. ], gian: 0.95em) = {
  let dong = tach-dong(nd)
  if dong.len() == 0 { return }
  lo(tu, block(
    width: 100%, inset: (left: 11pt, top: 5pt, bottom: 5pt),
    stroke: (left: 2.5pt + _luc), above: 10pt,
    {
      set par(leading: gian)
      align(center, text(fill: _luc, weight: "bold", size: 0.84em, nhan))
      dong.at(0)
      for i in range(1, dong.len()) {
        lo(tu + i, block(above: gian, dong.at(i)))
      }
    },
  ))
}

// ---------- Thiết lập tài liệu theo hồ sơ ----------
// Chuẩn hoá tên hồ sơ: "de-thi" -> "dethi", "LoiGiai" -> "loigiai"...
#let _chuan-ho-so(hs) = lower(hs).replace("-", "").replace("_", "")

#let de-toan(
  ho-so: "dethi",
  tieu-de: [ĐỀ KIỂM TRA],
  tieu-de-ngan: none,  // tên bài rút gọn ở header mọi slide (chỉ dùng ở beamer)
  nen: "trang",        // nền slide beamer: "trang" | "kem" | "xanh-nhat"
                       // | "luc-nhat" | "xam" | màu tuỳ ý (bản A4 luôn trắng)
  mon: none,           // vd [MÔN TOÁN 12]
  thoi-gian: none,     // vd "90 phút"
  truong: none,        // vd [SỞ GD&ĐT ... \ TRƯỜNG THPT ...]
  ma-de: none,
  // ----- 3 thông tin header đề thi: CHỈ hiện khi được khai báo -----
  hien-ho-ten: false,  // true -> dòng "Họ và tên thí sinh: ..."
  sbd: none,           // hiện dòng số báo danh / lớp:
                       //   none | false  -> ẩn
                       //   true  | "sbd" -> "Số báo danh: ..."
                       //   "lop"         -> "Lớp: ..."
  hien-ma-de: false,   // true -> ô "Mã đề ..." (dùng giá trị ma-de nếu có)
  thong-tin-hs: true,  // true: đề thi thật — có "(Đề thi có N trang)" (bản dethi)
                       // và "(Đề thi có N trang)"; false: tài liệu bài học
  ti-le-chu: 1.0,      // HỆ SỐ PHÓNG CỠ CHỮ THÂN NỘI DUNG (toàn file) —
                       // 1.0 giữ nguyên; >1 to hơn, <1 nhỏ đi. Áp dụng cho
                       // cả 3 hồ sơ (beamer + A4 dethi/loigiai).
  mau-cong-thuc: auto, // MÀU MỌI CÔNG THỨC trong $...$ (toàn file) — auto = thừa
                       // kế màu chữ (đen ở thân, trắng ở tiêu đề); đặt màu cụ
                       // thể để nhuộm tất cả. Dùng chung cho cả 3 hồ sơ.
  phu-de: none, gv: none, ngay: none,
  body,
) = {
  let hs = _chuan-ho-so(ho-so)
  _ma-de.update(ma-de)   // lưu mã đề để #bang-dap-an tự đồng bộ
  if hs == "beamer" {
    bai-giang(tieu-de: tieu-de, tieu-de-ngan: tieu-de-ngan, nen: nen,
      ti-le-chu: ti-le-chu, mau-cong-thuc: mau-cong-thuc,
      phu-de: phu-de, gv: gv, ngay: ngay, {
      bat-dap-an()
      body
    })
  } else {
    // Ghi hồ sơ vào trạng thái để các hàm câu hỏi (vd/tn/ds/...) tự nhận
    // biết đang ở bản A4; mọi #lo(n) trên bản in đều hiện đủ.
    _ho-so.update("sach" + hs)
    _buoc-ht.update(1000000)
    set page(
      paper: "a4",
      margin: (x: 1.8cm, top: 1.6cm, bottom: 2.2cm),
      footer: context align(center, text(size: 9pt, fill: luma(35%), {
        [Trang #counter(page).display() / #counter(page).final().first()]
        if ma-de != none { [ — Mã đề #ma-de] }
      })),
    )
    set text(size: 11pt * ti-le-chu, lang: "vi")
    show math.equation: it => {
      if mau-cong-thuc == auto { it } else {
        set text(fill: mau-cong-thuc)
        it
      }
    }
    set par(justify: true)
    if hs == "loigiai" { bat-dap-an() } else { tat-dap-an() }
    // ----- đầu đề thi -----
    grid(
      columns: (1fr, 1.25fr), column-gutter: 14pt,
      align(center, {
        if truong != none {
          text(weight: "bold", size: 10pt, truong)
          v(3pt)
        }
        // Dòng "(Đề thi có N trang)" chỉ dành cho đề thi thật —
        // tài liệu kiểu bài học đặt thong-tin-hs: false là bỏ.
        if thong-tin-hs {
          text(size: 9pt, style: "italic")[(Đề thi có #context [#counter(page).final().first()] trang)]
        }
      }),
      align(center, {
        text(weight: "bold", size: 12.5pt, fill: _xanh, tieu-de)
        if mon != none {
          linebreak()
          text(weight: "bold", size: 11pt, mon)
        }
        if thoi-gian != none {
          linebreak()
          text(size: 9pt, style: "italic")[Thời gian làm bài: #thoi-gian]
        }
        if ngay != none and hs == "dethi" {
          linebreak()
          text(size: 9pt, style: "italic")[Ngày kiểm tra: #ngay]
        }
        if hs == "loigiai" {
          linebreak()
          text(weight: "bold", size: 10.5pt, fill: _do)[ĐÁP ÁN VÀ LỜI GIẢI CHI TIẾT]
        }
      }),
    )
    // ----- 3 thông tin tuỳ chọn: chỉ hiện mục nào được khai báo -----
    let hien-sbd = sbd != none and sbd != false
    let co-trai = hien-ho-ten or hien-sbd
    if hs == "dethi" and (co-trai or hien-ma-de) {
      v(10pt)
      let cot-trai = {
        let dong = ()
        if hien-ho-ten {
          dong.push([Họ và tên thí sinh: #box(width: 1fr, repeat[.])])
        }
        if hien-sbd {
          let nhan-sbd = if sbd == "lop" [Lớp] else [Số báo danh]
          dong.push([#nhan-sbd: #box(width: 1fr, repeat[.])])
        }
        dong.join(v(4pt))
      }
      let o-ma-de = rect(inset: 8pt, stroke: 0.8pt,
        text(weight: "bold")[Mã đề #if ma-de == none [......] else [#ma-de]])
      if co-trai and hien-ma-de {
        grid(columns: (1fr, auto), column-gutter: 12pt,
          cot-trai, align(horizon, o-ma-de))
      } else if co-trai {
        cot-trai
      } else {
        align(right, o-ma-de)
      }
    }
    v(8pt)
    line(length: 100%, stroke: 0.7pt)
    v(4pt)
    body
  }
}

// ---------- Bộ hàm câu hỏi theo hồ sơ ----------
// Trả về (vd, tn, ds, tln, tl, phan) có CÙNG cách gọi ở cả 3 hồ sơ
// (kèm bí danh cũ mc/tf/sa để tương thích ngược).
// Trong lời giải, mỗi dấu \ là một bước xuất hiện (chỉ tác dụng ở beamer).
// tieu-de: tiêu đề slide của câu (chỉ dùng ở beamer).
// Các slide "(tiếp)" cho những màn lời giải sau màn đầu.
#let _man-tiep(man, tieu-de, nhan: [Hướng dẫn giải (tiếp). ]) = {
  for mk in man.slice(1) {
    slide(tieu-de: tieu-de, so-buoc: calc.max(1, mk.len()))[
      #giai-buoc(mk, tu: 1, nhan: nhan)
    ]
  }
}

// ---------- 8 DẠNG CÂU DÙNG TRỰC TIẾP Ở MỌI CHẾ ĐỘ ----------
// Các hàm #vd/#tn/#ds/#tln/#tl/#hd/#lt/#vdtt/#phan tự đọc hồ sơ hiển thị
// (do bai-giang/de-toan ghi vào trạng thái) rồi chọn cách dựng:
//   beamer -> mỗi câu một slide, lời giải hiện dần theo từng dấu \;
//   A4     -> khối liên tục (dethi ẩn/loigiai hiện đáp án).
// KHÔNG cần khai báo #let (...) = tao-cau-hoi(...) nữa — import là dùng.
// Trình tự beamer: bước 1 hiện đề — bước 2.. lời giải từng dòng — đánh dấu
// đáp án ở BƯỚC CUỐI màn đầu; các màn #sang-man thành slide "(tiếp)".

// Hình kèm LỜI GIẢI (mọi dạng câu): fig-giai (bí danh hinh-giai) +
// fig-giai-pos/fig-giai-width — bố cục 2 cột như hình kèm đề; ở beamer
// hình hiện từ bước đầu tiên của lời giải, các màn #sang-man sau muốn có
// hình thì chèn trực tiếp trong nội dung màn đó.
#let _giai-kem-hinh(nd, hg, vi-tri, be-rong) = voi-hinh(
  nd, if hg == none { none } else { lo(2, hg) }, vi-tri: vi-tri, be-rong: be-rong,
)

#let vd(noi-dung, loi-giai: none, loigiai: none, diem: none, hinh: none, fig: none,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto,
  tieu-de: [Ví dụ]) = context {
  let loi-giai = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  if _la-sach(_ho-so.get()) {
    // Ví dụ: LUÔN hiện lời giải, kể cả trong hồ sơ "dethi".
    vi-du(voi-hinh(noi-dung, hinh))
    if loi-giai != none {
      _mt-loi-giai(voi-hinh(_ghep(loi-giai), hg, vi-tri: fig-giai-pos, be-rong: fig-giai-width))
    }
  } else {
    let man = tach-man(loi-giai)
    slide(tieu-de: tieu-de, so-buoc: 1 + calc.max(1, man.at(0).len()))[
      #vi-du(voi-hinh(noi-dung, hinh))
      #_giai-kem-hinh(giai-buoc(man.at(0), nhan: [Lời giải. ]), hg, fig-giai-pos, fig-giai-width)
    ]
    _man-tiep(man, tieu-de, nhan: [Lời giải (tiếp). ])
  }
}

// FORM MỚI (khuyến nghị — dễ hoán vị đáp án, xáo trộn tạo mã đề):
//   #tn(
//     [Nội dung đề bài],
//     ( [$A$], True([$B$]), [$C$], [$D$] ),   // đáp án đúng bọc True(...)
//     loigiai: [Lời giải chi tiết],
//     fig: none, fig-pos: "right", fig-width: 35%,  // hình kèm đề
//     cols: 0,          // 0 = tự chọn số cột; 1/2/4 = cố định
//     lines: 0,         // số dòng chừa làm bài (bản in đề)
//     num: auto, prefix: "Câu", boxed: false,
//   )
// Form cũ (dap-an: "B", hinh:, cot:, loi-giai:) vẫn dùng được.
#let tn(
  cau, phuong-an, dap-an: none, cot: auto, cols: 0, diem: none,
  hinh: none, fig: none, fig-pos: "right", fig-width: auto,
  loi-giai: none, loigiai: none, lines: 0, num: auto, prefix: "Câu",
  boxed: false, fig-giai: none, hinh-giai: none, cham: auto, khoa-pa: false,
  fig-giai-pos: "right", fig-giai-width: auto, tieu-de: [Trắc nghiệm],
) = context {
  let lg = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let cot = if cols != 0 { cols } else { cot }
  let goi(..them) = cau-mc(
    cau, phuong-an, dap-an: dap-an, cot: cot, diem: diem, hinh: hinh, cham: cham,
    khoa-pa: khoa-pa,
    fig-pos: fig-pos, fig-width: fig-width, lines: lines,
    num: num, prefix: prefix, boxed: boxed,
    hinh-giai: hg, fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width, ..them,
  )
  if _la-sach(_ho-so.get()) {
    goi(loi-giai: _ghep(lg))
  } else {
    let man = tach-man(lg)
    let buoc-da = 2 + man.at(0).len()
    slide(tieu-de: tieu-de, so-buoc: buoc-da)[
      #goi(lo-da: buoc-da)
      #_giai-kem-hinh(giai-buoc(man.at(0)), hg, fig-giai-pos, fig-giai-width)
    ]
    _man-tiep(man, tieu-de)
  }
}

// FORM MỚI:
//   #ds(
//     [Thân câu chung — nêu tình huống / bài toán],
//     (
//       [Phát biểu a — SAI],
//       True([Phát biểu b — ĐÚNG]),   // ý đúng bọc True(...)
//       True([Phát biểu c — ĐÚNG]),
//       [Phát biểu d — SAI],
//     ),
//     loigiai: [Phân tích từng ý.],
//     fig: none, fig-pos: "right", fig-width: 30%,
//     lines: 0, num: auto, prefix: "Câu",
//   )
// Form cũ (dap-an: (false, true, true, false)) vẫn dùng được.
// Lời giải riêng từng ý (an toàn khi trộn hoán vị ý) — đặt `giai:` trong
// True(...)/Sai(...); `khoa-y: true` báo công cụ trộn đừng xáo các ý của câu.
#let ds(
  cau, cac-y, dap-an: none, diem: none,
  hinh: none, fig: none, fig-pos: "right", fig-width: auto,
  loi-giai: none, loigiai: none, o-tick: false, lines: 0, num: auto, cham: auto,
  khoa-y: false,
  prefix: "Câu", boxed: false, fig-giai: none, hinh-giai: none,
  fig-giai-pos: "right", fig-giai-width: auto, tieu-de: [Đúng — Sai],
) = context {
  let lg = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let goi(..them) = cau-tf(
    cau, cac-y, dap-an: dap-an, diem: diem, hinh: hinh, o-tick: o-tick, cham: cham,
    khoa-y: khoa-y,
    fig-pos: fig-pos, fig-width: fig-width, lines: lines,
    num: num, prefix: prefix, boxed: boxed,
    hinh-giai: hg, fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width, ..them,
  )
  if _la-sach(_ho-so.get()) {
    goi(loi-giai: _ghep(lg))
  } else {
    let man = tach-man(lg)
    let buoc-da = 2 + man.at(0).len()
    slide(tieu-de: tieu-de, so-buoc: buoc-da)[
      #goi(lo-da: buoc-da)
      #_giai-kem-hinh(giai-buoc(man.at(0)), hg, fig-giai-pos, fig-giai-width)
    ]
    _man-tiep(man, tieu-de)
  }
}

// FORM MỚI — đáp án đặt NGAY SAU đề bài (positional thứ 2):
//   #tln(
//     [Nội dung đề bài],
//     [$6$],                    // đáp án
//     loigiai: [Lời giải.],
//     fig: none, fig-pos: "right", fig-width: 30%,
//     show-boxes: true, box-count: 4,   // ô điền trên phiếu (bản in đề)
//     lines: 0, num: auto, prefix: "Câu",
//   )
// Form cũ (dap-an: [$6$]) vẫn dùng được.
#let tln(
  cau, ..tra-loi, dap-an: none, diem: none,
  hinh: none, fig: none, fig-pos: "right", fig-width: auto,
  loi-giai: none, loigiai: none, show-boxes: true, box-count: 4,
  lines: 0, num: auto, prefix: "Câu", boxed: false,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto,
  tieu-de: [Trả lời ngắn],
) = context {
  let lg = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let dap-an = if tra-loi.pos().len() > 0 { tra-loi.pos().first() } else { dap-an }
  let goi(..them) = cau-sa(
    cau, dap-an: dap-an, diem: diem, hinh: hinh,
    fig-pos: fig-pos, fig-width: fig-width,
    show-boxes: show-boxes, box-count: box-count, lines: lines,
    num: num, prefix: prefix, boxed: boxed,
    hinh-giai: hg, fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width, ..them,
  )
  if _la-sach(_ho-so.get()) {
    goi(loi-giai: _ghep(lg))
  } else {
    let man = tach-man(lg)
    let buoc-da = 2 + man.at(0).len()
    slide(tieu-de: tieu-de, so-buoc: buoc-da)[
      #goi(lo-da: buoc-da)
      #_giai-kem-hinh(giai-buoc(man.at(0)), hg, fig-giai-pos, fig-giai-width)
    ]
    _man-tiep(man, tieu-de)
  }
}

// Bộ dựng chung cho 4 dạng "kiểu tự luận" (TL/HĐ/LT/VDTT).
#let _dang-tl(ham-cau, cau, loi-giai, diem, cho-trong, hinh, tieu-de,
  hg: none, hg-pos: "right", hg-width: auto) = context {
  if _la-sach(_ho-so.get()) {
    ham-cau(cau, loi-giai: _ghep(loi-giai), diem: diem, cho-trong: cho-trong, hinh: hinh,
      hinh-giai: hg, fig-giai-pos: hg-pos, fig-giai-width: hg-width)
  } else {
    let man = tach-man(loi-giai)
    slide(tieu-de: tieu-de, so-buoc: 1 + calc.max(1, man.at(0).len()))[
      #ham-cau(cau, diem: diem, hinh: hinh)
      #_giai-kem-hinh(giai-buoc(man.at(0)), hg, hg-pos, hg-width)
    ]
    _man-tiep(man, tieu-de)
  }
}

// (loigiai:/fig:/fig-giai: là bí danh kiểu mới của loi-giai:/hinh:/hinh-giai:)
#let tl(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, tieu-de: [Tự luận]) = _dang-tl(cau-tl, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width)
#let hd(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, tieu-de: [Hoạt động]) = _dang-tl(cau-hd, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width)
#let lt(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, tieu-de: [Luyện tập]) = _dang-tl(cau-lt, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width)
#let vdtt(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, tieu-de: [Vận dụng]) = _dang-tl(cau-vdtt, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width)

#let phan(ten, ngan: none) = context {
  if _la-sach(_ho-so.get()) {
    // Heading cấp 1 (để vào MỤC LỤC #outline + bookmark PDF), nhưng hiển thị
    // y hệt khối màu cũ qua show-rule cục bộ (không ảnh hưởng heading khác).
    show heading.where(level: 1): it => block(
      width: 100%, fill: rgb("#eaf2f8"), inset: (x: 10pt, y: 7pt),
      stroke: (left: 3pt + _xanh), above: 14pt, below: 10pt,
      text(weight: "bold", fill: _xanh, it.body),
    )
    heading(level: 1, ten)
  } else {
    muc(ten, ngan: ngan)
  }
}

// =====================================================================
// KẾT THÚC ĐỀ + BẢNG ĐÁP ÁN  (chỉ dựng ở bản in A4 dethi/loigiai)
// =====================================================================

// ---------- #het — dòng kết thúc đề ----------
// Dựng khối "––––– HẾT –––––" + ghi chú (căn giữa), chỉ hiện ở bản in A4;
// ở beamer bỏ qua (không sinh slide thừa).
//   #het()                                  -> mặc định
//   #het(ghi-chu: [Không được dùng tài liệu.])
//   #het(chu: [THE END], ghi-chu: none)
#let het(
  chu: [HẾT],
  ghi-chu: [Thí sinh không được sử dụng tài liệu.\ Giám thị coi thi không giải thích gì thêm.],
) = context {
  if _la-sach(_ho-so.get()) {
    v(14pt)
    align(center, {
      text(weight: "bold", size: 1.05em)[#("–" * 5) #h(4pt) #chu #h(4pt) #("–" * 5)]
      if ghi-chu != none {
        linebreak()
        v(3pt)
        text(style: "italic", size: 0.95em, ghi-chu)
      }
    })
  }
}

// ---------- Cố gắng lấy CHUỖI từ đáp án (cho ô điền tln) ----------
// str/số -> chuỗi; content -> đọc .text/.children/.body đệ quy; không tách
// được -> none (khi đó bảng đáp án in nguyên nội dung vào một ô).
#let _da-chuoi(c) = {
  if c == none { return "" }
  if type(c) == str { return c }
  if type(c) == int or type(c) == float { return str(c) }
  if type(c) != content { return none }
  if c.has("text") { return c.text }
  if c.has("children") {
    let cac = c.children.map(_da-chuoi)
    if cac.any(p => p == none) { return none }
    return cac.join("")
  }
  if c.has("body") { return _da-chuoi(c.body) }
  none
}

// ---------- #bang-dap-an — 3 bảng đáp án tn / ds / tln ----------
// Tự thu thập đáp án MỌI câu tn/ds/tln trong tài liệu (qua metadata <bg-da>)
// rồi dựng bảng theo mẫu đề 2025. Mỗi loại đánh số 1..n độc lập.
//   #bang-dap-an(ma-de: "0101")
// Tham số:
//   ma-de     : auto = LẤY TỰ ĐỘNG từ mã đề khai ở de-toan (đồng bộ, khỏi nhập
//               tay); none = không in mã đề; hoặc giá trị cụ thể để ghi đè.
//   tieu-de   : auto = tự dựng theo ma-de; hoặc nội dung tuỳ ý; none = ẩn.
//   so-o-tln  : số ô mỗi đáp án trả lời ngắn (mặc định 4; tự nới nếu dài hơn).
//   ngat-trang: true = sang trang mới trước bảng.
#let bang-dap-an(
  ma-de: auto,
  tieu-de: auto,
  so-o-tln: 4,
  ngat-trang: true,
) = context {
  if not _la-sach(_ho-so.get()) { } else {
    let ma-de = if ma-de == auto { _ma-de.get() } else { ma-de }
    let items = query(<bg-da>).map(m => m.value)
    let ds-tn = items.filter(x => x.loai == "tn")
    let ds-ds = items.filter(x => x.loai == "ds")
    let ds-tln = items.filter(x => x.loai == "tln")
    if ds-tn.len() + ds-ds.len() + ds-tln.len() > 0 {
      if ngat-trang { pagebreak(weak: true) }

      // ----- Tiêu đề -----
      let td = if tieu-de == auto {
        if ma-de != none [BẢNG ĐÁP ÁN MÃ ĐỀ #ma-de] else [BẢNG ĐÁP ÁN]
      } else { tieu-de }
      if td != none {
        align(center, text(weight: "bold", size: 13pt, fill: _xanh, upper(td)))
        v(8pt)
      }

      let tieu-muc(nd) = block(above: 12pt, below: 7pt,
        text(weight: "bold", size: 1.05em, nd))

      // ===== 1) Trắc nghiệm nhiều lựa chọn =====
      if ds-tn.len() > 0 {
        tieu-muc[Bảng đáp án các câu trắc nghiệm nhiều lựa chọn]
        let o-tn(i, x) = box(stroke: 0.7pt + _xanh, radius: 2.5pt,
          inset: (x: 6pt, y: 3.5pt), baseline: 30%)[
          #text(fill: _xanh, weight: "bold")[#(i + 1).]~#text(weight: "bold")[#x.da]
        ]
        let cot = calc.min(ds-tn.len(), 12)
        grid(columns: (auto,) * cot, column-gutter: 6pt, row-gutter: 7pt,
          align: center + horizon,
          ..ds-tn.enumerate().map(p => o-tn(p.at(0), p.at(1))))
      }

      // ===== 2) Đúng — Sai =====
      if ds-ds.len() > 0 {
        tieu-muc[Bảng đáp án các câu trắc nghiệm đúng sai]
        let vong(dung) = if dung {
          circle(radius: 7pt, fill: _xanh, stroke: none,
            align(center + horizon, text(fill: white, weight: "bold", size: 8pt)[Đ]))
        } else {
          circle(radius: 7pt, fill: white, stroke: 0.9pt + luma(45%),
            align(center + horizon, text(weight: "bold", size: 8pt)[S]))
        }
        let o-ds(i, x) = {
          let bs = if type(x.da) == array { x.da } else { (false, false, false, false) }
          box(stroke: 0.7pt + luma(45%), radius: 2.5pt, inset: (x: 8pt, y: 6pt),
            baseline: 30%)[
            #text(fill: _do, weight: "bold")[Câu #(i + 1).]~~#h(2pt)#box(baseline: 35%,
              stack(dir: ltr, spacing: 3pt, ..bs.map(vong)))
          ]
        }
        grid(columns: (auto,) * calc.min(ds-ds.len(), 4),
          column-gutter: 8pt, row-gutter: 8pt, align: left + horizon,
          ..ds-ds.enumerate().map(p => o-ds(p.at(0), p.at(1))))
      }

      // ===== 3) Trả lời ngắn =====
      if ds-tln.len() > 0 {
        tieu-muc[Bảng đáp án các câu trắc nghiệm trả lời ngắn]
        let o-ky-tu(ky) = box(width: 17pt, height: 19pt, stroke: 0.7pt + luma(40%),
          radius: 1.5pt, inset: 0pt, align(center + horizon,
            if ky != none { text(size: 0.9em, ky) }))
        let o-tln(i, x) = {
          let s = _da-chuoi(x.da)
          let noi = if s != none {
            let kts = s.clusters()
            let n = calc.max(so-o-tln, kts.len())
            box(baseline: 35%, stack(dir: ltr, spacing: 3pt,
              ..range(n).map(k => o-ky-tu(if k < kts.len() { kts.at(k) } else { none }))))
          } else {
            // Không tách được thành ký tự -> in nguyên nội dung vào một ô rộng.
            box(stroke: 0.7pt + luma(40%), radius: 1.5pt, inset: (x: 5pt, y: 3pt),
              baseline: 30%, x.da)
          }
          box(stroke: 0.7pt + luma(45%), radius: 2.5pt, inset: (x: 8pt, y: 6pt),
            baseline: 30%)[
            #text(fill: _do, weight: "bold")[Câu #(i + 1).]~~#h(2pt)#noi
          ]
        }
        grid(columns: (auto,) * calc.min(ds-tln.len(), 3),
          column-gutter: 8pt, row-gutter: 8pt, align: left + horizon,
          ..ds-tln.enumerate().map(p => o-tln(p.at(0), p.at(1))))
      }
    }
  }
}

// Bí danh tên cũ (tương thích ngược): mc = tn, tf = ds, sa = tln.
#let mc = tn
#let tf = ds
#let sa = tln

// TƯƠNG THÍCH NGƯỢC: các file cũ vẫn gọi được
//   #let (vd, tn, ds, tln, tl, hd, lt, vdtt, phan) = tao-cau-hoi(ho-so)
// (tham số ho-so nay không còn cần thiết — hồ sơ đọc từ trạng thái).
#let tao-cau-hoi(..thua) = (
  vd: vd, tn: tn, ds: ds, tln: tln, tl: tl, hd: hd, lt: lt, vdtt: vdtt,
  phan: phan, mc: tn, tf: ds, sa: tln,
)
