# Ví dụ QR và phiếu OMR

- [qr-12-2-4.typ](qr-12-2-4.typ): đề 12 TN, 2 Đ/S, 4 TLN, QR đáp án và phiếu A5 ghép trong đề A4.
- [omr/new-state-example.typ](omr/new-state-example.typ): `state("sbd").update("1001")` ghi/tô bốn cột đầu, hai cột cuối để học sinh điền.
- [omr/12-2-4.typ](omr/12-2-4.typ): file include A5, không thay khổ trang của đề.
- [Thư viện 24 mẫu mới](../omr/README.md): danh sách ID, khổ giấy và file in riêng.
- [qr-12-4-6.typ](qr-12-4-6.typ), [omr/state-example.typ](omr/state-example.typ): cách dùng phiếu 12–4–6 cũ; SBD ngắn cũng là tiền tố ở các cột đầu.

Biên dịch từ checkout `typst/packages` bằng Typst 0.15.0 trở lên:

```bash
typst compile --root . --package-path packages packages/preview/sang-math/1.1.1/examples/qr-12-2-4.typ /tmp/qr-12-2-4.pdf
```
