# Changelog

## 1.1.0

- Dùng Typst 0.15.0 trở lên để hỗ trợ Touying 0.8.0; cú pháp câu hỏi 1.0.6 được giữ nguyên.
- Giữ nguyên toàn bộ API và cách soạn câu của bản 1.0.6.
- Bổ sung tám phiếu OMR trong `examples/omr/`; `state("sbd")` và `state("made")` có thể tô sẵn trước khi `#include`.
- `sang-omr-qr` nhận tùy chọn `profile:` để khớp QR đáp án với đúng phiếu, kiểm số câu và tự chọn khổ giấy. Khi không truyền profile, hành vi 1.0.6 được giữ nguyên.
- Mã hóa các ký tự đặc biệt trong JSON của QR đáp án; thêm `sang-omr-profile` để tra cấu hình phiếu.
