# sang-math

Bộ macro Typst dành cho Toán THPT Việt Nam: đề thi bốn dạng câu hỏi, sách/chuyên đề, bảng biến thiên, bảng xét dấu và hình học CeTZ.

- Hướng dẫn trực tuyến: https://hdsd-conictypst.pages.dev
- Mã nguồn: https://github.com/sangnhc87/conictypst
- Yêu cầu bản 1.1: Typst 0.15.0 trở lên (do `touying 0.8.0`); đã thử trên 0.15.1.

Bản 1.1.1 giữ nguyên cách soạn đề của 1.0.6 và API 1.1.0; bổ sung thư viện 24 mẫu OMR A5/A4, điền SBD/mã đề bằng state và ghép phiếu vào đề. Xem [thư viện phiếu và cách sử dụng](omr/README.md).

## Cài đặt

```typ
#import "@preview/sang-math:1.1.1": *
```

Khi chỉ dùng một nhóm chức năng, nên import đúng tên cần dùng để file dễ đọc và API rõ ràng:

```typ
#import "@preview/sang-math:1.1.1": tn, ds, tln, tl, True, sang-setup
```

## API chính

| Nhóm | Macro tiêu biểu |
|---|---|
| Đề thi | `tn`, `ds`, `tln`, `tl`, `exam-mode`, `exam-part`, `print-answer-key` |
| QR và phiếu tô | `sang-omr-sheet`, `sang-omr-catalog`, `sang-omr-qr`, `sang-omr-profile`, 24 mẫu mới và tám mẫu cũ |
| Giao diện đề | `exam-theme`, `exam-preset`, `exam-input-preset`, `exam-template-names` |
| Sách/chuyên đề | `book-theme`, `book-chapter`, `book-lesson`, các hộp sư phạm, `book-template-names` |
| Layout in hai mặt | `layout-draft`, `layout-2col-draft` — nội dung 70%, nháp 30% đổi bên chẵn/lẻ |
| Bảng Toán | `bbtv2`, `bbbt`, `bxd`, `bang-gia-tri`, `bang-phan-phoi`, `auto-bbt` |
| Hình học cơ bản | `tri-abc`, `tri-right`, `chop-sabc`, `circle-desc`, `axis-xy`, `plot` |
| Conic | `draw-parabola`, `draw-ellipse`, `draw-hyperbola` |
| Khối tròn xoay | `draw-cylinder`, `draw-cone`, `draw-sphere` |
| Đường cong 3D | `draw-helix`, `draw-spring` |
| Ký hiệu | `RR`, `ZZ`, `NN`, `QQ`, `Rightarrow`, `Leftrightarrow`, `vect`... |

`lib.typ` là cổng public duy nhất và hiện đã export cả template đề, template sách cùng các module CeTZ nâng cao. Người dùng không cần import đường dẫn nội bộ.

## Câu đúng/sai dạng bảng hoặc danh sách

Mặc định `#ds` vẫn dùng bảng Đ/S như các phiên bản trước. Từ `1.0.4`, có thể
chuyển nhanh sang danh sách bằng `use-table: false`:

```typ
#ds(
  [Xét các phát biểu sau.],
  (True([Mệnh đề đúng.]), [Mệnh đề sai.]),
  use-table: false,
)
```

Để chọn giao diện danh sách, dùng `ds-style` với một trong các giá trị:
`"list"`, `"pill"`, `"modern"`, `"minimal"`, `"bookmark"`, `"folder"`,
`"diamond"`, `"gradient"` hoặc `"checklist"`.

```typ
#ds(
  [Xét các phát biểu sau.],
  (True([Mệnh đề đúng.]), [Mệnh đề sai.]),
  ds-style: "bookmark",
)
```

`use-table: false` tương đương `ds-style: "list"`. Cú pháp cũ
`table: false` cũng được giữ để tương thích với các ví dụ đã lưu.

## Ví dụ đề thi

```typ
#import "@preview/sang-math:1.1.1": *

#let preset = exam-preset(
  theme: "teal-pro",
  profile: "dethi", // dethi | loigiai | compact | draft | beamer
)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: preset.accent)
#show: exam-theme.with(
  theme: preset.theme,
  school: "TRƯỜNG THPT SANG-MATH",
  exam-title: "ĐỀ THI THỬ TỐT NGHIỆP THPT",
  subject: "TOÁN 12",
  duration: "90 phút",
  code: "101",
  ..preset.template,
)

#tn(
  [Đạo hàm của $f(x)=x^3-3x+1$ tại $x=2$ bằng],
  ([$3$], True([$9$]), [$6$], [$-3$]),
  loigiai: [$f'(2)=3 dot 2^2-3=9$.],
)
```

## Bộ mẫu để copy và sửa

Thư mục [`examples/copy-ready`](https://github.com/sangnhc87/conictypst/tree/14b296889533c8b1897e5bebbfec499de7c5a932/typst-pkg-sang-math/examples/copy-ready) có các mẫu chạy sẵn cho
đề 15 phút, giữa kỳ hỗn hợp, cấu trúc THPT 12–4–6, đề tự luận có nháp, phiếu học
tập và câu có bảng biến thiên/CeTZ. Xem bảng chọn mẫu tại
[`examples/README.md`](https://github.com/sangnhc87/conictypst/blob/14b296889533c8b1897e5bebbfec499de7c5a932/typst-pkg-sang-math/examples/README.md).

Giáo viên dùng AI/OCR để tạo hoặc chuyển đề có thể sao chép bộ hướng dẫn tại
[`PROMPT_AI_TAO_DE.md`](https://github.com/sangnhc87/conictypst/blob/14b296889533c8b1897e5bebbfec499de7c5a932/typst-pkg-sang-math/PROMPT_AI_TAO_DE.md). Prompt quy định đúng chữ ký
`tn/ds/tln/tl`, ID ổn định, cú pháp toán Typst và bước tự kiểm tra đáp án.

Các theme đề có thể lấy trực tiếp bằng `exam-template-names`; hiện gồm `classic`, `ocean`, `emerald`, `royal`, `violet`, `crimson`, `graphite`, `amber`, `teal-pro`, `sky`, `indigo-minimal`, `print-economy`, `aurora`, `lotus`, `navy-gold`, `jade`, `coral`, `plum`.

## Ví dụ sách/chuyên đề

```typ
#import "@preview/sang-math:1.1.1": *

#show: book-theme.with(
  theme: "sgk-modern",
  title: "CHUYÊN ĐỀ HÀM SỐ",
  author: "Tổ Toán",
)

#book-chapter([Ứng dụng đạo hàm], number: 1)
#book-lesson([Tính đơn điệu của hàm số], number: 1)

#theory-box[Hàm số đồng biến trên khoảng $K$ khi...]
#example-box[Khảo sát tính đơn điệu của $f(x)=x^3-3x$.]
#practice-box[Giải các bài tập tương tự.]
```

Danh sách giao diện sách có sẵn nằm trong `book-template-names`.


## QR Đáp án OMR (Chấm bài tự động qua Sang Math OMR)

Từ phiên bản `1.0.6`, `sang-math` bổ sung hàm `sang-omr-qr` tự động đọc dữ liệu đáp án của đề thi (`tn`, `ds`, `tln`) và tạo mã QR nạp key cho ứng dụng chấm bài trực tiếp:

```typ
#import "@preview/sang-math:1.1.1": *

#make-questions()

#if in-qr-dap-an [
  #pagebreak()
  #align(center)[
    #text(weight: "bold", size: 15pt, fill: accent)[QR ĐÁP ÁN OMR - BẢN GIÁO VIÊN]
    #v(0.5em)
    #text(size: 10pt)[Mã đề #ma-de. Mở Sang Math OMR, chọn “Quét QR trực tiếp” để nạp key và chấm bài.]
    #v(1em)
    #sang-omr-qr(ma-de: ma-de)
  ]
]

#print-answer-key()
```

### Nâng cấp QR và phiếu ở 1.1.1

Giữ nguyên các câu `#tn/#ds/#tln/#tl`. QR `SMKEY` đọc đáp án từ các câu đã in, dùng cho giáo viên nạp đáp án vào Sang Math OMR. Phiếu có QR `SMOMR` riêng để nhận dạng bố cục; mã này không chứa đáp án.

```typ
#let ma-de = "0101"
// ... các câu #tn(...), #ds(...), #tln(...) như 1.0.6 ...
#sang-omr-qr(ma-de: ma-de, profile: "12-4-6ngang")

#pagebreak()
#state("sbd").update("1001")
#state("made").update(ma-de)
#include "omr/12-4-6ngang.typ"
```

Đoạn trên cần file phiếu ở `examples/omr/` đặt cạnh file đề theo đúng đường dẫn `#include`. Xem [ví dụ đầy đủ biên dịch được](examples/qr-12-4-6.typ), không cần viết phần `...` khi dùng. `1001` in/tô bốn cột đầu SBD, để hai cột cuối trống cho học sinh; mã đề được đệm đủ bốn chữ số. Không đặt state thì các ô SBD/mã đề để trống.

`profile:` là tùy chọn. Khi ghi tên phiếu, hàm QR kiểm số câu TN/ĐS/TLN đúng với phiếu và tự chọn khổ giấy. Bỏ `profile:` thì cách tạo QR của 1.0.6 được giữ nguyên. Các profile có sẵn:

| Profile | TN | Đ/S | TLN | Khổ |
|---|---:|---:|---:|---|
| `12-4-6ngang` | 12 | 4 | 6 | A5 ngang |
| `thptqg-toan-2025` | 12 | 4 | 6 | A4 |
| `ds-12` | 0 | 12 | 0 | A4 |
| `hybrid-28tn-12ds` | 28 | 12 | 0 | A4 |
| `tln-10` | 0 | 0 | 10 | A4 |
| `tn-40` / `tn-50` / `tn-60` | 40 / 50 / 60 | 0 | 0 | A4 |

Tên, số câu và khổ của từng phiếu có thể xem bằng `sang-omr-profile("tn-40")`. Nội dung TLN có dấu nháy, gạch chéo hoặc xuống dòng được mã hóa đúng trong JSON của QR.

## Bảng biến thiên

```typ
#import "@preview/sang-math:1.1.1": bbtv2

#bbtv2(
  x-vals: ($-oo$, $-1$, $1$, $+oo$),
  d-signs: ("+", 0, "-", 0, "+"),
  v-vals: ($-oo$, $3$, $-1$, $+oo$),
)
```

## Đề 70/30 có nháp khi in hai mặt

```typ
#import "@preview/sang-math:1.1.1": layout-draft

#show: layout-draft.with(
  nháp-pct: 30%,
  accent: rgb("#117a65"),
)

Nội dung đề thi...
```

Trang lẻ đặt vùng nháp bên phải, trang chẵn đặt vùng nháp bên trái. Lề nội dung
dùng cơ chế `inside`/`outside` nên tự đảo đúng khi in hai mặt. Mẫu đầy đủ nằm tại
[`examples/copy-ready/07-de-70-30-nhap-in-hai-mat.typ`](https://github.com/sangnhc87/conictypst/blob/14b296889533c8b1897e5bebbfec499de7c5a932/typst-pkg-sang-math/examples/copy-ready/07-de-70-30-nhap-in-hai-mat.typ).


## Hình học CeTZ nâng cao

Các hàm `draw-*` được gọi bên trong `cetz.canvas`:

```typ
#import "@preview/cetz:0.5.2"
#import "@preview/sang-math:1.1.1": draw-ellipse, draw-cylinder

#cetz.canvas({
  draw-ellipse(a: 2, b: 1, show-axes: true, show-foci: true)
})

#cetz.canvas({
  draw-cylinder(radius: 1.4, height: 3.5, show-hidden: true)
})
```

## Ứng dụng cho Đa môn (Vật lí, Hóa học, KHTN)
Gói `sang-math` cung cấp khung đề thi chuẩn Bộ GD&ĐT 2025, hoàn toàn có thể dùng cho mọi môn học:
- **Vật lí**: Đổi `subject: "VẬT LÍ 12"`, sử dụng các ký hiệu `$ohm$`, `$doC$` hoặc `$mu"F"$.
- **Hóa học**: Kết hợp với gói công thức hóa học `@preview/typsium:0.3.2`:
```typ
#import "@preview/sang-math:1.1.1": *
#import "@preview/typsium:0.3.2": *

#show: exam-classic.with(subject: "HÓA HỌC 12", duration: "50 phút")

#exam-part([PHẦN I. Trắc nghiệm 4 lựa chọn])
#tn([Chất nào là este no, đơn chức, mạch hở?], (
  [#ce("CH3COOH")],
  True([#ce("CH3COOC2H5")]),
  [#ce("CH2=CHCOOCH3")],
  [#ce("HCOOCH=CH2")],
))
```

## Tạo đề bằng AI (ChatGPT / Claude / Gemini)
Để AI hỗ trợ soạn đề tự động đúng 100% cú pháp `sang-math:1.0.6`, xem hướng dẫn và sao chép System Prompt chuẩn tại [`PROMPT_AI_TAO_DE.md`](https://github.com/sangnhc87/conictypst/blob/14b296889533c8b1897e5bebbfec499de7c5a932/typst-pkg-sang-math/PROMPT_AI_TAO_DE.md).

## Phát triển và kiểm thử

```bash
typst compile --root . examples/exam-template-demo.typ
typst compile --root . examples/book-template-demo.typ
typst compile --root . tests/test-public-api.typ
```

Các thay đổi phá vỡ tên hoặc chữ ký macro phải dành cho phiên bản major mới. Tính năng mới nên được export từ `lib.typ`, có ví dụ tối thiểu và có bài kiểm thử compile.

## License

MIT © Nguyễn Văn Sang

## Thư viện phiếu OMR A5/A4 (1.1.1)

```typ
#import "@preview/sang-math:1.1.1": sang-omr-sheet
#set page(paper: "a4", margin: 10mm)
#state("sbd").update("1001")
#state("made").update("0101")
#sang-omr-sheet(profile: "new-12-2-4-a5")
```

SBD `1001` được ghi/tô ở bốn cột đầu; hai cột cuối để học sinh điền. Mã đề là `0101`. Không đặt state thì các ô định danh để trống. Phiếu A5 giữ đủ 12 mốc, cần vùng chứa rộng 190 mm và cao 140 mm; không thu nhỏ phiếu. Hướng dẫn đầy đủ, danh sách 24 ID và các file include: [omr/README.md](omr/README.md).
