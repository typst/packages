# sang-math

A comprehensive package for Vietnamese high school mathematics, providing macros for:
- Sign tables and variation tables (Bảng biến thiên & Bảng xét dấu)
- Multiple-choice questions (Trắc nghiệm)
- Geometry drawing via CeTZ (Hình học phẳng & không gian)

📖 **Full documentation / Hướng dẫn sử dụng:** [https://hdsd-sang-math.pages.dev](https://hdsd-sang-math.pages.dev)

## Usage

```typ
#import "@preview/sang-math:1.0.0": *
```

### 1. Variation Tables (Bảng biến thiên)

```typ
#bbtv2(
  x-vals: ($-oo$, $-1$, $1$, $+oo$),
  d-signs: ("+", 0, "-", 0, "+"),
  v-vals: ($-oo$, $3$, $-1$, $+oo$),
)
```

### 2. Sign Tables (Bảng xét dấu)

```typ
#bxd(
  x-vals: ($-oo$, $-2$, $1$, $+oo$),
  rows: (
    ($x + 2$, "-", z, "+", "|", "+"),
    ($x - 1$, "-", "|", "-", z, "+"),
    ($f(x)$,  "+", z, "-", z, "+"),
  ),
)
```

### 3. Multiple Choice Questions (Trắc nghiệm)

```typ
#show: sang-setup

#tn(
  [Đạo hàm của hàm số $f(x) = x^3 - 3x + 1$ tại $x = 2$ bằng],
  ([$3$], True([$9$]), [$6$], [$-3$]),
  loigiai: [$f'(x) = 3x^2 - 3 Rightarrow f'(2) = 9$],
)
```

### 4. Mathematical Symbols

```typ
// Common mathematical symbols
$+oo$, $-oo$, $RR$, $ZZ$, $NN$, $QQ$
$=>$, $<=>$, $forall$, $exists$
```

### 5. Geometry (Hình học CeTZ)

```typ
#tri-abc()
```

## License

MIT © 2024 Sang Nguyen
