# Changelog

Các thay đổi đáng chú ý của `sang-math` được ghi tại đây. Gói tuân theo Semantic Versioning; nhánh `1.0.x` không được xóa hoặc đổi chữ ký API public đã phát hành.

## 1.1.0 — chuẩn bị phát hành

### Added

- `bank-mode()` cho phép soạn ngân hàng bằng chính tên và thứ tự tham số `tn/ds/tln/tl`; một mã `bank.json` tự điền lớp, chương, chủ đề mã và độ khó. Nhiều câu cùng mã phân loại được trộn/cân bằng riêng theo vị trí trong bank. Bộ lọc và blueprint nhận `id-prefix`.
- Unified Question Model cho MCQ, đúng/sai, trả lời ngắn và tự luận; metadata học tập tùy chọn, đáp án có kiểu và lời giải nhiều bước.
- `validate-question` với thông báo lỗi theo ID câu hỏi; chế độ kiểm tra nghiêm cho API mới và tương thích cho API cũ.
- `render-question` với các chế độ học sinh, giáo viên, lời giải và đáp án.
- `question-bank`, `bank-filter`, `bank-select` và `bank-shuffle-choices` với seed xác định.
- `exam-variant`/`exam-variants`: ma trận chỉ tiêu từng phần, chọn không lặp, cân bằng mức sử dụng câu giữa nhiều mã đề và trộn đáp án trắc nghiệm có cập nhật đáp án đúng.
- `render-exam-variant` và QR đáp án `exam-variant-qr` đọc trực tiếp từng biến thể; tám mẫu phiếu OMR chuẩn nhận `state("sbd")`/`state("made")` khi `#include`.
- Semantic theme tokens nội bộ, tài liệu chuyển đổi và bài kiểm thử hồi quy câu hỏi/OMR.
- Các module sách Đề cương và ma trận Logic từ nhánh phát triển nội bộ được đưa vào bản phát hành 1.1.0.
- Giữ các namespace `book`, `beamer` và những export hình học/OMR của gói 1.0.6 đã xuất bản.
- Nâng Touying lên 0.8.0 cho beamer; yêu cầu Typst tối thiểu 0.15.0.

### Changed

- `tn`/`mcq`, `ds`/`tf`, `tln`/`short` và `tl` chuẩn hóa dữ liệu trước khi dùng renderer legacy; giữ nguyên chữ ký và hành vi hiển thị.
- Sửa ví dụ `exam-template-demo.typ` dùng `overrightarrow` vì `vec` được export bởi hình học 3D và đã khiến ví dụ 1.0.6 không biên dịch.

### Compatibility

- Tài liệu 1.0.6 hợp lệ không cần đổi source khi nâng Typst lên 0.15.x. Với Typst 0.14.x, tiếp tục dùng sang-math 1.0.6.
- Chưa phát hành lên Typst Universe; thay đổi phiên bản chỉ là bước chuẩn bị release.

## Phần phát triển nội bộ sau 1.0.6, đưa vào 1.1.0

Các chức năng bên dưới có trong nhánh phát triển ConicTypst nhưng chưa có trong
gói `sang-math:1.0.6` đã xuất bản trên Typst Universe.

### Hệ thống Sách Toàn năng & Đề Cương (`decuong-book.typ`)

- **`#show: decuong-book.with(...)`**: Template sách Đề cương / Tài liệu học tập THPT chuẩn hoá toàn diện:
  - Hỗ trợ tham số linh hoạt tiếng Việt & tiếng Anh (`title`/`tieu-de`, `author`/`to-bomon`, `school`/`truong`, `subject`/`mon`, `year`/`nam-hoc`).
  - Tự động chuyển đổi chế độ thông minh qua `mode: "dethi"` vs `mode: "loigiai"`:
    - `"dethi"`: Bản sách bài tập cho học sinh, bài tập trắc nghiệm hiển thị bố cục 2 cột (câu hỏi bên trái, ô chấm `_Bài làm:_` bên phải) tiết kiệm giấy tối đa; tự động ẩn toàn bộ lời giải chi tiết.
    - `"loigiai"`: Bản sách hướng dẫn giải chi tiết cho giáo viên, bố cục 1 cột thoáng đãng, sắc nét; tự động hiển thị đầy đủ các khối lời giải (`loigiai`).
  - Tự động sinh trang bìa nghệ thuật chuẩn nhận diện thương hiệu và mục lục 3 cấp với phong cách chuyên nghiệp.
- **`#show: chuyende-book.with(...)`**: Mẫu sách chuyên đề chuyên sâu, bồi dưỡng học sinh giỏi, biên soạn SGK.
- **`#show: dethi-book.with(...)`**: Mẫu sách tuyển tập bộ đề thi thử tốt nghiệp THPT chuẩn BGD 2025.
- **Hệ thống phân cấp bài giảng & bài tập chuẩn mực**:
  - `#chuong(ten, mau: C1)`: Phân chia chương kèm huy hiệu số chương hình tròn và dải màu gradient.
  - `#bai(ten, mau: C1)`: Phân bài học kèm badge `[BÀI X]` và thanh gạch chân màu chủ đề.
  - `#dang(ten, mau: C1)`: Banner dạng toán tự động tăng bộ đếm dạng.
  - `#phuong-phap[...]`: Khung phương pháp giải màu pastel nhẹ nhàng.
  - `#ly-thuyet[...]`: Khung lý thuyết cần nhớ viền trái đậm.
  - `#bai-tap-tu-luan[...]` & `#bai-tap-trac-nghiem()`: Khung bài tập tự luận và trắc nghiệm.
  - `#bt-item(num, stem, loigiai: ...)`: Bài tập tự luận tự động hiển thị/ẩn lời giải theo `mode`.
- **Hỗ trợ Ma trận Suy luận Logic & Bảng nâng cao**:
  - `#co`, `#yes` ($bold(text("✔ Có"))$) và `#khong`, `#no` ($bold(text("✘ Không"))$).
  - `#logic-check` ($bold(text("✔"))$) và `#logic-cross` ($bold(text("✘"))$).
  - `#matrix-table(...)`: Bảng ma trận logic với hàng tiêu đề và cột định danh nổi bật.
- **Bảng màu chủ đề 5 Chương chuẩn mực**: `C1`, `C2`, `C3`, `C4`, `C5`, `gold`, `ok`, `warn`.
- **Độ co giãn BBT/BXD (`my-bxd`, `my-bbbt`)**: Tự động nhận diện số cột và thu phóng phù hợp với chế độ in 2 cột hoặc 1 cột.

## 1.0.6 — 2026-09-21 (Typst Universe)

- Bản public làm mốc tương thích cho 1.1.0; xem [PR #5890](https://github.com/typst/packages/pull/5890).
- Bao gồm namespace `book`, `beamer`, QR OMR và các hàm khối tròn xoay/đường cong 3D.

## 1.0.5 — 2026-09-09


### Đề thi & Khung câu hỏi (`sang-exam.typ`)

- Sửa lỗi hàm `exam-mode` không chuyển tiếp đầy đủ tham số: hỗ trợ `..args` và `params`
  pass-through, giúp các cấu hình nâng cao (`opt-style: "circle"`, `prefix: "Bài"`, `box-inset`...)
  truyền thông suốt xuống các hàm con `#tn`, `#ds`.

### Ký hiệu toán & đa môn (`math-sym.typ`)

- Chuẩn hóa `lim`: dùng `math.limits(math.lim, inline: true)` để cận dưới giới hạn hiển thị chuẩn toán học Việt Nam.
- Bổ sung ký hiệu tiện ích cho Đa môn (Vật lí, Hóa học):
  - `#doC`, `#celsius`: Độ Celsius ($degree C$).
  - `#ohm`: Đơn vị điện trở Ohm ($Omega$).
  - `#pu-tn`: Mũi tên phản ứng thuận nghịch ($<=>$).
  - `#pu-nhiet`: Mũi tên phản ứng có điều kiện nhiệt độ ($->^(t^compose)$).

### Tài liệu & AI

- Cập nhật hướng dẫn sử dụng và System Prompt mẫu cho AI tạo đề Đa môn (Toán, Lý, Hóa) theo chuẩn BGD 2025.

## 1.0.4 — 2026-07-26

### Câu đúng/sai

- Sửa `use-table: false` để `#ds`/`#tf` thực sự hiển thị dạng danh sách thay vì
  luôn render bảng.
- Kích hoạt `ds-style` với các kiểu `"list"`, `"pill"`, `"modern"`,
  `"minimal"`, `"bookmark"`, `"folder"`, `"diamond"`, `"gradient"` và
  `"checklist"`.
- Giữ mặc định `"table"` để tài liệu dùng `1.0.3` không đổi bố cục khi nâng cấp.
- Giữ tương thích với cú pháp cũ `table: false`.

### Kiểm thử

- Thêm bài compile bao phủ bảng mặc định, hai alias không bảng và toàn bộ chín
  kiểu danh sách ở chế độ lời giải.

## 1.0.3 — 2026-07-23

### Tính năng mới — `bbt.typ`

- **`node-pad`** (mặc định `0.18`): Điều chỉnh khoảng trắng xung quanh nhãn giá trị trên bảng biến thiên. Áp dụng cho cả `bbtv2` và `bbbt`.
- **`arr-shorten`** (mặc định `3pt`): Khoảng lùi đầu mũi tên khỏi nhãn, tránh mũi tên đè số. Áp dụng cho cả `bbtv2` và `bbbt`.
- **`tab-val`**: Macro helper kiểu `\tkzTabVal` (LaTeX tkz-tab) — vẽ đường chấm dứt đoạn từ hàng $x$ xuống hàng $y$ tại vị trí tuỳ chọn (`from-col`, `to-col`, `pos`, `x-lab`, `y-lab`).
- **`annotations`**: Tham số mảng trong `bbtv2` cho phép thêm nhiều `tab-val` cùng lúc, thay thế `guides`.
- **`overlay`**: Tham số nhận hàm CeTZ closure, vẽ tuỳ ý lên canvas sau khi bảng đã hoàn chỉnh.

### Cải tiến

- Mũi tên biến thiên không còn đè vào số giá trị; mặc định mới hài hoà với mọi cỡ font.
- Tính tái sử dụng cao: tất cả khoảng cách mũi tên / nhãn đều có thể override từng lần gọi.

## 1.0.2 — 2026-07-17

### Sửa lỗi

- Không còn ép toàn bộ `math.equation` nội dòng sang display style.
- Chỉ áp dụng display style cho `math.frac`, để Typst giữ baseline tự nhiên của dòng chữ.
- Loại bỏ dò cấu trúc toán bằng `repr()` và phần bù chiều cao `box(inset: ...)` không ổn định.
- Đồng bộ cách xử lý phân số giữa `sang-setup`, template đề thi, template sách và bản submit.
- Dùng `tfrac` khi cần phân số nhỏ trong số mũ, chỉ số hoặc cận tích phân.
- Thêm `layout-draft` cho đề 70/30: vùng nháp 30% tự đổi từ phải ở trang lẻ sang trái ở trang chẵn khi in hai mặt.
- Thêm `layout-2col-draft`, mẫu copy-ready và kiểm thử compile cho layout nháp đối xứng.

### Kiểm thử

- Thêm kiểm thử baseline cho phân số lớn trong văn bản và trong cột hẹp.
- Thêm kiểm thử tương ứng cho bản package submit.
- Thêm kiểm thử compile hai trang chẵn/lẻ cho `layout-draft`.

## 1.0.1 — 2026

### Sửa lỗi

- Giữ đầy đủ API public của 1.0.0, gồm template đề/sách, tiện ích core và hình học CeTZ nâng cao.
- Khôi phục đúng hệ thống theme câu hỏi, nhãn đáp án, tag, khung nháp và các tham số của `exam-mode`.
- Căn nhãn A/B/C/D ổn định khi phương án bắt đầu bằng số mũ hoặc phân số cao.
- Thu nhỏ `tfrac` và `tfrac-tex` đúng vai trò phân số inline.
- Bổ sung cơ chế hiển thị phân số lớn; cơ chế này được sửa lại ở 1.0.2 để không ảnh hưởng baseline.
- Khai báo đúng Typst tối thiểu 0.14.0 theo yêu cầu của `cetz 0.5.2`.

### Kiểm thử

- Thêm kiểm thử compile cho hợp đồng API public, bố cục phân số, baseline phương án và mẫu nộp bài.
- Kiểm tra lại demo đề thi, demo sách và tài liệu HDSD đầy đủ.

## 1.0.0 — 2026

- Phiên bản public đầu tiên trên Typst Universe.
