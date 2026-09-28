# v-exam: 0.1.0

Bộ công cụ biên soạn bài tập, tài liệu ôn tập và trộn đề thi trắc nghiệm / tự luận chuẩn định dạng Bộ Giáo dục & Đào tạo Việt Nam dành cho mọi môn học (Toán, Vật lý, Hóa học, Sinh học, Lịch sử, Địa lý, GDKT&PL, ...).

---

## 🚀 Tính năng nổi bật

- **Tự động trộn đề:** Trộn đảo phương án NLC, đảo ý $a, b, c, d$ của câu hỏi Đúng/Sai, hoán vị câu hỏi theo seed mã đề.
- **Tự động xuất bảng đáp án & mã QR:** Tạo bảng đáp án tổng hợp và mã QR cho phần mềm chấm thi tự động (như UNT, Chấm thi KC, ...).
- **Hỗ trợ câu hỏi chùm (Dữ kiện chung):** Tự động gom nhóm các câu hỏi con đi kèm đoạn văn cảnh/dữ kiện dùng chung mà không bị xáo rời rạc cho trường hợp câu hỏi chùm các môn.
- **Biên soạn bài tập nối tiếp (`exercise` / `baitap_inline`):** Hỗ trợ biên soạn tài liệu giảng dạy, bài tập ôn tập chuyên đề có kèm lời giải chi tiết.

---
## 🖼️ Mẫu kết quả (Gallery)

<p align="center">
  <img src="https://github.com/KieuQuangVu-NCP/v-exam/blob/main/gallery/Picture-de.png" width="48%" alt="Đề thi mẫu" /> <br>
  <img src="https://github.com/KieuQuangVu-NCP/v-exam/blob/main/gallery/Picture-bangda.png" width="48%" alt="Bảng đáp án" /> <br>
  <img src="https://github.com/KieuQuangVu-NCP/v-exam/blob/main/gallery/Picture-maQR.png" width="48%" alt="Mã QRcode dùng cho máy chấm" />
</p>

## 📦 Hướng dẫn sử dụng

### 1. Import thư viện

```typst
#import "@preview/v-exam:0.1.0": *
```

### 2. Định dạng ngân hàng câu hỏi

Ngân hàng câu hỏi được lưu dưới dạng mảng `array` các `dictionary`:

```typst
#let data = (
// Câu hỏi đơn trắc nghiệm nhiều lựa chọn.
(
    type: "NLC",
    hv:none,//none: không có hình vẽ; nếu có hình vẽ có thể dùng image("đường dẫn") dùng cho trường hợp import hình có sẳn hoặc canvas({}) để vẽ trực tiếp
    lv: 1, //lv: 1 - Nhận biết, lv: 2 - Thông hiểu, lv: 3 - Vận dụng
    nd: [Nội dung lời dẫn],
    pa: ([Phương án A], [Phương án B], [Phương án C], [Phương án]),
    cot: 4,//cot: 1 - bố trí 1 cột, cot: 2 - bố trí 2 cột, cot: 4 - bố trí 4 cột
    da: 0, //da: 0 - đáp án đúng A, da: 1 - đáp án đúng B, da: 2 - đáp án đúng C, da: 3 - đáp án đúng D
    lg: [Lời giải cho câu hỏi],
  ),
// Câu hỏi chùm trắc nghiệm nhiều lựa chọn.
(
    type: "NLC",
    hv:none,//none: không có hình vẽ; nếu có hình vẽ có thể dùng image("đường dẫn) dùng cho trường hợp import hình có sẳn hoặc canvas({}) để vẽ trực tiếp
    lv: 1, //lv: 1 - Nhận biết, lv: 2 - Thông hiểu, lv: 3 - Vận dụng
    is_chum:true,
    du_kien:[Nội dung dùng chung],
    cau_hoi_con:(
    // Câu hỏi con 1.
    (nd: [Nội dung lời dẫn câu hỏi 1],
    pa: ([Phương án A], [Phương án B], [Phương án C], [Phương án]),
    cot: 4,//cot: 1 - bố trí 1 cột, cot: 2 - bố trí 2 cột, cot: 4 - bố trí 4 cột
    da: 0, //da: 0 - đáp án đúng A, da: 1 - đáp án đúng B, da: 2 - đáp án đúng C, da: 3 - đáp án đúng D
    lg: [Lời giải cho câu hỏi 1],),
    // Câu hỏi con 2.
    (nd: [Nội dung lời dẫn câu hỏi 2],
    pa: ([Phương án A], [Phương án B], [Phương án C], [Phương án]),
    cot: 4,//cot: 1 - bố trí 1 cột, cot: 2 - bố trí 2 cột, cot: 4 - bố trí 4 cột
    da: 0, //da: 0 - đáp án đúng A, da: 1 - đáp án đúng B, da: 2 - đáp án đúng C, da: 3 - đáp án đúng D
    lg: [Lời giải cho câu hỏi 2],)
  ),),
  // Câu hỏi đúng sai
  (
    type: "TF",
    hv:none,//none: không có hình vẽ; nếu có hình vẽ có thể dùng image("đường dẫn) dùng cho trường hợp import hình có sẳn hoặc canvas({}) để vẽ trực tiếp
    lv: 2, //lv: 1 - Nhận biết, lv: 2 - Thông hiểu, lv: 3 - Vận dụng
    nd: [Lời dẫn của của câu hỏi],
    ytf: (
      [nội dung ý a],
      [nội dung ý b],
      [nội dung ý c],
      [nội dung ý d],
    ),
    da: (1, 0, 1, 0), // 1 - đúng, 0 - sai
    lg: ([Lời giải cho ý a],
        [Lời giải cho ý b],
        [Lời giải cho ý c],
        [Lời giải cho ý d],
  ),
//Câu hỏi trả lời ngắn đơn
(
    type: "TLN",
    hv:none,//none: không có hình vẽ; nếu có hình vẽ có thể dùng image("đường dẫn) dùng cho trường hợp import hình có sẳn hoặc canvas({}) để vẽ trực tiếp
    lv: 2, //lv: 1 - Nhận biết, lv: 2 - Thông hiểu, lv: 3 - Vận dụng
    nd: [Lời dẫn của của câu hỏi],
    da:so,// Số nhập có thể là số thực chứa phần thập phân hoặc không (tối đa 4 kí tự) đối với thập phân thì viết dấu "." thay cho ","
    lg:[Lời giải cho bài toán],
    dong-ke: so,//nhập số dòng kẻ cần tạo để ghi lời giải
),
//Câu hỏi trắc lời ngắn dạng chùm
// Câu hỏi chùm trắc nghiệm nhiều lựa chọn.
(
    type: "TLN",
    hv:none,//none: không có hình vẽ; nếu có hình vẽ có thể dùng image("đường dẫn) dùng cho trường hợp import hình có sẳn hoặc canvas({}) để vẽ trực tiếp
    lv: 1, //lv: 1 - Nhận biết, lv: 2 - Thông hiểu, lv: 3 - Vận dụng
    is-chum:true,
    du-kien:[Nội dung dùng chung],
    cau_hoi_con:(
    // Câu hỏi con 1.
    (nd: [Nội dung lời dẫn câu hỏi 1],
    da:so,// Số nhập có thể là số thực chứa phần thập phân hoặc không (tối đa 4 kí tự) đối với thập phân thì viết dấu "." thay cho ","
    lg:[Lời giải cho bài toán],
    dong-ke: so,//nhập số dòng kẻ cần tạo để ghi lời giải
    ),
    // Câu hỏi con 2.
    (nd: [Nội dung lời dẫn câu hỏi 2],
    pa: ([Phương án A], [Phương án B], [Phương án C], [Phương án]),
    da:so,// Số nhập có thể là số thực chứa phần thập phân hoặc không (tối đa 4 kí tự) đối với thập phân thì viết dấu "." thay cho ","
    lg:[Lời giải cho bài toán],
    dong-ke: so,//nhập số dòng kẻ cần tạo để ghi lời giải
),
  ),
),
//Câu hỏi tự luận
(
    type: "TL",
    hv:none,//none: không có hình vẽ; nếu có hình vẽ có thể dùng image("đường dẫn) dùng cho trường hợp import hình có sẳn hoặc canvas({}) để vẽ trực tiếp
    lv: 2, //lv: 1 - Nhận biết, lv: 2 - Thông hiểu, lv: 3 - Vận dụng
    nd: [Lời dẫn của của câu hỏi],
    lg:[Lời giải cho bài toán],
    dong-ke: so,//nhập số dòng kẻ cần tạo để ghi lời giải
),
)
```

### 3. Biên soạn bài tập / Tài liệu ôn tập (`exercise` / `baitap-inline`)
```typst
#import "file.typ" as b
// code tạo bài tập.
#exercise(
  b.data,
  cm: 1,
  num-nlc: (1, 0, 0),
  num-tf: (0, 1, 0),
  num-tln: (0,1,2),
  show-lg: true,
  seed: 123,
  theo-lv:true,
  dong-ke:4
)
```

### 4. Trộn đề thi
#### a) Trộn đề thi khác nhau(`make-exam-matrix` / `tron_de_bankLevel`)
Tạo các đề thi tư ngân hàng với các lấy ngẫu nhiên các câu hỏi từ bank để tạo bộ câu hỏi khác nhau cho mỗi đề\
**- Import ngân hàng câu hỏi để trộn đề và tạo bank**
```typst
#import "file.typ" as b
#let matrix = (
  (
    bank: b.data,
    NLC-dem: (1, 0, 0),
    tf-dem: (0, 1, 0),
    tln-dem: (0, 1, 0),
    tl-dem: (0, 1, 0),
  ),
)
```
**- Tạo thông tin bài kiểm tra**
```typst
#let info = (
  so-gd: [SỞ GD VÀ ĐT QUẢNG NGÃI],
  truong: [TRƯỜNG THPT NGHĨA HÀNH],
  ky-thi: [KIỂM TRA GIỮA KỲ I],
  mon: [VẬT LÝ 12],
  thoi-gian: [45 phút],
  ds-ma-de: ("101", "102", "103", "104"),
)
```
**- Thực hiện lên trộn đề:**
```typst
Cách 1:
#make-exam-matrix(matrix, info, show-lg: false, hienthi-bangdapan: true, theo-lv:true)

Cách 2:
#tron-de-bankLevel(matrix, info, show-g: false, hienthi-bangdapan: true, theo-lv:true)
```
Giải thích:
- matrix: là nơi cấu hình cách lấy câu hỏi từ bank để đưa vào đề.
- info: nội dung hiển thị tiêu đề của của bài kiểm tra và các mã đề của đề
- show-lg: có hai chức năng: (1) hiện lời giải cho đề (true) để giáo viên cung cấp cho học sinh hoặc hướng dẫn giảng dạy; (2) Ẩn lời giải (false) dùng trong việc tạo đề dúng cho kiểm tra.
- hienthi_bangdapan: có hai chức năng: (1) hiển thị bảng đáp án (true) cuối file để dùng trong chấm bài; (2) không hiển thị bảng đáp án (false) đảm bào đề tạo ra không có bản đáp án.
- theo-lv: có chức năng: (1) xếp câu hỏi thức mức độ từ NB -> TH -> VD khi dùng chức năng true; (2) xếp câu hỏi ngẫu nhiên để  tạo đề khi dùng chức năng false.

#### b) chức năng trộn đề tạo các đề giống nhau (`make-exam-sync` / `tron_de_cungNoiDung`)
Cách thực hiện đuề giống với "Trộn đề thi khác nhau" chỉ khác ở mục thực hiện trộn đề khi gọi lệnh:
```typst
Cách 1:
#make-exam-sync(matrix, info, seed-goc: 2026, show-lg: false,theo-lv:false,xao-cau: true, xao-pa: true)

Cách 2:
#tron-de-cungNoiDung(matrix, info, seed-goc: 2026, show_lg: false,theo-lv:false,xao-cau: true, xao-pa: true)
```
Giải thích:
- seed-goc: 2026 dùng để ấn định một seed được chon để tạo đề gốc ban đầu sau đó căn cứ theo mã đề để xáo cho hợp lý
- show-lg: có hai chức năng: (1) hiện lời giải cho đề (true) để giáo viên cung cấp cho học sinh hoặc hướng dẫn giảng dạy; (2) Ẩn lời giải (false) dùng trong việc tạo đề dúng cho kiểm tra.
- hienthi_bangdapan: có hai chức năng: (1) hiển thị bảng đáp án (true) cuối file để dùng trong chấm bài; (2) không hiển thị bảng đáp án (false) đảm bào đề tạo ra không có bản đáp án.
- theo-lv: có chức năng: (1) xếp câu hỏi thức mức độ từ NB -> TH -> VD khi dùng chức năng true; (2) xếp câu hỏi ngẫu nhiên để  tạo đề khi dùng chức năng false.
- xao-cau: cho phép cố định câu không đổi vị trí câu ở các đề (false), đảo vị trí ở các đề (true)
- xao-pa: cho phép cố định phương án ABCD hoặc ý abcd ở các đề (false), đảo vị trí phương án ở các đề (true)
#### c) chức năng trộn đề ý hoặc phương án(`make-exam-sub-only` / `tron_de_chiY`)
Cách thực hiện đuề giống với "Trộn đề cùng nội dung" chỉ khác ở mục thực hiện trộn đề khi gọi lệnh:
```typst
Cách 1:
#make-exam-sub-only(matrix, info-de, seed-goc: 2024, show-lg: false,tf-mode:"y-only",nlc-mode:"none",theo-lv:false)

Cách 2:
#tron-de-chiY(matrix, info, seed-goc: 2024, show-lg: false,tf-mode:"y-only",nlc-mode:"none",theo-lv:false)
```
Giải thích:
- tf-mode: có hai chế độ "y-only" đảo ý và "full" đảo ý và đảo câu.
- nlc-mode: có 3 chế độ:  "y-only" đảo phương án; "full" đảo phương án và đảo câu; "none" không thay đổi.
---

## 📜 Giấy phép

Phát hành theo giấy phép [MIT License](LICENSE).
