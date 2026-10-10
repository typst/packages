# Changelog

## 1.1.1

- Giãn dòng theo biên chữ/công thức thực trong câu hỏi và lời giải; giữ phân số/hệ lớn, căn nhãn phương án theo hàng, tránh đè phân số lồng. Đề thi dùng khoảng cách tường minh và giữ câu/phương án cùng trang; thêm các tùy chọn khoảng cách tương thích cú pháp cũ.

- Thêm 24 cấu hình phiếu A5 ngang/A4 dọc; giữ API soạn đề 1.1.0/1.0.6.
- `sang-omr-sheet` đọc SBD/mã đề tại vị trí hiện tại từ `state("sbd")` / `state("made")`, ghi số và tô đúng ô; SBD ngắn là tiền tố giữ ở các cột đầu, cột cuối để học sinh tự điền. Mã đề ngắn được đệm số 0.
- Sửa cả tám file include 1.1.0: SBD `1001` điền/tô bốn cột đầu, để hai cột cuối trống; không đổi thành `001001`.
- Phiếu A5 ghép vào đề A4 không thay khổ trang hay định dạng của đề; tọa độ ô và 12 mốc giữ nguyên kho phiếu trên web.
- `sang-omr-profile` / `sang-omr-qr` nhận ID của 24 mẫu mới; kèm schema/tọa độ đo từ bản in trong `omr/profiles.json`.

## 1.1.0

- Dùng Typst 0.15.0 trở lên để hỗ trợ Touying 0.8.0; cú pháp câu hỏi 1.0.6 được giữ nguyên.
- Giữ nguyên toàn bộ API và cách soạn câu của bản 1.0.6.
- Bổ sung tám phiếu OMR trong `examples/omr/`; `state("sbd")` và `state("made")` có thể tô sẵn trước khi `#include`.
- `sang-omr-qr` nhận tùy chọn `profile:` để khớp QR đáp án với đúng phiếu, kiểm số câu và tự chọn khổ giấy. Khi không truyền profile, hành vi 1.0.6 được giữ nguyên.
- Mã hóa các ký tự đặc biệt trong JSON của QR đáp án; thêm `sang-omr-profile` để tra cấu hình phiếu.
