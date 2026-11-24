# sang-math

A comprehensive Typst package for typesetting Vietnamese High School Mathematics documents, exams, and presentations.

- Hướng dẫn trực tuyến: https://hdsd-conictypst.pages.dev
- Mã nguồn: https://github.com/sangnhc87/conictypst
- Yêu cầu: Typst 0.14.0 trở lên

## Tính năng nổi bật

- **Đề thi**: Macros tạo câu hỏi trắc nghiệm (MCQ), Đúng/Sai và đáp án.
- **Ký hiệu Toán**: Phím tắt cho các ký hiệu Toán phổ biến tại Việt Nam.
- **Bảng biến thiên**: Vẽ bảng xét dấu và bảng biến thiên tuyệt đẹp cho hàm số.
- **Hình học**: Các wrapper tích hợp sẵn cho CeTZ giúp vẽ hình 2D, 3D dễ dàng.
- **Trình chiếu (Beamer)**: Tạo slide dạy toán học với hiệu ứng xuất hiện từng bước.
- **Sách & Chuyên đề**: Macro soạn thảo sách, tài liệu với các hộp định lý, định nghĩa đẹp mắt.
- **Layout in hai mặt**: `layout-draft` tạo trang 70/30 với lề nháp tự động đổi bên chẵn/lẻ.

## Cài đặt và Sử dụng cơ bản

```typ
#import "@preview/sang-math:1.0.4": *
```

Khi chỉ dùng một nhóm chức năng, nên import đúng tên cần dùng để file dễ đọc và API rõ ràng:

```typ
#import "@preview/sang-math:1.0.4": tn, ds, tln, tl, True, sang-setup
```

### Sử dụng Sách và Beamer (Mới ở v1.0.3)

Phiên bản 1.0.3 bổ sung các module chuyên sâu cho sách và bài giảng trình chiếu:

```typ
// Sử dụng module sách
#import "@preview/sang-math:1.0.4": book
#show: book.stexgv-book.with(title: "Chuyên đề Toán")

// Sử dụng module trình chiếu
#import "@preview/sang-math:1.0.4": beamer
#show: beamer.sang-beamer-theme.with(
  title: "Bài 1: Hàm số",
)
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

## Câu Đúng/Sai: bảng và các kiểu danh sách

`#ds` tiếp tục dùng bảng Đ/S theo mặc định, nên tài liệu từ `1.0.3` giữ nguyên
bố cục khi nâng cấp. Từ `1.0.4`, có thể chuyển nhanh sang danh sách a), b), c),
d) bằng `use-table: false`:

```typ
#ds(
  [Xét các phát biểu sau.],
  (True([Mệnh đề đúng.]), [Mệnh đề sai.]),
  use-table: false,
)
```

Tham số `ds-style` hỗ trợ `"table"`, `"list"`, `"pill"`, `"modern"`,
`"minimal"`, `"bookmark"`, `"folder"`, `"diamond"`, `"gradient"` và
`"checklist"`:

```typ
#ds(
  [Xét các phát biểu sau.],
  (True([Mệnh đề đúng.]), [Mệnh đề sai.]),
  ds-style: "bookmark",
)
```

Cú pháp cũ `table: false` vẫn được chấp nhận để các tài liệu và ví dụ đã lưu
không bị hỏng.

## Câu trả lời ngắn: hiện hoặc ẩn ô điền

Trong chế độ đề thi, `#tln` mặc định hiện bốn ô điền đáp án. Dùng
`box-count` để đổi số ô, hoặc `show-boxes: false` để ẩn toàn bộ cụm ô:

```typ
// Mặc định: hiện 4 ô
#tln([Tính $2+3$.], [$5$])

// Ẩn cụm ô, phù hợp khi muốn học sinh viết đáp án trên dòng
#tln(
  [Tính $2+3$.],
  [$5$],
  show-boxes: false,
  lines: 2,
)

// Tuỳ chỉnh số ô
#tln([Ghi kết quả dưới dạng sáu ký tự.], [123456], box-count: 6)
```

## Ví dụ đề thi

```typ
#import "@preview/sang-math:1.0.4": *

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

## Hình học CeTZ nâng cao

Các hàm `draw-*` được gọi bên trong `cetz.canvas`:

```typ
#import "@preview/cetz:0.5.2"
#import "@preview/sang-math:1.0.4": draw-ellipse, draw-cylinder

#cetz.canvas({
  draw-ellipse(a: 2, b: 1, show-axes: true, show-foci: true)
})

#cetz.canvas({
  draw-cylinder(radius: 1.4, height: 3.5, show-hidden: true)
})
```

## Tác giả (Author)
- **Tên:** Nguyễn Văn Sang
- **Công việc:** Giáo viên Toán tại Trường THPT Nguyễn Hữu Cảnh - TP. HCM
- **Email:** nguyensangnhc@gmail.com
- **Facebook:** [Nguyễn Văn Sang](https://www.facebook.com/nguyenvan.sang.92798072/)

## Ủng hộ dự án (Donate)
Nếu bạn thấy thư viện này hữu ích cho công việc giảng dạy và soạn thảo tài liệu Toán học, bạn có thể ủng hộ tác giả qua:

- **Ngân hàng VPBank:** Số tài khoản `10389821115` - Chủ tài khoản: NGUYEN VAN SANG
<img src="https://img.vietqr.io/image/vpbank-10389821115-compact.jpg" width="300" alt="VPBank QR Code">

## License

MIT © Nguyễn Văn Sang
