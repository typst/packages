// =====================================================================
// baigiang.typ — NHẬP MỘT FILE DUY NHẤT NÀY LÀ DÙNG ĐƯỢC TẤT CẢ
//   #import "baigiang.typ": *
// =====================================================================
#import "lib/ve.typ": *
#import "lib/hinh-phang.typ": *
#import "lib/hinh-khong-gian.typ": *
#import "lib/da-dien.typ": *
#import "lib/mat-cong.typ": *
#import "lib/oxyz-toan.typ": *
#import "lib/do-thi.typ": *
#import "lib/so-do-cay.typ": *
#import "lib/bang.typ": *
#import "lib/khao-sat.typ": *
#import "lib/bang-thong-ke.typ": *
#import "lib/bieu-do-thong-ke.typ": *
#import "lib/tron-xoay.typ": *
#import "lib/slide.typ": *
#import "lib/cau-hoi.typ": *
#import "lib/che-do.typ": *

// =====================================================================
// ve-voi(ctx) — BỘ HÀM VẼ ĐÃ GẮN SẴN ctx (đỡ phải gõ ctx mỗi lệnh)
// Khai báo MỘT dòng ở đầu khối `them:` rồi gọi hàm như bình thường,
// bỏ tham số ctx đầu tiên:
//
//   them: ctx => {
//     let (doan, diem, nhan, ve-ham) = ve-voi(ctx)   // lấy hàm nào kê tên hàm đó
//     doan(M, N, mau: blue, dut: true)
//     ve-ham(g, mau: red)
//     diem(A, mau: red, ten: $A$)
//   }
//
// (Typst KHÔNG cho gọi `v.doan(M, N)` sau `let v = ve-voi(ctx)` — báo
//  "cannot directly call dictionary keys as functions"; muốn giữ một biến thì
//  phải bọc ngoặc `(v.doan)(M, N)`. Vậy nên cách kê tên ở trên là gọn nhất.)
//
// Cách gọi cũ `doan(ctx, M, N)` vẫn dùng được bình thường (không đổi gì).
// LƯU Ý: các hàm KHÔNG cần ctx (trung-diem, chia, hinh-chieu, giao-ham,
// ham-qua-2-diem, so-toan, mien-tron, giao/hop/bu...) cứ gọi thẳng như cũ;
// đổi khung nhìn (ctx-quay, ctx-tinh-tien) thì lấy bộ hàm mới:
//   let (doan, diem) = ve-voi(ctx-quay(ctx, 30deg))
// =====================================================================
#let ve-voi(ctx) = (
  // ve.typ — nguyên thuỷ
  toa: (..a) => toa(ctx, ..a),
  toa-pt: (..a) => toa-pt(ctx, ..a),
  toa-nguoc: (..a) => toa-nguoc(ctx, ..a),
  goc-truc: (..a) => goc-truc(ctx, ..a),
  dau-mui-ten: (..a) => dau-mui-ten(ctx, ..a),
  doan: (..a) => doan(ctx, ..a),
  cac-doan: (..a) => cac-doan(ctx, ..a),
  nhan: (..a) => nhan(ctx, ..a),
  nhan-goc: (..a) => nhan-goc(ctx, ..a),
  diem: (..a) => diem(ctx, ..a),
  cac-diem: (..a) => cac-diem(ctx, ..a),
  mui-ten: (..a) => mui-ten(ctx, ..a),
  mui-ten-2-dau: (..a) => mui-ten-2-dau(ctx, ..a),
  vecto: (..a) => vecto(ctx, ..a),
  duong-cong: (..a) => duong-cong(ctx, ..a),
  duong-gap-khuc: (..a) => duong-gap-khuc(ctx, ..a),
  da-giac: (..a) => da-giac(ctx, ..a),
  duong-tron: (..a) => duong-tron(ctx, ..a),
  elip: (..a) => elip(ctx, ..a),
  cung: (..a) => cung(ctx, ..a),
  cung-elip: (..a) => cung-elip(ctx, ..a),
  xoan-oc: (..a) => xoan-oc(ctx, ..a),
  goc-luong-giac: (..a) => goc-luong-giac(ctx, ..a),
  goc: (..a) => goc(ctx, ..a),
  goc-vuong: (..a) => goc-vuong(ctx, ..a),
  ve-goc: (..a) => ve-goc(ctx, ..a),             // lối TikZ: đỉnh ở GIỮA
  ve-goc-vuong: (..a) => ve-goc-vuong(ctx, ..a), // lối TikZ: đỉnh ở GIỮA
  danh-dau: (..a) => danh-dau(ctx, ..a),
  ve-ham: (..a) => ve-ham(ctx, ..a),
  to-vung: (..a) => to-vung(ctx, ..a),
  to-vung-2-ham: (..a) => to-vung-2-ham(ctx, ..a),
  gach-mien: (..a) => gach-mien(ctx, ..a),
  gach-vung: (..a) => gach-vung(ctx, ..a),
  ve-mien: (..a) => ve-mien(ctx, ..a),
  duong-luon: (..a) => duong-luon(ctx, ..a),
  nhan-cong: (..a) => nhan-cong(ctx, ..a),
  // do-thi.typ — hệ trục & gióng
  truc: (..a) => truc(ctx, ..a),
  luoi: (..a) => luoi(ctx, ..a),
  vach-chia: (..a) => vach-chia(ctx, ..a),
  he-truc: (..a) => he-truc(ctx, ..a),
  giong: (..a) => giong(ctx, ..a),
  tiep-tuyen: (..a) => tiep-tuyen(ctx, ..a),
  nhan-pi: (..a) => nhan-pi(ctx, ..a),
  // hinh-phang.typ
  da-giac-ten: (..a) => da-giac-ten(ctx, ..a),
  tam-giac: (..a) => tam-giac(ctx, ..a),
  duong-cao: (..a) => duong-cao(ctx, ..a),
  trung-tuyen: (..a) => trung-tuyen(ctx, ..a),
  phan-giac: (..a) => phan-giac(ctx, ..a),
  trung-truc: (..a) => trung-truc(ctx, ..a),
  tam-giac-deu: (..a) => tam-giac-deu(ctx, ..a),
  tam-giac-vuong: (..a) => tam-giac-vuong(ctx, ..a),
  tam-giac-can: (..a) => tam-giac-can(ctx, ..a),
  tam-giac-vuong-can: (..a) => tam-giac-vuong-can(ctx, ..a),
  tu-giac: (..a) => tu-giac(ctx, ..a),
  hinh-binh-hanh: (..a) => hinh-binh-hanh(ctx, ..a),
  hinh-chu-nhat: (..a) => hinh-chu-nhat(ctx, ..a),
  hinh-thang: (..a) => hinh-thang(ctx, ..a),
  duong-tron-ngoai-tiep: (..a) => duong-tron-ngoai-tiep(ctx, ..a),
  duong-tron-noi-tiep: (..a) => duong-tron-noi-tiep(ctx, ..a),
  duong-tron-bang-tiep: (..a) => duong-tron-bang-tiep(ctx, ..a),
  ve-truc-tam: (..a) => ve-truc-tam(ctx, ..a),
  tiep-tuyen-tu-diem: (..a) => tiep-tuyen-tu-diem(ctx, ..a),
  tiep-tuyen-tai-diem: (..a) => tiep-tuyen-tai-diem(ctx, ..a),
  // tron-xoay.typ
  ve-khoi-xoay: (..a) => ve-khoi-xoay(ctx, ..a),
  ve-mien-xoay: (..a) => ve-mien-xoay(ctx, ..a),
  // hinh-khong-gian.typ — Oxyz
  diem-oxyz: (..a) => diem-oxyz(ctx, ..a),
  doan-oxyz: (..a) => doan-oxyz(ctx, ..a),
  vecto-oxyz: (..a) => vecto-oxyz(ctx, ..a),
  giong-oxyz: (..a) => giong-oxyz(ctx, ..a),
  // da-dien.typ — engine đa diện tổng quát, mặt phẳng, thiết diện
  // (da-dien / da-dien-thiet-dien TỰ tạo khung nên không kê ở đây)
  ve-da-dien: (..a) => ve-da-dien(ctx, ..a),
  mat-phang: (..a) => mat-phang(ctx, ..a),
  mat-phang-oxyz: (..a) => mat-phang-oxyz(ctx, ..a),
  mat-phang-bh: (..a) => mat-phang-bh(ctx, ..a),
  ve-thiet-dien: (..a) => ve-thiet-dien(ctx, ..a),
  // mat-cong.typ — nón/trụ có nét khuất tự động (mat-cong tự tạo khung, không kê)
  ve-mat-cong: (..a) => ve-mat-cong(ctx, ..a),
  ve-truc-3d: (..a) => ve-truc-3d(ctx, ..a),
)


// =====================================================================
// ctx NGẦM — gọi hàm vẽ KHÔNG cần truyền ctx (07/2026)
// Trong thân #hinh(...) hoặc trong `them: ctx => ...` của mọi hình/đồ thị
// dựng sẵn, cứ gọi thẳng:
//
//   them: ctx => {
//     doan(M, N, mau: blue, dut: true)
//     ve-ham(g, mau: red)
//     diem(A, mau: red, ten: $A$)
//   }
//
// Cách CŨ `doan(ctx, M, N)` vẫn chạy y nguyên (đối số đầu là ctx thì gọi
// thẳng) — bài soạn cũ không phải sửa gì.
// NGOẠI LỆ vẫn phải truyền ctx: các hàm TRẢ VỀ GIÁ TRỊ, không vẽ —
// toa, toa-pt, toa-nguoc, goc-truc, ctx-quay, ctx-tinh-tien.
// (Bên trong lib các hàm vẫn gọi nhau theo lối cũ nên không ảnh hưởng.)
// =====================================================================
// ve.typ — nguyên thuỷ vẽ
/// `doan(A, B, mau: black, day: 1pt, dut: false, ten: none, tai: 0.5, huong: auto, cach: 6pt, ten-quay: false, mau-ten: auto)`
///
/// Đoạn thẳng AB, kèm NHÃN CHÚ THÍCH đặt trên đoạn (tuỳ chọn):
/// ten   : nội dung nhãn (vd $a$, [3 cm]) — none = không ghi
/// tai   : vị trí nhãn theo TỈ LỆ từ A đến B (0 = tại A, 1 = tại B, .5 = giữa)
/// huong : auto = tự đặt VUÔNG GÓC phía trên đoạn (đoạn dọc thì ra trái);
/// hoặc tên hướng ("above", "below", "left", ...), hoặc vectơ (dx, dy)
/// cach  : khoảng cách từ đoạn tới nhãn
#let doan = _voi-ctx(doan)
/// `cac-doan(..noi-dung, mau: black, day: 1pt, dut: false, dong: false, to: none, mui-ten: false, ten: none, tai: 0.5, huong: auto, cach: 6pt, ten-quay: false, mau-ten: auto)`
///
/// Vẽ NHIỀU nét trong một lệnh: điểm liền nhau thành một đường gấp khúc,
/// mỗi MẢNG điểm là một nét riêng — `cac-doan((A, B), (C, D), (M, N))`.
/// Nét cần kiểu riêng thì bọc `duong(...)`.
#let cac-doan = _voi-ctx(cac-doan)
/// `nhan(P, noi-dung, huong: "above", cach: 6pt, mau: black, quay: 0deg)`
///
/// Nhãn văn bản đặt cạnh điểm P.
/// huong: "above", "below", "left", "right", "above-left", "above-right",
/// "below-left", "below-right", "center"
/// (tên tiếng Việt cũ "tren", "duoi", "trai", "phai", ... vẫn dùng được)
/// quay: góc xoay chữ (vd 90deg, -45deg, hoặc goc-truc(...)). Mặc định 0deg.
/// Đặt chữ/công thức tại điểm P. `huong` là phía đặt chữ so với P
#let nhan = _voi-ctx(nhan)
/// `nhan-goc(..muc, mau: black, ban-kinh: 6pt)`
///
/// Đặt nhãn cho nhiều điểm, VỊ TRÍ nhãn xác định bằng GÓC LƯỢNG GIÁC (thay cho
/// tên hướng "above"/"below"…). Mỗi mục là một tuple:
/// (P, nội-dung, goc)                — bán kính & màu lấy mặc định
/// (P, nội-dung, goc, ban-kinh)      — ban-kinh là ĐỘ DÀI trang (vd 8pt)
/// (P, nội-dung, goc, ban-kinh, mau) — kèm màu riêng
/// `goc` là góc lượng giác (số trần = ĐỘ, dương = ngược kim đồng hồ; nhãn đặt
#let nhan-goc = _voi-ctx(nhan-goc)
/// `diem(P, ten: none, huong: "tren", bk: 2pt, mau: black, cach: 6pt, mau-ten: black)`
///
/// Điểm (chấm tròn) + nhãn tuỳ chọn.
/// cach: khoảng cách nhãn tới điểm · mau-ten: màu chữ (auto = màu chấm).
/// Chấm một điểm, kèm tên: `diem(A, ten: $A$, huong: "below-left")`.
/// Nhiều điểm một lệnh thì dùng `cac-diem`.
#let diem = _voi-ctx(diem)
/// `cac-diem(..noi-dung, mau: black, bk: 2pt, huong: "above", cach: 6pt, mau-ten: black)`
///
/// Mỗi đối số vị trí là một điểm, viết theo 1 trong 4 dạng:
/// A                      -> chỉ chấm, không nhãn
/// (A, $A$)               -> chấm + nhãn, hướng lấy theo `huong` chung
/// (A, $A$, "left")       -> + hướng riêng
/// (A, $A$, "left", red)  -> + màu riêng (cả chấm lẫn chữ nếu mau-ten: auto)
/// Tuỳ chọn chung: mau · bk (bán kính chấm) · huong · cach (nhãn cách chấm)
#let cac-diem = _voi-ctx(cac-diem)
/// `mui-ten(A, B, mau: black, day: 1pt, kich: 7pt, dut: false)`
///
/// Mũi tên A -> B.
#let mui-ten = _voi-ctx(mui-ten)
/// `mui-ten-2-dau(A, B, mau: black, day: 1pt, kich: 7pt, dut: false, ten: none, huong: auto, cach: 5pt, ten-quay: false, mau-ten: auto, trong: auto, dem: 3pt, nen: white, vach: false, dai-vach: 9pt, le: 0pt)`
///
/// không đủ dài thì tự đặt chữ ra ngoài (phía trên đoạn)
/// huong    : chỗ đặt chữ khi KHÔNG nằm giữa thân
/// (auto = vuông góc phía trên đoạn, như `doan`)
/// ten-quay : true = chữ NẰM DỌC theo mũi tên (luôn đọc xuôi)
/// vach     : true = kẻ vạch chặn vuông góc ở hai đầu (kiểu ghi kích thước)
/// le       : lùi hai đầu mũi tên vào trong, để hở khỏi vật đang đo
#let mui-ten-2-dau = _voi-ctx(mui-ten-2-dau)
/// `vecto(A, B, ten: none, huong: "tren", mau: black, day: 1.1pt, dut: false)`
///
/// Vectơ A -> B kèm tên đặt ở trung điểm.
/// dut: true = thân nét đứt (vectơ nằm trên cạnh khuất, kiểu hình SGK);
/// đầu mũi tên luôn nét liền.
#let vecto = _voi-ctx(vecto)
/// `duong-cong(cac-diem, mau: black, day: 1pt, dut: false, dong: false)`
///
/// Đường gấp khúc qua dãy điểm. dut: nét đứt (vẽ cách đoạn -> đều trên đường cong).
#let duong-cong = _voi-ctx(duong-cong)
/// `duong-gap-khuc(cac-diem, mau: black, day: 1pt, dut: false, dong: false)`
///
/// Đường gấp khúc nối lần lượt A - B - C - ... KHÁC duong-cong ở chỗ:
/// dut: true là nét đứt THẬT trên TỪNG đoạn (hợp polyline ít đoạn;
/// duong-cong đứt kiểu "bỏ đoạn xen kẽ" chỉ hợp đường nhiều mẫu).
/// dong: true nối điểm cuối về điểm đầu.
#let duong-gap-khuc = _voi-ctx(duong-gap-khuc)
/// `da-giac(cac-diem, mau: black, day: 1pt, dut: false, to: none)`
///
/// Đa giác kín: viền + tô màu tuỳ chọn (to: màu hoặc none).
/// Đa giác khép kín. Đỉnh truyền vào dưới dạng MỘT MẢNG:
/// `da-giac((A, B, C))` — không phải `da-giac(A, B, C)`. `to:` để tô màu.
#let da-giac = _voi-ctx(da-giac)
/// `duong-tron(O, r, mau: black, day: 1pt, dut: false, to: none)`
///
/// Đường tròn tâm O bán kính r (theo đơn vị trục x; nếu 2 trục cùng tỉ lệ
/// thì là đường tròn thật, khác tỉ lệ sẽ thành elip tương ứng).
#let duong-tron = _voi-ctx(duong-tron)
/// `elip(O, a, b, mau: black, day: 1pt, dut: false, to: none, quay: 0deg, n: 72)`
///
/// Elip tâm O, bán trục a (ngang), b (dọc); quay: góc xoay quanh tâm
/// (dương = ngược chiều kim đồng hồ), n: số mẫu khi vẽ elip xoay.
#let elip = _voi-ctx(elip)
/// `cung(O, r, tu: 0deg, den: 180deg, mau: black, day: 1pt, dut: false, n: 48, quay: 0deg)`
///
/// Cung tròn tâm O bán kính r từ góc `tu` đến `den` (kiểu angle, vd 30deg).
#let cung = _voi-ctx(cung)
/// `cung-elip(O, a, b, tu: 0deg, den: 180deg, mau: black, day: 1pt, dut: false, n: 48, quay: 0deg)`
///
/// Cung elip (dùng cho hình không gian: đáy nón, trụ...).
#let cung-elip = _voi-ctx(cung-elip)
/// `xoan-oc(O, tu: 0deg, den: 360deg, r: 0.12, r-cuoi: auto, buoc: 0.16, mau: black, day: 1pt, dut: false, mui-ten: true, kich: 7pt, n: auto, ten: none, huong: "above", cach: 6pt, mau-ten: auto)`
///
/// Xoắn ốc Archimedes tâm O: bán kính TĂNG ĐỀU theo góc, quét từ `tu` đến `den`.
/// Góc quét |den - tu| ĐƯỢC PHÉP lớn hơn 360° (nhiều vòng);
/// den > tu = ngược chiều kim đồng hồ (chiều dương), den < tu = cùng chiều kim đồng hồ.
/// r       : bán kính tại góc `tu`
/// r-cuoi  : bán kính tại góc `den` (auto = r + buoc · số vòng quét)
/// buoc    : khoảng cách giữa hai vòng liên tiếp (dùng khi r-cuoi: auto)
#let xoan-oc = _voi-ctx(xoan-oc)
/// `goc-luong-giac(O, A, M, chieu: "duong", vong: 0, r: auto, r-cuoi: auto, buoc: auto, mau: blue, day: 0.9pt, dut: false, kich: 6pt, ten: none, so-do: false, huong: "above", cach: 6pt, mau-ten: auto, n: auto)`
///
/// Góc lượng giác (OA, OM): xoắn ốc từ tia OA quay tới tia OM (kiểu SGK 11).
/// chieu : "duong" = ngược chiều kim đồng hồ (mặc định) · "am" = cùng chiều
/// vong  : số vòng quay THÊM (0, 1, 2, ...) trước khi dừng ở tia OM
/// so-do : true = tự ghi số đo (vd -430°) cạnh mũi tên; `ten` được ưu tiên
/// Ví dụ hình "AOM = 70°, (OA, OM) = -430°": goc-luong-giac(O, A, M, chieu: "am", vong: 1)
#let goc-luong-giac = _voi-ctx(goc-luong-giac)
/// `goc(O, A, B, r: 0.45, ten: none, so-do: false, so-cung: 1, vach: 0, vach-danh-dau: auto, dai-vach: 6pt, to: none, mau: black, day: 0.8pt, cach-nhan: 1.9)`
///
/// Góc (thường, không vuông) giữa hai tia O->A và O->B:
/// cung nhỏ + nhãn + số cung (1..3) + tô quạt + tự ghi số đo.
/// to    : màu tô hình quạt (nên trong suốt, vd rgb(255, 170, 0, 70))
/// so-do : true = tự ghi số đo góc (vd 60°) khi không đặt `ten`
/// vach  : 1..3 vạch CẮT NGANG cung (ký hiệu hai góc bằng nhau, kiểu SGK).
/// Khác `so-cung` (vẽ nhiều cung đồng tâm) — `vach` chỉ vẽ MỘT cung
#let goc = _voi-ctx(goc)
/// `goc-vuong(O, A, B, r: 0.32, mau: black, day: 0.8pt)`
///
/// Ký hiệu góc vuông tại O (giữa hai tia O->A, O->B).
/// Ký hiệu góc vuông TẠI O (giữa hai tia O→A, O→B). ĐỈNH là đối số ĐẦU.
/// Quen lối TikZ (đỉnh ở giữa) thì dùng `ve-goc-vuong(A, O, B)`.
#let goc-vuong = _voi-ctx(goc-vuong)
/// `ve-goc(A, O, B, ..tuy-chon)`
///
/// `goc`/`goc-vuong` ở trên đặt ĐỈNH góc làm đối số ĐẦU: goc-vuong(O, A, B).
/// TikZ lại viết đỉnh ở GIỮA (pic angle = A--O--B), nên hai hàm dưới đây nhận
/// thứ tự quen thuộc đó — đỉnh là đối số THỨ HAI:
/// ve-goc(A, O, B, ...)        <=>  goc(O, A, B, ...)
/// ve-goc-vuong(A, O, B, ...)  <=>  goc-vuong(O, A, B, ...)
/// Mọi tuỳ chọn (r, ten, so-do, so-cung, vach, to, mau, day, cach-nhan…) giữ
#let ve-goc = _voi-ctx(ve-goc)
/// `ve-goc-vuong(A, O, B, ..tuy-chon)`
///
/// Ký hiệu góc vuông TẠI O theo lối TikZ: ĐỈNH nằm GIỮA — `ve-goc-vuong(A, O, B)`.
/// Cùng bộ tuỳ chọn với `goc-vuong` (r, mau, day).
#let ve-goc-vuong = _voi-ctx(ve-goc-vuong)
/// `danh-dau(A, B, so: 1, dai: 6pt, mau: black, day: 1pt, nghieng: 0deg, cheo: false)`
///
/// so     : số vạch song song (1/2/3…) tại trung điểm đoạn.
/// nghieng: góc NGHIÊNG của vạch so với pháp tuyến đoạn (0deg = vuông góc như cũ);
/// đặt ~20–30deg cho kiểu vạch chéo "/" "//" "///".
/// cheo   : true = mỗi mốc vẽ dấu CHÉO NHAU "✕" (hai vạch ±góc); khi đó `nghieng`
/// = nửa góc mở của dấu ✕ (mặc định 30deg nếu để 0deg).
#let danh-dau = _voi-ctx(danh-dau)
/// `ve-ham(f, tu: auto, den: auto, n: 150, mau: blue, day: 1.3pt, dut: false)`
///
/// Vẽ đồ thị hàm f trên [tu, den]; tự tách nhánh khi ra ngoài cửa sổ y
/// (dùng được cho hàm có tiệm cận đứng như 1/x, tan x).
#let ve-ham = _voi-ctx(ve-ham)
/// `to-vung(f, a, b, mau: rgb(30, 100, 200, 60), n: 80)`
///
/// Tô miền giữa đồ thị f và trục hoành trên [a, b] (mau nên có độ trong suốt).
#let to-vung = _voi-ctx(to-vung)
/// `to-vung-2-ham(f, g, a, b, mau: rgb(30, 100, 200, 60), n: 80)`
///
/// Tô miền giữa HAI đồ thị f và g trên [a, b] (mau nên có độ trong suốt).
#let to-vung-2-ham = _voi-ctx(to-vung-2-ham)
/// `gach-mien(cac-dinh, goc: 45deg, buoc: 6.5pt, mau: red, day: 0.55pt)`
///
/// Gạch chéo đa giác lồi theo toạ độ TOÁN.
#let gach-mien = _voi-ctx(gach-mien)
/// `gach-vung(kiem, goc: 45deg, buoc: 6.5pt, mau: red, day: 0.55pt, n: 180)`
///
/// Gạch chéo MIỀN BẤT KÌ (biên cong tuỳ ý).
/// kiem: miền đặt tên/tổ hợp giao-hop-bu (khuyên dùng) HOẶC hàm P => true/false:
/// gach-vung(ctx, giao(A, B, bu(C)))
/// gach-vung(ctx, P => trong(P, A) and P.at(1) > 0)
/// goc: hướng vạch; buoc: khoảng cách 2 vạch; n: số mẫu mỗi vạch (biên càng mịn).
#let gach-vung = _voi-ctx(gach-vung)
/// `ve-mien(m, mau: black, day: 1pt, dut: false, to: none)`
///
/// Vẽ biên miền (đường tròn/elip tương ứng với khai báo).
#let ve-mien = _voi-ctx(ve-mien)
/// `duong-luon(..noi-dung, mau: black, day: 1pt, dut: false, dong: false, to: none, mui-ten: false, kich: 7pt, ten: none, tai: 0.5, huong: auto, cach: 6pt, ten-quay: false, mau-ten: auto, n: 16)`
///
/// Vẽ đường cong uốn lượn qua các điểm neo, điểm điều khiển kiểu `controls` TikZ.
/// duong-luon(A, B, C, D)                          // trơn tự động qua 4 neo
/// duong-luon(A, dieu-khien(c1, c2), B)            // Bézier bậc ba một đoạn
/// duong-luon(A, dieu-khien(c1,c2), B, C, dong: true, to: blue.lighten(85%))
/// Tuỳ chọn: mau · day · dut · dong (khép kín) · to (tô) · mui-ten · kich ·
/// ten/tai/huong/cach/ten-quay/mau-ten (nhãn đặt theo TỈ LỆ độ dài, như cac-doan) ·
#let duong-luon = _voi-ctx(duong-luon)
/// `nhan-cong(duong, chu, tu: 0, can: "trai", khoang: 0pt, co: auto, mau: black, phia: "tren", cach: 2pt, dao: false)`
///
/// Đặt từng ký tự của `chu` DỌC THEO đường `duong` (mảng điểm toạ độ toán, vd
/// lấy từ diem-luon / diem-cung / lay-mau), tự xoay tiếp tuyến, canh theo độ dài cung.
/// duong: mảng điểm (>= 2). chu: str (khuyên dùng) hoặc content văn bản thuần.
/// tu    : vị trí BẮT ĐẦU theo tỉ lệ độ dài đường (0 = đầu, 1 = cuối, .5 = giữa)
/// can   : "trai" (bắt đầu tại `tu`) · "giua" (canh giữa chữ quanh `tu`) · "phai"
/// khoang: giãn cách thêm giữa các ký tự (length)
#let nhan-cong = _voi-ctx(nhan-cong)
/// `dau-mui-ten(A, B, mau: black, kich: 7pt)`
///
/// Đầu mũi tên tại B, hướng A->B.
#let dau-mui-ten = _voi-ctx(dau-mui-ten)

// do-thi.typ — hệ trục, lưới, vạch chia, đường gióng
/// `truc(ten-x: $x$, ten-y: $y$, ten-goc: $O$, mau: black, day: 0.9pt)`
///
#let truc = _voi-ctx(truc)
/// `luoi(buoc: 1, mau: luma(87%), day: 0.5pt)`
///
/// Lưới ô vuông mờ.
#let luoi = _voi-ctx(luoi)
/// `vach-chia(buoc-x: 1, buoc-y: 1, so: true, mau: black)`
///
/// Vạch chia + số trên hai trục (bỏ qua 0).
#let vach-chia = _voi-ctx(vach-chia)
/// `he-truc(ten-x: $x$, ten-y: $y$, ten-goc: $O$, luoi-o: true, buoc-luoi: auto, vach: true, so: true, buoc-x: 1, buoc-y: 1, mau: black, day: 0.9pt, mau-luoi: luma(87%))`
///
/// Hệ trục TRỌN GÓI: lưới + trục + vạch chia + số — một lệnh thay ba.
/// #hinh(xmin: -4, xmax: 4, ymin: -3, ymax: 3, ctx => { he-truc(ctx) ... })
/// luoi-o: lưới ô vuông mờ · vach: vạch chia đơn vị · so: ghi số trên vạch
#let he-truc = _voi-ctx(he-truc)
/// `giong(P, ten-x: auto, ten-y: auto, huong-x: "below", huong-y: "left", mau: gray.darken(20%), mau-diem: red, diem-to: true)`
///
/// Đường gióng từ điểm P về 2 trục (nét đứt) + nhãn toạ độ trên trục.
/// ten-x / ten-y: auto = tự ghi số; none = không ghi; hoặc nội dung tuỳ ý.
#let giong = _voi-ctx(giong)
/// `tiep-tuyen(f, x0, mau: red, day: 1.2pt, dut: false, dai: auto, cham: true, mau-cham: auto, ten-diem: none, huong-diem: "above-left", ten: none, tai: 0.9, huong-ten: auto, cach: 6pt, ten-quay: false, giong: false, h: auto)`
///
/// TIẾP TUYẾN của đồ thị y = f(x) tại điểm có hoành độ x0 (hoặc DÃY hoành độ).
/// Hệ số góc lấy bằng đạo hàm số nên dùng được cho MỌI hàm f viết bằng closure.
/// tiep-tuyen(f, 1)                                  // tiếp tuyến tại x = 1
/// tiep-tuyen(f, (-1, 2), mau: green)                // nhiều tiếp điểm
/// tiep-tuyen(f, 1, ten: auto)                       // tự ghi y = kx + m
/// tiep-tuyen(f, 1, ten: $Delta$, ten-diem: $M$)     // đặt tên tuỳ ý
#let tiep-tuyen = _voi-ctx(tiep-tuyen)
/// `nhan-pi()`
///
/// Ghi nhãn các bội của π trên trục hoành.
#let nhan-pi = _voi-ctx(nhan-pi)

// hinh-phang.typ — tam giác, tứ giác, đường tròn đặc biệt
/// `da-giac-ten(dinh, ten: none, mau: black, day: 1.1pt, to: none, cham: true)`
///
/// Vẽ đa giác + nhãn đỉnh tự động hướng ra ngoài.
/// ten: mảng nội dung nhãn (cùng độ dài số đỉnh) hoặc none.
#let da-giac-ten = _voi-ctx(da-giac-ten)
/// `tam-giac(A, B, C, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, cham: true)`
///
#let tam-giac = _voi-ctx(tam-giac)
/// `duong-cao(P, A, B, ten-chan: none, mau: red, day: 1pt, dut: false, vuong: true)`
///
/// Đường cao hạ từ P xuống đường thẳng AB (kèm ký hiệu vuông góc).
/// ten-chan: nhãn chân đường cao (vd $H$).
#let duong-cao = _voi-ctx(duong-cao)
/// `trung-tuyen(P, A, B, ten-chan: none, mau: blue, day: 1pt, dut: false, so-vach: 1)`
///
/// Trung tuyến từ P đến trung điểm AB (kèm 2 vạch đánh dấu bằng nhau).
#let trung-tuyen = _voi-ctx(trung-tuyen)
/// `phan-giac(O, A, B, ten-chan: none, mau: green.darken(20%), day: 1pt, dut: false, r-cung: 0.5, vach: 0, so-cung: 1, dai-vach: 6pt, lech: auto, ten-goc: none, cach-nhan: 1.9)`
///
/// Phân giác trong góc O của tam giác OAB (kèm 2 cung đánh dấu góc bằng nhau).
/// vach     : số VẠCH gạch ngang cung (0/1/2/3) — ký hiệu hai góc bằng nhau
/// so-cung  : số CUNG đồng tâm vẽ ở mỗi góc (1/2/3)
/// lech     : hệ số bán kính cung thứ hai so với cung thứ nhất
/// (auto = 1.18 khi KHÔNG đánh dấu, = 1 khi có vạch/nhiều cung —
/// vì hai góc bằng nhau thì phải vẽ cùng bán kính mới đúng quy ước)
#let phan-giac = _voi-ctx(phan-giac)
/// `trung-truc(A, B, dai: 1.5, mau: purple, day: 1pt, dut: true, so-vach: 1)`
///
/// Đường trung trực của đoạn AB (đoạn vuông góc tại trung điểm, dài 2*dai).
#let trung-truc = _voi-ctx(trung-truc)
/// `tam-giac-deu(A, canh, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, vach: 1)`
///
/// Tam giác đều cạnh `canh`, đỉnh A ở dưới-trái, đáy nằm ngang.
/// vach: số vạch đánh dấu cạnh bằng nhau (0 = không vẽ).
#let tam-giac-deu = _voi-ctx(tam-giac-deu)
/// `tam-giac-vuong(A, a, b, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none)`
///
/// Tam giác vuông tại A: cạnh AB ngang dài a, cạnh AC đứng dài b.
#let tam-giac-vuong = _voi-ctx(tam-giac-vuong)
/// `tam-giac-can(A, canh-day, chieu-cao, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, vach: 1)`
///
/// Tam giác cân tại C: đáy AB ngang dài `canh-day`, chiều cao `chieu-cao`.
#let tam-giac-can = _voi-ctx(tam-giac-can)
/// `tam-giac-vuong-can(A, canh, ten: ($A$, $B$, $C$), mau: black, day: 1.1pt, to: none, vach: 1)`
///
/// Tam giác vuông cân tại A, hai cạnh góc vuông dài `canh`.
#let tam-giac-vuong-can = _voi-ctx(tam-giac-vuong-can)
/// `tu-giac(A, B, C, D, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none)`
///
/// Tứ giác bất kỳ ABCD.
#let tu-giac = _voi-ctx(tu-giac)
/// `hinh-binh-hanh(A, B, C, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none)`
///
/// Hình bình hành biết 3 đỉnh liên tiếp A, B, C (D tự tính = A + C - B).
#let hinh-binh-hanh = _voi-ctx(hinh-binh-hanh)
/// `hinh-chu-nhat(A, r, c, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none, goc-vg: true)`
///
/// Hình chữ nhật: góc dưới-trái A, chiều rộng r, chiều cao c.
#let hinh-chu-nhat = _voi-ctx(hinh-chu-nhat)
/// `hinh-thang(A, a, b, c, lech: 0.6, ten: ($A$, $B$, $C$, $D$), mau: black, day: 1.1pt, to: none)`
///
/// Hình thang: đáy lớn AB (dưới, dài a), đáy nhỏ DC (trên, dài b),
/// cao c, lech: độ lệch ngang của D so với A.
#let hinh-thang = _voi-ctx(hinh-thang)
/// `duong-tron-ngoai-tiep(..vi-tri, ten-tam: $O$, huong-tam: auto, mau: blue, day: 1pt, dut: false, to: none, ban-kinh: false, dinh-r: auto, ten-r: none, canh: false, mau-canh: black)`
///
/// Đường tròn ngoại tiếp TAM GIÁC hoặc ĐA GIÁC.
/// duong-tron-ngoai-tiep(A, B, C)            — 3 đỉnh rời (lối cũ)
/// duong-tron-ngoai-tiep((A, B, C, D, E))    — MỘT MẢNG đỉnh, đa giác tuỳ ý
/// Từ 4 đỉnh trở lên, tâm/bán kính khớp theo bình phương bé nhất (đa giác nội
/// tiếp được cho ra đúng đường tròn của nó — xem `tron-qua-diem`).
/// ten-tam    : nhãn tâm (none = không ghi)
#let duong-tron-ngoai-tiep = _voi-ctx(duong-tron-ngoai-tiep)
/// `duong-tron-noi-tiep(A, B, C, ten-tam: $I$, mau: orange.darken(10%), day: 1pt, dut: false, ban-kinh: false)`
///
/// Đường tròn nội tiếp tam giác ABC.
#let duong-tron-noi-tiep = _voi-ctx(duong-tron-noi-tiep)
/// `duong-tron-bang-tiep(A, B, C, ten-tam: $J$, ten-tiep: none, mau: green.darken(25%), day: 1pt, keo-dai: true, tiep-diem: true, ban-kinh: false)`
///
/// Đường tròn bàng tiếp TRONG GÓC A của tam giác ABC (tiếp xúc cạnh BC và
/// phần kéo dài của AB, AC). Muốn góc B thì gọi duong-tron-bang-tiep(ctx, B, C, A).
/// ten-tam   : nhãn tâm (mặc định $J$)
/// keo-dai   : vẽ nét đứt kéo dài hai cạnh AB, AC tới tiếp điểm
/// tiep-diem : chấm 3 tiếp điểm
/// ban-kinh  : vẽ bán kính tới cạnh BC (kèm ký hiệu vuông góc)
#let duong-tron-bang-tiep = _voi-ctx(duong-tron-bang-tiep)
/// `ve-truc-tam(A, B, C, ten: $H$, ten-chan: ($H_A$, $H_B$, $H_C$), ten-dinh: ($A$, $B$, $C$), canh: true, mau: black, mau-cao: red, day: 1.1pt, dut: false, vuong: true)`
///
/// Ba đường cao của tam giác ABC + trực tâm H.
/// ten       : nhãn trực tâm (none = không ghi)
/// ten-chan  : nhãn 3 chân đường cao theo thứ tự hạ từ A, B, C
/// (none = không ghi; mặc định $H_A$, $H_B$, $H_C$)
/// vuong     : vẽ ký hiệu góc vuông tại chân đường cao
/// canh      : true = vẽ luôn tam giác ABC (kèm nhãn đỉnh)
#let ve-truc-tam = _voi-ctx(ve-truc-tam)
/// `tiep-tuyen-tu-diem(O, r, M, ten-tam: $O$, ten-diem: $M$, ten-tiep: ($T_1$, $T_2$), mau: black, mau-tt: red, day: 1pt)`
///
/// Hai tiếp tuyến kẻ từ điểm M ngoài đường tròn (O; r).
#let tiep-tuyen-tu-diem = _voi-ctx(tiep-tuyen-tu-diem)
/// `tiep-tuyen-tai-diem(O, r, M, dai: auto, mau: black, day: 1pt, dut: false)`
///
/// Dựng tiếp tuyến của đường tròn (O; r) TẠI điểm M (M nằm trên đường tròn):
/// đoạn thẳng qua M, VUÔNG GÓC với bán kính OM.
/// dai : nửa độ dài đoạn tiếp tuyến (auto = 1.4·r); đơn vị toạ độ toán.
/// mau / day / dut : kiểu nét của đoạn tiếp tuyến.
/// M không cần chính xác trên đường tròn — hướng tiếp tuyến lấy theo OM thực tế.
/// Tiếp tuyến của (O; r) TẠI điểm M: đoạn qua M vuông góc OM.
#let tiep-tuyen-tai-diem = _voi-ctx(tiep-tuyen-tai-diem)

// tron-xoay.typ — khối tròn xoay (khoi-tron-xoay tự tạo khung, không kê ở đây)
/// `ve-khoi-xoay(f, a, b, g: none, ngang: true, k: 0.26, mau: blue, day: 1.2pt, mau-to: rgb(70, 130, 200, 60), duong-sinh: true, truc-mo: true, mat-cat: none, mau-mat-cat: rgb(235, 130, 40, 120), ten-ban-kinh: auto, ten-mat-cat: auto, n: 120)`
///
#let ve-khoi-xoay = _voi-ctx(ve-khoi-xoay)
/// `ve-mien-xoay(f, a, b, g: none, ngang: true, mau: blue, day: 1.3pt, mau-to: rgb(70, 130, 200, 90), ten-ham: auto, ten-ham-trong: none, ten-a: auto, ten-b: auto, giong-ab: true, n: 120)`
///
#let ve-mien-xoay = _voi-ctx(ve-mien-xoay)

// hinh-khong-gian.typ — nhóm Oxyz
/// `diem-oxyz(t3, P, ten: none, huong: "above", bk: 2pt, mau: black)`
///
/// Điểm 3D: chấm + nhãn.
#let diem-oxyz = _voi-ctx(diem-oxyz)
/// `doan-oxyz(t3, A, B, mau: black, day: 1pt, dut: false)`
///
/// Đoạn / vectơ nối hai điểm 3D.
#let doan-oxyz = _voi-ctx(doan-oxyz)
/// `vecto-oxyz(t3, A, B, ten: none, huong: "tren", mau: black, day: 1.1pt, dut: false)`
///
#let vecto-oxyz = _voi-ctx(vecto-oxyz)
/// `giong-oxyz(t3, P, mau: blue, day: 0.8pt)`
///
/// Hộp gióng nét đứt từ gốc O đến điểm P = (a, b, c): vẽ các cạnh của
/// hình hộp chữ nhật [0,a]×[0,b]×[0,c] (trừ 3 cạnh nằm trên trục).
#let giong-oxyz = _voi-ctx(giong-oxyz)

// da-dien.typ — khối đa diện tổng quát, mặt phẳng, thiết diện
// (da-dien, da-dien-thiet-dien tự tạo khung; các hàm TRẢ GIÁ TRỊ như
//  chieu-*, khoi-*, mp-*, thiet-dien, v3-*, phan-tich-khoi KHÔNG bọc)
/// `ve-da-dien(dinh: (), mat: (), cam: auto, ten: none, huong: auto, cach: 6pt, mau-ten: black, hien-dinh: true, bk: 1.6pt, mau: black, day: 1.1pt, mau-khuat: auto, day-khuat: auto, hien-khuat: true, to: none, to-mat: none, diem: (), duong: (), mau-diem: auto, bk-diem: 1.8pt, them: none)`
///
#let ve-da-dien = _voi-ctx(ve-da-dien)
/// `mat-phang(p, dinh3, to: auto, mau: blue.darken(15%), day: 1pt, dut: false, ten: none, ten-tai: 0, huong: "above-left", cach: 5pt, che: (), mau-che: black, day-che: 0.9pt, nhin: auto, them: none)`
///
#let mat-phang = _voi-ctx(mat-phang)
/// `mat-phang-oxyz(t3, a, b, c, to: auto, mau: blue.darken(15%), day: 1pt, dut: false, ten: none, ten-tai: 0, huong: "above-left", cach: 5pt, ten-dinh: false, ten-abc: ($A$, $B$, $C$), hien-dinh: true, bk: 1.8pt, truc: auto, mau-che: black, day-che: 0.9pt, them: none)`
///
#let mat-phang-oxyz = _voi-ctx(mat-phang-oxyz)
/// `mat-phang-bh(t3, tam, u, v, to: auto, mau: blue.darken(15%), day: 1pt, dut: false, ten: none, ten-tai: 1, huong: "above-right", cach: 5pt, truc: none, mau-che: black, day-che: 0.9pt, them: none)`
///
#let mat-phang-bh = _voi-ctx(mat-phang-bh)
/// `ve-thiet-dien(dinh: (), mat: (), mp: none, cam: auto, to: auto, mau: red.darken(10%), day: 1.1pt, hien-khuat: true, mau-khuat: auto, day-khuat: auto, ten: none, huong: auto, cach: 6pt, hien-dinh: true, bk: 1.8pt, mau-ten: auto, them: none)`
///
/// Vẽ thiết diện TRÊN một khối: tô miền + viền LIỀN ở phần nằm trên mặt
/// THẤY, ĐỨT ở phần nằm trên mặt KHUẤT (nhận ctx ⇒ kê vào ve-voi).
/// ve-thiet-dien(ctx, dinh: d, mat: m, mp: mp-qua-3-diem(P, Q, R))
#let ve-thiet-dien = _voi-ctx(ve-thiet-dien)

// ---------------------------------------------------------------------
// mat-cong.typ — nón / trụ có NÉT KHUẤT TỰ ĐỘNG (kể cả hai khối che nhau).
// `mat-non`, `mat-tru`, `dinh-non` TRẢ GIÁ TRỊ ⇒ KHÔNG kê ở đây.
// `mat-cong` tự tạo khung hình ⇒ cũng KHÔNG kê.
// ---------------------------------------------------------------------
/// `ve-mat-cong(..khoi, cam: auto, mau: black, day: 1.1pt, to: none, hien-khuat: true, mau-khuat: auto, day-khuat: auto, n: 48, duong: (), truc: none, truoc: none, them: none)`
///
/// Vẽ một hoặc nhiều khối nón/trụ trục đứng, TỰ chia nét liền/đứt bằng cách
/// bắn tia về phía người nhìn — lo cả tự khuất lẫn hai khối che nhau.
/// ve-mat-cong(mat-non(r: 2, cao: 4), mat-tru(tam: (0, 2, 0), r: 2, cao: 4))
#let ve-mat-cong = _voi-ctx(ve-mat-cong)
/// `ve-truc-3d(cam, x: 3, y: 4, z: 4, am: 0.4, dm: 0.55, ten: ($x$, $y$, $z$), ten-goc: $O$, huong-ten: ("below-left", "below-right", "left"), huong-goc: "below-right", mau: black, day: 0.9pt, cach: 5pt)`
///
/// Vẽ hệ trục Oxyz bằng CHÍNH camera của khối ⇒ cả khung hình chung một góc
/// nghiêng (khác `oxyz`, vốn tự dựng phép chiếu xiên riêng).
#let ve-truc-3d = _voi-ctx(ve-truc-3d)
