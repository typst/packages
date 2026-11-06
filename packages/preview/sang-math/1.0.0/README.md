# sang-math

A comprehensive Typst toolkit designed primarily for typesetting high school mathematics and general mathematical documents (focused on the Vietnamese curriculum).

Bộ macro Toán THPT Việt Nam — Bảng biến thiên, Bảng xét dấu, Trắc nghiệm, Hình học CeTZ.

📖 Tài liệu đầy đủ: https://hdsd-conictypst.pages.dev

## Cài đặt

```typ
#import "@preview/sang-math:1.0.0": *
```

## Các macro chính

### 1. Bảng biến thiên (`bbtv2`)

```typ
#import "@preview/sang-math:1.0.0": bbtv2

#bbtv2(
  x-vals: ($-oo$, $-1$, $1$, $+oo$),
  d-signs: ("+", 0, "-", 0, "+"),
  v-vals: ($-oo$, $3$, $-1$, $+oo$),
)
```

### 2. Bảng biến thiên đầy đủ (`bbbt`) — có hàng `f(x)` và `ranks`

```typ
#import "@preview/sang-math:1.0.0": bbbt

#bbbt(
  x-vals: ($-oo$, $0$, $+oo$),
  d-signs: ("-", z, "+"),
  v-vals: ($+oo$, $0$, $+oo$),
  ranks: ("CB", none, "CT"),
)
```

### 3. Bảng xét dấu (`bxd`)

```typ
#import "@preview/sang-math:1.0.0": bxd

#bxd(
  x-vals: ($-oo$, $-2$, $1$, $+oo$),
  rows: (
    ($x + 2$, "-", z, "+", "|", "+"),
    ($x - 1$, "-", "|", "-", z, "+"),
    ($f(x)$,  "+", z, "-", z, "+"),
  ),
)
```

### 4. Câu trắc nghiệm (`tn`)

```typ
#import "@preview/sang-math:1.0.0": tn, sang-setup, True

#show: sang-setup

#tn(
  [Đạo hàm của hàm số $f(x) = x^3 - 3x + 1$ tại $x = 2$ bằng],
  ([$3$], True([$9$]), [$6$], [$-3$]),
  loigiai: [$f'(x) = 3x^2 - 3 Rightarrow f'(2) = 9$],
)
```

### 5. Câu tự luận có lời giải (`tl`)

```typ
#import "@preview/sang-math:1.0.0": tl, sang-setup

#show: sang-setup

#tl(
  [Giải phương trình $2^x = 8$.],
  loigiai: [$2^x = 2^3 Rightarrow x = 3$],
)
```

### 6. Template đề thi đẹp

```typ
#import "@preview/sang-math:1.0.0": *

#let theme = "royal"
#let profile = "dethi" // "dethi" | "loigiai" | "compact" | "draft" | "beamer"
#let opt-style = auto // auto = "plain" = A. B. C. D.
// #let opt-style = "theme"  // theo theme
// #let opt-style = "circle" // khoanh tròn

#let preset = exam-preset(
  theme: theme,
  profile: profile,
  opt-style: opt-style,
)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: preset.accent)
#show: exam-theme.with(
  theme: preset.theme,
  school: "TRƯỜNG THPT SANG-MATH",
  exam-title: "ĐỀ THI THỬ THPT",
  subject: "TOÁN 12",
  duration: "90 phút",
  code: "101",
  ..preset.template,
)
```

Các theme có sẵn: `classic`, `ocean`, `emerald`, `royal`, `violet`, `crimson`, `graphite`, `amber`, `teal-pro`, `sky`, `indigo-minimal`, `print-economy`, `aurora`, `lotus`, `navy-gold`, `jade`, `coral`, `plum`.

Profile nhanh:

- `profile: "dethi"`: in đề học sinh.
- `profile: "loigiai"`: in đề có lời giải và tự bật bảng đáp án cuối đề.
- `profile: "compact"`: dàn 2 cột.
- `profile: "draft"`: thêm cột nháp bên phải từng câu.
- `profile: "beamer"`: bỏ header/trang in để cùng nội dung chuyển sang `sang-beamer.typ`.

Tùy chọn nổi bật:

- `mode: "dethi"` hoặc `"loigiai"` để in đề hoặc in kèm lời giải.
- `opt-style: auto` hoặc `"plain"` là kiểu nguyên thuỷ `A. B. C. D.`.
- `opt-style: "theme"` là tự lấy kiểu đẹp theo theme. Ví dụ `teal-pro` dùng `solid-pentagon`.
- `opt-style: "circle" | "double-circle" | "solid-circle" | "square" | "solid-square" | "rounded-square" | "diamond" | "solid-diamond" | "triangle" | "solid-triangle" | "pentagon" | "solid-pentagon" | "hexagon" | "solid-hexagon" | "badge"` cho nhãn A, B, C, D. Các kiểu cụ thể phải viết trong dấu nháy.
- `opt-label-color: rgb(...)` để ép màu riêng cho nhãn A, B, C, D.
- `q-label-style: "plain" | "pill" | "solid-pill" | "badge" | "ribbon" | "flag" | "underline" | "spark"` cho nhãn Câu.
- `show-tags: false` để ẩn tag phân loại ở mép phải.
- `draft: true`, `draft-width: 28%`, `draft-lines: 6` để thêm cột nháp bên phải từng câu.
- `two-columns: true` trong template để dàn đề 2 cột.
- `answer-key: true` trong template để in bảng đáp án cuối đề. Dùng `profile: "loigiai"` thì preset tự bật.

Mẫu công tắc ngay trong file:

```typ
#let profile = "dethi"       // đề học sinh
// #let profile = "loigiai"  // lời giải + bảng đáp án
// #let profile = "compact"  // đề 2 cột
// #let profile = "draft"    // có nháp bên phải
// #let profile = "beamer"   // sẵn chuyển sang slide

#let theme = "teal-pro"
// #let theme = "aurora"
// #let theme = "navy-gold"

#let opt-style = auto // nguyên thuỷ A. B. C. D.
// #let opt-style = "theme" // theo theme
// #let opt-style = "circle"
// #let opt-style = "hexagon"
// #let opt-style = "solid-hexagon"
```

File demo đầy đủ nằm tại `examples/exam-template-demo.typ`, gồm 12 câu trắc nghiệm, 4 câu đúng/sai, 6 câu trả lời ngắn và 3 câu tự luận.

Script kiểm tra nội bộ cho người phát triển package:

```bash
typst-pkg-sang-math/tests/compile-exam-templates.sh
```

### 7. Chế độ hiển thị đề thi (`exam-mode`)

```typ
#import "@preview/sang-math:1.0.0": exam-mode, sang-setup

#let (tn, ds, tln, tl) = exam-mode(mode: "dethi")
#show: sang-setup
```

### 8. Ký hiệu toán học tắt (`math-sym`)

```typ
#import "@preview/sang-math:1.0.0": *

// Các ký hiệu: vô cực, tập hợp, mũi tên...
$+oo$, $-oo$, $RR$, $ZZ$, $NN$, $QQ$
$=>$, $<=>$, $forall$, $exists$
```

### 9. Hình học CeTZ (`geometry`)

```typ
#import "@preview/sang-math:1.0.0": tri-abc

// Tam giác ABC với đỉnh tùy chỉnh
#tri-abc()
```

## Tùy chọn bbt-opt

```typ
#import "@preview/sang-math:1.0.0": bbt-opt, bbtv2

// Đặt tùy chọn toàn cục
#bbt-opt(
  var: $t$,       // Tên biến (mặc định: $x$)
  der: $f'(t)$,   // Ký hiệu đạo hàm
  func: $f(t)$,   // Tên hàm số
  w1: 1.2,        // Chiều rộng cột tên
  w2: 12,         // Chiều rộng mỗi khoảng
)
```

## License

MIT © 2024 Sang Nguyen
