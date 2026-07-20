# sang-math

Bộ macro Typst dành cho Toán THPT Việt Nam: đề thi bốn dạng câu hỏi, sách/chuyên đề, bảng biến thiên, bảng xét dấu và hình học CeTZ.

- Hướng dẫn trực tuyến: https://hdsd-conictypst.pages.dev
- Mã nguồn: https://github.com/sangnhc87/conictypst
- Yêu cầu: Typst 0.14.0 trở lên (do `cetz 0.5.2`)

## Cài đặt

```typ
#import "@preview/sang-math:1.0.2": *
```

Khi chỉ dùng một nhóm chức năng, nên import đúng tên cần dùng để file dễ đọc và API rõ ràng:

```typ
#import "@preview/sang-math:1.0.2": tn, ds, tln, tl, True, sang-setup
```

## API chính

| Nhóm | Macro tiêu biểu |
|---|---|
| Đề thi | `tn`, `ds`, `tln`, `tl`, `exam-mode`, `exam-part`, `print-answer-key` |
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

## Ví dụ đề thi

```typ
#import "@preview/sang-math:1.0.2": *

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

Thư mục [`examples/copy-ready`](./examples/copy-ready) có các mẫu chạy sẵn cho
đề 15 phút, giữa kỳ hỗn hợp, cấu trúc THPT 12–4–6, đề tự luận có nháp, phiếu học
tập và câu có bảng biến thiên/CeTZ. Xem bảng chọn mẫu tại
[`examples/README.md`](./examples/README.md).

Giáo viên dùng AI/OCR để tạo hoặc chuyển đề có thể sao chép bộ hướng dẫn tại
[`PROMPT_AI_TAO_DE.md`](./PROMPT_AI_TAO_DE.md). Prompt quy định đúng chữ ký
`tn/ds/tln/tl`, ID ổn định, cú pháp toán Typst và bước tự kiểm tra đáp án.

Các theme đề có thể lấy trực tiếp bằng `exam-template-names`; hiện gồm `classic`, `ocean`, `emerald`, `royal`, `violet`, `crimson`, `graphite`, `amber`, `teal-pro`, `sky`, `indigo-minimal`, `print-economy`, `aurora`, `lotus`, `navy-gold`, `jade`, `coral`, `plum`.

## Ví dụ sách/chuyên đề

```typ
#import "@preview/sang-math:1.0.2": *

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

## Bảng biến thiên

```typ
#import "@preview/sang-math:1.0.2": bbtv2

#bbtv2(
  x-vals: ($-oo$, $-1$, $1$, $+oo$),
  d-signs: ("+", 0, "-", 0, "+"),
  v-vals: ($-oo$, $3$, $-1$, $+oo$),
)
```

## Đề 70/30 có nháp khi in hai mặt

```typ
#import "@preview/sang-math:1.0.2": layout-draft

#show: layout-draft.with(
  nháp-pct: 30%,
  accent: rgb("#117a65"),
)

Nội dung đề thi...
```

Trang lẻ đặt vùng nháp bên phải, trang chẵn đặt vùng nháp bên trái. Lề nội dung
dùng cơ chế `inside`/`outside` nên tự đảo đúng khi in hai mặt. Mẫu đầy đủ nằm tại
[`examples/copy-ready/07-de-70-30-nhap-in-hai-mat.typ`](./examples/copy-ready/07-de-70-30-nhap-in-hai-mat.typ).


## Hình học CeTZ nâng cao

Các hàm `draw-*` được gọi bên trong `cetz.canvas`:

```typ
#import "@preview/cetz:0.5.2"
#import "@preview/sang-math:1.0.2": draw-ellipse, draw-cylinder

#cetz.canvas({
  draw-ellipse(a: 2, b: 1, show-axes: true, show-foci: true)
})

#cetz.canvas({
  draw-cylinder(radius: 1.4, height: 3.5, show-hidden: true)
})
```

## Phát triển và kiểm thử

```bash
typst compile --root . examples/exam-template-demo.typ
typst compile --root . examples/book-template-demo.typ
typst compile --root . tests/test-public-api.typ
```

Các thay đổi phá vỡ tên hoặc chữ ký macro phải dành cho phiên bản major mới. Tính năng mới nên được export từ `lib.typ`, có ví dụ tối thiểu và có bài kiểm thử compile.

## License

MIT © Nguyễn Văn Sang
