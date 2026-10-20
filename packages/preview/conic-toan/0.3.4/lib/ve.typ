// =====================================================================
// ve.typ — ENGINE VẼ HÌNH THUẦN TYPST (không phụ thuộc package nào)
// Hệ toạ độ toán học: gốc do người dùng chọn, trục y hướng LÊN.
// Mọi hàm vẽ nhận `ctx` (do #hinh cung cấp) + toạ độ dạng (x, y) là số.
// Quy ước tham số chung: mau (màu), day (độ dày nét), dut (nét đứt).
// =====================================================================

// ---------- Khung vẽ ----------
// Tạo khung vẽ. `ve` là hàm nhận ctx và trả về nội dung vẽ.
// h: auto => tự tính để 2 trục CÙNG TỈ LỆ (nên giữ auto với hình hình học).
// Ngăn xếp ctx của các khung hình đang vẽ — cho phép GỌI HÀM VẼ KHÔNG CẦN ctx
// (xem _voi-ctx ngay dưới hinh). Đẩy vào khi vào khung, lấy ra khi rời khung.
#let _ctx-ht = state("bg-ctx-ht", ())

/// Khung vẽ: đặt cửa sổ toạ độ toán (xmin..xmax, ymin..ymax) rồi vẽ bên trong.
/// Mọi lệnh vẽ đặt trong thân hàm này là tự có `ctx`, không phải gõ.
/// -> content
#let hinh(
  w: 8cm,
  h: auto,
  xmin: -5, xmax: 5,
  ymin: -4, ymax: 4,
  co-chu: 10pt,
  khung: false,   // vẽ viền khung (để căn chỉnh khi soạn)
  cat: false,     // cắt phần tràn ra ngoài khung
  ve,
) = {
  let hh = if h == auto { w * (ymax - ymin) / (xmax - xmin) } else { h }
  let ctx = (
    w: w, h: hh,
    xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax,
    sx: w / (xmax - xmin),
    sy: hh / (ymax - ymin),
  )
  box(
    width: w, height: hh,
    stroke: if khung { 0.4pt + luma(70%) } else { none },
    clip: cat,
    {
      set text(size: co-chu)
      _ctx-ht.update(s => s + (ctx,))
      ve(ctx)
      _ctx-ht.update(s => s.slice(0, -1))
    },
  )
}

// Bọc hàm vẽ f(ctx, ...) thành hàm gọi được KHÔNG CẦN ctx: nếu đối số đầu là
// ctx thì gọi thẳng (lối cũ), không thì tự lấy ctx của khung hình đang vẽ.
// Dùng ở baigiang.typ để bọc đồng loạt các hàm vẽ (xem cuối file đó).
//
// ⚠ NGĂN XẾP RỖNG — KHÔNG ĐƯỢC panic (xem CLAUDE.md, mục "CTX NGẦM TRONG
// MEASURE"). Nội dung nằm trong `measure(...)` KHÔNG được dựng vào tài liệu nên
// mọi `state.update` bên trong nó vô hiệu: `_ctx-ht.get()` trả về giá trị CUỐI
// tài liệu = () ⇒ trước đây panic, làm beamer chết ở phép đo tự ngắt màn
// (_cat-man-vua) và ở `cot: auto` của cau-mc. Nay:
//   · trong measure ⇒ BỎ QUA, không vẽ gì. Phép đo KHÔNG đổi vì #hinh là `box`
//     có width/height CỐ ĐỊNH, nét vẽ bên trong đều `place` (không chiếm chỗ);
//     bản in thật thì ngăn xếp đầy đủ nên vẫn vẽ đúng như cũ.
//   · thật sự quên #hinh(...) ⇒ ghi DẤU ĐỎ (dùng `place` nên không phá bố cục)
//     thay cho panic — đủ để thấy mà không giết cả lần biên dịch.
#let _voi-ctx(f) = (..a) => {
  let p = a.pos()
  if p.len() > 0 and type(p.at(0)) == dictionary and "sx" in p.at(0) {
    f(..a)
  } else {
    context {
      let ds = _ctx-ht.get()
      if ds.len() > 0 {
        f(ds.last(), ..a)
      } else {
        place(text(fill: red, size: 7pt)[⚠ lệnh vẽ đặt NGOÀI khung hình])
      }
    }
  }
}

// ---------- Đổi toạ độ ----------
// Toạ độ toán (x, y) -> toạ độ trang (length, length), gốc trên-trái.
#let toa(ctx, P) = {
  let Q = if "bien-doi" in ctx and ctx.bien-doi != none { (ctx.bien-doi)(P) } else { P }
  ((Q.at(0) - ctx.xmin) * ctx.sx, (ctx.ymax - Q.at(1)) * ctx.sy)
}
// Như trên nhưng trả về số float tính bằng pt (để tính toán).
#let toa-pt(ctx, P) = {
  let q = toa(ctx, P)
  (q.at(0).pt(), q.at(1).pt())
}

// ---------- Phép biến hình (toạ độ toán) ----------
// Quay điểm P quanh tâm `tam` góc `goc` (dương = ngược chiều kim đồng hồ).
#let quay-diem(P, tam, goc) = {
  let dx = P.at(0) - tam.at(0)
  let dy = P.at(1) - tam.at(1)
  let c = calc.cos(goc)
  let s = calc.sin(goc)
  (tam.at(0) + dx * c - dy * s, tam.at(1) + dx * s + dy * c)
}
// Tịnh tiến điểm P theo vectơ v.
#let tinh-tien-diem(P, v) = (P.at(0) + v.at(0), P.at(1) + v.at(1))
// Toạ độ CỰC kiểu TikZ: điểm cách `tam` một khoảng `bk`, quay góc `goc`
// (số trần = ĐỘ, nhận cả kiểu angle 30deg/0.5rad; dương = ngược kim đồng hồ).
//   toa-cuc((0,0), 2, 30)  ~  TikZ (30:2)
/// Toạ độ cực kiểu TikZ: điểm cách `tam` một khoảng `bk`, theo `goc`
/// (số trần = độ, dương = ngược kim đồng hồ). TikZ `(30:2)` <=> `toa-cuc((0,0), 2, 30)`.
/// TRẢ VỀ điểm, không vẽ gì.
#let toa-cuc(tam, bk, goc) = {
  let g = if type(goc) == angle { goc } else { goc * 1deg }
  (tam.at(0) + bk * calc.cos(g), tam.at(1) + bk * calc.sin(g))
}
// Dựng điểm M sao cho tia AM = tia AB QUAY quanh A một góc lượng giác `goc`
// (số trần = ĐỘ, dương = ngược kim đồng hồ) và AM = `r`. Nói cách khác, góc
// định hướng (AB, AM) = `goc`. Dùng dựng đỉnh tam giác biết một cạnh + một góc.
//   let M = dung-diem(A, B, 60, 3)     // góc BAM = 60°, AM = 3
/// TRẢ VỀ điểm M: tia AM là tia AB quay quanh A góc lượng giác `goc`
/// (số trần = độ, dương ngược kim đồng hồ), độ dài AM = `r`. Không vẽ gì.
#let dung-diem(A, B, goc, r) = {
  let g = if type(goc) == angle { goc } else { goc * 1deg }
  let base = calc.atan2(B.at(0) - A.at(0), B.at(1) - A.at(1))
  toa-cuc(A, r, base + g)
}
// Ghép thêm một phép biến hình f vào ctx (nội bộ; phép cũ làm trước, f làm sau).
#let _ghep-bien-doi(ctx, f) = {
  let cu = ctx.at("bien-doi", default: none)
  ctx + (bien-doi: if cu == none { f } else { P => f((cu)(P)) })
}
// Bản sao ctx bị QUAY: mọi hàm vẽ dùng ctx này đều quay quanh `tam` góc `goc`.
//   let cq = ctx-quay(ctx, 30deg, tam: (1, 1)); tam-giac(cq, A, B, C)
// Bản sao ctx bị TỊNH TIẾN theo vectơ v; ghép nối tiếp được nhiều phép:
//   ctx-tinh-tien(ctx-quay(ctx, 30deg, tam: G), (2, 0))  — quay trước, tịnh tiến sau
// Lưu ý: duong-tron/elip vẫn đúng dưới 2 phép này (tâm tự biến đổi); riêng
// gach-vung mô tả miền theo toạ độ GỐC của khung (không qua bien-doi).
#let ctx-quay(ctx, goc, tam: (0, 0)) = _ghep-bien-doi(ctx, P => quay-diem(P, tam, goc))
#let ctx-tinh-tien(ctx, v) = _ghep-bien-doi(ctx, P => tinh-tien-diem(P, v))

// Kiểu nét
#let net(mau, day, dut) = (
  paint: mau,
  thickness: day,
  dash: if dut { "dashed" } else { none },
)

// ---------- Nguyên thuỷ cấp thấp (toạ độ pt, dùng nội bộ) ----------
#let doan-pt(p, q, mau: black, day: 1pt, dut: false) = place(
  line(
    start: (p.at(0) * 1pt, p.at(1) * 1pt),
    end: (q.at(0) * 1pt, q.at(1) * 1pt),
    stroke: net(mau, day, dut),
  )
)

// Đa giác tô màu từ toạ độ pt (tự chuẩn hoá về gốc bao).
#let da-giac-pt(pts, to: black, vien: none) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let x0 = calc.min(..xs)
  let y0 = calc.min(..ys)
  place(
    dx: x0 * 1pt, dy: y0 * 1pt,
    polygon(
      fill: to, stroke: vien,
      ..pts.map(p => ((p.at(0) - x0) * 1pt, (p.at(1) - y0) * 1pt)),
    ),
  )
}

// Đầu mũi tên tại b, hướng a->b (toạ độ pt, dùng nội bộ).
#let _dau-pt(a, b, mau: black, kich: 7pt) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let l = calc.sqrt(dx * dx + dy * dy)
  if l < 0.001 { return }
  let k = kich.pt()
  let ux = dx / l
  let uy = dy / l
  let px = -uy
  let py = ux
  da-giac-pt(
    (
      b,
      (b.at(0) - k * ux + 0.38 * k * px, b.at(1) - k * uy + 0.38 * k * py),
      (b.at(0) - 0.72 * k * ux, b.at(1) - 0.72 * k * uy),
      (b.at(0) - k * ux - 0.38 * k * px, b.at(1) - k * uy - 0.38 * k * py),
    ),
    to: mau,
  )
}

// Đầu mũi tên tại B, hướng A->B.
#let dau-mui-ten(ctx, A, B, mau: black, kich: 7pt) = _dau-pt(
  toa-pt(ctx, A), toa-pt(ctx, B), mau: mau, kich: kich,
)

// ---------- Nguyên thuỷ chính ----------
// (định nghĩa `doan` nằm NGAY SAU `nhan` vì có tuỳ chọn nhãn giữa đoạn)

// Hướng VUÔNG GÓC với đoạn AB trên TRANG (vectơ đơn vị dùng cho `nhan`):
// ưu tiên phía trên đoạn; đoạn thẳng đứng thì ra phía trái.
#let _phap-tuyen(ctx, A, B) = {
  let a = toa-pt(ctx, A)
  let b = toa-pt(ctx, B)
  let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
  let l = calc.sqrt(dx * dx + dy * dy)
  if l < 0.0001 { return (0, -1) }
  let n = (-dy / l, dx / l)
  if n.at(1) > 0.000001 { n = (-n.at(0), -n.at(1)) }              // xoay lên trên
  if calc.abs(n.at(1)) <= 0.000001 and n.at(0) > 0 { n = (-1, 0) } // đoạn dọc -> trái
  n
}

// Góc xoay (kiểu angle) để chữ NẰM DỌC THEO đoạn/đường A -> B (toạ độ toán),
// có tính cả tỉ lệ 2 trục sx, sy. Dùng cho nhãn tiệm cận xiên, nhãn dọc theo trục...
//   nhan(ctx, P, $y = x - 1$, quay: goc-truc(ctx, (0, -1), (1, 0)))
//   nhan(ctx, (1, y), $x = 1$, quay: goc-truc(ctx, (1, 0), (1, 1)))  // dọc, đọc từ dưới lên
#let goc-truc(ctx, A, B) = {
  let dx = (B.at(0) - A.at(0)) * ctx.sx.pt()
  let dy = (B.at(1) - A.at(1)) * ctx.sy.pt()
  -calc.atan2(dx, dy)
}

// ---------- Đo nhãn theo BIÊN NÉT CHỮ ----------
// Typst tính HỤT khung của công thức TRONG DÒNG: `measure($1/2$)` chỉ trả về
// chiều cao MỘT DÒNG CHỮ (≈6.8pt ở cỡ 10pt) trong khi phân số vẽ ra cao gấp
// đôi (≈12pt) và tràn cả trên lẫn dưới khung. Nhãn đặt theo khung đó nên bị
// đường vẽ CẮT NGANG (phân số, căn bậc hai, chỉ số trên/dưới…). Đo lại bằng
// top-edge/bottom-edge: "bounds" cho ra đúng biên nét chữ.
// PHẢI gọi trong `context`. Số chữ thường (không tràn) cho kết quả nhỏ hơn
// hoặc bằng khung, nên nơi dùng luôn lấy phần TRÀN = max(0, biên − khung):
// chữ thường bù 0 ⇒ mọi hình cũ giữ nguyên bố cục.
#let co-net(nd) = measure({
  set text(top-edge: "bounds", bottom-edge: "bounds")
  nd
})

// Phần nét chữ tràn ra NGOÀI khung, chia đều hai bên: (dx, dy) tính bằng length.
#let _tran-net(nd) = {
  let k = measure(nd)
  let b = co-net(nd)
  (
    calc.max(0pt, b.width - k.width) / 2,
    calc.max(0pt, b.height - k.height) / 2,
  )
}

// Nhãn văn bản đặt cạnh điểm P.
// huong: "above", "below", "left", "right", "above-left", "above-right",
//        "below-left", "below-right", "center"
// (tên tiếng Việt cũ "tren", "duoi", "trai", "phai", ... vẫn dùng được)
// quay: góc xoay chữ (vd 90deg, -45deg, hoặc goc-truc(...)). Mặc định 0deg.
/// Đặt chữ/công thức tại điểm P. `huong` là phía đặt chữ so với P
/// ("above", "below", "left", "right", "above-left"… hoặc tuple (dx, dy)),
/// `cach` là khoảng cách tới P, `quay` để xoay chữ theo đường.
#let nhan(ctx, P, noi-dung, huong: "above", cach: 6pt, mau: black, quay: 0deg) = {
  let p = toa(ctx, P)
  // huong: tên hướng, HOẶC vectơ (dx, dy) trên trang (y hướng XUỐNG) — dùng
  // cho nhãn đặt vuông góc với một đoạn bất kỳ (xem _phap-tuyen).
  let hd = if type(huong) == array { huong } else {
    (
      above: (0, -1), below: (0, 1), left: (-1, 0), right: (1, 0),
      above-left: (-0.7, -0.7), above-right: (0.7, -0.7),
      below-left: (-0.7, 0.7), below-right: (0.7, 0.7),
      center: (0, 0),
      // bí danh tiếng Việt (tương thích ngược)
      tren: (0, -1), duoi: (0, 1), trai: (-1, 0), phai: (1, 0),
      tren-trai: (-0.7, -0.7), tren-phai: (0.7, -0.7),
      duoi-trai: (-0.7, 0.7), duoi-phai: (0.7, 0.7),
      giua: (0, 0),
    ).at(huong)
  }
  context {
    let nd = text(fill: mau, noi-dung)
    let nd2 = if quay == 0deg { nd } else { rotate(quay, reflow: true, nd) }
    let s = measure(nd2)
    // bù phần nét chữ tràn ra ngoài khung (phân số, căn…) — xem `co-net`
    let (bx, by) = _tran-net(nd2)
    place(
      dx: p.at(0) - s.width / 2 + hd.at(0) * (cach + s.width / 2 + bx),
      dy: p.at(1) - s.height / 2 + hd.at(1) * (cach + s.height / 2 + by),
      nd2,
    )
  }
}

// Đoạn thẳng AB, kèm NHÃN CHÚ THÍCH đặt trên đoạn (tuỳ chọn):
//   ten   : nội dung nhãn (vd $a$, [3 cm]) — none = không ghi
//   tai   : vị trí nhãn theo TỈ LỆ từ A đến B (0 = tại A, 1 = tại B, .5 = giữa)
//   huong : auto = tự đặt VUÔNG GÓC phía trên đoạn (đoạn dọc thì ra trái);
//           hoặc tên hướng ("above", "below", "left", ...), hoặc vectơ (dx, dy)
//   cach  : khoảng cách từ đoạn tới nhãn
//   ten-quay: true = chữ NẰM DỌC theo đoạn (tự xoay, luôn đọc xuôi)
//   mau-ten : màu chữ (auto = theo màu đoạn)
//   Ví dụ: doan(A, B, ten: $2a$)            // giữa đoạn, phía trên
//          doan(A, B, ten: $h$, tai: 0.7, huong: "right", cach: 4pt)
//          doan(A, B, ten: [đường chéo], ten-quay: true)
/// Đoạn thẳng A–B. Kèm nhãn giữa đoạn bằng `ten:` (đặt chỗ khác bằng `tai:`
/// tỉ lệ 0..1, lệch sang bên bằng `huong:`, xoay theo đoạn bằng `ten-quay: true`).
#let doan(
  ctx, A, B,
  mau: black, day: 1pt, dut: false,
  ten: none, tai: 0.5, huong: auto, cach: 6pt, ten-quay: false, mau-ten: auto,
) = {
  place(line(start: toa(ctx, A), end: toa(ctx, B), stroke: net(mau, day, dut)))
  if ten != none {
    let P = (A.at(0) + tai * (B.at(0) - A.at(0)), A.at(1) + tai * (B.at(1) - A.at(1)))
    // chữ dọc theo đoạn: chọn chiều A->B hay B->A để không bị lộn ngược
    let xuoi = toa-pt(ctx, A).at(0) <= toa-pt(ctx, B).at(0)
    nhan(
      ctx, P, ten,
      huong: if huong == auto { _phap-tuyen(ctx, A, B) } else { huong },
      cach: cach,
      mau: if mau-ten == auto { mau } else { mau-ten },
      quay: if ten-quay { if xuoi { goc-truc(ctx, A, B) } else { goc-truc(ctx, B, A) } } else { 0deg },
    )
  }
}

// Điểm (chấm tròn) + nhãn tuỳ chọn.
// cach: khoảng cách nhãn tới điểm · mau-ten: màu chữ (auto = màu chấm).
/// Chấm một điểm, kèm tên: `diem(A, ten: $A$, huong: "below-left")`.
/// Nhiều điểm một lệnh thì dùng `cac-diem`.
#let diem(ctx, P, ten: none, huong: "tren", bk: 2pt, mau: black, cach: 6pt, mau-ten: black) = {
  let p = toa(ctx, P)
  place(dx: p.at(0) - bk, dy: p.at(1) - bk, circle(radius: bk, fill: mau, stroke: none))
  if ten != none {
    nhan(ctx, P, ten, huong: huong, cach: cach, mau: if mau-ten == auto { mau } else { mau-ten })
  }
}

// Đặt nhãn cho nhiều điểm, VỊ TRÍ nhãn xác định bằng GÓC LƯỢNG GIÁC (thay cho
// tên hướng "above"/"below"…). Mỗi mục là một tuple:
//   (P, nội-dung, goc)                — bán kính & màu lấy mặc định
//   (P, nội-dung, goc, ban-kinh)      — ban-kinh là ĐỘ DÀI trang (vd 8pt)
//   (P, nội-dung, goc, ban-kinh, mau) — kèm màu riêng
// `goc` là góc lượng giác (số trần = ĐỘ, dương = ngược kim đồng hồ; nhãn đặt
// về phía góc đó so với điểm). Phần tử sau `goc` nhận diện theo kiểu: color ->
// màu, còn lại -> bán kính, nên thứ tự ban-kinh/mau linh hoạt.
//   nhan-goc((A, $A$, 210), (B, $B$, -30, 9pt), (C, $C$, 90, 8pt, red))
/// Đặt nhãn nhiều điểm theo GÓC LƯỢNG GIÁC. Mỗi mục:
/// `(P, nội-dung, goc[, ban-kinh][, mau])` — `goc` số trần = độ, dương ngược
/// kim đồng hồ; `ban-kinh` là độ dài trang (khoảng cách điểm→nhãn).
#let nhan-goc(ctx, ..muc, mau: black, ban-kinh: 6pt) = {
  for m in muc.pos() {
    let P = m.at(0)
    let nd = m.at(1)
    let goc = m.at(2)
    let r = ban-kinh
    let c = mau
    for x in m.slice(3) {
      if type(x) == color { c = x } else { r = x }
    }
    let g = if type(goc) == angle { goc } else { goc * 1deg }
    // hướng trên TRANG (y hướng XUỐNG) theo góc lượng giác (y toán hướng lên)
    let hd = (calc.cos(g), -calc.sin(g))
    nhan(ctx, P, nd, huong: hd, cach: r, mau: c)
  }
}

// Mũi tên A -> B.
#let mui-ten(ctx, A, B, mau: black, day: 1pt, kich: 7pt, dut: false) = {
  doan(ctx, A, B, mau: mau, day: day, dut: dut)
  dau-mui-ten(ctx, A, B, mau: mau, kich: kich)
}

// Vectơ A -> B kèm tên đặt ở trung điểm.
// dut: true = thân nét đứt (vectơ nằm trên cạnh khuất, kiểu hình SGK);
// đầu mũi tên luôn nét liền.
#let vecto(ctx, A, B, ten: none, huong: "tren", mau: black, day: 1.1pt, dut: false) = {
  mui-ten(ctx, A, B, mau: mau, day: day, dut: dut)
  if ten != none {
    nhan(ctx, ((A.at(0) + B.at(0)) / 2, (A.at(1) + B.at(1)) / 2), ten, huong: huong, mau: mau)
  }
}

// ---------- Mũi tên HAI ĐẦU (đường ghi số đo) ----------
// Mũi tên có đầu ở CẢ HAI phía, kiểu đường ghi kích thước trong bản vẽ:
// thường dùng để chú thích số đo đặt Ở GIỮA đoạn mũi tên.
//   ten      : nội dung chú thích (vd $2a$, [5 cm]) — none = chỉ vẽ mũi tên
//   trong    : chữ nằm CHÍNH GIỮA thân, thân bị cắt chừa chỗ (|<-- 5 cm -->|)
//              auto = tự bật khi có `ten` và đoạn đủ dài để chứa chữ,
//              không đủ dài thì tự đặt chữ ra ngoài (phía trên đoạn)
//   huong    : chỗ đặt chữ khi KHÔNG nằm giữa thân
//              (auto = vuông góc phía trên đoạn, như `doan`)
//   ten-quay : true = chữ NẰM DỌC theo mũi tên (luôn đọc xuôi)
//   vach     : true = kẻ vạch chặn vuông góc ở hai đầu (kiểu ghi kích thước)
//   le       : lùi hai đầu mũi tên vào trong, để hở khỏi vật đang đo
//   nen      : màu nền lót sau chữ khi chữ nằm giữa thân (none = không lót)
// Ví dụ:
//   mui-ten-2-dau(A, B, ten: [5 cm])                    // chữ giữa thân
//   mui-ten-2-dau(A, B, ten: $2a$, trong: false)        // chữ trên đoạn
//   mui-ten-2-dau((0, -0.4), (4, -0.4), ten: $h$, vach: true)
/// Mũi tên HAI ĐẦU giữa A và B, kiểu đường ghi kích thước. `ten:` là số đo
/// đặt GIỮA thân (`trong: false` để đưa chữ ra ngoài), `vach: true` kẻ vạch
/// chặn hai đầu, `le:` lùi hai đầu vào trong cho hở khỏi vật đang đo.
#let mui-ten-2-dau(
  ctx, A, B,
  mau: black, day: 1pt, kich: 7pt, dut: false,
  ten: none, huong: auto, cach: 5pt, ten-quay: false, mau-ten: auto,
  trong: auto, dem: 3pt, nen: white,
  vach: false, dai-vach: 9pt,
  le: 0pt,
) = context {
  let a0 = toa-pt(ctx, A)
  let b0 = toa-pt(ctx, B)
  let (dx, dy) = (b0.at(0) - a0.at(0), b0.at(1) - a0.at(1))
  let l0 = calc.sqrt(dx * dx + dy * dy)
  if l0 < 0.001 { return }
  let (ux, uy) = (dx / l0, dy / l0)
  let lp = calc.min(le.pt(), l0 / 2 - 0.5)
  let a = (a0.at(0) + lp * ux, a0.at(1) + lp * uy)
  let b = (b0.at(0) - lp * ux, b0.at(1) - lp * uy)
  let l = l0 - 2 * lp
  let mc = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  let mt = ((A.at(0) + B.at(0)) / 2, (A.at(1) + B.at(1)) / 2)
  let mau-t = if mau-ten == auto { mau } else { mau-ten }

  // Kích thước chữ (đo cả biên nét để phân số/căn không bị thân mũi tên cắt).
  let nd = if ten == none { none } else {
    let n = text(fill: mau-t, ten)
    let q = if ten-quay {
      let g = if a.at(0) <= b.at(0) { goc-truc(ctx, A, B) } else { goc-truc(ctx, B, A) }
      rotate(g, reflow: true, n)
    } else { n }
    q
  }
  let (kw, kh, bw, bh) = if nd == none { (0pt, 0pt, 0pt, 0pt) } else {
    let k = measure(nd)
    let bn = co-net(nd)
    (k.width, k.height, calc.max(k.width, bn.width), calc.max(k.height, bn.height))
  }
  // Bề ngang chỗ chữ chiếm DỌC THEO thân mũi tên + hai đầu mũi tên phải đủ chỗ.
  let ho = bw.pt() * calc.abs(ux) + bh.pt() * calc.abs(uy) + 2 * dem.pt()
  let o-giua = (
    ten != none
      and (if trong == auto { l > ho + 3.2 * kich.pt() } else { trong })
  )

  // Thân: cắt đôi chừa chỗ cho chữ nếu chữ nằm giữa
  if o-giua {
    let h2 = calc.min(ho / 2, l / 2 - 0.2)
    doan-pt(a, (mc.at(0) - h2 * ux, mc.at(1) - h2 * uy), mau: mau, day: day, dut: dut)
    doan-pt((mc.at(0) + h2 * ux, mc.at(1) + h2 * uy), b, mau: mau, day: day, dut: dut)
  } else {
    doan-pt(a, b, mau: mau, day: day, dut: dut)
  }
  _dau-pt(b, a, mau: mau, kich: kich)
  _dau-pt(a, b, mau: mau, kich: kich)

  // Vạch chặn hai đầu (kiểu đường ghi kích thước)
  if vach {
    let hv = dai-vach.pt() / 2
    let (px, py) = (-uy, ux)
    for q in (a0, b0) {
      doan-pt(
        (q.at(0) - hv * px, q.at(1) - hv * py),
        (q.at(0) + hv * px, q.at(1) + hv * py),
        mau: mau, day: day,
      )
    }
  }

  // Chú thích
  if ten != none {
    if o-giua {
      if nen != none {
        place(
          dx: (mc.at(0) - bw.pt() / 2 - dem.pt() / 2) * 1pt,
          dy: (mc.at(1) - bh.pt() / 2) * 1pt,
          rect(width: bw + dem, height: bh, fill: nen, stroke: none),
        )
      }
      place(dx: (mc.at(0) - kw.pt() / 2) * 1pt, dy: (mc.at(1) - kh.pt() / 2) * 1pt, nd)
    } else {
      nhan(
        ctx, mt, ten,
        huong: if huong == auto { _phap-tuyen(ctx, A, B) } else { huong },
        cach: cach, mau: mau-t,
        quay: if ten-quay {
          if a.at(0) <= b.at(0) { goc-truc(ctx, A, B) } else { goc-truc(ctx, B, A) }
        } else { 0deg },
      )
    }
  }
}

// Đường gấp khúc qua dãy điểm. dut: nét đứt (vẽ cách đoạn -> đều trên đường cong).
#let duong-cong(ctx, cac-diem, mau: black, day: 1pt, dut: false, dong: false) = {
  let pts = cac-diem
  if dong and pts.len() > 1 { pts = pts + (pts.at(0),) }
  for i in range(pts.len() - 1) {
    if not dut or calc.rem(i, 2) == 0 {
      doan(ctx, pts.at(i), pts.at(i + 1), mau: mau, day: day)
    }
  }
}

// Đường gấp khúc nối lần lượt A - B - C - ... KHÁC duong-cong ở chỗ:
// dut: true là nét đứt THẬT trên TỪNG đoạn (hợp polyline ít đoạn;
// duong-cong đứt kiểu "bỏ đoạn xen kẽ" chỉ hợp đường nhiều mẫu).
// dong: true nối điểm cuối về điểm đầu.
#let duong-gap-khuc(ctx, cac-diem, mau: black, day: 1pt, dut: false, dong: false) = {
  let pts = cac-diem
  if dong and pts.len() > 1 { pts = pts + (pts.at(0),) }
  for i in range(pts.len() - 1) {
    doan(ctx, pts.at(i), pts.at(i + 1), mau: mau, day: day, dut: dut)
  }
}

// Đa giác kín: viền + tô màu tuỳ chọn (to: màu hoặc none).
/// Đa giác khép kín. Đỉnh truyền vào dưới dạng MỘT MẢNG:
/// `da-giac((A, B, C))` — không phải `da-giac(A, B, C)`. `to:` để tô màu.
#let da-giac(ctx, cac-diem, mau: black, day: 1pt, dut: false, to: none) = {
  if to != none {
    da-giac-pt(cac-diem.map(P => toa-pt(ctx, P)), to: to)
  }
  duong-cong(ctx, cac-diem, mau: mau, day: day, dut: dut, dong: true)
}

// ---------- cac-doan: VẼ NHIỀU NÉT TRONG MỘT LỆNH (kiểu \draw của TikZ) ----
// Đối số vị trí có thể trộn thoải mái:
//   • các ĐIỂM liền nhau -> nối thành MỘT đường gấp khúc:
//       cac-doan(A, B)              // một đoạn
//       cac-doan(A, B, C, D)        // A-B-C-D
//   • một MẢNG ĐIỂM -> một nét riêng:
//       cac-doan((A, B), (C, D))    // hai đoạn rời
//   • duong(...) -> một nét riêng CÓ KIỂU RIÊNG (đè lên kiểu chung):
//       cac-doan(
//         duong(A, B, C, dong: true, to: blue.lighten(85%)),  // tam giác tô
//         duong(S, H, dut: true, ten: $h$),                   // nét đứt có nhãn
//         (M, N),                                            // đoạn thường
//         mau: blue, day: 1.2pt,                             // kiểu CHUNG
//       )
// Tuỳ chọn mỗi nét (đặt ở duong(...) hoặc dùng chung ở cac-doan):
//   mau · day · dut · dong (khép kín) · to (tô màu, tự khép kín)
//   mui-ten (vẽ đầu mũi tên ở điểm cuối) · ten/tai/huong/cach/ten-quay/mau-ten
//   (nhãn đặt tại tỉ lệ `tai` tính theo TỔNG chiều dài nét — xem `doan`)
#let duong(
  ..noi-dung,
  mau: auto, day: auto, dut: auto, dong: auto, to: auto, mui-ten: auto,
  ten: auto, tai: auto, huong: auto, cach: auto, ten-quay: auto, mau-ten: auto,
) = {
  let p = noi-dung.pos()
  // duong((A, B, C)) — truyền nguyên một mảng điểm
  if (p.len() == 1 and type(p.at(0)) == array and p.at(0).len() > 0
      and type(p.at(0).at(0)) == array) { p = p.at(0) }
  (
    bg-duong: true, diem: p,
    mau: mau, day: day, dut: dut, dong: dong, to: to, mui-ten: mui-ten,
    ten: ten, tai: tai, huong: huong, cach: cach, ten-quay: ten-quay, mau-ten: mau-ten,
  )
}

#let _la-duong(x) = type(x) == dictionary and x.at("bg-duong", default: false)
#let _la-diem(x) = type(x) == array and x.len() == 2 and type(x.at(0)) != array

/// Vẽ NHIỀU nét trong một lệnh: điểm liền nhau thành một đường gấp khúc,
/// mỗi MẢNG điểm là một nét riêng — `cac-doan((A, B), (C, D), (M, N))`.
/// Nét cần kiểu riêng thì bọc `duong(...)`.
#let cac-doan(
  ctx, ..noi-dung,
  mau: black, day: 1pt, dut: false, dong: false, to: none, mui-ten: false,
  ten: none, tai: 0.5, huong: auto, cach: 6pt, ten-quay: false, mau-ten: auto,
) = {
  // gom đối số vị trí thành danh sách các nét
  let nets = ()
  let dem = ()
  for x in noi-dung.pos() {
    if _la-diem(x) { dem.push(x) } else {
      if dem.len() > 0 { nets.push(duong(..dem)); dem = () }
      if _la-duong(x) { nets.push(x) } else if type(x) == array { nets.push(duong(x)) }
    }
  }
  if dem.len() > 0 { nets.push(duong(..dem)) }
  // vẽ từng nét: giá trị auto của nét lấy theo tuỳ chọn chung
  for n in nets {
    let ly(khoa, chung) = if n.at(khoa) == auto { chung } else { n.at(khoa) }
    let (m, d, du) = (ly("mau", mau), ly("day", day), ly("dut", dut))
    let (dg, tt) = (ly("dong", dong), ly("to", to))
    let pts = n.diem
    if pts.len() == 0 { continue }
    if pts.len() == 1 { diem(ctx, pts.at(0), mau: m); continue }
    if tt != none { da-giac-pt(pts.map(P => toa-pt(ctx, P)), to: tt) }
    let cd = if dg or tt != none { pts + (pts.at(0),) } else { pts }
    for i in range(cd.len() - 1) {
      doan(ctx, cd.at(i), cd.at(i + 1), mau: m, day: d, dut: du)
    }
    if ly("mui-ten", mui-ten) {
      dau-mui-ten(ctx, cd.at(cd.len() - 2), cd.at(cd.len() - 1), mau: m)
    }
    // nhãn: đặt tại tỉ lệ `tai` tính theo TỔNG chiều dài nét (trên trang)
    let nh = ly("ten", ten)
    if nh != none {
      let t = ly("tai", tai)
      let dai = range(cd.len() - 1).map(i => {
        let a = toa-pt(ctx, cd.at(i))
        let b = toa-pt(ctx, cd.at(i + 1))
        calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2))
      })
      let tong = dai.sum()
      let moc = calc.max(calc.min(t, 1), 0) * tong
      let i = 0
      let con = moc
      while i < dai.len() - 1 and con > dai.at(i) { con = con - dai.at(i); i = i + 1 }
      let ti = if dai.at(i) > 0.0001 { con / dai.at(i) } else { 0.5 }
      let (U, V) = (cd.at(i), cd.at(i + 1))
      let P = (U.at(0) + ti * (V.at(0) - U.at(0)), U.at(1) + ti * (V.at(1) - U.at(1)))
      let hg = ly("huong", huong)
      let mt = ly("mau-ten", mau-ten)
      let xuoi = toa-pt(ctx, U).at(0) <= toa-pt(ctx, V).at(0)
      nhan(
        ctx, P, nh,
        huong: if hg == auto { _phap-tuyen(ctx, U, V) } else { hg },
        cach: ly("cach", cach),
        mau: if mt == auto { m } else { mt },
        quay: if ly("ten-quay", ten-quay) {
          if xuoi { goc-truc(ctx, U, V) } else { goc-truc(ctx, V, U) }
        } else { 0deg },
      )
    }
  }
}

// ---------- cac-diem: CHẤM + ĐẶT TÊN NHIỀU ĐIỂM TRONG MỘT LỆNH ----------
// Mỗi đối số vị trí là một điểm, viết theo 1 trong 4 dạng:
//   A                      -> chỉ chấm, không nhãn
//   (A, $A$)               -> chấm + nhãn, hướng lấy theo `huong` chung
//   (A, $A$, "left")       -> + hướng riêng
//   (A, $A$, "left", red)  -> + màu riêng (cả chấm lẫn chữ nếu mau-ten: auto)
// Tuỳ chọn chung: mau · bk (bán kính chấm) · huong · cach (nhãn cách chấm)
//   · mau-ten (auto = theo màu chấm).
//   cac-diem(
//     (A, $A$, "below-left"), (B, $B$, "below-right"), (C, $C$, "above"),
//     mau: blue, bk: 2.2pt,
//   )
/// Chấm + đặt tên nhiều điểm một lệnh. Mỗi mục: `A` | `(A, $A$)` |
/// `(A, $A$, "left")` | `(A, $A$, "left", red)`.
#let cac-diem(
  ctx, ..noi-dung,
  mau: black, bk: 2pt, huong: "above", cach: 6pt, mau-ten: black,
) = {
  for x in noi-dung.pos() {
    let la-diem = type(x) == array and x.len() == 2 and type(x.at(0)) != array
    let P = if la-diem { x } else { x.at(0) }
    let t = if la-diem { none } else { x.at(1, default: none) }
    let h = if la-diem { auto } else { x.at(2, default: auto) }
    let m = if la-diem { auto } else { x.at(3, default: auto) }
    let mc = if m == auto { mau } else { m }
    diem(
      ctx, P, ten: t,
      huong: if h == auto { huong } else { h },
      bk: bk, mau: mc, cach: cach,
      mau-ten: if mau-ten == auto or m != auto { mc } else { mau-ten },
    )
  }
}

// Dãy điểm trên cung elip tâm O bán trục (a, b), góc tu -> den.
#let diem-cung(O, a, b, tu, den, n: 48) = range(n + 1).map(i => {
  let t = tu + (den - tu) * (i / n)
  (O.at(0) + a * calc.cos(t), O.at(1) + b * calc.sin(t))
})

// Đường tròn tâm O bán kính r (theo đơn vị trục x; nếu 2 trục cùng tỉ lệ
// thì là đường tròn thật, khác tỉ lệ sẽ thành elip tương ứng).
#let duong-tron(ctx, O, r, mau: black, day: 1pt, dut: false, to: none) = {
  let c = toa(ctx, O)
  let rx = r * ctx.sx
  let ry = r * ctx.sy
  place(
    dx: c.at(0) - rx, dy: c.at(1) - ry,
    ellipse(width: 2 * rx, height: 2 * ry, stroke: net(mau, day, dut), fill: to),
  )
}

// Elip tâm O, bán trục a (ngang), b (dọc); quay: góc xoay quanh tâm
// (dương = ngược chiều kim đồng hồ), n: số mẫu khi vẽ elip xoay.
#let elip(ctx, O, a, b, mau: black, day: 1pt, dut: false, to: none, quay: 0deg, n: 72) = {
  if quay == 0deg and not ("bien-doi" in ctx and ctx.bien-doi != none) {
    let c = toa(ctx, O)
    let rx = a * ctx.sx
    let ry = b * ctx.sy
    place(
      dx: c.at(0) - rx, dy: c.at(1) - ry,
      ellipse(width: 2 * rx, height: 2 * ry, stroke: net(mau, day, dut), fill: to),
    )
  } else {
    // elip xoay (hoặc ctx có phép biến hình): vẽ theo dãy điểm quanh chu vi
    let pts = diem-cung(O, a, b, 0deg, 360deg, n: n).map(P => quay-diem(P, O, quay))
    if to != none { da-giac-pt(pts.map(P => toa-pt(ctx, P)), to: to) }
    duong-cong(ctx, pts, mau: mau, day: day, dut: dut, dong: true)
  }
}

// Cung tròn tâm O bán kính r từ góc `tu` đến `den` (kiểu angle, vd 30deg).
#let cung(ctx, O, r, tu: 0deg, den: 180deg, mau: black, day: 1pt, dut: false, n: 48, quay: 0deg) = {
  duong-cong(ctx, diem-cung(O, r, r, tu + quay, den + quay, n: n), mau: mau, day: day, dut: dut)
}

// Cung elip (dùng cho hình không gian: đáy nón, trụ...).
#let cung-elip(ctx, O, a, b, tu: 0deg, den: 180deg, mau: black, day: 1pt, dut: false, n: 48, quay: 0deg) = {
  let pts = diem-cung(O, a, b, tu, den, n: n)
  if quay != 0deg { pts = pts.map(P => quay-diem(P, O, quay)) }
  duong-cong(ctx, pts, mau: mau, day: day, dut: dut)
}

// ---------- Đường xoắn ốc ----------
// Xoắn ốc Archimedes tâm O: bán kính TĂNG ĐỀU theo góc, quét từ `tu` đến `den`.
// Góc quét |den - tu| ĐƯỢC PHÉP lớn hơn 360° (nhiều vòng);
// den > tu = ngược chiều kim đồng hồ (chiều dương), den < tu = cùng chiều kim đồng hồ.
//   r       : bán kính tại góc `tu`
//   r-cuoi  : bán kính tại góc `den` (auto = r + buoc · số vòng quét)
//   buoc    : khoảng cách giữa hai vòng liên tiếp (dùng khi r-cuoi: auto)
//   mui-ten : true|"cuoi" (đầu mũi tên ở điểm cuối) · "dau" · "ca-hai" · false
//   ten/huong/cach/mau-ten : nhãn đặt cạnh điểm cuối của xoắn ốc
#let xoan-oc(
  ctx, O,
  tu: 0deg, den: 360deg,
  r: 0.12, r-cuoi: auto, buoc: 0.16,
  mau: black, day: 1pt, dut: false,
  mui-ten: true, kich: 7pt,
  n: auto,
  ten: none, huong: "above", cach: 6pt, mau-ten: auto,
) = {
  let quet = den - tu
  let so-vong = calc.abs(quet.deg()) / 360
  let r2 = if r-cuoi == auto { r + buoc * so-vong } else { r-cuoi }
  let m = if n == auto { calc.max(32, int(calc.ceil(so-vong * 72))) } else { n }
  let pts = range(m + 1).map(i => {
    let s = i / m
    let a = tu + quet * s
    let rr = r + (r2 - r) * s
    (O.at(0) + rr * calc.cos(a), O.at(1) + rr * calc.sin(a))
  })
  duong-cong(ctx, pts, mau: mau, day: day, dut: dut)
  if mui-ten == true or mui-ten == "cuoi" or mui-ten == "ca-hai" {
    dau-mui-ten(ctx, pts.at(m - 1), pts.at(m), mau: mau, kich: kich)
  }
  if mui-ten == "dau" or mui-ten == "ca-hai" {
    dau-mui-ten(ctx, pts.at(1), pts.at(0), mau: mau, kich: kich)
  }
  if ten != none {
    nhan(
      ctx, pts.at(m), ten,
      huong: huong, cach: cach,
      mau: if mau-ten == auto { mau } else { mau-ten },
    )
  }
}

// Góc lượng giác (OA, OM): xoắn ốc từ tia OA quay tới tia OM (kiểu SGK 11).
//   chieu : "duong" = ngược chiều kim đồng hồ (mặc định) · "am" = cùng chiều
//   vong  : số vòng quay THÊM (0, 1, 2, ...) trước khi dừng ở tia OM
//   so-do : true = tự ghi số đo (vd -430°) cạnh mũi tên; `ten` được ưu tiên
// Ví dụ hình "AOM = 70°, (OA, OM) = -430°": goc-luong-giac(O, A, M, chieu: "am", vong: 1)
#let goc-luong-giac(
  ctx, O, A, M,
  chieu: "duong", vong: 0,
  r: auto, r-cuoi: auto, buoc: auto,
  mau: blue, day: 0.9pt, dut: false, kich: 6pt,
  ten: none, so-do: false, huong: "above", cach: 6pt, mau-ten: auto,
  n: auto,
) = {
  let am = chieu in ("am", "-", -1) or chieu == false
  // r, buoc mặc định tính THEO chiều dài tia (để hình nào cũng cân đối)
  let dai = calc.min(
    calc.sqrt(calc.pow(A.at(0) - O.at(0), 2) + calc.pow(A.at(1) - O.at(1), 2)),
    calc.sqrt(calc.pow(M.at(0) - O.at(0), 2) + calc.pow(M.at(1) - O.at(1), 2)),
  )
  if dai <= 0 { dai = 1 }
  let r = if r == auto { 0.12 * dai } else { r }
  let buoc = if buoc == auto { 0.14 * dai } else { buoc }
  let a1 = calc.atan2(A.at(0) - O.at(0), A.at(1) - O.at(1))
  let a2 = calc.atan2(M.at(0) - O.at(0), M.at(1) - O.at(1))
  let d = a2 - a1
  while d < 0deg { d = d + 360deg }
  while d >= 360deg { d = d - 360deg }
  if am and d != 0deg { d = d - 360deg }
  let tong = d + (if am { -1 } else { 1 }) * vong * 360deg
  let nd = if ten != none { ten } else if so-do {
    let v = calc.round(tong.deg(), digits: 1)
    let s = if calc.abs(v - calc.round(v)) < 0.01 { str(int(calc.round(v))) } else { str(v) }
    [#s#sym.degree]
  } else { none }
  xoan-oc(
    ctx, O, tu: a1, den: a1 + tong,
    r: r, r-cuoi: r-cuoi, buoc: buoc,
    mau: mau, day: day, dut: dut, kich: kich, n: n,
    ten: nd, huong: huong, cach: cach, mau-ten: mau-ten,
  )
}

// ---------- Đường cong uốn lượn (Bézier kiểu \draw ... controls ... của TikZ) ----------
// `dieu-khien(c1, c2)` — điểm điều khiển của MỘT đoạn cong, đặt XEN GIỮA hai
// điểm neo (giống `.. controls (c1) and (c2) ..` của TikZ):
//   duong-luon(A, dieu-khien(c1, c2), B, dieu-khien(c3, c4), C)
//   dieu-khien(c1)        // một điểm điều khiển (c2 = c1)
//   dieu-khien(c1, auto)  // c1 tự chọn cho mềm, c2 do người dùng đặt (auto lấy Catmull-Rom)
// Đoạn KHÔNG có dieu-khien giữa hai neo -> tự làm MỀM bằng Catmull-Rom
// (đường trơn đi qua đúng các điểm neo, khỏi tính điểm điều khiển bằng tay).
#let dieu-khien(..a) = {
  let p = a.pos()
  let c1 = p.at(0, default: auto)
  let c2 = p.at(1, default: c1)
  (bg-dk: true, c1: c1, c2: c2)
}
#let _la-dk(x) = type(x) == dictionary and x.at("bg-dk", default: false)

// Lấy MẢNG điểm mẫu của đường uốn lượn (dùng chung cho vẽ và cho nhãn bám đường).
// items: dãy đối số vị trí (điểm neo trộn với dieu-khien(...)); n: mẫu mỗi đoạn.
#let _luon-mau(items, n, dong) = {
  let anchors = ()
  let ctrls = ()          // ctrls.at(k) = dieu-khien của đoạn anchors[k] -> anchors[k+1]
  let pending = none
  for x in items {
    if _la-dk(x) { pending = x }
    else if _la-diem(x) {
      if anchors.len() > 0 { ctrls.push(pending); pending = none }
      anchors.push(x)
    }
  }
  if anchors.len() < 2 { return anchors }
  if dong {
    ctrls.push(pending)              // điều khiển của đoạn khép kín (cuối -> đầu)
    anchors.push(anchors.at(0))
  }
  let m = anchors.len()
  let getc = i => anchors.at(calc.max(0, calc.min(m - 1, i)))
  let getw = i => {
    if dong {
      let base = m - 1
      anchors.at(calc.rem(calc.rem(i, base) + base, base))
    } else { getc(i) }
  }
  let pts = (anchors.at(0),)
  for k in range(m - 1) {
    let p1 = anchors.at(k)
    let p2 = anchors.at(k + 1)
    let p0 = getw(k - 1)
    let p3 = getw(k + 2)
    // điểm điều khiển Catmull-Rom (đường trơn qua các neo)
    let ec1 = (p1.at(0) + (p2.at(0) - p0.at(0)) / 6, p1.at(1) + (p2.at(1) - p0.at(1)) / 6)
    let ec2 = (p2.at(0) - (p3.at(0) - p1.at(0)) / 6, p2.at(1) - (p3.at(1) - p1.at(1)) / 6)
    let dk = ctrls.at(k, default: none)
    let c1 = if dk == none or dk.c1 == auto { ec1 } else { dk.c1 }
    let c2 = if dk == none or dk.c2 == auto { ec2 } else { dk.c2 }
    for j in range(1, n + 1) {
      let t = j / n
      let u = 1 - t
      let x = u * u * u * p1.at(0) + 3 * u * u * t * c1.at(0) + 3 * u * t * t * c2.at(0) + t * t * t * p2.at(0)
      let y = u * u * u * p1.at(1) + 3 * u * u * t * c1.at(1) + 3 * u * t * t * c2.at(1) + t * t * t * p2.at(1)
      pts.push((x, y))
    }
  }
  pts
}

// TRẢ VỀ mảng điểm mẫu của đường uốn lượn (dùng cho nhan-cong hoặc để vẽ lại).
// KHÔNG cần ctx (chỉ tính trên toạ độ toán).
#let diem-luon(..noi-dung, n: 16, dong: false) = _luon-mau(noi-dung.pos(), n, dong)

// Vẽ đường cong uốn lượn qua các điểm neo, điểm điều khiển kiểu `controls` TikZ.
//   duong-luon(A, B, C, D)                          // trơn tự động qua 4 neo
//   duong-luon(A, dieu-khien(c1, c2), B)            // Bézier bậc ba một đoạn
//   duong-luon(A, dieu-khien(c1,c2), B, C, dong: true, to: blue.lighten(85%))
// Tuỳ chọn: mau · day · dut · dong (khép kín) · to (tô) · mui-ten · kich ·
//   ten/tai/huong/cach/ten-quay/mau-ten (nhãn đặt theo TỈ LỆ độ dài, như cac-doan) ·
//   n (số mẫu mỗi đoạn, tăng cho mượt).
#let duong-luon(
  ctx, ..noi-dung,
  mau: black, day: 1pt, dut: false, dong: false, to: none,
  mui-ten: false, kich: 7pt,
  ten: none, tai: 0.5, huong: auto, cach: 6pt, ten-quay: false, mau-ten: auto,
  n: 16,
) = {
  let pts = _luon-mau(noi-dung.pos(), n, dong)
  if pts.len() < 2 { return }
  if to != none { da-giac-pt(pts.map(P => toa-pt(ctx, P)), to: to) }
  duong-cong(ctx, pts, mau: mau, day: day, dut: dut)
  if mui-ten {
    dau-mui-ten(ctx, pts.at(pts.len() - 2), pts.at(pts.len() - 1), mau: mau, kich: kich)
  }
  if ten != none {
    let pg = pts.map(P => toa-pt(ctx, P))
    let dai = range(pg.len() - 1).map(i => {
      let a = pg.at(i)
      let b = pg.at(i + 1)
      calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2))
    })
    let tong = dai.sum()
    let moc = calc.max(calc.min(tai, 1), 0) * tong
    let i = 0
    let con = moc
    while i < dai.len() - 1 and con > dai.at(i) { con = con - dai.at(i); i = i + 1 }
    let ti = if dai.at(i) > 0.0001 { con / dai.at(i) } else { 0.5 }
    let U = pts.at(i)
    let V = pts.at(i + 1)
    let P = (U.at(0) + ti * (V.at(0) - U.at(0)), U.at(1) + ti * (V.at(1) - U.at(1)))
    let xuoi = toa-pt(ctx, U).at(0) <= toa-pt(ctx, V).at(0)
    nhan(
      ctx, P, ten,
      huong: if huong == auto { _phap-tuyen(ctx, U, V) } else { huong },
      cach: cach,
      mau: if mau-ten == auto { mau } else { mau-ten },
      quay: if ten-quay { if xuoi { goc-truc(ctx, U, V) } else { goc-truc(ctx, V, U) } } else { 0deg },
    )
  }
}

// ---------- Nhãn chữ BÁM THEO đường cong ----------
// Chuỗi văn bản từ nội dung (str hoặc content đơn giản).
#let _chuoi-cong(c) = {
  if type(c) == str { c }
  else if type(c) == content {
    if c.has("text") { c.text }
    else if c.has("children") { c.children.map(_chuoi-cong).fold("", (a, b) => a + b) }
    else if c.has("body") { _chuoi-cong(c.body) }
    else { "" }
  } else { str(c) }
}

// Đặt từng ký tự của `chu` DỌC THEO đường `duong` (mảng điểm toạ độ toán, vd
// lấy từ diem-luon / diem-cung / lay-mau), tự xoay tiếp tuyến, canh theo độ dài cung.
//   duong: mảng điểm (>= 2). chu: str (khuyên dùng) hoặc content văn bản thuần.
//   tu    : vị trí BẮT ĐẦU theo tỉ lệ độ dài đường (0 = đầu, 1 = cuối, .5 = giữa)
//   can   : "trai" (bắt đầu tại `tu`) · "giua" (canh giữa chữ quanh `tu`) · "phai"
//   khoang: giãn cách thêm giữa các ký tự (length)
//   co    : cỡ chữ (auto = theo cỡ hiện hành) · mau : màu chữ
//   phia  : "tren" (chữ nằm TRÊN đường) · "duoi" · "giua" (tâm chữ trên đường)
//   cach  : khoảng hở giữa chữ và đường (khi phia = tren/duoi)
//   dao   : true = đi ngược đường (khi đường vẽ từ phải sang trái, chữ khỏi lộn ngược)
//   Ví dụ: nhan-cong(diem-cung((0,0), 2, 2, 20deg, 160deg), "cung tron")
#let nhan-cong(
  ctx, duong, chu,
  tu: 0, can: "trai", khoang: 0pt,
  co: auto, mau: black, phia: "tren", cach: 2pt, dao: false,
) = {
  let pts = if dao { duong.rev() } else { duong }
  let txt = _chuoi-cong(chu)
  let cl = txt.clusters()
  if pts.len() < 2 or cl.len() == 0 { return }
  let pg = pts.map(P => toa-pt(ctx, P))
  let cum = (0.0,)
  for i in range(pg.len() - 1) {
    let a = pg.at(i)
    let b = pg.at(i + 1)
    cum.push(cum.at(i) + calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2)))
  }
  let tong = cum.at(cum.len() - 1)
  context {
    let els = cl.map(g => if co == auto { text(fill: mau, g) } else { text(size: co, fill: mau, g) })
    let ws = els.map(e => measure(e).width.pt())
    let totw = ws.sum() + khoang.pt() * calc.max(0, els.len() - 1)
    let s0 = tu * tong
    if can == "giua" { s0 = s0 - totw / 2 } else if can == "phai" { s0 = s0 - totw }
    let cursor = s0
    for idx in range(els.len()) {
      let w = ws.at(idx)
      let mid = calc.max(0, calc.min(tong, cursor + w / 2))
      let i = 0
      while i < cum.len() - 2 and cum.at(i + 1) < mid { i = i + 1 }
      let seg = cum.at(i + 1) - cum.at(i)
      let t = if seg > 0.000001 { (mid - cum.at(i)) / seg } else { 0 }
      let A = pg.at(i)
      let B = pg.at(i + 1)
      let px = A.at(0) + t * (B.at(0) - A.at(0))
      let py = A.at(1) + t * (B.at(1) - A.at(1))
      let dx = B.at(0) - A.at(0)
      let dy = B.at(1) - A.at(1)
      let ll = calc.sqrt(dx * dx + dy * dy)
      let (ux, uy) = if ll > 0.000001 { (dx / ll, dy / ll) } else { (1, 0) }
      let ang = calc.atan2(dx, dy)          // góc của vectơ (dx, dy) trên TRANG (y xuống)
      let el = els.at(idx)
      let hh = measure(el).height.pt()
      let off = if phia == "tren" { cach.pt() + hh / 2 } else if phia == "duoi" { -(cach.pt() + hh / 2) } else { 0 }
      let cx = px + uy * off                // pháp tuyến hướng "lên" trên trang: (uy, -ux)
      let cy = py + (-ux) * off
      place(
        dx: (cx - w / 2) * 1pt,
        dy: (cy - hh / 2) * 1pt,
        rotate(ang, reflow: false, el),
      )
      cursor = cursor + w + khoang.pt()
    }
  }
}

// ---------- Đánh dấu góc ----------
// Góc (thường, không vuông) giữa hai tia O->A và O->B:
// cung nhỏ + nhãn + số cung (1..3) + tô quạt + tự ghi số đo.
//   to    : màu tô hình quạt (nên trong suốt, vd rgb(255, 170, 0, 70))
//   so-do : true = tự ghi số đo góc (vd 60°) khi không đặt `ten`
//   vach  : 1..3 vạch CẮT NGANG cung (ký hiệu hai góc bằng nhau, kiểu SGK).
//           Khác `so-cung` (vẽ nhiều cung đồng tâm) — `vach` chỉ vẽ MỘT cung
//           rồi gạch 1/2/3 vạch nhỏ vuông góc cung tại giữa cung.
//           Bí danh `vach-danh-dau:` dùng được y hệt.
/// Đánh dấu góc (không vuông) TẠI O, giữa hai tia O→A và O→B.
/// ĐỈNH là đối số ĐẦU. Quen lối TikZ (đỉnh ở giữa) thì dùng `ve-goc(A, O, B)`.
/// `ten:` nhãn · `so-do: true` tự ghi số đo · `vach: 1..3` vạch góc bằng nhau ·
/// `so-cung: 1..3` cung đồng tâm · `to:` tô quạt · `cach-nhan:` nhãn xa/gần cung.
#let goc(
  ctx, O, A, B,
  r: 0.45,          // bán kính cung (đơn vị toạ độ)
  ten: none,
  so-do: false,     // tự ghi số đo (làm tròn 0.1°); `ten` được ưu tiên
  so-cung: 1,
  vach: 0,          // số vạch đánh dấu cắt ngang cung (0 = không)
  vach-danh-dau: auto,   // bí danh của `vach`
  dai-vach: 6pt,    // độ dài mỗi vạch
  to: none,         // tô màu hình quạt của góc
  mau: black, day: 0.8pt,
  cach-nhan: 1.9,   // hệ số đặt nhãn so với r
) = {
  let vach = if vach-danh-dau == auto { vach } else { vach-danh-dau }
  let a1 = calc.atan2(A.at(0) - O.at(0), A.at(1) - O.at(1))
  let a2 = calc.atan2(B.at(0) - O.at(0), B.at(1) - O.at(1))
  let d = a2 - a1
  if d > 180deg { d = d - 360deg }
  if d < -180deg { d = d + 360deg }
  if to != none {
    da-giac-pt(
      ((O,) + diem-cung(O, r, r, a1, a1 + d, n: 32)).map(P => toa-pt(ctx, P)),
      to: to,
    )
  }
  for i in range(so-cung) {
    let rr = r * (1 + 0.22 * i)
    cung(ctx, O, rr, tu: a1, den: a1 + d, mau: mau, day: day, n: 24)
  }
  // Vạch đánh dấu cắt ngang cung (ký hiệu góc bằng nhau)
  if vach > 0 {
    let tm = a1 + d / 2
    let opt = toa-pt(ctx, O)
    let ppt = toa-pt(ctx, (O.at(0) + r * calc.cos(tm), O.at(1) + r * calc.sin(tm)))
    let rp = calc.sqrt(
      calc.pow(ppt.at(0) - opt.at(0), 2) + calc.pow(ppt.at(1) - opt.at(1), 2)
    )
    if rp > 0.01 {
      let da = (3.4 / rp) * 1rad        // khoảng cách 2 vạch ~3.4pt trên cung
      let hd = dai-vach.pt() / 2
      for i in range(vach) {
        let ang = tm + (i - (vach - 1) / 2) * da
        let q = toa-pt(ctx, (O.at(0) + r * calc.cos(ang), O.at(1) + r * calc.sin(ang)))
        let l = calc.sqrt(
          calc.pow(q.at(0) - opt.at(0), 2) + calc.pow(q.at(1) - opt.at(1), 2)
        )
        let (ux, uy) = ((q.at(0) - opt.at(0)) / l, (q.at(1) - opt.at(1)) / l)
        doan-pt(
          (q.at(0) - hd * ux, q.at(1) - hd * uy),
          (q.at(0) + hd * ux, q.at(1) + hd * uy),
          mau: mau, day: day,
        )
      }
    }
  }
  let nd = if ten != none { ten } else if so-do {
    let dd = if d < 0deg { -d } else { d }
    let v = calc.round(dd.deg(), digits: 1)
    let s = if calc.abs(v - calc.round(v)) < 0.01 { str(int(calc.round(v))) } else { str(v) }
    $#s degree$
  } else { none }
  if nd != none {
    let tm = a1 + d / 2
    nhan(
      ctx,
      (O.at(0) + r * cach-nhan * calc.cos(tm), O.at(1) + r * cach-nhan * calc.sin(tm)),
      nd, huong: "giua", mau: mau,
    )
  }
}

// Ký hiệu góc vuông tại O (giữa hai tia O->A, O->B).
/// Ký hiệu góc vuông TẠI O (giữa hai tia O→A, O→B). ĐỈNH là đối số ĐẦU.
/// Quen lối TikZ (đỉnh ở giữa) thì dùng `ve-goc-vuong(A, O, B)`.
#let goc-vuong(ctx, O, A, B, r: 0.32, mau: black, day: 0.8pt) = {
  let ka = calc.sqrt(calc.pow(A.at(0) - O.at(0), 2) + calc.pow(A.at(1) - O.at(1), 2))
  let kb = calc.sqrt(calc.pow(B.at(0) - O.at(0), 2) + calc.pow(B.at(1) - O.at(1), 2))
  if ka == 0 or kb == 0 { return }
  let u = ((A.at(0) - O.at(0)) / ka * r, (A.at(1) - O.at(1)) / ka * r)
  let v = ((B.at(0) - O.at(0)) / kb * r, (B.at(1) - O.at(1)) / kb * r)
  let P1 = (O.at(0) + u.at(0), O.at(1) + u.at(1))
  let P2 = (O.at(0) + u.at(0) + v.at(0), O.at(1) + u.at(1) + v.at(1))
  let P3 = (O.at(0) + v.at(0), O.at(1) + v.at(1))
  duong-cong(ctx, (P1, P2, P3), mau: mau, day: day)
}

// ---------- Lối viết TikZ: ĐỈNH góc đặt ở GIỮA ----------
// `goc`/`goc-vuong` ở trên đặt ĐỈNH góc làm đối số ĐẦU: goc-vuong(O, A, B).
// TikZ lại viết đỉnh ở GIỮA (pic angle = A--O--B), nên hai hàm dưới đây nhận
// thứ tự quen thuộc đó — đỉnh là đối số THỨ HAI:
//     ve-goc(A, O, B, ...)        <=>  goc(O, A, B, ...)
//     ve-goc-vuong(A, O, B, ...)  <=>  goc-vuong(O, A, B, ...)
// Mọi tuỳ chọn (r, ten, so-do, so-cung, vach, to, mau, day, cach-nhan…) giữ
// nguyên tên và được truyền thẳng xuống hàm gốc, nên hai lối dùng lẫn được
// trong cùng một hình. Hàm gốc KHÔNG đổi ⇒ mọi bài cũ chạy y như trước.
/// Đánh dấu góc TẠI O theo lối TikZ: ĐỈNH nằm GIỮA — `ve-goc(A, O, B)`.
/// Cùng bộ tuỳ chọn với `goc` (r, ten, so-do, so-cung, vach, to, mau, day, cach-nhan).
#let ve-goc(ctx, A, O, B, ..tuy-chon) = goc(ctx, O, A, B, ..tuy-chon)

/// Ký hiệu góc vuông TẠI O theo lối TikZ: ĐỈNH nằm GIỮA — `ve-goc-vuong(A, O, B)`.
/// Cùng bộ tuỳ chọn với `goc-vuong` (r, mau, day).
#let ve-goc-vuong(ctx, A, O, B, ..tuy-chon) = goc-vuong(ctx, O, A, B, ..tuy-chon)

// ---------- Đánh dấu đoạn bằng nhau (1..3 vạch tại trung điểm) ----------
// so     : số vạch song song (1/2/3…) tại trung điểm đoạn.
// nghieng: góc NGHIÊNG của vạch so với pháp tuyến đoạn (0deg = vuông góc như cũ);
//          đặt ~20–30deg cho kiểu vạch chéo "/" "//" "///".
// cheo   : true = mỗi mốc vẽ dấu CHÉO NHAU "✕" (hai vạch ±góc); khi đó `nghieng`
//          = nửa góc mở của dấu ✕ (mặc định 30deg nếu để 0deg).
#let danh-dau(ctx, A, B, so: 1, dai: 6pt, mau: black, day: 1pt,
              nghieng: 0deg, cheo: false) = {
  let a = toa-pt(ctx, A)
  let b = toa-pt(ctx, B)
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let l = calc.sqrt(dx * dx + dy * dy)
  if l == 0 { return }
  let ux = dx / l
  let uy = dy / l
  let m = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  let hd = dai.pt() / 2
  // vẽ MỘT vạch tại tâm c, nghiêng góc g so với pháp tuyến (−uy, ux) của đoạn.
  let mot-vach(c, g) = {
    let cs = calc.cos(g)
    let sn = calc.sin(g)
    // pháp tuyến p = (−uy, ux); tiếp tuyến u = (ux, uy)
    // vạch nghiêng: v = cos(g)·p + sin(g)·u
    let vx = -uy * cs + ux * sn
    let vy = ux * cs + uy * sn
    doan-pt(
      (c.at(0) - hd * vx, c.at(1) - hd * vy),
      (c.at(0) + hd * vx, c.at(1) + hd * vy),
      mau: mau, day: day,
    )
  }
  for i in range(so) {
    let t = (i - (so - 1) / 2) * 3.2
    let c = (m.at(0) + t * ux, m.at(1) + t * uy)
    if cheo {
      let g = if nghieng == 0deg { 30deg } else { nghieng }
      mot-vach(c, g)
      mot-vach(c, -g)
    } else {
      mot-vach(c, nghieng)
    }
  }
}

// ---------- Tiện ích hình học phẳng (tính toán) ----------
/// TRẢ VỀ trung điểm của A và B (chỉ tính, không vẽ).
#let trung-diem(A, B) = ((A.at(0) + B.at(0)) / 2, (A.at(1) + B.at(1)) / 2)

#let khoang-cach(A, B) = calc.sqrt(
  calc.pow(B.at(0) - A.at(0), 2) + calc.pow(B.at(1) - A.at(1), 2)
)

// Điểm chia: A + t*(B - A).
/// TRẢ VỀ điểm M trên đường AB với AM/AB = t (t = 0.5 là trung điểm,
/// t > 1 là kéo dài quá B, t < 0 là ngược về phía A).
#let chia(A, B, t) = (
  A.at(0) + t * (B.at(0) - A.at(0)),
  A.at(1) + t * (B.at(1) - A.at(1)),
)

// Chân đường vuông góc hạ từ P xuống đường thẳng AB.
/// TRẢ VỀ hình chiếu vuông góc của P lên đường thẳng AB (chân đường cao).
#let hinh-chieu(P, A, B) = {
  let ux = B.at(0) - A.at(0)
  let uy = B.at(1) - A.at(1)
  let t = ((P.at(0) - A.at(0)) * ux + (P.at(1) - A.at(1)) * uy) / (ux * ux + uy * uy)
  (A.at(0) + t * ux, A.at(1) + t * uy)
}

// ---------- Cửa sổ khung vừa khít hình (TRẢ GIÁ TRỊ, không vẽ) ----------
// Gom mọi điểm mà một đối tượng chiếm chỗ (nội bộ của khung-vua).
#let _diem-cua(m) = {
  if type(m) != array or m.len() == 0 { return () }
  let so = (int, float)
  if m.len() == 2 and type(m.at(0)) in so and type(m.at(1)) in so {
    (m,)                                   // một ĐIỂM (x, y)
  } else if m.len() == 2 and type(m.at(0)) == array and type(m.at(1)) in so {
    let (O, r) = m                         // một ĐƯỜNG TRÒN (tâm, bán kính)
    (
      (O.at(0) - r, O.at(1)), (O.at(0) + r, O.at(1)),
      (O.at(0), O.at(1) - r), (O.at(0), O.at(1) + r),
    )
  } else {
    let ds = ()
    for x in m { ds += _diem-cua(x) }      // mảng điểm / mảng lồng nhau
    ds
  }
}

// Cửa sổ toạ độ vừa khít các đối tượng truyền vào — để hình KHÔNG tràn ra
// ngoài khung. Mỗi đối số là một ĐIỂM (x, y), một ĐƯỜNG TRÒN (tâm, bán kính),
// hoặc một MẢNG gồm các thứ đó.
//   #hinh(w: 5cm, ..khung-vua((A, B, C), (O, R)), ctx => { ... })
// le: chừa lề quanh hình, tính theo TỈ LỆ cạnh lớn của hình (0.12 = 12%).
/// TRẢ VỀ cửa sổ `(xmin:, xmax:, ymin:, ymax:)` vừa khít các điểm/đường tròn
/// truyền vào, để rải thẳng vào `#hinh`:
/// `#hinh(w: 5cm, ..khung-vua((A, B, C), (O, R)), ctx => { … })`.
#let khung-vua(..muc, le: 0.12) = {
  let ds = ()
  for m in muc.pos() { ds += _diem-cua(m) }
  if ds.len() == 0 { return (xmin: -5, xmax: 5, ymin: -4, ymax: 4) }
  let xs = ds.map(P => P.at(0))
  let ys = ds.map(P => P.at(1))
  let (x1, x2) = (calc.min(..xs), calc.max(..xs))
  let (y1, y2) = (calc.min(..ys), calc.max(..ys))
  let d = calc.max(x2 - x1, y2 - y1, 0.001)
  let m = d * le
  (xmin: x1 - m, xmax: x2 + m, ymin: y1 - m, ymax: y2 + m)
}

// Tâm đường tròn ngoại tiếp tam giác ABC.
#let tam-ngoai-tiep(A, B, C) = {
  let d = 2 * (A.at(0) * (B.at(1) - C.at(1)) + B.at(0) * (C.at(1) - A.at(1)) + C.at(0) * (A.at(1) - B.at(1)))
  let a2 = A.at(0) * A.at(0) + A.at(1) * A.at(1)
  let b2 = B.at(0) * B.at(0) + B.at(1) * B.at(1)
  let c2 = C.at(0) * C.at(0) + C.at(1) * C.at(1)
  (
    (a2 * (B.at(1) - C.at(1)) + b2 * (C.at(1) - A.at(1)) + c2 * (A.at(1) - B.at(1))) / d,
    (a2 * (C.at(0) - B.at(0)) + b2 * (A.at(0) - C.at(0)) + c2 * (B.at(0) - A.at(0))) / d,
  )
}

// Đường tròn ĐI QUA một dãy điểm — dùng cho đường tròn ngoại tiếp ĐA GIÁC.
// 3 điểm: đúng bằng đường tròn ngoại tiếp tam giác. Nhiều hơn 3: khớp theo
// bình phương bé nhất (đa giác NỘI TIẾP ĐƯỢC vẫn cho đúng đường tròn của nó,
// đa giác vẽ hơi lệch thì cho đường tròn sát nhất — không lệch hẳn về 3 đỉnh
// đầu như khi chỉ lấy 3 điểm).
// TRẢ VỀ (tâm, bán kính).
#let tron-qua-diem(ds) = {
  let n = ds.len()
  if n < 3 { panic("tron-qua-diem: cần ít nhất 3 điểm") }
  let xm = ds.map(P => P.at(0)).sum() / n
  let ym = ds.map(P => P.at(1)).sum() / n
  let us = ds.map(P => P.at(0) - xm)
  let vs = ds.map(P => P.at(1) - ym)
  let s(f) = range(n).map(i => f(us.at(i), vs.at(i))).sum()
  let suu = s((u, v) => u * u)
  let svv = s((u, v) => v * v)
  let suv = s((u, v) => u * v)
  let a1 = (s((u, v) => u * u * u) + s((u, v) => u * v * v)) / 2
  let a2 = (s((u, v) => v * v * v) + s((u, v) => v * u * u)) / 2
  let d = suu * svv - suv * suv
  if calc.abs(d) < 1e-12 { panic("tron-qua-diem: các điểm thẳng hàng") }
  let uc = (a1 * svv - a2 * suv) / d
  let vc = (a2 * suu - a1 * suv) / d
  (
    (xm + uc, ym + vc),
    calc.sqrt(uc * uc + vc * vc + (suu + svv) / n),
  )
}

// Tâm đường tròn nội tiếp + bán kính: trả về (I, r).
#let tam-noi-tiep(A, B, C) = {
  let a = khoang-cach(B, C)
  let b = khoang-cach(C, A)
  let c = khoang-cach(A, B)
  let p = a + b + c
  let I = (
    (a * A.at(0) + b * B.at(0) + c * C.at(0)) / p,
    (a * A.at(1) + b * B.at(1) + c * C.at(1)) / p,
  )
  let s = p / 2
  let r = calc.sqrt((s - a) * (s - b) * (s - c) / s)
  (I, r)
}

// Trực tâm tam giác ABC (giao ba đường cao).
// Dùng hệ thức Euler: vec(OH) = vec(OA) + vec(OB) + vec(OC) => H = A + B + C - 2O.
#let truc-tam(A, B, C) = {
  let O = tam-ngoai-tiep(A, B, C)
  (
    A.at(0) + B.at(0) + C.at(0) - 2 * O.at(0),
    A.at(1) + B.at(1) + C.at(1) - 2 * O.at(1),
  )
}

// Tâm bàng tiếp + bán kính đường tròn bàng tiếp TRONG GÓC A
// (tiếp xúc cạnh BC và phần kéo dài của AB, AC): trả về (J, r).
//   J_A = (-a*A + b*B + c*C) / (-a + b + c),  r_A = S / (p - a)
// Muốn tâm bàng tiếp trong góc B thì gọi tam-bang-tiep(B, C, A).
#let tam-bang-tiep(A, B, C) = {
  let a = khoang-cach(B, C)
  let b = khoang-cach(C, A)
  let c = khoang-cach(A, B)
  let t = -a + b + c
  let J = (
    (-a * A.at(0) + b * B.at(0) + c * C.at(0)) / t,
    (-a * A.at(1) + b * B.at(1) + c * C.at(1)) / t,
  )
  let s = (a + b + c) / 2
  let S = calc.sqrt(s * (s - a) * (s - b) * (s - c))
  (J, S / (s - a))
}

// Hàm bậc nhất y = f(x) của đường thẳng qua 2 điểm A, B (AB không thẳng đứng)
// — dùng ghép với giao-ham để tìm giao đường thẳng với đường cong.
#let ham-qua-2-diem(A, B) = {
  let a = (B.at(1) - A.at(1)) / (B.at(0) - A.at(0))
  x => A.at(1) + a * (x - A.at(0))
}

// Giao điểm của 2 đồ thị y = f(x) và y = g(x) trên [tu, den]:
// quét n mẫu tìm chỗ f − g đổi dấu rồi chia đôi 40 lần (chính xác ~1e-12).
// Trả về MẢNG các điểm (x, f(x)) theo x tăng dần (rỗng nếu không cắt).
// Giao đường thẳng AB với đường cong f: giao-ham(f, ham-qua-2-diem(A, B), ...);
// đường thẳng ĐỨNG x = k thì giao là (k, f(k)) — không cần hàm này.
//
// CÁCH GỌI (hàm này chỉ TÍNH, không vẽ — không cần ctx):
//   giao-ham(f, g, -3, 2)              // cận positional
//   giao-ham(f, g, tu: -3, den: 2)     // hoặc cận đặt tên (như ve-ham)
//   for P in giao-ham(f, g, -3, 2) { diem(ctx, P, mau: red) }
// Lỡ truyền ctx ở đầu (giao-ham(ctx, f, g, ...)) thì tự bỏ qua, không lỗi.
// Chỗ f, g "nhảy" qua tiệm cận đứng cũng đổi dấu — các điểm giả đó bị LOẠI
// (kiểm tra lại |f − g| tại nghiệm), nên quét qua tiệm cận vẫn an toàn.
#let giao-ham(..thamso, tu: auto, den: auto, n: 200) = {
  let p = thamso.pos()
  // bỏ qua ctx nếu lỡ truyền vào (ctx là dictionary, f/g là hàm)
  if p.len() > 0 and type(p.at(0)) == dictionary { p = p.slice(1) }
  let f = p.at(0)
  let g = p.at(1)
  let tu = if p.len() > 2 { p.at(2) } else { tu }
  let den = if p.len() > 3 { p.at(3) } else { den }
  let h = x => f(x) - g(x)
  let kq = ()
  // lệch mẫu một lượng cực nhỏ để không rơi ĐÚNG vào điểm hàm không xác định
  // (vd x = −1 của (x+2)/(x+1) — Typst báo lỗi "cannot divide by zero")
  let le = 0.0000001
  for i in range(n) {
    let x1 = tu + (den - tu) * (i + le) / n
    let x2 = tu + (den - tu) * (i + 1 + le) / n
    let (y1, y2) = (h(x1), h(x2))
    if y1 * y2 <= 0 and (y1 != 0 or y2 != 0) {
      let (lo, hi) = (x1, x2)
      for _ in range(40) {
        let m = (lo + hi) / 2
        if h(lo) * h(m) <= 0 { hi = m } else { lo = m }
      }
      let x = (lo + hi) / 2
      let y = f(x)
      // nghiệm THẬT: f(x) ≈ g(x); tiệm cận đứng cho |f − g| rất lớn -> bỏ
      let that = calc.abs(h(x)) < 0.000001 * calc.max(1, calc.abs(y))
      if that and (kq.len() == 0 or x - kq.last().at(0) > (den - tu) / n * 0.5) {
        kq.push((x, y))
      }
    }
  }
  kq
}

// Hai tiếp điểm của tiếp tuyến kẻ từ điểm M ngoài đường tròn (O; r).
#let tiep-diem(O, r, M) = {
  let d = khoang-cach(O, M)
  let a = r * r / d               // khoảng cách từ O đến hình chiếu tiếp điểm trên OM
  let hcao = r * calc.sqrt(d * d - r * r) / d
  let ux = (M.at(0) - O.at(0)) / d
  let uy = (M.at(1) - O.at(1)) / d
  let H = (O.at(0) + a * ux, O.at(1) + a * uy)
  (
    (H.at(0) - hcao * uy, H.at(1) + hcao * ux),
    (H.at(0) + hcao * uy, H.at(1) - hcao * ux),
  )
}

// ---------- Lấy mẫu hàm số ----------
#let lay-mau(f, a, b, n: 100) = range(n + 1).map(i => {
  let x = a + (b - a) * (i / n)
  (x, f(x))
})

// Vẽ đồ thị hàm f trên [tu, den]; tự tách nhánh khi ra ngoài cửa sổ y
// (dùng được cho hàm có tiệm cận đứng như 1/x, tan x).
#let ve-ham(
  ctx, f,
  tu: auto, den: auto,
  n: 150, mau: blue, day: 1.3pt, dut: false,
) = {
  let a = if tu == auto { ctx.xmin } else { tu }
  let b = if den == auto { ctx.xmax } else { den }
  let le-y = (ctx.ymax - ctx.ymin) * 0.02
  let nhanh = ()
  let hien-tai = ()
  for p in lay-mau(f, a, b, n: n) {
    if p.at(1) >= ctx.ymin - le-y and p.at(1) <= ctx.ymax + le-y {
      hien-tai.push(p)
    } else {
      if hien-tai.len() > 1 { nhanh.push(hien-tai) }
      hien-tai = ()
    }
  }
  if hien-tai.len() > 1 { nhanh.push(hien-tai) }
  for nh in nhanh {
    duong-cong(ctx, nh, mau: mau, day: day, dut: dut)
  }
}

// Tô miền giữa đồ thị f và trục hoành trên [a, b] (mau nên có độ trong suốt).
#let to-vung(ctx, f, a, b, mau: rgb(30, 100, 200, 60), n: 80) = {
  let pts = lay-mau(f, a, b, n: n)
  da-giac-pt(((a, 0), ..pts, (b, 0)).map(P => toa-pt(ctx, P)), to: mau)
}

// Tô miền giữa HAI đồ thị f và g trên [a, b] (mau nên có độ trong suốt).
#let to-vung-2-ham(ctx, f, g, a, b, mau: rgb(30, 100, 200, 60), n: 80) = {
  let tren = lay-mau(f, a, b, n: n)
  let duoi = lay-mau(g, a, b, n: n).rev()
  da-giac-pt((tren + duoi).map(P => toa-pt(ctx, P)), to: mau)
}

// ---------- Gạch chéo (miền loại bỏ của BPT, vùng cấm...) ----------
// Toạ độ trang (pt) -> toạ độ toán (nghịch đảo của toa-pt).
#let toa-nguoc(ctx, p) = (
  ctx.xmin + p.at(0) / ctx.sx.pt(),
  ctx.ymax - p.at(1) / ctx.sy.pt(),
)

// Gạch chéo một đa giác LỒI cho trước bằng các đoạn song song.
// pts: toạ độ pt. goc: hướng vạch gạch. buoc: khoảng cách 2 vạch.
#let _gach-loi-pt(pts, goc: 45deg, buoc: 6.5pt, mau: red, day: 0.55pt) = {
  if pts.len() < 3 { return }
  let d = (calc.cos(goc), -calc.sin(goc))     // trục y trang hướng xuống
  let nv = (-d.at(1), d.at(0))
  let ts = pts.map(p => p.at(0) * nv.at(0) + p.at(1) * nv.at(1))
  let t = calc.min(..ts) + buoc.pt() / 2
  let t1 = calc.max(..ts)
  while t < t1 {
    // giao của đường {X · nv = t} với từng cạnh đa giác
    let gd = ()
    for i in range(pts.len()) {
      let P = pts.at(i)
      let Q = pts.at(calc.rem(i + 1, pts.len()))
      let a1 = P.at(0) * nv.at(0) + P.at(1) * nv.at(1)
      let a2 = Q.at(0) * nv.at(0) + Q.at(1) * nv.at(1)
      if calc.abs(a2 - a1) > 0.000001 {
        let s = (t - a1) / (a2 - a1)
        if s >= 0 and s < 1 {
          gd.push((P.at(0) + s * (Q.at(0) - P.at(0)), P.at(1) + s * (Q.at(1) - P.at(1))))
        }
      }
    }
    let gd = gd.sorted(key: p => p.at(0) * d.at(0) + p.at(1) * d.at(1))
    let i = 0
    while i + 1 < gd.len() {
      doan-pt(gd.at(i), gd.at(i + 1), mau: mau, day: day)
      i = i + 2
    }
    t = t + buoc.pt()
  }
}

// Gạch chéo đa giác lồi theo toạ độ TOÁN.
#let gach-mien(ctx, cac-dinh, goc: 45deg, buoc: 6.5pt, mau: red, day: 0.55pt) = {
  _gach-loi-pt(cac-dinh.map(P => toa-pt(ctx, P)), goc: goc, buoc: buoc, mau: mau, day: day)
}

// Cắt đa giác bởi nửa mặt phẳng a*x + b*y <= c (Sutherland–Hodgman, toạ độ toán).
#let cat-nua-mp(pts, a, b, c) = {
  let kq = ()
  let n = pts.len()
  for i in range(n) {
    let P = pts.at(i)
    let Q = pts.at(calc.rem(i + 1, n))
    let fp = a * P.at(0) + b * P.at(1) - c
    let fq = a * Q.at(0) + b * Q.at(1) - c
    if fp <= 0.000001 { kq.push(P) }
    if fp * fq < 0 {
      let s = fp / (fp - fq)
      kq.push((P.at(0) + s * (Q.at(0) - P.at(0)), P.at(1) + s * (Q.at(1) - P.at(1))))
    }
  }
  kq
}

// Điểm P có thuộc hình tròn tâm O bán kính r không (toạ độ toán)?
#let trong-tron(P, O, r) = (
  calc.pow(P.at(0) - O.at(0), 2) + calc.pow(P.at(1) - O.at(1), 2) <= r * r
)

// Điểm P có thuộc hình elip tâm O, bán trục a (ngang), b (dọc) không?
// quay: cùng góc xoay với hàm vẽ elip(ctx, O, a, b, quay: ...).
#let trong-elip(P, O, a, b, quay: 0deg) = {
  let Q = if quay == 0deg { P } else { quay-diem(P, O, -quay) }
  calc.pow((Q.at(0) - O.at(0)) / a, 2) + calc.pow((Q.at(1) - O.at(1)) / b, 2) <= 1
}

// ---------- Miền hình học ĐẶT TÊN (khai báo MỘT lần, vẽ + gạch dùng chung) ----------
//   let A = mien-tron((-0.5, 0.3), 0.9)      // đổi bán kính MỘT chỗ duy nhất
//   ve-mien(ctx, A)                          // vẽ biên
//   gach-vung(ctx, giao(A, B, bu(C)))        // gạch (A ∩ B) \ C — tự khớp
#let mien-tron(O, r) = (kieu: "tron", O: O, r: r)
#let mien-elip(O, a, b, quay: 0deg) = (kieu: "elip", O: O, a: a, b: b, quay: quay)

// Điểm P có thuộc miền m không? m là mien-tron/mien-elip HOẶC hàm P => bool.
#let trong(P, m) = {
  if type(m) == function { m(P) } else if m.kieu == "tron" {
    trong-tron(P, m.O, m.r)
  } else {
    trong-elip(P, m.O, m.a, m.b, quay: m.quay)
  }
}

// Phép tập hợp trên miền: giao ∩, hợp ∪, bù (phần ngoài) — lồng nhau tuỳ ý:
//   giao(A, hop(B, C)), giao(A, B, bu(C)), ...  Kết quả dùng thẳng cho gach-vung.
#let giao(..ms) = P => ms.pos().all(m => trong(P, m))
#let hop(..ms) = P => ms.pos().any(m => trong(P, m))
#let bu(m) = P => not trong(P, m)

// Vẽ biên miền (đường tròn/elip tương ứng với khai báo).
#let ve-mien(ctx, m, mau: black, day: 1pt, dut: false, to: none) = {
  if m.kieu == "tron" {
    duong-tron(ctx, m.O, m.r, mau: mau, day: day, dut: dut, to: to)
  } else {
    elip(ctx, m.O, m.a, m.b, quay: m.quay, mau: mau, day: day, dut: dut, to: to)
  }
}

// Gạch chéo MIỀN BẤT KÌ (biên cong tuỳ ý).
// kiem: miền đặt tên/tổ hợp giao-hop-bu (khuyên dùng) HOẶC hàm P => true/false:
//   gach-vung(ctx, giao(A, B, bu(C)))
//   gach-vung(ctx, P => trong(P, A) and P.at(1) > 0)
// goc: hướng vạch; buoc: khoảng cách 2 vạch; n: số mẫu mỗi vạch (biên càng mịn).
#let gach-vung(ctx, kiem, goc: 45deg, buoc: 6.5pt, mau: red, day: 0.55pt, n: 180) = {
  let W = ctx.w.pt()
  let H = ctx.h.pt()
  let u = (calc.cos(goc), -calc.sin(goc))   // hướng vạch trên trang (y trang hướng xuống)
  let v = (-u.at(1), u.at(0))               // pháp tuyến đơn vị
  let b = buoc.pt()
  let cac-goc = ((0, 0), (W, 0), (0, H), (W, H))
  let ds = cac-goc.map(p => p.at(0) * v.at(0) + p.at(1) * v.at(1))
  let ts = cac-goc.map(p => p.at(0) * u.at(0) + p.at(1) * u.at(1))
  let dmin = calc.min(..ds)
  let dmax = calc.max(..ds)
  let tmin = calc.min(..ts)
  let tmax = calc.max(..ts)
  for i in range(calc.floor((dmax - dmin) / b) + 1) {
    let d = dmin + i * b
    let dau = none
    let truoc = none
    for j in range(n + 1) {
      let t = tmin + (tmax - tmin) * j / n
      let p = (d * v.at(0) + t * u.at(0), d * v.at(1) + t * u.at(1))
      let thuoc = (
        p.at(0) >= 0 and p.at(0) <= W and p.at(1) >= 0 and p.at(1) <= H
          and trong(toa-nguoc(ctx, p), kiem)
      )
      if thuoc and dau == none { dau = p }
      if not thuoc and dau != none {
        doan-pt(dau, truoc, mau: mau, day: day)
        dau = none
      }
      truoc = p
    }
    if dau != none { doan-pt(dau, truoc, mau: mau, day: day) }
  }
}
