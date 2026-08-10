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
#import "slide.typ": slide, muc, bai-giang, lo, vi-du, loi-giai, _ho-so, _la-sach, _buoc-ht, gian-dong, _gd, _dat-gian, _he-so-gian, _gian-ht, _bd-cau, cao-that, _cao-that, _chong-net, voi-cao-that, _vung-than
#import "cau-hoi.typ": cau-mc, cau-tf, cau-sa, cau-tl, cau-hd, cau-lt, cau-vdtt, bat-dap-an, tat-dap-an, voi-hinh, True, Dung, _la-y

// Gộp tham số kiểu mới / kiểu cũ: ưu tiên giá trị kiểu mới nếu được đặt.
#let _uu-tien(moi, cu) = if moi != none { moi } else { cu }

#let _xanh = rgb("#0f4c81")
#let _luc = rgb("#1e8449")
#let _do = rgb("#a93226")
// giữ tham chiếu đến môi trường lời giải (vì tham số cùng tên sẽ che nó)
#let _mt-loi-giai = loi-giai

// Mã đề khai ở de-toan -> lưu vào state để #bang-dap-an tự lấy (khỏi nhập tay).
#let _ma-de = state("bg-ma-de", none)

// =====================================================================
// HOÁN VỊ (TRỘN ĐỀ) — công tắc đặt Ở ĐẦU FILE ĐỀ
// ---------------------------------------------------------------------
// Cách dùng (khung một file ngân hàng / một đề thi):
//     #let ho-so = sys.inputs.at("ho-so", default: "dethi")
//     #let hoan-vi = false        // <- ĐỔI THÀNH true LÀ TRỘN
//     #show: de-toan.with(ho-so: ho-so, ma-de: "0101", hoan-vi: hoan-vi)
//
// NGUYÊN TẮC (chốt 08/2026):
//   • Hoán vị các CÂU trong cùng MỘT NHÓM THỂ LOẠI: nhóm tn xáo với nhau,
//     nhóm ds xáo với nhau, nhóm tln xáo với nhau. Câu tl GIỮ NGUYÊN thứ tự.
//     "Nhóm" = dãy câu CÙNG LOẠI đứng liền nhau (chỉ cách nhau bằng dòng
//     trống). Gặp #phan, một đoạn văn xen giữa, một câu tl... là hết nhóm và
//     sang nhóm mới ⇒ câu KHÔNG BAO GIỜ nhảy qua tiêu đề phần.
//   • Hoán vị 4 PHƯƠNG ÁN A/B/C/D của câu tn. Các Ý a/b/c/d của câu ds GIỮ
//     NGUYÊN, KHÔNG hoán vị (ý sau thường dựa vào ý trước).
//   • Chỉ chạy ở bản in A4 (dethi/loigiai); trình chiếu beamer không trộn.
//   • dethi và loigiai cùng mầm ⇒ RA CÙNG MỘT THỨ TỰ, bảng đáp án luôn khớp.
//
// hoan-vi: false (mặc định) | true (trộn cả câu lẫn phương án)
//          | "cau" (chỉ trộn thứ tự câu) | "pa" (chỉ trộn phương án)
// mam:     MÃ TRỘN — auto (mặc định) = băm từ `ma-de`, nên hai mã đề 0101 /
//          0102 tự cho hai thứ tự khác nhau; đặt tay `mam: 7` để ghi đè.
//
// GIỚI HẠN đã biết:
//   • Câu tn viết theo FORM CŨ `dap-an: "B"` (chữ cái) KHÔNG được trộn phương
//     án — trộn sẽ lệch đáp án. Muốn trộn thì bọc phương án đúng bằng True(...).
//   • `khoa-pa: true` ở một câu tn ⇒ riêng câu đó giữ nguyên thứ tự phương án.
// =====================================================================

// ---------- Bộ sinh số giả ngẫu nhiên TẤT ĐỊNH (LCG 32 bit) ----------
// Typst không có random. Dùng LCG để CÙNG một mầm luôn cho CÙNG một kết quả —
// nhờ vậy bản dethi và bản loigiai (hai lần biên dịch khác nhau) trộn giống hệt.
#let _hv-m = 2147483648
#let _hv-tiep(s) = calc.rem(1103515245 * s + 12345, _hv-m)

// Chuẩn hoá mầm: số / chuỗi / nội dung / none -> số nguyên không âm (băm djb2).
#let _hv-mam(x) = {
  if x == none or x == auto { return 20250101 }
  if type(x) == int { return calc.rem(calc.abs(x), _hv-m) }
  let s = if type(x) == str { x } else { repr(x) }
  let h = 5381
  for c in s.clusters() {
    h = calc.rem(h * 33 + str.to-unicode(c), _hv-m)
  }
  h
}

// Xáo một mảng theo mầm — RÚT ngẫu nhiên không hoàn lại (khỏi gán theo chỉ số).
#let _hv-xao(mang, mam) = {
  let con = mang
  let kq = ()
  let s = _hv-tiep(_hv-mam(mam) + 1013904223)
  while con.len() > 0 {
    s = _hv-tiep(s)
    let j = calc.rem(calc.quo(s, 65536), con.len())
    kq.push(con.at(j))
    con = con.slice(0, j) + con.slice(j + 1)
  }
  kq
}

// ---------- Nhãn nhận diện câu (đánh dấu chỗ được phép xáo) ----------
#let _hv-nhan = (tn: <bg-cau-tn>, ds: <bg-cau-ds>, tln: <bg-cau-tln>)
#let _gan-tn(c) = [#c <bg-cau-tn>]
#let _gan-ds(c) = [#c <bg-cau-ds>]
#let _gan-tln(c) = [#c <bg-cau-tln>]

// Phần tử "trắng" giữa hai câu (dòng trống, xuống dòng, khoảng trắng,
// metadata) — bỏ qua khi gom nhóm và LUÔN giữ nguyên vị trí lúc ghép lại.
#let _hv-f-space = [ ].func()
#let _hv-trong(c) = {
  if type(c) == str { return c.trim() == "" }
  if type(c) != content { return false }
  let f = c.func()
  f == _hv-f-space or f == parbreak or f == linebreak or f == metadata
}

// Loại của một phần tử: "tn" | "ds" | "tln" | none.
// Nếu markup bọc câu trong một sequence MỘT phần tử thì bóc thêm một lớp.
#let _hv-loai(c) = {
  if type(c) != content { return none }
  let l = c.at("label", default: none)
  if l == _hv-nhan.tn { return "tn" }
  if l == _hv-nhan.ds { return "ds" }
  if l == _hv-nhan.tln { return "tln" }
  if l == none and c.has("children") {
    let ct = c.children.filter(x => not _hv-trong(x))
    if ct.len() == 1 { return _hv-loai(ct.first()) }
  }
  none
}

// ---------- Xáo THỨ TỰ CÂU trong thân tài liệu ----------
// Duyệt các phần tử cấp cao nhất, gom từng DÃY LIỀN NHAU cùng loại rồi hoán vị
// các phần tử của dãy đó TẠI CHỖ (vị trí nào là câu tn thì sau khi trộn vẫn là
// câu tn). Phần tử không nhận diện được giữ nguyên vị trí ⇒ nếu vì lý do nào đó
// không nhận ra câu, tài liệu vẫn dựng đúng y như khi tắt trộn.
#let _hv-xao-than(than, mam) = {
  if type(than) != content or not than.has("children") { return than }
  let cs = than.children
  let n = cs.len()
  let kq = ()
  let nhom = 0
  let i = 0
  while i < n {
    let loai = _hv-loai(cs.at(i))
    if loai == none {
      kq.push(cs.at(i))
      i = i + 1
    } else {
      // gom dãy: các câu CÙNG loại, chỉ được cách nhau bằng phần tử trắng
      let vt = ()
      let cuoi = i
      let j = i
      while j < n {
        let lj = _hv-loai(cs.at(j))
        if lj == loai {
          vt.push(j)
          cuoi = j
          j = j + 1
        } else if _hv-trong(cs.at(j)) {
          j = j + 1
        } else {
          break
        }
      }
      nhom = nhom + 1
      let cac = vt.map(k => cs.at(k))
      let moi = if cac.len() > 1 { _hv-xao(cac, _hv-mam(mam) + nhom * 7919) } else { cac }
      let d = 0
      for k in range(i, cuoi + 1) {
        if vt.contains(k) {
          kq.push(moi.at(d))
          d = d + 1
        } else {
          kq.push(cs.at(k))
        }
      }
      i = cuoi + 1
    }
  }
  if kq.len() == 0 { than } else { kq.join() }
}

// Trạng thái để #tn biết có xáo phương án hay không (và xáo theo mầm nào).
//   bat: xáo PHƯƠNG ÁN · cau: xáo THỨ TỰ CÂU · mam: mầm chung.
// Khoá `cau` để các lệnh bố cục (#chia-2-cot, #chia-2-cot-lech) tự xáo lại
// phần thân NẰM TRONG cột — vì thân đó đã bị bọc thành MỘT phần tử nên vòng
// duyệt ở #de-toan không nhìn thấy các câu bên trong.
#let _hv = state("bg-hoan-vi", (bat: false, cau: false, mam: 0))

// Tách công tắc hoan-vi thành hai cờ: xáo CÂU và xáo PHƯƠNG ÁN.
#let _hv-che(h) = (
  cau: h == true or h == "cau" or h == "ca-hai",
  pa: h == true or h == "pa" or h == "ca-hai",
)

// Dùng như một show-rule RIÊNG khi tài liệu không đi qua #de-toan:
//   #show: hoan-vi-de.with(true)
//   #show: hoan-vi-de.with(true, mam: "0102")
// (Đi qua #de-toan thì chỉ cần tham số hoan-vi: — khỏi gọi hàm này.)
#let hoan-vi-de(bat, mam: auto, body) = {
  let che = _hv-che(bat)
  let m = _hv-mam(mam)
  _hv.update((bat: che.pa, cau: che.cau, mam: m))
  if che.cau { _hv-xao-than(body, m) } else { body }
}

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

#let _khoang-trang = [ ].func()

// Dòng "rỗng" — chỉ gồm khoảng trắng / dấu ngắt / metadata (không in ra gì).
#let _dong-trong(d) = {
  if d == none { return true }
  if type(d) != content { return false }
  let f = d.func()
  if f == _khoang-trang or f == linebreak or f == parbreak or f == metadata {
    return true
  }
  if f == text { return d.text.trim() == "" }
  if d.has("children") { return d.children.all(c => _dong-trong(c)) }
  false
}

// Cắt MỘT dòng tại dấu #sang-man đầu tiên -> (trước, sau, có-cắt-được).
// ⚠️ Lỗi cũ (09/08/2026): `tach-man` coi CẢ DÒNG chứa dấu là dấu ngắt rồi
// VỨT ĐI. Người soạn viết `... hết ý.` xuống dòng rồi `#sang-man \` (không có
// dấu \ ở cuối dòng chữ) thì cả câu chữ đó BIẾN MẤT khỏi trình chiếu. Nay cắt
// đôi tại dấu, giữ nguyên phần chữ hai bên.
// Chỉ cắt ở lớp con TRỰC TIẾP để không bóc mất lớp bọc (strong, emph...);
// dấu nằm sâu hơn thì trả `false` và dòng được giữ nguyên (dấu vô hình, chỉ
// mất tác dụng ngắt màn) — thà không ngắt còn hơn mất chữ.
#let _cat-sang-man(d) = {
  if type(d) != content { return (d, none, false) }
  if d.func() == metadata {
    return if d.value == "bg-sang-man" { (none, none, true) } else { (d, none, false) }
  }
  if not d.has("children") { return (d, none, false) }
  let truoc = ()
  let sau = ()
  let co = false
  for c in d.children {
    if co { sau.push(c) }
    else if (type(c) == content and c.func() == metadata
             and c.value == "bg-sang-man") { co = true }
    else { truoc.push(c) }
  }
  if not co { (d, none, false) } else { (truoc.join(), sau.join(), true) }
}

// Tách lời giải thành các màn; mỗi màn là một mảng dòng.
#let tach-man(nd) = {
  let man = ()
  let ht = ()
  for d in tach-dong(nd) {
    let con = d
    let dau = true   // lần lặp đầu: `con` còn là NGUYÊN dòng ban đầu
    while con != none {
      let (truoc, sau, co) = _cat-sang-man(con)
      // mảnh cắt ra chỉ toàn khoảng trắng thì bỏ; dòng nguyên thì giữ y như cũ
      if (dau and not co) or not _dong-trong(truoc) { ht.push(truoc) }
      if not co { con = none } else {
        if ht.len() > 0 { man.push(ht) }
        ht = ()
        con = sau
      }
      dau = false
    }
  }
  if ht.len() > 0 { man.push(ht) }
  if man.len() == 0 { ((),) } else { man }
}

// Ghép lại thành một khối (dùng cho bản A4) — bỏ các dấu #sang-man nhưng
// GIỮ nguyên chữ nằm cùng dòng với dấu (đi chung một đường với tach-man).
#let _ghep(nd) = {
  if nd == none { return none }
  let dong = ()
  for mk in tach-man(nd) { dong += mk }
  if dong.len() == 0 { return none }
  dong.join(linebreak())
}

// ---------- Lời giải hiện dần từng dòng (dùng trong slide) ----------
// Khung hiện từ bước `tu`; dòng thứ i hiện ở bước tu + i.
// gian: giãn dòng trong lời giải — ĐỘ DÀI tuyệt đối (mốc 0.95em, ~150% so với
//   thân slide 0.62em) để phân số, căn thức chồng tầng không dính vào nhau.
//   `auto` (mặc định) = 0.95em × hệ số giãn dòng hiện hành.
// gian-dong: HỆ SỐ giãn dòng riêng cho khung này (auto = lấy hệ số toàn tài
//   liệu do #bai-giang/#de-toan/#gian-dong đặt).
// do: true -> dựng SẴN mọi bước (không qua #lo) để ĐO chiều cao lúc cuối bài;
//   dùng cho bộ tự ngắt màn, không phải để hiển thị.
#let giai-buoc(nd, tu: 2, nhan: [Hướng dẫn giải. ], gian: auto, gian-dong: auto,
  do: false) = {
  let dong = tach-dong(nd)
  if dong.len() == 0 { return }
  let khung = block(
    width: 100%, inset: (left: 11pt, top: 5pt, bottom: 5pt),
    stroke: (left: 2.5pt + _luc), above: 10pt,
    context {
      let k = if gian-dong == auto { _he-so-gian() } else { gian-dong }
      let g = if gian == auto { 0.95em * k } else { gian }
      set par(leading: g, spacing: _gd.get().at("doan", default: 1.2em) * k)
      align(center, text(fill: _luc, weight: "bold", size: 0.84em, nhan))
      dong.at(0)
      for i in range(1, dong.len()) {
        let b = block(above: g, dong.at(i))
        if do { b } else { lo(tu + i, b) }
      }
    },
  )
  if do { khung } else { lo(tu, khung) }
}

// ---------- Ghi đè giãn dòng cho MỘT câu ----------
// gd == auto -> giữ nguyên; ngược lại nhân hệ số gd vào leading NỀN của hồ sơ.
#let _voi-gian(gd, nd) = if gd == auto { nd } else {
  context {
    let g = _gd.get()
    // giãn CẢ khoảng cách dòng lẫn khoảng cách đoạn (dòng trống trong nội dung)
    set par(leading: g.nen * gd, spacing: g.at("doan", default: 1.2em) * gd)
    nd
  }
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
  gian-dong: 1.0,      // HỆ SỐ GIÃN DÒNG (toàn file) — 1.0 = mốc mặc định
                       // (A4 đề thi 0.65em, trình chiếu 0.62em); 1.25 = giãn
                       // thêm 25%; 0.9 = thu lại 10%. Tăng khi phân số/căn
                       // thức nhiều tầng làm hai dòng dính nhau. Đổi giữa
                       // bài: #gian-dong(1.4); riêng một câu: tham số
                       // gian-dong: của #vd/#tn/#ds/#tln/#tl/#hd/#lt/#vdtt.
  mau-cong-thuc: auto, // MÀU MỌI CÔNG THỨC trong $...$ (toàn file) — auto = thừa
                       // kế màu chữ (đen ở thân, trắng ở tiêu đề); đặt màu cụ
                       // thể để nhuộm tất cả. Dùng chung cho cả 3 hồ sơ.
  hoan-vi: false,      // TRỘN ĐỀ — xem khối "HOÁN VỊ" ở đầu file này:
                       //   false (mặc định) = giữ nguyên thứ tự soạn;
                       //   true  = trộn thứ tự CÂU (theo nhóm tn/ds/tln, câu
                       //           tl giữ nguyên) VÀ trộn phương án A/B/C/D
                       //           của câu tn (ý a/b/c/d của ds giữ nguyên);
                       //   "cau" = chỉ trộn thứ tự câu;
                       //   "pa"  = chỉ trộn phương án.
                       // Chỉ tác dụng ở bản in A4 (dethi/loigiai).
  mam: auto,           // MÃ TRỘN: auto = băm từ `ma-de` (mã đề khác ⇒ thứ tự
                       // khác); hoặc số/chuỗi tuỳ ý để ghi đè.
  phu-de: none, gv: none, ngay: none,
  body,
) = {
  let hs = _chuan-ho-so(ho-so)
  _ma-de.update(ma-de)   // lưu mã đề để #bang-dap-an tự đồng bộ
  // ----- Hoán vị (trộn đề): chỉ ở bản in A4, beamer giữ nguyên bài giảng -----
  let _che = _hv-che(hoan-vi)
  let _mam = _hv-mam(if mam == auto { ma-de } else { mam })
  _hv.update((bat: _che.pa and hs != "beamer", cau: _che.cau and hs != "beamer", mam: _mam))
  let body = if _che.cau and hs != "beamer" { _hv-xao-than(body, _mam) } else { body }
  if hs == "beamer" {
    bai-giang(tieu-de: tieu-de, tieu-de-ngan: tieu-de-ngan, nen: nen,
      ti-le-chu: ti-le-chu, gian-dong: gian-dong, mau-cong-thuc: mau-cong-thuc,
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
    // 0.65em = leading mặc định của Typst -> gian-dong: 1.0 giữ y nguyên bố cục.
    _dat-gian(0.65em, gian-dong)
    set par(justify: true, leading: 0.65em * gian-dong, spacing: 1.2em * gian-dong)
    // Công thức TRONG DÒNG khai đúng chiều cao nét vẽ (phân số, căn, chỉ số
    // chồng tầng) ⇒ dòng VÀ ô lưới phương án tự nới đúng chỗ cần, khỏi phải
    // đôn `gian-dong` lên 3 rồi làm trống hoác chỗ khác. Tắt: #cao-that(false).
    show math.equation.where(block: false): _chong-net
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
// nhan-dau: nhãn của màn ĐẦU TIÊN khi màn 0 rỗng (đề dài quá nên lời giải bị
//   đẩy hết sang đây) — lúc đó chưa có gì để "tiếp", ghi nhãn thường.
#let _man-tiep(man, tieu-de, nhan: [Hướng dẫn giải (tiếp). ],
  nhan-dau: [Hướng dẫn giải. ], gd: auto) = {
  for (i, mk) in man.slice(1).enumerate() {
    let nh = if i == 0 and man.at(0).len() == 0 { nhan-dau } else { nhan }
    slide(tieu-de: tieu-de, so-buoc: calc.max(1, mk.len()))[
      #_voi-gian(gd, giai-buoc(mk, tu: 1, nhan: nh, gian-dong: gd))
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
#let _giai-kem-hinh(nd, hg, vi-tri, be-rong, do: false) = voi-hinh(
  nd,
  if hg == none { none } else if do { hg } else { lo(2, hg) },
  vi-tri: vi-tri, be-rong: be-rong,
)

// ---------- TỰ NGẮT MÀN KHI LỜI GIẢI TRÀN TRANG (chỉ beamer) ----------
// Bệnh cũ: lời giải cao hơn thân slide thì Typst đẩy phần thừa sang TRANG SAU,
// mà mỗi bước hoạt hình lại in slide LẠI TỪ ĐẦU ⇒ bấm chuyển bước thì thấy
// xen kẽ "đề bài + mấy dòng đầu" — "phần tràn" — "đề bài + mấy dòng đầu" …
// tức ĐỀ BÀI HIỆN LẶP LẠI giữa lời giải. Nay đo trước: dòng nào làm tràn thì
// tự đẩy sang một màn "(tiếp)" y như đặt #sang-man bằng tay.
// Tắt (giữ nếp cũ) cho cả tài liệu: #tu-ngat-man(false).
#let _tu-man = state("bg-tu-man", true)
#let tu-ngat-man(bat) = _tu-man.update(bat)

// Cắt một màn thành nhiều màn vừa trang. `dung(dòng, có-đề)` dựng thử nội dung
// slide (đã hiện hết mọi bước) để đo. Tìm nhị phân số dòng lớn nhất còn vừa.
#let _cat-vua(dong, co-de, dung, vung) = {
  if dong.len() == 0 { return (dong,) }
  let vua(n) = measure(block(width: vung.rong, dung(dong.slice(0, n), co-de))).height <= vung.cao
  if vua(dong.len()) { return (dong,) }
  // Đề bài dài, chiếm gần hết slide: slide đầu CHỈ hiện đề, lời giải sang màn
  // "(tiếp)" — thà một slide đề trơn còn hơn đề bị in lại giữa lời giải.
  if co-de and not vua(1) { return ((),) + _cat-vua(dong, false, dung, vung) }
  let a = 1              // màn tiếp luôn giữ ít nhất 1 dòng ⇒ chắc chắn tiến
  let b = dong.len()     // đã biết là KHÔNG vừa
  while b - a > 1 {
    let m = int((a + b) / 2)
    if vua(m) { a = m } else { b = m }
  }
  (dong.slice(0, a),) + _cat-vua(dong.slice(a), false, dung, vung)
}

#let _cat-man-vua(man, dung) = {
  if not _tu-man.get() { return man }
  let vung = _vung-than()
  let kq = ()
  for (i, mk) in man.enumerate() {
    if mk.len() == 0 { kq.push(mk) } else { kq += _cat-vua(mk, i == 0, dung, vung) }
  }
  kq
}

#let vd(noi-dung, loi-giai: none, loigiai: none, diem: none, hinh: none, fig: none,
  fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto,
  gian-dong: auto, tieu-de: [Ví dụ]) = context {
  let loi-giai = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let gd = gian-dong
  if _la-sach(_ho-so.get()) {
    // Ví dụ: LUÔN hiện lời giải, kể cả trong hồ sơ "dethi".
    _voi-gian(gd, {
      vi-du(voi-hinh(noi-dung, hinh))
      if loi-giai != none {
        _mt-loi-giai(voi-hinh(_ghep(loi-giai), hg, vi-tri: fig-giai-pos, be-rong: fig-giai-width))
      }
    })
  } else {
    let dung(dg, co-de) = if co-de {
      _voi-gian(gd, [
        #vi-du(voi-hinh(noi-dung, hinh))
        #_giai-kem-hinh(giai-buoc(dg, nhan: [Lời giải. ], gian-dong: gd, do: true), hg, fig-giai-pos, fig-giai-width, do: true)
      ])
    } else {
      _voi-gian(gd, giai-buoc(dg, tu: 1, nhan: [Lời giải (tiếp). ],
        gian-dong: gd, do: true))
    }
    let man = _cat-man-vua(tach-man(loi-giai), dung)
    // màn đầu rỗng (đề dài, lời giải đã bị đẩy hết sang màn "(tiếp)") thì
    // slide này chỉ cần MỘT bước — đừng in lại y hệt lần nữa.
    slide(tieu-de: tieu-de, so-buoc: if man.at(0).len() > 0 { 1 + man.at(0).len() }
      else if man.len() > 1 { 1 } else { 2 })[
      #_voi-gian(gd, [
        #vi-du(voi-hinh(noi-dung, hinh))
        #_giai-kem-hinh(giai-buoc(man.at(0), nhan: [Lời giải. ], gian-dong: gd), hg, fig-giai-pos, fig-giai-width)
      ])
    ]
    _man-tiep(man, tieu-de, nhan: [Lời giải (tiếp). ], nhan-dau: [Lời giải. ], gd: gd)
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
  fig-giai-pos: "right", fig-giai-width: auto, gian-dong: auto,
  trong-dong: auto,
  tieu-de: [Trắc nghiệm],
) = _gan-tn(context {
  let lg = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let gd = gian-dong
  let cot = if cols != 0 { cols } else { cot }
  // ----- HOÁN VỊ PHƯƠNG ÁN A/B/C/D -----
  // Chỉ xáo khi phương án đúng được bọc True(...) (form mới) — form cũ
  // `dap-an: "B"` gắn đáp án vào CHỮ CÁI nên xáo sẽ lệch. `khoa-pa: true`
  // giữ nguyên riêng câu này. Mầm riêng từng câu = mầm chung + số thứ tự câu
  // ⇒ mỗi câu một hoán vị khác nhau, mà vẫn tất định.
  let _hvt = _hv.get()
  let phuong-an = if (_hvt.bat and not khoa-pa and phuong-an.len() > 1
      and phuong-an.any(_la-y)) {
    let _so = _bd-cau.goc.get() + _bd-cau.cnt.get().first()
    _hv-xao(phuong-an, _hvt.mam + (_so + 1) * 104729)
  } else { phuong-an }
  let goi(..them) = cau-mc(
    cau, phuong-an, dap-an: dap-an, cot: cot, diem: diem, hinh: hinh, cham: cham,
    khoa-pa: khoa-pa, trong-dong: trong-dong,
    fig-pos: fig-pos, fig-width: fig-width, lines: lines,
    num: num, prefix: prefix, boxed: boxed,
    hinh-giai: hg, fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width, ..them,
  )
  if _la-sach(_ho-so.get()) {
    _voi-gian(gd, goi(loi-giai: _ghep(lg)))
  } else {
    let dung(dg, co-de) = if co-de {
      _voi-gian(gd, [
        #goi(lo-da: 1)
        #_giai-kem-hinh(giai-buoc(dg, gian-dong: gd, do: true), hg, fig-giai-pos, fig-giai-width, do: true)
      ])
    } else {
      _voi-gian(gd, giai-buoc(dg, tu: 1, nhan: [Hướng dẫn giải (tiếp). ],
        gian-dong: gd, do: true))
    }
    let man = _cat-man-vua(tach-man(lg), dung)
    let buoc-da = 2 + man.at(0).len()
    slide(tieu-de: tieu-de, so-buoc: buoc-da)[
      #_voi-gian(gd, [
        #goi(lo-da: buoc-da)
        #_giai-kem-hinh(giai-buoc(man.at(0), gian-dong: gd), hg, fig-giai-pos, fig-giai-width)
      ])
    ]
    _man-tiep(man, tieu-de, gd: gd)
  }
})

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
  khoa-y: false, trong-dong: auto,
  prefix: "Câu", boxed: false, fig-giai: none, hinh-giai: none,
  fig-giai-pos: "right", fig-giai-width: auto, gian-dong: auto,
  tieu-de: [Đúng — Sai],
) = _gan-ds(context {
  let lg = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let gd = gian-dong
  let goi(..them) = cau-tf(
    cau, cac-y, dap-an: dap-an, diem: diem, hinh: hinh, o-tick: o-tick, cham: cham,
    khoa-y: khoa-y, trong-dong: trong-dong,
    fig-pos: fig-pos, fig-width: fig-width, lines: lines,
    num: num, prefix: prefix, boxed: boxed,
    hinh-giai: hg, fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width, ..them,
  )
  if _la-sach(_ho-so.get()) {
    _voi-gian(gd, goi(loi-giai: _ghep(lg)))
  } else {
    let dung(dg, co-de) = if co-de {
      _voi-gian(gd, [
        #goi(lo-da: 1)
        #_giai-kem-hinh(giai-buoc(dg, gian-dong: gd, do: true), hg, fig-giai-pos, fig-giai-width, do: true)
      ])
    } else {
      _voi-gian(gd, giai-buoc(dg, tu: 1, nhan: [Hướng dẫn giải (tiếp). ],
        gian-dong: gd, do: true))
    }
    let man = _cat-man-vua(tach-man(lg), dung)
    let buoc-da = 2 + man.at(0).len()
    slide(tieu-de: tieu-de, so-buoc: buoc-da)[
      #_voi-gian(gd, [
        #goi(lo-da: buoc-da)
        #_giai-kem-hinh(giai-buoc(man.at(0), gian-dong: gd), hg, fig-giai-pos, fig-giai-width)
      ])
    ]
    _man-tiep(man, tieu-de, gd: gd)
  }
})

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
  gian-dong: auto, tieu-de: [Trả lời ngắn],
) = _gan-tln(context {
  let lg = _uu-tien(loigiai, loi-giai)
  let hinh = _uu-tien(fig, hinh)
  let hg = _uu-tien(fig-giai, hinh-giai)
  let gd = gian-dong
  let dap-an = if tra-loi.pos().len() > 0 { tra-loi.pos().first() } else { dap-an }
  let goi(..them) = cau-sa(
    cau, dap-an: dap-an, diem: diem, hinh: hinh,
    fig-pos: fig-pos, fig-width: fig-width,
    show-boxes: show-boxes, box-count: box-count, lines: lines,
    num: num, prefix: prefix, boxed: boxed,
    hinh-giai: hg, fig-giai-pos: fig-giai-pos, fig-giai-width: fig-giai-width, ..them,
  )
  if _la-sach(_ho-so.get()) {
    _voi-gian(gd, goi(loi-giai: _ghep(lg)))
  } else {
    let dung(dg, co-de) = if co-de {
      _voi-gian(gd, [
        #goi(lo-da: 1)
        #_giai-kem-hinh(giai-buoc(dg, gian-dong: gd, do: true), hg, fig-giai-pos, fig-giai-width, do: true)
      ])
    } else {
      _voi-gian(gd, giai-buoc(dg, tu: 1, nhan: [Hướng dẫn giải (tiếp). ],
        gian-dong: gd, do: true))
    }
    let man = _cat-man-vua(tach-man(lg), dung)
    let buoc-da = 2 + man.at(0).len()
    slide(tieu-de: tieu-de, so-buoc: buoc-da)[
      #_voi-gian(gd, [
        #goi(lo-da: buoc-da)
        #_giai-kem-hinh(giai-buoc(man.at(0), gian-dong: gd), hg, fig-giai-pos, fig-giai-width)
      ])
    ]
    _man-tiep(man, tieu-de, gd: gd)
  }
})

// Bộ dựng chung cho 4 dạng "kiểu tự luận" (TL/HĐ/LT/VDTT).
#let _dang-tl(ham-cau, cau, loi-giai, diem, cho-trong, hinh, tieu-de,
  hg: none, hg-pos: "right", hg-width: auto, gd: auto) = context {
  if _la-sach(_ho-so.get()) {
    _voi-gian(gd, ham-cau(cau, loi-giai: _ghep(loi-giai), diem: diem,
      cho-trong: cho-trong, hinh: hinh,
      hinh-giai: hg, fig-giai-pos: hg-pos, fig-giai-width: hg-width))
  } else {
    let dung(dg, co-de) = if co-de {
      _voi-gian(gd, [
        #ham-cau(cau, diem: diem, hinh: hinh)
        #_giai-kem-hinh(giai-buoc(dg, gian-dong: gd, do: true), hg, hg-pos, hg-width, do: true)
      ])
    } else {
      _voi-gian(gd, giai-buoc(dg, tu: 1, nhan: [Hướng dẫn giải (tiếp). ],
        gian-dong: gd, do: true))
    }
    let man = _cat-man-vua(tach-man(loi-giai), dung)
    // màn đầu rỗng (đề dài, lời giải đã bị đẩy hết sang màn "(tiếp)") thì
    // slide này chỉ cần MỘT bước — đừng in lại y hệt lần nữa.
    slide(tieu-de: tieu-de, so-buoc: if man.at(0).len() > 0 { 1 + man.at(0).len() }
      else if man.len() > 1 { 1 } else { 2 })[
      #_voi-gian(gd, [
        #ham-cau(cau, diem: diem, hinh: hinh)
        #_giai-kem-hinh(giai-buoc(man.at(0), gian-dong: gd), hg, hg-pos, hg-width)
      ])
    ]
    _man-tiep(man, tieu-de, gd: gd)
  }
}

// (loigiai:/fig:/fig-giai: là bí danh kiểu mới của loi-giai:/hinh:/hinh-giai:)
#let tl(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, gian-dong: auto, tieu-de: [Tự luận]) = _dang-tl(cau-tl, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width, gd: gian-dong)
#let hd(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, gian-dong: auto, tieu-de: [Hoạt động]) = _dang-tl(cau-hd, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width, gd: gian-dong)
#let lt(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, gian-dong: auto, tieu-de: [Luyện tập]) = _dang-tl(cau-lt, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width, gd: gian-dong)
#let vdtt(cau, loi-giai: none, loigiai: none, diem: none, cho-trong: 0pt, hinh: none, fig: none, fig-giai: none, hinh-giai: none, fig-giai-pos: "right", fig-giai-width: auto, gian-dong: auto, tieu-de: [Vận dụng]) = _dang-tl(cau-vdtt, cau, _uu-tien(loigiai, loi-giai), diem, cho-trong, _uu-tien(fig, hinh), tieu-de, hg: _uu-tien(fig-giai, hinh-giai), hg-pos: fig-giai-pos, hg-width: fig-giai-width, gd: gian-dong)

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
// BỐ CỤC PHẦN CÂU HỎI — #chia-2-cot · #chia-2-cot-lech   (08/2026)
// ---------------------------------------------------------------------
// Hai lệnh này dùng như SHOW-RULE: ĐẶT Ở ĐÂU THÌ ÁP DỤNG TỪ DÒNG ĐÓ TRỞ
// XUỐNG (đúng lối #show: de-toan.with(...) đã quen):
//
//     #show: de-toan.with(ho-so: ho-so, tieu-de: [...])
//     #show: chia-2-cot                  // từ đây trở xuống: 2 cột đều nhau
//     #tn(...) #tn(...) ...
//
//     #show: chia-2-cot-lech             // trái = câu hỏi, phải = chỗ làm bài
//     #show: chia-2-cot-lech.with(rong-trai: 60%)     // đổi bề rộng cột trái
//
// Muốn NGỪNG chia cột (bắt buộc trước #bang-dap-an, vì lệnh đó có
// #pagebreak mà pagebreak không chạy được bên trong cột) thì đặt
//     #thoi-cot()
// — phần sau dấu này trở lại nguyên khổ giấy.
//
// Cũng dùng được dạng KHỐI cho một đoạn: #chia-2-cot[ ... ].
//
// Chỉ tác dụng ở bản in A4 (dethi/loigiai); trình chiếu beamer bỏ qua
// (mỗi câu vốn đã là một slide riêng).
// =====================================================================

// ---------- Dấu kết thúc vùng chia cột ----------
#let thoi-cot() = metadata("bg-thoi-cot")

#let _la-thoi-cot(c) = (type(c) == content and c.func() == metadata
  and c.value == "bg-thoi-cot")

// Tách thân thành (phần NẰM TRONG cột, phần SAU #thoi-cot()).
// Không có dấu #thoi-cot() ⇒ (toàn bộ thân, none).
#let _tach-thoi-cot(than) = {
  if type(than) != content or not than.has("children") { return (than, none) }
  let cs = than.children
  let i = cs.position(_la-thoi-cot)
  if i == none { return (than, none) }
  let truoc = cs.slice(0, i)
  let sau = cs.slice(i + 1)
  (
    if truoc.len() == 0 { none } else { truoc.join() },
    if sau.len() == 0 { none } else { sau.join() },
  )
}

// Phần thân nằm TRONG cột đã bị bọc thành MỘT phần tử nên vòng duyệt hoán vị
// ở #de-toan không nhìn thấy các câu bên trong ⇒ xáo lại ngay tại đây.
// (Mầm vẫn là mầm chung ⇒ bản dethi và bản loigiai trộn giống hệt nhau.)
#let _cot-than(nd) = {
  let hv = _hv.get()
  if nd != none and hv.at("cau", default: false) { _hv-xao-than(nd, hv.mam) } else { nd }
}

// ---------- Tự CÂN BẰNG chiều cao các cột ----------
// Typst KHÔNG cân bằng `columns`: cột 1 được rót đầy tới HẾT chiều cao trang
// rồi mới tràn sang cột 2 ⇒ phần câu hỏi ngắn (chưa đầy một trang) nằm gọn
// trong cột 1, cột 2 để trống — nhìn y như lệnh không chạy.
// Cách chữa: đo chiều cao thân ở bề rộng MỘT CỘT rồi chèn #colbreak() tại các
// mốc 1/so, 2/so… của tổng chiều cao. KHÔNG dùng block(height:) cố định (thân
// cao hơn dự tính là tràn ra ngoài khung).
// Thân DÀI hơn `tran` (không gọn trong một trang) thì để Typst tự rót như cũ.
#let _can-cot(nd, so, wcol, tran) = {
  if so < 2 or type(nd) != content or not nd.has("children") { return nd }
  let tong = measure(block(width: wcol, nd)).height
  if tong <= 0pt or tong >= tran { return nd }
  let cs = nd.children
  // Đo TỪNG phần tử (bỏ qua phần tử trắng) — dùng chính tổng của các phép đo
  // rời này làm mốc chia, nhờ vậy sai số khoảng cách giữa các khối tự triệt
  // tiêu, không bị lệch dồn về một phía.
  let cao = cs.map(c => if _hv-trong(c) { 0pt } else {
    measure(block(width: wcol, c)).height })
  let tong-le = cao.fold(0pt, (a, b) => a + b)
  if tong-le <= 0pt { return nd }
  let muc = tong-le / so
  let kq = ()
  let dang = 0pt
  let cot = 1
  for (i, c) in cs.enumerate() {
    if cot < so and dang >= muc * cot and not _hv-trong(c) {
      kq.push(colbreak())
      cot = cot + 1
    }
    kq.push(c)
    dang = dang + cao.at(i)
  }
  kq.join()
}

// ---------- #chia-2-cot — chia phần câu hỏi thành 2 cột đều nhau ----------
//   so     : số cột (mặc định 2; đặt 3 nếu muốn ba cột)
//   khoang : khe giữa hai cột
//   can    : true (mặc định) = tự cân chiều cao hai cột; false = để Typst rót
//            đầy cột 1 trước (lối gốc của Typst)
#let chia-2-cot(so: 2, khoang: 18pt, can: true, body) = context {
  if not _la-sach(_ho-so.get()) { body } else {
    let (nd0, sau) = _tach-thoi-cot(body)
    if nd0 != none {
      let nd = _cot-than(nd0)
      layout(kich => {
        let wcol = (kich.width - khoang * (so - 1)) / so
        let than = if can { _can-cot(nd, so, wcol, kich.height * so) } else { nd }
        columns(so, gutter: khoang, than)
      })
    }
    if sau != none { sau }
  }
}

// ---------- #chia-2-cot-lech — cột trái câu hỏi, cột phải cho HS làm bài ----
// Cột phải để trống, kẻ hàng ngang MỜ (kiểu vở kẻ ngang) và có vạch dọc mờ
// ngăn giữa hai cột. Số hàng kẻ tính theo chiều cao thật của phần câu hỏi
// (đo bằng measure) nên không thừa/thiếu giấy.
//   rong-trai   : BỀ RỘNG CỘT TRÁI — mặc định 70% khổ chữ; nhận cả tỉ lệ
//                 (60%) lẫn độ dài tuyệt đối (11cm).
//   khoang      : khe giữa hai cột
//   cao-dong    : khoảng cách giữa hai hàng kẻ (mặc định 9mm)
//   mau, day    : màu và độ dày hàng kẻ
//   ke          : false = cột phải để trắng trơn (không kẻ dòng)
//   vach-ngan   : true (mặc định) = vạch dọc mờ ngăn hai cột
//   tieu-de-phai: vd [Bài làm] — in nhạt ở đầu cột phải; none = không in
#let chia-2-cot-lech(
  rong-trai: 70%,
  khoang: 10pt,
  cao-dong: 9mm,
  mau: luma(65%),
  day: 0.4pt,
  ke: true,
  vach-ngan: true,
  tieu-de-phai: none,
  body,
) = context {
  if not _la-sach(_ho-so.get()) { body } else {
    let (nd0, sau) = _tach-thoi-cot(body)
    let nd = _cot-than(nd0)
    if nd != none {
      layout(kich => {
        let wc = kich.width
        let w0 = if type(rong-trai) == ratio { wc * rong-trai
        } else if type(rong-trai) == relative { wc * rong-trai.ratio + rong-trai.length
        } else { rong-trai }
        // chốt chặn: cột trái không hẹp quá 2cm, không nuốt hết cột phải
        let wt = calc.max(2cm, calc.min(w0, wc - khoang - 1.5cm))
        let wp = wc - wt - khoang
        if wp <= 0pt {
          // không đủ chỗ cho cột phải ⇒ giữ nguyên lối một cột (an toàn)
          nd
        } else {
          let cao = measure(block(width: wt, nd)).height
          let so-dong = calc.min(4000, calc.max(1, int(calc.floor(cao / cao-dong))))
          let dong-ke = block(
            width: 100%, height: cao-dong, above: 0pt, below: 0pt, breakable: false,
            place(bottom + left, line(length: 100%, stroke: day + mau)),
          )
          grid(
            columns: (wt, wp), column-gutter: khoang,
            block(width: 100%, nd),
            block(
              width: 100%,
              stroke: if vach-ngan { (left: day + mau) } else { none },
              inset: (left: if vach-ngan { 7pt } else { 0pt }),
              above: 0pt, below: 0pt,
              {
                if tieu-de-phai != none {
                  block(above: 0pt, below: 3pt,
                    text(size: 0.85em, style: "italic", fill: mau.darken(25%), tieu-de-phai))
                }
                if ke { for _ in range(so-dong) { dong-ke } }
              },
            ),
          )
        }
      })
    }
    if sau != none { sau }
  }
}

// =====================================================================
// #ke-het-trang — KẺ DÒNG LẤP ĐẦY CHỖ TRỐNG CÒN LẠI CỦA TRANG  (08/2026)
// ---------------------------------------------------------------------
// Đặt ở đâu thì kẻ dòng từ chỗ đó xuống HẾT TRANG ĐÓ — số dòng tự tính, không
// phải đếm tay:
//     #ke-het-trang()                        // nét chấm, cách 9mm
//     #ke-het-trang(cao-dong: 7mm, kieu: none)   // nét liền, dày dòng hơn
//     #ke-het-trang(chua: 2cm)               // chừa 2cm cuối trang
//     #ke-het-trang(them-trang: 1)           // kẻ thêm TRỌN 1 trang nữa
//
// Cách làm: `here().position().y` cho biết đang ở đâu trên trang, trừ khỏi
// `page.height` và lề dưới là ra chỗ còn lại, chia cho `cao-dong` ra số dòng.
// Vị trí của chính lệnh này KHÔNG bị đẩy đi bởi các dòng kẻ nó sinh ra (chúng
// nằm SAU nó) nên phép đo ổn định, không lặp vô hạn.
//
// Chỉ dựng ở bản in A4 (dethi/loigiai); beamer bỏ qua như #het/#bang-dap-an.
// =====================================================================
#let ke-het-trang(
  cao-dong: 9mm,     // khoảng cách giữa hai dòng kẻ
  mau: luma(65%),    // màu nét
  day: 0.4pt,        // độ dày nét
  kieu: "dotted",    // "dotted" | "dashed" | "dash-dotted" | none (nét liền)
  dai: 100%,         // bề dài dòng kẻ (50% = nửa bề ngang)
  chua: 0pt,         // chừa thêm chỗ trống ở đáy trang
  le-tren: auto,     // ghi đè lề trang nếu lề khai kiểu lạ
  le-duoi: auto,
  them-trang: 0,     // kẻ thêm bao nhiêu TRANG ĐẦY nữa sau trang hiện tại
) = context {
  if not _la-sach(_ho-so.get()) { } else if type(page.height) != length { } else {
    // ----- lấy lề trên / lề dưới từ thiết lập trang -----
    let m = page.margin
    let _le(khoa, mac-dinh) = {
      if type(m) == dictionary { m.at(khoa, default: m.at("y", default: mac-dinh))
      } else if m == auto { 2.5cm } else { m }
    }
    let lt = if le-tren != auto { le-tren } else { _le("top", 1.6cm) }
    let ld = if le-duoi != auto { le-duoi } else { _le("bottom", 2.2cm) }

    // MỘT dòng kẻ = MỘT khối cao ĐÚNG `cao-dong`, nét vẽ sát đáy khối.
    // ⚠️ ĐỪNG viết `v(cao-dong); line(...)`: `line` tự tạo một ĐOẠN VĂN nên
    // Typst cộng thêm khoảng cách đoạn trên/dưới ⇒ mỗi dòng chiếm gần GẤP ĐÔI
    // `cao-dong`, số dòng tính ra thừa và tràn sang trang sau.
    let net = (paint: mau, thickness: day, dash: kieu)
    let mot-dong = block(
      width: 100%, height: cao-dong, above: 0pt, below: 0pt, breakable: false,
      place(bottom + left, line(length: dai, stroke: net)),
    )

    // ----- phần còn lại của TRANG HIỆN TẠI -----
    // trừ thêm 1mm chống tràn (khoảng cách đoạn của khối đứng ngay trên lệnh
    // có thể đẩy vị trí xuống một chút so với phép đo)
    let con = page.height - here().position().y - ld - chua - 1mm
    for _ in range(calc.max(0, int(calc.floor(con / cao-dong)))) { mot-dong }

    // ----- các trang ĐẦY tiếp theo (nếu có) -----
    if them-trang > 0 {
      let cao-trang = page.height - lt - ld - chua
      let n-day = calc.max(0, int(calc.floor(cao-trang / cao-dong)))
      for _ in range(them-trang) {
        pagebreak()
        for _ in range(n-day) { mot-dong }
      }
    }
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
