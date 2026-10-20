# sang-math

Bộ macro Typst dành cho Toán THPT Việt Nam: đề thi bốn dạng câu hỏi, sách/chuyên đề, bảng biến thiên, bảng xét dấu và hình học CeTZ.

- Hướng dẫn trực tuyến: https://hdsd-conictypst.pages.dev
- Mã nguồn: https://github.com/sangnhc87/conictypst
- Yêu cầu: Typst 0.14.0 trở lên (do `cetz 0.5.2`)

## Cài đặt

```typ
#import "@preview/sang-math:1.0.1": *
```

Khi chỉ dùng một nhóm chức năng, nên import đúng tên cần dùng để file dễ đọc và API rõ ràng:

```typ
#import "@preview/sang-math:1.0.1": tn, ds, tln, tl, True, sang-setup
```

## API chính

| Nhóm | Macro tiêu biểu |
|---|---|
| Đề thi | `tn`, `ds`, `tln`, `tl`, `exam-mode`, `exam-part`, `print-answer-key` |
| Giao diện đề | `exam-theme`, `exam-preset`, `exam-input-preset`, `exam-template-names` |
| Sách/chuyên đề | `book-theme`, `book-chapter`, `book-lesson`, các hộp sư phạm, `book-template-names` |
| Bảng Toán | `bbtv2`, `bbbt`, `bxd`, `bang-gia-tri`, `bang-phan-phoi`, `auto-bbt` |
| Hình học cơ bản | `tri-abc`, `tri-right`, `chop-sabc`, `circle-desc`, `axis-xy`, `plot` |
| Conic | `draw-parabola`, `draw-ellipse`, `draw-hyperbola` |
| Khối tròn xoay | `draw-cylinder`, `draw-cone`, `draw-sphere` |
| Đường cong 3D | `draw-helix`, `draw-spring` |
| Ký hiệu | `RR`, `ZZ`, `NN`, `QQ`, `Rightarrow`, `Leftrightarrow`, `vect`... |

`lib.typ` là cổng public duy nhất và hiện đã export cả template đề, template sách cùng các module CeTZ nâng cao. Người dùng không cần import đường dẫn nội bộ.

## Ví dụ đề thi

```typ
#import "@preview/sang-math:1.0.1": *

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

Các theme đề có thể lấy trực tiếp bằng `exam-template-names`; hiện gồm `classic`, `ocean`, `emerald`, `royal`, `violet`, `crimson`, `graphite`, `amber`, `teal-pro`, `sky`, `indigo-minimal`, `print-economy`, `aurora`, `lotus`, `navy-gold`, `jade`, `coral`, `plum`.

## Ví dụ sách/chuyên đề

```typ
#import "@preview/sang-math:1.0.1": *

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
#import "@preview/sang-math:1.0.1": bbtv2

#bbtv2(
  x-vals: ($-oo$, $-1$, $1$, $+oo$),
  d-signs: ("+", 0, "-", 0, "+"),
  v-vals: ($-oo$, $3$, $-1$, $+oo$),
)
```

## Hình học CeTZ nâng cao

Các hàm `draw-*` được gọi bên trong `cetz.canvas`:

```typ
#import "@preview/cetz:0.5.2"
#import "@preview/sang-math:1.0.1": draw-ellipse, draw-cylinder

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
