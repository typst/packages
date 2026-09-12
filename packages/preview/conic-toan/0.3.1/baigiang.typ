// =====================================================================
// baigiang.typ — NHẬP MỘT FILE DUY NHẤT NÀY LÀ DÙNG ĐƯỢC TẤT CẢ
//   #import "baigiang.typ": *
// =====================================================================
#import "lib/ve.typ": *
#import "lib/hinh-phang.typ": *
#import "lib/hinh-khong-gian.typ": *
#import "lib/da-dien.typ": *
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
  diem: (..a) => diem(ctx, ..a),
  cac-diem: (..a) => cac-diem(ctx, ..a),
  mui-ten: (..a) => mui-ten(ctx, ..a),
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
#let doan = _voi-ctx(doan)
#let cac-doan = _voi-ctx(cac-doan)
#let nhan = _voi-ctx(nhan)
#let diem = _voi-ctx(diem)
#let cac-diem = _voi-ctx(cac-diem)
#let mui-ten = _voi-ctx(mui-ten)
#let vecto = _voi-ctx(vecto)
#let duong-cong = _voi-ctx(duong-cong)
#let duong-gap-khuc = _voi-ctx(duong-gap-khuc)
#let da-giac = _voi-ctx(da-giac)
#let duong-tron = _voi-ctx(duong-tron)
#let elip = _voi-ctx(elip)
#let cung = _voi-ctx(cung)
#let cung-elip = _voi-ctx(cung-elip)
#let xoan-oc = _voi-ctx(xoan-oc)
#let goc-luong-giac = _voi-ctx(goc-luong-giac)
#let goc = _voi-ctx(goc)
#let goc-vuong = _voi-ctx(goc-vuong)
#let danh-dau = _voi-ctx(danh-dau)
#let ve-ham = _voi-ctx(ve-ham)
#let to-vung = _voi-ctx(to-vung)
#let to-vung-2-ham = _voi-ctx(to-vung-2-ham)
#let gach-mien = _voi-ctx(gach-mien)
#let gach-vung = _voi-ctx(gach-vung)
#let ve-mien = _voi-ctx(ve-mien)
#let duong-luon = _voi-ctx(duong-luon)
#let nhan-cong = _voi-ctx(nhan-cong)
#let dau-mui-ten = _voi-ctx(dau-mui-ten)

// do-thi.typ — hệ trục, lưới, vạch chia, đường gióng
#let truc = _voi-ctx(truc)
#let luoi = _voi-ctx(luoi)
#let vach-chia = _voi-ctx(vach-chia)
#let he-truc = _voi-ctx(he-truc)
#let giong = _voi-ctx(giong)
#let tiep-tuyen = _voi-ctx(tiep-tuyen)
#let nhan-pi = _voi-ctx(nhan-pi)

// hinh-phang.typ — tam giác, tứ giác, đường tròn đặc biệt
#let da-giac-ten = _voi-ctx(da-giac-ten)
#let tam-giac = _voi-ctx(tam-giac)
#let duong-cao = _voi-ctx(duong-cao)
#let trung-tuyen = _voi-ctx(trung-tuyen)
#let phan-giac = _voi-ctx(phan-giac)
#let trung-truc = _voi-ctx(trung-truc)
#let tam-giac-deu = _voi-ctx(tam-giac-deu)
#let tam-giac-vuong = _voi-ctx(tam-giac-vuong)
#let tam-giac-can = _voi-ctx(tam-giac-can)
#let tam-giac-vuong-can = _voi-ctx(tam-giac-vuong-can)
#let tu-giac = _voi-ctx(tu-giac)
#let hinh-binh-hanh = _voi-ctx(hinh-binh-hanh)
#let hinh-chu-nhat = _voi-ctx(hinh-chu-nhat)
#let hinh-thang = _voi-ctx(hinh-thang)
#let duong-tron-ngoai-tiep = _voi-ctx(duong-tron-ngoai-tiep)
#let duong-tron-noi-tiep = _voi-ctx(duong-tron-noi-tiep)
#let duong-tron-bang-tiep = _voi-ctx(duong-tron-bang-tiep)
#let ve-truc-tam = _voi-ctx(ve-truc-tam)
#let tiep-tuyen-tu-diem = _voi-ctx(tiep-tuyen-tu-diem)

// tron-xoay.typ — khối tròn xoay (khoi-tron-xoay tự tạo khung, không kê ở đây)
#let ve-khoi-xoay = _voi-ctx(ve-khoi-xoay)
#let ve-mien-xoay = _voi-ctx(ve-mien-xoay)

// hinh-khong-gian.typ — nhóm Oxyz
#let diem-oxyz = _voi-ctx(diem-oxyz)
#let doan-oxyz = _voi-ctx(doan-oxyz)
#let vecto-oxyz = _voi-ctx(vecto-oxyz)
#let giong-oxyz = _voi-ctx(giong-oxyz)

// da-dien.typ — khối đa diện tổng quát, mặt phẳng, thiết diện
// (da-dien, da-dien-thiet-dien tự tạo khung; các hàm TRẢ GIÁ TRỊ như
//  chieu-*, khoi-*, mp-*, thiet-dien, v3-*, phan-tich-khoi KHÔNG bọc)
#let ve-da-dien = _voi-ctx(ve-da-dien)
#let mat-phang = _voi-ctx(mat-phang)
#let mat-phang-oxyz = _voi-ctx(mat-phang-oxyz)
#let mat-phang-bh = _voi-ctx(mat-phang-bh)
#let ve-thiet-dien = _voi-ctx(ve-thiet-dien)
