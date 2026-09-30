# Bộ mẫu copy-ready cho sang-math 1.1.0

Các file trong `copy-ready/` là mẫu API cũ dùng bản 1.0.2 đã phát hành trên Typst Universe. Giáo viên
có thể tải một file, đổi phần **CẤU HÌNH NHANH**, thay nội dung câu hỏi và biên
dịch ngay trên Typst.app, VS Code hoặc TypstConicHub.

| File | Dùng khi |
|---|---|
| `01-de-15-phut.typ` | Bài kiểm tra ngắn, 4 TN + 2 TLN |
| `02-de-giua-ky-hon-hop.typ` | Đề có đủ TN, Đ/S, TLN và tự luận |
| `03-de-thpt-12-4-6.typ` | Khung chuẩn 12 TN + 4 Đ/S + 6 TLN |
| `04-de-tu-luan-co-nhap.typ` | Đề tự luận có dòng trống/vùng nháp |
| `05-phieu-hoc-tap-chuyen-de.typ` | Chuyên đề, lý thuyết, ví dụ và bài tập |
| `06-de-co-bbt-va-hinh-cetz.typ` | Câu có bảng biến thiên và hình vector CeTZ |
| `07-de-70-30-nhap-in-hai-mat.typ` | Đề in hai mặt: 70% nội dung, 30% nháp đổi bên chẵn/lẻ |

## Ví dụ trộn đề và phiếu OMR 1.1

[`exam-variant-omr.typ`](exam-variant-omr.typ) ghép ma trận 12–4–6, đề học sinh, QR đáp án giáo viên và phiếu ngang nhận `state("sbd")`/`state("made")`. Tám preset OMR nằm trong [`omr/`](omr/) để ví dụ tự biên dịch từ thư mục gói. Biên dịch với Typst 0.15.1 từ thư mục gốc của gói:

```bash
typst compile --root . examples/exam-variant-omr.typ
```

## Đổi đề học sinh sang bản lời giải

Trong mỗi file đề, sửa:

```typ
#let profile = "dethi"
```

thành:

```typ
#let profile = "loigiai"
```

Hoặc giữ nguyên file và biên dịch bằng input:

```bash
typst compile --input profile=loigiai ten-file.typ
```

## Dùng AI tạo nội dung

Sao chép prompt tại
[`../PROMPT_AI_TAO_DE.md`](../PROMPT_AI_TAO_DE.md), điền chủ đề, mức độ và cấu
trúc mong muốn. Yêu cầu AI chỉ thay vùng câu hỏi, giữ nguyên khối cấu hình đã
biên dịch tốt.
