# Typst Pointless Size——字号 zìhào

中文字号的号数制及字体度量单位。
Chinese size system (hào-system) and type-related measurements units.

```typst
#import "@preview/pointless-size:0.1.1": zh, zihao

#set text(size: zh(5)) // 五号（10.5pt）
// or
#set text(zh(5))
#show: zihao(5)

// 小号用负数表示 use negative numbers for small sizes 
#zh(-4) // 小四（12pt）
#zh(1) // 一号（26pt）
#zh(-1) // 小一（24pt）
#zh("-0") // 小初（36pt）
#zh(0) // 初号（42pt）

// 写汉字也可以 Han characters are also acceptable
#zh("五号")
#zh("五")
#zh("小五")
```

![zihao](https://github.com/user-attachments/assets/585d3016-5e7e-46fe-8e16-befcfe1ee6a3)
<!--
#import "@preview/pointless-size:0.1.0": zh

#set page(width: auto, height: auto, margin: 1em)

#table(
  columns: 3,
  align: left + horizon,
  stroke: none,
  table.hline(),
  [号数], [点数], [意义],
  table.hline(stroke: 0.5pt),
  ..(
    (0, "初号"),
    ("-0", "小初"),
    ..range(1, 9).map(n => (
      (n, numbering("一号", n)),
      ..if n < 7 {
        (-n, numbering("小一", n))
      },
    )),
  ).flatten().chunks(2).map(((n, t)) => (
    raw("zh(" + repr(n) + ")", lang: "typst"),
    [#zh(n)],
    text(zh(n), t),
  )).flatten(),
  table.hline(),
)
-->

## 覆盖定义 Override

字号没有统一规定，本包默认与 [CTeX、MS Word、WPS、Adobe 的中文规则][docs-ref]一致。
Chinese size systems were not standardized. By default, this package is consistent with [Chinese rules of CTeX, MS Word, WPS, Adobe][docs-ref].

如想覆盖定义：If you want to override:

```typst
#import "@preview/pointless-size:0.1.1": zh as _zh

#let zh = _zh.with(overrides: ((7, 5.25pt),))

#assert.eq(_zh(7), 5.5pt)
#assert.eq(zh(7), 5.25pt)
```

[docs-ref]: https://github.com/YDX-2147483647/typst-pointless-size/blob/main/docs/ref.md
