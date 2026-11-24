# Ví dụ QR và phiếu OMR

- [`qr-12-4-6.typ`](qr-12-4-6.typ): đề gõ bằng `#tn/#ds/#tln`, QR đáp án cho giáo viên và phiếu 12–4–6 nhận state SBD/mã đề.
- [`omr/state-example.typ`](omr/state-example.typ): chỉ in phiếu 12–4–6 có SBD/mã đề tô sẵn.
- `omr/` chứa tám preset có thể tải/copy để dùng với `#include`.

Biên dịch từ checkout `typst/packages`:

```bash
typst compile --root . --package-path packages packages/preview/sang-math/1.1.0/examples/qr-12-4-6.typ /tmp/qr-12-4-6.pdf
```
