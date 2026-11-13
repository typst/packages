# Changelog

## 1.1.2

- Sửa căn nhãn `a), b), c), d)` trong câu Đúng/Sai dạng danh sách (`ds-style: "list"`, `"modern"`, `"minimal"`): dùng `par(hanging-indent: ...)` để nhãn luôn bám đúng baseline dòng đầu ngay cả khi mệnh đề bắt đầu bằng phân số cao (`math.display`).
- Sửa khoảng cách giữa câu dẫn và phần phương án/ô đáp số trong `tf`/`ds` và `short`/`tln` ở chế độ `dethi`: đặt `set par(spacing: 0.45em); set block(spacing: 0.45em)` bao đúng phạm vi câu hỏi và dùng `#v(..., weak: true)` để không bị cộng dồn khoảng cách đoạn, đồng thời giữ khoảng đệm đều khi câu dẫn có hình vẽ CeTZ.
- Bổ sung tham số `option-leading` và `row-gutter` cho `tf`/`ds` để đồng bộ với `mcq`/`tn`.
- Hỗ trợ thêm tên tham số `sol:` (bên cạnh `loigiai:` và `solution:`) trong `tn`, `ds`, `tln`, `tl` và tham số `margin: auto` trong `thpt-school-exam`.
- Bổ sung định dạng cận dưới inline (`math.limits(..., inline: true)`) cho `max` và `min` trong `math-sym.typ` tương tự `lim`.

## 1.1.1

- Thu gọn gói: mỗi cặp phiếu A4/A5 dùng chung một file bố cục (`omr/layouts/*.typ`, tham số `paper`), 13 file thay cho 24; `omr/profiles.json` chỉ giữ trường mà `sang-omr-*` đọc (hơn 590 KB xuống vài KB). Đầu ra của 24 phiếu giữ nguyên từng byte SVG.
- Thêm `sang-typst` (chỉ chạy khi bật `#show: sang-typst`): dấu phẩy thập phân không giãn như `icomma`, `$0.5$` in ra 0,5, nhóm chữ số, ⩽ ⩾, ba preset `chuan`/`latex`/`times` (font Latin Modern hoặc Times + STIX Two Math), khoảng cách dòng đều, đánh số chỉ phương trình có nhãn. Kèm `num`, `qty`, `tg`, `cotg`, `arctg`, `arccotg`, `cung`, `goc`, `sfrac`. Không bật thì đầu ra giữ nguyên như 1.1.1.
- `vec` nhiều tham số trả về vectơ cột gốc của Typst (`vec(1, 2, 3)` trước đây báo lỗi); `vec(x)` một tham số vẫn là vectơ mũi tên.
- Gỡ khối `step`/`reset-step`/`configure-step-reveal` bị định nghĩa lặp trong `sang-exam.typ` (hai bản giống hệt, dùng chung bộ đếm; không đổi hành vi).
- Ghi chú `int` (ký hiệu ∫) che kiểu số nguyên trong code: dùng `std.int(...)`.

- Giãn dòng theo biên chữ/công thức thực trong câu hỏi và lời giải; giữ phân số/hệ lớn, căn nhãn phương án theo hàng, tránh đè phân số lồng. Đề thi dùng khoảng cách tường minh và giữ câu/phương án cùng trang; thêm các tùy chọn khoảng cách tương thích cú pháp cũ.

- Thêm 24 cấu hình phiếu A5 ngang/A4 dọc; giữ API soạn đề 1.1.0/1.0.6.
- `sang-omr-sheet` đọc SBD/mã đề tại vị trí hiện tại từ `state("sbd")` / `state("made")`, ghi số và tô đúng ô; SBD ngắn là tiền tố giữ ở các cột đầu, cột cuối để học sinh tự điền. Mã đề ngắn được đệm số 0.
- Sửa cả tám file include 1.1.0: SBD `1001` điền/tô bốn cột đầu, để hai cột cuối trống; không đổi thành `001001`.
- Phiếu A5 ghép vào đề A4 không thay khổ trang hay định dạng của đề; tọa độ ô và 12 mốc giữ nguyên kho phiếu trên web.
- `sang-omr-profile` / `sang-omr-qr` nhận ID của 24 mẫu mới; mô tả khổ giấy và số câu/cột nằm trong `omr/profiles.json`.

## 1.1.0

- Dùng Typst 0.15.0 trở lên để hỗ trợ Touying 0.8.0; cú pháp câu hỏi 1.0.6 được giữ nguyên.
- Giữ nguyên toàn bộ API và cách soạn câu của bản 1.0.6.
- Bổ sung tám phiếu OMR trong `examples/omr/`; `state("sbd")` và `state("made")` có thể tô sẵn trước khi `#include`.
- `sang-omr-qr` nhận tùy chọn `profile:` để khớp QR đáp án với đúng phiếu, kiểm số câu và tự chọn khổ giấy. Khi không truyền profile, hành vi 1.0.6 được giữ nguyên.
- Mã hóa các ký tự đặc biệt trong JSON của QR đáp án; thêm `sang-omr-profile` để tra cấu hình phiếu.
