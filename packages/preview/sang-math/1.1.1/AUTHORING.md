# Mẫu chuẩn soạn đề

Dùng [examples/canonical-exam.typ](examples/canonical-exam.typ). Một import `@preview/sang-math:1.1.1` cung cấp phần soạn đề, het, bảng đáp án, QR và phiếu mới. Không khai báo lại True/False/tn/ds/tln/tl/het hoặc import một engine soạn đề local. Không import thư viện hình nếu đề không dùng hình; thư viện sm-* riêng của dự án không nằm trong API hình học legacy của gói này.

TN: bốn phương án, đúng một `True(...)`. Đ/S: bốn ý, chỉ bọc ý đúng bằng `True(...)`, ý sai để `[ ... ]`. TLN: đáp án chuỗi ở đối số thứ hai (`"-1,5"`), không dùng `ans:`. Tự luận: câu dẫn + tham số tên `lines`/`loigiai`. Lời giải dùng `step`, ID ổn định, chia phần bằng `exam-part(..., count: ..., reset-counter: true)`, kết thúc bằng `het`. Giữ phân số/hệ cỡ display; không viết lại engine trong file đề.

Cấu hình đầu file gồm mode, mã đề, trường, tiêu đề, môn, thời gian, màu, bảng đáp án, QR, ID/khổ phiếu, bật phiếu và tiền tố SBD. Mẫu này có 12 TN / 2 ĐS / 4 TLN. Khi đổi nội dung/phiếu phải đổi count và ID đúng cấu trúc; QR có kiểm tra profile. SBD `1001` là bốn cột đầu, hai cột sau học sinh điền; không đổi thành `001001`.

```sh
typst compile canonical-exam.typ de.pdf
typst compile --input sheet=1 --input sbd=1001 canonical-exam.typ de-co-phieu.pdf
typst compile --input mode=loigiai --input qr=1 canonical-exam.typ loi-giai-va-qr.pdf
typst query canonical-exam.typ '<sang-math-answer-key>' --field value --one > dap-an.json
```

Mặc định đề học sinh không có bảng/QR đáp án. Bảng đáp án hiện tự động ở chế độ giáo viên hoặc khi bật answer-table=1. JSON là metadata của mẫu lấy từ state câu hỏi, không phải một macro ghi file JSON. Không tạo bảng khóa thủ công riêng: bảng in, QR và JSON phải trùng nhau. Mỗi khi sửa True hay đáp án TLN, mọi đầu ra tự cập nhật khi biên dịch lại.

Bản 1.0.6 vẫn đủ API soạn đề và QR 12–4–6, nhưng không hỗ trợ tham số profile của QR hay renderer phiếu mới; không ghép API mới vào đề import 1.0.6. Kiểm chứng cả dethi/loigiai, QR/JSON và PDF trước khi giao. Không tự thay câu đúng hoặc bịa khóa cho câu lỗi nguồn.
